module("luci.dispatcher",package.seeall)
local a=_G.L.http
context=setmetatable({},{
__index=function(t,e)
if e=="request"or e=="requestpath"then
return _G.L.ctx.request_path
elseif e=="requestargs"then
return _G.L.ctx.request_args
else
return _G.L.ctx[e]
end
end
})
uci=require"luci.model.uci"
uci:set_session_id(_G.L.ctx.authsession)
i18n=require"luci.i18n"
i18n.setlanguage(_G.L.dispatcher.lang)
build_url=_G.L.dispatcher.build_url
menu_json=_G.L.dispatcher.menu_json
error404=_G.L.dispatcher.error404
error500=_G.L.dispatcher.error500
function is_authenticated(e)
local e=_G.L.dispatcher.is_authenticated(e)
if e then
return e.sid,e.data,e.acls
end
end
function assign(e,a,o,t)
local e=node(unpack(e))
e.title=o
e.order=t
setmetatable(e,{__index=node(unpack(a))})
return e
end
function entry(e,t,a,o)
local e=node(unpack(e))
e.title=a
e.order=o
e.action=t
return e
end
function get(...)
return node(...)
end
function node(...)
local e=table.concat({...},"/")
if not __entries[e]then
__entries[e]={}
end
return __entries[e]
end
function lookup(...)
local e,t=nil,{}
for e=1,select('#',...)do
local a,e=nil,tostring(select(e,...))
for e in e:gmatch("[^/]+")do
t[#t+1]=e
end
end
local e=menu_json()
for a=1,#t do
e=e.children[t[a]]
if not e then
return nil
elseif e.leaf then
break
end
end
return e,build_url(unpack(t))
end
function process_lua_controller(e)
local t="/usr/lib/lua/luci/controller/"
local a="luci.controller."..e:sub(#t+1,#e-4):gsub("/",".")
local t=require(a)
assert(t~=true,
"Invalid controller file found\n"..
"The file '"..e.."' contains an invalid module line.\n"..
"Please verify whether the module name is set to '"..a..
"' - It must correspond to the file path!")
local e=t.index
if type(e)~="function"then
return nil
end
local o={}
__entries=o
__controller=a
setfenv(e,setmetatable({},{__index=luci.dispatcher}))()
__entries=nil
__controller=nil
for o,e in pairs(o)do
if e.leaf then
e.wildcard=true
end
if type(e.file_depends)=="table"then
for a,t in ipairs(e.file_depends)do
e.depends=e.depends or{}
e.depends.fs=e.depends.fs or{}
local a=fs.stat(t,"type")
if a=="dir"then
e.depends.fs[t]="directory"
elseif t:match("/s?bin/")then
e.depends.fs[t]="executable"
else
e.depends.fs[t]="file"
end
end
end
if type(e.uci_depends)=="table"then
for t,a in pairs(e.uci_depends)do
e.depends=e.depends or{}
e.depends.uci=e.depends.uci or{}
e.depends.uci[t]=a
end
end
if type(e.acl_depends)=="table"then
for a,t in ipairs(e.acl_depends)do
e.depends=e.depends or{}
e.depends.acl=e.depends.acl or{}
e.depends.acl[#e.depends.acl+1]=t
end
end
if(e.sysauth_authenticator~=nil)or
(e.sysauth~=nil and e.sysauth~=false)
then
if e.sysauth_authenticator=="htmlauth"then
e.auth={
login=true,
methods={"cookie:sysauth_https","cookie:sysauth_http"}
}
elseif o=="rpc"and a=="luci.controller.rpc"then
e.auth={
login=false,
methods={"query:auth","cookie:sysauth_https","cookie:sysauth_http","cookie:sysauth"}
}
elseif a=="luci.controller.admin.uci"then
e.auth={
login=false,
methods={"param:sid"}
}
end
elseif e.sysauth==false then
e.auth={}
end
if e.action==nil and type(e.target)=="table"then
e.action=e.target
e.target=nil
end
e.leaf=nil
e.file_depends=nil
e.uci_depends=nil
e.acl_depends=nil
e.sysauth=nil
e.sysauth_authenticator=nil
end
return o
end
function invoke_cbi_action(n,e,...)
local s=require"luci.cbi"
local t=require"luci.template"
local o=require"luci.util"
if not e then
e={}
end
local i=s.load(n,...)
local t=nil
local function d(t,e)
local e=o.ubus("session","access",{
ubus_rpc_session=context.authsession,
scope="uci",object=t,
["function"]=e
})
return(type(e)=="table"and e.access==true)or false
end
local h,h
for i,a in ipairs(i)do
if o.instanceof(a,s.SimpleForm)then
io.stderr:write("Model %s returns SimpleForm but is dispatched via cbi(),\n"
%n)
io.stderr:write("please change %s to use the form() action instead.\n"
%table.concat(context.request,"/"))
end
a.flow=e
local e=a:parse()
if e and(not t or e<t)then
t=e
end
end
local function o(e)
return type(e)=="table"and build_url(unpack(e))or e
end
if e.on_valid_to and t and t>0 and t<2 then
a:redirect(o(e.on_valid_to))
return
end
if e.on_changed_to and t and t>1 then
a:redirect(o(e.on_changed_to))
return
end
if e.on_success_to and t and t>0 then
a:redirect(o(e.on_success_to))
return
end
if e.state_handler then
if not e.state_handler(t,i)then
return
end
end
a:header("X-CBI-State",t or 0)
if not e.noheader then
_G.L.include("cbi/header",{state=t})
end
local o
local a
local r=false
local s=true
local n={}
local h=false
for t,e in ipairs(i)do
if e.apply_needed and e.parsechain then
local t
for t,e in ipairs(e.parsechain)do
n[#n+1]=e
end
r=true
end
if e.redirect then
o=o or e.redirect
end
if e.pageaction==false then
s=false
end
if e.message then
a=a or{}
a[#a+1]=e.message
end
end
for r,e in ipairs(i)do
local i=d(e.config,"read")
local t=d(e.config,"write")
h=h or t
e:render({
firstmap=(r==1),
redirect=o,
messages=a,
pageaction=s,
parsechain=n,
readable=i,
writable=t
})
end
if not e.nofooter then
_G.L.include("cbi/footer",{
flow=e,
pageaction=s,
redirect=o,
state=t,
autoapply=e.autoapply,
trigger_apply=r,
writable=h
})
end
end
function invoke_form_action(e,...)
local t=require"luci.cbi"
local t=require"luci.template"
local o=luci.cbi.load(e,...)
local e=nil
local t,t
for o,t in ipairs(o)do
local t=t:parse()
if t and(not e or t<e)then
e=t
end
end
a:header("X-CBI-State",e or 0)
_G.L.include("header")
for t,e in ipairs(o)do
e:render()
end
_G.L.include("footer")
end
function render_lua_template(t)
local e=require"luci.template"
e.render(t,getfenv(1))
end
function test_post_security()
if a:getenv("REQUEST_METHOD")~="POST"then
a:status(405,"Method Not Allowed")
a:header("Allow","POST")
return false
end
if a:formvalue("token")~=context.authtoken then
a:status(403,"Forbidden")
_G.L.include("csrftoken")
return false
end
return true
end
function call(e,...)
return{
["type"]="call",
["module"]=__controller,
["function"]=e,
["parameters"]=select('#',...)>0 and{...}or nil
}
end
function post_on(t,e,...)
return{
["type"]="call",
["module"]=__controller,
["function"]=e,
["parameters"]=select('#',...)>0 and{...}or nil,
["post"]=t
}
end
function post(...)
return post_on(true,...)
end
function view(e)
return{
["type"]="view",
["path"]=e
}
end
function template(e)
return{
["type"]="template",
["path"]=e
}
end
function cbi(e,t)
return{
["type"]="call",
["module"]="luci.dispatcher",
["function"]="invoke_cbi_action",
["parameters"]={e,t or{}},
["post"]={
["cbi.submit"]=true
}
}
end
function form(e)
return{
["type"]="call",
["module"]="luci.dispatcher",
["function"]="invoke_form_action",
["parameters"]={e},
["post"]={
["cbi.submit"]=true
}
}
end
function firstchild()
return{
["type"]="firstchild"
}
end
function firstnode()
return{
["type"]="firstchild",
["recurse"]=true
}
end
function arcombine(e,t)
return{
["type"]="arcombine",
["targets"]={e,t}
}
end
function alias(...)
return{
["type"]="alias",
["path"]=table.concat({...},"/")
}
end
function rewrite(e,...)
return{
["type"]="rewrite",
["path"]=table.concat({...},"/"),
["remove"]=e
}
end
translate=i18n.translate
function _(e)
return e
end
