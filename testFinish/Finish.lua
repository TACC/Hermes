-- $Id: Finish.lua 287 2008-11-06 18:45:20Z mclay $ --

require("posix")
require("sys")
require("serialize")
require("getUname")

Finish = BaseTask:new()

function Finish:execute(myTable)
   local masterTbl = masterTbl()

   ---------------------------------------------------------------
   -- Diff tools write out "result.lua"
   local cmdResultFn = masterTbl.cmdResultFn
   local resultFn    = masterTbl.resultFn
   local runtimeFn   = masterTbl.runtimeFn
   local result
   local f = io.open(cmdResultFn,"r")
   if (f) then
      local s = f:read("*all")
      assert(loadstring(s))()
      result = 'passed'
      for i,v in ipairs(myTbl) do
	 if (v.result ~= 'passed' and v.result ~= 'Passed') then
	    if (result == 'passed' or result == 'diff') then
	       result = v.result
	    end
	 end
      end
   else
      result = 'failed'
   end
   local myResult = { testresult = result }
   serialize{name="myResult", value=myResult, fn=resultFn, indent=true}

   local t = getUname()

   assert(loadfile(runtimeFn))()
   runtime.end_time = sys.gettimeofday()

   for k in pairs(t) do
      runtime[k] = t[k]
   end

   serialize{name="runtime",  value=runtime,  fn=runtimeFn, indent=true}
end
