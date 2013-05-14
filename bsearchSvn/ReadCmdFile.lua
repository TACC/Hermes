-- $Id$ --
ReadCmdFile = BaseTask:new()
local load  = (_VERSION == "Lua 5.1") and loadstring or load
function ReadCmdFile:execute(myTable)
   local masterTbl = masterTbl()
   local cmdFile   = io.open(masterTbl.pargs[1],"r")

   

   if (not cmdFile) then 
      return
   end

   local s = cmdFile:read("*all")
   assert(load(s))()

   masterTbl.cmd = cmd
end
