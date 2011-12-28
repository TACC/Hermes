-- $Id: ReportSpanResults.lua 287 2008-11-06 18:45:20Z mclay $ --

ReportSpanResults = BaseTask:new()

require("serializeTbl")
require("ReportResults")
require("fileOps")

function ReportSpanResults:execute(myTable)
   local tag         = myTable.tag
   local tagA        = masterTbl().tagA
   local origEpoch   = masterTbl().origEpoch

   if (not masterTbl().spanning) then return end

   local masterTbl   = masterTbl().tagTbl[tag]
   ReportSpanResults:summarize(masterTbl)
   local totalTime   = os.date("!%T", masterTbl.span.totalTime)

   local e           = string.format("%.2f", masterTbl.span.totalTime -
                                    math.floor(masterTbl.span.totalTime))

   local _, _, extra = e:find("0.(.*)")
   totalTime         = totalTime .. "." .. extra
   local date        = os.date("%c", masterTbl.currentEpoch)

   local spanSummary = masterTbl.span.Summary

   local HumanDataA = {}

   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, "************************************************************************")
   table.insert(HumanDataA, "*** Span Test Results                                                ***")
   table.insert(HumanDataA, "************************************************************************")
   table.insert(HumanDataA, " ")
   table.insert(HumanDataA, 0)
   
   table.insert(HumanDataA, 2)
   table.insert(HumanDataA, {"ProjectDir:",      masterTbl.packageDir})
   table.insert(HumanDataA, {"Date:",            date})
   table.insert(HumanDataA, {"TM Version:",      Version})
   table.insert(HumanDataA, {"Tag:",             masterTbl.tag})
   table.insert(HumanDataA, {"Hermes Version:",  masterTbl.HermesVersion})
   table.insert(HumanDataA, {"Lua Version:",     _G._VERSION})
   table.insert(HumanDataA, {"Total Test Time:", totalTime})
   table.insert(HumanDataA, -2)
   
   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, " ")
   table.insert(HumanDataA, "************************************************************************")
   table.insert(HumanDataA, "*** Test Summary                                                     ***")
   table.insert(HumanDataA, "************************************************************************")
   table.insert(HumanDataA, " ")
   table.insert(HumanDataA, 0)
   
   table.insert(HumanDataA, 2)
   table.insert(HumanDataA, {"Total: ", spanSummary.total})
   for v in pairs(spanSummary) do
      local count = spanSummary[v]
      if (v ~= "total" and count > 0) then
   	 table.insert(HumanDataA, { v..":", count})
      end
   end
   table.insert(HumanDataA, -2)
   
   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, "")
   table.insert(HumanDataA, 0)
   
   
   if (masterTbl.full) then
      table.insert(HumanDataA, 6)
      table.insert(HumanDataA, {"*******","*","****","******","*****************","***********************************"})
      table.insert(HumanDataA, {"Results","R","Time","Target","Test Name",         "version/message"})
      table.insert(HumanDataA, {"*******","*","****","******","*****************","***********************************"})
   
      local resultTbl = {}
   
      for target in pairs(masterTbl.targetTbl) do
         local rptTbl = masterTbl.targetTbl[target].rptTbl
         local testresultsTbl = masterTbl.targetTbl[target].testresultsTbl
         for id in hash.pairs(rptTbl) do
            local tst	    = rptTbl[id]
            local aFlag   = " "
            if (tst:get("active")) then aFlag = "R" end
            local result  = tst:get('result')
            local runtime = tst:get('strRuntime')
            local txt     = tst:get('ProgVersion')
            local message = tst:get('message')
            if (message:len() > 0) then txt = message end
            if (testresultsTbl[result]) then
               table.insert(resultTbl, {result, aFlag, runtime, target, id, txt})
            end
         end
      end
      table.sort(resultTbl, function (a, b) 
                               if (a[1] == b[1]) then 
                                  return (b[4] > a[4]) 
                               else 
                                  return (a[1] > b[1]) 
                               end 
                            end)
      for i, v in ipairs(resultTbl) do
         table.insert(HumanDataA,v)
      end
      table.insert(HumanDataA, -6)
      table.insert(HumanDataA, 0)
      table.insert(HumanDataA, "")
      table.insert(HumanDataA, 0)
   end
   
   table.insert(HumanDataA, 2)
   table.insert(HumanDataA, {"*******","******"})
   table.insert(HumanDataA, {"Results","TARGET"})
   table.insert(HumanDataA, {"*******","******"})
   
   local testresultsTbl = masterTbl.testresultsTbl
   for target in pairs(masterTbl.targetTbl) do
      local status = masterTbl.targetTbl[target].status
      if (testresultsTbl[status]) then
         table.insert(HumanDataA, {status,target})
      end
   end
   table.insert(HumanDataA, -2)

   local HumanData = ReportResults:FormatHumanData(HumanDataA)
   
   if (#tagA == 1 and (masterTbl.span.totalTime > 0 or masterTbl.AnalyzeFlag)) then
      print(HumanData)
   end
   
   local epoch = masterTbl.origEpoch
   if (masterTbl.span.numTests > 0) then
      epoch = masterTbl.currentEpoch
   end
   local uuid                = UUIDString(epoch) .. "-" .. masterTbl.os_mach
   masterTbl.tstSpanReportFn = pathJoin(masterTbl.testRptDirRoot,".span",masterTbl.tag, uuid .. masterTbl.testRptExt)

   if (masterTbl.span.numRpt > 0) then
      local testresultT = ReportSpanResults:buildTestReportTable(HumanData,masterTbl)
      serializeTbl{name="testresults", value=testresultT, fn=masterTbl.tstSpanReportFn, indent=true}
   end
end

function ReportSpanResults:summarize(masterTbl)
   local span         = {}
   local totalTime    = 0
   local numRpt       = 0
   local numTests     = 0
   local tstSummary

   span.Summary       = {}

   for target in pairs(masterTbl.targetTbl) do
      local tbl    = masterTbl.targetTbl[target]
      numRpt       = numRpt    + #tbl.rptTbl
      numTests     = numTests  + #tbl.tstTbl
      totalTime    = totalTime + tbl.totalTestTime
      tstSummary   = tbl.tstSummary
      for v in pairs(tstSummary) do
         span.Summary[v] = (span.Summary[v] or 0) + tstSummary[v]
      end
      
   end

   span.numRpt       = numRpt
   span.numTests     = numTests
   span.totalTime    = totalTime
   masterTbl.span    = span

end

function ReportSpanResults:buildTestReportTable(HumanData, masterTbl)
   local testresults  = {
      HumanData	      = HumanData,
      date	      = masterTbl.date,
      currentUUid     = masterTbl.currentUUid,
      origUUid	      = masterTbl.origUUid,
      currentEpoch    = masterTbl.currentEpoch,
      origEpoch	      = masterTbl.origEpoch,
      machType	      = masterTbl.os_mach,
      hostname	      = masterTbl.hostname,
      Targ	      = masterTbl.targ,
      tag	      = masterTbl.tag,
      ntimes	      = masterTbl.ntimes,
      TotalTestTime   = masterTbl.totalTestTime,
      TM_Version      = masterTbl.TM_Version,
      Hermes_Version  = masterTbl.HermesVersion,
      Lua_Version     = _G._VERSION,
      tests	      = {},
   }

   testresults.tests.targetTbl = {}

   local testfields = Tst:testfields()

   for target in pairs(masterTbl.targetTbl) do
      local rptTbl = masterTbl.targetTbl[target].rptTbl
      local tests  = {}
      for id in hash.pairs(rptTbl) do
         local tst      = rptTbl[id]
         local testData = {}
         for i,v in ipairs(testfields) do
            testData[v] = tst:get(v)
         end
         tests[#tests + 1] = testData
      end
      testresults.tests.targetTbl[target] = tests
   end
   return testresults
end
