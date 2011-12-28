-- $Id: Wrapper.lua 194 2008-06-25 21:43:50Z mclay $ --

require("serializeTbl")

myTbl = {}

DiffWrapper = BaseTask:new()

function DiffWrapper:execute(myTable)
   local masterTbl = masterTbl()
   local cmdA      = {}

   cmdA[#cmdA + 1] = "diff -c "

   cmdA[#cmdA + 1] = masterTbl.pargs[1]
   cmdA[#cmdA + 1] = masterTbl.pargs[2]
   cmdA[#cmdA + 1] = "> diff.log 2>&1"

   local cmdline = table.concat(cmdA," ")

   print (cmdline)
   local status     = os.execute(cmdline)
   masterTbl.status = status

   local resultFn = masterTbl.resultFn

   local f        = io.open(resultFn,"r")
   if (f) then
      local s = f:read("*all")
      assert(loadstring(s))()
   end
   local result = "failed"
   if (status == 0) then
      result = "passed"
   end
   os.remove("diff.log")
   myTbl[#myTbl+1] = { result=result, program="wrapperDiff"}
   serializeTbl{name="myTbl", value=myTbl, fn=resultFn, indent=true}
end
