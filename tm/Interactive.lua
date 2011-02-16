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
   local  a = {}
   a[#a + 1]  = "./" .. tbl.scriptFn
   a[#a + 1]  = ">"
   a[#a + 1]  = tbl.idTag .. ".log"
   a[#a + 1]  = "2>&1"
   if (tbl.background) then
      a[#a + 1]  = "</dev/null &"
   end

   local s = concatTbl(a," ")
   execute(s)
end

function queue(tbl)
   return ""
end

