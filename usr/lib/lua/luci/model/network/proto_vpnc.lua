local t=luci.model.network
local a=luci.model.network.interface
local e=t:register_protocol("vpnc")
function e.get_i18n(e)
return luci.i18n.translate("VPNC (CISCO 3000 (and others) VPN)")
end
function e.ifname(e)
return"vpn-"..e.sid
end
function e.get_interface(e)
return a(e:ifname(),e)
end
function e.opkg_package(e)
return"vpnc"
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/vpnc.sh")
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
t:register_pattern_virtual("^vpn%-%w")
