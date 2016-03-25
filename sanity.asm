
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <getStatistics>:
#define IO "I\\O"



void
getStatistics(int n){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 78             	sub    $0x78,%esp
  int i;

  int CPUtotalCounter=0;
   6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int SCPUtotalCounter=0;
   d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int IOtotalCounter=0;
  14:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

  int CPUtotalRetime=0;
  1b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  int SCPUtotalRetime=0;
  22:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  int IOtotalRetime=0;
  29:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)

  int CPUtotalRutime=0;
  30:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  int SCPUtotalRutime=0;
  37:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  int IOtotalRutime=0;
  3e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)

  int CPUtotalStime=0;
  45:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  int SCPUtotalStime=0;
  4c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  int IOtotalStime=0;
  53:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 for (i=0; i<3*n;i++){
  5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  61:	e9 f5 00 00 00       	jmp    15b <getStatistics+0x15b>
    int retime;
    int rutime;
    int stime;
    int pid=wait2(&retime,&rutime,&stime);
  66:	8d 45 b0             	lea    -0x50(%ebp),%eax
  69:	89 44 24 08          	mov    %eax,0x8(%esp)
  6d:	8d 45 b4             	lea    -0x4c(%ebp),%eax
  70:	89 44 24 04          	mov    %eax,0x4(%esp)
  74:	8d 45 b8             	lea    -0x48(%ebp),%eax
  77:	89 04 24             	mov    %eax,(%esp)
  7a:	e8 e5 06 00 00       	call   764 <wait2>
  7f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    char* type;

    if (pid%3==0){
  82:	8b 4d bc             	mov    -0x44(%ebp),%ecx
  85:	ba 56 55 55 55       	mov    $0x55555556,%edx
  8a:	89 c8                	mov    %ecx,%eax
  8c:	f7 ea                	imul   %edx
  8e:	89 c8                	mov    %ecx,%eax
  90:	c1 f8 1f             	sar    $0x1f,%eax
  93:	29 c2                	sub    %eax,%edx
  95:	89 d0                	mov    %edx,%eax
  97:	01 c0                	add    %eax,%eax
  99:	01 d0                	add    %edx,%eax
  9b:	89 ca                	mov    %ecx,%edx
  9d:	29 c2                	sub    %eax,%edx
  9f:	85 d2                	test   %edx,%edx
  a1:	75 1f                	jne    c2 <getStatistics+0xc2>
      type=CPU;
  a3:	c7 45 c0 18 0c 00 00 	movl   $0xc18,-0x40(%ebp)
      CPUtotalRetime+=retime;
  aa:	8b 45 b8             	mov    -0x48(%ebp),%eax
  ad:	01 45 e4             	add    %eax,-0x1c(%ebp)
      CPUtotalRutime+=rutime;
  b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  b3:	01 45 d8             	add    %eax,-0x28(%ebp)
      CPUtotalStime+=stime;
  b6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  b9:	01 45 cc             	add    %eax,-0x34(%ebp)
      CPUtotalCounter++;
  bc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  c0:	eb 5e                	jmp    120 <getStatistics+0x120>
    }
    else if (pid%3==1) {
  c2:	8b 4d bc             	mov    -0x44(%ebp),%ecx
  c5:	ba 56 55 55 55       	mov    $0x55555556,%edx
  ca:	89 c8                	mov    %ecx,%eax
  cc:	f7 ea                	imul   %edx
  ce:	89 c8                	mov    %ecx,%eax
  d0:	c1 f8 1f             	sar    $0x1f,%eax
  d3:	29 c2                	sub    %eax,%edx
  d5:	89 d0                	mov    %edx,%eax
  d7:	01 c0                	add    %eax,%eax
  d9:	01 d0                	add    %edx,%eax
  db:	89 ca                	mov    %ecx,%edx
  dd:	29 c2                	sub    %eax,%edx
  df:	83 fa 01             	cmp    $0x1,%edx
  e2:	75 1f                	jne    103 <getStatistics+0x103>
      type=SCPU;
  e4:	c7 45 c0 1c 0c 00 00 	movl   $0xc1c,-0x40(%ebp)
      SCPUtotalRetime+=retime;
  eb:	8b 45 b8             	mov    -0x48(%ebp),%eax
  ee:	01 45 e0             	add    %eax,-0x20(%ebp)
      SCPUtotalRutime+=rutime;
  f1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  f4:	01 45 d4             	add    %eax,-0x2c(%ebp)
      SCPUtotalStime+=stime;
  f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  fa:	01 45 c8             	add    %eax,-0x38(%ebp)
      SCPUtotalCounter++;
  fd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 101:	eb 1d                	jmp    120 <getStatistics+0x120>
    }
    else {
      type=IO;
 103:	c7 45 c0 22 0c 00 00 	movl   $0xc22,-0x40(%ebp)
      IOtotalRetime+=retime;
 10a:	8b 45 b8             	mov    -0x48(%ebp),%eax
 10d:	01 45 dc             	add    %eax,-0x24(%ebp)
      IOtotalRutime+=rutime;
 110:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 113:	01 45 d0             	add    %eax,-0x30(%ebp)
      IOtotalStime+=stime;
 116:	8b 45 b0             	mov    -0x50(%ebp),%eax
 119:	01 45 c4             	add    %eax,-0x3c(%ebp)
      IOtotalCounter++;
 11c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    }
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
 120:	8b 4d b0             	mov    -0x50(%ebp),%ecx
 123:	8b 55 b4             	mov    -0x4c(%ebp),%edx
 126:	8b 45 b8             	mov    -0x48(%ebp),%eax
 129:	89 4c 24 18          	mov    %ecx,0x18(%esp)
 12d:	89 54 24 14          	mov    %edx,0x14(%esp)
 131:	89 44 24 10          	mov    %eax,0x10(%esp)
 135:	8b 45 c0             	mov    -0x40(%ebp),%eax
 138:	89 44 24 0c          	mov    %eax,0xc(%esp)
 13c:	8b 45 bc             	mov    -0x44(%ebp),%eax
 13f:	89 44 24 08          	mov    %eax,0x8(%esp)
 143:	c7 44 24 04 28 0c 00 	movl   $0xc28,0x4(%esp)
 14a:	00 
 14b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 152:	e8 fc 06 00 00       	call   853 <printf>
  int IOtotalRutime=0;

  int CPUtotalStime=0;
  int SCPUtotalStime=0;
  int IOtotalStime=0;
 for (i=0; i<3*n;i++){
 157:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 15b:	8b 55 08             	mov    0x8(%ebp),%edx
 15e:	89 d0                	mov    %edx,%eax
 160:	01 c0                	add    %eax,%eax
 162:	01 d0                	add    %edx,%eax
 164:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 167:	0f 8f f9 fe ff ff    	jg     66 <getStatistics+0x66>
      IOtotalStime+=stime;
      IOtotalCounter++;
    }
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  }
  printf(1, "CPU  Avg. Ready Time: %d\n", CPUtotalRetime/CPUtotalCounter);
 16d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 170:	89 c2                	mov    %eax,%edx
 172:	c1 fa 1f             	sar    $0x1f,%edx
 175:	f7 7d f0             	idivl  -0x10(%ebp)
 178:	89 44 24 08          	mov    %eax,0x8(%esp)
 17c:	c7 44 24 04 66 0c 00 	movl   $0xc66,0x4(%esp)
 183:	00 
 184:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18b:	e8 c3 06 00 00       	call   853 <printf>
  printf(1, "SCPU Avg. Ready Time: %d\n", SCPUtotalRetime/SCPUtotalCounter);
 190:	8b 45 e0             	mov    -0x20(%ebp),%eax
 193:	89 c2                	mov    %eax,%edx
 195:	c1 fa 1f             	sar    $0x1f,%edx
 198:	f7 7d ec             	idivl  -0x14(%ebp)
 19b:	89 44 24 08          	mov    %eax,0x8(%esp)
 19f:	c7 44 24 04 80 0c 00 	movl   $0xc80,0x4(%esp)
 1a6:	00 
 1a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ae:	e8 a0 06 00 00       	call   853 <printf>
  printf(1, "IO   Avg. Ready Time: %d\n\n", IOtotalRetime/IOtotalCounter);
 1b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1b6:	89 c2                	mov    %eax,%edx
 1b8:	c1 fa 1f             	sar    $0x1f,%edx
 1bb:	f7 7d e8             	idivl  -0x18(%ebp)
 1be:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c2:	c7 44 24 04 9a 0c 00 	movl   $0xc9a,0x4(%esp)
 1c9:	00 
 1ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1d1:	e8 7d 06 00 00       	call   853 <printf>

  printf(1, "CPU  Avg. Run Time: %d\n", CPUtotalRutime/CPUtotalCounter);
 1d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
 1d9:	89 c2                	mov    %eax,%edx
 1db:	c1 fa 1f             	sar    $0x1f,%edx
 1de:	f7 7d f0             	idivl  -0x10(%ebp)
 1e1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e5:	c7 44 24 04 b5 0c 00 	movl   $0xcb5,0x4(%esp)
 1ec:	00 
 1ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1f4:	e8 5a 06 00 00       	call   853 <printf>
  printf(1, "SCPU Avg. Run Time: %d\n", SCPUtotalRutime/SCPUtotalCounter);
 1f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1fc:	89 c2                	mov    %eax,%edx
 1fe:	c1 fa 1f             	sar    $0x1f,%edx
 201:	f7 7d ec             	idivl  -0x14(%ebp)
 204:	89 44 24 08          	mov    %eax,0x8(%esp)
 208:	c7 44 24 04 cd 0c 00 	movl   $0xccd,0x4(%esp)
 20f:	00 
 210:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 217:	e8 37 06 00 00       	call   853 <printf>
  printf(1, "IO   Avg. Run Time: %d\n\n", IOtotalRutime/IOtotalCounter);
 21c:	8b 45 d0             	mov    -0x30(%ebp),%eax
 21f:	89 c2                	mov    %eax,%edx
 221:	c1 fa 1f             	sar    $0x1f,%edx
 224:	f7 7d e8             	idivl  -0x18(%ebp)
 227:	89 44 24 08          	mov    %eax,0x8(%esp)
 22b:	c7 44 24 04 e5 0c 00 	movl   $0xce5,0x4(%esp)
 232:	00 
 233:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 23a:	e8 14 06 00 00       	call   853 <printf>

  printf(1, "CPU  Avg. Sleep Time: %d\n", (CPUtotalStime)/CPUtotalCounter);
 23f:	8b 45 cc             	mov    -0x34(%ebp),%eax
 242:	89 c2                	mov    %eax,%edx
 244:	c1 fa 1f             	sar    $0x1f,%edx
 247:	f7 7d f0             	idivl  -0x10(%ebp)
 24a:	89 44 24 08          	mov    %eax,0x8(%esp)
 24e:	c7 44 24 04 fe 0c 00 	movl   $0xcfe,0x4(%esp)
 255:	00 
 256:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 25d:	e8 f1 05 00 00       	call   853 <printf>
  printf(1, "SCPU Avg. Sleep Time: %d\n", (SCPUtotalStime)/SCPUtotalCounter);
 262:	8b 45 c8             	mov    -0x38(%ebp),%eax
 265:	89 c2                	mov    %eax,%edx
 267:	c1 fa 1f             	sar    $0x1f,%edx
 26a:	f7 7d ec             	idivl  -0x14(%ebp)
 26d:	89 44 24 08          	mov    %eax,0x8(%esp)
 271:	c7 44 24 04 18 0d 00 	movl   $0xd18,0x4(%esp)
 278:	00 
 279:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 280:	e8 ce 05 00 00       	call   853 <printf>
  printf(1, "IO   Avg. Sleep Time: %d\n\n", (IOtotalStime)/IOtotalCounter);
 285:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 288:	89 c2                	mov    %eax,%edx
 28a:	c1 fa 1f             	sar    $0x1f,%edx
 28d:	f7 7d e8             	idivl  -0x18(%ebp)
 290:	89 44 24 08          	mov    %eax,0x8(%esp)
 294:	c7 44 24 04 32 0d 00 	movl   $0xd32,0x4(%esp)
 29b:	00 
 29c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a3:	e8 ab 05 00 00       	call   853 <printf>

  printf(1, "CPU  Avg. Turnaround Time: %d\n", (CPUtotalStime+CPUtotalRutime+CPUtotalRetime)/CPUtotalCounter);
 2a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
 2ab:	8b 55 cc             	mov    -0x34(%ebp),%edx
 2ae:	01 d0                	add    %edx,%eax
 2b0:	03 45 e4             	add    -0x1c(%ebp),%eax
 2b3:	89 c2                	mov    %eax,%edx
 2b5:	c1 fa 1f             	sar    $0x1f,%edx
 2b8:	f7 7d f0             	idivl  -0x10(%ebp)
 2bb:	89 44 24 08          	mov    %eax,0x8(%esp)
 2bf:	c7 44 24 04 50 0d 00 	movl   $0xd50,0x4(%esp)
 2c6:	00 
 2c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ce:	e8 80 05 00 00       	call   853 <printf>
  printf(1, "SCPU Avg. Turnaround Time: %d\n", (SCPUtotalStime+SCPUtotalRutime+SCPUtotalRetime)/SCPUtotalCounter);
 2d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2d6:	8b 55 c8             	mov    -0x38(%ebp),%edx
 2d9:	01 d0                	add    %edx,%eax
 2db:	03 45 e0             	add    -0x20(%ebp),%eax
 2de:	89 c2                	mov    %eax,%edx
 2e0:	c1 fa 1f             	sar    $0x1f,%edx
 2e3:	f7 7d ec             	idivl  -0x14(%ebp)
 2e6:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ea:	c7 44 24 04 70 0d 00 	movl   $0xd70,0x4(%esp)
 2f1:	00 
 2f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f9:	e8 55 05 00 00       	call   853 <printf>
  printf(1, "IO   Avg. Turnaround Time: %d\n\n", (IOtotalStime+IOtotalRutime+IOtotalRetime)/IOtotalCounter);
 2fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
 301:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 304:	01 d0                	add    %edx,%eax
 306:	03 45 dc             	add    -0x24(%ebp),%eax
 309:	89 c2                	mov    %eax,%edx
 30b:	c1 fa 1f             	sar    $0x1f,%edx
 30e:	f7 7d e8             	idivl  -0x18(%ebp)
 311:	89 44 24 08          	mov    %eax,0x8(%esp)
 315:	c7 44 24 04 90 0d 00 	movl   $0xd90,0x4(%esp)
 31c:	00 
 31d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 324:	e8 2a 05 00 00       	call   853 <printf>
}
 329:	c9                   	leave  
 32a:	c3                   	ret    

