require("strict")
_G._DEBUG       = false                     -- Required by luaposix 33
local concatTbl = table.concat
local posix     = require("posix")
local function argsPack(...)
   local arg = { n = select("#", ...), ...}
   return arg
end
local pack        = (_VERSION == "Lua 5.1") and argsPack or table.pack
--------------------------------------------------------------------------
-- remove leading and trailing spaces.
-- @param self input string

function string.trim(self)
   local ja = self:find("%S")
   if (ja == nil) then
      return ""
   end
   local  jb = self:find("%s+$") or 0
   return self:sub(ja,jb-1)
end

--------------------------------------------------------------------------
-- An iterator to loop split a pieces.  This code is from the
-- lua-users.org/lists/lua-l/2006-12/msg00414.html
-- @param self input string
-- @param pat pattern to split on.

function string.split(self, pat)
   pat  = pat or "%s+"
   local st, g = 1, self:gmatch("()("..pat..")")
   local function getter(myself, segs, seps, sep, cap1, ...)
      st = sep and seps + #sep
      return myself:sub(segs, (seps or 0) - 1), cap1 or sep, ...
   end
   local function splitter(myself)
      if st then return getter(myself, st, g()) end
   end
   return splitter, self
end

--------------------------------------------------------------------------
-- Join argument into a path that has single slashes between directory
-- names and no trailing slash.
-- @return a file path with single slashes between directory names
-- and no trailing slash.

function pathJoin(...)
   local a = {}
   local arg = pack(...)
   for i = 1, arg.n  do
      local v = arg[i]
      if (v and v ~= '') then
         local vType = type(v)
         if (vType ~= "string") then
            local msg = "bad argument #" .. i .." (string expected, got " .. vType .. " instead)\n"
            assert(vType ~= "string", msg)
         end
      	 v = v:trim()
      	 if (v:sub(1,1) == '/' and i > 1) then
	    if (v:len() > 1) then
	       v = v:sub(2,-1)
	    else
	       v = ''
	    end
      	 end
      	 v = v:gsub('//+','/')
      	 if (v:sub(-1,-1) == '/') then
	    if (v:len() > 1) then
	       v = v:sub(1,-2)
	    elseif (i == 1) then
	       v = '/'
      	    else
	       v = ''
	    end
      	 end
      	 if (v:len() > 0) then
	    a[#a + 1] = v
	 end
      end
   end
   local s = concatTbl(a,"/")
   s = path_regularize(s)
   return s
end
--------------------------------------------------------------------------
-- Remove leading and trail spaces and extra slashes.
-- @param value A path
-- @return A clean canonical path.
function path_regularize(value)
   if value == nil then return nil end
   value = value:gsub("^%s+", "")
   value = value:gsub("%s+$", "")
   value = value:gsub("//+" , "/")
   value = value:gsub("/%./", "/")
   value = value:gsub("/$"  , "")
   if (value == '') then
      value = ' '
      return value
   end
   local t    = {}
   local icnt = 0
   for dir in value:split("/") do
      icnt = icnt + 1
      if (    dir == ".." and icnt > 1) then
         t[#t] = nil
      elseif (dir ~= "."  or icnt == 1) then
         t[#t+1] = dir
      end
   end
   value = concatTbl(t,"/")

   return value
end

--------------------------------------------------------------------------
-- find the absolute path to an executable.
-- @param exec Name of executable
-- @param path The path to use. If nil then use env PATH.
function findInPath(exec, path)
   local result  = "unknown_path_for_" .. (exec or "unknown")
   if ( exec == nil) then return result end
   exec = exec:trim()
   local i = exec:find(" ")
   local cmd  = exec
   local tail = ""
   if (i) then
      cmd  = exec:sub(1,i-1)
      tail = exec:sub(i)
   end

   if (cmd:find("/")) then
      if (posix.access(cmd,"x")) then
         return exec
      else
         return result
      end
   end

   path    = path or os.getenv("PATH")
   for dir in path:split(":") do
      local fullcmd = pathJoin(dir, cmd)
      if (posix.access(fullcmd,"x")) then
         result = fullcmd .. tail
         break
      end
   end
   return result
end

local path = findInPath("FooBar")
print(path)

local path = findInPath("cp")
print(path)
