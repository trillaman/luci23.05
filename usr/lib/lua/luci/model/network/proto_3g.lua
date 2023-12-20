local t=luci.model.network
local a=luci.model.network.interface
local e=t:register_protocol("3g")
function e.get_i18n(e)
return luci.i18n.translate("UMTS/GPRS/EV-DO")
end
function e.ifname(e)
return"3g-"..e.sid
end
function e.get_interface(e)
return a(e:ifname(),e)
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/3g.sh")
end
function e.opkg_package(e)
return"comgt"
end
function e.is_floating(e)
return true
end
function e.is_virtual(e)
return true
end
function e.get_interfaces(e)
return nil
end
function e.contains_interface(e,a)
if e:is_floating()then
return(t:ifnameof(a)==e:ifname())
else
return t.protocol.contains_interface(e,a)
end
end
t:register_pattern_virtual("^3g%-%w")
