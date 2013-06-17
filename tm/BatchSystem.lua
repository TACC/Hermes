BatchSystems = {
   SLURM = {
      stampede = {
         submitHeader = [[
               # stampede
               #SBATCH -J $(JOBNAME)
               #SBATCH -o $(JOBNAME).%j.out
               #SBATCH -p $(QUEUE)
               #SBATCH -N $(NODES)
               #SBATCH -n $(NP)
               #SBATCH -t $(TIME)
               #SBATCH -A $(ACCOUNT)
         ]],
         maxCoresPerNode = 16,
      },
   },
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
      garnet = {
         submitHeader= [[
               #PBS -V
               #PBS -N $(JOBNAME)
               #PBS -A $(ACCOUNT)
               #PBS -q $(QUEUE)
               #PBS -l walltime=$(TIME)
               #PBS -l ncpus=$(NP)
               #PBS -j oe
               #PBS -o $(JOBNAME).oe
               # START OF COMMANDS
               umask 007
               umask
               cd $PBS_O_WORKDIR
         ]],
         maxCoresPerNode = 16,
      },
      diamond  = {
         submitHeader= [[
               #PBS -V
               #PBS -N $(JOBNAME)
               #PBS -A $(ACCOUNT)
               #PBS -q $(QUEUE)
               #PBS -l walltime=$(TIME)
               #PBS -l ncpus=$(NP)
               #PBS -j oe
               # START OF COMMANDS
               umask 007
               umask
               cd $PBS_O_WORKDIR
         ]],
         maxCoresPerNode = 16,
      },
      chugach  = {
         submitHeader= [[
               #PBS -V
               #PBS -N $(JOBNAME)
               #PBS -A $(ACCOUNT)
               #PBS -q $(QUEUE)
               #PBS -l walltime=$(TIME)
               #PBS -l mppwidth=$(NP)
               #PBS -j oe
               # START OF COMMANDS
               umask 007
               umask
               cd $PBS_O_WORKDIR
         ]],
         maxCoresPerNode = 16,
      },
   },
}
