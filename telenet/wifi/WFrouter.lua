comp =require("component")
event=require("event")
local TNport=1

if not comp.isAvailable("modem") then
  error("Сетевая карта не обнаружена")
end
modem=comp.modem
modem.open(TNport)
if not comp.isAvailable("tunnel") then
    error("TeleNet-карта не обнаружена")
end
TNcard=comp.tunnel

ok,err=TNcard.send("", "", "getip")
if not ok then  error(err)  end
local ev, addr, _, mess
repeat
  ev, addr, _, _, _, MyIP, _, mess = event.pull(3,"modem_message")
  if not ev then
      error("Нет ответа от proxy-сервера")
  end
until addr == TNcard.address and mess=="setip"
print("IP",MyIP)

Clients={}
local localAdr, senderAdr, recIP, sendIP, command
function send(recIP, sendIP, ...)
  local client=recIP:match("^"..MyIP.."%.([^%.]+)")
  if client then
    if Clients[client] then
	  modem.send(Clients[client], TNport, recIP, sendIP, ...)
	else
	  send(sendIP,MyIP,false,"Недоступный адрес "..recIP)
	end
  else
    TNcard.send(recIP, sendIP, ...)
  end
end

commands={}
function commands.ping()
  return "pong"
end

function commands.ver()
  return "WiFi router ver 1.0"
end

function commands.getip()
  if localAdr==modem.address then
    local adr=senderAdr:sub(1,3)
    print("getip",adr)
	  Clients[adr]=senderAdr
    send(MyIP.."."..adr, MyIP, "setip" )
    return 
  else
    return("setip")
  end
end

while true do
  ev = {event.pull()}
  eventname = ev[1]
  if eventname=="modem_message" then
    localAdr, senderAdr, recIP, sendIP, command= ev[2], ev[3], ev[6], ev[7], ev[8]
	if recIP==MyIP or recIP=="" then
	  if commands[command] then
	    if sendIP=="" then commands[command](table.unpack(ev,9))
		else
	      send(sendIP, MyIP, commands[command](table.unpack(ev,9)) )
		end
	  end
	else
	  send(recIP,sendIP,table.unpack(ev,8))
	end
  elseif eventname=="key_up" then
    local key=ev[4]
	if key==20 then -- T
	  print("Роутер "..MyIP,"Локальные клиенты:")
	  for k,v in pairs(Clients) do print(k, v) end
	elseif key==16 then --Q
	  break
	end
  end
end