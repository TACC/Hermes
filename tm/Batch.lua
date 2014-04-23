require("strict")

local masterTbl     = masterTbl()
local concatTbl     = table.concat
local execute       = os.execute
local dbg           = require("Dbg"):dbg()

local M             = inheritsFrom(JobSubmitBase)
M.my_name           = "Batch"



function M.queue(tbl, envTbl, funcTbl)
   local t      = funcTbl.batchTbl.queueTbl
   local name   = tbl.name
   local result = t[name] or name
   return result
end

function M.runtest(self, tbl)
   local logFileNm = masterTbl.batchLog or tbl.idTag .. ".log"
   local a = {}
   a[#a + 1] = self.batchTbl.submitCmd
   a[#a + 1] = tbl.scriptFn
   a[#a + 1] = ">>"
   a[#a + 1] = logFileNm
   a[#a + 1] = "2>&1"
   local s = concatTbl(a," ")
   execute(s)
end   

return M

