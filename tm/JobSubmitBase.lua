-- $Id$ --


require("inherits")
require("fileOps")

local M            = {}
local Stencil      = require("Stencil")
local date         = os.date
local format       = string.format
local getenv       = os.getenv
local systemG      = _G

s_jobTypeT = false


function M.name(self)
   return self.my_name
end

function M.tableMerge(t1, t2)
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

function M.Msg(self, result, iTest, numTests, id, resultFn, background)
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

function M.formatMsg(self, result, iTest, passed, failed, numTests, id)
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

function M.findcmd(tbl)
   local abspath = findInPath(tbl.cmd, tbl.path)
   if (abspath == nil) then abspath = "" end
   return abspath 
end

local function findFileInPackagePath(modulename)
  -- Find source
  for path in package.path:gmatch("([^;]+)") do
    local filename = path:gsub("%?", modulename)
    if (isFile(filename)) then
       return filename
    end
  end
  return nil
end


function M.mpr(tbl, envTbl, funcTbl)
   local mprCmd  = funcTbl.batchTbl.mprCmd
   local stencil = Stencil:new{tbl=tbl, envTbl=envTbl, funcTbl=funcTbl}
   
   return stencil:expand(mprCmd)
end


function M.CWD(tbl, envTbl, funcTbl)
   return funcTbl.batchTbl.CurrentWD
end

function M.submit(tbl, envTbl, funcTbl)
   local batchTbl = funcTbl.batchTbl
   local stencil  = Stencil:new{tbl=tbl, envTbl=envTbl, funcTbl=funcTbl}
   return stencil:expand(batchTbl.submitHeader)
end

function M.build(self, name, masterTbl)
   if (not s_jobTypeT) then
      local jobTypeT       = {}
      jobTypeT.INTERACTIVE = require("Interactive")
      jobTypeT.BATCH       = require("Batch")
      s_jobTypeT           = jobTypeT
   end

   local class     = s_jobTypeT[name:upper()] or s_jobTypeT["INTERACTIVE"]
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
            vv = self.tableMerge(vv,v.default)
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

return M
