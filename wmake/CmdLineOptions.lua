-- $Id: CmdLineOptions.lua 302 2009-02-04 23:56:32Z mclay $ --
require("Optiks")
require("string_split")
CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "wmake [options]"
   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count',
      help   = "Report Engine Performance with increasing verbosity",
   }

   cmdlineParser:add_option{ 
      name   = {'-o','--opt'},
      dest   = 'optFlag',
      action = 'store_true',
      help   = "Compile in optimized mode",
   }

   cmdlineParser:add_option{ 
      name   = {'-d','--dbg'},
      dest   = 'dbgFlag',
      action = 'store_true',
      help   = "Compile in debug mode",
   }

   cmdlineParser:add_option{ 
      name   = {'-t','--target'},
      dest   = 'targetList',
      action = 'append',
      help   = "list of target options",
   }

   cmdlineParser:add_option{ 
      name   = {'--show'},
      dest   = 'show',
      action = 'store_true',
      help   = "print but not execute make",
   }

   cmdlineParser:add_option{ 
      name   = {'-m','--max'},
      dest   = 'maxFlag',
      action = 'store_true',
      help   = "Compile in max debug mode",
   }

   cmdlineParser:add_option{ 
      name    = {'-c','--compilier'},
      dest    = 'compiler',
      action  = 'store',
      help    = "Set compiler to be name given",
   }

   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end

   local targetA = {}
   local targetList = masterTbl.targetList

   for _,v in ipairs(targetList) do
      for s in v:split("[ :,]") do
         s = s:trim()
         if (s ~= "") then
            targetA[#targetA + 1] = s
         end
      end
   end

   local t = {dbgFlag='dbg', optFlag='opt', maxFlag='mdbg',}

   for k in pairs(t) do
      if (masterTbl[k]) then
         targetA[#targetA+1] = t[k]
      end
   end

   for _,v in ipairs(targetA) do
      print(v)
   end


   masterTbl.targetA = targetA
   masterTbl.pargs   = pargs
end
