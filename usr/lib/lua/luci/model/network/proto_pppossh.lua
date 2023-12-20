local t=luci.model.network
local e=t:register_protocol("pppossh")
function e.get_i18n(e)
return luci.i18n.translate("PPPoSSH")
end
function e.ifname(e)
return"pppossh-"..e.sid
end
function e.opkg_package(e)
return"pppossh"
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/pppossh.sh")
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
t:register_pattern_virtual("^pppossh%-%w")
