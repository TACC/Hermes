require("strict")

CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)

   local usage         = "H5MGFdiff -r resultFn -f xdrdiff.lua  xdr1 xdr2"
   local Optiks        = require("Optiks")
   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   cmdlineParser:add_option{ 
      name   = {'-f','--file'},
      dest   = 'tdesc',
      action = 'store'
   }
   cmdlineParser:add_option{ 
      name   = {'-r', '--resultfile'},
      dest   = 'resultFn',
      action = 'store'
   }

   local optionTbl, pargs = cmdlineParser:parse(arg)
   local masterTbl        = masterTbl()

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end

   masterTbl.pargs = pargs

   if (#masterTbl.pargs < 2) then
      Error("Usage: ",usage)
   end
end
