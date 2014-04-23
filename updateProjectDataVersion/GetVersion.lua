GetVersion = BaseTask:new()

function GetVersion:execute(myTable)
   local masterTbl     = masterTbl()
   print (masterTbl.projectData.HermesVersion)
end
