local a=luci.model.network
local e,e
for t,e in ipairs({"ppp","pptp","pppoe","pppoa","l2tp"})do
local t=a:register_protocol(e)
function t.get_i18n(t)
if e=="ppp"then
return luci.i18n.translate("PPP")
elseif e=="pptp"then
return luci.i18n.translate("PPtP")
elseif e=="pppoe"then
return luci.i18n.translate("PPPoE")
elseif e=="pppoa"then
return luci.i18n.translate("PPPoATM")
elseif e=="l2tp"then
return luci.i18n.translate("L2TP")
end
end
function t.ifname(t)
return e.."-"..t.sid
end
function t.opkg_package(t)
if e=="ppp"then
return e
elseif e=="pptp"then
return"ppp-mod-pptp"
elseif e=="pppoe"then
return"ppp-mod-pppoe"
elseif e=="pppoa"then
return"ppp-mod-pppoa"
elseif e=="l2tp"then
return"xl2tpd"
end
end
function t.is_installed(t)
if e=="pppoa"then
return(nixio.fs.glob("/usr/lib/pppd/*/pppoatm.so")()~=nil)
elseif e=="pppoe"then
return(nixio.fs.glob("/usr/lib/pppd/*/rp-pppoe.so")()~=nil)
elseif e=="pptp"then
return(nixio.fs.glob("/usr/lib/pppd/*/pptp.so")()~=nil)
elseif e=="l2tp"then
return nixio.fs.access("/lib/netifd/proto/l2tp.sh")
else
return nixio.fs.access("/lib/netifd/proto/ppp.sh")
end
end
function t.is_floating(t)
return(e~="pppoe")
end
function t.is_virtual(e)
return true
end
function t.get_interfaces(e)
if e:is_floating()then
return nil
else
return a.protocol.get_interfaces(e)
end
end
function t.contains_interface(e,t)
if e:is_floating()then
return(a:ifnameof(t)==e:ifname())
else
return a.protocol.contains_interface(e,t)
end
end
a:register_pattern_virtual("^%s%%-%%w"%e)
end
