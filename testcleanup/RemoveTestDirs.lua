require("dirlist")
require("fileOps")
require("ignoreDirList")
RemoveTestDirs = BaseTask:new()

local function execute(cmd)
   if (masterTbl().show) then
      print (cmd)
   else
      os.execute(cmd)
   end
end   

function RemoveTestDirs:execute(myTable)
   local masterTbl = masterTbl()
   local cmd

   ---------------------------------------------
   -- Remove test directories from each .tm file
   -- then remove the test

   for i,v in ipairs(masterTbl.tmfiles) do
      self:removeDir(v)
      cmd = "rm ".. v
      execute(cmd)
   end

   ---------------------------------------------
   -- Remove the target directories in
   --  "masterTbl.testRptRootDir"

   local ignoreT   = ignoreDirList()
   local t = dirlist(masterTbl.testRptRootDir)
   local targetA = t.dirs
   for _,target in ipairs(targetA) do
      if (not ignoreT[target]) then
         local dir  = pathJoin(masterTbl.testRptRootDir, target)
         local list = dirlist(dir)
         -- '.' and '..' are automatically removed by 'dirlist'
         if (#list.files == 0) then
	    cmd = "rm -rf " .. dir
            execute(cmd)
         end
      end
   end
end



function RemoveTestDirs:removeDir(file)

   -- read each tm file and remove test


   local masterTbl = masterTbl()
   local cmd

   assert(loadfile(file))()

   for i,v in ipairs(testresults.tests) do

      -- Convert id into testdir name
      local i, j, dir, fn, idTag = v.id:find("(.*)/([^/]*)/(.*)")

      if (i == nil) then
	 dir = "./"
         _, _, fn, idTag = v.id:find("([^/]*)/(.*)")
      end
      
      local outputDir = pathJoin(masterTbl.projectDir, v.outputDir)
      if (isDir(outputDir)) then
	 cmd = "rm -rf ".. outputDir
         execute(cmd)
      end
      local idDir = pathJoin(masterTbl.projectDir, dir, idTag)
      if (isDir(idDir)) then
         local list  = dirlist(idDir)

         -- '.' and '..' are automatically removed by 'dirlist'
         if (#list.files == 0 or masterTbl.keep == 0) then
	    cmd = "rm -rf " .. idDir
            execute(cmd)
         end
      end
   end
end
