local u=require"io"
local m=require"os"
local y=require"table"
local e=require"nixio"
local s=require"nixio.fs"
local i=require"luci.model.uci"
local t={}
t.util=require"luci.util"
t.ip=require"luci.ip"
local w,p,v,q,f,a,a,k,c,j=
tonumber,ipairs,pairs,pcall,type,next,setmetatable,require,select,unpack
module"luci.sys"
function call(...)
return m.execute(...)/256
end
exec=t.util.exec
getenv=e.getenv
function hostname(t)
if f(t)=="string"and#t>0 then
s.writefile("/proc/sys/kernel/hostname",t)
return t
else
return e.uname().nodename
end
end
function httpget(e,o,a)
if not a then
local a=o and u.popen or t.util.exec
return a("wget -qO- %s"%t.util.shellquote(e))
else
return m.execute("wget -qO %s %s"%
{t.util.shellquote(a),t.util.shellquote(e)})
end
end
function reboot()
return m.execute("reboot >/dev/null 2>&1")
end
function syslog()
return t.util.exec("logread")
end
function dmesg()
return t.util.exec("dmesg")
end
function uniqueid(t)
local t=s.readfile("/dev/urandom",t)
return t and e.bin.hexlify(t)
end
function uptime()
return e.sysinfo().uptime
end
net={}
local function r(n,b)
local g,h,h,a,r,o,y,w
local m=i.cursor()
local l={}
local i={}
local d={}
local function h(e,...)
local e=c(e,...)
if e then
if not i[e]then i[e]={}end
i[e][1]=c(1,...)or i[e][1]
i[e][2]=c(2,...)or i[e][2]
i[e][3]=c(3,...)or i[e][3]
i[e][4]=c(4,...)or i[e][4]
end
end
t.ip.neighbors(nil,function(e)
if e.mac and e.family==4 then
h(n,e.mac:string(),e.dest:string(),nil,nil)
elseif e.mac and e.family==6 then
h(n,e.mac:string(),nil,e.dest:string(),nil)
end
end)
if s.access("/etc/ethers")then
for e in u.lines("/etc/ethers")do
a,o=e:match("^([a-fA-F0-9:-]+)%s+(%S+)")
a=t.ip.checkmac(a)
if a and o then
if t.ip.checkip4(o)then
h(n,a,o,nil,nil)
else
h(n,a,nil,nil,o)
end
end
end
end
m:foreach("dhcp","dnsmasq",
function(e)
if e.leasefile and s.access(e.leasefile)then
for e in u.lines(e.leasefile)do
a,r,o=e:match("^%d+ (%S+) (%S+) (%S+)")
a=t.ip.checkmac(a)
if a and r then
h(n,a,r,nil,o~="*"and o)
end
end
end
end
)
m:foreach("dhcp","odhcpd",
function(e)
if f(e.leasefile)=="string"and s.access(e.leasefile)then
for e in u.lines(e.leasefile)do
y,w,o,g,r=e:match("^# %S+ (%S+) (%S+) (%S+) (-?%d+) %S+ %S+ ([0-9a-f:.]+)/[0-9]+")
a=net.duid_to_mac(y)
if a then
if r and w=="ipv4"then
h(n,a,r,nil,o~="*"and o)
elseif r then
h(n,a,nil,r,o~="*"and o)
end
end
end
end
end
)
m:foreach("dhcp","host",
function(a)
for e in t.util.imatch(a.mac)do
e=t.ip.checkmac(e)
if e then
h(n,e,a.ip,nil,a.name)
end
end
end)
for t,e in p(e.getifaddrs())do
if e.name~="lo"then
l[e.name]=l[e.name]or{}
if e.family=="packet"and e.addr and#e.addr==17 then
l[e.name][1]=e.addr:upper()
elseif e.family=="inet"then
l[e.name][2]=e.addr
elseif e.family=="inet6"then
l[e.name][3]=e.addr
end
end
end
for t,e in v(l)do
if e[n]and(e[2]or e[3])then
h(n,e[1],e[2],e[3],e[4])
end
end
for t,e in v(i)do
d[#d+1]=(n>1)and e[n]or(e[2]or e[3])
end
if#d>0 then
d=t.util.ubus("network.rrdns","lookup",{
addrs=d,
timeout=250,
limit=1000
})or{}
end
for t,e in t.util.kspairs(i)do
b(e[1],e[2],e[3],d[e[2]]or d[e[3]]or e[4])
end
end
function net.mac_hints(t)
if t then
r(1,function(o,a,i,e)
e=e or a
if e and e~=o then
t(o,e or a)
end
end)
else
local t={}
r(1,function(o,a,i,e)
e=e or a
if e and e~=o then
t[#t+1]={o,e or a}
end
end)
return t
end
end
function net.ipv4_hints(t)
if t then
r(2,function(o,a,i,e)
e=e or o
if e and e~=a then
t(a,e)
end
end)
else
local t={}
r(2,function(o,a,i,e)
e=e or o
if e and e~=a then
t[#t+1]={a,e}
end
end)
return t
end
end
function net.ipv6_hints(t)
if t then
r(3,function(o,i,a,e)
e=e or o
if e and e~=a then
t(a,e)
end
end)
else
local t={}
r(3,function(o,i,a,e)
e=e or o
if e and e~=a then
t[#t+1]={a,e}
end
end)
return t
end
end
function net.host_hints(o)
if o then
r(1,function(e,t,i,a)
if e and e~="00:00:00:00:00:00"and(t or i or a)then
o(e,t,i,a)
end
end)
else
local n={}
r(1,function(o,i,t,a)
if o and o~="00:00:00:00:00:00"and(i or t or a)then
local e={}
if i then e.ipv4=i end
if t then e.ipv6=t end
if a then e.name=a end
n[o]=e
end
end)
return n
end
end
function net.conntrack(i)
local o,a=q(u.lines,"/proc/net/nf_conntrack")
if not o or not a then
return nil
end
local o,n=nil,(not i)and{}
for a in a do
local h,r,a,s=
a:match("^(ipv[46]) +(%d+) +%S+ +(%d+) +(.+)$")
local d,o=s:match("^(%d+) +(.+)$")
if not o then
o=s
end
if h and r and a and not o:match("^TIME_WAIT ")then
a=e.getprotobynumber(a)
local a={
bytes=0,
packets=0,
layer3=h,
layer4=a and a.name or"unknown",
timeout=w(d,10)
}
local e,e
for e,o in o:gmatch("(%w+)=(%S+)")do
if e=="bytes"or e=="packets"then
a[e]=a[e]+w(o,10)
elseif e=="src"or e=="dst"then
if a[e]==nil then
a[e]=t.ip.new(o):string()
end
elseif e=="sport"or e=="dport"then
if a[e]==nil then
a[e]=o
end
elseif o then
a[e]=o
end
end
if i then
i(a)
else
n[#n+1]=a
end
end
end
return i and true or n
end
function net.devices()
local t={}
local a={}
for o,e in p(e.getifaddrs())do
if e.name and not a[e.name]then
a[e.name]=true
t[#t+1]=e.name
end
end
return t
end
function net.duid_to_mac(e)
local a,o,n,i,h,s
if f(e)=="string"then
if#e==28 then
a,o,n,i,h,s=e:match("^00010001(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)%x%x%x%x%x%x%x%x$")
elseif#e==20 then
a,o,n,i,h,s=e:match("^00030001(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)$")
elseif#e==12 then
a,o,n,i,h,s=e:match("^(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)$")
end
end
return a and t.ip.checkmac(y.concat({a,o,n,i,h,s},":"))
end
process={}
function process.info(t)
local e={uid=e.getuid(),gid=e.getgid()}
return not t and e or e[t]
end
function process.list()
local o={}
local e
local e=t.util.execi("/bin/busybox top -bn1")
if not e then
return
end
for e in e do
local a,i,h,s,r,n,d,t=e:match(
"^ *(%d+) +(%d+) +(%S.-%S) +([RSDZTW][<NW ][<N ]) +(%d+m?) +(%d+%%) +(%d+%%) +(.+)"
)
local e=w(a)
if e and not t:match("top %-bn1")then
o[e]={
['PID']=a,
['PPID']=i,
['USER']=h,
['STAT']=s,
['VSZ']=r,
['%MEM']=n,
['%CPU']=d,
['COMMAND']=t
}
end
end
return o
end
function process.setgroup(t)
return e.setgid(t)
end
function process.setuser(t)
return e.setuid(t)
end
process.signal=e.kill
local function a(e)
if e and e:fileno()>2 then
e:close()
end
end
function process.exec(l,h,r,c)
local s,o,n,i
if h then s,o=e.pipe()end
if r then n,i=e.pipe()end
local d=e.fork()
if d==0 then
e.chdir("/")
local t=e.open("/dev/null","w+")
if t then
e.dup(o or t,e.stdout)
e.dup(i or t,e.stderr)
e.dup(t,e.stdin)
a(o)
a(s)
a(i)
a(n)
a(t)
end
e.exec(j(l))
m.exit(-1)
end
local u,t,l=nil,{},{code=-1,pid=d}
a(o)
a(i)
if s then
t[#t+1]={
fd=s,
cb=f(h)=="function"and h,
name="stdout",
events=e.poll_flags("in","err","hup")
}
end
if n then
t[#t+1]={
fd=n,
cb=f(r)=="function"and r,
name="stderr",
events=e.poll_flags("in","err","hup")
}
end
while#t>0 do
local a,o=e.poll(t,-1)
if not a and o~=e.const.EINTR then
break
end
local e
for o=#t,1,-1 do
local e=t[o]
if e.revents>0 then
local a,i=e.fd:read(4096)
if a and#a>0 then
if e.cb then
e.cb(a)
else
e.buf=e.buf or{}
e.buf[#e.buf+1]=a
end
else
y.remove(t,o)
if e.buf then
l[e.name]=y.concat(e.buf,"")
end
e.fd:close()
end
end
end
end
if not c then
u,u,l.code=e.waitpid(d)
end
return l
end
user={}
user.getuser=e.getpw
function user.getpasswd(t)
local e=e.getsp and e.getsp(t)or e.getpw(t)
local t=e and(e.pwdp or e.passwd)
if not t or#t<1 then
return nil,e
else
return t,e
end
end
function user.checkpasswd(t,a)
local t,o=user.getpasswd(t)
if o then
return(t==nil or e.crypt(a,t)==t)
end
return false
end
function user.setpasswd(a,e)
return m.execute("(echo %s; sleep 1; echo %s) | passwd %s >/dev/null 2>&1"%{
t.util.shellquote(e),
t.util.shellquote(e),
t.util.shellquote(a)
})
end
wifi={}
function wifi.getiwinfo(t)
local e=k"luci.model.network"
e.init()
local a=e:get_wifinet(t)
if a and a.iwinfo then
return a.iwinfo
end
local e=e:get_wifidev(t)
if e and e.iwinfo then
return e.iwinfo
end
return{ifname=t}
end
init={}
init.dir="/etc/init.d/"
function init.names()
local e={}
for t in s.glob(init.dir.."*")do
e[#e+1]=s.basename(t)
end
return e
end
function init.index(e)
e=s.basename(e)
if s.access(init.dir..e)then
return call("env -i sh -c 'source %s%s enabled; exit ${START:-255}' >/dev/null"
%{init.dir,e})
end
end
local function e(t,e)
e=s.basename(e)
if s.access(init.dir..e)then
return call("env -i %s%s %s >/dev/null"%{init.dir,e,t})
end
end
function init.enabled(t)
return(e("enabled",t)==0)
end
function init.enable(t)
return(e("enable",t)==0)
end
function init.disable(t)
return(e("disable",t)==0)
end
function init.start(t)
return(e("start",t)==0)
end
function init.stop(t)
return(e("stop",t)==0)
end
function init.restart(t)
return(e("restart",t)==0)
end
function init.reload(t)
return(e("reload",t)==0)
end
