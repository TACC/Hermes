-- $Id$ --
ReadCmdFile = BaseTask:new()

local load = (_VERSION == "Lua 5.1") and loadstring or load
function ReadCmdFile:execute(myTable)
   local masterTbl = masterTbl()
   local cmdFn     = masterTbl.pargs[1]
   
   if (not cmdFn) then return end

   local cmdFile = io.open(cmdFn,"r")

   local s = cmdFile:read("*all")
   assert(load(s))()

   masterTbl.cmd = cmd
end
