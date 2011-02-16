-- $Id: Batch.lua 353 2011-02-01 21:09:25Z mclay $ --

local JobSubmitBase = JobSubmitBase
local masterTbl     = masterTbl()
local concatTbl     = table.concat
local execute       = os.execute

BATCH         = inheritsFrom(JobSubmitBase)
BATCH.my_name = "Batch"

module("BATCH")

function queue(tbl, envTbl, funcTbl)
   local t      = funcTbl.batchTbl.queueTbl
   local name   = tbl.name
   local result = name
   if (t[name]) then
      result = t[name]
   end
   return result
end

function runtest(self, tbl)
   local logFileNm = tbl.idTag .. ".log"
   if (masterTbl.batchLog) then
      logFileNm = masterTbl.batchLog
   end

   local a = {}
   a[#a + 1] = self.batchTbl.submitCmd
   a[#a + 1] = tbl.scriptFn
   a[#a + 1] = ">>"
   a[#a + 1] = logFileNm
   a[#a + 1] = "2>&1"
   local s = concatTbl(a," ")
   execute(s)
end   
