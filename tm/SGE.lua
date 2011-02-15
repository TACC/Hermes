-- $Id: sge.lua 194 2008-06-25 21:43:50Z mclay $ --
require("inherits")

local concatTbl  = table.concat
local execute    = os.execute
local date       = os.date
local print      = print


SGE         = inheritsFrom("JobSubmitBase")
SGE.my_name = "SGE"

module ("SGE")

local blank = " "
local function formatMsg(self, result, iTest, passed, failed, numTests, id)
   local r        = result or "failed"
   local blankLen = self.resultMaxLen - r:len()
   local msg      = format("%s%s : %s tst: %d/%d P/F: %d:%d, %s",
                           blank:rep(blankLen),
                           result,
                           date("%X"),
                           iTest, numTests,
                           passed, failed,
                           id)
   return msg
end
function mpr(tbl)
   local t = {}
   t[#t + 1]  = "ibrun"
   t[#t + 1]  = tbl.cmd
   t[#t + 1]  = tbl.cmd_args or ""
   local s = concatTbl(t," ")
   return s
end

local qn = {short="development", medium="normal", long="long", systest="systest"}

function queue(tbl)
   local name = tbl.name
   if (qn[name] == nil) then name = "medium" end
   return qn[name]
end

function CWD(tbl)
   return "."
end

function submit(tbl)
   local t = {}
   local n = 16
   if (tbl.jobname) then t[#t + 1] = "#$ -N ".. tbl.jobname           end
   if (tbl.queue)   then t[#t + 1] = "#$ -q ".. tbl.queue             end
   if (tbl.jobname) then t[#t + 1] = "#$ -o ".. tbl.jobname .. ".log" end
   t[#t + 1] = "#$ -l h_rt="  .. (tbl.time    or "01:00:00")
   t[#t + 1] = "#$ -pe ".. (tbl.np or "1") .. "way " .. n
   t[#t + 1] = "#$ -V"
   t[#t + 1] = "#$ -cwd"
   t[#t + 1] = "#$ -j y"

   if (tbl.sge)     then t[#t + 1] = tbl.sge               end       
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

function Msg(self, result, iTest, numTests, id, resultFn, background)
   local masterTbl	= self.masterTbl
   
   if (result == "Started") then
      print(formatMsg(self, result, iTest, masterTbl.passed, masterTbl.failed, numTests, id))
   elseif (not background) then
      assert(loadfile(resultFn))()
      local myResult = systemG.myResult.testresult
      if (myResult == "passed") then
         masterTbl.passed = masterTbl.passed + 1
      else
         masterTbl.failed = masterTbl.failed + 1
      end
      
      print(formatMsg(self, myResult, iTest, masterTbl.passed, masterTbl.failed, numTests, id),"\n")
   end
end
