local w,C,fa,ka,oa,ra,ua,va,xa,ya,za,Aa,Ca,Da,Ea,Fa,Ja,Ka,Na,Oa,Pa,Qa,Ra,Sa=gpu,lines,term,tags,require,string,0xFFFFFF,winshift,math,winwrite,winhead,0x000000,tonumber,wintext,false,load,tostring,winclear,computer,htmltext,"key_down","component","download","Telenet Explorer 1"w=oa(Qa).gpu
kbd=oa(Qa).keyboard
Na=oa("computer")fs=oa("filesystem")text=oa("text")fa=oa("term")wlen=oa("unicode").wlen
event=oa("event")on=oa("telenet")local
W,M=1,1
local ma=0
local la=0
local Ia,sa=1,3
local U,wa=w.getResolution()wa=wa-sa+1
local Ma=Sa
local ea=""
local Ba=ua
local Ha=Aa
local Ta=0x0080FF
local na={}
local ta={}
function za()
    w.setForeground(ua)
    w.setBackground(0x0000FF)
    w.fill(1,1,U,1," ")
    w.set(2,1,Ma)
    w.setBackground(0x00FF00)
    w.set(U-8,1," S ")
    w.setBackground(0x0080FF)
    w.set(U-5,1," < ")
    w.setBackground(0xFF0000)
    w.set(U-2,1," X ")
    w.setForeground(Aa)
    w.setBackground(ua)
    w.fill(1,2,U,1," ")
    w.set(2,2,ea)
    w.setForeground(Ba)
    w.setBackground(Ha)
end
function ya(X)
    X=text.detab(Ja(X))
    if wlen(X)==0 then
        return
    end
    local B,ja
    repeat
    if M>wa then
        return
    end
    B,X,ja = text.wrap(X,U-(W-2),U)
    if M>=1 then
        w.set(W+Ia-1-ma,M+sa-1,B)
    end
    W = W+wlen(B)
    if ja or(W > U) then
        W=1
        M=M+1
    end
    until not X
end
function Ka()
    ta={}w.fill(Ia,sa,U,wa," ")
    W,M=1,1
end
ka={}ka['html']=function(X)
    if X.caption then
        Ma=X.caption
        za()
    end
    local B=Ca(X.color)
    if B then
        Ba=B
        w.setForeground(B)
    end
    B=Ca(X.bgcolor)
    if B then
        Ha=B
        w.setBackground(B)Ka()
    end
end
ka['font']=function(X)
    local B=Ca(X.color)
    if B then
        w.setForeground(B)
    end
    B=Ca(X.bgcolor)
    if B then
        w.setBackground(B)
    end
