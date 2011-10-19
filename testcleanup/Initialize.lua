-- $Id: Initialize.lua 239 2008-07-10 00:02:22Z mclay $ --

require("getUname")
require("fileOps")
local posix = require("posix")

Initialize = BaseTask:new()

function Initialize:execute(myTable)
   local masterTbl          = masterTbl()

   masterTbl.testlistFn	    = "my.tests"
   masterTbl.testRptLoc	    = "testreports"
   masterTbl.testRptExt	    = ".tm"
   masterTbl.descriptExt    = ".tdesc"
   masterTbl.testRptRootDir = pathJoin(masterTbl.projectDir, masterTbl.testRptLoc)
   local t                  = getUname()

   masterTbl.os_mach  = t.os_mach
   masterTbl.hostname = t.hostName
   masterTbl.target   = t.target
end
