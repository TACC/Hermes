Wrapper = BaseTask:new()

function Wrapper:execute(myTable)
   local masterTbl = masterTbl()
   
   assert(loadfile(masterTbl.tdesc))()
   
   local cmdA = {}

   cmdA[#cmdA + 1] = "stwcmp"

   if (masterTbl.maxSteps) then
      cmdA[#cmdA + 1] = "-S " .. masterTbl.maxSteps
   end
      
   cmdA[#cmdA + 1] = "-r"
   local optTbl  = {"resultFn","goldSimFile", "testSimFile"}

   for i,v in ipairs(optTbl) do
      cmdA[#cmdA + 1] = masterTbl[v]
   end

   for i,v in ipairs(testdescript.tolerances.vars) do
      cmdA[#cmdA + 1] = v.name .. " " .. v.rel .. " " .. v.abs
   end
   
   local cmdline = table.concat(cmdA," ")

   print ("cmdline",cmdline)

   local status = os.execute(cmdline .. " > diff.log 2>&1")
   masterTbl.status = status
end
