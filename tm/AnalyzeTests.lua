-- $Id: AnalyzeTests.lua 301 2009-02-04 23:56:06Z mclay $ --
require("common")
require("Dbg")
AnalyzeTests = BaseTask:new()

MyResult = nil
function AnalyzeTests:execute(myTable)
   local masterTbl     = myTable.masterTbl
   local tstTbl        = masterTbl.tstTbl
   local rptTbl        = masterTbl.rptTbl
   local dbg           = Dbg:dbg()
   
   local tstSummary    = {}
   local testValues    = Tst:testresultValues()
   for v in pairs(testValues) do
      tstSummary[v] = 0
   end
   tstSummary.total = 0
   masterTbl.errors = 0
      
   masterTbl.totalTestTime = 0

   local epoch = masterTbl.currentEpoch
   if (#tstTbl == 0) then
      epoch = masterTbl.origEpoch
   end
   
   local status = 'passed'
   if (#rptTbl == 0) then
      status = ' '
   end

   for id in hash.pairs(rptTbl) do
      local tst		= rptTbl[id]
      local resultFn	= fullFn(tst:get('resultFn'))

      assert(loadfile(resultFn))()
      
      local result = myResult.testresult:lower()


      dbg.print ("tst.testName: ", tst.testName, " result: ",result,"\n")

      -- Save result in current test
      tst:set('result', result)
   
      -- Accumulate test results
      if (testValues[result] == nil) then
	 result = result or "nil"
   	 Error("Unknown test result: " .. result .. " from: " .. resultFn)
      end
      tstSummary[result] = tstSummary[result] + 1
      tstSummary.total   = tstSummary.total   + 1


      if (testValues[result] < testValues[status] ) then
         status = result
      end

      if (result ~= 'passed') then
         masterTbl.errors  = masterTbl.errors  + 1
      end
   
      local fini = sys.gettimeofday()
   

      -- Save runtime in current test
      assert(loadfile(fullFn(tst:get('runtimeFn'))))()
      local tstTime
      local t, _
      if (runtime.start_time < 0 or runtime.end_time < 0) then
   	 tstTime = '****'
	 t       = -1
      else
	 t                 = runtime.end_time - runtime.start_time
	 _, _, tstTime     = string.format("%10.3g", t):find("^%s*([0123456789.-e+]+%s*)")
	 masterTbl.totalTestTime = masterTbl.totalTestTime + t
      end

      local versionFn = fullFn(tst:get("versionFn"))
      local f = io.open(versionFn,"r")
      if (f) then
         local s = f:read("*all")
         assert(loadstring(s))()
         tst:set('ProgVersion',ProgVersion)
         f:close()
      end

      local messageFn = fullFn(tst:get("messageFn"))
      local f = io.open(messageFn,"r")
      if (f) then
         local s = f:read("*all")
         assert(loadstring(s))()
         tst:set('message',messageTbl.message)
         f:close()
      end

      tst:set('runtime', t)
      tst:set('strRuntime', tstTime)
      for k in pairs(runtime) do
         tst:set(k,runtime[k])
      end

   end
   if (masterTbl.totalTestTime <= 0) then
      masterTbl.errors  = 0
   end
   masterTbl.tstSummary = tstSummary
   masterTbl.status     = status
   masterTbl.epoch      = epoch
end
