require("strict")

ResetMasterTbl = BaseTask:new()

function ResetMasterTbl:execute(myTable)
   local masterTbl = masterTbl()
   local mtblFunc  = masterTbl.mtblFunc

   masterTbl       = mtblFunc()
   _G.masterTbl = function() return masterTbl end
end
