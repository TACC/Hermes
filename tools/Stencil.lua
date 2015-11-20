------------------------------------------------------------------------
--
--  Copyright (C) 2008-2014 Robert McLay
--
--  Permission is hereby granted, free of charge, to any person obtaining
--  a copy of this software and associated documentation files (the
--  "Software"), to deal in the Software without restriction, including
--  without limitation the rights to use, copy, modify, merge, publish,
--  distribute, sublicense, and/or sell copies of the Software, and to
--  permit persons to whom the Software is furnished to do so, subject
--  to the following conditions:
--
--  The above copyright notice and this permission notice shall be
--  included in all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
--  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
--  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
--  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
--  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
--  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
--  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.
--
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Stencil:  This class takes several kinds of tables and a string with
--           with $(<keys>) in it.  The expand function uses the tables to
--           replace the keys with values from the tables.

require("strict")
require("string_utils")
local concatTbl = table.concat
local dbg       = require("Dbg"):dbg()
local M         = {}     

function M.new(self, t)
   local tbl = t
   local o = {}

   setmetatable(o, self)
   self.__index  = self

   o.__tbl   = t.tbl     or {}
   o.__envT  = t.envTbl  or {}
   o.__funcT = t.funcTbl or {}
   return o
end

local function findCmd(s)
   local ja, jb = s:find("%$%(")
   if (ja == nil) then
      return nil, nil
   end 
   local idx    = 1
   local q      = ""
   local iparen = 1
   idx = jb + 1
   
   while(true) do
      local jc, jd = s:find("[()]",idx)
      if (jc == nil) then Error("unequal number of parens") end

      local c = s:sub(jc,jd)

      if ( c == "(") then iparen = iparen + 1 end
      if ( c == ")") then
         iparen = iparen - 1
         if (iparen == 0) then
            return ja, jd
         end
      end
      idx = jd + 1
   end
end

local function assignOneArg(s,tbl)
   local ja = s:find("=")
   if (ja == nil) then
      tbl[#tbl + 1] = s:trim()
   else
      local key   = s:sub(1,ja-1):trim()
      local value = s:sub(ja+1,-1)
      tbl[key]    = value
   end 
   return tbl
end

local function findKeyArgs(sIn)
   local tbl = {}
   local s   = sIn:trim()
   local ja  = s:find("%s")
   if (ja == nil) then
      return s, tbl
   end 
   local key = s:sub(1,ja-1)

   s = s:sub(ja,-1)

   local srchlist = '[' .. "'" .. '"' .. ',' .. ']'

   local ss
   local r    = {}
   local q    = nil
   local qIdx = nil
   local idx  = 1
   while (true) do
      ja = s:find(srchlist,idx)
      if (ja == nil) then
         r[#r + 1] = s:sub(idx, -1)
         ss        = concatTbl(r,"")
         tbl = assignOneArg(ss,tbl)
         break
      end

      local c   = s:sub(ja,ja)

      if (c == '"' or c == "'") then
         if (q == nil) then
            r[#r + 1] = s:sub(idx, ja - 1)
            qIdx = ja 
            q    = c
         elseif (c == q) then
            r[#r + 1] = s:sub(qIdx+1, ja - 1)
            qIdx      = nil
            q         = nil
         end
      elseif ( c == ',' and q == nil) then
         r[#r + 1] = s:sub(idx, ja - 1)
         ss  = concatTbl(r,"")
         tbl = assignOneArg(ss,tbl)
         r   = {}
      else
         r[#r + 1] = s:sub(idx, ja - 1)
      end
      idx = ja + 1
   end

   return key, tbl
end

function M.expand(self, s)
   local result = ''
   local tbl     = self.__tbl
   local envTbl  = self.__envT
   local funcTbl = self.__funcT
   local a       = {}

   while (true) do
      local ja, jb = findCmd(s)
      if (ja == nil) then 
         a[#a+1] = s
	 break 
      end
      a[#a+1]        = s:sub(1, ja-1)
      local q        = s:sub(ja+2, jb-1)
      local key,args = findKeyArgs(self:expand(q))
      local v        = ''
      if (funcTbl[key] ~= nil) then
         v = funcTbl[key](args, envTbl, funcTbl)
      else
         v           = tbl[key] or envTbl[key] or os.getenv(key)
         if ((not v)) then
            local entry = funcTbl.batchTbl[key]
            if (type(entry) == "function") then
               v = entry(args, envTbl, funcTbl)
            else
               v = entry
            end
         end
      end
      if (v == nil) then Error("No replacement value for key: \""..key.."\" found") end
      s              = v .. s:sub(jb+1,-1)
   end
   return concatTbl(a,"")
end

return M
