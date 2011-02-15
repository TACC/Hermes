-- $Id: Wrapper.lua 327 2009-08-24 20:03:46Z eijkhout $ --
require("serialize")
require("fileOps")
Wrapper = BaseTask:new()

function Wrapper:execute(myTable)
   local masterTbl = masterTbl()
   
   assert(loadfile(masterTbl.tdesc))()
   
   
   local cmdA = {}
   cmdA[#cmdA + 1] = "bincomp"
   cmdA[#cmdA + 1] = "-t"
   cmdA[#cmdA + 1] = self:prep(masterTbl.pargs[1])
   cmdA[#cmdA + 1] = "-g"
   cmdA[#cmdA + 1] = self:prep(masterTbl.pargs[2])
   cmdA[#cmdA + 1] = "-r"
   cmdA[#cmdA + 1] = masterTbl.resultFn

   for i,v in ipairs(testdescript.tolerances.vars) do
      cmdA[#cmdA + 1] = v.name .. " " .. v.rel .. " " .. v.abs
   end
 
   local cmdline = table.concat(cmdA," ")
   print ("cmdline:",cmdline)

   masterTbl.status = os.execute(cmdline .. " >& xdrdiff.log")

end

function Wrapper:prep(fn)
   local dir      = dirname(fn)
   local bfn      = barefilename(fn)
   local i,j, fn1 = bfn:find("(.*)%.%d*")
   if (i) then bfn = fn1 end
   i, j, fn1 = fn:find("(.*)%.soln")
   if (i) then bfn = fn1 end
   return pathJoin(dir,bfn)
end
