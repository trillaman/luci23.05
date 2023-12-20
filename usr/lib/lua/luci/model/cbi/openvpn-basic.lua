local o=require("nixio.fs")
local e={
{ListValue,
"verb",
{0,1,2,3,4,5,6,7,8,9,10,11},
translate("Set output verbosity")},
{Value,
"nice",
0,
translate("Change process priority")},
{Value,
"port",
1194,
translate("TCP/UDP port # for both local and remote")},
{ListValue,
"dev_type",
{"tun","tap"},
translate("Type of used device")},
{Value,
"ifconfig",
"10.200.200.3 10.200.200.1",
translate("Set tun/tap adapter parameters")},
{Value,
"server",
"10.200.200.0 255.255.255.0",
translate("Configure server mode")},
{Value,
"server_bridge",
"192.168.1.1 255.255.255.0 192.168.1.128 192.168.1.254",
translate("Configure server bridge")},
{Flag,
"nobind",
0,
translate("Do not bind to local address and port")},
{ListValue,
"comp_lzo",
{"yes","no","adaptive"},
translate("Security recommendation: It is recommended to not enable compression and set this parameter to `no`")},
{Value,
"keepalive",
"10 60",
translate("Helper directive to simplify the expression of --ping and --ping-restart in server mode configurations")},
{Flag,
"client",
0,
translate("Configure client mode")},
{Flag,
"client_to_client",
0,
translate("Allow client-to-client traffic")},
{DynamicList,
"remote",
"vpnserver.example.org",
translate("Remote host name or IP address")},
{FileUpload,
"secret",
"/etc/openvpn/secret.key",
translate("Enable Static Key encryption mode (non-TLS)")},
{ListValue,
"key_direction",
{0,1},
translate("The key direction for 'tls-auth' and 'secret' options")},
{FileUpload,
"pkcs12",
"/etc/easy-rsa/keys/some-client.pk12",
translate("PKCS#12 file containing keys")},
{FileUpload,
"ca",
"/etc/easy-rsa/keys/ca.crt",
translate("Certificate authority")},
{FileUpload,
"dh",
"/etc/easy-rsa/keys/dh1024.pem",
translate("Diffie-Hellman parameters")},
{FileUpload,
"cert",
"/etc/easy-rsa/keys/some-client.crt",
translate("Local certificate")},
{FileUpload,
"key",
"/etc/easy-rsa/keys/some-client.key",
translate("Local private key")},
}
local t=o.access("/proc/net/ipv6_route")
if t then
table.insert(e,{ListValue,
"proto",
{"udp","tcp-client","tcp-server","udp6","tcp6-client","tcp6-server"},
translate("Use protocol")
})
else
table.insert(e,{ListValue,
"proto",
{"udp","tcp-client","tcp-server"},
translate("Use protocol")
})
end
local a=Map("openvpn")
a.redirect=luci.dispatcher.build_url("admin","vpn","openvpn")
a.apply_on_parse=true
local t=a:section(SimpleSection)
t.template="openvpn/pageswitch"
t.mode="basic"
t.instance=arg[1]
local t=a:section(NamedSection,arg[1],"openvpn")
for a,e in ipairs(e)do
local t=t:option(
e[1],e[2],
e[2],e[4]
)
t.optional=true
if e[1]==DummyValue then
t.value=e[3]
elseif e[1]==FileUpload then
t.initial_directory="/etc/openvpn"
function t.cfgvalue(e,t)
local e=AbstractValue.cfgvalue(e,t)
if e then
return e
end
end
function t.formvalue(e,a)
local t=AbstractValue.formvalue(e,a)
local e=luci.http.formvalue("cbid."..e.map.config.."."..a.."."..e.option..".textbox")
if t and t~=""then
return t
end
if e and e~=""then
return e
end
end
function t.remove(e,t)
local a=AbstractValue.cfgvalue(e,t)
local i=luci.http.formvalue("cbid."..e.map.config.."."..t.."."..e.option..".textbox")
if a and o.access(a)and i==""then
o.unlink(a)
end
return AbstractValue.remove(e,t)
end
elseif e[1]==Flag then
t.default=nil
else
if e[1]==DynamicList then
function t.cfgvalue(...)
local e=AbstractValue.cfgvalue(...)
return(e and type(e)~="table")and{e}or e
end
end
if type(e[3])=="table"then
if t.optional then t:value("","-- remove --")end
for a,e in ipairs(e[3])do
e=tostring(e)
t:value(e)
end
t.default=tostring(e[3][1])
else
t.default=tostring(e[3])
end
end
for a=5,#e do
if type(e[a])=="table"then
t:depends(e[a])
end
end
end
return a
