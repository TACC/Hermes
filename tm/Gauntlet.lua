require("strict")

Gauntlet = {}

function Gauntlet.new(self, gauntletData)
   local o =  {}
   setmetatable(o,self)
   self.__index = self
   
   self.gauntletData = gauntletData
   self.dispatchTbl  = gauntletData.dispatchTbl
   self.runTbl       = {}

   return o
end

function Gauntlet.add(self, name, value)
   local setupFn = self.dispatchTbl[name][1]
   local applyFn = self.dispatchTbl[name][2]

   if (value == nil) then return end
   if (type(value) == "table" and #value < 1) then 
      return 
   end

   setupFn(self.gauntletData, name, value)
   self.runTbl[name] = applyFn
end

function Gauntlet.apply(self, candidateTsts)
   for name in pairs(self.runTbl) do
      local applyFn = self.runTbl[name]
      applyFn(self.gauntletData, name, candidateTsts)
   end
end
   
