local e=luci.model.uci.cursor_state()
local o=require"luci.model.network"
local a,e,i,t
a=Map("p910nd",translate("p910nd - Printer server"),
translatef("First you have to install the packages to get support for USB (kmod-usb-printer) or parallel port (kmod-lp)."))
o=o.init(a.uci)
e=a:section(TypedSection,"p910nd",translate("Settings"))
e.addremove=true
e.anonymous=true
e:option(Flag,"enabled",translate("enable"))
e:option(Value,"device",translate("Device")).rmempty=true
t=e:option(Value,"bind",translate("Interface"),translate("Specifies the interface to listen on."))
t.template="cbi/network_netlist"
t.nocreate=true
t.unspecified=true
function t.cfgvalue(...)
local e=Value.cfgvalue(...)
if e then
return(o:get_status_by_address(e))
end
end
function t.write(a,t,e)
local e=o:get_network(e)
if e and e:ipaddr()then
Value.write(a,t,e:ipaddr())
end
end
i=e:option(ListValue,"port",translate("Port"),translate("TCP listener port."))
i.rmempty=true
for t=0,9 do
i:value(t,9100+t)
end
e:option(Flag,"bidirectional",translate("Bidirectional mode"))
return a
