-- $Id: WriteTests.lua 287 2008-11-06 18:45:20Z mclay $ --

WriteTests = BaseTask:new()
require("fileOps")
require("serialize")
function WriteTests:execute(myTable)
   local masterTbl  = masterTbl()
   local testlistFn = pathJoin(masterTbl.projectDir, masterTbl.testlistFn)

   local testlist = {}

   local icount = 0
   for id in hash.pairs(masterTbl.tstTbl) do
      icount = icount + 1
      table.insert(testlist, id)
   end

   print ("Found " .. icount .. " tests")

   serialize{name="testlist", value=testlist, fn=testlistFn, indent=true}
end
