local a=luci.model.network
local e=luci.util.class(a.interface)
a:register_pattern_virtual("^relay%-%w")
local t=a:register_protocol("relay")
function t.get_i18n(e)
return luci.i18n.translate("Relay bridge")
end
function t.ifname(e)
return"relay-"..e.sid
end
function t.opkg_package(e)
return"relayd"
end
function t.is_installed(e)
return nixio.fs.access("/etc/init.d/relayd")
end
function t.is_floating(e)
return true
end
function t.is_virtual(e)
return true
end
function t.is_up(e)
local e=e:get_interface()
return e and e:is_up()or false
end
function t.get_interface(t)
return e(t.sid,t)
end
function t.get_interfaces(e)
if not e.ifaces then
local o={}
local i,i,t
for e in luci.util.imatch(e:_get("network"))do
e=a:get_network(e)
if e then
t=e:get_interface()
if t then
o[t:name()]=t
end
end
end
for t in luci.util.imatch(e:_get("ifname"))do
t=a:get_interface(t)
if t then
o[t:name()]=t
end
end
e.ifaces={}
for a,t in luci.util.kspairs(o)do
e.ifaces[#e.ifaces+1]=t
end
end
return e.ifaces
end
function t.uptime(e)
local t
local t=0
for e in luci.util.imatch(e:_get("network"))do
e=a:get_network(e)
if e then
t=math.max(t,e:uptime())
end
end
return t
end
function t.errors(e)
return nil
end
function e.__init__(e,a,t)
e.ifname=a
e.network=t
end
function e.type(e)
return"tunnel"
end
function e.is_up(e)
if e.network then
local t,t
for t,e in ipairs(e.network:get_interfaces())do
if not e:is_up()then
return false
end
end
return true
end
return false
end
function e._stat(t,a)
local e=0
if t.network then
local o,o
for o,t in ipairs(t.network:get_interfaces())do
e=e+t[a](t)
end
end
return e
end
function e.rx_bytes(e)return e:_stat("rx_bytes")end
function e.tx_bytes(e)return e:_stat("tx_bytes")end
function e.rx_packets(e)return e:_stat("rx_packets")end
function e.tx_packets(e)return e:_stat("tx_packets")end
function e.mac(e)
if e.network then
local t,t
for t,e in ipairs(e.network:get_interfaces())do
return e:mac()
end
end
end
function e.ipaddrs(e)
local t={}
if e.network then
t[1]=luci.ip.IPv4(e.network:_get("ipaddr"))
end
return t
end
function e.ip6addrs(e)
return{}
end
function e.shortname(e)
return"%s %q"%{luci.i18n.translate("Relay"),e.ifname}
end
function e.get_type_i18n(e)
return luci.i18n.translate("Relay Bridge")
end
