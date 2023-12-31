module("luci.cbi",package.seeall)
require("luci.template")
local h=require("luci.util")
require("luci.http")
local o=require("nixio.fs")
local l=require("luci.model.uci")
local d=require("luci.cbi.datatypes")
local r=require("luci.dispatcher")
local t=h.class
local i=h.instanceof
FORM_NODATA=0
FORM_PROCEED=0
FORM_VALID=1
FORM_DONE=1
FORM_INVALID=-1
FORM_CHANGED=2
FORM_SKIP=4
AUTO=true
CREATE_PREFIX="cbi.cts."
REMOVE_PREFIX="cbi.rts."
RESORT_PREFIX="cbi.sts."
FEXIST_PREFIX="cbi.cbe."
function load(t,...)
local s=require"nixio.fs"
local n=require"luci.i18n"
require("luci.config")
require("luci.util")
local h="/etc/luci-uploads/"
local o=luci.util.libpath().."/model/cbi/"
local e,a
if s.access(o..t..".lua")then
e,a=loadfile(o..t..".lua")
elseif s.access(t)then
e,a=loadfile(t)
else
e,a=nil,"Model '"..t.."' not found!"
end
assert(e,a)
local t={
translate=n.translate,
translatef=n.translatef,
arg={...}
}
setfenv(e,setmetatable(t,{__index=
function(t,e)
return rawget(t,e)or _M[e]or _G[e]
end}))
local s={e()}
local n={}
local t=false
for a,e in ipairs(s)do
if not i(e,Node)then
error("CBI map returns no valid map object!")
return nil
else
e:prepare()
if e.upload_fields then
t=true
for t,e in ipairs(e.upload_fields)do
n[
e.config..'.'..
(e.section.sectiontype or'1')..'.'..
e.option
]=true
end
end
end
end
if t then
local u=luci.model.uci.cursor()
local d=luci.http.context.request.message.params
local e,a
luci.http.setfilehandler(
function(t,l,r)
if not t then return end
if t.name and not a then
local i,o,s=t.name:gmatch(
"cbid%.([^%.]+)%.([^%.]+)%.([^%.]+)"
)()
if i and o and s then
local o=u:get(i,o)or o
if n[i.."."..o.."."..s]then
local o=h..t.name
e=io.open(o,"w")
if e then
a=t.name
d[a]=o
end
end
end
end
if t.name==a and e then
e:write(l)
end
if r and e then
e:close()
e=nil
a=nil
end
end
)
end
return s
end
local s={}
function compile_datatype(s)
local e
local n=0
local t=false
local o=0
local e={}
for a=1,#s+1 do
local i=s:byte(a)or 44
if t then
t=false
elseif i==92 then
t=true
elseif i==40 or i==44 then
if o<=0 then
if n<a then
local t=s:sub(n,a-1)
:gsub("\\(.)","%1")
:gsub("^%s+","")
:gsub("%s+$","")
if#t>0 and tonumber(t)then
e[#e+1]=tonumber(t)
elseif t:match("^'.*'$")or t:match('^".*"$')then
e[#e+1]=t:gsub("[\"'](.*)[\"']","%1")
elseif type(d[t])=="function"then
e[#e+1]=d[t]
e[#e+1]={}
else
error("Datatype error, bad token %q"%t)
end
end
n=a+1
end
o=o+(i==40 and 1 or 0)
elseif i==41 then
o=o-1
if o<=0 then
if type(e[#e-1])~="function"then
error("Datatype error, argument list follows non-function")
end
e[#e]=compile_datatype(s:sub(n,a-1))
n=a+1
end
end
end
return e
end
function verify_datatype(e,a)
if e and#e>0 then
if not s[e]then
local t=compile_datatype(e)
if t and type(t[1])=="function"then
s[e]=t
else
error("Datatype error, not a function expression")
end
end
if s[e]then
return s[e][1](a,unpack(s[e][2]))
end
end
return true
end
Node=t()
function Node.__init__(e,a,t)
e.children={}
e.title=a or""
e.description=t or""
e.template="cbi/node"
end
function Node._run_hook(e,t)
if type(e[t])=="function"then
return e[t](e)
end
end
function Node._run_hooks(e,...)
local t
local t=false
for o,a in ipairs(arg)do
if type(e[a])=="function"then
e[a](e)
t=true
end
end
return t
end
function Node.prepare(e,...)
for t,e in ipairs(e.children)do
e:prepare(...)
end
end
function Node.append(t,e)
table.insert(t.children,e)
end
function Node.parse(e,...)
for t,e in ipairs(e.children)do
e:parse(...)
end
end
function Node.render(t,e)
e=e or{}
e.self=t
luci.template.render(t.template,e)
end
function Node.render_children(a,...)
local e,e
for t,e in ipairs(a.children)do
e.last_child=(t==#a.children)
e.index=t
e:render(...)
end
end
Template=t(Node)
function Template.__init__(e,t)
Node.__init__(e)
e.template=t
end
function Template.render(e)
luci.template.render(e.template,{self=e})
end
function Template.parse(e,t)
e.readinput=(t~=false)
return Map.formvalue(e,"cbi.submit")and FORM_DONE or FORM_NODATA
end
Map=t(Node)
function Map.__init__(e,t,...)
Node.__init__(e,...)
e.config=t
e.parsechain={e.config}
e.template="cbi/map"
e.apply_on_parse=nil
e.readinput=true
e.proceed=false
e.flow={}
e.uci=l.cursor()
e.save=true
e.changed=false
local t="%s/%s"%{e.uci:get_confdir(),e.config}
if o.stat(t,"type")~="reg"then
o.writefile(t,"")
end
local a,n=e.uci:load(e.config)
if not a then
local s=r.build_url(unpack(r.context.request))
local i=e:formvalue("cbi.source")
if type(i)=="string"then
o.writefile(t,i:gsub("\r\n","\n"))
a,n=e.uci:load(e.config)
if a then
luci.http.redirect(s)
end
end
e.save=false
end
if not a then
e.template="cbi/error"
e.error=n
e.source=o.readfile(t)or""
e.pageaction=false
end
end
function Map.formvalue(e,t)
return e.readinput and luci.http.formvalue(t)or nil
end
function Map.formvaluetable(t,e)
return t.readinput and luci.http.formvaluetable(e)or{}
end
function Map.get_scheme(e,t,a)
if not a then
return e.scheme and e.scheme.sections[t]
else
return e.scheme and e.scheme.variables[t]
and e.scheme.variables[t][a]
end
end
function Map.submitstate(e)
return e:formvalue("cbi.submit")
end
function Map.chain(e,t)
table.insert(e.parsechain,t)
end
function Map.state_handler(t,e)
return e
end
function Map.parse(e,t,...)
if e:formvalue("cbi.skip")then
e.state=FORM_SKIP
elseif not e.save then
e.state=FORM_INVALID
elseif not e:submitstate()then
e.state=FORM_NODATA
end
if e.state~=nil then
return e:state_handler(e.state)
end
e.readinput=(t~=false)
e:_run_hooks("on_parse")
Node.parse(e,...)
if e.save then
e:_run_hooks("on_save","on_before_save")
local t,t
for a,t in ipairs(e.parsechain)do
e.uci:save(t)
end
e:_run_hooks("on_after_save")
if(not e.proceed and e.flow.autoapply)or luci.http.formvalue("cbi.apply")then
e:_run_hooks("on_before_commit")
if e.apply_on_parse==false then
for a,t in ipairs(e.parsechain)do
e.uci:commit(t)
end
end
e:_run_hooks("on_commit","on_after_commit","on_before_apply")
if e.apply_on_parse==true or e.apply_on_parse==false then
e.uci:apply(e.apply_on_parse)
e:_run_hooks("on_apply","on_after_apply")
else
e.apply_needed=true
end
Node.parse(e,true)
end
for a,t in ipairs(e.parsechain)do
e.uci:unload(t)
end
if type(e.commit_handler)=="function"then
e:commit_handler(e:submitstate())
end
end
if not e.save then
e.state=FORM_INVALID
elseif e.proceed then
e.state=FORM_PROCEED
elseif e.changed then
e.state=FORM_CHANGED
else
e.state=FORM_VALID
end
return e:state_handler(e.state)
end
function Map.render(e,...)
e:_run_hooks("on_init")
Node.render(e,...)
end
function Map.section(t,e,...)
if i(e,AbstractSection)then
local e=e(t,...)
t:append(e)
return e
else
error("class must be a descendent of AbstractSection")
end
end
function Map.add(e,t)
return e.uci:add(e.config,t)
end
function Map.set(e,o,a,t)
if type(t)~="table"or#t>0 then
if a then
return e.uci:set(e.config,o,a,t)
else
return e.uci:set(e.config,o,t)
end
else
return Map.del(e,o,a)
end
end
function Map.del(e,t,a)
if a then
return e.uci:delete(e.config,t,a)
else
return e.uci:delete(e.config,t)
end
end
function Map.get(e,t,a)
if not t then
return e.uci:get_all(e.config)
elseif a then
return e.uci:get(e.config,t,a)
else
return e.uci:get_all(e.config,t)
end
end
Compound=t(Node)
function Compound.__init__(e,...)
Node.__init__(e)
e.template="cbi/compound"
e.children={...}
end
function Compound.populate_delegator(e,t)
for a,e in ipairs(e.children)do
e.delegator=t
end
end
function Compound.parse(a,...)
local t,e=0
for o,a in ipairs(a.children)do
t=a:parse(...)
e=(not e or t<e)and t or e
end
return e
end
Delegator=t(Node)
function Delegator.__init__(e,...)
Node.__init__(e,...)
e.nodes={}
e.defaultpath={}
e.pageaction=false
e.readinput=true
e.allow_reset=false
e.allow_cancel=false
e.allow_back=false
e.allow_finish=false
e.template="cbi/delegator"
end
function Delegator.set(e,t,a)
assert(not e.nodes[t],"Duplicate entry")
e.nodes[t]=a
end
function Delegator.add(e,t,a)
a=e:set(t,a)
e.defaultpath[#e.defaultpath+1]=t
end
function Delegator.insert_after(e,i,a)
local t=#e.chain+1
for e,o in ipairs(e.chain)do
if o==a then
t=e+1
break
end
end
table.insert(e.chain,t,i)
end
function Delegator.set_route(o,...)
local e,t,a=0,o.chain,{...}
for a=1,#t do
if t[a]==o.current then
e=a
break
end
end
for o=1,#a do
e=e+1
t[e]=a[o]
end
for e=e+1,#t do
t[e]=nil
end
end
function Delegator.get(e,t)
local e=e.nodes[t]
if type(e)=="string"then
e=load(e,t)
end
if type(e)=="table"and getmetatable(e)==nil then
e=Compound(unpack(e))
end
return e
end
function Delegator.parse(e,...)
if e.allow_cancel and Map.formvalue(e,"cbi.cancel")then
if e:_run_hooks("on_cancel")then
return FORM_DONE
end
end
if not Map.formvalue(e,"cbi.delg.current")then
e:_run_hooks("on_init")
end
local t
e.chain=e.chain or e:get_chain()
e.current=e.current or e:get_active()
e.active=e.active or e:get(e.current)
assert(e.active,"Invalid state")
local a=FORM_DONE
if type(e.active)~="function"then
e.active:populate_delegator(e)
a=e.active:parse()
else
e:active()
end
if a>FORM_PROCEED then
if Map.formvalue(e,"cbi.delg.back")then
t=e:get_prev(e.current)
else
t=e:get_next(e.current)
end
elseif a<FORM_PROCEED then
return a
end
if not Map.formvalue(e,"cbi.submit")then
return FORM_NODATA
elseif a>FORM_PROCEED
and(not t or not e:get(t))then
return e:_run_hook("on_done")or FORM_DONE
else
e.current=t or e.current
e.active=e:get(e.current)
if type(e.active)~="function"then
e.active:populate_delegator(e)
local t=e.active:parse(false)
if t==FORM_SKIP then
return e:parse(...)
else
return FORM_PROCEED
end
else
return e:parse(...)
end
end
end
function Delegator.get_next(e,o)
for a,t in ipairs(e.chain)do
if t==o then
return e.chain[a+1]
end
end
end
function Delegator.get_prev(e,t)
for a,o in ipairs(e.chain)do
if o==t then
return e.chain[a-1]
end
end
end
function Delegator.get_chain(e)
local e=Map.formvalue(e,"cbi.delg.path")or e.defaultpath
return type(e)=="table"and e or{e}
end
function Delegator.get_active(e)
return Map.formvalue(e,"cbi.delg.current")or e.chain[1]
end
Page=t(Node)
Page.__init__=Node.__init__
Page.parse=function()end
SimpleForm=t(Node)
function SimpleForm.__init__(e,i,o,a,t)
Node.__init__(e,o,a)
e.config=i
e.data=t or{}
e.template="cbi/simpleform"
e.dorender=true
e.pageaction=false
e.readinput=true
end
SimpleForm.formvalue=Map.formvalue
SimpleForm.formvaluetable=Map.formvaluetable
function SimpleForm.parse(e,t,...)
e.readinput=(t~=false)
if e:formvalue("cbi.skip")then
return FORM_SKIP
end
if e:formvalue("cbi.cancel")and e:_run_hooks("on_cancel")then
return FORM_DONE
end
if e:submitstate()then
Node.parse(e,1,...)
end
local t=true
for a,e in ipairs(e.children)do
for a,e in ipairs(e.children)do
t=t
and(not e.tag_missing or not e.tag_missing[1])
and(not e.tag_invalid or not e.tag_invalid[1])
and(not e.error)
end
end
local t=
not e:submitstate()and FORM_NODATA
or t and FORM_VALID
or FORM_INVALID
e.dorender=not e.handle
if e.handle then
local o,a=e:handle(t,e.data)
e.dorender=e.dorender or(o~=false)
t=a or t
end
return t
end
function SimpleForm.render(e,...)
if e.dorender then
Node.render(e,...)
end
end
function SimpleForm.submitstate(e)
return e:formvalue("cbi.submit")
end
function SimpleForm.section(t,e,...)
if i(e,AbstractSection)then
local e=e(t,...)
t:append(e)
return e
else
error("class must be a descendent of AbstractSection")
end
end
function SimpleForm.field(t,a,...)
local e
for a,t in ipairs(t.children)do
if i(t,SimpleSection)then
e=t
break
end
end
if not e then
e=t:section(SimpleSection)
end
if i(a,AbstractValue)then
local t=a(t,e,...)
t.track_missing=true
e:append(t)
return t
else
error("class must be a descendent of AbstractValue")
end
end
function SimpleForm.set(e,o,a,t)
e.data[a]=t
end
function SimpleForm.del(t,a,e)
t.data[e]=nil
end
function SimpleForm.get(t,a,e)
return t.data[e]
end
function SimpleForm.get_scheme()
return nil
end
Form=t(SimpleForm)
function Form.__init__(e,...)
SimpleForm.__init__(e,...)
e.embedded=true
end
AbstractSection=t(Node)
function AbstractSection.__init__(e,t,a,...)
Node.__init__(e,...)
e.sectiontype=a
e.map=t
e.config=t.config
e.optionals={}
e.defaults={}
e.fields={}
e.tag_error={}
e.tag_invalid={}
e.tag_deperror={}
e.changed=false
e.optional=true
e.addremove=false
e.dynamic=false
end
function AbstractSection.tab(e,t,a,o)
e.tabs=e.tabs or{}
e.tab_names=e.tab_names or{}
e.tab_names[#e.tab_names+1]=t
e.tabs[t]={
title=a,
description=o,
childs={}
}
end
function AbstractSection.has_tabs(e)
return(e.tabs~=nil)and(next(e.tabs)~=nil)
end
function AbstractSection.option(e,a,o,...)
if i(a,AbstractValue)then
local t=a(e.map,e,o,...)
e:append(t)
e.fields[o]=t
return t
elseif a==true then
error("No valid class was given and autodetection failed.")
else
error("class must be a descendant of AbstractValue")
end
end
function AbstractSection.taboption(t,e,...)
assert(e and t.tabs and t.tabs[e],
"Cannot assign option to not existing tab %q"%tostring(e))
local a=t.tabs[e].childs
local e=AbstractSection.option(t,...)
if e then a[#a+1]=e end
return e
end
function AbstractSection.render_tab(t,e,...)
assert(e and t.tabs and t.tabs[e],
"Cannot render not existing tab %q"%tostring(e))
local a,a
for o,a in ipairs(t.tabs[e].childs)do
a.last_child=(o==#t.tabs[e].childs)
a.index=o
a:render(...)
end
end
function AbstractSection.parse_optionals(e,o,a)
if not e.optional then
return
end
e.optionals[o]={}
local t=nil
if not a then
t=e.map:formvalue("cbi.opt."..e.config.."."..o)
end
for i,a in ipairs(e.children)do
if a.optional and not a:cfgvalue(o)and not e:has_tabs()then
if t==a.option then
t=nil
e.map.proceed=true
else
table.insert(e.optionals[o],a)
end
end
end
if t and#t>0 and e.dynamic then
e:add_dynamic(t)
end
end
function AbstractSection.add_dynamic(a,e,t)
local e=a:option(Value,e,e)
e.optional=t
end
function AbstractSection.parse_dynamic(e,t)
if not e.dynamic then
return
end
local a=luci.util.clone(e:cfgvalue(t))
local t=e.map:formvaluetable("cbid."..e.config.."."..t)
for e,t in pairs(t)do
a[e]=t
end
for t,a in pairs(a)do
local a=true
for o,e in ipairs(e.children)do
if e.option==t then
a=false
end
end
if a and t:sub(1,1)~="."then
e.map.proceed=true
e:add_dynamic(t,true)
end
end
end
function AbstractSection.cfgvalue(e,t)
return e.map:get(t)
end
function AbstractSection.push_events(e)
e.map.changed=true
end
function AbstractSection.remove(e,t)
e.map.proceed=true
return e.map:del(t)
end
function AbstractSection.create(e,t)
local a
if t then
a=t:match("^[%w_]+$")and e.map:set(t,nil,e.sectiontype)
else
t=e.map:add(e.sectiontype)
a=t
end
if a then
for o,a in pairs(e.children)do
if a.default then
e.map:set(t,a.option,a.default)
end
end
for o,a in pairs(e.defaults)do
e.map:set(t,o,a)
end
end
e.map.proceed=true
return a
end
SimpleSection=t(AbstractSection)
function SimpleSection.__init__(e,t,...)
AbstractSection.__init__(e,t,nil,...)
e.template="cbi/nullsection"
end
Table=t(AbstractSection)
function Table.__init__(t,e,o,...)
local e={}
local a=t
e.config="table"
t.data=o or{}
e.formvalue=Map.formvalue
e.formvaluetable=Map.formvaluetable
e.readinput=true
function e.get(o,e,t)
return a.data[e]and a.data[e][t]
end
function e.submitstate(e)
return Map.formvalue(e,"cbi.submit")
end
function e.del(...)
return true
end
function e.get_scheme()
return nil
end
AbstractSection.__init__(t,e,"table",...)
t.template="cbi/tblsection"
t.rowcolors=true
t.anonymous=true
end
function Table.parse(e,t)
e.map.readinput=(t~=false)
for a,t in ipairs(e:cfgsections())do
if e.map:submitstate()then
Node.parse(e,t)
end
end
end
function Table.cfgsections(t)
local e={}
for t,a in luci.util.kspairs(t.data)do
table.insert(e,t)
end
return e
end
function Table.update(t,e)
t.data=e
end
NamedSection=t(AbstractSection)
function NamedSection.__init__(e,o,a,t,...)
AbstractSection.__init__(e,o,t,...)
e.addremove=false
e.template="cbi/nsection"
e.section=a
end
function NamedSection.prepare(e)
AbstractSection.prepare(e)
AbstractSection.parse_optionals(e,e.section,true)
end
function NamedSection.parse(e,t)
local t=e.section
local a=e:cfgvalue(t)
if e.addremove then
local o=e.config.."."..t
if a then
if e.map:formvalue("cbi.rns."..o)and e:remove(t)then
e:push_events()
return
end
else
if e.map:formvalue("cbi.cns."..o)then
e:create(t)
return
end
end
end
if a then
AbstractSection.parse_dynamic(e,t)
if e.map:submitstate()then
Node.parse(e,t)
end
AbstractSection.parse_optionals(e,t)
if e.changed then
e:push_events()
end
end
end
TypedSection=t(AbstractSection)
function TypedSection.__init__(e,t,a,...)
AbstractSection.__init__(e,t,a,...)
e.template="cbi/tsection"
e.deps={}
e.anonymous=false
end
function TypedSection.prepare(e)
AbstractSection.prepare(e)
local t,t
for a,t in ipairs(e:cfgsections())do
AbstractSection.parse_optionals(e,t,true)
end
end
function TypedSection.cfgsections(e)
local t={}
e.map.uci:foreach(e.map.config,e.sectiontype,
function(a)
if e:checkscope(a[".name"])then
table.insert(t,a[".name"])
end
end)
return t
end
function TypedSection.depends(a,e,t)
table.insert(a.deps,{option=e,value=t})
end
function TypedSection.parse(e,a)
if e.addremove then
local t=REMOVE_PREFIX..e.config
local t=e.map:formvaluetable(t)
for t,a in pairs(t)do
if t:sub(-2)==".x"then
t=t:sub(1,#t-2)
end
if e:cfgvalue(t)and e:checkscope(t)then
e:remove(t)
end
end
end
local t
for o,t in ipairs(e:cfgsections())do
AbstractSection.parse_dynamic(e,t)
if e.map:submitstate()then
Node.parse(e,t,a)
end
AbstractSection.parse_optionals(e,t)
end
if e.addremove then
local a
local t=CREATE_PREFIX..e.config.."."..e.sectiontype
local o,t=next(e.map:formvaluetable(t))
if e.anonymous then
if t then
a=e:create(nil,o)
end
else
if t then
if e:cfgvalue(t)then
t=nil
e.err_invalid=true
else
t=e:checkscope(t)
if not t then
e.err_invalid=true
end
if t and#t>0 then
a=e:create(t,o)and t
if not a then
e.invalid_cts=true
end
end
end
end
end
if a then
AbstractSection.parse_optionals(e,a)
end
end
if e.sortable then
local t=RESORT_PREFIX..e.config.."."..e.sectiontype
local a=e.map:formvalue(t)
if a and#a>0 then
local t,o={},nil
for e in h.imatch(a)do
t[#t+1]=e
end
if#t>0 then
e.map.uci:reorder(e.config,t)
e.changed=true
end
end
end
if created or e.changed then
e:push_events()
end
end
function TypedSection.checkscope(e,t)
if e.filter and not e:filter(t)then
return nil
end
if#e.deps>0 and e:cfgvalue(t)then
local o=false
for i,a in ipairs(e.deps)do
if e:cfgvalue(t)[a.option]==a.value then
o=true
end
end
if not o then
return nil
end
end
return e:validate(t)
end
function TypedSection.validate(t,e)
return e
end
AbstractValue=t(Node)
function AbstractValue.__init__(e,t,a,o,...)
Node.__init__(e,...)
e.section=a
e.option=o
e.map=t
e.config=t.config
e.tag_invalid={}
e.tag_missing={}
e.tag_reqerror={}
e.tag_error={}
e.deps={}
e.track_missing=false
e.rmempty=true
e.default=nil
e.size=nil
e.optional=false
end
function AbstractValue.prepare(e)
e.cast=e.cast or"string"
end
function AbstractValue.depends(o,t,a)
local e
if type(t)=="string"then
e={}
e[t]=a
else
e=t
end
table.insert(o.deps,e)
end
function AbstractValue.deplist2json(o,n,e)
local a,t,t={}
if type(o.deps)=="table"then
for t,e in ipairs(e or o.deps)do
local t,i,i={}
for e,i in pairs(e)do
if e:find("!",1,true)then
t[e]=i
elseif e:find(".",1,true)then
t['cbid.%s'%e]=i
else
t['cbid.%s.%s.%s'%{o.config,n,e}]=i
end
end
a[#a+1]=t
end
end
return h.serialize_json(a)
end
function AbstractValue.choices(e)
if type(e.keylist)=="table"and#e.keylist>0 then
local t,t,a=nil,nil,{}
for o,t in ipairs(e.keylist)do
a[t]=e.vallist[o]or t
end
return a
end
return nil
end
function AbstractValue.cbid(e,t)
return"cbid."..e.map.config.."."..t.."."..e.option
end
function AbstractValue.formcreated(e,t)
local t="cbi.opt."..e.config.."."..t
return(e.map:formvalue(t)==e.option)
end
function AbstractValue.formvalue(e,t)
return e.map:formvalue(e:cbid(t))
end
function AbstractValue.additional(t,e)
t.optional=e
end
function AbstractValue.mandatory(t,e)
t.rmempty=not e
end
function AbstractValue.add_error(e,t,a,o)
e.error=e.error or{}
e.error[t]=o or a
e.section.error=e.section.error or{}
e.section.error[t]=e.section.error[t]or{}
table.insert(e.section.error[t],o or a)
if a=="invalid"then
e.tag_invalid[t]=true
elseif a=="missing"then
e.tag_missing[t]=true
end
e.tag_error[t]=true
e.map.save=false
end
function AbstractValue.parse(e,a,i)
local t=e:formvalue(a)
local o=e:cfgvalue(a)
if type(t)=="table"and type(o)=="table"then
local e=#t==#o
if e then
for a=1,#t do
if o[a]~=t[a]then
e=false
end
end
end
if e then
t=o
end
end
if t and#t>0 then
local n
t,n=e:validate(t,a)
t=e:transform(t)
if not t and not i then
e:add_error(a,"invalid",n)
end
if e.alias then
e.section.aliased=e.section.aliased or{}
e.section.aliased[a]=e.section.aliased[a]or{}
e.section.aliased[a][e.alias]=true
end
if t and(e.forcewrite or not(t==o))then
if e:write(a,t)then
e.section.changed=true
end
end
else
if e.rmempty or e.optional then
if not e.alias or
not e.section.aliased or
not e.section.aliased[a]or
not e.section.aliased[a][e.alias]
then
if e:remove(a)then
e.section.changed=true
end
end
elseif o~=t and not i then
local o,t=e:validate(nil,a)
e:add_error(a,"missing",t)
end
end
end
function AbstractValue.render(e,a,t)
if not e.optional or e.section:has_tabs()or e:cfgvalue(a)or e:formcreated(a)then
t=t or{}
t.section=a
t.cbid=e:cbid(a)
Node.render(e,t)
end
end
function AbstractValue.cfgvalue(e,a)
local t
if e.tag_error[a]then
t=e:formvalue(a)
else
t=e.map:get(a,e.alias or e.option)
end
if not t then
return nil
elseif not e.cast or e.cast==type(t)then
return t
elseif e.cast=="string"then
if type(t)=="table"then
return t[1]
end
elseif e.cast=="table"then
return{t}
end
end
function AbstractValue.validate(t,e)
if t.datatype and e then
if type(e)=="table"then
local a
for a,e in ipairs(e)do
if e and#e>0 and not verify_datatype(t.datatype,e)then
return nil
end
end
else
if not verify_datatype(t.datatype,e)then
return nil
end
end
end
return e
end
AbstractValue.transform=AbstractValue.validate
function AbstractValue.write(e,a,t)
return e.map:set(a,e.alias or e.option,t)
end
function AbstractValue.remove(e,t)
return e.map:del(t,e.alias or e.option)
end
Value=t(AbstractValue)
function Value.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/value"
e.keylist={}
e.vallist={}
e.readonly=nil
end
function Value.reset_values(e)
e.keylist={}
e.vallist={}
end
function Value.value(t,a,e)
e=e or a
table.insert(t.keylist,tostring(a))
table.insert(t.vallist,tostring(e))
end
function Value.parse(e,a,t)
if e.readonly then return end
AbstractValue.parse(e,a,t)
end
DummyValue=t(AbstractValue)
function DummyValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/dvalue"
e.value=nil
end
function DummyValue.cfgvalue(e,a)
local t
if e.value then
if type(e.value)=="function"then
t=e:value(a)
else
t=e.value
end
else
t=AbstractValue.cfgvalue(e,a)
end
return t
end
function DummyValue.parse(e)
end
Flag=t(AbstractValue)
function Flag.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/fvalue"
e.enabled="1"
e.disabled="0"
e.default=e.disabled
end
function Flag.parse(e,t,n)
local a=e.map:formvalue(
FEXIST_PREFIX..e.config.."."..t.."."..e.option)
if a then
local a=e:formvalue(t)and e.enabled or e.disabled
local i=e:cfgvalue(t)
local o
a,o=e:validate(a,t)
if not a then
if not n then
e:add_error(t,"invalid",o)
end
return
end
if a==e.default and(e.optional or e.rmempty)then
e:remove(t)
else
e:write(t,a)
end
if(a~=i)then e.section.changed=true end
else
e:remove(t)
e.section.changed=true
end
end
function Flag.cfgvalue(e,t)
return AbstractValue.cfgvalue(e,t)or e.default
end
function Flag.validate(t,e)
return e
end
ListValue=t(AbstractValue)
function ListValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/lvalue"
e.size=1
e.widget="select"
e:reset_values()
end
function ListValue.reset_values(e)
e.keylist={}
e.vallist={}
e.deplist={}
end
function ListValue.value(e,a,t,...)
if luci.util.contains(e.keylist,a)then
return
end
t=t or a
table.insert(e.keylist,tostring(a))
table.insert(e.vallist,tostring(t))
table.insert(e.deplist,{...})
end
function ListValue.validate(t,e)
if luci.util.contains(t.keylist,e)then
return e
else
return nil
end
end
MultiValue=t(AbstractValue)
function MultiValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/mvalue"
e.widget="checkbox"
e.delimiter=" "
e:reset_values()
end
function MultiValue.render(e,...)
if e.widget=="select"and not e.size then
e.size=#e.vallist
end
AbstractValue.render(e,...)
end
function MultiValue.reset_values(e)
e.keylist={}
e.vallist={}
e.deplist={}
end
function MultiValue.value(a,t,e)
if luci.util.contains(a.keylist,t)then
return
end
e=e or t
table.insert(a.keylist,tostring(t))
table.insert(a.vallist,tostring(e))
end
function MultiValue.valuelist(e,t)
local t=e:cfgvalue(t)
if not(type(t)=="string")then
return{}
end
return luci.util.split(t,e.delimiter)
end
function MultiValue.validate(a,e)
e=(type(e)=="table")and e or{e}
local t
for o,e in ipairs(e)do
if luci.util.contains(a.keylist,e)then
t=t and(t..a.delimiter..e)or e
end
end
return t
end
StaticList=t(MultiValue)
function StaticList.__init__(e,...)
MultiValue.__init__(e,...)
e.cast="table"
e.valuelist=e.cfgvalue
if not e.override_scheme
and e.map:get_scheme(e.section.sectiontype,e.option)then
local t=e.map:get_scheme(e.section.sectiontype,e.option)
if e.value and t.values and not e.override_values then
for a,t in pairs(t.values)do
e:value(a,t)
end
end
end
end
function StaticList.validate(a,e)
e=(type(e)=="table")and e or{e}
local t={}
for o,e in ipairs(e)do
if luci.util.contains(a.keylist,e)then
table.insert(t,e)
end
end
return t
end
DynamicList=t(AbstractValue)
function DynamicList.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/dynlist"
e.cast="table"
e:reset_values()
end
function DynamicList.reset_values(e)
e.keylist={}
e.vallist={}
end
function DynamicList.value(t,a,e)
e=e or a
table.insert(t.keylist,tostring(a))
table.insert(t.vallist,tostring(e))
end
function DynamicList.write(a,o,e)
local t={}
if type(e)=="table"then
local a
for a,e in ipairs(e)do
if e and#e>0 then
t[#t+1]=e
end
end
else
t={e}
end
if a.cast=="string"then
e=table.concat(t," ")
else
e=t
end
return AbstractValue.write(a,o,e)
end
function DynamicList.cfgvalue(e,t)
local e=AbstractValue.cfgvalue(e,t)
if type(e)=="string"then
local t
local t={}
for a in e:gmatch("%S+")do
if#a>0 then
t[#t+1]=a
end
end
e=t
end
return e
end
function DynamicList.formvalue(t,e)
local e=AbstractValue.formvalue(t,e)
if type(e)=="string"then
if t.cast=="string"then
local t
local t={}
for a in e:gmatch("%S+")do
t[#t+1]=a
end
e=t
else
e={e}
end
end
return e
end
DropDown=t(MultiValue)
function DropDown.__init__(e,...)
ListValue.__init__(e,...)
e.template="cbi/dropdown"
e.delimiter=" "
end
TextValue=t(AbstractValue)
function TextValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/tvalue"
end
Button=t(AbstractValue)
function Button.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/button"
e.inputstyle=nil
e.rmempty=true
e.unsafeupload=false
end
FileUpload=t(AbstractValue)
function FileUpload.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/upload"
if not e.map.upload_fields then
e.map.upload_fields={e}
else
e.map.upload_fields[#e.map.upload_fields+1]=e
end
end
function FileUpload.formcreated(e,t)
if e.unsafeupload then
return AbstractValue.formcreated(e,t)or
e.map:formvalue("cbi.rlf."..t.."."..e.option)or
e.map:formvalue("cbi.rlf."..t.."."..e.option..".x")or
e.map:formvalue("cbid."..e.map.config.."."..t.."."..e.option..".textbox")
else
return AbstractValue.formcreated(e,t)or
e.map:formvalue("cbid."..e.map.config.."."..t.."."..e.option..".textbox")
end
end
function FileUpload.cfgvalue(e,t)
local e=AbstractValue.cfgvalue(e,t)
if e and o.access(e)then
return e
end
return nil
end
function FileUpload.formvalue(e,a)
local t=AbstractValue.formvalue(e,a)
if t then
if e.unsafeupload then
if not e.map:formvalue("cbi.rlf."..a.."."..e.option)and
not e.map:formvalue("cbi.rlf."..a.."."..e.option..".x")
then
return t
end
o.unlink(t)
e.value=nil
return nil
elseif t~=""then
return t
end
end
t=luci.http.formvalue("cbid."..e.map.config.."."..a.."."..e.option..".textbox")
if t==""then
t=nil
end
if not e.unsafeupload then
if not t then
t=e.map:formvalue("cbi.rlf."..a.."."..e.option)
end
end
return t
end
function FileUpload.remove(t,a)
if t.unsafeupload then
local e=AbstractValue.formvalue(t,a)
if e and o.access(e)then o.unlink(e)end
return AbstractValue.remove(t,a)
else
return nil
end
end
FileBrowser=t(AbstractValue)
function FileBrowser.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/browser"
end
