local n=require"luci.util"
local e=require"luci.config"
local u=require"luci.template.parser"
local s,t,t=tostring,pairs,loadstring
local r,t=setmetatable,loadfile
local a,v,f=getfenv,setfenv,rawget
local t,i,m=assert,type,error
local g,p,b=table,string,unpack
local l=_G
local t=l.L
local d=l.L.http
local o=require"luci.dispatcher"
local y=require"luci.i18n"
local h=require"luci.xml"
local w=require"nixio.fs"
module"luci.template"
e.template=e.template or{}
viewdir=e.template.viewdir or n.libpath().."/view"
context={}
function render(t,e)
return Template(t):render(e or a(2))
end
function render_string(e,t)
return Template(nil,e):render(t or a(2))
end
Template=n.class()
Template.cache=r({},{__mode="v"})
local function c(o,t,e,r)
if o then
local a=a(3)
local o=(i(a.self)=="table")and a.self
if i(e)=="table"then
if not next(e)then
return''
else
e=n.serialize_json(e)
end
end
e=s(e or
(i(a[t])~="function"and a[t])or
(o and i(o[t])~="function"and o[t])or"")
if r~=true then
e=h.pcdata(e)
end
return p.format(' %s="%s"',s(t),e)
else
return''
end
end
context.viewns=r({
include=function(e)
if w.access(viewdir.."/"..e..".htm")then
Template(e):render(a(2))
else
t.include(e,a(2))
end
end;
translate=y.translate;
translatef=y.translatef;
export=function(e,t)if context.viewns[e]==nil then context.viewns[e]=t end end;
striptags=h.striptags;
pcdata=h.pcdata;
ifattr=function(...)return c(...)end;
attr=function(...)return c(true,...)end;
url=o.build_url;
},{__index=function(a,e)
if e=="controller"then
return o.build_url()
elseif e=="REQUEST_URI"then
return o.build_url(b(o.context.requestpath))
elseif e=="FULL_REQUEST_URI"then
local e={d:getenv("SCRIPT_NAME")or"",d:getenv("PATH_INFO")}
local t=d:getenv("QUERY_STRING")
if t and#t>0 then
e[#e+1]="?"
e[#e+1]=t
end
return g.concat(e,"")
elseif e=="token"then
return o.context.authtoken
elseif e=="theme"then
return t.media and w.basename(t.media)or s(t)
elseif e=="resource"then
return t.config.main.resourcebase
else
return f(a,e)or l[e]or t[e]
end
end})
function Template.__init__(e,t,i)
if t then
e.template=e.cache[t]
e.name=t
else
e.name="[string]"
end
e.viewns=context.viewns
if not e.template then
local o
local a
if t then
a=viewdir.."/"..t..".htm"
e.template,_,o=u.parse(a)
else
a="[string]"
e.template,_,o=u.parse_string(i)
end
if not e.template then
m("Failed to load template '"..e.name.."'.\n"..
"Error while parsing template '"..a.."':\n"..
(o or"Unknown syntax error"))
elseif t then
e.cache[t]=e.template
end
end
end
function Template.render(e,t)
t=t or a(2)
v(e.template,r({},{__index=
function(o,a)
return f(o,a)or e.viewns[a]or t[a]
end}))
local a,t=n.copcall(e.template)
if not a then
m("Failed to execute template '"..e.name.."'.\n"..
"A runtime error occurred: "..s(t or"(nil)"))
end
end
