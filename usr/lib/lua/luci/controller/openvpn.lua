module("luci.controller.openvpn",package.seeall)
function index()
entry({"admin","vpn","openvpn"},cbi("openvpn"),_("OpenVPN")).acl_depends={"luci-app-openvpn"}
entry({"admin","vpn","openvpn","basic"},cbi("openvpn-basic"),nil).leaf=true
entry({"admin","vpn","openvpn","advanced"},cbi("openvpn-advanced"),nil).leaf=true
entry({"admin","vpn","openvpn","file"},form("openvpn-file"),nil).leaf=true
entry({"admin","vpn","openvpn","upload"},call("ovpn_upload"))
end
function ovpn_upload()
local n=require("nixio.fs")
local o=require("luci.http")
local e=require("luci.util")
local t=require("luci.model.uci").cursor()
local s=o.formvalue("ovpn_file")
local a=o.formvalue("instance_name2")
local e="/etc/openvpn"
local i=e.."/"..a..".ovpn"
if not n.stat(e)then
n.mkdir(e)
end
if a and s then
local e
o.setfilehandler(
function(a,t,o)
local t=t:gsub("\r\n","\n")
if not e and a and a.name=="ovpn_file"then
e=io.open(i,"w")
end
if e and t then
e:write(t)
end
if e and o then
e:close()
end
end
)
if n.access(i)then
if not t:get_first("openvpn",a)then
t:set("openvpn",a,"openvpn")
t:set("openvpn",a,"config",i)
t:save("openvpn")
t:commit("openvpn")
end
end
end
o.redirect(luci.dispatcher.build_url('admin/vpn/openvpn'))
end
