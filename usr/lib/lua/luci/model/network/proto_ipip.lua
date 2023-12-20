local t=luci.model.network
local e=luci.model.network.interface
local e=t:register_protocol("ipip")
function e.get_i18n(e)
return luci.i18n.translate("IPv4-in-IPv4 (RFC2003)")
end
function e.ifname(e)
return"ipip-"..e.sid
end
function e.opkg_package(e)
return"ipip"
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/ipip.sh")
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
return(t:ifnameof(a)==e:ifname())
end
t:register_pattern_virtual("^ipip%-%w")
