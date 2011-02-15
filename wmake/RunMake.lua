-- $Id: RunMake.lua 314 2009-02-12 01:52:31Z mclay $ --

RunMake = BaseTask:new()
require("lfs")
require("fileOps")
require("string_utils")
require("posix")
function RunMake:execute(myTable)
   local masterTbl  = masterTbl()
   local pargs      = masterTbl.pargs
   local wd         = lfs.currentdir()
   local packageDir = masterTbl.packageDir
   local i,j        = wd:find(packageDir)

   if (i == nil) then
      print("Current working directory not in a project: " .. wd)
      return
   end 

   local workDir = pathJoin(masterTbl.projectDir, masterTbl.packageName,
                            masterTbl.projectData.TopMakeDir or "")

   if ((masterTbl.verbosityLevel or 0) > 1) then
      print ("workDir", workDir)
   end

   local attr = lfs.attributes(workDir)

   if (attr == nil or attr.mode ~= 'directory') then
      print ("workDir: ".. workDir.." not found")
      return
   end 

   local a    = {}
   local cmdA = {}
   local settarg_cmd = findInPath('settarg_cmd')
   if (settarg_cmd ~= '') then
      cmdA[#cmdA+1] = "settarg_cmd --shell bare"
      for _,v in ipairs(masterTbl.targetA) do
         cmdA[#cmdA+1] = v
      end

      local cmd = table.concat(cmdA," ")
      if (masterTbl.show) then
         print(cmd)
      else
         local Hnd, ErrStr = io.popen(cmd)
         if Hnd then
            for line in Hnd:lines() do
               a[#a + 1] = line:trim()
            end -- for Line
            Hnd:close()
         else
            print(ErrStr)
         end -- if
         for _,v in ipairs(a) do
            local i,j   = v:find("%s+")
            local var   = v:sub(1,i-1)
            local value = v:sub(j+1):trim()
            value       = value:sub(2,-2)
            posix.setenv(var,value,true)
         end
      end
   end


   cmdA = {}
   cmdA[#cmdA + 1] = "make  -C"  
   cmdA[#cmdA + 1] = workDir
   if (masterTbl.compiler) then
      cmdA[#cmdA + 1] = "compiler=" .. masterTbl.compiler
   end
   for i,v in ipairs(pargs) do
      cmdA[#cmdA + 1] = v
   end
   
   local make_cmd = table.concat(cmdA," ")

   print (make_cmd)
   if (not masterTbl.show) then
      masterTbl.status = os.execute(make_cmd)
   end
end
