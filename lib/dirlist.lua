_DEBUG      = false
local posix = require("posix")

require("strict")
require("fileOps")
local lfs   = require("lfs")

function dirlist(path)
   local list = {}
   list.dirs  = {}
   list.files = {}

   local attr = lfs.attributes(path)

   if (attr == nil or attr.mode ~= "directory") then return list end
   for fn in lfs.dir(path) do
      if (fn ~= "." and fn ~= "..") then
         local f    = pathJoin(path, fn)
         local attr = lfs.attributes(f)
         if (type(attr) == "table") then
            if (attr.mode == "directory") then
               table.insert(list.dirs, fn)
            else
               table.insert(list.files, fn)
            end
         end
      end
   end
   return list
end

function filelist(path)
   local list = {}

   local attr = lfs.attributes(path)

   if (attr == nil or attr.mode ~= "directory") then return list end
   for fn in lfs.dir(path) do
      if (fn ~= "." and fn ~= "..") then
	 list[#list + 1] = fn
      end
   end
   return list
end

