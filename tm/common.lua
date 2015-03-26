require("strict")
require("fileOps")


function countEntries(T)
   local count = 0
   for _ in pairs(T) do
      count = count + 1
   end
   return count
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

   for id in pairs(masterTbl.rptTbl) do
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

function UUIDString(epoch)
   local ymd  = os.date("*t", math.floor(epoch))

   --                           y    m    d    h    m    s
   local uuid = string.format("%d_%02d_%02d_%02d_%02d_%02d", 
			      ymd.year, ymd.month, ymd.day, 
			      ymd.hour, ymd.min,   ymd.sec)
   return uuid
end

function ymdString(epoch)
   local ymd  = os.date("*t", math.floor(epoch))

   --                     y    m    d
   return string.format("%d_%02d_%02d", ymd.year, ymd.month, ymd.day)
end
