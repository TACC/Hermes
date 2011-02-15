-- $Id: Tst.lua 345 2010-09-28 22:29:58Z mclay $ --
require("fileOps")
require("string_split")

Tst = {}

function buildTstTbl(fileName, testdescript, target, epoch, ntimes)
   local tstTbl = {}

   Tst:initFmt(ntimes)

   for _,v in ipairs(testdescript.tests) do
      for i = 1, ntimes do
         local tst  = Tst:new(v, fileName, testdescript, target, epoch, i)
         local id   = tst:get('id')
         tstTbl[id] = tst
      end
   end
   return tstTbl
end


function Tst:initFmt(ntimes)
   local fmt = nil
   if (ntimes > 1) then
      local numplaces = math.floor(math.log10(ntimes)) + 1
      fmt             = "_%0" .. tostring(numplaces) .. "d"
   end
   self.fmt = fmt
end


function Tst.new(self, testparams, fileName, testdescript, target, epoch, i)
   local o = {}
   setmetatable(o,self)
   self.__index = self

   local masterTbl = masterTbl()

   masterTbl.date = os.date("%c", masterTbl.currentEpoch)

   local projectDir   = masterTbl.projectDir
   local pattern      = projectDir:gsub("%-","%%-")
   pattern            = pattern:gsub("%.","%%.")
   pattern            = "^"..  pattern .. "/"  .. "(.*)%.tdesc$"

   local _, _, baseId = fileName:find(pattern )
   local _, _, tstDir = baseId:find("^(.*)/")

   if (tstDir == nil) then tstDir = "./" end

   local extra = ''
   if (self.fmt) then
      extra = string.format(self.fmt,i)
   end
   local id            = testparams.id .. extra

   o.testdescript      = testdescript
   o.test              = testparams
   o.id                = pathJoin(baseId, id)
   o.idTag             = id
   o.start_epoch       = -1
   o.runtime           = -1
   o.job_submit_method = o.testdescript.job_submit_method or false
   o.strRuntime        = "***"
   o.result            = 'notrun'
   o.active            = 1
   o.epoch             = epoch
   o.report            = false
   o.testDir           = tstDir
   o.testdescriptFn    = baseId .. ".tdesc"
   o.testName          = o.testdescript.testName
   o.packageName       = masterTbl.packageName
   o.packageDir        = masterTbl.packageDir
   o.tag               = masterTbl.tag
   o.parentDir         = pathJoin(o.testDir,o.idTag)
   o.ProgVersion       = ''
   o.message           = ''
   o.osName            = ''
   o.machName          = ''
   o.hostName          = ''
   o.os_mach           = ''
   o.target            = target
   o.TARGET            = target
   o.start_time        = 0
   o.end_time          = 0
   o.background        = testdescript.background or false
   o.at_top_of_script  = testdescript.topOfScript or
[[#!/bin/sh
# -*- shell-script -*-
]]


   local i, j = o.testName:find('[ ?/*"\']')
   if (i) then
      Error("Test Name: \"",o.testName,"\" has an illegal character: '",o.testName:sub(i,j),"'",
         "\nIllegal characters are: \" ?/*\" and the quote characters: ' and '\"'")
   end

   o:setup_outputDir(epoch,target)

   if (o.testdescript.active ~= nil) then
      o.active = o.testdescript.active
      if (o.active == 0) then o.active = false end
   end

   o.keywords         = {}

   for _,key in ipairs(o.testdescript.keywords) do
      o.keywords[key] = 1
   end

   o.np = 1
   if (o.test.np) then o.np = o.test.np end
   return o
end

function Tst.topOfScript(self)
   return self.at_top_of_script
end

function Tst.setup_outputDir(self,epoch, target)
   local masterTbl       = masterTbl()
   local prefix          = ''
   if (target and target:len() > 0) then
      prefix = target .. "-"
   end
   

   local UUid            = prefix .. UUIDString(epoch) .. "-" ..  masterTbl.os_mach
   self.UUid             = UUid
   self.outputDir        = pathJoin(self.parentDir,UUid .. '-' .. self.testName)
   self.resultFn         = pathJoin(self.outputDir,self.idTag .. ".result")
   self.runtimeFn        = pathJoin(self.outputDir,self.idTag .. ".runtime")
   self.cmdResultFn      = pathJoin(self.outputDir, "results.lua")
   self.versionFn        = pathJoin(self.outputDir, "version.lua")
   self.messageFn        = pathJoin(self.outputDir, "message.lua")
end

function Tst.expandRunScript(self, envTbl, funcTbl)
   local runScript = expand(self.testdescript.runScript, self.test, envTbl, funcTbl)
   runScript = runScript:gsub("^%s+#","#")
   runScript = runScript:gsub("\n%s+#","\n#")

   local aa = {}
   for k in pairs(envTbl) do
      aa[#aa + 1] = k .. "=\"" .. envTbl[k] .. "\"; export "..k
   end
   
   local mark   = 0
   local icount = 0
   local a = {}
   local aaa = {}
   for line in runScript:split("\n") do
      icount = icount + 1
      if (not line:find("^#") and mark == 0) then
         mark = icount
      end
      if (mark == 0) then
         a[#a+1] = line
      else
         aaa[#aaa+1] = line
      end
   end
   
   local t = {}
   for _,v in ipairs(a) do
      t[#t+1] = v
   end
   for _,v in ipairs(aa) do
      t[#t+1] = v
   end
   for _,v in ipairs(aaa) do
      t[#t+1] = v
   end
   
   runScript = table.concat(t,"\n")
   return runScript
end


function Tst.testfields(self)
   local tbl = {
      "id", "idTag", "start_epoch", "runtime", "result", "active", "report" , "strRuntime",
      "outputDir", "testName", "reason", "UUid", "resultFn", "runtimeFn", "cmdResultFn",
      "versionFn","osName","machName","hostName","target","ProgVersion","message","tag"
   }

   return tbl
end

function Tst.testresultValues(self)
   local tbl = {
      notrun = 1, notfinished = 2, failed = 3, diff = 4 , passed = 5, inactive = 6, 
   }

   return tbl
end

function Tst.get(self, key)
   local result = self[key]
   if (result == nil) then
      result   = self.testdescript[key]
   end
   return result
end

function Tst.set(self, key, value)
   local result = self[key]
   if (result == nil) then
      Error('Tst.set: Unknown key: "'..key..'"')
   end
   self[key] = value
end

function Tst.hasAnyKeywords(self, keyInA)
   local keyTbl = self:get('keywords')
   local result = false
   for _,v in ipairs(keyInA) do
      if (keyTbl[v]) then
	 result = true
	 break
      end
   end
   return result
end

function Tst.hasAllKeywords(self, keyInA)
   local keyTbl = self:get('keywords')
   local result = true
   for _,v in ipairs(keyInA) do
      if (not keyTbl[v]) then
	 result = false
	 break
      end
   end
   return result
end
