ProcessSimFile = BaseTask:new()

require("string_split")

function ProcessSimFile:execute(myTable)
   local masterTbl     = masterTbl()

   if (masterTbl.pargs[1] == nil) then
      return
   end

   local simTbl = {
      --
      --  Input files:
      --
      DEP   = { kind = 'input',  name = 'dep.in',        fname = 'DepFile',    lun = 15},
      OPTS  = { kind = 'input',  name = 'options.in',    fname = 'OptsFile',   lun = 11},
      SURGE = { kind = 'input',  name = 'surge.in',      fname = 'SurgeFile',  lun = 19},
      WIND  = { kind = 'input',  name = 'wind.in',       fname = 'WindFile',   lun = 20},
      SPEC  = { kind = 'input',  name = 'spec.in',       fname = 'EngInFile',  lun =  8},
      CURR  = { kind = 'input',  name = 'current.in',    fname = 'CurrFile',   lun = 16},
      FRIC  = { kind = 'input',  name = 'fricion.dat',   fname = 'FricFile',   lun = 25},
      SIM   = { kind = 'input',  name = 'sim',           fname = 'SimFile',    lun = 41},
      --
      --  Output files:
      --
      WAVE  = { kind = 'output', name = 'wavfld',        fname = 'WaveFile',   lun = 66},
      OBSE  = { kind = 'output', name = 'spec.out',      fname = 'EngOutFile', lun = 10},
      NEST  = { kind = 'output', name = 'nest.out',      fname = 'NestFile',   lun = 13},
      BREAK = { kind = 'output', name = 'break.out',     fname = 'BreakFile',  lun = 17},
      RADS  = { kind = 'output', name = 'radstress.out', fname = 'RadsFile',   lun = 18},
      SELH  = { kind = 'output', name = 'selhts.out',    fname = 'ObsFile',    lun = 12},
      TP    = { kind = 'output', name = 'Tp.out',        fname = 'TpFile',     lun = 67},
      LOG   = { kind = 'output', name = 'stwave.log',    fname = 'Logfile',    lun = 31},
   }
     
   io.input(masterTbl.pargs[1])

   simTbl.SIM.name=masterTbl.pargs[1]

   local lineA = io.read("*all")
   
   for v in lineA:split("\n") do
      local t = {}
      for vv in v:split("%s+") do
	 t[#t + 1] = vv
      end

      local key = t[1]
      if (simTbl[key] ~= nil) then
	 simTbl[key].name = t[2]
      end
   end

   masterTbl.simTbl = simTbl
end
