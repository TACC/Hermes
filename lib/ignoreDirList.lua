require("strict")
function ignoreDirList()
   local  ignoreT = { ['.'] = 1, ['..'] = 1, ['.svn'] = 1, ['.git'] = 1, CVS = 1, ['.bzr'] = 1, ['.hg'] = 1,
                      ['.span'] = 1}
   return ignoreT
end
