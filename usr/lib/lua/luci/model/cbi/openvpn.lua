local o=require"nixio.fs"
local t=require"luci.sys"
local a=require"luci.model.uci".cursor()
local e=t.exec("ps --help 2>&1 | grep BusyBox")
local n=(string.len(e)>0)and"ps w"or"ps axfw"
local i=Map("openvpn",translate("OpenVPN"))
local e=i:section(TypedSection,"openvpn",translate("OpenVPN instances"),translate("Below is a list of configured OpenVPN instances and their current state"))
e.template="cbi/tblsection"
e.template_addremove="openvpn/cbi-select-input-add"
e.addremove=true
e.add_select_options={}
local s=e:option(DummyValue,"config")
function s.cfgvalue(t,o)
local t=t.map:get(o,"config")
if t then
e.extedit=luci.dispatcher.build_url("admin","vpn","openvpn","file","%s")
else
e.extedit=luci.dispatcher.build_url("admin","vpn","openvpn","basic","%s")
end
end
a:load("openvpn_recipes")
a:foreach("openvpn_recipes","openvpn_recipe",
function(t)
e.add_select_options[t['.name']]=
t['_description']or t['.name']
end
)
function e.getPID(e)
local e=t.exec("%s | grep -w '[o]penvpn(%s)'"%{n,e})
if e and#e>0 then
return tonumber(e:match("^%s*(%d+)"))
else
return nil
end
end
function e.parse(t,o)
local a=luci.http.formvalue(
luci.cbi.CREATE_PREFIX..t.config.."."..
t.sectiontype..".select"
)
if a and not e.add_select_options[a]then
t.invalid_cts=true
else
TypedSection.parse(t,o)
end
end
function e.create(t,e)
local o=luci.http.formvalue(
luci.cbi.CREATE_PREFIX..t.config.."."..
t.sectiontype..".select"
)
local e=luci.http.formvalue(
luci.cbi.CREATE_PREFIX..t.config.."."..
t.sectiontype..".text"
)
if#e>3 and not e:match("[^a-zA-Z0-9_]")then
local i=a:section("openvpn","openvpn",e)
if i then
local o=a:get_all("openvpn_recipes",o)
for o,t in pairs(o)do
if o~="_role"and o~="_description"then
if type(t)=="boolean"then
t=t and"1"or"0"
end
a:set("openvpn",e,o,t)
end
end
a:save("openvpn")
a:commit("openvpn")
if extedit then
luci.http.redirect(t.extedit:format(e))
end
end
elseif#e>0 then
t.invalid_cts=true
end
return 0
end
function e.remove(i,t)
local n="/etc/openvpn/"..t..".ovpn"
local i="/etc/openvpn/"..t..".auth"
if o.access(n)then
o.unlink(n)
end
if o.access(i)then
o.unlink(i)
end
a:delete("openvpn",t)
a:save("openvpn")
a:commit("openvpn")
end
e:option(Flag,"enabled",translate("Enabled"))
local a=e:option(DummyValue,"_active",translate("Started"))
function a.cfgvalue(o,a)
local e=e.getPID(a)
if e~=nil then
return(t.process.signal(e,0))
and translatef("yes (%i)",e)
or translate("no")
end
return translate("no")
end
local a=e:option(Button,"_updown",translate("Start/Stop"))
a._state=false
a.redirect=luci.dispatcher.build_url(
"admin","vpn","openvpn"
)
function a.cbid(a,o)
local e=e.getPID(o)
a._state=e~=nil and t.process.signal(e,0)
a.option=a._state and"stop"or"start"
return AbstractValue.cbid(a,o)
end
function a.cfgvalue(e,t)
e.title=e._state and"stop"or"start"
e.inputstyle=e._state and"reset"or"reload"
end
function a.write(e,a,o)
if e.option=="stop"then
t.call("/etc/init.d/openvpn stop %s"%a)
else
t.call("/etc/init.d/openvpn start %s"%a)
end
luci.http.redirect(e.redirect)
end
local a=e:option(DummyValue,"port",translate("Port"))
function a.cfgvalue(a,i)
local e=AbstractValue.cfgvalue(a,i)
if not e then
local a=a.map:get(i,"config")
if a and o.access(a)then
e=t.exec("awk '{if(match(tolower($1),/^port$/)&&match($2,/[0-9]+/)){cnt++;printf $2;exit}}END{if(cnt==0)printf \"-\"}' "..a)
if e=="-"then
e=t.exec("awk '{if(match(tolower($1),/^remote$/)&&match($3,/[0-9]+/)){cnt++;printf $3;exit}}END{if(cnt==0)printf \"-\"}' "..a)
end
end
end
return e or"-"
end
local e=e:option(DummyValue,"proto",translate("Protocol"))
function e.cfgvalue(i,a)
local e=AbstractValue.cfgvalue(i,a)
if not e then
local a=i.map:get(a,"config")
if a and o.access(a)then
e=t.exec("awk '{if(match(tolower($1),/^proto$/)&&match(tolower($2),/^udp[46]*$|^tcp[a-z46-]*$/)){cnt++;print tolower(substr($2,1,3));exit}}END{if(cnt==0)printf \"-\"}' "..a)
if e=="-"then
e=t.exec("awk '{if(match(tolower($1),/^remote$/)&&match(tolower($4),/^udp[46]*$|^tcp[a-z46-]*$/)){cnt++;print tolower(substr($4,1,3));exit}}END{if(cnt==0)printf \"-\"}' "..a)
end
end
end
return e or"-"
end
function i.on_after_apply(e,e)
t.call('/etc/init.d/openvpn reload')
end
return i
