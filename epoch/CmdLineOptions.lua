CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local Usage         = "epoch [options]"
   local Optiks        = require("Optiks")
   local cmdlineParser = Optiks:new{usage=Usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   cmdlineParser:add_option{ 
      name   = {'-d', '--date'},
      dest   = 'date',
      action = 'store',
      type   = 'string',
   }

   cmdlineParser:add_option{ 
      name   = {'-u', '--uuid'},
      dest   = 'uuid',
      action = 'store',
      type   = 'string',
   }

   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end
   masterTbl.pargs = pargs
end
