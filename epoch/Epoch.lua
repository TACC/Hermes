-- $Id: CmdLineOptions.lua 149 2008-06-23 18:42:11Z mclay $ --
require("string_utils")
require("sys")

Epoch = BaseTask:new()

function Epoch:execute(myTable)
   local masterTbl     = masterTbl()
   local epoch         = sys.gettimeofday()
   print (epoch)
end
