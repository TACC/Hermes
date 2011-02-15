-- $Id: WriteProjectData.lua 287 2008-11-06 18:45:20Z mclay $ --
require("serialize")

GetVersion = BaseTask:new()

function GetVersion:execute(myTable)
   local masterTbl     = masterTbl()
   print (masterTbl.projectData.HermesVersion)
end
