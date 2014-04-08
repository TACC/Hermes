 -- $Id: FindTests.lua 249 2008-07-17 00:25:08Z mclay $ --
require("strict")
BuildMasterTbl = BaseTask:new()

function BuildMasterTbl:execute(myTable)
   local masterTbl = masterTbl()

   --------------------------------------------------------------------------
   -- This is very tricky:  the 'mt' metatable uses the metamethod to extract 
   -- values from the parent master table if they don't exist in the child
   -- master table.

   local mt	   = { __index = function (t,k) return t.mtblFunc()[k] end }
   local mtblFunc  = masterTbl.mtblFunc
   if (not masterTbl.tagTbl) then
      masterTbl.tagTbl = {}
      for _,tag        in ipairs(masterTbl.tagA)    do
         masterTbl.tagTbl[tag]           = {}
         masterTbl.tagTbl[tag].targetTbl = {}
         masterTbl.tagTbl[tag].mtblFunc  = mtblFunc
         masterTbl.tagTbl[tag].tag       = tag
         setmetatable(masterTbl.tagTbl[tag], mt)
         for _, target in ipairs(masterTbl.targetA) do
            masterTbl.tagTbl[tag].targetTbl[target]          = {}
            masterTbl.tagTbl[tag].targetTbl[target].tag      = tag
            masterTbl.tagTbl[tag].targetTbl[target].target   = target
            masterTbl.tagTbl[tag].targetTbl[target].mtblFunc = mtblFunc
            setmetatable(masterTbl.tagTbl[tag].targetTbl[target], mt)
         end
      end
      return
   end

   for tag       in pairs(masterTbl.tagTbl)    do
      masterTbl.tagTbl[tag].mtblFunc = mtblFunc
      masterTbl.tagTbl[tag].tag      = tag
      setmetatable(masterTbl.tagTbl[tag], mt)
      for target in pairs(masterTbl.tagTbl[tag].targetTbl) do
	 masterTbl.tagTbl[tag].targetTbl[target].tag      = tag
	 masterTbl.tagTbl[tag].targetTbl[target].target   = target
	 masterTbl.tagTbl[tag].targetTbl[target].mtblFunc = mtblFunc
         setmetatable(masterTbl.tagTbl[tag].targetTbl[target], mt)
      end
   end
end

