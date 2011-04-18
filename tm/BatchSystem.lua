BatchSystems = {
   SGE = {
      ranger = {
         submitHeader= [[
               # ranger
               #$ -V
               #$ -cwd
               #$ -N $(JOBNAME)
               #$ -A $(ACCOUNT)
               #$ -pe $(NPway NP=$(NP), NODES=$(NODES), WAY=$(WAY))
               #$ -q  $(QUEUE)
               #$ -l h_rt=$(TIME)
         ]],
         maxCoresPerNode = 16,
      },
      longhorn = {
         submitHeader= [[
               # longhorn
               #$ -V
               #$ -cwd
               #$ -N $(JOBNAME)
               #$ -P hpc
               #$ -A $(ACCOUNT)
               #$ -pe $(NPway NP=$(NP), NODES=$(NODES), WAY=$(WAY))
               #$ -q  $(QUEUE)
               #$ -l h_rt=$(TIME)
         ]],
         maxCoresPerNode = 8,
      },
      ls4 = {
         submitHeader= [[
               # lonestar
               #$ -V
               #$ -cwd
               #$ -N $(JOBNAME)
               #$ -A $(ACCOUNT)
               #$ -pe $(NPway NP=$(NP), NODES=$(NODES), WAY=$(WAY))
               #$ -q  $(QUEUE)
               #$ -l h_rt=$(TIME)
         ]],
         maxCoresPerNode = 12,
      },
   },
   PBS = {
      harvard = {
         submitHeader= [[
               #PBS -N $(JOBNAME)
               #PBS -A $(ACCOUNT)
               #PBS -q $(QUEUE)
               #PBS -o $(LOGNAME)
               #PBS -l walltime="$(TIME)"
               #PBS -l size="$(NP)"
               #PBS -j oe
         ]],
         maxCoresPerNode = 16,
      },
   },
}
