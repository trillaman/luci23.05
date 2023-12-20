local t,E,l,i,e,h,_
=type,next,pairs,ipairs,loadfile,table,select
local k,S,T=tonumber,tostring,math
local g,s,j=pcall,require,setmetatable
local N=s"nixio"
local v=s"nixio.fs"
local r=s"luci.ip"
local a=s"luci.util"
local I=s"luci.model.uci"
local o=s"luci.i18n"
local O=s"luci.jsonc"
module"luci.model.network"
IFACE_PATTERNS_VIRTUAL={}
IFACE_PATTERNS_IGNORE={"^wmaster%d","^wifi%d","^hwsim%d","^imq%d","^ifb%d","^mon%.wlan%d","^sit%d","^gre%d","^gretap%d","^ip6gre%d","^ip6tnl%d","^tunl%d","^lo$"}
IFACE_PATTERNS_WIRELESS={"^wlan%d","^wl%d","^ath%d","^%w+%.network%d"}
IFACE_ERRORS={
CONNECT_FAILED=o.translate("Connection attempt failed"),
INVALID_ADDRESS=o.translate("IP address is invalid"),
INVALID_GATEWAY=o.translate("Gateway address is invalid"),
INVALID_LOCAL_ADDRESS=o.translate("Local IP address is invalid"),
MISSING_ADDRESS=o.translate("IP address is missing"),
MISSING_PEER_ADDRESS=o.translate("Peer address is missing"),
NO_DEVICE=o.translate("Network device is not present"),
NO_IFACE=o.translate("Unable to determine device name"),
NO_IFNAME=o.translate("Unable to determine device name"),
NO_WAN_ADDRESS=o.translate("Unable to determine external IP address"),
NO_WAN_LINK=o.translate("Unable to determine upstream interface"),
PEER_RESOLVE_FAIL=o.translate("Unable to resolve peer host name"),
PIN_FAILED=o.translate("PIN code rejected")
}
protocol=a.class()
local d={}
local n,b,w,y,p
local m,c,u
local e
function _filter(r,n,s,d)
local o=e:get(r,n,s)
if o then
local a={}
if t(o)=="string"then
for e in o:gmatch("%S+")do
if e~=d then
a[#a+1]=e
end
end
if#a>0 then
e:set(r,n,s,h.concat(a," "))
else
e:delete(r,n,s)
end
elseif t(o)=="table"then
for t,e in i(o)do
if e~=d then
a[#a+1]=e
end
end
if#a>0 then
e:set(r,n,s,a)
else
e:delete(r,n,s)
end
end
end
end
function _append(r,s,n,o)
local a=e:get(r,s,n)or""
if t(a)=="string"then
local t={}
for e in a:gmatch("%S+")do
if e~=o then
t[#t+1]=e
end
end
t[#t+1]=o
e:set(r,s,n,h.concat(t," "))
elseif t(a)=="table"then
local t={}
for a,e in i(a)do
if e~=o then
t[#t+1]=e
end
end
t[#t+1]=o
e:set(r,s,n,t)
end
end
function _stror(e,t)
if not e or#e==0 then
return t and#t>0 and t
else
return e
end
end
function _get(a,t,o)
return e:get(a,t,o)
end
function _set(n,o,i,a)
if a~=nil then
if t(a)=="boolean"then a=a and"1"or"0"end
return e:set(n,o,i,a)
else
return e:delete(n,o,i)
end
end
local function f()
if not E(u)then
u=a.ubus("network.wireless","status",{})or{}
end
return u
end
local function A(a)
local n,s=e:get("wireless",a)
if n=="wifi-iface"and s~=nil then
local a,a
for h,a in l(f())do
if t(a)=="table"and
t(a.interfaces)=="table"
then
local o,o
for i,o in i(a.interfaces)do
if t(o)=="table"and
t(o.section)=="string"
then
local t,e=e:get("wireless",o.section)
if n==t and s==e then
return h,a,o
end
end
end
end
end
end
end
local function x(o)
if t(o)=="string"then
local e,e
for n,a in l(f())do
if t(a)=="table"and
t(a.interfaces)=="table"
then
local e,e
for i,e in i(a.interfaces)do
if t(e)=="table"and
t(e.ifname)=="string"and
e.ifname==o
then
return n,a,e
end
end
end
end
end
end
function _wifi_iface(e)
local t,t
for a,t in i(IFACE_PATTERNS_WIRELESS)do
if e:match(t)then
return true
end
end
return(v.access("/sys/class/net/%s/phy80211"%e)==true)
end
local function q(e,i)
local o,a=g(s,"iwinfo")
local o=o and t(e)=="string"and a.type(e)
local n={
bitrate=true,
quality=true,
quality_max=true,
mode=true,
ssid=true,
bssid=true,
assoclist=true,
encryption=true
}
if o then
local i=i or(r.link(e).type~=1)
return j({},{
__index=function(s,t)
if t=="ifname"then
return e
elseif i and n[t]then
return nil
elseif a[o][t]then
return a[o][t](e)
end
end
})
end
end
local function z(a)
if t(a)=="string"then
local i,t=a:match("^(%w+)%.network(%d+)$")
if i and t then
local a,o=0,nil
t=k(t)
e:foreach("wireless","wifi-iface",
function(e)
if e.device==i then
a=a+1
if a==t then
o=e[".name"]
return false
end
end
end)
return o
end
end
end
function _wifi_sid_by_ifname(a)
local e=z(a)
if e then
return e
end
local a,a,e=x(a)
if e and t(e.section)=="string"then
return e.section
end
end
local function f(a)
local a,o=e:get("wireless",a)
if a=="wifi-iface"and o~=nil then
local a=e:get("wireless",o,"device")
if t(a)=="string"then
local t,i=0,nil
e:foreach("wireless","wifi-iface",
function(e)
if e.device==a then
t=t+1
if e[".name"]==o then
i="%s.network%d"%{a,t}
return false
end
end
end)
return i,a
end
end
end
local function j(o)
local t=nil
e:foreach("wireless","wifi-iface",
function(e)
local i
for a in a.imatch(e.network)do
if a==o then
t=f(e[".name"])
return false
end
end
end)
return t
end
function _iface_virtual(e)
local t,t
for a,t in i(IFACE_PATTERNS_VIRTUAL)do
if e:match(t)then
return true
end
end
return false
end
function _iface_ignore(e)
local t,t
for a,t in i(IFACE_PATTERNS_IGNORE)do
if e:match(t)then
return true
end
end
return false
end
function init(o)
e=o or e or I.cursor()
n={}
b={}
w={}
y={}
p={}
m={}
c={}
u={}
local e,e
for a,t in i(N.getifaddrs())do
local e=t.name:match("[^:]+")
if _iface_virtual(e)then
y[e]=true
end
if y[e]or not(_iface_ignore(e)or _iface_virtual(e))then
n[e]=n[e]or{
idx=t.ifindex or a,
name=e,
rawname=t.name,
flags={},
ipaddrs={},
ip6addrs={}
}
if t.family=="packet"then
n[e].flags=t.flags
n[e].stats=t.data
n[e].macaddr=r.checkmac(t.addr)
elseif t.family=="inet"then
n[e].ipaddrs[#n[e].ipaddrs+1]=r.IPv4(t.addr,t.netmask)
elseif t.family=="inet6"then
n[e].ip6addrs[#n[e].ip6addrs+1]=r.IPv6(t.addr,t.netmask)
end
end
end
local e,o
for t in a.execi("brctl show")do
if not t:match("STP")then
local t=a.split(t,"%s+",nil,true)
if#t==4 then
e={
name=t[1],
id=t[2],
stp=t[3]=="yes",
ifnames={n[t[4]]}
}
if e.ifnames[1]then
e.ifnames[1].bridge=e
end
b[t[1]]=e
n[t[1]].bridge=e
elseif e then
e.ifnames[#e.ifnames+1]=n[t[2]]
e.ifnames[#e.ifnames].bridge=e
end
end
end
local e=O.parse(v.readfile("/etc/board.json")or"")
if t(e)=="table"and t(e.switch)=="table"then
local a,a
for r,e in l(e.switch)do
if t(e)=="table"and t(e.ports)=="table"then
local a,a
local a={}
local n={}
local s={}
for o,e in i(e.ports)do
if t(e)=="table"and
t(e.num)=="number"and
(t(e.role)=="string"or
t(e.device)=="string")
then
local t={
num=e.num,
role=e.role or"cpu",
index=e.index or e.num
}
if e.device then
t.device=e.device
t.tagged=e.need_tag
s[S(e.num)]=e.device
end
a[#a+1]=t
if e.role then
n[e.role]=(n[e.role]or 0)+1
end
end
end
h.sort(a,function(t,e)
if t.role~=e.role then
return(t.role<e.role)
end
return(t.index<e.index)
end)
local o,t
for a,e in i(a)do
if e.role~=t then
t=e.role
o=1
end
if t=="cpu"then
e.label="CPU (%s)"%e.device
elseif n[t]>1 then
e.label="%s %d"%{t:upper(),o}
o=o+1
else
e.label=t:upper()
end
e.role=nil
e.index=nil
end
p[r]={
ports=a,
netdevs=s
}
end
end
end
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
function ifnameof(o,e)
if a.instanceof(e,interface)then
return e:name()
elseif a.instanceof(e,protocol)then
return e:ifname()
elseif t(e)=="string"then
return e:match("^[^:]+")
end
end
function get_protocol(a,e,t)
local e=d[e]
if e then
return e(t or"__dummy__")
end
end
function get_protocols(e)
local e={}
local t,t
for a,t in i(d)do
e[#e+1]=t("__dummy__")
end
return e
end
function register_protocol(e,t)
local e=a.class(protocol)
function e.__init__(e,t)
e.sid=t
end
function e.proto(e)
return t
end
d[#d+1]=e
d[t]=e
return e
end
function register_pattern_virtual(t,e)
IFACE_PATTERNS_VIRTUAL[#IFACE_PATTERNS_VIRTUAL+1]=e
end
function register_error_code(o,e,a)
if t(e)=="string"and
t(a)=="string"and
not IFACE_ERRORS[e]
then
IFACE_ERRORS[e]=a
return true
end
return false
end
function has_ipv6(e)
return v.access("/proc/net/ipv6_route")
end
function add_network(a,t,o)
local a=a:get_network(t)
if t and#t>0 and t:match("^[a-zA-Z0-9_]+$")and not a then
if e:section("network","interface",t,o)then
return network(t)
end
elseif a and a:is_empty()then
if o then
local e,e
for e,t in l(o)do
a:set(e,t)
end
end
return a
end
end
function get_network(i,o)
if o and e:get("network",o)=="interface"then
return network(o)
elseif o then
local e=a.ubus("network.interface","status",{interface=o})
if t(e)=="table"and
t(e.proto)=="string"
then
return network(o,e.proto)
end
end
end
function get_networks(o)
local n={}
local o={}
e:foreach("network","interface",
function(e)
o[e['.name']]=network(e['.name'])
end)
local e=a.ubus("network.interface","dump",{})
if t(e)=="table"and
t(e.interface)=="table"
then
local a,a
for a,e in i(e.interface)do
if t(e)=="table"and
t(e.proto)=="string"and
t(e.interface)=="string"
then
if not o[e.interface]then
o[e.interface]=network(e.interface,e.proto)
end
end
end
end
local e
for e in a.kspairs(o)do
n[#n+1]=o[e]
end
return n
end
function del_network(o,t)
local n=e:delete("network",t)
if n then
e:delete_all("luci","ifstate",
function(e)return(e.interface==t)end)
e:delete_all("network","alias",
function(e)return(e.interface==t)end)
e:delete_all("network","route",
function(e)return(e.interface==t)end)
e:delete_all("network","route6",
function(e)return(e.interface==t)end)
e:foreach("wireless","wifi-iface",
function(i)
local o
local o={}
for e in a.imatch(i.network)do
if e~=t then
o[#o+1]=e
end
end
if#o>0 then
e:set("wireless",i['.name'],"network",
h.concat(o," "))
else
e:delete("wireless",i['.name'],"network")
end
end)
local a,e=g(s,"luci.model.firewall")
if a then
e.init()
e:del_network(t)
end
end
return n
end
function rename_network(i,o,t)
local n
if t and#t>0 and t:match("^[a-zA-Z0-9_]+$")and not i:get_network(t)then
n=e:section("network","interface",t,e:get_all("network",o))
if n then
e:foreach("network","alias",
function(a)
if a.interface==o then
e:set("network",a['.name'],"interface",t)
end
end)
e:foreach("network","route",
function(a)
if a.interface==o then
e:set("network",a['.name'],"interface",t)
end
end)
e:foreach("network","route6",
function(a)
if a.interface==o then
e:set("network",a['.name'],"interface",t)
end
end)
e:foreach("wireless","wifi-iface",
function(n)
local i
local i={}
for e in a.imatch(n.network)do
if e==o then
i[#i+1]=t
else
i[#i+1]=e
end
end
if#i>0 then
e:set("wireless",n['.name'],"network",
h.concat(i," "))
end
end)
e:delete("network",o)
end
end
return n or false
end
function get_interface(t,e)
if n[e]or _wifi_iface(e)then
return interface(e)
else
local e=f(e)
return e and interface(e)
end
end
function get_interfaces(o)
local o
local i={}
local o={}
e:foreach("network","interface",
function(e)
for e in a.imatch(e.ifname)do
if not _iface_ignore(e)and not _iface_virtual(e)and not _wifi_iface(e)then
o[e]=interface(e)
end
end
end)
for t in a.kspairs(n)do
if not(o[t]or _iface_ignore(t)or _iface_virtual(t)or _wifi_iface(t))then
o[t]=interface(t)
end
end
e:foreach("network","switch_vlan",
function(e)
if t(e.ports)~="string"or
t(e.device)~="string"or
t(p[e.device])~="table"
then
return
end
local t,t
for t,a in e.ports:gmatch("(%d+)([tu]?)")do
local t=p[e.device].netdevs[t]
if t then
if not o[t]then
o[t]=interface(t)
end
w[t]=true
if a=="t"then
local e=k(e.vid or e.vlan)
if e~=nil and e>=0 and e<=4095 then
local e="%s.%d"%{t,e}
if not o[e]then
o[e]=interface(e)
end
w[e]=true
end
end
end
end
end)
for e in a.kspairs(o)do
i[#i+1]=o[e]
end
local t={}
local o={}
e:foreach("wireless","wifi-iface",
function(e)
if e.device then
t[e.device]=t[e.device]and t[e.device]+1 or 1
local e="%s.network%d"%{e.device,t[e.device]}
o[e]=interface(e)
end
end)
for e in a.kspairs(o)do
i[#i+1]=o[e]
end
return i
end
function ignore_interface(t,e)
return _iface_ignore(e)
end
function get_wifidev(a,t)
if e:get("wireless",t)=="wifi-device"then
return wifidev(t)
end
end
function get_wifidevs(t)
local t={}
local o={}
e:foreach("wireless","wifi-device",
function(e)o[#o+1]=e['.name']end)
local e
for a,e in a.vspairs(o)do
t[#t+1]=wifidev(e)
end
return t
end
function get_wifinet(t,e)
local e=_wifi_sid_by_ifname(e)
if e then
return wifinet(e)
end
end
function add_wifinet(o,o,a)
if t(a)=="table"and a.device and
e:get("wireless",a.device)=="wifi-device"
then
local e=e:section("wireless","wifi-iface",nil,a)
return wifinet(e)
end
end
function del_wifinet(a,t)
local t=_wifi_sid_by_ifname(t)
if t then
e:delete("wireless",t)
return true
end
return false
end
function get_status_by_route(e,h,s)
local o={}
local e,e
for t,e in i(a.ubus())do
local n=e:match("^network%.interface%.(.+)")
if n then
local e=a.ubus(e,"status",{})
if e and e.route then
local t
for a,t in i(e.route)do
if not t.table and t.target==h and t.mask==s then
o[n]=e
end
end
end
end
end
return o
end
function get_status_by_address(e,o)
local e,e
for t,e in i(a.ubus())do
local t=e:match("^network%.interface%.(.+)")
if t then
local e=a.ubus(e,"status",{})
if e and e['ipv4-address']then
local a
for i,a in i(e['ipv4-address'])do
if a.address==o then
return t,e
end
end
end
if e and e['ipv6-address']then
local a
for i,a in i(e['ipv6-address'])do
if a.address==o then
return t,e
end
end
end
if e and e['ipv6-prefix-assignment']then
local a
for i,a in i(e['ipv6-prefix-assignment'])do
if a and a['local-address']and a['local-address'].address==o then
return t,e
end
end
end
end
end
end
function get_wan_networks(t)
local e,e
local e={}
local t=t:get_status_by_route("0.0.0.0",0)
for a,t in l(t)do
e[#e+1]=network(a,t.proto)
end
return e
end
function get_wan6_networks(t)
local e,e
local e={}
local t=t:get_status_by_route("::",0)
for t,a in l(t)do
e[#e+1]=network(t,a.proto)
end
return e
end
function get_switch_topologies(e)
return p
end
function network(t,a)
if t then
local e=a or e:get("network",t,"proto")
local e=e and d[e]or protocol
return e(t)
end
end
function protocol.__init__(e,t)
e.sid=t
end
function protocol._get(o,a)
local e=e:get("network",o.sid,a)
if t(e)=="table"then
return h.concat(e," ")
end
return e or""
end
function protocol._ubus(e,t)
if not m[e.sid]then
m[e.sid]=a.ubus("network.interface.%s"%e.sid,
"status",{})
end
if m[e.sid]and t then
return m[e.sid][t]
end
return m[e.sid]
end
function protocol.get(e,t)
return _get("network",e.sid,t)
end
function protocol.set(e,t,a)
return _set("network",e.sid,t,a)
end
function protocol.ifname(t)
local e
if t:is_floating()then
e=t:_ubus("l3_device")
else
e=t:_ubus("device")
end
if not e then
e=j(t.sid)
end
return e
end
function protocol.proto(e)
return"none"
end
function protocol.get_i18n(e)
local e=e:proto()
if e=="none"then
return o.translate("Unmanaged")
elseif e=="static"then
return o.translate("Static address")
elseif e=="dhcp"then
return o.translate("DHCP client")
else
return o.translate("Unknown")
end
end
function protocol.type(e)
return e:_get("type")
end
function protocol.name(e)
return e.sid
end
function protocol.uptime(e)
return e:_ubus("uptime")or 0
end
function protocol.expires(e)
local a=e:_ubus("uptime")
local e=e:_ubus("data")
if t(a)=="number"and t(e)=="table"and
t(e.leasetime)=="number"
then
local e=(e.leasetime-(a%e.leasetime))
return e>0 and e or 0
end
return-1
end
function protocol.metric(e)
return e:_ubus("metric")or 0
end
function protocol.zonename(e)
local e=e:_ubus("data")
if t(e)=="table"and t(e.zone)=="string"then
return e.zone
end
return nil
end
function protocol.ipaddr(e)
local e=e:_ubus("ipv4-address")
return e and#e>0 and e[1].address
end
function protocol.ipaddrs(e)
local a=e:_ubus("ipv4-address")
local e={}
if t(a)=="table"then
local t,t
for a,t in i(a)do
e[#e+1]="%s/%d"%{t.address,t.mask}
end
end
return e
end
function protocol.netmask(e)
local e=e:_ubus("ipv4-address")
return e and#e>0 and
r.IPv4("0.0.0.0/%d"%e[1].mask):mask():string()
end
function protocol.gwaddr(e)
local t,t
for t,e in i(e:_ubus("route")or{})do
if e.target=="0.0.0.0"and e.mask==0 then
return e.nexthop
end
end
end
function protocol.dnsaddrs(t)
local e={}
local a,a
for a,t in i(t:_ubus("dns-server")or{})do
if not t:match(":")then
e[#e+1]=t
end
end
return e
end
function protocol.ip6addr(t)
local e=t:_ubus("ipv6-address")
if e and#e>0 then
return"%s/%d"%{e[1].address,e[1].mask}
else
e=t:_ubus("ipv6-prefix-assignment")
if e and#e>0 then
return"%s/%d"%{e[1].address,e[1].mask}
end
end
end
function protocol.ip6addrs(o)
local e=o:_ubus("ipv6-address")
local a={}
local n,n
if t(e)=="table"then
for t,e in i(e)do
a[#a+1]="%s/%d"%{e.address,e.mask}
end
end
e=o:_ubus("ipv6-prefix-assignment")
if t(e)=="table"then
for o,e in i(e)do
if t(e["local-address"])=="table"and
t(e["local-address"].mask)=="number"and
t(e["local-address"].address)=="string"
then
a[#a+1]="%s/%d"%{
e["local-address"].address,
e["local-address"].mask
}
end
end
end
return a
end
function protocol.gw6addr(e)
local t,t
for t,e in i(e:_ubus("route")or{})do
if e.target=="::"and e.mask==0 then
return r.IPv6(e.nexthop):string()
end
end
end
function protocol.dns6addrs(t)
local e={}
local a,a
for a,t in i(t:_ubus("dns-server")or{})do
if t:match(":")then
e[#e+1]=t
end
end
return e
end
function protocol.ip6prefix(e)
local e=e:_ubus("ipv6-prefix")
if e and#e>0 then
return"%s/%d"%{e[1].address,e[1].mask}
end
end
function protocol.errors(a)
local n,n,e
local a=a:_ubus("errors")
if t(a)=="table"then
for i,a in i(a)do
if t(a)=="table"and
t(a.code)=="string"
then
e=e or{}
e[#e+1]=IFACE_ERRORS[a.code]or o.translatef("Unknown error (%s)",a.code)
end
end
end
return e
end
function protocol.is_bridge(e)
return(not e:is_virtual()and e:type()=="bridge")
end
function protocol.opkg_package(e)
return nil
end
function protocol.is_installed(e)
return true
end
function protocol.is_virtual(e)
return false
end
function protocol.is_floating(e)
return false
end
function protocol.is_dynamic(e)
return(e:_ubus("dynamic")==true)
end
function protocol.is_auto(e)
return(e:_get("auto")~="0")
end
function protocol.is_alias(o)
local i,t=nil,nil
for e in a.imatch(e:get("network",o.sid,"ifname"))do
if#e>1 and e:byte(1)==64 then
t=e:sub(2)
elseif t~=nil then
t=nil
end
end
return t
end
function protocol.is_empty(t)
if t:is_floating()then
return false
else
local e=true
if(t:_get("ifname")or""):match("%S+")then
e=false
end
if e and j(t.sid)then
e=false
end
return e
end
end
function protocol.is_up(e)
return(e:_ubus("up")==true)
end
function protocol.add_interface(t,e)
e=_M:ifnameof(e)
if e and not t:is_floating()then
local a=_wifi_sid_by_ifname(e)
if a then
_append("wireless",a,"network",t.sid)
else
_append("network",t.sid,"ifname",e)
end
end
end
function protocol.del_interface(t,e)
e=_M:ifnameof(e)
if e and not t:is_floating()then
local a=_wifi_sid_by_ifname(e)
if a then _filter("wireless",a,"network",t.sid)end
_filter("network",t.sid,"ifname",e)
end
end
function protocol.get_interface(t)
if t:is_virtual()then
y[t:proto().."-"..t.sid]=true
return interface(t:proto().."-"..t.sid,t)
elseif t:is_bridge()then
b["br-"..t.sid]=true
return interface("br-"..t.sid,t)
else
local o=t:_ubus("l3_device")or t:_ubus("device")
if o then
return interface(o,t)
end
for e in a.imatch(e:get("network",t.sid,"ifname"))do
e=e:match("^[^:/]+")
return e and interface(e,t)
end
o=j(t.sid)
return o and interface(o,t)
end
end
function protocol.get_interfaces(t)
if t:is_bridge()or(t:is_virtual()and not t:is_floating())then
local o={}
local i
local n={}
for e in a.imatch(t:get("ifname"))do
e=e:match("^[^:/]+")
n[e]=interface(e,t)
end
for e in a.kspairs(n)do
o[#o+1]=n[e]
end
local n={}
e:foreach("wireless","wifi-iface",
function(e)
if e.device then
local o
for a in a.imatch(e.network)do
if a==t.sid then
i=f(e[".name"])
if i then
n[i]=interface(i,t)
end
end
end
end
end)
for e in a.kspairs(n)do
o[#o+1]=n[e]
end
return o
end
end
function protocol.contains_interface(t,o)
o=_M:ifnameof(o)
if not o then
return false
elseif t:is_virtual()and t:proto().."-"..t.sid==o then
return true
elseif t:is_bridge()and"br-"..t.sid==o then
return true
else
local i
for e in a.imatch(t:get("ifname"))do
e=e:match("[^:]+")
if e==o then
return true
end
end
local o=_wifi_sid_by_ifname(o)
if o then
local i
for e in a.imatch(e:get("wireless",o,"network"))do
if e==t.sid then
return true
end
end
end
end
return false
end
function protocol.adminlink(e)
local a,t=g(s,"luci.dispatcher")
return a and t.build_url("admin","network","network",e.sid)
end
interface=a.class()
function interface.__init__(e,t,o)
local a=_wifi_sid_by_ifname(t)
if a then
e.wif=wifinet(a)
e.ifname=e.wif:ifname()
end
e.ifname=e.ifname or t
e.dev=n[e.ifname]
e.network=o
end
function interface._ubus(e,t)
if not c[e.ifname]then
c[e.ifname]=a.ubus("network.device","status",
{name=e.ifname})
end
if c[e.ifname]and t then
return c[e.ifname][t]
end
return c[e.ifname]
end
function interface.name(e)
return e.wif and e.wif:ifname()or e.ifname
end
function interface.mac(e)
return r.checkmac(e:_ubus("macaddr"))
end
function interface.ipaddrs(e)
return e.dev and e.dev.ipaddrs or{}
end
function interface.ip6addrs(e)
return e.dev and e.dev.ip6addrs or{}
end
function interface.type(e)
if e.ifname and e.ifname:byte(1)==64 then
return"alias"
elseif e.wif or _wifi_iface(e.ifname)then
return"wifi"
elseif b[e.ifname]then
return"bridge"
elseif y[e.ifname]then
return"tunnel"
elseif e.ifname:match("%.")then
return"vlan"
elseif w[e.ifname]then
return"switch"
else
return"ethernet"
end
end
function interface.shortname(e)
if e.wif then
return e.wif:shortname()
else
return e.ifname
end
end
function interface.get_i18n(e)
if e.wif then
return"%s: %s %q"%{
o.translate("Wireless Network"),
e.wif:active_mode(),
e.wif:active_ssid()or e.wif:active_bssid()or e.wif:id()or"?"
}
else
return"%s: %q"%{e:get_type_i18n(),e:name()}
end
end
function interface.get_type_i18n(t)
local e=t:type()
if e=="alias"then
return o.translate("Alias Interface")
elseif e=="wifi"then
return o.translate("Wireless Adapter")
elseif e=="bridge"then
return o.translate("Bridge")
elseif e=="switch"then
return o.translate("Ethernet Switch")
elseif e=="vlan"then
if w[t.ifname]then
return o.translate("Switch VLAN")
else
return o.translate("Software VLAN")
end
elseif e=="tunnel"then
return o.translate("Tunnel Interface")
else
return o.translate("Ethernet Adapter")
end
end
function interface.adminlink(e)
if e.wif then
return e.wif:adminlink()
end
end
function interface.ports(e)
local t=e:_ubus("bridge-members")
if t then
local e,e
local e={}
for a,t in i(t)do
e[#e+1]=interface(t)
end
return e
end
end
function interface.bridge_id(e)
if e.dev and e.dev.bridge then
return e.dev.bridge.id
else
return nil
end
end
function interface.bridge_stp(e)
if e.dev and e.dev.bridge then
return e.dev.bridge.stp
else
return false
end
end
function interface.is_up(t)
local e=t:_ubus("up")
if e==nil then
e=(t:type()=="alias")
end
return e or false
end
function interface.is_bridge(e)
return(e:type()=="bridge")
end
function interface.is_bridgeport(e)
return e.dev and e.dev.bridge and
(e.dev.bridge.name~=e:name())and true or false
end
function interface.tx_bytes(e)
local e=e:_ubus("statistics")
return e and e.tx_bytes or 0
end
function interface.rx_bytes(e)
local e=e:_ubus("statistics")
return e and e.rx_bytes or 0
end
function interface.tx_packets(e)
local e=e:_ubus("statistics")
return e and e.tx_packets or 0
end
function interface.rx_packets(e)
local e=e:_ubus("statistics")
return e and e.rx_packets or 0
end
function interface.get_network(e)
return e:get_networks()[1]
end
function interface.get_networks(e)
if not e.networks then
local t={}
local a,a
for o,a in i(_M:get_networks())do
if a:contains_interface(e.ifname)or
a:ifname()==e.ifname
then
t[#t+1]=a
end
end
h.sort(t,function(t,e)return t.sid<e.sid end)
e.networks=t
return t
else
return e.networks
end
end
function interface.get_wifinet(e)
return e.wif
end
wifidev=a.class()
function wifidev.__init__(t,a)
local o,e=e:get("wireless",a)
if o=="wifi-device"and e~=nil then
t.sid=e
t.iwinfo=q(t.sid,true)
end
t.sid=t.sid or a
t.iwinfo=t.iwinfo or{ifname=t.sid}
end
function wifidev.get(e,t)
return _get("wireless",e.sid,t)
end
function wifidev.set(t,a,e)
return _set("wireless",t.sid,a,e)
end
function wifidev.name(e)
return e.sid
end
function wifidev.hwmodes(e)
local e=e.iwinfo.hwmodelist
if e and E(e)then
return e
else
return{b=true,g=true}
end
end
function wifidev.get_i18n(a)
local o=a.iwinfo.hardware_name or"Generic"
if a.iwinfo.type=="wl"then
o="Broadcom"
end
local e=""
local t=a:hwmodes()
if t.a then e=e.."a"end
if t.b then e=e.."b"end
if t.g then e=e.."g"end
if t.n then e=e.."n"end
if t.ac then e="ac"end
return"%s 802.11%s Wireless Controller (%s)"%{o,e,a:name()}
end
function wifidev.is_up(e)
if u[e.sid]then
return(u[e.sid].up==true)
end
return false
end
function wifidev.get_wifinet(a,t)
if e:get("wireless",t)=="wifi-iface"then
return wifinet(t)
else
local e=_wifi_sid_by_ifname(t)
if e then
return wifinet(e)
end
end
end
function wifidev.get_wifinets(a)
local t={}
e:foreach("wireless","wifi-iface",
function(e)
if e.device==a.sid then
t[#t+1]=wifinet(e['.name'])
end
end)
return t
end
function wifidev.add_wifinet(a,t)
t=t or{}
t.device=a.sid
local e=e:section("wireless","wifi-iface",nil,t)
if e then
return wifinet(e,t)
end
end
function wifidev.del_wifinet(o,t)
if a.instanceof(t,wifinet)then
t=t.sid
elseif e:get("wireless",t)~="wifi-iface"then
t=_wifi_sid_by_ifname(t)
end
if t and e:get("wireless",t,"device")==o.sid then
e:delete("wireless",t)
return true
end
return false
end
wifinet=a.class()
function wifinet.__init__(s,o,e)
local t,i,e,n,a
t=z(o)
if t then
i=o
e,n,a=A(t)
else
e,n,a=x(o)
if e and n and a then
t=a.section
i=f(t)
else
e,n,a=A(o)
if e and n and a then
t=o
i=f(t)
else
i,e=f(o)
if i and e then
t=o
end
end
end
end
local h=
(a and q(a.ifname))or
(e and q(e))or
{ifname=(i or t or o)}
s.sid=t or o
s.wdev=h.ifname
s.iwinfo=h
s.netid=i
s._ubusdata={
radio=e,
dev=n,
net=a
}
end
function wifinet.ubus(e,...)
local a,e=e._ubusdata
for a=1,_('#',...)do
if t(e)=="table"then
e=e[_(a,...)]
else
return nil
end
end
return e
end
function wifinet.get(t,e)
return _get("wireless",t.sid,e)
end
function wifinet.set(e,t,a)
return _set("wireless",e.sid,t,a)
end
function wifinet.mode(e)
return e:ubus("net","config","mode")or e:get("mode")or"ap"
end
function wifinet.ssid(e)
return e:ubus("net","config","ssid")or e:get("ssid")
end
function wifinet.bssid(e)
return e:ubus("net","config","bssid")or e:get("bssid")
end
function wifinet.network(t)
local o,e=nil,{}
for t in a.imatch(t:ubus("net","config","network")or t:get("network"))do
e[#e+1]=t
end
return e
end
function wifinet.id(e)
return e.netid
end
function wifinet.name(e)
return e.sid
end
function wifinet.ifname(t)
local e=t:ubus("net","ifname")or t.iwinfo.ifname
if not e or e:match("^wifi%d")or e:match("^radio%d")then
e=t.netid
end
return e
end
function wifinet.get_device(e)
local e=e:ubus("radio")or e:get("device")
return e and wifidev(e)or nil
end
function wifinet.is_up(e)
local e=e:get_interface()
return(e and e:is_up()or false)
end
function wifinet.active_mode(e)
local e=e.iwinfo.mode or e:ubus("net","config","mode")or e:get("mode")or"ap"
if e=="ap"then e="Master"
elseif e=="sta"then e="Client"
elseif e=="adhoc"then e="Ad-Hoc"
elseif e=="mesh"then e="Mesh"
elseif e=="monitor"then e="Monitor"
end
return e
end
function wifinet.active_mode_i18n(e)
return o.translate(e:active_mode())
end
function wifinet.active_ssid(e)
return e.iwinfo.ssid or e:ubus("net","config","ssid")or e:get("ssid")
end
function wifinet.active_bssid(e)
return e.iwinfo.bssid or e:ubus("net","config","bssid")or e:get("bssid")
end
function wifinet.active_encryption(e)
local e=e.iwinfo and e.iwinfo.encryption
return e and e.description or"-"
end
function wifinet.assoclist(e)
return e.iwinfo.assoclist or{}
end
function wifinet.frequency(e)
local e=e.iwinfo.frequency
if e and e>0 then
return"%.03f"%(e/1000)
end
end
function wifinet.bitrate(e)
local e=e.iwinfo.bitrate
if e and e>0 then
return(e/1000)
end
end
function wifinet.channel(e)
return e.iwinfo.channel or e:ubus("dev","config","channel")or
k(e:get("channel"))
end
function wifinet.signal(e)
return e.iwinfo.signal or 0
end
function wifinet.noise(e)
return e.iwinfo.noise or 0
end
function wifinet.country(e)
return e.iwinfo.country or e:ubus("dev","config","country")or"00"
end
function wifinet.txpower(e)
local t=(e.iwinfo.txpower or 0)
return t+e:txpower_offset()
end
function wifinet.txpower_offset(e)
return e.iwinfo.txpower_offset or 0
end
function wifinet.signal_level(e,t,a)
if e:active_bssid()~="00:00:00:00:00:00"then
local t=t or e:signal()
local e=a or e:noise()
if t<0 and e<0 then
local e=-1*(e-t)
return T.floor(e/5)
else
return 0
end
else
return-1
end
end
function wifinet.signal_percent(e)
local t=e.iwinfo.quality or 0
local e=e.iwinfo.quality_max or 0
if t>0 and e>0 then
return T.floor((100/e)*t)
else
return 0
end
end
function wifinet.shortname(e)
return"%s %q"%{
o.translate(e:active_mode()),
e:active_ssid()or e:active_bssid()or e:id()
}
end
function wifinet.get_i18n(e)
return"%s: %s %q (%s)"%{
o.translate("Wireless Network"),
o.translate(e:active_mode()),
e:active_ssid()or e:active_bssid()or e:id(),
e:ifname()
}
end
function wifinet.adminlink(t)
local a,e=g(s,"luci.dispatcher")
return e and e.build_url("admin","network","wireless",t.netid)
end
function wifinet.get_network(e)
return e:get_networks()[1]
end
function wifinet.get_networks(o)
local t={}
local i
for a in a.imatch(o:ubus("net","config","network")or o:get("network"))do
if e:get("network",a)=="interface"then
t[#t+1]=network(a)
end
end
h.sort(t,function(e,t)return e.sid<t.sid end)
return t
end
function wifinet.get_interface(e)
return interface(e:ifname())
end
_M:register_protocol("static")
_M:register_protocol("dhcp")
_M:register_protocol("none")
local e=v.dir(a.libpath().."/model/network")
if e then
local t
for e in e do
if e:match("%.lua$")then
s("luci.model.network."..e:gsub("%.lua$",""))
end
end
end
