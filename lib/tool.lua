#!/usr/bin/env lua
-- -*- lua -*-
function tool()
   require ("engine")

   table.remove(arg,1)

   local execDir, execName = engine.splitCmdName(arg[0])
   
   return engine.execute(execDir, execName)
end

os.exit(tool())

