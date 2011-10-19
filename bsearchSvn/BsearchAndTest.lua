-- $Id$ --
BsearchAndTest = BaseTask:new()

require("fileOps")
local lfs = require("lfs")

local function testRev(rev, cmd)
   local cwd  = lfs.currentdir()
   local name = cmd.name .. "_" .. tostring(rev)
   local s    = "svn co -r " .. rev .. " " .. cmd.repo .. " " .. name
   io.stdout:write(s,"\n"); io.stdout:flush()
   os.execute(s)
   lfs.chdir(name)
   io.stdout:write(cmd.build,"\n"); io.stdout:flush()
   os.execute(cmd.build,"\n")
   io.stdout:write(cmd.testCmd); io.stdout:flush()
   local status = os.execute(cmd.testCmd)
   io.stdout:write("status: ",tostring(status),"\n"); io.stdout:flush()
   lfs.chdir(cwd)
   return status
end



function BsearchAndTest:execute(myTable)
   local masterTbl = masterTbl()
   local cmd       = masterTbl.cmd

   if (not cmd) then
      masterTbl.status = 1
      return
   end

   local low  = cmd.startRev
   local high = cmd.endRev
   local rev 

   while (low <= high) do
      local mid    = math.floor((low + high) / 2)
      local status = testRev(mid, cmd)
      if (status == 0) then
         rev  = mid
         low  = mid + 1
      else
         high = mid - 1
      end
   end

   io.stdout:write("rev: ",tostring(rev),"\n")
end

