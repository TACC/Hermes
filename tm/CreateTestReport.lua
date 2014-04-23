require("strict")

CreateTestReport = BaseTask:new()

require("serializeTbl")
require("fileOps")

function CreateTestReport:execute(myTable)
   local masterTbl	 = masterTbl()
   local target          = myTable.target

   local prefix = ""
   if (target ~= "") then
      prefix = target .. "-"
   end

   local uuid            = prefix .. UUIDString(masterTbl.epoch) .. "-" .. masterTbl.os_mach
   local tstReportFn	 = pathJoin(masterTbl.testRptDir, uuid .. masterTbl.testRptExt)
   masterTbl.tstReportFn = tstReportFn

   --------------------------------------------------------
   -- Do not create a report when there are no tests to run

   if (next(masterTbl.tstTbl) == nil) then return end

   local HumanData	 = ''
   local testresults	 = buildTestReportTable(HumanData,masterTbl)

   serializeTbl{name="testresults", value=testresults, fn=tstReportFn, indent=true}
end
