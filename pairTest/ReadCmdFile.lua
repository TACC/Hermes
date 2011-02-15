-- $Id$ --
ReadCmdFile = BaseTask:new()

function ReadCmdFile:execute(myTable)
   local masterTbl = masterTbl()
   local cmdFn     = masterTbl.pargs[1]
   
   if (not cmdFn) then return end

   local cmdFile = io.open(cmdFn,"r")

   local s = cmdFile:read("*all")
   assert(loadstring(s))()

   masterTbl.cmd = cmd
end
