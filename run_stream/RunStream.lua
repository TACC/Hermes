local posix = require("posix")
RunStream   = BaseTask:new()

function RunStream:execute(myTable)
   local masterTbl     = masterTbl()

   for _,rack in ipairs(masterTbl.pargs) do
      local fn      = os.tmpname()
      local fn_targ = fn .. ".targ"
      local f = assert(io.open(fn_targ,"w"))
      for j = 1, 4 do
         for i = 1, 12 do
            local node = string.format("i%s-%d%02d",rack,j,i)
            f:write(node,"\n")
         end
      end
      f:close()
      local cmd = "tm --tag " .. rack .. " " .. fn_targ .. " ."
      print (cmd)
      os.execute(cmd)
      os.remove(fn)
      os.remove(fn_targ)
   end
end
