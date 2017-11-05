tn = require"telenet"
term = require"term"
DNSserv = "dns"

MyIP,err=tn.getIP()
if not MyIP then error(err) end

function readIP()
  local ip
  repeat
    io.write("Введите IP-адрес или пустую строку для локального IP: ")
    ip=io.read()
	if ip=="" then ip=MyIP end
	if not ip:find(" ") then break end
	print("IP-адрес не должен содержать пробелы")
  until false
  return ip
end

function checkDNS()
  local dns,serv,command,name,ip
  repeat
    io.write("Введите DNS-имя: ")
    dns=io.read()
	if not (dns:find(" ") or dns=="") then break end
	print("DNS-имя не должно содержать пробелы")
  until false
  tn.send(DNSserv,"DNStoIP",dns)
  repeat
    serv,command,name,ip=tn.receive(10)
	if not serv then
	  print("DNS-сервер не отвечает")
	  return
	end
  until command=="DNStoIP"
  if ip then
    print("DNS-имя "..dns.." зарегистрировано на IP-адрес "..ip)
  else
    print("DNS-имя "..dns.." не зарегистрировано")
  end
  return dns, ip
end

function checkIP()
  local ip=readIP()
  local dat
  tn.send(DNSserv,"IPtoDNS",ip)
  repeat
    dat={tn.receive(10)}
	if not dat[1] then
	  print("DNS-сервер не отвечает")
	  return
	end
  until dat[2]=="IPtoDNS"
  if #dat>3 then
    print("IP-адрес "..ip.." ассоциирован с DNS-именами:")
	print(table.unpack(dat,4))
  else
    print("IP-адрес "..ip.." не ассоциирован с DNS-именем")
  end
end

function changeDNS()
  local dns,ip=checkDNS()
  if ip then
    io.write("Желаете откорректировать настройки DNS-имени? [y/n]")
	if io.read()~="y" then return end
  end
  newip=readIP()
  repeat
    io.write("Пароль: ") pwd1=term.read(nil,nil,nil,"*"):sub(1,-2)
    if ip then
      io.write("Желаете изменить пароль? [y/n]")
	  if io.read()=="y" then
        io.write("Новый пароль: ") pwd2=term.read(nil,nil,nil,"*"):sub(1,-2)
	  else
	    pwd2=nil
	  end
	  break
    else
      io.write("Повторите пароль: ") pwd2=term.read(nil,nil,nil,"*"):sub(1,-2)
	  if pwd1==pwd2 then pwd2=nil break end
    end
	print("Несовпадение пароля")
  until false
  tn.send(DNSserv,"setDNS",dns,newip,pwd1,pwd2)
  repeat
    serv,command,result,name,mess=on.receive(10)
	if not serv then
	  print("DNS-сервер не отвечает")
	  return
	end
  until command=="setDNS"
  print(name,mess)
end

function delDNS()
  print("Удаление зарегистрированного DNS-имени в настоящее время не реализовано")
end

while true do
  print()
  print("1. Проверка DNS-имени (получение IP по DNS)")
  print("2. Проверка IP-адреса (получение DNS по IP)")
  print("3. Создание/коррекция DNS-имени")
  print("4. Удаление DNS-имени")
  print("0. Выход из программы")
  n=io.read()
  if n=="0" then return end
  if n=="1" then checkDNS() end
  if n=="2" then checkIP() end
  if n=="3" then changeDNS() end
  if n=="4" then delDNS() end
end