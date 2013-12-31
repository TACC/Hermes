-- $Id: Finish.lua 287 2008-11-06 18:45:20Z mclay $ --

require("sys")
require("serializeTbl")
require("getUname")
require("fileOps")
require("string_split")
require("string_trim")

local dbg   = require("Dbg"):dbg()
local lfs   = require("lfs")
local posix = require("posix")
local load  = (_VERSION == "Lua 5.1") and loadstring or load

Finish = BaseTask:new()

function Finish.parseInput(self, fn)
   local attr = lfs.attributes(fn)
   if ( not attr or type(attr) ~= "table" or attr.mode ~= "file") then
      return "failed"
   end

   local ext = extname(fn)
   if (ext == "lua") then
      return self:parseLuaResult(fn)
   else
      return self:parseCSVResult(fn)
   end
end

acceptT = { failed = true, passed = true, diff = true } 


function Finish.parseCSVResult(self, fn)
   local result = "passed"
   local f      = io.open(fn,"r")
   local whole  = f:read("*all")
   local found  = false
   f:close()

   for line in whole:split("\n") do
      line        = line:trim()
      local first = line:sub(1,1)
      if (first ~= "#" and line:len() > 0) then
         local word = line
         local idx  = line:find(',')
         if (idx) then
             word = line:sub(1, idx-1)
         end
         word       = word:lower()
         found      = true
         if (word ~= "passed") then
            result = word
            break
         end
      end
   end
   if (not found) then
      result = "failed"
   end
   return acceptT[result] and result or "failed"
end

function Finish.parseLuaResult(self, fn)
   local f      = io.open(cmdResultFn,"r")
   local result = "passed"
   local found  = false
   if (f) then
      local s = f:read("*all")
      assert(load(s))()
      for i,v in ipairs(myTbl) do
         local word  = v.result:lower()
         found       = true
	 if (word ~= "passed") then
            result = word
	 end
      end
   end
   if (not found) then
      result = "failed"
   end
   return acceptT[result] and result or "failed"
end



function Finish.execute(self,myTable)
   local masterTbl = masterTbl()

   ---------------------------------------------------------------
   -- Diff tools write out "result.lua"
   local cmdResultFn = masterTbl.cmdResultFn or masterTbl.pargs[1]
   local resultFn    = masterTbl.resultFn
   local runtimeFn   = masterTbl.runtimeFn
   local result      = self:parseInput(cmdResultFn)

   local myResult = { testresult = result }

   serializeTbl{name="myResult", value=myResult, fn=resultFn, indent=true}

   local t = getUname()

   assert(loadfile(runtimeFn))()
   runtime.end_time = sys.gettimeofday()

   for k in pairs(t) do
      runtime[k] = t[k]
   end

   serializeTbl{name="runtime",  value=runtime,  fn=runtimeFn, indent=true}
end
