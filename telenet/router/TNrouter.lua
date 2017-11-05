event  = require('event')
comp   = require('component')
thread = require('thred')
computer=require('computer')

if not comp.isAvailable("modem") then
  print("Сетевая карта не найдена")
  return
end
modem = comp.modem
LocalIP=modem.address:sub(1,3)
TNport = 1
BCport = 2
modem.open(TNport)
modem.open(BCport)

Tunnels = {}
for address in comp.list('tunnel') do
  Tunnels[address:sub(1,3)]=comp.proxy(address)
end

Routers = {}
DNS = {}

thread.init()
thread.create(
  function ()
    while true do
	  modem.broadcast(BCport,"",LocalIP,"refresh")
	  local rout=next(Routers)
	  while rout do
	    Routers[rout].t=Routers[rout].t-1
		if Routers[rout].t <=0 then
          Routers[rout],rout=nil,next(Routers,rout)
		else
		  rout=next(Routers,rout)
		end
	  end
	  local dns=next(DNS)
	  while dns do
	    DNS[dns].t=DNS[dns].t-1
		if DNS[dns].t <=0 then
          DNS[dns],dns=nil,next(DNS,dns)
		else
		  dns=next(DNS,dns)
		end
	  end
	  os.sleep(300)
	end
  end
)

local function sendtoIP(recIP, sendIP, ... )
  local proxy,adr = recIP:match("([^%.]*)%.?([^%.]*)")
  if proxy==LocalIP then
    if Tunnels[adr] then
	  Tunnels[adr].send(recIP, sendIP, ... )
	  return true
	end
  else
    if Routers[proxy] then
	  modem.send(Routers[proxy].adr,TNport,recIP, sendIP, ... )
	  return true
	end
  end
  return false
end

function send(recIP, sendIP, ... )
  if sendtoIP(recIP, sendIP, ... ) then return end
  if DNS[recIP] then sendtoIP(DNS[recIP].adr.."."..recIP, sendIP, ...) return end
  if Routers.dns then
    print("Запрос DNS",recIP)
    DNSrec=recIP DNSsend=sendIP DNSdat={...}
    return sendtoIP("dns", LocalIP, "DNStoIP",recIP)
  end
  sendtoIP(sendIP,LocalIP,false,"Недоступный адрес "..recIP)
end

commands={}
function commands.ping(localAdr, senderAdr, sendIP)
  send(sendIP,LocalIP,"pong")
end

function commands.getip(localAdr)
  local adr=localAdr:sub(1,3)
  print("getip",localAdr)
  if Tunnels[adr] then
    Tunnels[adr].send(LocalIP.."."..adr, LocalIP, "setip")
  end
end

function commands.refresh(localAdr, senderAdr, sendIP)
  Routers[sendIP]={t=5,adr=senderAdr}
end

function commands.DNStoIP(localAdr, senderAdr, sendIP, Name, IP)
--  print("Name",Name,"IP",IP)
--  print(DNSrec,DNSsend,table.unpack(DNSdat))
  if sendIP=="dns" and Name==DNSrec then
    if IP then
	  DNS[Name]={t=5, adr=IP}
	  send(DNSrec,DNSsend,table.unpack(DNSdat))
	else
	  send(DNSsend,LocalIP,false,"DNS-имя не найдено "..DNSrec)
	end
  end
  DNSrec=nil
  DNSsend=nil
  DNSdat=nil
end

while true do
  ev = {event.pull()}
  eventname = ev[1]
  if eventname=="modem_message" then
    local localAdr, senderAdr, recIP, sendIP, command= ev[2], ev[3], ev[6], ev[7], ev[8]
	if recIP==LocalIP or recIP=="" then
	  if commands[command] then commands[command](localAdr, senderAdr, sendIP, table.unpack(ev,9)) end
	else
	  send(recIP,sendIP,table.unpack(ev,8))
	end
  elseif eventname=="key_up" then
    local key=ev[4]
	if key==19 then -- R
	  print("Роутер "..LocalIP,"Соседние роутеры:")
	  for k,v in pairs(Routers) do print(k, v.t, v.adr) end
	elseif key==20 then -- T
	  print("Роутер "..LocalIP,"Связанные платы:")
	  for k,v in pairs(Tunnels) do print(k, v.address) end
	elseif key==21 then --M
      print("Свободная память",computer.freeMemory(),"Общая память",computer.totalMemory())
	elseif key==16 then --Q
	  break
	else
	  print("key",key)
	end
  end
end

thread.killAll()
modem.close()