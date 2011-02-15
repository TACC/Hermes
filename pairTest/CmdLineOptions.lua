-- $Id$ --
require("Optiks")
CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "Usage: pairTest cmd"

   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count',
      help   = 'Increasing the level of verbosity help output',
   }

   cmdlineParser:add_option{
      name    = {'-s','--step'},
      dest    = 'nStep',
      action  = 'store',
      type    = "number",
      default = -1,
      help    = 'Increasing the level of verbosity help output',
   }



   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end
   masterTbl.pargs = pargs
end
