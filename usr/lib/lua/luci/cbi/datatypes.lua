local o=require"nixio.fs"
local n=require"luci.ip"
local h=require"math"
local e=require"luci.util"
local e,s,i,r,a=tonumber,tostring,type,unpack,select
module"luci.cbi.datatypes"
_M['or']=function(n,...)
local t,o=1,a('#',...)
while t<=o do
local o=a(t,...)
if i(o)~="function"then
t=t+1
local t=n
if i(o)=="number"then
t=e(t)
end
if o==t then
return true
end
else
t=t+2
local e=a(t-1,...)
if o(n,r(e))then
return true
end
end
end
return false
end
_M['and']=function(n,...)
local t,o=1,a('#',...)
while t<=o do
local o=a(t,...)
if i(o)~="function"then
t=t+1
local a=n
if i(o)=="number"then
a=e(a)
end
if o~=a then
return false
end
t=t-1
else
t=t+2
local e=a(t-1,...)
if not o(n,r(e))then
return false
end
end
end
return true
end
function neg(e,...)
return _M['or'](e:gsub("^%s*!%s*",""),...)
end
function list(t,e,a)
if i(e)~="function"then
return false
end
local o
for t in t:gmatch("%S+")do
if not e(t,r(a))then
return false
end
end
return true
end
function bool(e)
if e=="1"or e=="yes"or e=="on"or e=="true"then
return true
elseif e=="0"or e=="no"or e=="off"or e=="false"then
return true
elseif e==""or e==nil then
return true
end
return false
end
function uinteger(t)
local e=e(t)
if e~=nil and h.floor(e)==e and e>=0 then
return true
end
return false
end
function integer(t)
local e=e(t)
if e~=nil and h.floor(e)==e then
return true
end
return false
end
function ufloat(t)
local e=e(t)
return(e~=nil and e>=0)
end
function float(t)
return(e(t)~=nil)
end
function ipaddr(e)
return ip4addr(e)or ip6addr(e)
end
function ip4addr(e)
if e then
return n.IPv4(e)and true or false
end
return false
end
function ip4prefix(t)
t=e(t)
return(t and t>=0 and t<=32)
end
function ip6addr(e)
if e then
return n.IPv6(e)and true or false
end
return false
end
function ip6prefix(t)
t=e(t)
return(t and t>=0 and t<=128)
end
function cidr(e)
return cidr4(e)or cidr6(e)
end
function cidr4(e)
local t,e=e:match("^([^/]+)/([^/]+)$")
return ip4addr(t)and ip4prefix(e)
end
function cidr6(e)
local e,t=e:match("^([^/]+)/([^/]+)$")
return ip6addr(e)and ip6prefix(t)
end
function ipnet4(e)
local t,e=e:match("^([^/]+)/([^/]+)$")
return ip4addr(t)and ip4addr(e)
end
function ipnet6(e)
local t,e=e:match("^([^/]+)/([^/]+)$")
return ip6addr(t)and ip6addr(e)
end
function ipmask(e)
return ipmask4(e)or ipmask6(e)
end
function ipmask4(e)
return cidr4(e)or ipnet4(e)or ip4addr(e)
end
function ipmask6(e)
return cidr6(e)or ipnet6(e)or ip6addr(e)
end
function ip6hostid(e)
if e=="eui64"or e=="random"then
return true
else
local e=n.IPv6(e)
if e and e:prefix()==128 and e:lower("::1:0:0:0:0")then
return true
end
end
return false
end
function port(t)
t=e(t)
return(t and t>=0 and t<=65535)
end
function portrange(t)
local a,e=t:match("^(%d+)%-(%d+)$")
if a and e and port(a)and port(e)then
return true
else
return port(t)
end
end
function macaddr(e)
return n.checkmac(e)and true or false
end
function hostname(e,t)
if e and(#e<254)and(
e:match("^[a-zA-Z_]+$")or
(e:match("^[a-zA-Z0-9_][a-zA-Z0-9_%-%.]*[a-zA-Z0-9]$")and
e:match("[^0-9%.]"))
)then
return(not t or not e:match("^_"))
end
return false
end
function host(e,t)
return hostname(e)or((t==1)and ip4addr(e))or((not(t==1))and ipaddr(e))
end
function network(e)
return uciname(e)or host(e)
end
function hostport(e,a)
local t,e=e:match("^([^:]+):([^:]+)$")
return not not(t and e and host(t,a)and port(e))
end
function ip4addrport(e,t)
local e,t=e:match("^([^:]+):([^:]+)$")
return(e and t and ip4addr(e)and port(t))
end
function ip4addrport(e)
local e,t=e:match("^([^:]+):([^:]+)$")
return(e and t and ip4addr(e)and port(t))
end
function ipaddrport(a,o)
local t,e=a:match("^([^%[%]:]+):([^:]+)$")
if(t and e and ip4addr(t)and port(e))then
return true
elseif(o==1)then
t,e=a:match("^%[(.+)%]:([^:]+)$")
if(t and e and ip6addr(t)and port(e))then
return true
end
end
t,e=a:match("^([^%[%]]+):([^:]+)$")
return(t and e and ip6addr(t)and port(e))
end
function wpakey(e)
if#e==64 then
return(e:match("^[a-fA-F0-9]+$")~=nil)
else
return(#e>=8)and(#e<=63)
end
end
function wepkey(e)
if e:sub(1,2)=="s:"then
e=e:sub(3)
end
if(#e==10)or(#e==26)then
return(e:match("^[a-fA-F0-9]+$")~=nil)
else
return(#e==5)or(#e==13)
end
end
function hexstring(e)
if e then
return(e:match("^[a-fA-F0-9]+$")~=nil)
end
return false
end
function hex(a,t)
t=e(t)
if a and t~=nil then
return((a:match("^0x[a-fA-F0-9]+$")~=nil)and(#a<=2+t*2))
end
return false
end
function base64(e)
if e then
return(e:match("^[a-zA-Z0-9/+]+=?=?$")~=nil)and(h.fmod(#e,4)==0)
end
return false
end
function string(e)
return true
end
function directory(a,t)
local e=o.stat(a)
t=t or{}
if e and not t[e.ino]then
t[e.ino]=true
if e.type=="dir"then
return true
elseif e.type=="lnk"then
return directory(o.readlink(a),t)
end
end
return false
end
function file(a,t)
local e=o.stat(a)
t=t or{}
if e and not t[e.ino]then
t[e.ino]=true
if e.type=="reg"then
return true
elseif e.type=="lnk"then
return file(o.readlink(a),t)
end
end
return false
end
function device(a,t)
local e=o.stat(a)
t=t or{}
if e and not t[e.ino]then
t[e.ino]=true
if e.type=="chr"or e.type=="blk"then
return true
elseif e.type=="lnk"then
return device(o.readlink(a),t)
end
end
return false
end
function uciname(e)
return(e:match("^[a-zA-Z0-9_]+$")~=nil)
end
function range(t,a,o)
t=e(t)
a=e(a)
o=e(o)
if t~=nil and a~=nil and o~=nil then
return((t>=a)and(t<=o))
end
return false
end
function min(a,t)
a=e(a)
t=e(t)
if a~=nil and t~=nil then
return(a>=t)
end
return false
end
function max(a,t)
a=e(a)
t=e(t)
if a~=nil and t~=nil then
return(a<=t)
end
return false
end
function rangelength(t,o,a)
t=s(t)
o=e(o)
a=e(a)
if t~=nil and o~=nil and a~=nil then
return((#t>=o)and(#t<=a))
end
return false
end
function minlength(t,a)
t=s(t)
a=e(a)
if t~=nil and a~=nil then
return(#t>=a)
end
return false
end
function maxlength(a,t)
a=s(a)
t=e(t)
if a~=nil and t~=nil then
return(#a<=t)
end
return false
end
function phonedigit(e)
return(e:match("^[0-9%*#!%.]+$")~=nil)
end
function timehhmmss(e)
return(e:match("^[0-6][0-9]:[0-6][0-9]:[0-6][0-9]$")~=nil)
end
function dateyyyymmdd(t)
if t~=nil then
yearstr,monthstr,daystr=t:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
if(yearstr==nil)or(monthstr==nil)or(daystr==nil)then
return false;
end
year=e(yearstr)
month=e(monthstr)
day=e(daystr)
if(year==nil)or(month==nil)or(day==nil)then
return false;
end
local a={31,28,31,30,31,30,31,31,30,31,30,31}
local function t(e)
return(e%4==0)and((e%100~=0)or(e%400==0))
end
function get_days_in_month(e,o)
if(e==2)and t(o)then
return 29
else
return a[e]
end
end
if(year<2015)then
return false
end
if((month==0)or(month>12))then
return false
end
if((day==0)or(day>get_days_in_month(month,year)))then
return false
end
return true
end
return false
end
function unique(e)
return true
end
