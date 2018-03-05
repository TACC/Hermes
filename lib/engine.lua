-- -*- lua -*-
if not setfenv then -- Lua 5.2
  -- based on http://lua-users.org/lists/lua-l/2010-06/msg00314.html
  -- this assumes f is a function
  local function findenv(f)
    local level = 1
    repeat
      local name, value = debug.getupvalue(f, level)
      if name == '_ENV' then return level, value end
      level = level + 1
    until name == nil
    return nil end
  getfenv = function (f) return(select(2, findenv(f)) or _G) end
  setfenv = function (f, t)
    local level = findenv(f)
    if level then debug.setupvalue(f, level, t) end
    return f end
end

require("strict")
require("fileOps")
_DEBUG      = false
local dbg   = require("Dbg"):dbg()
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

   -- Load the Hermes.db file from the Hermes Project file: Hermes.db
   local projDir = findDirInDirTree(engine.execDir, masterTbl.projectFn)

   local fn = pathJoin(projDir, masterTbl.projectFn)
   assert(loadfile(fn))()

   masterTbl.HermesVersion = ProjectData.HermesVersion

   local taskDir      = pathJoin(projDir, execName) 
   local taskFileName = pathJoin(taskDir, execName .. ".tasks")

   masterTbl.taskDir = taskDir

   assert(loadfile(taskFileName))()

   engine.buildLuaPath(taskDir,execName)
   require("BaseTask")

   -- count number of '-v' or '--verbose' in argument list

   local verboseCnt = 0
   local debugCnt = 0
   for i,v in ipairs(arg) do
      if (v == '-v' or v == '--verbose') then verboseCnt = verboseCnt + 1 end
      if (v == '-D' or v == '--debug')   then debugCnt   = debugCnt   + 1 end
      
   end

  
   engine.verboseCnt = math.max(verboseCnt, debugCnt)

   Error = ErrorStd
   if (engine.verboseCnt > 0) then
      dbg:activateDebug(engine.verboseCnt) 
   end
   
   dbg.start{"engine()"}
   dbg.start{"engine initial state()", level=2}
   dbg.print{'projDir:      ',projDir,      "\n"}
   dbg.print{'execDir:      ',execDir,      "\n"}
   dbg.print{'execName:     ',execName,     "\n"}
   dbg.print{'taskDir:      ',taskDir,      "\n"}
   dbg.print{'taskFileName: ',taskFileName, "\n"}
   dbg.fini("engine initial state")


   local rtn = taskMain()
   dbg.fini("engine")

   return rtn
end

function engine.verbosityLevel()
   return engine.verboseCnt
end

function findDirInDirTree(wd, fn)
   local masterTbl = masterTbl()
   local cwd       = posix.getcwd()
   local dir       = nil
   local prev      = ""
   posix.chdir(wd)
   while (true) do
      local fullFn = pathJoin(wd,  fn)
      local mystat = posix.stat(fullFn)
      if (mystat and mystat.type == 'regular') then
         dir = wd
         break
      end
      if (wd == '/' or wd == prev) then
         Error("You must be in a project! Did not find: " .. masterTbl.projectFn)
      end
      prev = wd
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
   table.remove(myTable,1)

   dbg.start{"task{",name,"}"}
   require(name)
   local myTask = _G[name]:new(name)

   myTask:execute(myTable)
   dbg.fini()
end
