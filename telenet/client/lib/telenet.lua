local component=require("component")
local event = require("event")

local telenet = {}
local TNcard
local LocalIP
local Router
local TNport=1

function telenet.ver()
  return "1.0"
end

function telenet.getIP()
  if not component.isAvailable("modem") then
    TNcard=nil
    return nil, "Сетевая карта не обнаружена"
  end
  TNcard=component.modem
  TNcard.open(TNport)
  local ok,err=TNcard.broadcast(TNport,"", "", "getip")
  if not ok then  return ok, err  end
  local Dist=math.huge
  LocalIP=nil
  Router=nil
  while true do
    local ev, addr, rout, _, dist, locip, _, mess = event.pull(1,"modem_message")
    if ev then
      if dist<Dist and addr == TNcard.address and mess == "setip" then
  	    LocalIP=locip Router=rout Dist=dist
	  end
	else
	  if LocalIP then return LocalIP, Dist
	  else  return nil, "Нет ответа от WiFi роутера" end
    end
  end
end

function telenet.send(recIP, ... )
  if not TNcard or not Router then
    return nil, "Сетевая карта не инициализирована"
  end
  return TNcard.send(Router, TNport, recIP, LocalIP, ...)
end

function telenet.receive(timeout)
  local ev
  repeat
    ev = {event.pull(timeout,"modem_message")}
    if not ev[1] then return nil end
	  if ev[2] == TNcard.address and ev[8]=="ping" then
	    telenet.send(ev[7], "pong" )
	    ev[2]=nil
	  end
  until ev[2] == TNcard.address
  return table.unpack(ev,7)
end

function telenet.sendrec(recIP, ... )
  local ok,err=telenet.send(recIP, ... )
  if ok then
    return telenet.receive(10)
  else
    return ok,err
  end
end

-----------------------------------------------------------------------
return telenet