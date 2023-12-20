local u=require"io"
local x=require"math"
local b=require"table"
local z=require"debug"
local j=require"luci.debug"
local a=require"string"
local d=require"coroutine"
local e=require"luci.template.parser"
local k=require"luci.jsonc"
local i=require"lucihttp"
local q=require"ubus"
local l=nil
local s,r=getmetatable,setmetatable
local e,e,g,m=rawget,rawset,unpack,select
local o,t,p,y=tostring,type,assert,error
local w,h,E,v=ipairs,pairs,next,loadstring
local f,c,T=require,pcall,xpcall
local e,e=collectgarbage,get_memory_limit
module"luci.util"
s("").__mod=function(i,e)
local n,a
if not e then
return i
elseif t(e)=="table"then
local s,s
for a,i in h(e)do if t(e[a])=="userdata"then e[a]=o(e[a])end end
n,a=c(i.format,i,g(e))
if not n then
y(a,2)
end
return a
else
if t(e)=="userdata"then e=o(e)end
n,a=c(i.format,i,e)
if not n then
y(a,2)
end
return a
end
end
local function n(e,...)
local e=r({},{__index=e})
if e.__init__ then
e:__init__(...)
end
return e
end
function class(e)
return r({},{
__call=n,
__index=e
})
end
function instanceof(e,t)
local e=s(e)
while e and e.__index do
if e.__index==t then
return true
end
e=s(e.__index)
end
return false
end
function threadlocal(e)
return e or{}
end
function perror(e)
return u.stderr:write(o(e).."\n")
end
function dumptable(n,s,e,i)
e=e or 0
i=i or r({},{__mode="k"})
for h,n in h(n)do
perror(a.rep("\t",e)..o(h).."\t"..o(n))
if t(n)=="table"and(not s or e<s)then
if not i[n]then
i[n]=true
dumptable(n,s,e+1,i)
else
perror(a.rep("\t",e).."*** RECURSION ***")
end
end
end
end
function pcdata(e)
local t=f"luci.xml"
perror("luci.util.pcdata() has been replaced by luci.xml.pcdata() - Please update your code.")
return t.pcdata(e)
end
function urlencode(e)
if e~=nil then
local e=o(e)
return i.urlencode(e,i.ENCODE_IF_NEEDED+i.ENCODE_FULL)
or e
end
return nil
end
function urldecode(e,t)
if e~=nil then
local t=t and i.DECODE_PLUS or 0
local e=o(e)
return i.urldecode(e,i.DECODE_IF_NEEDED+t)
or e
end
return nil
end
function striptags(e)
local t=f"luci.xml"
perror("luci.util.striptags() has been replaced by luci.xml.striptags() - Please update your code.")
return t.striptags(e)
end
function shellquote(e)
return a.format("'%s'",a.gsub(e or"","'","'\\''"))
end
function shellsqescape(t)
local e
e,_=a.gsub(t,"'","'\\''")
return e
end
function shellstartsqescape(e)
res,_=a.gsub(e,"^%-","\\-")
return shellsqescape(res)
end
function split(e,o,t,n)
o=o or"\n"
t=t or#e
local a={}
local i=1
if#e==0 then
return{""}
end
if#o==0 then
return nil
end
if t==0 then
return e
end
repeat
local o,n=e:find(o,i,not n)
t=t-1
if o and t<0 then
a[#a+1]=e:sub(i)
else
a[#a+1]=e:sub(i,o and o-1)
end
i=n and n+1 or#e+1
until not o or t<0
return a
end
function trim(e)
return(e:gsub("^%s*(.-)%s*$","%1"))
end
function cmatch(t,a)
local e=0
for t in t:gmatch(a)do e=e+1 end
return e
end
function imatch(e)
if t(e)=="table"then
local t=nil
return function()
t=E(e,t)
return e[t]
end
elseif t(e)=="number"or t(e)=="boolean"then
local t=true
return function()
if t then
t=false
return o(e)
end
end
elseif t(e)=="userdata"or t(e)=="string"then
return o(e):gmatch("%S+")
end
return function()end
end
function parse_units(t)
local e=0
local o={
y=60*60*24*366,
m=60*60*24*31,
w=60*60*24*7,
d=60*60*24,
h=60*60,
min=60,
kb=1024,
mb=1024*1024,
gb=1024*1024*1024,
kib=1000,
mib=1000*1000,
gib=1000*1000*1000
}
for t in t:lower():gmatch("[0-9%.]+[a-zA-Z]*")do
local a=t:gsub("[^0-9%.]+$","")
local t=t:gsub("^[0-9%.]+","")
if o[t]or o[t:sub(1,1)]then
e=e+a*(o[t]or o[t:sub(1,1)])
else
e=e+a
end
end
return e
end
a.split=split
a.trim=trim
a.cmatch=cmatch
a.parse_units=parse_units
function append(e,...)
for o,a in w({...})do
if t(a)=="table"then
for a,t in w(a)do
e[#e+1]=t
end
else
e[#e+1]=a
end
end
return e
end
function combine(...)
return append({},...)
end
function contains(e,t)
for e,a in h(e)do
if t==a then
return e
end
end
return false
end
function update(a,e)
for t,e in h(e)do
a[t]=e
end
end
function keys(t)
local e={}
if t then
for t,a in kspairs(t)do
e[#e+1]=t
end
end
return e
end
function clone(i,a)
local o={}
for i,e in h(i)do
if a and t(e)=="table"then
e=clone(e,a)
end
o[i]=e
end
return r(o,s(i))
end
function _serialize_table(o,a)
p(not a[o],"Recursion detected.")
a[o]=true
local i=""
local n=""
local s=0
for e,n in h(o)do
if t(e)~="number"or e<1 or x.floor(e)~=e or(e-#o)>3 then
e=serialize_data(e,a)
n=serialize_data(n,a)
i=i..(#i>0 and", "or"")..
'['..e..'] = '..n
elseif e>s then
s=e
end
end
for e=1,s do
local e=serialize_data(o[e],a)
n=n..(#n>0 and", "or"")..e
end
return n..(#i>0 and#n>0 and", "or"")..i
end
function serialize_data(e,a)
a=a or r({},{__mode="k"})
if e==nil then
return"nil"
elseif t(e)=="number"then
return e
elseif t(e)=="string"then
return"%q"%e
elseif t(e)=="boolean"then
return e and"true"or"false"
elseif t(e)=="function"then
return"loadstring(%q)"%get_bytecode(e)
elseif t(e)=="table"then
return"{ ".._serialize_table(e,a).." }"
else
return'"[unhandled data type:'..t(e)..']"'
end
end
function restore_data(e)
return v("return "..e)()
end
function get_bytecode(e)
local o
if t(e)=="function"then
o=a.dump(e)
else
o=a.dump(v("return "..serialize_data(e)))
end
return o
end
function strip_bytecode(r)
local t,t,e,i,s,l,c,u=r:byte(5,12)
local o
if e==1 then
o=function(o,a,t)
local e=0
for t=t,1,-1 do
e=e*256+o:byte(a+t-1)
end
return e,a+t
end
else
o=function(o,a,t)
local e=0
for t=1,t,1 do
e=e*256+o:byte(a+t-1)
end
return e,a+t
end
end
local function d(t)
local n,e=o(t,1,s)
local h={a.rep("\0",s)}
local r=e+n
e=e+n+i*2+4
e=e+i+o(t,e,i)*l
n,e=o(t,e,i)
for a=1,n do
local a
a,e=o(t,e,1)
if a==1 then
e=e+1
elseif a==4 then
e=e+s+o(t,e,s)
elseif a==3 then
e=e+c
elseif a==254 or a==9 then
e=e+u
end
end
n,e=o(t,e,i)
h[#h+1]=t:sub(r,e-1)
for a=1,n do
local t,a=d(t:sub(e,-1))
h[#h+1]=t
e=e+a-1
end
e=e+o(t,e,i)*i+i
n,e=o(t,e,i)
for a=1,n do
e=e+o(t,e,s)+s+i*2
end
n,e=o(t,e,i)
for a=1,n do
e=e+o(t,e,s)+s
end
h[#h+1]=a.rep("\0",i*3)
return b.concat(h),e
end
return r:sub(1,12)..d(r:sub(13,-1))
end
function _sortiter(a,o)
local e={}
local t,t
for t,a in h(a)do
e[#e+1]=t
end
local t=0
b.sort(e,o)
return function()
t=t+1
if t<=#e then
return e[t],a[e[t]],t
end
end
end
function spairs(e,t)
return _sortiter(e,t)
end
function kspairs(e)
return _sortiter(e)
end
function vspairs(e)
return _sortiter(e,function(t,a)return e[t]<e[a]end)
end
function bigendian()
return a.byte(a.dump(function()end),7)==0
end
function exec(e)
local e=u.popen(e)
local t=e:read("*a")
e:close()
return t
end
function execi(e)
local e=u.popen(e)
return e and function()
local t=e:read()
if not t then
e:close()
end
return t
end
end
function execl(e)
local a=u.popen(e)
local t=""
local e={}
while true do
t=a:read()
if(t==nil)then break end
e[#e+1]=t
end
a:close()
return e
end
local o={
"INVALID_COMMAND",
"INVALID_ARGUMENT",
"METHOD_NOT_FOUND",
"NOT_FOUND",
"NO_DATA",
"PERMISSION_DENIED",
"TIMEOUT",
"NOT_SUPPORTED",
"UNKNOWN_ERROR",
"CONNECTION_FAILED"
}
local function i(...)
if m('#',...)==2 then
local a,e=m(1,...),m(2,...)
if a==nil and t(e)=="number"then
return nil,e,o[e]
end
end
return...
end
function ubus(e,o,a,n,s)
if not l then
l=q.connect(n,s)
p(l,"Unable to establish ubus connection")
end
if e and o then
if t(a)~="table"then
a={}
end
return i(l:call(e,o,a))
elseif e then
return l:signatures(e)
else
return l:objects()
end
end
function serialize_json(e,a)
local e=k.stringify(e)
if t(a)=="function"then
a(e)
else
return e
end
end
function libpath()
return f"nixio.fs".dirname(j.__file__)
end
function checklib(t,o)
local e=f"nixio.fs"
local i=e.access('/usr/bin/ldd')
local e=e.access(t)
if not i or not e then
return false
end
local e=exec(a.format("/usr/bin/ldd %s",shellquote(t)))
if not e then
return false
end
for t,e in w(split(e))do
if e:find(o)then
return true
end
end
return false
end
local n=r({},{__mode="k"})
local function a(t,e,a,...)
if not a then
return false,t(z.traceback(e,(...)),...)
end
if d.status(e)=='suspended'then
return performResume(t,e,d.yield(...))
else
return true,...
end
end
function performResume(t,e,...)
return a(t,e,d.resume(e,...))
end
local function o(e,...)
return e
end
function coxpcall(e,t,...)
local i=d.running()
if not i then
if t==o then
return c(e,...)
else
if m("#",...)>0 then
local t,a=e,{...}
e=function()return t(g(a))end
end
return T(e,t)
end
else
local o,a=c(d.create,e)
if not o then
local e=function(...)return e(...)end
a=d.create(e)
end
n[a]=i
return performResume(t,a,...)
end
end
function copcall(e,...)
return coxpcall(e,o,...)
end
