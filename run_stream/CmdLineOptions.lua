-- $Id: CmdLineOptions.lua 204 2008-06-26 23:06:17Z mclay $ --
require("Optiks")
CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()

   local usage         = "Usage: run_stream [options] rack1 rack2 ..."

   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count',
      help   = 'Increasing the level of verbosity help output',
   }


   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end
   masterTbl.pargs = pargs
end