0000032b <runSanity>:


void
runSanity(){
 32b:	55                   	push   %ebp
 32c:	89 e5                	mov    %esp,%ebp
 32e:	53                   	push   %ebx
 32f:	83 ec 24             	sub    $0x24,%esp
  int pid=getpid();
 332:	e8 0d 04 00 00       	call   744 <getpid>
 337:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  int j;
  switch (pid%3){
 33a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 33d:	ba 56 55 55 55       	mov    $0x55555556,%edx
 342:	89 c8                	mov    %ecx,%eax
 344:	f7 ea                	imul   %edx
 346:	89 c8                	mov    %ecx,%eax
 348:	c1 f8 1f             	sar    $0x1f,%eax
 34b:	89 d3                	mov    %edx,%ebx
 34d:	29 c3                	sub    %eax,%ebx
 34f:	89 d8                	mov    %ebx,%eax
 351:	89 c2                	mov    %eax,%edx
 353:	01 d2                	add    %edx,%edx
 355:	01 c2                	add    %eax,%edx
 357:	89 c8                	mov    %ecx,%eax
 359:	29 d0                	sub    %edx,%eax
 35b:	83 f8 01             	cmp    $0x1,%eax
 35e:	74 34                	je     394 <runSanity+0x69>
 360:	83 f8 02             	cmp    $0x2,%eax
 363:	74 5f                	je     3c4 <runSanity+0x99>
 365:	85 c0                	test   %eax,%eax
 367:	75 7c                	jne    3e5 <runSanity+0xba>
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 369:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 370:	eb 1a                	jmp    38c <runSanity+0x61>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
 372:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 379:	eb 04                	jmp    37f <runSanity+0x54>
 37b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 37f:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 386:	7e f3                	jle    37b <runSanity+0x50>
  int pid=getpid();
  int i;
  int j;
  switch (pid%3){
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 388:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 38c:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 390:	7e e0                	jle    372 <runSanity+0x47>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;
 392:	eb 52                	jmp    3e6 <runSanity+0xbb>

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 394:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 39b:	eb 1f                	jmp    3bc <runSanity+0x91>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
 39d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 3a4:	eb 04                	jmp    3aa <runSanity+0x7f>
 3a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 3aa:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 3b1:	7e f3                	jle    3a6 <runSanity+0x7b>
        yield();
 3b3:	e8 bc 03 00 00       	call   774 <yield>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3bc:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 3c0:	7e db                	jle    39d <runSanity+0x72>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
        yield();
      }
      break;
 3c2:	eb 22                	jmp    3e6 <runSanity+0xbb>

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3cb:	eb 10                	jmp    3dd <runSanity+0xb2>
        sleep(TIME_TO_SLEEP);
 3cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3d4:	e8 7b 03 00 00       	call   754 <sleep>
        yield();
      }
      break;

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3dd:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 3e1:	7e ea                	jle    3cd <runSanity+0xa2>
        sleep(TIME_TO_SLEEP);
      }
      break;
 3e3:	eb 01                	jmp    3e6 <runSanity+0xbb>

    default:
        break;
 3e5:	90                   	nop
  }
}
 3e6:	83 c4 24             	add    $0x24,%esp
 3e9:	5b                   	pop    %ebx
 3ea:	5d                   	pop    %ebp
 3eb:	c3                   	ret    

