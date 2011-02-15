-- $Id: CmdLineOptions.lua 204 2008-06-26 23:06:17Z mclay $ --
require("string_split")

F90Continue = BaseTask:new()

function F90Continue:execute(myTable)
   local masterTbl     = masterTbl()

   for _,fn in ipairs(masterTbl.pargs) do
      local status = F90Continue:moveMarker(fn)
      if (status) then
         os.rename(fn, fn .. "~")
         os.rename(fn..".new", fn)
      end
   end
end

function F90Continue:moveMarker(fn)
   local masterTbl = masterTbl()
   local f         = assert(io.open(fn))
   local whole     = f:read("*all")
   local column    = masterTbl.column
   f:close()

   local lineA = {}

   local b = nil
   local e = nil

   for l in whole:split("\n") do
      local i,j = l:find("&%s*$")
      if (not i or i == column) then
         if (b) then
            e = #lineA
            F90Continue:lineUp(lineA,b,e)
            b = nil
         end
         lineA[#lineA+1] = l
      else
         if (not b) then b = #lineA + 1 end
         l           = l:sub(1,i-1)
         local  jb   = l:find("%s+$") or 0
         l           = l:sub(1,jb-1)
         local count = column - l:len() - 1
         if (count < 0 ) then
            count = 2
         end
         lineA[#lineA+1] = l .. string.rep(" ",count) .. "&"
      end
   end

   whole = table.concat(lineA,"\n")
   f = assert(io.open(fn .. ".new", "w"))
   f:write(whole)
   f:close()
   return true
end

function F90Continue:lineUp(lineA, b, e)
   local masterTbl = masterTbl()
   local column    = masterTbl.column
   local mcolumn   = 0
   for c = b, e do
      local l = lineA[c]
      mcolumn = math.max(mcolumn, l:find("&"))
   end

   if (mcolumn <= column) then return end

   for c = b, e do
      local l     = lineA[c]
      local i     = l:find("&") 
      local count = mcolumn - i
      lineA[c]    = l:sub(1,i-1) ..  string.rep(" ",count) .. "&"
   end
end
