-- $Id: lsf.lua 287 2008-11-06 18:45:20Z mclay $ --
require("inherits")
require("string_split")

local concatTbl  = table.concat
local execute    = os.execute

LSF         = inheritsFrom("JobSubmitBase")
LSF.my_name = "LSF"

module ("LSF")

local function hours_minutes(s)
   local t = {}
   for v in s:split(':') do
      t[#t + 1] = v
   end
   return t[1] .. ":" .. (t[2] or "00")
end


function mpr(tbl)
   local t = {}
   t[#t + 1]  = "ibrun"
   t[#t + 1]  = tbl.cmd or ""
   t[#t + 1]  = tbl.cmd_args or ""
   local s = table.concat(t," ")
   return s
end

local qn = {short="development", medium="normal", long="long"}

function queue(tbl)
   local name = tbl.name
   if (qn[name] == nil) then name = "medium" end
   return qn[name]
end

function CWD(tbl)
   return "$LS_SUBCWD"
end

function submit(tbl)
   local jobTime = hours_minutes(tbl.time or "01:00:00")

   local t = {}
   if (tbl.jobname) then t[#t + 1] = "#BSUB -J ".. tbl.jobname           end
   if (tbl.queue)   then t[#t + 1] = "#BSUB -q ".. tbl.queue             end
   if (tbl.jobname) then t[#t + 1] = "#BSUB -o ".. tbl.jobname .. ".log" end
   t[#t + 1] = "#BSUB -W ".. jobTime
   t[#t + 1] = "#BSUB -n ".. (tbl.np      or "1")

   if (tbl.lsf)     then t[#t + 1] = tbl.lsf               end       

   local s = table.concat(t,"\n")
   return s
end

function runtest(self, tbl)
   local t = {}
   t[#t + 1] = "bsub <"
   t[#t + 1] = tbl.scriptFn
   local s = table.concat(t," ")
   execute(s)
end 