000003ec <main>:

int
main(int argc, char *argv[])
{
 3ec:	55                   	push   %ebp
 3ed:	89 e5                	mov    %esp,%ebp
 3ef:	83 e4 f0             	and    $0xfffffff0,%esp
 3f2:	83 ec 20             	sub    $0x20,%esp
  int i;
  if(argc != 2)
 3f5:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 3f9:	74 05                	je     400 <main+0x14>
    exit();
 3fb:	e8 c4 02 00 00       	call   6c4 <exit>
  int n=atoi(argv[1]);
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	83 c0 04             	add    $0x4,%eax
 406:	8b 00                	mov    (%eax),%eax
 408:	89 04 24             	mov    %eax,(%esp)
 40b:	e8 23 02 00 00       	call   633 <atoi>
 410:	89 44 24 18          	mov    %eax,0x18(%esp)

  for (i=0; i<3*n;i++){
 414:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
 41b:	00 
 41c:	eb 1f                	jmp    43d <main+0x51>
    int pid=fork();
 41e:	e8 99 02 00 00       	call   6bc <fork>
 423:	89 44 24 14          	mov    %eax,0x14(%esp)
    if (pid==0) {
 427:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 42c:	75 0a                	jne    438 <main+0x4c>
      runSanity();
 42e:	e8 f8 fe ff ff       	call   32b <runSanity>
      exit();
 433:	e8 8c 02 00 00       	call   6c4 <exit>
  int i;
  if(argc != 2)
    exit();
  int n=atoi(argv[1]);

  for (i=0; i<3*n;i++){
 438:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 43d:	8b 54 24 18          	mov    0x18(%esp),%edx
 441:	89 d0                	mov    %edx,%eax
 443:	01 c0                	add    %eax,%eax
 445:	01 d0                	add    %edx,%eax
 447:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 44b:	7f d1                	jg     41e <main+0x32>
      exit();
    }
  }


getStatistics(n);
 44d:	8b 44 24 18          	mov    0x18(%esp),%eax
 451:	89 04 24             	mov    %eax,(%esp)
 454:	e8 a7 fb ff ff       	call   0 <getStatistics>
  exit();
 459:	e8 66 02 00 00       	call   6c4 <exit>
 45e:	90                   	nop
 45f:	90                   	nop

00000460 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	57                   	push   %edi
 464:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 465:	8b 4d 08             	mov    0x8(%ebp),%ecx
 468:	8b 55 10             	mov    0x10(%ebp),%edx
 46b:	8b 45 0c             	mov    0xc(%ebp),%eax
 46e:	89 cb                	mov    %ecx,%ebx
 470:	89 df                	mov    %ebx,%edi
 472:	89 d1                	mov    %edx,%ecx
 474:	fc                   	cld    
 475:	f3 aa                	rep stos %al,%es:(%edi)
 477:	89 ca                	mov    %ecx,%edx
 479:	89 fb                	mov    %edi,%ebx
 47b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 47e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 481:	5b                   	pop    %ebx
 482:	5f                   	pop    %edi
 483:	5d                   	pop    %ebp
 484:	c3                   	ret    

00000485 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 485:	55                   	push   %ebp
 486:	89 e5                	mov    %esp,%ebp
 488:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 491:	90                   	nop
 492:	8b 45 0c             	mov    0xc(%ebp),%eax
 495:	0f b6 10             	movzbl (%eax),%edx
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	88 10                	mov    %dl,(%eax)
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	0f b6 00             	movzbl (%eax),%eax
 4a3:	84 c0                	test   %al,%al
 4a5:	0f 95 c0             	setne  %al
 4a8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ac:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4b0:	84 c0                	test   %al,%al
 4b2:	75 de                	jne    492 <strcpy+0xd>
    ;
  return os;
 4b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b7:	c9                   	leave  
 4b8:	c3                   	ret    

000004b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4b9:	55                   	push   %ebp
 4ba:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4bc:	eb 08                	jmp    4c6 <strcmp+0xd>
    p++, q++;
 4be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	0f b6 00             	movzbl (%eax),%eax
 4cc:	84 c0                	test   %al,%al
 4ce:	74 10                	je     4e0 <strcmp+0x27>
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	0f b6 10             	movzbl (%eax),%edx
 4d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d9:	0f b6 00             	movzbl (%eax),%eax
 4dc:	38 c2                	cmp    %al,%dl
 4de:	74 de                	je     4be <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 4e0:	8b 45 08             	mov    0x8(%ebp),%eax
 4e3:	0f b6 00             	movzbl (%eax),%eax
 4e6:	0f b6 d0             	movzbl %al,%edx
 4e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ec:	0f b6 00             	movzbl (%eax),%eax
 4ef:	0f b6 c0             	movzbl %al,%eax
 4f2:	89 d1                	mov    %edx,%ecx
 4f4:	29 c1                	sub    %eax,%ecx
 4f6:	89 c8                	mov    %ecx,%eax
}
 4f8:	5d                   	pop    %ebp
 4f9:	c3                   	ret    

000004fa <strlen>:

uint
strlen(char *s)
{
 4fa:	55                   	push   %ebp
 4fb:	89 e5                	mov    %esp,%ebp
 4fd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 500:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 507:	eb 04                	jmp    50d <strlen+0x13>
 509:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 50d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 510:	03 45 08             	add    0x8(%ebp),%eax
 513:	0f b6 00             	movzbl (%eax),%eax
 516:	84 c0                	test   %al,%al
 518:	75 ef                	jne    509 <strlen+0xf>
    ;
  return n;
 51a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51d:	c9                   	leave  
 51e:	c3                   	ret    

0000051f <memset>:

void*
memset(void *dst, int c, uint n)
{
 51f:	55                   	push   %ebp
 520:	89 e5                	mov    %esp,%ebp
 522:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 525:	8b 45 10             	mov    0x10(%ebp),%eax
 528:	89 44 24 08          	mov    %eax,0x8(%esp)
 52c:	8b 45 0c             	mov    0xc(%ebp),%eax
 52f:	89 44 24 04          	mov    %eax,0x4(%esp)
 533:	8b 45 08             	mov    0x8(%ebp),%eax
 536:	89 04 24             	mov    %eax,(%esp)
 539:	e8 22 ff ff ff       	call   460 <stosb>
  return dst;
 53e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 541:	c9                   	leave  
 542:	c3                   	ret    

00000543 <strchr>:

char*
strchr(const char *s, char c)
{
 543:	55                   	push   %ebp
 544:	89 e5                	mov    %esp,%ebp
 546:	83 ec 04             	sub    $0x4,%esp
 549:	8b 45 0c             	mov    0xc(%ebp),%eax
 54c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 54f:	eb 14                	jmp    565 <strchr+0x22>
    if(*s == c)
 551:	8b 45 08             	mov    0x8(%ebp),%eax
 554:	0f b6 00             	movzbl (%eax),%eax
 557:	3a 45 fc             	cmp    -0x4(%ebp),%al
 55a:	75 05                	jne    561 <strchr+0x1e>
      return (char*)s;
 55c:	8b 45 08             	mov    0x8(%ebp),%eax
 55f:	eb 13                	jmp    574 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 561:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 565:	8b 45 08             	mov    0x8(%ebp),%eax
 568:	0f b6 00             	movzbl (%eax),%eax
 56b:	84 c0                	test   %al,%al
 56d:	75 e2                	jne    551 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 56f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 574:	c9                   	leave  
 575:	c3                   	ret    

00000576 <gets>:

char*
gets(char *buf, int max)
{
 576:	55                   	push   %ebp
 577:	89 e5                	mov    %esp,%ebp
 579:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 57c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 583:	eb 44                	jmp    5c9 <gets+0x53>
    cc = read(0, &c, 1);
 585:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 58c:	00 
 58d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 590:	89 44 24 04          	mov    %eax,0x4(%esp)
 594:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 59b:	e8 3c 01 00 00       	call   6dc <read>
 5a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a7:	7e 2d                	jle    5d6 <gets+0x60>
      break;
    buf[i++] = c;
 5a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ac:	03 45 08             	add    0x8(%ebp),%eax
 5af:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 5b3:	88 10                	mov    %dl,(%eax)
 5b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 5b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5bd:	3c 0a                	cmp    $0xa,%al
 5bf:	74 16                	je     5d7 <gets+0x61>
 5c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5c5:	3c 0d                	cmp    $0xd,%al
 5c7:	74 0e                	je     5d7 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cc:	83 c0 01             	add    $0x1,%eax
 5cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 5d2:	7c b1                	jl     585 <gets+0xf>
 5d4:	eb 01                	jmp    5d7 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 5d6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 5d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5da:	03 45 08             	add    0x8(%ebp),%eax
 5dd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5e3:	c9                   	leave  
 5e4:	c3                   	ret    

000005e5 <stat>:

int
stat(char *n, struct stat *st)
{
 5e5:	55                   	push   %ebp
 5e6:	89 e5                	mov    %esp,%ebp
 5e8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 5f2:	00 
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	89 04 24             	mov    %eax,(%esp)
 5f9:	e8 06 01 00 00       	call   704 <open>
 5fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 601:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 605:	79 07                	jns    60e <stat+0x29>
    return -1;
 607:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 60c:	eb 23                	jmp    631 <stat+0x4c>
  r = fstat(fd, st);
 60e:	8b 45 0c             	mov    0xc(%ebp),%eax
 611:	89 44 24 04          	mov    %eax,0x4(%esp)
 615:	8b 45 f4             	mov    -0xc(%ebp),%eax
 618:	89 04 24             	mov    %eax,(%esp)
 61b:	e8 fc 00 00 00       	call   71c <fstat>
 620:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 623:	8b 45 f4             	mov    -0xc(%ebp),%eax
 626:	89 04 24             	mov    %eax,(%esp)
 629:	e8 be 00 00 00       	call   6ec <close>
  return r;
 62e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 631:	c9                   	leave  
 632:	c3                   	ret    

00000633 <atoi>:

int
atoi(const char *s)
{
 633:	55                   	push   %ebp
 634:	89 e5                	mov    %esp,%ebp
 636:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 639:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 640:	eb 23                	jmp    665 <atoi+0x32>
    n = n*10 + *s++ - '0';
 642:	8b 55 fc             	mov    -0x4(%ebp),%edx
 645:	89 d0                	mov    %edx,%eax
 647:	c1 e0 02             	shl    $0x2,%eax
 64a:	01 d0                	add    %edx,%eax
 64c:	01 c0                	add    %eax,%eax
 64e:	89 c2                	mov    %eax,%edx
 650:	8b 45 08             	mov    0x8(%ebp),%eax
 653:	0f b6 00             	movzbl (%eax),%eax
 656:	0f be c0             	movsbl %al,%eax
 659:	01 d0                	add    %edx,%eax
 65b:	83 e8 30             	sub    $0x30,%eax
 65e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 661:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	0f b6 00             	movzbl (%eax),%eax
 66b:	3c 2f                	cmp    $0x2f,%al
 66d:	7e 0a                	jle    679 <atoi+0x46>
 66f:	8b 45 08             	mov    0x8(%ebp),%eax
 672:	0f b6 00             	movzbl (%eax),%eax
 675:	3c 39                	cmp    $0x39,%al
 677:	7e c9                	jle    642 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 67c:	c9                   	leave  
 67d:	c3                   	ret    

0000067e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 67e:	55                   	push   %ebp
 67f:	89 e5                	mov    %esp,%ebp
 681:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 684:	8b 45 08             	mov    0x8(%ebp),%eax
 687:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 68a:	8b 45 0c             	mov    0xc(%ebp),%eax
 68d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 690:	eb 13                	jmp    6a5 <memmove+0x27>
    *dst++ = *src++;
 692:	8b 45 f8             	mov    -0x8(%ebp),%eax
 695:	0f b6 10             	movzbl (%eax),%edx
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	88 10                	mov    %dl,(%eax)
 69d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 6a1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6a9:	0f 9f c0             	setg   %al
 6ac:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6b0:	84 c0                	test   %al,%al
 6b2:	75 de                	jne    692 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6b7:	c9                   	leave  
 6b8:	c3                   	ret    
 6b9:	90                   	nop
 6ba:	90                   	nop
 6bb:	90                   	nop

000006bc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6bc:	b8 01 00 00 00       	mov    $0x1,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	ret    

000006c4 <exit>:
SYSCALL(exit)
 6c4:	b8 02 00 00 00       	mov    $0x2,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	ret    

000006cc <wait>:
SYSCALL(wait)
 6cc:	b8 03 00 00 00       	mov    $0x3,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	ret    

000006d4 <pipe>:
SYSCALL(pipe)
 6d4:	b8 04 00 00 00       	mov    $0x4,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	ret    

000006dc <read>:
SYSCALL(read)
 6dc:	b8 05 00 00 00       	mov    $0x5,%eax
 6e1:	cd 40                	int    $0x40
 6e3:	c3                   	ret    

000006e4 <write>:
SYSCALL(write)
 6e4:	b8 10 00 00 00       	mov    $0x10,%eax
 6e9:	cd 40                	int    $0x40
 6eb:	c3                   	ret    

000006ec <close>:
SYSCALL(close)
 6ec:	b8 15 00 00 00       	mov    $0x15,%eax
 6f1:	cd 40                	int    $0x40
 6f3:	c3                   	ret    

000006f4 <kill>:
SYSCALL(kill)
 6f4:	b8 06 00 00 00       	mov    $0x6,%eax
 6f9:	cd 40                	int    $0x40
 6fb:	c3                   	ret    

000006fc <exec>:
SYSCALL(exec)
 6fc:	b8 07 00 00 00       	mov    $0x7,%eax
 701:	cd 40                	int    $0x40
 703:	c3                   	ret    

00000704 <open>:
SYSCALL(open)
 704:	b8 0f 00 00 00       	mov    $0xf,%eax
 709:	cd 40                	int    $0x40
 70b:	c3                   	ret    

0000070c <mknod>:
SYSCALL(mknod)
 70c:	b8 11 00 00 00       	mov    $0x11,%eax
 711:	cd 40                	int    $0x40
 713:	c3                   	ret    

00000714 <unlink>:
SYSCALL(unlink)
 714:	b8 12 00 00 00       	mov    $0x12,%eax
 719:	cd 40                	int    $0x40
 71b:	c3                   	ret    

0000071c <fstat>:
SYSCALL(fstat)
 71c:	b8 08 00 00 00       	mov    $0x8,%eax
 721:	cd 40                	int    $0x40
 723:	c3                   	ret    

00000724 <link>:
SYSCALL(link)
 724:	b8 13 00 00 00       	mov    $0x13,%eax
 729:	cd 40                	int    $0x40
 72b:	c3                   	ret    

0000072c <mkdir>:
SYSCALL(mkdir)
 72c:	b8 14 00 00 00       	mov    $0x14,%eax
 731:	cd 40                	int    $0x40
 733:	c3                   	ret    

00000734 <chdir>:
SYSCALL(chdir)
 734:	b8 09 00 00 00       	mov    $0x9,%eax
 739:	cd 40                	int    $0x40
 73b:	c3                   	ret    

0000073c <dup>:
SYSCALL(dup)
 73c:	b8 0a 00 00 00       	mov    $0xa,%eax
 741:	cd 40                	int    $0x40
 743:	c3                   	ret    

00000744 <getpid>:
SYSCALL(getpid)
 744:	b8 0b 00 00 00       	mov    $0xb,%eax
 749:	cd 40                	int    $0x40
 74b:	c3                   	ret    

0000074c <sbrk>:
SYSCALL(sbrk)
 74c:	b8 0c 00 00 00       	mov    $0xc,%eax
 751:	cd 40                	int    $0x40
 753:	c3                   	ret    

00000754 <sleep>:
SYSCALL(sleep)
 754:	b8 0d 00 00 00       	mov    $0xd,%eax
 759:	cd 40                	int    $0x40
 75b:	c3                   	ret    

0000075c <uptime>:
SYSCALL(uptime)
 75c:	b8 0e 00 00 00       	mov    $0xe,%eax
 761:	cd 40                	int    $0x40
 763:	c3                   	ret    

00000764 <wait2>:
SYSCALL(wait2)
 764:	b8 16 00 00 00       	mov    $0x16,%eax
 769:	cd 40                	int    $0x40
 76b:	c3                   	ret    

0000076c <set_prio>:
SYSCALL(set_prio)
 76c:	b8 17 00 00 00       	mov    $0x17,%eax
 771:	cd 40                	int    $0x40
 773:	c3                   	ret    

00000774 <yield>:
SYSCALL(yield)
 774:	b8 18 00 00 00       	mov    $0x18,%eax
 779:	cd 40                	int    $0x40
 77b:	c3                   	ret    

0000077c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 77c:	55                   	push   %ebp
 77d:	89 e5                	mov    %esp,%ebp
 77f:	83 ec 28             	sub    $0x28,%esp
 782:	8b 45 0c             	mov    0xc(%ebp),%eax
 785:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 788:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 78f:	00 
 790:	8d 45 f4             	lea    -0xc(%ebp),%eax
 793:	89 44 24 04          	mov    %eax,0x4(%esp)
 797:	8b 45 08             	mov    0x8(%ebp),%eax
 79a:	89 04 24             	mov    %eax,(%esp)
 79d:	e8 42 ff ff ff       	call   6e4 <write>
}
 7a2:	c9                   	leave  
 7a3:	c3                   	ret    

000007a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7a4:	55                   	push   %ebp
 7a5:	89 e5                	mov    %esp,%ebp
 7a7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7b5:	74 17                	je     7ce <printint+0x2a>
 7b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7bb:	79 11                	jns    7ce <printint+0x2a>
    neg = 1;
 7bd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 7c7:	f7 d8                	neg    %eax
 7c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7cc:	eb 06                	jmp    7d4 <printint+0x30>
  } else {
    x = xx;
 7ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 7d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7db:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7e1:	ba 00 00 00 00       	mov    $0x0,%edx
 7e6:	f7 f1                	div    %ecx
 7e8:	89 d0                	mov    %edx,%eax
 7ea:	0f b6 90 38 10 00 00 	movzbl 0x1038(%eax),%edx
 7f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 7f4:	03 45 f4             	add    -0xc(%ebp),%eax
 7f7:	88 10                	mov    %dl,(%eax)
 7f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 7fd:	8b 55 10             	mov    0x10(%ebp),%edx
 800:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 803:	8b 45 ec             	mov    -0x14(%ebp),%eax
 806:	ba 00 00 00 00       	mov    $0x0,%edx
 80b:	f7 75 d4             	divl   -0x2c(%ebp)
 80e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 811:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 815:	75 c4                	jne    7db <printint+0x37>
  if(neg)
 817:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 81b:	74 2a                	je     847 <printint+0xa3>
    buf[i++] = '-';
 81d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 820:	03 45 f4             	add    -0xc(%ebp),%eax
 823:	c6 00 2d             	movb   $0x2d,(%eax)
 826:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 82a:	eb 1b                	jmp    847 <printint+0xa3>
    putc(fd, buf[i]);
 82c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 82f:	03 45 f4             	add    -0xc(%ebp),%eax
 832:	0f b6 00             	movzbl (%eax),%eax
 835:	0f be c0             	movsbl %al,%eax
 838:	89 44 24 04          	mov    %eax,0x4(%esp)
 83c:	8b 45 08             	mov    0x8(%ebp),%eax
 83f:	89 04 24             	mov    %eax,(%esp)
 842:	e8 35 ff ff ff       	call   77c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 847:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 84b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 84f:	79 db                	jns    82c <printint+0x88>
    putc(fd, buf[i]);
}
 851:	c9                   	leave  
 852:	c3                   	ret    

00000853 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 853:	55                   	push   %ebp
 854:	89 e5                	mov    %esp,%ebp
 856:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 859:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 860:	8d 45 0c             	lea    0xc(%ebp),%eax
 863:	83 c0 04             	add    $0x4,%eax
 866:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 869:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 870:	e9 7d 01 00 00       	jmp    9f2 <printf+0x19f>
    c = fmt[i] & 0xff;
 875:	8b 55 0c             	mov    0xc(%ebp),%edx
 878:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87b:	01 d0                	add    %edx,%eax
 87d:	0f b6 00             	movzbl (%eax),%eax
 880:	0f be c0             	movsbl %al,%eax
 883:	25 ff 00 00 00       	and    $0xff,%eax
 888:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 88b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 88f:	75 2c                	jne    8bd <printf+0x6a>
      if(c == '%'){
 891:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 895:	75 0c                	jne    8a3 <printf+0x50>
        state = '%';
 897:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 89e:	e9 4b 01 00 00       	jmp    9ee <printf+0x19b>
      } else {
        putc(fd, c);
 8a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a6:	0f be c0             	movsbl %al,%eax
 8a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ad:	8b 45 08             	mov    0x8(%ebp),%eax
 8b0:	89 04 24             	mov    %eax,(%esp)
 8b3:	e8 c4 fe ff ff       	call   77c <putc>
 8b8:	e9 31 01 00 00       	jmp    9ee <printf+0x19b>
      }
    } else if(state == '%'){
 8bd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8c1:	0f 85 27 01 00 00    	jne    9ee <printf+0x19b>
      if(c == 'd'){
 8c7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8cb:	75 2d                	jne    8fa <printf+0xa7>
        printint(fd, *ap, 10, 1);
 8cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 8d9:	00 
 8da:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 8e1:	00 
 8e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 8e6:	8b 45 08             	mov    0x8(%ebp),%eax
 8e9:	89 04 24             	mov    %eax,(%esp)
 8ec:	e8 b3 fe ff ff       	call   7a4 <printint>
        ap++;
 8f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8f5:	e9 ed 00 00 00       	jmp    9e7 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 8fa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8fe:	74 06                	je     906 <printf+0xb3>
 900:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 904:	75 2d                	jne    933 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 906:	8b 45 e8             	mov    -0x18(%ebp),%eax
 909:	8b 00                	mov    (%eax),%eax
 90b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 912:	00 
 913:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 91a:	00 
 91b:	89 44 24 04          	mov    %eax,0x4(%esp)
 91f:	8b 45 08             	mov    0x8(%ebp),%eax
 922:	89 04 24             	mov    %eax,(%esp)
 925:	e8 7a fe ff ff       	call   7a4 <printint>
        ap++;
 92a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 92e:	e9 b4 00 00 00       	jmp    9e7 <printf+0x194>
      } else if(c == 's'){
 933:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 937:	75 46                	jne    97f <printf+0x12c>
        s = (char*)*ap;
 939:	8b 45 e8             	mov    -0x18(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 941:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 949:	75 27                	jne    972 <printf+0x11f>
          s = "(null)";
 94b:	c7 45 f4 b0 0d 00 00 	movl   $0xdb0,-0xc(%ebp)
        while(*s != 0){
 952:	eb 1e                	jmp    972 <printf+0x11f>
          putc(fd, *s);
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	0f b6 00             	movzbl (%eax),%eax
 95a:	0f be c0             	movsbl %al,%eax
 95d:	89 44 24 04          	mov    %eax,0x4(%esp)
 961:	8b 45 08             	mov    0x8(%ebp),%eax
 964:	89 04 24             	mov    %eax,(%esp)
 967:	e8 10 fe ff ff       	call   77c <putc>
          s++;
 96c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 970:	eb 01                	jmp    973 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 972:	90                   	nop
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	0f b6 00             	movzbl (%eax),%eax
 979:	84 c0                	test   %al,%al
 97b:	75 d7                	jne    954 <printf+0x101>
 97d:	eb 68                	jmp    9e7 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 97f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 983:	75 1d                	jne    9a2 <printf+0x14f>
        putc(fd, *ap);
 985:	8b 45 e8             	mov    -0x18(%ebp),%eax
 988:	8b 00                	mov    (%eax),%eax
 98a:	0f be c0             	movsbl %al,%eax
 98d:	89 44 24 04          	mov    %eax,0x4(%esp)
 991:	8b 45 08             	mov    0x8(%ebp),%eax
 994:	89 04 24             	mov    %eax,(%esp)
 997:	e8 e0 fd ff ff       	call   77c <putc>
        ap++;
 99c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9a0:	eb 45                	jmp    9e7 <printf+0x194>
      } else if(c == '%'){
 9a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9a6:	75 17                	jne    9bf <printf+0x16c>
        putc(fd, c);
 9a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9ab:	0f be c0             	movsbl %al,%eax
 9ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 9b2:	8b 45 08             	mov    0x8(%ebp),%eax
 9b5:	89 04 24             	mov    %eax,(%esp)
 9b8:	e8 bf fd ff ff       	call   77c <putc>
 9bd:	eb 28                	jmp    9e7 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9bf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 9c6:	00 
 9c7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ca:	89 04 24             	mov    %eax,(%esp)
 9cd:	e8 aa fd ff ff       	call   77c <putc>
        putc(fd, c);
 9d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9d5:	0f be c0             	movsbl %al,%eax
 9d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 9dc:	8b 45 08             	mov    0x8(%ebp),%eax
 9df:	89 04 24             	mov    %eax,(%esp)
 9e2:	e8 95 fd ff ff       	call   77c <putc>
      }
      state = 0;
 9e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 9ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9f2:	8b 55 0c             	mov    0xc(%ebp),%edx
 9f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f8:	01 d0                	add    %edx,%eax
 9fa:	0f b6 00             	movzbl (%eax),%eax
 9fd:	84 c0                	test   %al,%al
 9ff:	0f 85 70 fe ff ff    	jne    875 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a05:	c9                   	leave  
 a06:	c3                   	ret    
 a07:	90                   	nop

00000a08 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a08:	55                   	push   %ebp
 a09:	89 e5                	mov    %esp,%ebp
 a0b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a0e:	8b 45 08             	mov    0x8(%ebp),%eax
 a11:	83 e8 08             	sub    $0x8,%eax
 a14:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a17:	a1 54 10 00 00       	mov    0x1054,%eax
 a1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a1f:	eb 24                	jmp    a45 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a24:	8b 00                	mov    (%eax),%eax
 a26:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a29:	77 12                	ja     a3d <free+0x35>
 a2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a2e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a31:	77 24                	ja     a57 <free+0x4f>
 a33:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a36:	8b 00                	mov    (%eax),%eax
 a38:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a3b:	77 1a                	ja     a57 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a40:	8b 00                	mov    (%eax),%eax
 a42:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a45:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a48:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a4b:	76 d4                	jbe    a21 <free+0x19>
 a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a50:	8b 00                	mov    (%eax),%eax
 a52:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a55:	76 ca                	jbe    a21 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a57:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5a:	8b 40 04             	mov    0x4(%eax),%eax
 a5d:	c1 e0 03             	shl    $0x3,%eax
 a60:	89 c2                	mov    %eax,%edx
 a62:	03 55 f8             	add    -0x8(%ebp),%edx
 a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a68:	8b 00                	mov    (%eax),%eax
 a6a:	39 c2                	cmp    %eax,%edx
 a6c:	75 24                	jne    a92 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 a6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a71:	8b 50 04             	mov    0x4(%eax),%edx
 a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a77:	8b 00                	mov    (%eax),%eax
 a79:	8b 40 04             	mov    0x4(%eax),%eax
 a7c:	01 c2                	add    %eax,%edx
 a7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a81:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a84:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a87:	8b 00                	mov    (%eax),%eax
 a89:	8b 10                	mov    (%eax),%edx
 a8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8e:	89 10                	mov    %edx,(%eax)
 a90:	eb 0a                	jmp    a9c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 a92:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a95:	8b 10                	mov    (%eax),%edx
 a97:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a9a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9f:	8b 40 04             	mov    0x4(%eax),%eax
 aa2:	c1 e0 03             	shl    $0x3,%eax
 aa5:	03 45 fc             	add    -0x4(%ebp),%eax
 aa8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 aab:	75 20                	jne    acd <free+0xc5>
    p->s.size += bp->s.size;
 aad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab0:	8b 50 04             	mov    0x4(%eax),%edx
 ab3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab6:	8b 40 04             	mov    0x4(%eax),%eax
 ab9:	01 c2                	add    %eax,%edx
 abb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ac1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac4:	8b 10                	mov    (%eax),%edx
 ac6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac9:	89 10                	mov    %edx,(%eax)
 acb:	eb 08                	jmp    ad5 <free+0xcd>
  } else
    p->s.ptr = bp;
 acd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 ad3:	89 10                	mov    %edx,(%eax)
  freep = p;
 ad5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad8:	a3 54 10 00 00       	mov    %eax,0x1054
}
 add:	c9                   	leave  
 ade:	c3                   	ret    

00000adf <morecore>:

static Header*
morecore(uint nu)
{
 adf:	55                   	push   %ebp
 ae0:	89 e5                	mov    %esp,%ebp
 ae2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ae5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 aec:	77 07                	ja     af5 <morecore+0x16>
    nu = 4096;
 aee:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 af5:	8b 45 08             	mov    0x8(%ebp),%eax
 af8:	c1 e0 03             	shl    $0x3,%eax
 afb:	89 04 24             	mov    %eax,(%esp)
 afe:	e8 49 fc ff ff       	call   74c <sbrk>
 b03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b06:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b0a:	75 07                	jne    b13 <morecore+0x34>
    return 0;
 b0c:	b8 00 00 00 00       	mov    $0x0,%eax
 b11:	eb 22                	jmp    b35 <morecore+0x56>
  hp = (Header*)p;
 b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b1c:	8b 55 08             	mov    0x8(%ebp),%edx
 b1f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b25:	83 c0 08             	add    $0x8,%eax
 b28:	89 04 24             	mov    %eax,(%esp)
 b2b:	e8 d8 fe ff ff       	call   a08 <free>
  return freep;
 b30:	a1 54 10 00 00       	mov    0x1054,%eax
}
 b35:	c9                   	leave  
 b36:	c3                   	ret    

00000b37 <malloc>:

void*
malloc(uint nbytes)
{
 b37:	55                   	push   %ebp
 b38:	89 e5                	mov    %esp,%ebp
 b3a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b3d:	8b 45 08             	mov    0x8(%ebp),%eax
 b40:	83 c0 07             	add    $0x7,%eax
 b43:	c1 e8 03             	shr    $0x3,%eax
 b46:	83 c0 01             	add    $0x1,%eax
 b49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b4c:	a1 54 10 00 00       	mov    0x1054,%eax
 b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b58:	75 23                	jne    b7d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b5a:	c7 45 f0 4c 10 00 00 	movl   $0x104c,-0x10(%ebp)
 b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b64:	a3 54 10 00 00       	mov    %eax,0x1054
 b69:	a1 54 10 00 00       	mov    0x1054,%eax
 b6e:	a3 4c 10 00 00       	mov    %eax,0x104c
    base.s.size = 0;
 b73:	c7 05 50 10 00 00 00 	movl   $0x0,0x1050
 b7a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b80:	8b 00                	mov    (%eax),%eax
 b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b88:	8b 40 04             	mov    0x4(%eax),%eax
 b8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b8e:	72 4d                	jb     bdd <malloc+0xa6>
      if(p->s.size == nunits)
 b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b93:	8b 40 04             	mov    0x4(%eax),%eax
 b96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b99:	75 0c                	jne    ba7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9e:	8b 10                	mov    (%eax),%edx
 ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba3:	89 10                	mov    %edx,(%eax)
 ba5:	eb 26                	jmp    bcd <malloc+0x96>
      else {
        p->s.size -= nunits;
 ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 baa:	8b 40 04             	mov    0x4(%eax),%eax
 bad:	89 c2                	mov    %eax,%edx
 baf:	2b 55 ec             	sub    -0x14(%ebp),%edx
 bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bbb:	8b 40 04             	mov    0x4(%eax),%eax
 bbe:	c1 e0 03             	shl    $0x3,%eax
 bc1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bca:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd0:	a3 54 10 00 00       	mov    %eax,0x1054
      return (void*)(p + 1);
 bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd8:	83 c0 08             	add    $0x8,%eax
 bdb:	eb 38                	jmp    c15 <malloc+0xde>
    }
    if(p == freep)
 bdd:	a1 54 10 00 00       	mov    0x1054,%eax
 be2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 be5:	75 1b                	jne    c02 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 bea:	89 04 24             	mov    %eax,(%esp)
 bed:	e8 ed fe ff ff       	call   adf <morecore>
 bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bf9:	75 07                	jne    c02 <malloc+0xcb>
        return 0;
 bfb:	b8 00 00 00 00       	mov    $0x0,%eax
 c00:	eb 13                	jmp    c15 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0b:	8b 00                	mov    (%eax),%eax
 c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c10:	e9 70 ff ff ff       	jmp    b85 <malloc+0x4e>
}
 c15:	c9                   	leave  
 c16:	c3                   	ret    
