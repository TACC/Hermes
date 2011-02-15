-- $Id: BuildMpprunCmd.lua 239 2008-07-10 00:02:22Z mclay $ --

require("fileOps")
BuildMpprunCmd = BaseTask:new()

function BuildMpprunCmd:execute(myTable)
   local masterTbl = masterTbl()
   local pargs     = masterTbl.pargs

   local machineFile = ' '
   if (masterTbl.hostlist) then
      machineFile = '-machinefile ' .. masterTbl.hostlist .. " "
   end
   
   local cmd    = findInPath(masterTbl.pargs[1])

   if (cmd == nil) then
      ErrorStd("Did not find Command: "..masterTbl.pargs[1])
   end

   local extra  = table.concat(masterTbl.pargs, " ", 2)


   local mprcmd = "mpirun -np " .. masterTbl.np .. machineFile .. cmd .. " " .. extra
   --print (mprcmd)
   os.execute(mprcmd)
end
