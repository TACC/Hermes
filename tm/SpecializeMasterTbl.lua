-- $Id: SpecializeMasterTbl.lua 254 2008-07-18 01:38:42Z mclay $ --

SpecializeMasterTbl = BaseTask:new()
require("fileOps")

function SpecializeMasterTbl:execute(myTable)
   local tag       = myTable.tag
   local target    = myTable.target
   local masterTbl = masterTbl()

   local origTbl   = masterTbl.mtblFunc()

   local tbl       = origTbl.tagTbl[tag].targetTbl[target]

   local prefix = ""
   if (target ~= "") then
      prefix = target .. "-"
   end


   tbl.testRptDir  = pathJoin(tbl.projectDir, tbl.testRptLoc, target) 
   tbl.tag         = tag
   tbl.target      = target

   _G.masterTbl = function() return origTbl.tagTbl[tag].targetTbl[target] end
end
