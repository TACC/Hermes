-- $Id: CVSWrapper.lua 194 2008-06-25 21:43:50Z mclay $ --

CVSWrapper = BaseTask:new()

function CVSWrapper:execute(myTable)
   local masterTbl = masterTbl()
   
   local checkoutOptions = masterTbl.checkoutOptions

   local strTbl = {}

   for _, v in checkoutOptions do
      value = masterTbl[v.varName]
      if (value) then
	 if     (v.action == 'store_true' ) then table.insert(strTbl,v.flag)
	 elseif (v.action == 'store'      ) then table.insert(strTbl,v.flag .. ' ' .. value)
	 elseif (v.action == 'append'     ) then
	    for _, vv in ipairs(value) do
	       table.insert(strTbl,v.flag .. ' ' .. vv)
	    end
	 end
      end
   end

   if (masterTbl.cvsOptions) then
      table.insert(strTbl,1, 'cvs ' .. masterTbl.cvsOptions .. ' checkout')
   else 
      table.insert(strTbl,1, 'cvs  checkout')
   end

   for _,v in masterTbl.pargs do
      table.insert(strTbl,v)
   end

   local string = table.concat(strTbl," ")

   for iTries = 1, masterTbl.tries do
      status = os.execute(string)
      if (status == 0) then break end
   end
   masterTbl.status = status
end
