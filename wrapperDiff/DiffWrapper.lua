
require("serializeTbl")
require("fileOps")

myTbl       = {}
concatTbl   = table.concat
local load  = (_VERSION == "Lua 5.1") and loadstring or load
DiffWrapper = BaseTask:new()

function DiffWrapper:execute(myTable)
   local masterTbl = masterTbl()

   local origA      = { masterTbl.pargs[1], masterTbl.pargs[2] } 
   local modA       = { '_' .. removeExt(barefilename(origA[1])) .. ".left",
                        '_' .. removeExt(barefilename(origA[2])) .. ".right",}
   local cmdA       = {}
   local cmdLine

   for i = 1,2 do
      cmdA[#cmdA + 1 ] = "sed -e 's/Lua: Version.*/Lua: Version/g' -e 's/suite: Version.*//g' <"
      cmdA[#cmdA + 1 ] = origA[i]
      cmdA[#cmdA + 1 ] = ">"
      cmdA[#cmdA + 1 ] = modA[i]

      cmdLine = concatTbl(cmdA," ")
      print (cmdLine)
      os.execute(cmdLine)
      cmdA = {}
   end

   cmdA[#cmdA + 1] = "diff -c "

   cmdA[#cmdA + 1] = modA[1]
   cmdA[#cmdA + 1] = modA[2]
   cmdA[#cmdA + 1] = "> diff.log 2>&1"

   local cmdline = concatTbl(cmdA," ")

   print (cmdline)
   local status = os_execute(cmdline)
   masterTbl.status = status

   local result = "diff"
   if (status == 0) then
      result = "passed"
   else
      cmdA = {}
      cmdA[#cmdA + 1] = 'grep -q "lua: error"'
      cmdA[#cmdA + 1] = modA[2]
      cmdA[#cmdA + 1] = "> diff.log 2>&1"      
      cmdline         = concatTbl(cmdA," ")
      status          = os_execute(cmdline)
      result          = (status == 0) and "failed" or "diff"
   end
   os.remove("diff.log")
   --os.remove(modA[1])
   --os.remove(modA[2])

   local resultFn = masterTbl.resultFn
   local csvFn    = masterTbl.csvFn

   if (csvFn) then
      local f = io.open(csvFn,"a")
      f:write(result,", ",modA[2],", wrapperDiff\n")
      f:close()
   end

   if (resultFn) then
      local f        = io.open(resultFn,"r")
      if (f) then
         local s = f:read("*all")
         assert(load(s))()
      end
      myTbl[#myTbl+1] = { result=result, program="wrapperDiff"}
      serializeTbl{name="myTbl", value=myTbl, fn=resultFn, indent=true}
   end
end






local function execute51(s)
   return os.execute(s)
end

local function execute52(s)
   local success, flag, status = os.execute(s)
   return status
end

local version = _VERSION:gsub("^Lua%s+","")
os_execute = execute52
if (version == "5.1") then
  os_execute = execute51
end

