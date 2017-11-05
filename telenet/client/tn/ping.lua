local name=...
if not name then
  print("Использование: ping <адрес>")
  return
end
local tn=require"telenet"
local uptime=require("computer").uptime

local MyIP,err=tn.getIP()
if not MyIP then
  error(err)
end
print("Локальный адрес: "..MyIP)
print("Обмен пакетами с "..name)
for i=1,4 do
  local start=uptime()
  local addr,ansv1,ansv2=tn.sendrec(name,"ping")
  if addr then
    if ansv1=="pong" then
      print("Ответ от "..addr.." ","время="..tostring(uptime()-start))
	else
      print("Ответ от "..addr.." ",ansv1 or ansv2)
	end
  else
    print("Таймаут ожидания")
  end
end