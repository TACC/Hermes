-- $Id: WriteProjectData.lua 306 2009-02-06 18:30:56Z eijkhout $ --
require("serialize")

WriteProjectData = BaseTask:new()

function WriteProjectData:execute(myTable)
   local masterTbl     = masterTbl()

   masterTbl.projectData.HermesVersion     = masterTbl.new_version

   masterTbl.projectData.HermesVersionDate = os.date("%c")

   print ('version: ', masterTbl.new_version)

   serialize{name="ProjectData",value=masterTbl.projectData, fn=masterTbl.projectFn, indent=true}
end
