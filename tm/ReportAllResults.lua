-- $Id: ReportSpanResults.lua 247 2008-07-16 16:01:11Z mclay $ --

ReportAllResults = BaseTask:new()

require("ReportResults")
require("fileOps")

function ReportAllResults:execute(myTable)
   local tagA      = masterTbl().tagA

   if (#tagA < 2) then return end

   local masterTbl   = masterTbl()
   ReportAllResults:summarize(masterTbl)
   local totalTime   = os.date("!%T", masterTbl.span.totalTime)

   local e           = string.format("%.2f", masterTbl.span.totalTime -
                                    math.floor(masterTbl.span.totalTime))

   local _, _, extra = e:find("0.(.*)")
   totalTime         = totalTime .. "." .. extra
   local date        = os.date("%c", masterTbl.currentEpoch)

   local spanSummary = masterTbl.span.Summary

   local HumanDataA  = {}
   local targetA     = masterTbl.targetA

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
   table.insert(HumanDataA, {"Tag:",             masterTbl.tagString})
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
      table.insert(HumanDataA, 7)
      table.insert(HumanDataA, {"*******","*","****","***","******","*****************","***********************************"})
      table.insert(HumanDataA, {"Results","R","Time","Tag","Target","Test Name",         "version/message"})
      table.insert(HumanDataA, {"*******","*","****","***","******","*****************","***********************************"})
   
      local resultTbl = {}
   
      for tag       in pairs(masterTbl.tagTbl)                do
         for target in pairs(masterTbl.tagTbl[tag].targetTbl) do
            local tbl            = masterTbl.tagTbl[tag].targetTbl[target]
            local rptTbl         = tbl.rptTbl
            local testresultsTbl = tbl.testresultsTbl
            for id in hash.pairs(rptTbl) do
               local tst     = rptTbl[id]
               local aFlag   = " "
               if (tst:get("active")) then aFlag = "R" end
               local result  = tst:get('result')
               local runtime = tst:get('strRuntime')
               local txt     = tst:get('ProgVersion')
               local message = tst:get('message')
               if (message:len() > 0) then txt = message end
               if (testresultsTbl[result]) then
                  table.insert(resultTbl, {result, aFlag, runtime, tag, target, id, txt})
               end
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
      table.insert(HumanDataA, -7)
      table.insert(HumanDataA, 0)
      table.insert(HumanDataA, "")
      table.insert(HumanDataA, 0)
   end
   
   table.insert(HumanDataA, 2)
   table.insert(HumanDataA, {"*******","***"})
   table.insert(HumanDataA, {"Results","Tag"})
   table.insert(HumanDataA, {"*******","***"})
   
   local testresultsTbl = masterTbl.testresultsTbl
   for tag       in pairs(masterTbl.tagTbl)                do
      local status = masterTbl.tagTbl[tag].status
      if (testresultsTbl[status]) then
         table.insert(HumanDataA, {status, tag})
      end
   end
   table.insert(HumanDataA, -2)

   local HumanData = ReportResults:FormatHumanData(HumanDataA)
   
   if (masterTbl.span.totalTime > 0 or masterTbl.AnalyzeFlag) then
      print(HumanData)
   end
end

function ReportAllResults:summarize(masterTbl)
   local span         = {}
   local totalTime    = 0
   local numRpt       = 0
   local currentEpoch = 0
   local origEpoch    = 0
   local numTests     = 0
   local testValues   = Tst:testresultValues()
   local tstSummary   
   local status

   span.Summary       = {}

   for tag       in pairs(masterTbl.tagTbl)                do
      status = "passed"
      for target in pairs(masterTbl.tagTbl[tag].targetTbl) do
         local tbl    = masterTbl.tagTbl[tag].targetTbl[target]
         if (testValues[tbl.status] < testValues[status]) then
            status = tbl.status
         end
         numRpt       = numRpt    + #tbl.rptTbl
         numTests     = numTests  + #tbl.tstTbl
         totalTime    = totalTime + tbl.totalTestTime
         currentEpoch = math.max(currentEpoch, tbl.currentEpoch)
         origEpoch    = math.max(origEpoch,    tbl.origEpoch)
         tstSummary   = tbl.tstSummary
         for v in pairs(tstSummary) do
            span.Summary[v] = (span.Summary[v] or 0) + tstSummary[v]
         end
      end
      masterTbl.tagTbl[tag].status = status
   end

   span.currentEpoch = currentEpoch
   span.origEpoch    = origEpoch
   span.numRpt       = numRpt
   span.numTests     = numTests
   span.totalTime    = totalTime
   masterTbl.span    = span
end
