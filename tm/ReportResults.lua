require("strict")
require("Tst")
require("common")
require("serializeTbl")
require("TermWidth")

ReportResults = BaseTask:new()

function ReportResults:execute(myTable)
   local width          = TermWidth() - 1 
   local masterTbl      = myTable.masterTbl
   local tstTbl         = masterTbl.tstTbl
   local rptTbl         = masterTbl.rptTbl
   local HumanDataA     = {}
   local tstSummary     = masterTbl.tstSummary
   local totalTime      = os.date("!%T", math.floor(masterTbl.totalTestTime))

   local e              = string.format("%.2f", masterTbl.totalTestTime -
                                            math.floor(masterTbl.totalTestTime))

   local _, _, extra    = e:find("0.(.*)")
   totalTime            = totalTime .. "." .. extra
   local testresultsTbl = masterTbl.testresultsTbl

   local icount = 0
   for id in pairs(rptTbl) do
      local tst	    = rptTbl[id]
      local result  = tst:get('result')
      if (testresultsTbl[result]) then
         icount = icount + 1
      end
   end

   local HDR = string.rep("*", width)
   local TR  = "*** Test Results"
   local TS  = "*** Test Summary"
   local TRl = width - TR:len() - 3
   TR        = TR .. string.rep(" ", TRl) .. "***"
   TS        = TS .. string.rep(" ", TRl) .. "***"

   
   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, HDR)
   table.insert(HumanDataA, TR)
   table.insert(HumanDataA, HDR)
   table.insert(HumanDataA, " ")
   table.insert(HumanDataA, 0)
   
   table.insert(HumanDataA, 2)
   table.insert(HumanDataA, {"Date:",            masterTbl.date})
   table.insert(HumanDataA, {"TARGET:",          masterTbl.target})
   table.insert(HumanDataA, {"Tag:",             masterTbl.tag})
   table.insert(HumanDataA, {"TM Version:",      Version})
   table.insert(HumanDataA, {"Hermes Version:",  masterTbl.HermesVersion})
   table.insert(HumanDataA, {"Lua Version:",     _G._VERSION})
   table.insert(HumanDataA, {"Total Test Time:", totalTime})
   table.insert(HumanDataA, -2)
   
   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, " ")
   table.insert(HumanDataA, HDR)
   table.insert(HumanDataA, TS)
   table.insert(HumanDataA, HDR)
   table.insert(HumanDataA, " ")
   table.insert(HumanDataA, 0)
   
   table.insert(HumanDataA, 2)
   table.insert(HumanDataA, {"Total: ", tstSummary.total})
   for v in pairs(tstSummary) do
      local count = tstSummary[v]
      if (v ~= "total" and count > 0) then
   	 table.insert(HumanDataA, { v..":", count})
      end
   end
   table.insert(HumanDataA, -2)
   
   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, "")
   table.insert(HumanDataA, 0)
   
   table.insert(HumanDataA, 5)
   table.insert(HumanDataA, {"*******","*","****","*********","***************"})
   table.insert(HumanDataA, {"Results","R","Time","Test Name","version/message"})
   table.insert(HumanDataA, {"*******","*","****","*********","***************"})
   
   
   local resultTbl = {}

   for id in pairs(rptTbl) do
      local tst	    = rptTbl[id]
      local aFlag   = " "
      if (tst:get("active")) then aFlag = "R" end
      local result  = tst:get('result')
      local runtime = tst:get('strRuntime')
      local txt     = tst:get('ProgVersion')
      local message = tst:get('message')
      if (message:len() > 0) then txt = message end
      if (testresultsTbl[result]) then
         table.insert(resultTbl, {result, aFlag, runtime, id, txt})
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
   table.insert(HumanDataA, -5)
   table.insert(HumanDataA, 0)
   table.insert(HumanDataA, "")
   table.insert(HumanDataA, 0)

   if (tstSummary.total ~= tstSummary.passed) then
      table.insert(HumanDataA, 2)
      table.insert(HumanDataA, {"*******",  "****************"})
      table.insert(HumanDataA, {"Results",  "Output Directory"})
      table.insert(HumanDataA, {"*******",  "****************"})

      resultTbl = {}

      for id in pairs(rptTbl) do
         local tst = rptTbl[id]
         local result  = tst:get('result')
         if (result ~= "passed" and testresultsTbl[result]) then
	    table.insert(resultTbl, {result, fullFn(tst:get('outputDir'))})
	 end
      end
      table.sort(resultTbl, function (a, b) 
      			      if (a[1] == b[1]) then 
      			        return (b[2] > a[2]) 
      			      else 
      			        return (b[1] > a[1]) 
			      end 
			   end)
      for i, v in ipairs(resultTbl) do
         table.insert(HumanDataA,v)
      end
      table.insert(HumanDataA, -2)
   end

   local HumanData = ReportResults:FormatHumanData(HumanDataA)
   
   if (masterTbl.totalTestTime > 0 and not masterTbl.spanning and icount > 0) then
      print(HumanData)
   end
   
   if (icount > 0) then
      local testresultT = buildTestReportTable(HumanData, masterTbl)
      serializeTbl{name="testresults", value=testresultT, fn=masterTbl.tstReportFn, indent=true}
   end
end


function ReportResults:FormatHumanData(HumanDataA)

   local tbl       = {}
   local numCols   = HumanDataA[1]
   local HumanData = ''
   local method
   if (numCols == 0) then
      method = "strings"
   else
      method = "column"
   end

   table.remove(HumanDataA,1)
   

   for i,v in ipairs(HumanDataA) do
      if (type(v)  == 'number') then
	 if (numCols == -v) then
	    -- Time to write
	    HumanData = HumanData .. ReportResults[method](ReportResults, tbl, numCols)
	    numCols   = -10
	    tbl       = {}
	 else
	    numCols = v
	    if (numCols == 0) then
	       method = "strings"
	    else
	       method = "columns"
	    end
	 end
      else
	 table.insert(tbl, v)
      end
   end

   return HumanData
end

function ReportResults:strings(tbl, numCols)
   return table.concat(tbl, "\n") .. "\n"
end

function ReportResults:columns(tbl, numCols)

   local w
   local widths = {}
   for icol = 1, numCols do
      w = 0
      for i,v in ipairs(tbl) do
         if (type(v[icol]) ~= "string") then
            v[icol] = tostring(v[icol])
         end
	 w = math.max(w, v[icol]:len())
      end
      widths[icol] = w + 2
   end

   for icol = 1, numCols-1 do
      w = widths[icol]
      for i,v in ipairs(tbl) do
	 local blankLen = w - v[icol]:len()
	 v[icol] = v[icol] .. string.rep(" ",  blankLen)
      end
   end

   local s      = {}
   for i,v in ipairs(tbl) do
      table.insert(s, table.concat(v))
   end

   return table.concat(s,"\n") .. "\n"
end
