require("strict")
require("build_epoch")
Epoch = BaseTask:new()

function Epoch:execute(myTable)
   build_epoch()
   print (epoch())
end
