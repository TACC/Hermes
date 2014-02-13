require("strict")
require("string_split")
require("fileOps")
require("pairsByKeys")

local posix     = require("posix")
local getenv    = posix.getenv
local setenv    = posix.setenv
local concatTbl = table.concat
local keepT     = {
   ['ACCOUNT']         = 'keep',
   ['HOME']            = 'keep',
   ['USER']            = 'keep',
   ['LD_LIBRARY_PATH'] = 'keep',
   ['LUA_CPATH']       = 'keep',
   ['LUA_PATH']        = 'keep',
   ['TARG']            = 'keep',
   ['TARGET']          = 'keep',
   --
   ['PATH']            = 'neat',
}
   

local execT = {
   gcc    = 'keep',
   icc    = 'keep',
   lua    = 'keep',
   python = 'keep',
   tm     = 'keep',
   expr   = 'keep',
   seq    = 'keep',
}

local function cleanPath(v)

   local pathT  = {}
   local pathA  = {}

   local idx = 0
   for path in v:split(':') do
      idx = idx + 1
      path = path_regularize(path)
      if (pathT[path] == nil) then
         pathT[path]     = { idx = idx, keep = false }
         pathA[#pathA+1] = path
      end
   end

   local myPath = concatTbl(pathA,':')
   pathA        = {}

   for execName in pairs(execT) do
      local cmd = findInPath(execName, myPath)
      if (cmd ~= '') then
         local p = path_regularize(dirname(cmd))
         pathT[p].keep = true
      end
   end
         
   for path in pairs(pathT) do
      if (v:find('^/usr/')) then
         pathT[path].keep = true
      end
   end

   -- Step 1: Make a sparse array with path as values
   local t = {}

   for k, v in pairs(pathT) do
      if (v.keep) then
         t[v.idx] = k
      end
   end

   -- Step 2: Use pairsByKeys to copy paths into pathA in correct order
   local n = 0
   for _, v in pairsByKeys(t) do
      n = n + 1
      pathA[n] = v
   end

   -- Step 3: rebuild path
   return concatTbl(pathA,':')
end


function cleanEnv()
   local envT = getenv()

   for k, v in pairs(envT) do
      local keep = keepT[k]
      if (not keep) then
         setenv(k, nil, true)
      elseif (keep == 'neat') then
         setenv(k, cleanPath(v), true)
      end
   end
end
