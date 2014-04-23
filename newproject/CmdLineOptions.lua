
CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local Optiks = require("Optiks")
   local usage  = "newproject project_name"

   cmdlineParser = Optiks:new{usage = usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   local optionTbl, pargs = cmdlineParser:parse(arg)
   local masterTbl        = masterTbl()

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end

   masterTbl.pargs = pargs

   if (#masterTbl.pargs < 1) then
      Error("Usage: ",usage)
   end
end
