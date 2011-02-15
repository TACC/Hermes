-- $Id: RunMake.lua 314 2009-02-12 01:52:31Z mclay $ --

ProjectTop = BaseTask:new()
require("fileOps")
require("lfs")
require("posix")
function ProjectTop:execute(myTable)
   local masterTbl  = masterTbl()
   local pargs      = masterTbl.pargs
   local wd         = lfs.currentdir()
   local packageDir = masterTbl.packageDir
   local i,j        = wd:find(packageDir)

   if (i == nil) then
      io.stderr:write("Current directory not in a project: ",wd,"\n")
      return
   end 

   local topDir = pathJoin(masterTbl.projectDir, masterTbl.packageName)

   if ((masterTbl.verbosityLevel or 0) > 1) then
      io.stderr:write ("topDir", topDir, "\n")
   end

   local attr = lfs.attributes(topDir)

   if (attr == nil or attr.mode ~= 'directory') then
      io.stderr:write ("topDir: ".. topDir.." not found")
      return
   end 
   print ("cd " .. topDir)
end
