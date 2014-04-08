require("strict")

function UUIDString(epoch)
   local ymd  = os.date("*t", epoch)

   --                           y    m    d    h    m    s
   local uuid = string.format("%d_%02d_%02d_%02d_%02d_%02d", 
			      ymd.year, ymd.month, ymd.day, 
			      ymd.hour, ymd.min,   ymd.sec)
   return uuid
end

function ymdString(epoch)
   local ymd  = os.date("*t", epoch)

   --                     y    m    d
   return string.format("%d_%02d_%02d", ymd.year, ymd.month, ymd.day)
end
