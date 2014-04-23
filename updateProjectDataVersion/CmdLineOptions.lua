CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "updateProjectDataVersion [options]" 
   local Optiks        = require("Optiks")
   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'--new_version'},
      dest   = 'new_version',
      action = 'store',
      type   = 'string',
      default = false,
   }

   cmdlineParser:add_option{ 
      name   = {'--version'},
      dest   = 'version',
      action = 'store_true',
      type   = 'string',
   }

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end

   masterTbl.pargs = pargs

end

