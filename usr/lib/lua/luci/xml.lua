local e=require"luci.template.parser"
local o=require"string"
local a=tostring
module"luci.xml"
function pcdata(t)
return t and e.pcdata(a(t))
end
function striptags(t)
return t and e.striptags(a(t))
end
o.pcdata=pcdata
o.striptags=striptags
