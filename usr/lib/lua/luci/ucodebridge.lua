local a,s,h,i,e=coroutine,assert,error,type,require
local n=e"luci.template"
local t=e"luci.util"
local t=e"luci.http"
local t=e"luci.sys"
local t=e"luci.ltn12"
module"luci.ucodebridge"
local function t(e,...)
local t=a.create(e)
local o,e
while a.status(t)~="dead"do
o,e=a.resume(t,...)
if not o then
h(e)
end
end
return e
end
function compile(a)
t(function(e)
return n.Template(e)
end,a)
end
function render(e,a)
t(n.render,e,a)
end
function call(a,o,...)
return t(function(o,t,...)
local e=e(a)
local e=e[t]
s(e~=nil,
'Cannot resolve function "'..t..'". Is it misspelled or local?')
s(i(e)=="function",
'The symbol "'..t..'" does not refer to a function but data '..
'of type "'..i(e)..'".')
return e(...)
end,a,o,...)
end
