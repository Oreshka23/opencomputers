-- Web-server by Zer0Galaxy
tn = require("telenet")
fs = require("filesystem")
ser = require("serialization").serialize
webDir='/web/'
maxPacketSize=8000
pwd="parallel"

local myIP,err=tn.getIP()
if not myIP then
  print(err)
  return
end

local sendIP, command
commands={}
function commands.ping()
  return "pong"
end

function commands.ver()
  return "Web-server ver 1.2"
end

function commands.get(path)
  path=path or 'index'
  file=io.open(webDir..path,'r')
  if not file then file=io.open(webDir..'404','r') end
  if file then
    text=file:read("*a") file:close() 
  else 
    text="Файл "..path.." не найден"
  end
  if #text>maxPacketSize then text="Файл слишком большой" end
  return text
end

function commands.list(path)
  local result={}
  path=webDir..(path or "")
  for name in fs.list(path) do
    result[#result+1]=name
  end
  return ser(result)
end

function commands.put(path,text,passwd)
  if passwd==pwd then
    file=io.open(webDir..path,'w')
    if not file then return "Неверное имя файла" end
	file:write(text)
    file:close()
    return "Файл сохранен"
  end
  return "Неверный пароль"
end

print("Работает Web-server",myIP)
while true do
  local dat = {tn.receive()}
  sendIP, command = dat[1], dat[2]
  if command then
    if commands[command] then
      tn.send(sendIP, command, commands[command](table.unpack(dat,3)) )
    else
      tn.send(sendIP, false, command, "Недопустимая команда" )
	end
  end
end