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

  int CPUtotalCounter=0;
  int SCPUtotalCounter=0;
  int IOtotalCounter=0;

  int CPUtotalRetime=0;
  int SCPUtotalRetime=0;
  int IOtotalRetime=0;

  int CPUtotalRutime=0;
  int SCPUtotalRutime=0;
  int IOtotalRutime=0;

  int CPUtotalStime=0;
  int SCPUtotalStime=0;
  int IOtotalStime=0;
 for (i=0; i<3*n;i++){
    int retime;
    int rutime;
    int stime;
    int pid=wait2(&retime,&rutime,&stime);
    char* type;

    if (pid%3==0){
      type=CPU;
      CPUtotalRetime+=retime;
      CPUtotalRutime+=rutime;
      CPUtotalStime+=stime;
      CPUtotalCounter++;
    }
    else if (pid%3==1) {
      type=SCPU;
      SCPUtotalRetime+=retime;
      SCPUtotalRutime+=rutime;
      SCPUtotalStime+=stime;
      SCPUtotalCounter++;
    }
    else {
      type=IO;
      IOtotalRetime+=retime;
      IOtotalRutime+=rutime;
      IOtotalStime+=stime;
      IOtotalCounter++;
    }
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  }
  printf(1, "CPU  Avg. Ready Time: %d\n", CPUtotalRetime/CPUtotalCounter);
  printf(1, "SCPU Avg. Ready Time: %d\n", SCPUtotalRetime/SCPUtotalCounter);
  printf(1, "IO   Avg. Ready Time: %d\n\n", IOtotalRetime/IOtotalCounter);

  printf(1, "CPU  Avg. Run Time: %d\n", CPUtotalRutime/CPUtotalCounter);
  printf(1, "SCPU Avg. Run Time: %d\n", SCPUtotalRutime/SCPUtotalCounter);
  printf(1, "IO   Avg. Run Time: %d\n\n", IOtotalRutime/IOtotalCounter);

  printf(1, "CPU  Avg. Sleep Time: %d\n", (CPUtotalStime)/CPUtotalCounter);
  printf(1, "SCPU Avg. Sleep Time: %d\n", (SCPUtotalStime)/SCPUtotalCounter);
  printf(1, "IO   Avg. Sleep Time: %d\n\n", (IOtotalStime)/IOtotalCounter);

  printf(1, "CPU  Avg. Turnaround Time: %d\n", (CPUtotalStime+CPUtotalRutime+CPUtotalRetime)/CPUtotalCounter);
  printf(1, "SCPU Avg. Turnaround Time: %d\n", (SCPUtotalStime+SCPUtotalRutime+SCPUtotalRetime)/SCPUtotalCounter);
  printf(1, "IO   Avg. Turnaround Time: %d\n\n", (IOtotalStime+IOtotalRutime+IOtotalRetime)/IOtotalCounter);
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
