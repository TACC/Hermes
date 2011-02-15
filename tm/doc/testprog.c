#include <stdio.h>
#include <stdlib.h>
#define SZ  100
int main(int argc, char* argv[])
{
  FILE*  fp; int    i; double x;
  
  if (argc < 2)
    {
      fprintf(stderr,"Usage %s file.name\n",argv[0]);
      return 1;
    }

  fp = fopen(argv[1], "w");
  fprintf(fp,"%d\n",SZ);

  for (i = 0; i < SZ; ++i)
    {
      x = ((double) i) + 1.e-8*drand48();
      fprintf(fp,"%22.15g\n", x);
    }
  fclose(fp);
  return 0;
}
