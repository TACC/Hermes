CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "testcleanup [options]"
   local Optiks        = require("Optiks")
   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   cmdlineParser:add_option{ 
      name    = {'-k','--keep'},
      dest    = 'keep',
      action  = 'store',
      type    = 'number',
      default = 0
   }
   cmdlineParser:add_option{ 
      name    = {'--show'},
      dest    = 'show',
      action  = 'store_true',
   }


   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end
   
   masterTbl.pargs = pargs

end
