local t=luci.model.network
local o=luci.model.network.interface
local e=t:register_protocol("qmi")
function e.get_i18n(e)
return luci.i18n.translate("QMI Cellular")
end
function e.ifname(a)
local e=t._M.protocol
local e=e.ifname(a)
if e==nil then
e="qmi-"..a.sid
end
return e
end
function e.get_interface(e)
return o(e:ifname(),e)
end
function e.opkg_package(e)
return"uqmi"
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/qmi.sh")
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
t:register_pattern_virtual("^qmi%-%w")
t:register_error_code("CALL_FAILED",luci.i18n.translate("Call failed"))
t:register_error_code("NO_CID",luci.i18n.translate("Unable to obtain client ID"))
t:register_error_code("PLMN_FAILED",luci.i18n.translate("Setting PLMN failed"))
