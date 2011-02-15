-- $Id$ --

JobSubmitBase = {}


require("inherits")
JobSubmitBase = inheritsFrom(nil)
require("Interactive")
require("Batch")
require("fileOps")

local BATCH        = BATCH
local Error        = Error
local INTERACTIVE  = INTERACTIVE
local assert       = assert
local date         = os.date
local expand       = expand
local format       = string.format
local io           = io
local isFile       = isFile
local getenv       = os.getenv
local getmetatable = getmetatable
local inheritsFrom = inheritsFrom
local loadfile     = loadfile
local package      = package
local pairs        = pairs
local print        = print
local string       = string
local systemG      = _G
local type         = type

local factoryT = {
   INTERACTIVE = INTERACTIVE,
   BATCH       = BATCH
}


module ("JobSubmitBase")

function name(self)
   return self.my_name
end

function tableMerge(t1, t2)
   for k,v in pairs(t2) do
      if (type(v) == "table") then
         if (type(t1[k] or false) == "table") then
            tableMerge(t1[k] or {}, t2[k] or {})
         else
            if (t1[k] == nil) then
               t1[k] = v
            end
         end
      else
         if (t1[k] == nil) then
            t1[k] = v
         end
      end
   end
   return t1
end

function Msg(self, result, iTest, numTests, id, resultFn, background)
   local masterTbl	= self.masterTbl
   
   if (result == "Started") then
      print(self.formatMsg(self, result, iTest, masterTbl.passed, masterTbl.failed, numTests, id))
   elseif (not background) then
      assert(loadfile(resultFn))()
      local myResult = systemG.myResult.testresult
      if (myResult == "passed") then
         masterTbl.passed = masterTbl.passed + 1
      else
         masterTbl.failed = masterTbl.failed + 1
      end
      
      print(self.formatMsg(self, myResult, iTest, masterTbl.passed, masterTbl.failed, numTests, id),"\n")
   end
end

function formatMsg(self, result, iTest, passed, failed, numTests, id)
   local blank    = " "
   local r        = result or "failed"
   local blankLen = self.resultMaxLen - r:len()
   local msg      = format("%s%s : %s tst: %d/%d P/F: %d:%d, %s",
                           blank:rep(blankLen),
                           result,
                           date("%X"),
                           iTest, numTests,
                           passed, failed,
                           id)
   return msg
end

function findcmd(tbl)
   local abspath = findInPath(tbl.cmd, tbl.path)
   if (abspath == nil) then abspath = "" end
   return abspath 
end

local function findFileInPackagePath(modulename)
  -- Find source
  for path in string.gmatch(package.path, "([^;]+)") do
    local filename = string.gsub(path, "%?", modulename)
    if (isFile(filename)) then
       return filename
    end
  end
  return nil
end


function mpr(tbl, envTbl, funcTbl)
   local mprCmd = funcTbl.batchTbl.mprCmd
   return expand(mprCmd, tbl, envTbl, funcTbl)
end


function CWD(tbl, envTbl, funcTbl)
   return funcTbl.batchTbl.CurrentWD
end

function submit(tbl, envTbl, funcTbl)
   local batchTbl = funcTbl.batchTbl
   return expand(batchTbl.submitHeader, tbl, envTbl, funcTbl)
end

function build(self, name, masterTbl)
   local class     = factoryT[name:upper()]
   local o         = class:create()

   o.masterTbl     = masterTbl
   o.resultMaxLen  = masterTbl.resultMaxLen
   o.batchHostNm   = getenv("BATCH_HOSTNAME") or "unknown"
   o.style         = name:upper()

   assert(loadfile(findFileInPackagePath("BatchSystemDefault.lua")))()
   local batchDefault = systemG.BatchSystems
   assert(loadfile(findFileInPackagePath("BatchSystem.lua")))()
   local batchTbl     = systemG.BatchSystems

   batchTbl.INTERACTIVE         = {}
   batchTbl.INTERACTIVE.default = {}

   for k,v in pairs(batchDefault) do
      if (type (batchTbl[k]) == "table") then
         for kk, vv in pairs(batchTbl[k]) do
            vv = tableMerge(vv,v.default)
         end
      end
   end

   if (o.style == "INTERACTIVE") then
      o.batchTbl = batchTbl.INTERACTIVE.default
   else
      local host = o.batchHostNm
      for k,v in pairs(batchTbl) do
         if (type(v) == "table") then
            for kk, vv in pairs(v) do
               if (kk == host) then
                  o.batchTbl = vv
                  break
               end
            end
         end
         if (o.batchTbl) then break end
      end
   end

   if (o.batchTbl == nil) then
      Error("Unable to find BatchSystems entry for ",o.batchHostNm)
   end
                  
   return o
end
