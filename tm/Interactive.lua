-- $Id: Default.lua 322 2009-03-27 23:06:59Z eijkhout $ --
require("inherits")
local assert        = assert
local concatTbl     = table.concat
local date          = os.date
local execute       = os.execute
local findInPath    = findInPath
local format        = string.format
local loadfile      = loadfile
local print         = print
local systemG       = _G

INTERACTIVE         = inheritsFrom(JobSubmitBase)
INTERACTIVE.my_name = "INTERACTIVE"

module("INTERACTIVE")

function runtest(self, tbl)
   local  t = {}
   t[#t + 1]  = "./" .. tbl.scriptFn
   t[#t + 1]  = "2>&1"
   t[#t + 1]  = ">"
   t[#t + 1]  = tbl.idTag .. ".log"
   if (tbl.background) then
      t[#t + 1]  = "</dev/null &"
   end

   local s = concatTbl(t," ")
   execute(s)
end

function queue(tbl)
   return ""
end

