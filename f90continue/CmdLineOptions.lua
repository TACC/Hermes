-- $Id: CmdLineOptions.lua 204 2008-06-26 23:06:17Z mclay $ --
require("Optiks")
CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "Usage: f90continue [options] *.f *.f90 *.F *.F90"
   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count',
      help   = 'Increasing the level of verbosity help output',
   }

   cmdlineParser:add_option{
      name    = {'-m','--ampersand'},
      dest    = 'column',
      action  = 'store',
      type    = 'number',
      default = 81,
      help    = 'Minimum column where \'&\' will go',
   }


   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end
   masterTbl.pargs = pargs
end
