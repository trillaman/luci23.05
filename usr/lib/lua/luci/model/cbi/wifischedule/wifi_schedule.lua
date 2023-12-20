local t=require"nixio.fs"
local e=require"luci.sys"
local a=require("luci.model.uci").cursor()
function time_validator(a,e,t)
if e~=nil then
h_str,m_str=string.match(e,"^(%d%d?):(%d%d?)$")
h=tonumber(h_str)
m=tonumber(m_str)
if(h~=nil and
h>=0 and
h<=23 and
m~=nil and
m>=0 and
m<=59)then
return e
end
end
return nil,translatef("The value %s is invalid",t)
end
m=Map("wifi_schedule",translate("Wifi Schedule"),translate("Defines a schedule when to turn on and off wifi."))
m.apply_on_parse=true
function m.on_apply(t)
e.exec("/usr/bin/wifi_schedule.sh cron")
end
global_section=m:section(TypedSection,"global",translate("Global Settings"))
global_section.optional=false
global_section.rmempty=false
global_section.anonymous=true
global_enable=global_section:option(Flag,"enabled",translate("Enable Wifi Schedule"))
global_enable.optional=false
global_enable.rmempty=false
function global_enable.validate(a,e,a)
if e=="1"then
if(t.access("/sbin/wifi")and
t.access("/usr/bin/wifi_schedule.sh"))then
return e
else
return nil,translate("Could not find required /usr/bin/wifi_schedule.sh or /sbin/wifi")
end
else
return"0"
end
end
global_logging=global_section:option(Flag,"logging",translate("Enable logging"))
global_logging.optional=false
global_logging.rmempty=false
global_logging.default=0
enable_wifi=global_section:option(Button,"enable_wifi",translate("Activate wifi"))
function enable_wifi.write()
e.exec("/usr/bin/wifi_schedule.sh start manual")
end
disable_wifi_gracefully=global_section:option(Button,"disable_wifi_gracefully",translate("Disable wifi gracefully"))
function disable_wifi_gracefully.write()
e.exec("/usr/bin/wifi_schedule.sh stop manual")
end
disable_wifi_forced=global_section:option(Button,"disable_wifi_forced",translate("Disabled wifi forced"))
function disable_wifi_forced.write()
e.exec("/usr/bin/wifi_schedule.sh forcestop manual")
end
global_unload_modules=global_section:option(Flag,"unload_modules",translate("Unload Modules (experimental; saves more power)"))
global_unload_modules.optional=false
global_unload_modules.rmempty=false
global_unload_modules.default=0
modules=global_section:option(TextValue,"modules","")
modules:depends("unload_modules",global_unload_modules.enabled);
modules.wrap="off"
modules.rows=10
function modules.cfgvalue(t,e)
mod=a:get("wifi_schedule",e,"modules")
if mod==nil then
mod=""
end
return mod:gsub(" ","\r\n")
end
function modules.write(o,t,e)
if e then
value_list=e:gsub("\r\n"," ")
ListValue.write(o,t,value_list)
a:set("wifi_schedule",t,"modules",value_list)
end
end
determine_modules=global_section:option(Button,"determine_modules",translate("Determine Modules Automatically"))
determine_modules:depends("unload_modules",global_unload_modules.enabled);
function determine_modules.write(a,t)
output=e.exec("/usr/bin/wifi_schedule.sh getmodules")
modules:write(t,output)
end
d=m:section(TypedSection,"entry",translate("Schedule events"))
d.addremove=true
c=d:option(Flag,"enabled",translate("Enable"))
c.optional=false
c.rmempty=false
dow=d:option(MultiValue,"daysofweek",translate("Day(s) of Week"))
dow.optional=false
dow.rmempty=false
dow:value("Monday",translate("Monday"))
dow:value("Tuesday",translate("Tuesday"))
dow:value("Wednesday",translate("Wednesday"))
dow:value("Thursday",translate("Thursday"))
dow:value("Friday",translate("Friday"))
dow:value("Saturday",translate("Saturday"))
dow:value("Sunday",translate("Sunday"))
starttime=d:option(Value,"starttime",translate("Start WiFi"))
starttime.optional=false
starttime.rmempty=false
starttime:value("00:00")
starttime:value("01:00")
starttime:value("02:00")
starttime:value("03:00")
starttime:value("04:00")
starttime:value("05:00")
starttime:value("06:00")
starttime:value("07:00")
starttime:value("08:00")
starttime:value("09:00")
starttime:value("10:00")
starttime:value("11:00")
starttime:value("12:00")
starttime:value("13:00")
starttime:value("14:00")
starttime:value("15:00")
starttime:value("16:00")
starttime:value("17:00")
starttime:value("18:00")
starttime:value("19:00")
starttime:value("20:00")
starttime:value("21:00")
starttime:value("22:00")
starttime:value("23:00")
function starttime.validate(e,t,a)
return time_validator(e,t,translate("Start Time"))
end
stoptime=d:option(Value,"stoptime",translate("Stop WiFi"))
stoptime.optional=false
stoptime.rmempty=false
stoptime:value("00:00")
stoptime:value("01:00")
stoptime:value("02:00")
stoptime:value("03:00")
stoptime:value("04:00")
stoptime:value("05:00")
stoptime:value("06:00")
stoptime:value("07:00")
stoptime:value("08:00")
stoptime:value("09:00")
stoptime:value("10:00")
stoptime:value("11:00")
stoptime:value("12:00")
stoptime:value("13:00")
stoptime:value("14:00")
stoptime:value("15:00")
stoptime:value("16:00")
stoptime:value("17:00")
stoptime:value("18:00")
stoptime:value("19:00")
stoptime:value("20:00")
stoptime:value("21:00")
stoptime:value("22:00")
stoptime:value("23:00")
function stoptime.validate(e,t,a)
return time_validator(e,t,translate("Stop Time"))
end
force_wifi=d:option(Flag,"forcewifidown",translate("Force disabling wifi even if stations associated"))
force_wifi.default=false
force_wifi.rmempty=false
function force_wifi.validate(a,e,a)
if e=="0"then
if t.access("/usr/bin/iwinfo")then
return e
else
return nil,translate("Could not find required program /usr/bin/iwinfo")
end
else
return"1"
end
end
return m
