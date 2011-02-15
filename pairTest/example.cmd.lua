cmd = {
   PREFIX  = "B2D_",
   name    = "bouss2d",
   runCmd  = { "cd ~/w/Bouss2d_161/; bouss2d -B run/c0_test.nml -I data -O output",
               "cd ~/w/bouss2d/;     bouss2d -B run/c0_test.nml -I data -O output",},
   testCmd = { "cd ~/w/bouss2d/; cmp ~/w/Bouss2d_161/output/c0_test.mtx  output/c0_test.mtx", 
               "cd ~/w/bouss2d/; cmp ~/w/Bouss2d_161/output/c0_test.soln output/c0_test.soln",},
   maxStep = 1
}

    
