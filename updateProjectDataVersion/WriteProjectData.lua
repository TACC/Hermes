require("serializeTbl")

WriteProjectData = BaseTask:new()

function WriteProjectData:execute(myTable)
   local masterTbl     = masterTbl()

   masterTbl.projectData.HermesVersion     = masterTbl.new_version

   masterTbl.projectData.HermesVersionDate = os.date("%c")

   print ('version: ', masterTbl.new_version)

   serializeTbl{name="ProjectData",value=masterTbl.projectData, fn=masterTbl.projectFn, indent=true}
end
