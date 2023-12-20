local e=luci.model.network
local t=e:register_protocol("ncm")
local a=luci.model.network.interface
function t.get_i18n(e)
return luci.i18n.translate("NCM")
end
function t.opkg_package(e)
return"comgt-ncm"
end
function t.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/ncm.sh")
end
function t.is_floating(e)
return true
end
function t.is_virtual(e)
return true
end
function t.get_interface(t)
local e=e.protocol.ifname(t)
if not e then
e="wan"
end
return a(e,t)
end
function t.get_interfaces(e)
return nil
end
function t.contains_interface(t,a)
return(e:ifnameof(a)==t:ifname())
end
e:register_pattern_virtual("^ncm%-%w")
e:register_error_code("CONFIGURE_FAILED",luci.i18n.translate("Configuration failed"))
e:register_error_code("DISCONNECT_FAILED",luci.i18n.translate("Disconnection attempt failed"))
e:register_error_code("FINALIZE_FAILED",luci.i18n.translate("Finalizing failed"))
e:register_error_code("GETINFO_FAILED",luci.i18n.translate("Modem information query failed"))
e:register_error_code("INITIALIZE_FAILED",luci.i18n.translate("Initialization failure"))
e:register_error_code("SETMODE_FAILED",luci.i18n.translate("Setting operation mode failed"))
e:register_error_code("UNSUPPORTED_MODEM",luci.i18n.translate("Unsupported modem"))
