require("strict")
require("Gauntlet")
SelectTests = BaseTask:new()

function SelectTests:execute(myTable)
   local masterTbl        = masterTbl()
   local target           = myTable.target

   -- Run the gauntlet on the candidate tests.

   if (masterTbl.minNP or masterTbl.maxNP ) then
      local procA   = {}
      table.insert(procA, masterTbl.minNP)
      table.insert(procA, masterTbl.maxNP)
      masterTbl.gauntlet:add('NP', procA)
   end
   
   masterTbl.gauntlet:add('keywords', masterTbl.keywords)
   masterTbl.gauntlet:add('restart',  masterTbl.restart)


   masterTbl.gauntlet:apply(masterTbl.candidateTsts)


   local analyzeFlag      = masterTbl.analyzeFlag
   masterTbl.tstTbl       = {}
   masterTbl.rptTbl       = {}
   masterTbl.resultMaxLen = 12

   for id in pairs(masterTbl.candidateTsts) do
      local tst = masterTbl.candidateTsts[id]
      if (analyzeFlag or tst:get('report')) then
	 masterTbl.rptTbl[id] = tst
      elseif (tst:get('active')) then
      	 masterTbl.tstTbl[id] = tst
      	 masterTbl.rptTbl[id] = tst
      end 
   end

end
