-- $Id: engine.lua 337 2010-02-24 21:43:36Z mclay $ --
-- -*- lua -*-
require("strict")
require("fileOps")
local Dbg   = require("Dbg")
local posix = require("posix")

Error  = nil
engine = {}
master = {
   projectFn  = "Hermes.db",
}
function ErrorStd(...)
   ErrorDbg(...)
   os.exit(1)
end

function fixFileName(name)
   name = name:gsub("[ &'\"!()[@#]","_")
   name = name:gsub("]","_")
   return name
end


function ErrorDbg(...)
   io.stderr:write("\nError: ")
   for _,v in ipairs{...} do
      io.stderr:write(v)
   end
   io.stderr:write("\n")
end

function engine.buildLuaPath(taskDir, execName)
   local luaPathTbl = {}
   table.insert(luaPathTbl, pathJoin(taskDir, "?" ))
   table.insert(luaPathTbl, pathJoin(taskDir, "?.lua"))
   table.insert(luaPathTbl, "?.lua;?")
   table.insert(luaPathTbl, package.path)
   package.path = table.concat(luaPathTbl,";")
end

function engine.splitCmdName(path)
   return splitFileName(path)
end

function engine.execute(execDir, execName)
   engine.execDir   = execDir
   engine.execName  = execName
   local masterTbl  = masterTbl()
   local dbg        = Dbg:dbg()

   -- Load the Hermes.db file from the Hermes Project file: Hermes.db
   local projDir = findDirInDirTree(engine.execDir, masterTbl.projectFn)

   local fn = pathJoin(projDir, masterTbl.projectFn)
   assert(loadfile(fn))()

   masterTbl.HermesVersion = ProjectData.HermesVersion

   local taskDir      = pathJoin(projDir, execName) 
   local taskFileName = pathJoin(taskDir, execName .. ".tasks")

   masterTbl.taskDir = taskDir

   --print ('projDir:',projDir)
   --print ('execDir:',execDir)
   --print ('execName:',execName)
   --print ('taskDir:',taskDir)
   --print ('taskFileName:',taskFileName)
   assert(loadfile(taskFileName))()

   engine.buildLuaPath(taskDir,execName)
   require("BaseTask")

   -- count number of '-v' or '--verbose' in argument list

   local verboseCnt = 0
   for i,v in ipairs(arg) do
      if (v == '-v' or v == '--verbose') then verboseCnt = verboseCnt + 1 end
   end

  
   engine.verboseCnt = verboseCnt

   Error = ErrorStd
   if (verboseCnt > 0) then
      Error = ErrorDbg
   end
   if (engine.verboseCnt > 1) then  dbg:activateDebug() end
   
   dbg.start("engine")
   local rtn = taskMain()
   dbg.fini()

   return rtn
end

function engine.verbosityLevel()
   return engine.verboseCnt
end

function findDirInDirTree(wd, fn)
   local masterTbl = masterTbl()
   local cwd       = posix.getcwd()
   local dir       = nil

   posix.chdir(wd)
   while (true) do
      local fullFn = pathJoin(wd,  fn)
      local mystat = posix.stat(fullFn)
      if (mystat and mystat.type == 'regular') then
         dir = wd
         break
      end
      if (wd == '/') then
         Error("You must be in a project! Did not find: " .. masterTbl.projectFn)
      end
      posix.chdir("..")
      wd  = posix.getcwd()
   end

   posix.chdir(cwd)
   return dir
end

function masterTbl()
   return master
end

function task(myTable)
   local name = myTable[1]
   local dbg  = Dbg:dbg()
   table.remove(myTable,1)

   dbg.start("task{",name,"}")
   require(name)
   local myTask = _G[name]:new(name)

   myTask:execute(myTable)
   dbg.fini()
end
