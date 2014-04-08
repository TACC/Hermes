require("strict")
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

local M             = inheritsFrom(JobSubmitBase)
M.my_name           = "INTERACTIVE"


function M.runtest(self, tbl)
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

function M.queue(tbl)
   return ""
end

return M

