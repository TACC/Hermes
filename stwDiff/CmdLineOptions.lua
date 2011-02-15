-- $Id: CmdLineOptions.lua 302 2009-02-04 23:56:32Z mclay $ --

CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   require("Optiks")
   lcoal usage = "stwDiff [-v] [-S num] [-r resultFn] -t testSimFile -g goldSimFile -f tdesc"

   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   cmdlineParser:add_option{ 
      name   = {'-t','--testSimFile'},
      dest   = 'testSimFile',
      action = 'store'
   }
   cmdlineParser:add_option{ 
      name   = {'-g','--goldSimFile'},
      dest   = 'goldSimFile',
      action = 'store'
   }
   cmdlineParser:add_option{ 
      name   = {'-f', '--file'},
      dest   = 'tdesc',
      action = 'store'
   }
   cmdlineParser:add_option{ 
      name   = {'-S', '--step'},
      dest   = 'maxSteps',
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

   local optA = {"testSimFile","goldSimFile","tdesc"}

   local r       = true
   local missing = ''
   for i,v in ipairs(optA) do
      if (masterTbl[v] == nil) then
	 r = false
	 missing = missing .. " " .. v
      end
   end
	 
   if (not r) then
      print ("Missing ", missing)
      Error("Usage: ",usage)
   end
end
