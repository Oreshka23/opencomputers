-- p2p network
--
-- Telenet X Generation

local event = require("event")
local component = require("component")
local computer = require("computer")

local modem = component.modem
local tn = {}

local PORT = 420
local CODES = {
  send = "tn/send",
  ping = "tn/ping",
  pong = "tn/pong"
}

local FLAGS = {}

-- How long does this node remember transferred message hash (in-game seconds)
-- (Used to kill all possible dublicates)
local HASHLIFETIME = 43200

local isConnected = false


-- Session ---------------------------------------------------------------------

local hashes = {}

local function getTime()
  return tonumber(tostring(os.clock()):gsub("%.",""),10)
end

local function hashgen(time, data)
  return string.char(math.random(0, 255), math.random(0, 255),
                     math.random(0, 255), math.random(0, 255))
end

local function check(hash)
  local time = computer.uptime()
  for k, v in pairs(hashes) do
    if time - v > HASHLIFETIME then
      hashes[k] = nil
    end
  end
  if not hashes[hash] then
    hashes[hash] = computer.uptime()
    return true
  end
  return hashes[hash] == nil
end

local function parseFlags(str)
  local flags = {}
  for n = 1, #str, 1 do
    local b = str:sub(n, n)
    local flag
    for k, v in pairs(FLAGS) do
      if v == b then
        flag = k
      end
    end
    if flag then
      table.insert(flags, flag)
      flags[flag] = true
    end
  end
  return flags
end

local function packFlags(flags)
  local str = ""
  for k, v in pairs(flags) do
    if FLAGS[k] then
      str = str .. FLAGS[k]
    end
  end
  return str
end

local function send(selfAddress, address, message, hash, code, flags)
  local hash = hash or hashgen(getTime(), message)
  hashes[hash] = computer.uptime()
  modem.broadcast(PORT, code, address, selfAddress, hash, flags, message)
end

local function listener(name, receiver, sender, port, distance,
                        code, recvAddr, sendAddr, hash, flags, body)
  if receiver == zn.modem.address then
    if port == PORT and (
        code == CODES.send or
        code == CODES.pong or
        code == CODES.ping) then
      if code == CODES.ping then
        computer.pushSignal("tn_ping", sender, distance)
        modem.send(sender, PORT, CODES.pong)
        return true
      end
      if code == CODES.pong then
        computer.pushSignal("tn_pong", sender, distance)
        return true
      end
      if check(hash) then
        if recvAddr == zn.modem.address or recvAddr == "" then
          if code == CODES.send then
            computer.pushSignal("tn_message", body, recvAddr, sendAddr)
          end
        end
        if recvAddr ~= zn.modem.address then
          send(sendAddr, recvAddr, body, hash, code, flags)
        end
      end
    end
  end
end

telenet.ver = function()
  return "2.0"
end

telenet.connect = function()
  if isConnected then
    return false
  end
  math.randomseed(getTime())
  modem.open(PORT)
  event.listen("modem_message", listener)
  isConnected = true
  return true
end

telenet.disconnect = function()
  if not isConnected then
    return false
  end
  modem.close(PORT)
  event.ignore("modem_message", listener)
  isConnected = false
  return true
end

telenet.modem = component.modem

-- Messages --------------------------------------------------------------------

telenet.send = function(address, message)
  local hash = hashgen(getTime(), message)
  send(modem.address, address, message, hash, CODES.send, packFlags {})
  return true
end

telenet.broadcast = function(message)
  send(modem.address, "", message, nil, CODES.send, packFlags {})
  return true
end

telenet.ping = function()
  modem.broadcast(PORT, CODES.ping)
end

return zn