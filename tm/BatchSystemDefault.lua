BatchSystems = {
   INTERACTIVE = {
      default = {
         submitHeader = "",
         mprCmd = "mpirun -np $(NP) $(CMD) $(CMD_ARGS)",
         CurrentWD = ".",
         maxCoresPerNode = 1,
         submitCmd = "",
         queueTbl = {},
      },
   },
   SGE = {
      default = {
         submitHeader= [[
               #$ -V
               #$ -cwd
               #$ -N $(JOBNAME)
               #$ -A $(ACCOUNT)
               #$ -pe $(NPway NP=$(NP) NODES=$(NODES) WAY=$(WAY))
               #$ -q  $(QUEUE)
               #$ -l h_rt=$(TIME)
         ]],
         mprCmd = "ibrun $(CMD) $(CMD_ARGS)",
         submitCmd = "qsub ",
         queueTbl = {short="development", medium="normal", long="long", systest="systest"},
         CurrentWD = ".",
         maxCoresPerNode = 1,
         NODES = -1,
         WAY   = -1,
         NPway = function(tbl, envTbl, funcTbl)
                    local batchTbl = funcTbl.batchTbl
                    local np = tonumber(tbl.NP) or -1
                    local npWay
                    local maxWay = batchTbl.maxCoresPerNode
                    local userWay = tonumber(tbl.WAY) or -1
                    local way 
                    if (userWay > 0 ) then
                       way = userWay
                    else
                       way = batchTbl.maxCoresPerNode
                    end
                    local nNodes = -1
                    local userNodes = tonumber(tbl.NODES) or -1
                    if (userNodes > 0) then
                       nNodes = userNodes
                    end

                    if (nNodes > 0) then
                       npWay = tostring(way) .. "way " .. tostring(nNodes*maxWay)
                    elseif (np <= maxWay and way == maxWay) then
                       npWay = tostring(np) .. "way " .. maxWay
                    else
                       nNodes = math.ceil(np/way)
                       npWay  = way .. "way " .. tostring(nNodes*maxWay)
                    end
                    return npWay
                 end,
      }
   },
   LSF = {
      default = 
         {
         submitHeader= [[
               #BSUB -J $(JOBNAME)
               #BSUB -q $(QUEUE)
               #BSUB -W $(TIME)
               #BSUB -o $(LOGNAME)
               #BSUB -W $(TIME)
               #BSUB -n $(NP)
         ]],
         mprCmd = "ibrun $(CMD) $(CMD_ARGS)",
         submitCmd = "bsub < ",
         CurrentWD = "$LS_SUBCWD",
         maxCoresPerNode = 1,
      },
   },
   PBS = {
      default = 
         {
         submitHeader= [[
               #PBS -N $(JOBNAME)
               #PBS -A $(ACCOUNT)
               #PBS -q $(QUEUE)
               #PBS -o $(LOGNAME)
               #PBS -l walltime="$(TIME)"
               #PBS -l size="$(NP)"
               #PBS -j oe
         ]],
         mprCmd = "aprun -n $(NP) $(CMD) $(CMD_ARGS)",
         submitCmd = "qsub ",
         CurrentWD = "$PBS_O_WORKDIR",
         maxCoresPerNode = 1,
      },
   },
}
