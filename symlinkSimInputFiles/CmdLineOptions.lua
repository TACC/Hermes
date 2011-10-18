-- $Id: CmdLineOptions.lua 302 2009-02-04 23:56:32Z mclay $ --

CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "symlinkSimInputFiles [options]"
   local Optiks        = require("Optiks")
   local cmdlineParser = Optiks:new{usage = usage, error = Error}

   cmdlineParser:add_option{ 
      name    = {'-i','--inputDir'},
      dest    = 'inDir',
      default = './',
      action  = 'store',
   }

   cmdlineParser:add_option{ 
      name    = {'-o','--outputDir'},
      dest    = 'outDir',
      default = './',
      action  = 'store',
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

