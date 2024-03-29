require("strict")
require("dirlist")
require("fileOps")
require("ignoreDirList")
local lfs = require("lfs")

FindAllTmFiles = BaseTask:new()



function FindAllTmFiles:execute(myTable)
   local masterTbl      = masterTbl()
   local testRptRootDir = masterTbl.testRptRootDir
   local pattern        = masterTbl.testRptExt
   local tmTbl          = {}

   self:allTMFiles(testRptRootDir, pattern, tmTbl)
   table.sort(tmTbl)

   for i = 1, masterTbl.keep do
      table.remove(tmTbl) -- remove last entry
   end

   masterTbl.tmfiles = tmTbl
end

function FindAllTmFiles:allTMFiles(path, pattern, t)
   local attr = lfs.attributes(path)
   if (attr == nil or attr.mode ~= "directory") then return end

   local ignoreT = ignoreDirList()
   for file in lfs.dir(path) do
      if (not ignoreT[file]) then
         local f = pathJoin(path, file)
         local attr = lfs.attributes (f)
         assert (type(attr) == "table")
         if (attr.mode == "directory") then
            self:allTMFiles(f, pattern, t)
         elseif (file:sub(1,2) ~= ".#" and file:find(pattern,1,true)) then
            t[#t + 1] = f
         end
      end
   end
end
