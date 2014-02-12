require("strict")
require("string_split")

local posix     = require("posix")
local getenv    = posix.getenv
local setenv    = posix.setenv
local concatTbl = table.concat
local keepT     = {
   ['LD_LIBRARY_PATH'] = 'keep',
   ['TARGET']          = 'keep',
   ['PATH']            = 'neat',
}
   

local function cleanPath(v)
   local a = {}
   for path in v:split(':') do
      if (v:find('^/usr/') or v:find('/hermes/bin')) then
         a[#a+1] = v
      end
   end
   return concatTbl(a,':')
end


function cleanEnv()
   envT = getenv()

   for k, v in pairs(envT) do
      keep = keepT[k]
      if (not keep) then
         setenv(k, nil, true)
      elseif (keep == 'neat') then
         setenv(k, cleanPath(v), true)
      end
   end
end
