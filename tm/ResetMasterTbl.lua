-- $Id: ResetMasterTbl.lua 194 2008-06-25 21:43:50Z mclay $ --

ResetMasterTbl = BaseTask:new()

function ResetMasterTbl:execute(myTable)
   local masterTbl = masterTbl()
   local mtblFunc  = masterTbl.mtblFunc

   masterTbl       = mtblFunc()
   _G.masterTbl = function() return masterTbl end
end
