local e=luci.model.network
local t,t
for a,t in ipairs({"dslite","map","464xlat"})do
local a=e:register_protocol(t)
function a.get_i18n(e)
if t=="dslite"then
return luci.i18n.translate("Dual-Stack Lite (RFC6333)")
elseif t=="map"then
return luci.i18n.translate("MAP / LW4over6")
elseif t=="464xlat"then
return luci.i18n.translate("464XLAT (CLAT)")
end
end
function a.ifname(e)
return t.."-"..e.sid
end
function a.opkg_package(e)
if t=="dslite"then
return"ds-lite"
elseif t=="map"then
return"map-t"
elseif t=="464xlat"then
return"464xlat"
end
end
function a.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/"..t..".sh")
end
function a.is_floating(e)
return true
end
function a.is_virtual(e)
return true
end
function a.get_interfaces(e)
return nil
end
function a.contains_interface(t,a)
return(e:ifnameof(a)==t:ifname())
end
end
e:register_pattern_virtual("^464%-%w")
e:register_pattern_virtual("^ds%-%w")
e:register_pattern_virtual("^map%-%w")
e:register_error_code("AFTR_DNS_FAIL",luci.i18n.translate("Unable to resolve AFTR host name"))
e:register_error_code("INVALID_MAP_RULE",luci.i18n.translate("MAP rule is invalid"))
e:register_error_code("NO_MATCHING_PD",luci.i18n.translate("No matching prefix delegation"))
e:register_error_code("UNSUPPORTED_TYPE",luci.i18n.translate("Unsupported MAP type"))
