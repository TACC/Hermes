#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

enum {false = 0, true};
typedef enum { iPASSED = 0, iDIFF = 1, iFAILED = 2 } Status;

const char * STbl [] =
{
    "passed",
    "diff",
    "failed"
};
    
    


Status compare(char* argv[]);
void   write_results(Status s, const char * fn);

/*======================================================================
 *   This is a simple compare program.  It reads two files and report
 *   whether the two file are close enough 
 ======================================================================*/


int main(int argc, char* argv[])
{
  FILE*  fp_results;
  Status status;

  if (argc < 5)
    {
      fprintf(stderr,"Usage: %s results.lua value gold test\n", argv[0]);
      return 1;
    }

  status     = compare(argv);
  fp_results = fopen(argv[1],"w");

  write_results(status, argv[1]);
  
  return status;
}

Status compare(char *argv[] )
{
  FILE* fp_gold;
  FILE* fp_test;
  
  Status status = iDIFF;
  int    nx, ny, n, i;
  double x, y, eps;
  double sumDiff, diff, norm, diffMax, relDiff;
  int    relFlag = false;
  int    absFlag = false;

  /* Parse command line options for eps and file names*/
  eps        = strtod(argv[2],(char **) NULL);
  fp_gold    = fopen(argv[3],"r");  /* Gold file */
  fp_test    = fopen(argv[4],"r");  /* Test file */
  
  /* Report failure if either file does not exist. */

  if (fp_gold == NULL || fp_test == NULL)
    return iFAILED;
  



  /* Read in size of vector */
  fscanf(fp_test,"%d", &nx);
  fscanf(fp_gold,"%d", &ny);

  /* Quit if sizes do not match */
  if (nx != ny)
    {
      return iDIFF;
    }

  /* Loop over values computing norm */
  n       = nx;
  norm    = 0.0;
  sumDiff = 0.0;
  diffMax = 0.0;
  for (i = 1; i < n; ++i)
    {
      fscanf(fp_test, "%lf", &x);
      fscanf(fp_gold, "%lf", &y);

      diff     = fabs(x - y);
      norm    += y*y;
      sumDiff += diff*diff;
      if (diff > diffMax)
        diffMax = diff;
    }

  fclose(fp_test);
  fclose(fp_gold);
  
  sumDiff = sqrt(sumDiff);
  norm    = sqrt(norm);


  /* Check to see if difference pass or not */
  if (norm > 1.0e-20)
    {
      relDiff = sumDiff/ norm;
      if (relDiff < eps) relFlag = true;
    }

  if (sumDiff < eps) absFlag = true;

  if (relFlag || absFlag) status = iPASSED;

  /* Print results */
  printf("Relative Norm\tAbsolute Norm\tMax Diff\n");
  printf("%e\t%e\t%e\n",relDiff, sumDiff, diffMax);

  return status;
}

void   write_results(Status s, const char * fn)
{
  const int bufSize = 1024;
  char      buf[bufSize];
  time_t    t;
  struct tm stm;

  FILE* fp = fopen(fn,"w");

  t   = time(NULL);
  strftime(buf, bufSize, "%c", localtime(&t));
  

  fprintf(fp,"-- -*- lua -*-\n");
  fprintf(fp,"-- %s\n", buf);
  fprintf(fp,"myTbl = {\n"
             "  {\n"
             "     [\"result\"] = \"%s\"\n"
             "  },\n"
             "}\n", STbl[s]);
}
