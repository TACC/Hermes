
CmdLineOptions = BaseTask:new()

function CmdLineOptions:execute(myTable)
   local masterTbl     = masterTbl()
   local usage         = "mpr [options]"
   local Optiks        = require("Optiks")
   local cmdlineParser = Optiks:new{usage=usage, error = Error}

   cmdlineParser:add_option{ 
      name   = {'-v','--verbose'},
      dest   = 'verbosityLevel',
      action = 'count'
   }

   cmdlineParser:add_option{ 
      name    = {'-n','--np'},
      dest    = 'np',
      action  = 'store',
      type    = 'number',
      default = 1
   }

   cmdlineParser:add_option{ 
      name   = {'--test'},
      dest   = 'test',
      action = 'store_true'
   }

   cmdlineParser:add_option{ 
      name   = {'--wait_done_flag'},
      dest   = 'wait_done',
      action = 'store_true'
   }

   cmdlineParser:add_option{ 
      name   = {'--delete_input_file'},
      dest   = 'del_input',
      action = 'store_true'
   }

   cmdlineParser:add_option{ 
      name    = {'-t','--time'},
      dest    = 'time',
      action  = 'store',
      type    = 'number'
   }

   cmdlineParser:add_option{ 
      name   = {'--qsub', '--batch'},
      dest   = 'batch',
      action = 'store_true'
   }

   cmdlineParser:add_option{ 
      name    = {'-q','--qname', '--queueName' },
      dest    = 'qname',
      action  = 'store'
   }

   cmdlineParser:add_option{ 
      name    = {'--hostlist','--host'},
      dest    = 'hostlist',
      action  = 'store'
   }

   cmdlineParser:add_option{ 
      name    = {'--nodify'},
      dest    = 'nodify',
      action  = 'store'
   }

   local optionTbl, pargs = cmdlineParser:parse(arg)

   for v in pairs(optionTbl) do
      masterTbl[v] = optionTbl[v]
   end

   masterTbl.pargs = pargs
end
