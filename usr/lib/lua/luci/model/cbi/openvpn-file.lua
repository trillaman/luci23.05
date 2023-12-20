local e=require("luci.ip")
local t=require("nixio.fs")
local i=require("luci.util")
local e=require("luci.model.uci").cursor()
local e=e:get("openvpn",arg[1],"config")
local a=e:match("(.+)%..+")..".auth"
local function o(o,t,a)
local e=Template("openvpn/pageswitch")
e.mode="file"
e.instance=arg[1]
local t=SimpleForm(o,t,a)
t:append(e)
return t
end
if not e or not t.access(e)then
local e=o("error",nil,translatef("The OVPN config file (%s) could not be found, please check your configuration.",e or"n/a"))
e:append(Template("openvpn/ovpn_css"))
e.reset=false
e.submit=false
return e
end
if t.stat(e).size>=102400 then
local e=o("error",nil,
translatef("The size of the OVPN config file (%s) is too large for online editing in LuCI (&ge; 100 KB). ",e)
..translate("Please edit this file directly in a terminal session."))
e:append(Template("openvpn/ovpn_css"))
e.reset=false
e.submit=false
return e
end
f=o("cfg",nil)
f:append(Template("openvpn/ovpn_css"))
f.submit=translate("Save")
f.reset=false
s=f:section(SimpleSection,nil,translatef("Section to modify the OVPN config file (%s)",e))
file=s:option(TextValue,"data1")
file.datatype="string"
file.rows=20
function file.cfgvalue()
return t.readfile(e)or""
end
function file.write(o,o,a)
return t.writefile(e,i.trim(a:gsub("\r\n","\n")).."\n")
end
function file.remove(a,a,a)
return t.writefile(e,"")
end
function s.handle(e,e,e)
return true
end
s=f:section(SimpleSection,nil,translatef("Section to add an optional 'auth-user-pass' file with your credentials (%s)",a))
file=s:option(TextValue,"data2")
file.datatype="string"
file.rows=5
function file.cfgvalue()
return t.readfile(a)or""
end
function file.write(o,o,e)
return t.writefile(a,i.trim(e:gsub("\r\n","\n")).."\n")
end
function file.remove(e,e,e)
return t.writefile(a,"")
end
function s.handle(e,e,e)
return true
end
return f
