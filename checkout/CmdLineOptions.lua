-- $Id: CmdLineOptions.lua 302 2009-02-04 23:56:32Z mclay $ --


CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl = masterTbl()
   local usage     = "checkout --tries num [checkout options]"
   local Optiks    = require("Optiks")

   cmdlineParser = Optiks:new{usage=usage, error = Error}

   checkoutOptions = { 
      { flag = "-A",  varName='resetSticklyTags', action = 'store_true'  },
      { flag = "-N",  varName='CapN',             action = 'store_true'  },
      { flag = "-P",  varName='Prune',            action = 'store_true'  },
      { flag = "-R",  varName='recursiveDir',     action = 'store_true'  },
      { flag = "-c",  varName='cat',              action = 'store_true'  },
      { flag = "-f",  varName='forceHead',        action = 'store_true'  },
      { flag = "-l",  varName='localOnly',        action = 'store_true'  },
      { flag = "-n",  varName='noModuleProgram',  action = 'store_true'  },
      { flag = "-p",  varName='pipe',             action = 'store_true'  },
      { flag = "-s",  varName='moduleStatus',     action = 'store_true'  },
      { flag = "-r",  varName='revision',         action = 'store' 	 },
      { flag = "-D",  varName='date',             action = 'store' 	 },
      { flag = "-d",  varName='directory',        action = 'store' 	 },
      { flag = "-k",  varName='kopts',            action = 'store' 	 },
      { flag = "-j",  varName='mergeList',        action = 'append'	 },
   }

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   cmdlineParser:add_option{ 
      name    = {'--tries'},
      dest    = 'tries',
      action  = 'store',
      type    = 'number',
      default = 3
   }

   cmdlineParser:add_option{ 
      name   = {'--cvs'},
      dest   = 'cvsOptions',
      action = 'store'
   }

   for _,v in ipairs(checkoutOptions) do
      cmdlineParser:add_option{ 
	 name   = {v.flag},
	 dest   = v.varName,
	 action = v.action,
      }
   end

   masterTbl.checkoutOptions = checkoutOptions
   
   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end

   masterTbl.pargs = pargs

   if (#masterTbl.pargs < 1) then
      Error("Usage: ",usage)
   end
end
