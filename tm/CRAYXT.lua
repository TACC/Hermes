-- $Id: xt3.lua 194 2008-06-25 21:43:50Z mclay $ --
require("inherits")

local concatTbl  = table.concat
local execute    = os.execute

CRAYXT         = inheritsFrom("JobSubmitBase")
CRAYXT.my_name = "CRAYXT"

module ("CRAYXT")

function mpr(tbl)
   local t = {}
   t[#t + 1]  = "yod"
   t[#t + 1]  = "-np"
   t[#t + 1]  = tbl.np
   t[#t + 1]  = tbl.cmd or ""
   t[#t + 1]  = tbl.cmd_args or ""
   local s = concatTbl(t," ")
   return s
end

local qn = {short="debug", medium="normal", long="long"}

function queue(tbl)
   local name = tbl.name
   if (qn[name] == nil) then name = "medium" end
   return qn[name]
end

function CWD(tbl)
   return "$PBS_O_WORKDIR"
end

function submit(tbl)
   local t = {}
   if (tbl.jobname) then t[#t + 1] = "#PBS -N ".. tbl.jobname           end
   if (tbl.account) then t[#t + 1] = "#PBS -A ".. tbl.account           end
   if (tbl.queue)   then t[#t + 1] = "#PBS -q ".. tbl.queue             end
   if (tbl.jobname) then t[#t + 1] = "#PBS -o ".. tbl.jobname .. ".log" end
   t[#t + 1] = "#PBS -l walltime=".. (tbl.time    or "1:00")
   t[#t + 1] = "#PBS -l size="    .. (tbl.np      or "1")
   t[#t + 1] = "#PBS -j oe"
   if (tbl.xt3)     then t[#t + 1] = tbl.xt3 end       
   local s = concatTbl(t,"\n")
   return s
end

function runtest(self, tbl)
   local t = {}
   t[#t + 1] = "qsub"
   t[#t + 1] = tbl.scriptFn
   local s = concatTbl(t," ")
   execute(s)
end 
