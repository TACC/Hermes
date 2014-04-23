require("strict")
local posix = require("posix")
function getUname()
   local t                = {}
   local osName		  = posix.uname("%s")
   local machName	  = posix.uname("%m")
   osName		  = string.gsub(osName,"[ /]","_")
   if (string.lower(osName) == "aix") then
      machName = "rs6k"
   elseif (osName:lower():sub(1,4) == "irix") then
      osName   = "Irix"
      machName = "mips"
   end
   t.osName    = osName
   t.machName  = machName
   t.hostName  = posix.uname("%n")
   t.os_mach   = osName .. '-' .. machName
   t.target    = os.getenv("TARGET") or ""

   return t
end
