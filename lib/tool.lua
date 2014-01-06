#!/usr/bin/env lua
-- -*- lua -*-
function tool()
   require ("engine")

   table.remove(arg,1)

   local execDir, execName = engine.splitCmdName(arg[0])
   
   return engine.execute(execDir, execName)
end

local rtn = tool()

if (rtn ~= 0) then
   os.exit(rtn)
end
