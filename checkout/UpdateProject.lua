-- $Id: UpdateProject.lua 287 2008-11-06 18:45:20Z mclay $ --
require("serializeTbl")

UpdateProject = BaseTask:new()

function UpdateProject:execute(myTable)
   local masterTbl   = masterTbl()
   local ProjectData = masterTbl.projectData
   local PackageList = ProjectData.PackageList
   rev = masterTbl.revision
   if (rev == nil) then
      rev = 'head'
   end
   
   for _, v in ipairs(masterTbl.pargs) do
      table.insert(PackageList, 
		   {pkgName  =  v,
		    revision =  rev,
		   })
   end
   serializeTbl{name='ProjectData', value=ProjectData, fn=masterTbl.projectFn,indent=true}
end
