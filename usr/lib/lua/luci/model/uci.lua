local r=require"os"
local i=require"luci.util"
local m=require"table"
local e,e,e=setmetatable,rawget,rawset
local u,e,e=require,getmetatable,assert
local e,h,c,l=error,pairs,ipairs,select
local e,t,d,t=type,tostring,tonumber,unpack
module"luci.model.uci"
local a={
"Invalid command",
"Invalid argument",
"Method not found",
"Entry not found",
"No data",
"Permission denied",
"Timeout",
"Not supported",
"Unknown error",
"Connection failed"
}
local s=nil
local function t(a,t)
if e(t)=="table"and s then
t.ubus_rpc_session=s
end
return i.ubus("uci",a,t)
end
function cursor()
return _M
end
function cursor_state()
return _M
end
function substate(e)
return e
end
function get_confdir(e)
return"/etc/config"
end
function get_savedir(e)
return"/tmp/.uci"
end
function get_session_id(e)
return s
end
function set_confdir(e,e)
return false
end
function set_savedir(e,e)
return false
end
function set_session_id(t,e)
s=e
return true
end
function load(e,e)
return true
end
function save(e,e)
return true
end
function unload(e,e)
return true
end
function changes(i,o)
local t,o=t("changes",{config=o})
if e(t)=="table"and e(t.changes)=="table"then
return t.changes
elseif o then
return nil,a[o]
else
return{}
end
end
function revert(o,e)
local t,e=t("revert",{config=e})
return(e==nil),a[e]
end
function commit(o,e)
local t,e=t("commit",{config=e})
return(e==nil),a[e]
end
function apply(o,l)
local n,o
if l then
local h=u"luci.sys"
local e=u"luci.config"
local e=d(e and e.apply and e.apply.rollback or 90)or 0
n,o=t("apply",{
timeout=(e>90)and e or 90,
rollback=true
})
if not o then
local a=r.time()
local t=h.uniqueid(16)
i.ubus("session","set",{
ubus_rpc_session="00000000000000000000000000000000",
values={
rollback={
token=t,
session=s,
timeout=a+e
}
}
})
return t
end
else
n,o=t("changes",{})
if not o then
if e(n)=="table"and e(n.changes)=="table"then
local e,e
for e,a in h(n.changes)do
n,o=t("commit",{config=e})
if o then
break
end
end
end
end
if not o then
n,o=t("apply",{rollback=false})
end
end
return(o==nil),a[o]
end
function confirm(e,t)
local e,s,o,n=e:rollback_pending()
if e then
if t~=n then
return false,"Permission denied"
end
local t,e=i.ubus("uci","confirm",{
ubus_rpc_session=o
})
if not e then
i.ubus("session","set",{
ubus_rpc_session="00000000000000000000000000000000",
values={rollback={}}
})
end
return(e==nil),a[e]
end
return false,"No data"
end
function rollback(e)
local e,o,t=e:rollback_pending()
if e then
local t,e=i.ubus("uci","rollback",{
ubus_rpc_session=t
})
if not e then
i.ubus("session","set",{
ubus_rpc_session="00000000000000000000000000000000",
values={rollback={}}
})
end
return(e==nil),a[e]
end
return false,"No data"
end
function rollback_pending(t)
local t,i=i.ubus("session","get",{
ubus_rpc_session="00000000000000000000000000000000",
keys={"rollback"}
})
local o=r.time()
if e(t)=="table"and
e(t.values)=="table"and
e(t.values.rollback)=="table"and
e(t.values.rollback.token)=="string"and
e(t.values.rollback.session)=="string"and
e(t.values.rollback.timeout)=="number"and
t.values.rollback.timeout>o
then
return true,
t.values.rollback.timeout-o,
t.values.rollback.session,
t.values.rollback.token
end
return false,a[i]
end
function foreach(s,o,n,i)
if e(i)=="function"then
local o,s=t("get",{
config=o,
type=n
})
if e(o)=="table"and e(o.values)=="table"then
local t={}
local n=false
local e=1
local a,a
for o,a in h(o.values)do
a[".index"]=a[".index"]or e
t[e]=a
e=e+1
end
m.sort(t,function(e,t)
return e[".index"]<t[".index"]
end)
for t,e in c(t)do
local e=i(e)
n=true
if e==false then
break
end
end
return n
else
return false,a[s]or"No data"
end
else
return false,"Invalid argument"
end
end
local function s(h,s,n,i,o)
if i==nil then
return nil
elseif e(o)=="string"and o:byte(1)~=46 then
local t,o=t(s,{
config=n,
section=i,
option=o
})
if e(t)=="table"then
return t.value or nil
elseif o then
return false,a[o]
else
return nil
end
elseif o==nil then
local e=h:get_all(n,i)
if e then
return e[".type"],e[".name"]
else
return nil
end
else
return false,"Invalid argument"
end
end
function get(e,...)
return s(e,"get",...)
end
function get_state(e,...)
return s(e,"state",...)
end
function get_all(n,i,o)
local t,o=t("get",{
config=i,
section=o
})
if e(t)=="table"and e(t.values)=="table"then
return t.values
elseif o then
return false,a[o]
else
return nil
end
end
function get_bool(e,...)
local e=e:get(...)
return(e=="1"or e=="true"or e=="yes"or e=="on")
end
function get_first(n,t,s,i,a)
local o=a
n:foreach(t,s,function(t)
local t=not i and t[".name"]or t[i]
if e(a)=="number"then
t=d(t)
elseif e(a)=="boolean"then
t=(t=="1"or t=="true"or
t=="yes"or t=="on")
end
if t~=nil then
o=t
return false
end
end)
return o
end
function get_list(i,a,o,t)
if a and o and t then
local t=i:get(a,o,t)
return(e(t)=="table"and t or{t})
end
return{}
end
function section(h,o,i,s,n)
local o,t=t("add",{
config=o,
type=i,
name=s,
values=n
})
if e(o)=="table"then
return o.section
elseif t then
return false,a[t]
else
return nil
end
end
function add(a,e,t)
return a:section(e,t)
end
function set(n,e,o,i,...)
if l('#',...)==0 then
local t,e=n:section(e,i,o)
return(not not t),e
else
local t,e=t("set",{
config=e,
section=o,
values={[i]=l(1,...)}
})
return(e==nil),a[e]
end
end
function set_list(n,i,o,a,t)
if o==nil or a==nil then
return false
elseif t==nil or(e(t)=="table"and#t==0)then
return n:delete(i,o,a)
elseif e(t)=="table"then
return n:set(i,o,a,t)
else
return n:set(i,o,a,{t})
end
end
function tset(n,i,o,e)
local t,e=t("set",{
config=i,
section=o,
values=e
})
return(e==nil),a[e]
end
function reorder(h,s,i,n)
local o
if e(i)=="string"and e(n)=="number"then
local e=0
o={}
h:foreach(s,nil,function(t)
if e==n then
e=e+1
end
if t[".name"]~=i then
e=e+1
o[e]=t[".name"]
else
o[n+1]=i
end
end)
elseif e(i)=="table"then
o=i
else
return false,"Invalid argument"
end
local t,e=t("order",{
config=s,
sections=o
})
return(e==nil),a[e]
end
function delete(n,o,e,i)
local t,e=t("delete",{
config=o,
section=e,
option=i
})
return(e==nil),a[e]
end
function delete_all(o,n,s,i)
local r,o
if e(i)=="table"then
r,o=t("delete",{
config=n,
type=s,
match=i
})
elseif e(i)=="function"then
local a=t("get",{
config=n,
type=s
})
if e(a)=="table"and e(a.values)=="table"then
local e,e
for a,e in h(a.values)do
if i(e)then
r,o=t("delete",{
config=n,
section=a
})
end
end
end
elseif i==nil then
r,o=t("delete",{
config=n,
type=s
})
else
return false,"Invalid argument"
end
return(o==nil),a[o]
end
