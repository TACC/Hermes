-- $Id: common.lua 353 2011-02-01 21:09:25Z mclay $ --

require("string_utils")
require("posix")
require("fileOps")

local function findCmd(s,i)

   local i = 1
   local ja, jb = s:find("%$%(",i)
   if (ja == nil) then
      return nil, nil
   end 
   local q      = ""
   local iparen = 1
   i = jb + 1
   
   while(true) do
      local jc, jd = s:find("[()]",i)
      if (jc == nil) then Error("unequal number of parens") end

      local c = s:sub(jc,jd)

      if ( c == "(") then iparen = iparen + 1 end
      if ( c == ")") then
         iparen = iparen - 1
         if (iparen == 0) then
            return ja, jd
         end
      end
      i = jd + 1
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
   --io.stderr:write("findKeyArgs(s:",sIn,")\n")
   -- Remove leading spaces
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
   local i    = 1
   while (true) do
      ja = s:find(srchlist,i)
      if (ja == nil) then
         r[#r + 1] = s:sub(i, -1)
         ss        = table.concat(r,"")
         tbl = assignOneArg(ss,tbl)
         break
      end

      local c   = s:sub(ja,ja)

      if (c == '"' or c == "'") then
         if (q == nil) then
            r[#r + 1] = s:sub(i, ja - 1)
            qIdx = ja 
            q    = c
         elseif (c == q) then
            r[#r + 1] = s:sub(qIdx+1, ja - 1)
            qIdx      = nil
            q         = nil
         end
      elseif ( c == ',' and q == nil) then
         r[#r + 1] = s:sub(i, ja - 1)
         ss  = table.concat(r,"")
         tbl = assignOneArg(ss,tbl)
         r   = {}
      else
         r[#r + 1] = s:sub(i, ja - 1)
      end
      i         = ja + 1
   end

   --io.stderr:write("findKeyArgs: key: ",key,"\n")
   --for k in pairs(tbl) do
   --   io.stderr:write("  tbl.",k,": ",tbl[k],"\n")
   --end

   return key, tbl
end

function expand(s, tbl, envTbl, funcTbl)
   --io.stderr:write("expand(s:",s,")\n")
   local result = ''
   local i = 1
   while (true) do
      local ja, jb = findCmd(s,i)
      if (ja == nil) then 
	 result = result .. s:sub(i, -1)
	 break 
      end
      result         = result .. s:sub(i, ja-1)
      local q        = s:sub(ja+2, jb-1)
      local key,args = findKeyArgs(expand(q,tbl,envTbl,funcTbl))
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
      s              = result .. v .. s:sub(jb+1,-1)
      i              = ja
   end
   --io.stderr:write("expand rtn: ",result,"\n")
   return result
end




function buildTestReportTable(HumanData, masterTbl)
   local testresults = {
      HumanData	     = HumanData,
      date	     = masterTbl.date,
      currentUUid    = masterTbl.currentUUid,
      origUUid	     = masterTbl.origUUid,
      currentEpoch   = masterTbl.currentEpoch,
      origEpoch	     = masterTbl.origEpoch,
      machType	     = masterTbl.os_mach,
      hostname	     = masterTbl.hostname,
      Targ	     = masterTbl.targ,
      target	     = masterTbl.target,
      TotalTestTime  = masterTbl.totalTestTime,
      TM_Version     = masterTbl.TM_Version,
      Hermes_Version = masterTbl.HermesVersion,
      tag            = masterTbl.tag,
      ntimes         = masterTbl.ntimes,
      Lua_Version    = _G._VERSION,
      tests	     = {},
   }

   local testfields = Tst:testfields()

   for id in hash.pairs(masterTbl.rptTbl) do
      local tst	     = masterTbl.rptTbl[id]
      local testData = {}
      for i,v in ipairs(testfields) do
	 testData[v] = tst:get(v)
      end
      table.insert(testresults.tests,testData)
   end
   return testresults

end

function fullFn(f)
   return fixFileName(pathJoin(masterTbl().projectDir, f))
end

