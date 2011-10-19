local lfs = require("lfs")
require("fileOps")
SymlinkInputFiles = BaseTask:new()

function SymlinkInputFiles:execute(myTable)
   local masterTbl     = masterTbl()

   if (masterTbl.pargs[1] == nil) then
      return
   end

   local inDir   = masterTbl.inDir
   local outDir  = masterTbl.outDir
   local simTbl  = masterTbl.simTbl

   for key in pairs(simTbl) do
      if (simTbl[key].kind == 'input') then
	 local fn = pathJoin(inDir, simTbl[key].name)
	 local attr = lfs.attributes(fn)
	 if (attr and attr.mode == "file") then
	    local cmd = "ln -sf " .. fn .. " " .. outDir
	    os.execute(cmd)
	 end
      end
   end
end