end
ka['/font']=function()w.setForeground(Ba)w.setBackground(Ha)end
ka['cr']=function()M=M+1
W=1
end
ka['---']=function()if
W>1
then
M=M+1
W=1
end
ya(ra.rep('─',U))end
ka['===']=function()if
W>1
then
M=M+1
W=1
end
ya(ra.rep('═',U))end
local
function
X(B,ja,l)if
l>=B.y1
and
l<=B.y2
then
if(ja>=B.x1
or
l>B.y1)and(ja<=B.x2
or
l<B.y2)then
return
true
end
end
end
local
function
B(ja,l,v)return
v>=ja.y1
and
v<=ja.y2
and
l>=ja.x1
and
l<=ja.x2
end
local
function
ja(l)Fa(l.ref)end
ka['a']=function(l)if
l.ref
then
table.insert(ta,{check=X,x1=W+Ia-1-ma,y1=M+sa-1,work=ja,ref=l.ref,col=w.getForeground()})end
local
v=Ca(l.color)or
Ta
w.setForeground(v)end
ka['/a']=function()local
l=ta[#ta]if
l
and
not
l.x2
then
w.setForeground(l.col
or
Ba)l.x2,l.y2=W+Ia-2-ma,M+sa-1
end
end
function
tagWork(l)local
v=l:match('%S+')if
ka[v]then
local
H={}for
R,ba
in
l:gmatch('(%w+)=([^%s"]+)')do
H[R]=ba
end
for
R,ba
in
l:gmatch('(%w+)="([^"]+)"')do
H[R]=ba
end
ka[v](H)else
ya('<'..l..'>')end
end
function
winline(l)if
l
then
M=l.Y-la
W=l.X
local
v=l.text
while
ra.len(v)>0
do
local
H,R
H=v:find("<")if
H
then
R=v:find(">",H)end
if
R
then
ya(v:sub(1,H-1))tagWork(v:sub(H+1,R-1))v=v:sub(R+1)else
ya(v)v=""end
end
if
M<=wa
then
return
true
end
end
end
function
Oa()Ka()local
l=1
for
v=#C,1,-1
do
if
C[v].Y<=la
then
l=v
break
end
end
while
winline(C[l])do
l=l+1
if
C[l]then
C[l].Y=la+M
C[l].X=W
end
end
end
function
codetext()Ka()for
l=1,wa
do
if
C[l+la]then
w.set(1-ma,l+sa-1,C[l+la].text)else
break
end
end
end
Da=Oa
function
va(l,v)ma=ma+l
la=la+v
if
ma<0
then
ma=0
end
if
la<0
then
la=0
end
Da()end
function
Fa(l)if
l==''or
l==nil
or
l=="\n"then
za()return
end
if
l:sub(-1)=="\n"then
l=l:sub(1,-2)end
C={}ma=0
la=0
Ma=Sa
Ba=ua
Ha=Aa
if
l:sub(1,1)=="."then
while
l:sub(1,1)=="."do
ea=ea:match("(.+)/.*")or
ea
l=l:sub(2)end
ea=ea..l
else
ea=l
end
local
v,H=ea:match('(.-)/(.*)')if
not
v
then
v=ea
H=nil
end
if
v==""then
local
R=io.open(ea,"r")if
R
then
for
ba
in
R:lines()do
C[#C+1]={X=1,Y=xa.huge,text=ba}end
R:close()else
C[1]={X=5,Y=1,text="<html>Файл <font color=0xFF0000>"..ea.."</font> не найден"}end
else
local
R,ba=on.getIP()if
R
then
on.send(v,"get",H)local
J,qa,da
repeat
J,qa,da=on.receive(3)until
qa=="get"or
not
qa
if
qa=="get"then
da=Ja(da)local
Ga=1
while#da>0
do
local
La=da:find("\n")if
La
then
C[Ga],da={X=1,Y=xa.huge,text=da:sub(1,La-1)},da:sub(La+1)else
C[Ga],da={X=1,Y=xa.huge,text=da},""end
Ga=Ga+1
end
else
if
J
then
C[1]={X=1,Y=xa.huge,text="Ответ от узла "..Ja(J)}C[2]={X=1,Y=xa.huge,text=Ja(da)}else
C[1]={X=1,Y=xa.huge,text="Таймаут ожидания"}end
end
else
C[1]={X=5,Y=1,text="<html>Ошибка подключения к сети OpenNet: <font color=0xFF0000>"..ba.."</font>"}end
end
Da=codetext
if
C[1]then
C[1].Y=1
if
ra.find(C[1].text,"<%s*html.*>")then
Da=Oa
end
end
if
na[#na]~=ea
then
table.insert(na,ea)end
za()Da()end
local
l=true
function
read()w.setForeground(Aa)w.setBackground(ua)fa.setCursor(1,2)fa.clearLine()fa.setCursor(2,2)Fa(fa.read(na,Ea))end
function
save()if
kbd
then
w.setForeground(Aa)w.setBackground(ua)fa.setCursor(1,2)fa.clearLine()fa.setCursor(2,2)fa.write("Safe as: ")Na.pushSignal(Pa,kbd.address,0,200)local
v=fa.read({"/download/"..ea:match("[^/]*$")},Ea):sub(1,-2)if
v~=""then
if
not
fs.exists(Ra)then
fs.makeDirectory(Ra)end
local
H=io.open(v,"w")if
H
then
for
R=1,#C-1
do
H:write(C[R].text.."\n")end
H:write(C[#C].text)H:close()else
fa.clearLine()fa.setCursor(2,2)fa.write("File "..v.." can't be saved")Na.beep()os.sleep(2)end
end
za()end
end
function
back()if#na>1
then
na[#na]=nil
Fa(na[#na])end
end
function
quit()w.setForeground(ua)w.setBackground(Aa)fa.clear()l=Ea
end
do
local
v=...if
v
then
Fa(v)else
za()read()end
end
local
v=Ea
while
l
do
local
H,R,ba,J,qa=event.pull()if
H=="scroll"and
J>=sa
then
if
v
then
va(-5*qa,0)else
va(0,-3*qa)end
end
if
H==Pa
then
if
J==208
then
va(0,3)end
if
J==200
then
va(0,-3)end
if
J==203
then
va(-5,0)end
if
J==205
then
va(5,0)end
if
J==29
then
v=true
end
if
J==15
then
read()end
if
v
and
J==31
then
save()end
if
J==14
then
back()end
if
v
and
J==17
then
quit()end
end
if
H=="key_up"and
J==29
then
v=Ea
end
if
H=="touch"and
qa==0
then
if
J==1
then
if
ba>=U-8
and
ba<=U-6
then
save()end
if
ba>=U-5
and
ba<=U-3
then
back()end
if
ba>=U-2
then
quit()end
elseif
J==2
then
read()else
for
da=1,#ta
do
if
ta[da]:check(ba,J)then
ta[da]:work()break
end
end
end
end
end