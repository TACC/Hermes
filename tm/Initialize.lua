-- $Id: Initialize.lua 340 2010-03-30 20:42:27Z mclay $ --

require("strict")
require("GauntletData")
require("Gauntlet")
require("getUname")
require("dirlist")
require("version")
require("string_split")
require("ignoreDirList")
require("fileOps")

Initialize    = BaseTask:new()
JobSubmitBase = {}

local function  processTag(tagA)
   local masterTbl = masterTbl()

   for i, tag in ipairs(tagA) do
      local ltag = tag:lower()
      if (ltag == 'today') then
	 tag   = ymdString(epoch())
      elseif (ltag == 'yesterday') then
	 tag   = ymdString(epoch()-86400.0)
      end
      tagA[i] = tag
   end

   -----------------------------------------------------------------
   -- if Analyzing or Restarting and no tags (or '*') then
   --   get file names in .span directory.
   --   if no tag specified then use last directory in list
   --   if tag = '*' then get all dirs.

   if ((#tagA < 1 or tagA[1] == '*') and (masterTbl.AnalyzeFlag or #masterTbl.Restart > 0)) then
      local dir = pathJoin(masterTbl.testRptDirRoot, ".span")
      local a   = filelist(dir)
      table.sort(a)
      if (#tagA < 1) then
         tagA[1] = a[#a]
      else
         tagA = {}
         for _,v in ipairs(a) do
            tagA[#tagA+1] = v
         end
      end
   end

   if (#tagA < 1) then
      tagA[1] = ymdString(masterTbl.currentEpoch)
   end

   return tagA, table.concat(tagA," ")
end

function Initialize:execute(myTable)
   local mtblFunc            = masterTbl
   local masterTbl           = masterTbl()
   masterTbl.testRptLoc      = "testreports"
   masterTbl.testRptDirRoot  = pathJoin(masterTbl.projectDir, masterTbl.testRptLoc)
   masterTbl.tstReportFn     = nil
   masterTbl.mtblFunc        = mtblFunc
   masterTbl.testlistFn      = "my.tests"
   masterTbl.targExt         = ".targ"
   masterTbl.testRptExt      = ".tm"
   masterTbl.descriptExt     = ".tdesc"
   masterTbl.TM_Version      = "TM "..Version
   masterTbl.Lua_Version     = _G._VERSION
   masterTbl.errors          = 0
   masterTbl.diffCnt         = 0
   masterTbl.failCnt         = 0
   masterTbl.setparent       = function(k,v) local mtbl = masterTbl.mtblFunc()
                                  mtbl[k] = v
                               end

   JobSubmitBase             = require("JobSubmitBase")   
   ----------------------------------------------------------------------------------
   -- Use user supplied command line epoch if given (default is -1)

   masterTbl.currentEpoch    = epoch()
   if (masterTbl.epoch > 0) then
      masterTbl.currentEpoch = masterTbl.epoch
   end
   masterTbl.origEpoch       = masterTbl.currentEpoch

   masterTbl.tagA, masterTbl.tagString  = processTag(masterTbl.tagA)

   -----------------------------------------------------------------------------------
   -- Add projectDir to package.path for user functions

   package.path = masterTbl.projectDir .. "/?;" .. masterTbl.projectDir .. "/?.lua;" .. package.path

   -- Get os info and store in masterTbl
   local t                = getUname()
   for k in pairs(t) do
      masterTbl[k] = t[k]
   end

   -- Create name for span report
   local currentUUid         = UUIDString(masterTbl.origEpoch) .. "-" ..  masterTbl.os_mach
   masterTbl.tstSpanReportFn = pathJoin(masterTbl.testRptDirRoot, ".span", currentUUid .. masterTbl.testRptExt)

   -- Setup up gauntlet
   masterTbl.gauntlet	  = Gauntlet:new(GauntletData:new())

   local testresultValues = Tst:testresultValues()
   local testresultsTbl   = {}
   if (#masterTbl.statusList == 0) then
      testresultsTbl   = testresultValues
   else
      for _,v in ipairs(masterTbl.statusList) do
         if (v == 'wrong') then
            for k in pairs(testresultValues) do
               if (testresultValues[k] < testresultValues['passed']) then
                  testresultsTbl[k] = 1
               end
            end
         else
            testresultsTbl[v] = 1
         end
      end
   end
   masterTbl.testresultsTbl = testresultsTbl
   Initialize:build_targetA()
   masterTbl.spanning   = masterTbl.AnalyzeFlag or (#masterTbl.Restart > 0) or
                          (#masterTbl.tagA > 1) or (#masterTbl.targetA > 1)
end


function Initialize:build_targetA()
   local masterTbl = masterTbl()
   local mtblFunc  = masterTbl.mtblFunc 
   local targetA   = {}

   masterTbl.targetA = targetA

   for _,v in ipairs(masterTbl.targetList) do
      targetA[#targetA + 1] = v
   end
      
   Initialize:processTargFiles()
   if (#targetA < 1 and not masterTbl.spanning) then
      targetA[1] = os.getenv("TARGET") or os.getenv("TARG_SUMMARY") or ""
   end
end

function Initialize:processTargFiles()
   local masterTbl = masterTbl()
   local pargs     = {}
   local pattern   = '%' .. masterTbl.targExt .. "$"
   
   for _,item in ipairs(masterTbl.pargs) do
      if (item:find(pattern)) then
         Initialize:readTargFile(item)
      else
         pargs[#pargs + 1] = item
      end
   end
   masterTbl.pargs = pargs
end

function Initialize:readTargFile(fn)
   local masterTbl = masterTbl()
   local f         = assert(io.open(fn,"r"))
   local s         = f:read("*all")
   local t         = {}

   for line in s:split("\n") do
      local i = line:find('#')
      if (i) then
         line = line:sub(1,i-1)
      end
      if (not line:find('^%s*$')) then
         t[#t + 1] = line
      end
   end

   s = table.concat(t,"\n")

   t = {}
   for item in s:split("%s+") do
      t[item] = 1
   end

   local tt = {}
   for k in pairs(t) do
      tt[#tt + 1] = k
   end
   table.sort(tt)

   local targetA = masterTbl.targetA
   for _,v in ipairs(tt) do
      targetA[#targetA + 1] = v
   end
   f:close()
end
