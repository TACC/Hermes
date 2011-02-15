-- $Id: FindTests.lua 311 2009-02-12 01:50:31Z mclay $ --
FindTests = BaseTask:new()
require("common")
require("Tst")
require("dirlist")
require("posix")
require("fileOps")
require("Dbg")

function FindTests:execute(myTable)
   local masterTbl         = masterTbl()
   local pargs             = {}
   masterTbl.candidateTsts = {}

   if (masterTbl.spanning ~= myTable.spanning) then return end

   for _,v in ipairs(masterTbl.pargs) do
      pargs[#pargs + 1] = v
   end
   
   if (#pargs < 1) then
      if (#masterTbl.restart > 0 or masterTbl.analyzeFlag) then
         FindTests:findLastTM(pargs)
      else
	 pargs[#pargs + 1] = pathJoin(masterTbl.projectDir, masterTbl.testlistFn)
      end
   end

   for i,path in ipairs(pargs) do
      local mystat = posix.stat(path)
      if (mystat == nil) then
         path   = pathJoin(masterTbl.projectDir,path)
         mystat = posix.stat(path)
      end
      if (masterTbl.verbosityLevel > 0) then
	 print("Reading: "..path)
      end
      if (mystat and mystat.type == "regular") then
	 if (path:find(masterTbl.testRptExt.."$")) then
	    FindTests:readTMfile(path)
	 elseif (path:find(masterTbl.descriptExt.."$")) then
	    FindTests:readTestDescriptFn(path)
	 else
	    FindTests:readTestList(path)
	 end
      else
         if (masterTbl.verbosityLevel > 0) then
            print("Searching: "..path)
         end
	 FindTests:search(path)
      end
   end
end

function FindTests:buildCandidateTsts(testA, ntimes, target, epoch, candidateTsts)
   local idA = {}
   for _,v in ipairs(testA) do
      idA[#idA+1] = v.id
   end
   FindTests:buildCandidateTsts_id(idA, ntimes, target, epoch, candidateTsts)

   local tstKeys = Tst:testfields()

   for _,v in ipairs(testresults.tests) do
      local tst = candidateTsts[v.id]
      for _,key in ipairs(tstKeys) do 
	 tst[key] = v[key]
      end
   end
end

function FindTests:readTestDescriptFn(path)
   local masterTbl = masterTbl()
   local tagA      = masterTbl.tagA
   local targetA   = masterTbl.targetA
   local fn        = pathJoin(posix.getcwd(), path)
   local epoch     = masterTbl.origEpoch
   assert(loadfile(fn))()
   if (masterTbl.verbosityLevel > 0) then 
      print("Found: " .. fn)
   end
   if (masterTbl.spanning) then
      masterTbl.tagTbl = masterTbl.tagTbl or {} 
      for _,tag       in ipairs(tagA)    do
         masterTbl.tagTbl[tag]           = masterTbl.tagTbl[tag] or {} 
         masterTbl.tagTbl[tag].targetTbl = masterTbl.tagTbl[tag].targetTbl or {}
         local targT                     = masterTbl.tagTbl[tag].targetTbl
	 for _,target in ipairs(targetA) do
            targT[target]               = targT[target] or {} 
	    targT[target].candidateTsts = targT[target].candidateTsts or {} 
            targT[target].target        = target
            local candidateTsts         = targT[target].candidateTsts
	    local tstTbl                = buildTstTbl(fn, testdescript, target, epoch, masterTbl.ntimes)
	    for id in pairs(tstTbl) do
	       candidateTsts[id] = tstTbl[id]
	    end
            targT[target].epoch = epoch
	 end
      end
   else
      local target            = masterTbl.target
      local tstTbl            = buildTstTbl(fn, testdescript, target, epoch, masterTbl.ntimes)
      masterTbl.epoch         = epoch
      masterTbl.target        = target
      masterTbl.candidateTsts = masterTbl.candidateTsts or {}
      local candidateTsts     = masterTbl.candidateTsts
      for id in pairs(tstTbl) do
	 candidateTsts[id] = tstTbl[id]
      end
   end
end

function FindTests:readTMfile(path)
   local masterTbl = masterTbl()
   local tagA      = masterTbl.tagA
   if (masterTbl.verbosityLevel > 0) then
      print("readTMfile: "..path)
   end
   assert(loadfile(path))()

   -- Use original Epoch from TM file
   local epoch         = testresults.origEpoch

   local ntimes = testresults.ntimes
   masterTbl.ntimes = ntimes
   if (masterTbl.spanning) then
      local tag                       = testresults.tag
      masterTbl.tagTbl                = masterTbl.tagTbl or {} 
      masterTbl.tagTbl[tag]           = masterTbl.tagTbl[tag] or {}
      masterTbl.tagTbl[tag].origEpoch = epoch
      masterTbl.tagTbl[tag].targetTbl = masterTbl.tagTbl[tag].targetTbl or {} 
      local targT                     = masterTbl.tagTbl[tag].targetTbl
      for target in pairs(testresults.tests.targetTbl) do
	 local a                     = testresults.tests.targetTbl[target]
         targT[target]               = targT[target] or {} 
         targT[target].candidateTsts = targT[target].candidateTsts or {}
	 FindTests:buildCandidateTsts(a, ntimes, target, epoch, targT[target].candidateTsts)
	 targT[target].ntimes        = ntimes
	 targT[target].origEpoch     = epoch
	 targT[target].epoch         = epoch
	 targT[target].tag           = testresults.tag
      end
   else
      local target            = testresults.target
      local a                 = testresults.tests
      masterTbl.candidateTsts = masterTbl.candidateTsts or {}
      masterTbl.tag           = testresults.tag
      masterTbl.epoch         = epoch
      masterTbl.origEpoch     = epoch
      masterTbl.target        = target
      FindTests:buildCandidateTsts(a, ntimes, target, epoch, masterTbl.candidateTsts)
   end
end

function FindTests:readTestList(fn)
   local masterTbl = masterTbl()
   local tagA      = masterTbl.tagA
   local targetA   = masterTbl.targetA
   if (masterTbl.verbosityLevel > 0) then
      print("readTestList: "..fn)
   end
   assert(loadfile(fn))()

   local epoch = masterTbl.origEpoch

   local ntimes = masterTbl.ntimes
   if (masterTbl.spanning) then
      masterTbl.tagTbl = masterTbl.tagTbl or {} 
      for tag       in ipairs(tagA)    do
         masterTbl.tagTbl[tag]           = masterTbl.tagTbl[tag] or {}
         masterTbl.tagTbl[tag].targetTbl = masterTbl.tagTbl[tag].targetTbl or {}
         local targT                     = masterTbl.tagTbl[tag].targetTbl
	 for target in ipairs(targetA) do
            targT[target]               = targT[target] or {}
            targT[target].epoch         = epoch
	    targT[target].candidateTsts = targT[target].candidateTsts or {}
	    FindTests:buildCandidateTsts_id(testlist, ntimes, target, epoch, targT[target].candidateTsts)
	 end
      end
   else
      masterTbl.epoch         = epoch
      local target            = targetA[1]
      masterTbl.target        = targetA[1]
      masterTbl.candidateTsts = masterTbl.candidateTsts or {}
      FindTests:buildCandidateTsts_id(testlist, ntimes, target, epoch, masterTbl.candidateTsts)
   end
end

function FindTests:buildCandidateTsts_id(idA, ntimes, target, epoch, candidateTsts)
   local masterTbl = masterTbl()

   -- Transform id into test description file
   -- with a list of id's used

   local fnTbl = {}
   for _,id in ipairs(idA) do
      local _, _, fn, idTag = id:find("^(.*)/(.*)")
      fn = pathJoin(masterTbl.projectDir, fn .. ".tdesc")
      fnTbl[fn] = fnTbl[fn] or {}
      table.insert(fnTbl[fn],id)
   end

   local cwd = posix.getcwd()
   -- Read in test description file, store tests with id
   -- in masterTbl.candidateTsts 
   for fn in pairs(fnTbl) do
      local d, f = splitFileName(fn)
      posix.chdir(d)
      assert(loadfile(f))()
      local tstTbl = buildTstTbl(fn, testdescript, target, epoch, ntimes)
      for i,id in ipairs(fnTbl[fn]) do
	 candidateTsts[id] = tstTbl[id]
      end
   end
   posix.chdir(cwd)
end

function FindTests:search(path)
   local masterTbl = masterTbl()

   if (not posix.access(path)) then return end
   local cwd	   = posix.getcwd()
   posix.chdir(path)
   if (masterTbl.verbosityLevel > 3) then print("Searching: " .. posix.getcwd()) end

   if (masterTbl.verbosityLevel > 0) then
      print ("FindTests:search dirlist(\".\")")
   end
   local list	   = dirlist(".")
   local found     = false
   for _,v in ipairs(list.files) do
      if (v:find("%.tdesc$")) then
	 FindTests:readTestDescriptFn(v)
	 found = true
      end
   end

   if (not found) then
      for _,v in ipairs(list.dirs) do
	 local dir = pathJoin(posix.getcwd(), v)
	 FindTests:search(dir)
      end
   end
   posix.chdir(cwd)
end

function FindTests:findLastTM(pargs)
   local masterTbl  = masterTbl()
   local pattern    = masterTbl.os_mach .. '%' .. masterTbl.testRptExt .. "$"
   pattern          = pattern:gsub("%-", "%%-")
   local tmTbl      = {}
   local testRptDir = masterTbl.testRptDir

   local tagA
   if (masterTbl.spanning) then
      tagA = masterTbl.tagA
   else
      tagA = {''}
   end

   for _, tag in ipairs(tagA) do
      if (masterTbl.spanning) then
	 testRptDir = pathJoin(masterTbl.testRptDirRoot,".span",tag)
      end

      if (masterTbl.verbosityLevel > 0) then
	 print("FindTests:findLastTM:  filelist(\""..testRptDir .. "\")")
      end
      local list	    = filelist(testRptDir)
      for _,v in ipairs(list) do
	 if (v:find(pattern)) then
	    tmTbl[#tmTbl + 1] = v
	 end
      end
      local tmFileName = nil
      if (#tmTbl > 0) then
	 table.sort(tmTbl)
	 for i = #tmTbl, 1, -1 do
	    local fn = pathJoin(testRptDir, tmTbl[i])
	    local attr = lfs.attributes(fn)
	    if (attr and attr.size > 0) then tmFileName = fn; break end
	 end
      end
      if (tmFileName) then
	 pargs[#pargs+1] = tmFileName
      end
   end
end
