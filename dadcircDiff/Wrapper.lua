-- $Id: Wrapper.lua 194 2008-06-25 21:43:50Z mclay $ --

Wrapper = BaseTask:new()

function Wrapper:execute(myTable)
   local masterTbl = masterTbl()
   
   assert(loadfile(masterTbl.tdesc))()
   
   cmdline = "adccmp -r "

   local optA  = {"resultFn", "goldDir", "testDir"}

   for i,v in ipairs(optA) do
      cmdline = cmdline .. " " .. masterTbl[v]
   end

   for i,v in ipairs(testdescript.tolerances.vars) do
      cmdline = cmdline .. " " .. v.name .. " " .. v.rel .. " " .. v.abs
   end

   local status = os.execute(cmdline .. " > diff.log")
   masterTbl.status = status
end
