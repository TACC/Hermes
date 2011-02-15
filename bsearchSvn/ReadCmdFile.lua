-- $Id$ --
ReadCmdFile = BaseTask:new()

function ReadCmdFile:execute(myTable)
   local masterTbl = masterTbl()
   local cmdFile   = io.open(masterTbl.pargs[1],"r")

   

   if (not cmdFile) then 
      return
   end

   local s = cmdFile:read("*all")
   assert(loadstring(s))()

   masterTbl.cmd = cmd
end
