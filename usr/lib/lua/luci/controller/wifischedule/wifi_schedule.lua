module("luci.controller.wifischedule.wifi_schedule",package.seeall)
local e=require"nixio.fs"
local t=require"luci.sys"
local t=require"luci.template"
local a=require"luci.i18n"
function index()
if not nixio.fs.access("/etc/config/wifi_schedule")then
return
end
local e=entry({"admin","services","wifi_schedule"},firstchild(),_("Wifi Schedule"),60)
e.acl_depends={"luci-app-wifischedule"}
e.dependent=false
entry({"admin","services","wifi_schedule","tab_from_cbi"},cbi("wifischedule/wifi_schedule"),_("Schedule"),1)
entry({"admin","services","wifi_schedule","wifi_schedule"},call("wifi_schedule_log"),_("View Logfile"),2)
entry({"admin","services","wifi_schedule","cronjob"},call("view_crontab"),_("View Cron Jobs"),3)
end
function wifi_schedule_log()
local e=e.readfile("/tmp/log/wifi_schedule.log")or""
t.render("wifischedule/file_viewer",
{title=a.translate("Wifi Schedule Logfile"),content=e})
end
function view_crontab()
local e=e.readfile("/etc/crontabs/root")or""
t.render("wifischedule/file_viewer",
{title=a.translate("Cron Jobs"),content=e})
end
