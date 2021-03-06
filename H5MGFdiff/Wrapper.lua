require("strict")
require("serializeTbl")
require("fileOps")
Wrapper = BaseTask:new()

function Wrapper:execute(myTable)
   local masterTbl = masterTbl()
   
   assert(loadfile(masterTbl.tdesc))()
   
   
   local cmdA = {}
   cmdA[#cmdA + 1] = "compMGF"
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

   masterTbl.status = os.execute(cmdline .. " > H5MGFdiff.log 2>&1")

end

function Wrapper:prep(fn)
   local dir      = dirname(fn)
   local bfn      = barefilename(fn)
   local i,j, fn1 = bfn:find("(.*)_%d_soln.h5")
   if (i) then bfn = fn1 end
   return pathJoin(dir,bfn)
end
