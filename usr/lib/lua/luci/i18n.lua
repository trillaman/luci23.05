local e=require"luci.template.parser"
local t=require"luci.util"
local i=tostring
module"luci.i18n"
i18ndir=t.libpath().."/i18n/"
context=t.threadlocal()
default="en"
function setlanguage(o)
local a,t=o:match("^([A-Za-z][A-Za-z])[%-_]([A-Za-z][A-Za-z])$")
if not(a and t)then
t=o:match("^([A-Za-z][A-Za-z])$")
if not t then
return nil
end
end
context.parent=a and a:lower()
context.lang=context.parent and context.parent.."-"..t:lower()or t:lower()
if e.load_catalog(context.lang,i18ndir)and
e.change_catalog(context.lang)
then
return context.lang
elseif context.parent then
if e.load_catalog(context.parent,i18ndir)and
e.change_catalog(context.parent)
then
return context.parent
end
end
return nil
end
function translate(t)
return e.translate(t)or t
end
function translatef(e,...)
return i(translate(e)):format(...)
end
function dump()
local t={}
e.get_translations(function(e,a)t[e]=a end)
return t
end
