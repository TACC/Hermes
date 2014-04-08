require("strict")
BaseTask = {}

function BaseTask:new(name)
   local o = {}
   setmetatable(o,self)
   self.__index = self
   o.name       = name
   return o
end

function BaseTask:name()
   return self.name
end
