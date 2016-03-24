#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"

#define NUM_OF_DUMMY_LOOPS 100
#define NUM_OF_ITERATIONS 1000000
#define TIME_TO_SLEEP 1
#define CPU "CPU"
#define SCPU "S-CPU"
#define IO "I\\O"



void
getStatistics(int n){
  int i;
  int totalRetime=0;
  int totalRutime=0;
  int totalStime=0;
 for (i=0; i<3*n;i++){
    int retime;
    int rutime;
    int stime;
    int pid=wait2(&retime,&rutime,&stime);
    char* type;
    totalRetime+=retime;
    totalRutime+=rutime;
    totalStime+=stime;
    if (pid%3==0){
      type=CPU;
    }
    else if (pid%3==1) {
      type=SCPU;
    }
    else type=IO;
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  }
  printf(1, "Avg. Ready Time: %d\n", totalRetime/3*n);
  printf(1, "Avg. Run Time: %d\n", totalRutime/3*n);
  printf(1, "Avg. Sleep Time: %d\n", totalStime/3*n);
}


void
runSanity(){
  int pid=getpid();
  int i;
  int j;
  switch (pid%3){
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
        yield();
      }
      break;

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
        sleep(TIME_TO_SLEEP);
      }
      break;

    default:
        break;
  }
}

int
main(int argc, char *argv[])
{
  int i;
  if(argc != 2)
    exit();
  int n=atoi(argv[1]);

  for (i=0; i<3*n;i++){
    int pid=fork();
    if (pid==0) {
      runSanity();
      exit();
    }
  }


getStatistics(n);
  exit();
}
