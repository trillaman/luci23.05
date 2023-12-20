local a=require"luci.util"
local s=require"coroutine"
local e=require"table"
local o=require"lucihttp"
local e,n,r,i,d,h=_G.L,e,ipairs,pairs,type,error
module"luci.http"
HTTP_MAX_CONTENT=1024*100
function close()
e.http:close()
end
function content()
return e.http:content()
end
function formvalue(t,a)
return e.http:formvalue(t,a)
end
function formvaluetable(t)
return e.http:formvaluetable(t)
end
function getcookie(t)
return e.http:getcookie(t)
end
function getenv(t)
return e.http:getenv(t)
end
function setfilehandler(t)
return e.http:setfilehandler(t)
end
function header(t,a)
e.http:header(t,a)
end
function prepare_content(t)
e.http:prepare_content(t)
end
function source()
return e.http.input
end
function status(t,a)
e.http:status(t,a)
end
function write(a,t)
if t then
h(t)
end
return e.print(a)
end
function splice(e,t)
s.yield(6,e,t)
end
function redirect(t)
e.http:redirect(t)
end
function build_querystring(o)
local t,e,s,s={},1,nil,nil
for i,o in i(o)do
t[e+0]=(e==1)and"?"or"&"
t[e+1]=a.urlencode(i)
t[e+2]="="
t[e+3]=a.urlencode(o)
e=e+4
end
return n.concat(t,"")
end
urldecode=a.urldecode
urlencode=a.urlencode
function write_json(t)
e.printf('%J',t)
end
function urlencode_params(a)
local e,e
local e,t=1,{}
for i,a in i(a)do
if d(a)=="table"then
local n,n
for n,a in r(a)do
if t[1]then
t[e]="&"
e=e+1
end
t[e+0]=o.urlencode(i)
t[e+1]="="
t[e+2]=o.urlencode(a)
e=e+3
end
else
if t[1]then
t[e]="&"
e=e+1
end
t[e+0]=o.urlencode(i)
t[e+1]="="
t[e+2]=o.urlencode(a)
e=e+3
end
end
return n.concat(t,"")
end
context={
request={
formvalue=function(e,...)return formvalue(...)end;
formvaluetable=function(e,...)return formvaluetable(...)end;
content=function(e,...)return content(...)end;
getcookie=function(e,...)return getcookie(...)end;
setfilehandler=function(e,...)return setfilehandler(...)end;
message=e and e.http.message
}
}
