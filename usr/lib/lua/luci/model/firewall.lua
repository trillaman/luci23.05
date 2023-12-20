local h,e,n,s,e,o
=type,pairs,ipairs,table,luci,math
local l=require"luci.template.parser"
local a=require"luci.util"
local d=require"luci.model.uci"
module"luci.model.firewall"
local e,r
function _valid_id(e)
return(e and#e>0 and e:match("^[a-zA-Z0-9_]+$"))
end
function _get(t,o,a)
return e:get(t,o,a)
end
function _set(a,i,o,t)
if t~=nil then
if h(t)=="boolean"then t=t and"1"or"0"end
return e:set(a,i,o,t)
else
return e:delete(a,i,o)
end
end
function init(t)
e=t or e or d.cursor()
r=e:substate()
return _M
end
function save(t,...)
e:save(...)
e:load(...)
end
function commit(t,...)
e:commit(...)
e:load(...)
end
function get_defaults()
return defaults()
end
function new_zone(a)
local e="newzone"
local t=1
while a:get_zone(e)do
t=t+1
e="newzone%d"%t
end
return a:add_zone(e)
end
function add_zone(t,a)
if _valid_id(a)and not t:get_zone(a)then
local t=defaults()
local e=e:section("firewall","zone",nil,{
name=a,
network=" ",
input=t:input()or"DROP",
forward=t:forward()or"DROP",
output=t:output()or"DROP"
})
return e and zone(e)
end
end
function get_zone(a,t)
if e:get("firewall",t)=="zone"then
return zone(t)
else
local a
e:foreach("firewall","zone",
function(e)
if t and e.name==t then
a=e['.name']
return false
end
end)
return a and zone(a)
end
end
function get_zones(t)
local o={}
local t={}
e:foreach("firewall","zone",
function(e)
if e.name then
t[e.name]=zone(e['.name'])
end
end)
local e
for e in a.kspairs(t)do
o[#o+1]=t[e]
end
return o
end
function get_zone_by_network(t,o)
local t
e:foreach("firewall","zone",
function(e)
if e.name and o then
local i
for a in a.imatch(e.network or e.name)do
if a==o then
t=e['.name']
return false
end
end
end
end)
return t and zone(t)
end
function del_zone(a,t)
local a=false
if e:get("firewall",t)=="zone"then
local o=e:get("firewall",t,"name")
a=e:delete("firewall",t)
t=o
else
e:foreach("firewall","zone",
function(o)
if t and o.name==t then
a=e:delete("firewall",o['.name'])
return false
end
end)
end
if a then
e:foreach("firewall","rule",
function(a)
if a.src==t or a.dest==t then
e:delete("firewall",a['.name'])
end
end)
e:foreach("firewall","redirect",
function(a)
if a.src==t or a.dest==t then
e:delete("firewall",a['.name'])
end
end)
e:foreach("firewall","forwarding",
function(a)
if a.src==t or a.dest==t then
e:delete("firewall",a['.name'])
end
end)
end
return a
end
function rename_zone(o,t,a)
local i=false
if _valid_id(a)and not o:get_zone(a)then
e:foreach("firewall","zone",
function(o)
if t and o.name==t then
if not o.network then
e:set("firewall",o['.name'],"network",t)
end
e:set("firewall",o['.name'],"name",a)
i=true
return false
end
end)
if i then
e:foreach("firewall","rule",
function(o)
if o.src==t then
e:set("firewall",o['.name'],"src",a)
end
if o.dest==t then
e:set("firewall",o['.name'],"dest",a)
end
end)
e:foreach("firewall","redirect",
function(o)
if o.src==t then
e:set("firewall",o['.name'],"src",a)
end
if o.dest==t then
e:set("firewall",o['.name'],"dest",a)
end
end)
e:foreach("firewall","forwarding",
function(o)
if o.src==t then
e:set("firewall",o['.name'],"src",a)
end
if o.dest==t then
e:set("firewall",o['.name'],"dest",a)
end
end)
end
end
return i
end
function del_network(t,e)
local a
if e then
for a,t in n(t:get_zones())do
t:del_network(e)
end
end
end
defaults=a.class()
function defaults.__init__(t)
e:foreach("firewall","defaults",
function(e)
t.sid=e['.name']
return false
end)
t.sid=t.sid or e:section("firewall","defaults",nil,{})
end
function defaults.get(e,t)
return _get("firewall",e.sid,t)
end
function defaults.set(t,e,a)
return _set("firewall",t.sid,e,a)
end
function defaults.syn_flood(e)
return(e:get("syn_flood")=="1")
end
function defaults.drop_invalid(e)
return(e:get("drop_invalid")=="1")
end
function defaults.input(e)
return e:get("input")or"DROP"
end
function defaults.forward(e)
return e:get("forward")or"DROP"
end
function defaults.output(e)
return e:get("output")or"DROP"
end
zone=a.class()
function zone.__init__(t,a)
if e:get("firewall",a)=="zone"then
t.sid=a
t.data=e:get_all("firewall",a)
else
e:foreach("firewall","zone",
function(e)
if e.name==a then
t.sid=e['.name']
t.data=e
return false
end
end)
end
end
function zone.get(t,e)
return _get("firewall",t.sid,e)
end
function zone.set(t,a,e)
return _set("firewall",t.sid,a,e)
end
function zone.masq(e)
return(e:get("masq")=="1")
end
function zone.name(e)
return e:get("name")
end
function zone.network(e)
return e:get("network")
end
function zone.input(e)
return e:get("input")or defaults():input()or"DROP"
end
function zone.forward(e)
return e:get("forward")or defaults():forward()or"DROP"
end
function zone.output(e)
return e:get("output")or defaults():output()or"DROP"
end
function zone.add_network(o,t)
if e:get("network",t)=="interface"then
local e={}
local i
for a in a.imatch(o:get("network")or o:get("name"))do
if a~=t then
e[#e+1]=a
end
end
e[#e+1]=t
_M:del_network(t)
o:set("network",s.concat(e," "))
end
end
function zone.del_network(t,o)
local e={}
local i
for t in a.imatch(t:get("network")or t:get("name"))do
if t~=o then
e[#e+1]=t
end
end
if#e>0 then
t:set("network",s.concat(e," "))
else
t:set("network"," ")
end
end
function zone.get_networks(t)
local e={}
local o
for t in a.imatch(t:get("network")or t:get("name"))do
e[#e+1]=t
end
return e
end
function zone.clear_networks(e)
e:set("network"," ")
end
function zone.get_forwardings_by(t,o)
local a=t:name()
local t={}
e:foreach("firewall","forwarding",
function(e)
if e.src and e.dest and e[o]==a then
t[#t+1]=forwarding(e['.name'])
end
end)
return t
end
function zone.add_forwarding_to(a,t)
local o,i
for a,e in n(a:get_forwardings_by('src'))do
if e:dest()==t then
o=true
break
end
end
if not o and t~=a:name()and _valid_id(t)then
local e=e:section("firewall","forwarding",nil,{
src=a:name(),
dest=t
})
return e and forwarding(e)
end
end
function zone.add_forwarding_from(a,t)
local o,i
for a,e in n(a:get_forwardings_by('dest'))do
if e:src()==t then
o=true
break
end
end
if not o and t~=a:name()and _valid_id(t)then
local e=e:section("firewall","forwarding",nil,{
src=t,
dest=a:name()
})
return e and forwarding(e)
end
end
function zone.del_forwardings_by(a,t)
local a=a:name()
e:delete_all("firewall","forwarding",
function(e)
return(e.src and e.dest and e[t]==a)
end)
end
function zone.add_redirect(a,t)
t=t or{}
t.src=a:name()
local e=e:section("firewall","redirect",nil,t)
return e and redirect(e)
end
function zone.add_rule(a,t)
t=t or{}
t.src=a:name()
local e=e:section("firewall","rule",nil,t)
return e and rule(e)
end
function zone.get_color(e)
if e and e:name()=="lan"then
return"#90f090"
elseif e and e:name()=="wan"then
return"#f09090"
elseif e then
o.randomseed(l.hash(e:name()))
local e=o.random(128)
local t=o.random(128)
local a=0
local i=128
if(e+t)<128 then
a=128-e-t
else
i=255-e-t
end
local a=a+o.floor(o.random()*(i-a))
return"#%02x%02x%02x"%{255-e,255-t,255-a}
else
return"#eeeeee"
end
end
forwarding=a.class()
function forwarding.__init__(e,t)
e.sid=t
end
function forwarding.src(t)
return e:get("firewall",t.sid,"src")
end
function forwarding.dest(t)
return e:get("firewall",t.sid,"dest")
end
function forwarding.src_zone(e)
local e=zone(e:src())
return e.sid and e
end
function forwarding.dest_zone(e)
local e=zone(e:dest())
return e.sid and e
end
rule=a.class()
function rule.__init__(t,e)
t.sid=e
end
function rule.get(t,e)
return _get("firewall",t.sid,e)
end
function rule.set(a,e,t)
return _set("firewall",a.sid,e,t)
end
function rule.src(t)
return e:get("firewall",t.sid,"src")
end
function rule.dest(t)
return e:get("firewall",t.sid,"dest")
end
function rule.src_zone(e)
return zone(e:src())
end
function rule.dest_zone(e)
return zone(e:dest())
end
redirect=a.class()
function redirect.__init__(t,e)
t.sid=e
end
function redirect.get(e,t)
return _get("firewall",e.sid,t)
end
function redirect.set(t,e,a)
return _set("firewall",t.sid,e,a)
end
function redirect.src(t)
return e:get("firewall",t.sid,"src")
end
function redirect.dest(t)
return e:get("firewall",t.sid,"dest")
end
function redirect.src_zone(e)
return zone(e:src())
end
function redirect.dest_zone(e)
return zone(e:dest())
end
