-- $Id: GauntletData.lua 292 2008-12-01 05:28:35Z mclay $ --
require("Tst")

GauntletData = {}

function GauntletData.setupNP(self, name, value)
   if (value[1]) then    self.minNP = value[1] end
   if (value[2]) then    self.maxNP = value[2] end
end

function GauntletData.setupList(self, name, value)
   self.data[name] = value
end

function GauntletData.applyNP(self, name, candidateTsts)
   for id in pairs(candidateTsts) do
      local tst = candidateTsts[id]
      if (tst:get('active')) then
	 np = tst:get('np')
	 tst:set('active',  (self.minNP <= np ) and (np <= self.maxNP))
      end
   end
end

function GauntletData.applyKeyword(self, name, candidateTsts)
   for id in pairs(candidateTsts) do
      local tst = candidateTsts[id]
      if (tst:get('active')) then
	 tst:set('active',  tst:hasAllKeywords(self.data[name]))
      end
   end
end

function GauntletData.setupRestart(self, name, value)
   local restartValueTbl = {}
   local testresultTbl   = Tst:testresultValues()
   for _,v in ipairs(value) do
      if (v == 'wrong') then
	 for v in pairs(testresultTbl) do
	    if (testresultTbl[v] <  testresultTbl['passed']) then
	       restartValueTbl[v] = 1
	    end
	 end
      elseif (testresultTbl[v]) then
	 restartValueTbl[v] = 1
      end
   end
   self.restartValueTbl = restartValueTbl
end

function GauntletData.applyRestart(self, name, candidateTsts)
   for id in pairs(candidateTsts) do
      local tst = candidateTsts[id]
      local active = tst:get('active')
      if (tst:get('active')) then
	 local result = tst:get('result')
	 if (self.restartValueTbl[result] ~= nil) then
	    tst:set('active', true )
	 else
	    tst:set('report', true )
	    tst:set('active', false)
	 end
      end
   end
end

function GauntletData:new(o)
   o = o or {}
   setmetatable(o,self)
   self.__index = self

   o.dispatchTbl = {
      keywords = { GauntletData.setupList,    GauntletData.applyKeyword },
      NP       = { GauntletData.setupNP,      GauntletData.applyNP      },
      restart  = { GauntletData.setupRestart, GauntletData.applyRestart }
   }

   o.minNP   = 0
   o.maxNP   = 1.e20
   o.data    = {}

   return o
end
