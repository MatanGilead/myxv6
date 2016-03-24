#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#define NUM_OF_DUMMY_LOOPS 100
#define NUM_OF_ITERATIONS 1000000
#define NUM_OF_LOTS 21
#define NUM_PROC_PER_PRIORITY 21/3
#define MAX_PRIORITY 3
int array [NUM_OF_LOTS][2];

int
main(int argc, char *argv[]) {
int totalPriorityMAX=0;
int totalPriorityMIDDLE=0;
int totalPriorityMIN=0;
int i;
int j;
int l;
for(l=0;l<NUM_OF_LOTS;l++){
  int pid=fork();
  if(pid) {
    array[l][0]=pid;
    array[l][1]=l%MAX_PRIORITY+1;
    continue;
  }
  pid=getpid();
  int priority=l%MAX_PRIORITY+1;
  set_prio(priority);
  for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
    for (j=0;j<NUM_OF_ITERATIONS;j++){
    }
  exit();
  }
}


for(l=0;l<NUM_OF_LOTS;l++){
  int retime;
  int rutime;
  int stime;
  int pid=wait2(&retime,&rutime,&stime);
  int turnaroundTime=retime+rutime;
  for(i=0;i<NUM_OF_LOTS;i++) {
    if (array[i][0]==pid)
      break;
  }
  int priority=array[i][1];
  printf(1,"PID %d with priority %d has turnaround time of %d\n",pid,priority,turnaroundTime);
  if (priority==1) totalPriorityMIN+=turnaroundTime;
  if (priority==2) totalPriorityMIDDLE+=turnaroundTime;
  if (priority==3) totalPriorityMAX+=turnaroundTime;
  }
  printf(1,"\n");
  printf(1,"Average turnaround time for priority 1: %d\n",totalPriorityMIN/NUM_PROC_PER_PRIORITY);
  printf(1,"Average turnaround time for priority 2: %d\n",totalPriorityMIDDLE/NUM_PROC_PER_PRIORITY);
  printf(1,"Average turnaround time for priority 3: %d\n",totalPriorityMAX/NUM_PROC_PER_PRIORITY);
  exit();
}
