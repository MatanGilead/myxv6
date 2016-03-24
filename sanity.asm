
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
  7a:	e8 7d 06 00 00       	call   6fc <wait2>
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
  a3:	c7 45 c0 b0 0b 00 00 	movl   $0xbb0,-0x40(%ebp)
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
  e4:	c7 45 c0 b4 0b 00 00 	movl   $0xbb4,-0x40(%ebp)
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
 103:	c7 45 c0 ba 0b 00 00 	movl   $0xbba,-0x40(%ebp)
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
 143:	c7 44 24 04 c0 0b 00 	movl   $0xbc0,0x4(%esp)
 14a:	00 
 14b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 152:	e8 94 06 00 00       	call   7eb <printf>
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
 17c:	c7 44 24 04 fe 0b 00 	movl   $0xbfe,0x4(%esp)
 183:	00 
 184:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18b:	e8 5b 06 00 00       	call   7eb <printf>
  printf(1, "SCPU Avg. Ready Time: %d\n", SCPUtotalRetime/SCPUtotalCounter);
 190:	8b 45 e0             	mov    -0x20(%ebp),%eax
 193:	89 c2                	mov    %eax,%edx
 195:	c1 fa 1f             	sar    $0x1f,%edx
 198:	f7 7d ec             	idivl  -0x14(%ebp)
 19b:	89 44 24 08          	mov    %eax,0x8(%esp)
 19f:	c7 44 24 04 18 0c 00 	movl   $0xc18,0x4(%esp)
 1a6:	00 
 1a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ae:	e8 38 06 00 00       	call   7eb <printf>
  printf(1, "IO   Avg. Ready Time: %d\n\n", IOtotalRetime/IOtotalCounter);
 1b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1b6:	89 c2                	mov    %eax,%edx
 1b8:	c1 fa 1f             	sar    $0x1f,%edx
 1bb:	f7 7d e8             	idivl  -0x18(%ebp)
 1be:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c2:	c7 44 24 04 32 0c 00 	movl   $0xc32,0x4(%esp)
 1c9:	00 
 1ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1d1:	e8 15 06 00 00       	call   7eb <printf>

  printf(1, "CPU  Avg. Run Time: %d\n", CPUtotalRutime/CPUtotalCounter);
 1d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
 1d9:	89 c2                	mov    %eax,%edx
 1db:	c1 fa 1f             	sar    $0x1f,%edx
 1de:	f7 7d f0             	idivl  -0x10(%ebp)
 1e1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e5:	c7 44 24 04 4d 0c 00 	movl   $0xc4d,0x4(%esp)
 1ec:	00 
 1ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1f4:	e8 f2 05 00 00       	call   7eb <printf>
  printf(1, "SCPU Avg. Run Time: %d\n", SCPUtotalRutime/SCPUtotalCounter);
 1f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1fc:	89 c2                	mov    %eax,%edx
 1fe:	c1 fa 1f             	sar    $0x1f,%edx
 201:	f7 7d ec             	idivl  -0x14(%ebp)
 204:	89 44 24 08          	mov    %eax,0x8(%esp)
 208:	c7 44 24 04 65 0c 00 	movl   $0xc65,0x4(%esp)
 20f:	00 
 210:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 217:	e8 cf 05 00 00       	call   7eb <printf>
  printf(1, "IO   Avg. Run Time: %d\n\n", IOtotalRutime/IOtotalCounter);
 21c:	8b 45 d0             	mov    -0x30(%ebp),%eax
 21f:	89 c2                	mov    %eax,%edx
 221:	c1 fa 1f             	sar    $0x1f,%edx
 224:	f7 7d e8             	idivl  -0x18(%ebp)
 227:	89 44 24 08          	mov    %eax,0x8(%esp)
 22b:	c7 44 24 04 7d 0c 00 	movl   $0xc7d,0x4(%esp)
 232:	00 
 233:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 23a:	e8 ac 05 00 00       	call   7eb <printf>

  printf(1, "CPU  Avg. Sleep Time: %d\n", (CPUtotalStime+CPUtotalRutime+CPUtotalRetime)/CPUtotalCounter);
 23f:	8b 45 d8             	mov    -0x28(%ebp),%eax
 242:	8b 55 cc             	mov    -0x34(%ebp),%edx
 245:	01 d0                	add    %edx,%eax
 247:	03 45 e4             	add    -0x1c(%ebp),%eax
 24a:	89 c2                	mov    %eax,%edx
 24c:	c1 fa 1f             	sar    $0x1f,%edx
 24f:	f7 7d f0             	idivl  -0x10(%ebp)
 252:	89 44 24 08          	mov    %eax,0x8(%esp)
 256:	c7 44 24 04 96 0c 00 	movl   $0xc96,0x4(%esp)
 25d:	00 
 25e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 265:	e8 81 05 00 00       	call   7eb <printf>
  printf(1, "SCPU Avg. Sleep Time: %d\n", (SCPUtotalStime+SCPUtotalRutime+SCPUtotalRetime)/SCPUtotalCounter);
 26a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 26d:	8b 55 c8             	mov    -0x38(%ebp),%edx
 270:	01 d0                	add    %edx,%eax
 272:	03 45 e0             	add    -0x20(%ebp),%eax
 275:	89 c2                	mov    %eax,%edx
 277:	c1 fa 1f             	sar    $0x1f,%edx
 27a:	f7 7d ec             	idivl  -0x14(%ebp)
 27d:	89 44 24 08          	mov    %eax,0x8(%esp)
 281:	c7 44 24 04 b0 0c 00 	movl   $0xcb0,0x4(%esp)
 288:	00 
 289:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 290:	e8 56 05 00 00       	call   7eb <printf>
  printf(1, "IO   Avg. Sleep Time: %d\n\n", (IOtotalStime+IOtotalRutime+IOtotalRetime)/IOtotalCounter);
 295:	8b 45 d0             	mov    -0x30(%ebp),%eax
 298:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 29b:	01 d0                	add    %edx,%eax
 29d:	03 45 dc             	add    -0x24(%ebp),%eax
 2a0:	89 c2                	mov    %eax,%edx
 2a2:	c1 fa 1f             	sar    $0x1f,%edx
 2a5:	f7 7d e8             	idivl  -0x18(%ebp)
 2a8:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ac:	c7 44 24 04 ca 0c 00 	movl   $0xcca,0x4(%esp)
 2b3:	00 
 2b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bb:	e8 2b 05 00 00       	call   7eb <printf>
}
 2c0:	c9                   	leave  
 2c1:	c3                   	ret    

000002c2 <runSanity>:


void
runSanity(){
 2c2:	55                   	push   %ebp
 2c3:	89 e5                	mov    %esp,%ebp
 2c5:	53                   	push   %ebx
 2c6:	83 ec 24             	sub    $0x24,%esp
  int pid=getpid();
 2c9:	e8 0e 04 00 00       	call   6dc <getpid>
 2ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  int j;
  switch (pid%3){
 2d1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 2d4:	ba 56 55 55 55       	mov    $0x55555556,%edx
 2d9:	89 c8                	mov    %ecx,%eax
 2db:	f7 ea                	imul   %edx
 2dd:	89 c8                	mov    %ecx,%eax
 2df:	c1 f8 1f             	sar    $0x1f,%eax
 2e2:	89 d3                	mov    %edx,%ebx
 2e4:	29 c3                	sub    %eax,%ebx
 2e6:	89 d8                	mov    %ebx,%eax
 2e8:	89 c2                	mov    %eax,%edx
 2ea:	01 d2                	add    %edx,%edx
 2ec:	01 c2                	add    %eax,%edx
 2ee:	89 c8                	mov    %ecx,%eax
 2f0:	29 d0                	sub    %edx,%eax
 2f2:	83 f8 01             	cmp    $0x1,%eax
 2f5:	74 34                	je     32b <runSanity+0x69>
 2f7:	83 f8 02             	cmp    $0x2,%eax
 2fa:	74 5f                	je     35b <runSanity+0x99>
 2fc:	85 c0                	test   %eax,%eax
 2fe:	75 7c                	jne    37c <runSanity+0xba>
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 300:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 307:	eb 1a                	jmp    323 <runSanity+0x61>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
 309:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 310:	eb 04                	jmp    316 <runSanity+0x54>
 312:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 316:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 31d:	7e f3                	jle    312 <runSanity+0x50>
  int pid=getpid();
  int i;
  int j;
  switch (pid%3){
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 31f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 323:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 327:	7e e0                	jle    309 <runSanity+0x47>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;
 329:	eb 52                	jmp    37d <runSanity+0xbb>

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 32b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 332:	eb 1f                	jmp    353 <runSanity+0x91>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
 334:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 33b:	eb 04                	jmp    341 <runSanity+0x7f>
 33d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 341:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 348:	7e f3                	jle    33d <runSanity+0x7b>
        yield();
 34a:	e8 bd 03 00 00       	call   70c <yield>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 34f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 353:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 357:	7e db                	jle    334 <runSanity+0x72>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
        yield();
      }
      break;
 359:	eb 22                	jmp    37d <runSanity+0xbb>

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 35b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 362:	eb 10                	jmp    374 <runSanity+0xb2>
        sleep(TIME_TO_SLEEP);
 364:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 36b:	e8 7c 03 00 00       	call   6ec <sleep>
        yield();
      }
      break;

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 374:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 378:	7e ea                	jle    364 <runSanity+0xa2>
        sleep(TIME_TO_SLEEP);
      }
      break;
 37a:	eb 01                	jmp    37d <runSanity+0xbb>

    default:
        break;
 37c:	90                   	nop
  }
}
 37d:	83 c4 24             	add    $0x24,%esp
 380:	5b                   	pop    %ebx
 381:	5d                   	pop    %ebp
 382:	c3                   	ret    

00000383 <main>:

int
main(int argc, char *argv[])
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 e4 f0             	and    $0xfffffff0,%esp
 389:	83 ec 20             	sub    $0x20,%esp
  int i;
  if(argc != 2)
 38c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 390:	74 05                	je     397 <main+0x14>
    exit();
 392:	e8 c5 02 00 00       	call   65c <exit>
  int n=atoi(argv[1]);
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	83 c0 04             	add    $0x4,%eax
 39d:	8b 00                	mov    (%eax),%eax
 39f:	89 04 24             	mov    %eax,(%esp)
 3a2:	e8 24 02 00 00       	call   5cb <atoi>
 3a7:	89 44 24 18          	mov    %eax,0x18(%esp)

  for (i=0; i<3*n;i++){
 3ab:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
 3b2:	00 
 3b3:	eb 1f                	jmp    3d4 <main+0x51>
    int pid=fork();
 3b5:	e8 9a 02 00 00       	call   654 <fork>
 3ba:	89 44 24 14          	mov    %eax,0x14(%esp)
    if (pid==0) {
 3be:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 3c3:	75 0a                	jne    3cf <main+0x4c>
      runSanity();
 3c5:	e8 f8 fe ff ff       	call   2c2 <runSanity>
      exit();
 3ca:	e8 8d 02 00 00       	call   65c <exit>
  int i;
  if(argc != 2)
    exit();
  int n=atoi(argv[1]);

  for (i=0; i<3*n;i++){
 3cf:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 3d4:	8b 54 24 18          	mov    0x18(%esp),%edx
 3d8:	89 d0                	mov    %edx,%eax
 3da:	01 c0                	add    %eax,%eax
 3dc:	01 d0                	add    %edx,%eax
 3de:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 3e2:	7f d1                	jg     3b5 <main+0x32>
      exit();
    }
  }


getStatistics(n);
 3e4:	8b 44 24 18          	mov    0x18(%esp),%eax
 3e8:	89 04 24             	mov    %eax,(%esp)
 3eb:	e8 10 fc ff ff       	call   0 <getStatistics>
  exit();
 3f0:	e8 67 02 00 00       	call   65c <exit>
 3f5:	90                   	nop
 3f6:	90                   	nop
 3f7:	90                   	nop

000003f8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	57                   	push   %edi
 3fc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 400:	8b 55 10             	mov    0x10(%ebp),%edx
 403:	8b 45 0c             	mov    0xc(%ebp),%eax
 406:	89 cb                	mov    %ecx,%ebx
 408:	89 df                	mov    %ebx,%edi
 40a:	89 d1                	mov    %edx,%ecx
 40c:	fc                   	cld    
 40d:	f3 aa                	rep stos %al,%es:(%edi)
 40f:	89 ca                	mov    %ecx,%edx
 411:	89 fb                	mov    %edi,%ebx
 413:	89 5d 08             	mov    %ebx,0x8(%ebp)
 416:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 419:	5b                   	pop    %ebx
 41a:	5f                   	pop    %edi
 41b:	5d                   	pop    %ebp
 41c:	c3                   	ret    

0000041d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 41d:	55                   	push   %ebp
 41e:	89 e5                	mov    %esp,%ebp
 420:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 423:	8b 45 08             	mov    0x8(%ebp),%eax
 426:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 429:	90                   	nop
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	0f b6 10             	movzbl (%eax),%edx
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	88 10                	mov    %dl,(%eax)
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	0f b6 00             	movzbl (%eax),%eax
 43b:	84 c0                	test   %al,%al
 43d:	0f 95 c0             	setne  %al
 440:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 444:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 448:	84 c0                	test   %al,%al
 44a:	75 de                	jne    42a <strcpy+0xd>
    ;
  return os;
 44c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 44f:	c9                   	leave  
 450:	c3                   	ret    

00000451 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 451:	55                   	push   %ebp
 452:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 454:	eb 08                	jmp    45e <strcmp+0xd>
    p++, q++;
 456:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	84 c0                	test   %al,%al
 466:	74 10                	je     478 <strcmp+0x27>
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	0f b6 10             	movzbl (%eax),%edx
 46e:	8b 45 0c             	mov    0xc(%ebp),%eax
 471:	0f b6 00             	movzbl (%eax),%eax
 474:	38 c2                	cmp    %al,%dl
 476:	74 de                	je     456 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	0f b6 00             	movzbl (%eax),%eax
 47e:	0f b6 d0             	movzbl %al,%edx
 481:	8b 45 0c             	mov    0xc(%ebp),%eax
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	0f b6 c0             	movzbl %al,%eax
 48a:	89 d1                	mov    %edx,%ecx
 48c:	29 c1                	sub    %eax,%ecx
 48e:	89 c8                	mov    %ecx,%eax
}
 490:	5d                   	pop    %ebp
 491:	c3                   	ret    

00000492 <strlen>:

uint
strlen(char *s)
{
 492:	55                   	push   %ebp
 493:	89 e5                	mov    %esp,%ebp
 495:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 498:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 49f:	eb 04                	jmp    4a5 <strlen+0x13>
 4a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4a8:	03 45 08             	add    0x8(%ebp),%eax
 4ab:	0f b6 00             	movzbl (%eax),%eax
 4ae:	84 c0                	test   %al,%al
 4b0:	75 ef                	jne    4a1 <strlen+0xf>
    ;
  return n;
 4b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b5:	c9                   	leave  
 4b6:	c3                   	ret    

000004b7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4b7:	55                   	push   %ebp
 4b8:	89 e5                	mov    %esp,%ebp
 4ba:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 4bd:	8b 45 10             	mov    0x10(%ebp),%eax
 4c0:	89 44 24 08          	mov    %eax,0x8(%esp)
 4c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ce:	89 04 24             	mov    %eax,(%esp)
 4d1:	e8 22 ff ff ff       	call   3f8 <stosb>
  return dst;
 4d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d9:	c9                   	leave  
 4da:	c3                   	ret    

000004db <strchr>:

char*
strchr(const char *s, char c)
{
 4db:	55                   	push   %ebp
 4dc:	89 e5                	mov    %esp,%ebp
 4de:	83 ec 04             	sub    $0x4,%esp
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4e7:	eb 14                	jmp    4fd <strchr+0x22>
    if(*s == c)
 4e9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ec:	0f b6 00             	movzbl (%eax),%eax
 4ef:	3a 45 fc             	cmp    -0x4(%ebp),%al
 4f2:	75 05                	jne    4f9 <strchr+0x1e>
      return (char*)s;
 4f4:	8b 45 08             	mov    0x8(%ebp),%eax
 4f7:	eb 13                	jmp    50c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 4f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
 500:	0f b6 00             	movzbl (%eax),%eax
 503:	84 c0                	test   %al,%al
 505:	75 e2                	jne    4e9 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 507:	b8 00 00 00 00       	mov    $0x0,%eax
}
 50c:	c9                   	leave  
 50d:	c3                   	ret    

0000050e <gets>:

char*
gets(char *buf, int max)
{
 50e:	55                   	push   %ebp
 50f:	89 e5                	mov    %esp,%ebp
 511:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 514:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 51b:	eb 44                	jmp    561 <gets+0x53>
    cc = read(0, &c, 1);
 51d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 524:	00 
 525:	8d 45 ef             	lea    -0x11(%ebp),%eax
 528:	89 44 24 04          	mov    %eax,0x4(%esp)
 52c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 533:	e8 3c 01 00 00       	call   674 <read>
 538:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 53b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 53f:	7e 2d                	jle    56e <gets+0x60>
      break;
    buf[i++] = c;
 541:	8b 45 f4             	mov    -0xc(%ebp),%eax
 544:	03 45 08             	add    0x8(%ebp),%eax
 547:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 54b:	88 10                	mov    %dl,(%eax)
 54d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 551:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 555:	3c 0a                	cmp    $0xa,%al
 557:	74 16                	je     56f <gets+0x61>
 559:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 55d:	3c 0d                	cmp    $0xd,%al
 55f:	74 0e                	je     56f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 561:	8b 45 f4             	mov    -0xc(%ebp),%eax
 564:	83 c0 01             	add    $0x1,%eax
 567:	3b 45 0c             	cmp    0xc(%ebp),%eax
 56a:	7c b1                	jl     51d <gets+0xf>
 56c:	eb 01                	jmp    56f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 56e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 56f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 572:	03 45 08             	add    0x8(%ebp),%eax
 575:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 578:	8b 45 08             	mov    0x8(%ebp),%eax
}
 57b:	c9                   	leave  
 57c:	c3                   	ret    

0000057d <stat>:

int
stat(char *n, struct stat *st)
{
 57d:	55                   	push   %ebp
 57e:	89 e5                	mov    %esp,%ebp
 580:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 583:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 58a:	00 
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	89 04 24             	mov    %eax,(%esp)
 591:	e8 06 01 00 00       	call   69c <open>
 596:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 599:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59d:	79 07                	jns    5a6 <stat+0x29>
    return -1;
 59f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5a4:	eb 23                	jmp    5c9 <stat+0x4c>
  r = fstat(fd, st);
 5a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b0:	89 04 24             	mov    %eax,(%esp)
 5b3:	e8 fc 00 00 00       	call   6b4 <fstat>
 5b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 be 00 00 00       	call   684 <close>
  return r;
 5c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5c9:	c9                   	leave  
 5ca:	c3                   	ret    

000005cb <atoi>:

int
atoi(const char *s)
{
 5cb:	55                   	push   %ebp
 5cc:	89 e5                	mov    %esp,%ebp
 5ce:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5d8:	eb 23                	jmp    5fd <atoi+0x32>
    n = n*10 + *s++ - '0';
 5da:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5dd:	89 d0                	mov    %edx,%eax
 5df:	c1 e0 02             	shl    $0x2,%eax
 5e2:	01 d0                	add    %edx,%eax
 5e4:	01 c0                	add    %eax,%eax
 5e6:	89 c2                	mov    %eax,%edx
 5e8:	8b 45 08             	mov    0x8(%ebp),%eax
 5eb:	0f b6 00             	movzbl (%eax),%eax
 5ee:	0f be c0             	movsbl %al,%eax
 5f1:	01 d0                	add    %edx,%eax
 5f3:	83 e8 30             	sub    $0x30,%eax
 5f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5fd:	8b 45 08             	mov    0x8(%ebp),%eax
 600:	0f b6 00             	movzbl (%eax),%eax
 603:	3c 2f                	cmp    $0x2f,%al
 605:	7e 0a                	jle    611 <atoi+0x46>
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	0f b6 00             	movzbl (%eax),%eax
 60d:	3c 39                	cmp    $0x39,%al
 60f:	7e c9                	jle    5da <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 611:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 614:	c9                   	leave  
 615:	c3                   	ret    

00000616 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 616:	55                   	push   %ebp
 617:	89 e5                	mov    %esp,%ebp
 619:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 61c:	8b 45 08             	mov    0x8(%ebp),%eax
 61f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 622:	8b 45 0c             	mov    0xc(%ebp),%eax
 625:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 628:	eb 13                	jmp    63d <memmove+0x27>
    *dst++ = *src++;
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	0f b6 10             	movzbl (%eax),%edx
 630:	8b 45 fc             	mov    -0x4(%ebp),%eax
 633:	88 10                	mov    %dl,(%eax)
 635:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 639:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 63d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 641:	0f 9f c0             	setg   %al
 644:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 648:	84 c0                	test   %al,%al
 64a:	75 de                	jne    62a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 64f:	c9                   	leave  
 650:	c3                   	ret    
 651:	90                   	nop
 652:	90                   	nop
 653:	90                   	nop

00000654 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 654:	b8 01 00 00 00       	mov    $0x1,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <exit>:
SYSCALL(exit)
 65c:	b8 02 00 00 00       	mov    $0x2,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <wait>:
SYSCALL(wait)
 664:	b8 03 00 00 00       	mov    $0x3,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <pipe>:
SYSCALL(pipe)
 66c:	b8 04 00 00 00       	mov    $0x4,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <read>:
SYSCALL(read)
 674:	b8 05 00 00 00       	mov    $0x5,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <write>:
SYSCALL(write)
 67c:	b8 10 00 00 00       	mov    $0x10,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <close>:
SYSCALL(close)
 684:	b8 15 00 00 00       	mov    $0x15,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <kill>:
SYSCALL(kill)
 68c:	b8 06 00 00 00       	mov    $0x6,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <exec>:
SYSCALL(exec)
 694:	b8 07 00 00 00       	mov    $0x7,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	ret    

0000069c <open>:
SYSCALL(open)
 69c:	b8 0f 00 00 00       	mov    $0xf,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	ret    

000006a4 <mknod>:
SYSCALL(mknod)
 6a4:	b8 11 00 00 00       	mov    $0x11,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	ret    

000006ac <unlink>:
SYSCALL(unlink)
 6ac:	b8 12 00 00 00       	mov    $0x12,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	ret    

000006b4 <fstat>:
SYSCALL(fstat)
 6b4:	b8 08 00 00 00       	mov    $0x8,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	ret    

000006bc <link>:
SYSCALL(link)
 6bc:	b8 13 00 00 00       	mov    $0x13,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	ret    

000006c4 <mkdir>:
SYSCALL(mkdir)
 6c4:	b8 14 00 00 00       	mov    $0x14,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	ret    

000006cc <chdir>:
SYSCALL(chdir)
 6cc:	b8 09 00 00 00       	mov    $0x9,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	ret    

000006d4 <dup>:
SYSCALL(dup)
 6d4:	b8 0a 00 00 00       	mov    $0xa,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	ret    

000006dc <getpid>:
SYSCALL(getpid)
 6dc:	b8 0b 00 00 00       	mov    $0xb,%eax
 6e1:	cd 40                	int    $0x40
 6e3:	c3                   	ret    

000006e4 <sbrk>:
SYSCALL(sbrk)
 6e4:	b8 0c 00 00 00       	mov    $0xc,%eax
 6e9:	cd 40                	int    $0x40
 6eb:	c3                   	ret    

000006ec <sleep>:
SYSCALL(sleep)
 6ec:	b8 0d 00 00 00       	mov    $0xd,%eax
 6f1:	cd 40                	int    $0x40
 6f3:	c3                   	ret    

000006f4 <uptime>:
SYSCALL(uptime)
 6f4:	b8 0e 00 00 00       	mov    $0xe,%eax
 6f9:	cd 40                	int    $0x40
 6fb:	c3                   	ret    

000006fc <wait2>:
SYSCALL(wait2)
 6fc:	b8 16 00 00 00       	mov    $0x16,%eax
 701:	cd 40                	int    $0x40
 703:	c3                   	ret    

00000704 <set_prio>:
SYSCALL(set_prio)
 704:	b8 17 00 00 00       	mov    $0x17,%eax
 709:	cd 40                	int    $0x40
 70b:	c3                   	ret    

0000070c <yield>:
SYSCALL(yield)
 70c:	b8 18 00 00 00       	mov    $0x18,%eax
 711:	cd 40                	int    $0x40
 713:	c3                   	ret    

00000714 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 714:	55                   	push   %ebp
 715:	89 e5                	mov    %esp,%ebp
 717:	83 ec 28             	sub    $0x28,%esp
 71a:	8b 45 0c             	mov    0xc(%ebp),%eax
 71d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 720:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 727:	00 
 728:	8d 45 f4             	lea    -0xc(%ebp),%eax
 72b:	89 44 24 04          	mov    %eax,0x4(%esp)
 72f:	8b 45 08             	mov    0x8(%ebp),%eax
 732:	89 04 24             	mov    %eax,(%esp)
 735:	e8 42 ff ff ff       	call   67c <write>
}
 73a:	c9                   	leave  
 73b:	c3                   	ret    

0000073c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 73c:	55                   	push   %ebp
 73d:	89 e5                	mov    %esp,%ebp
 73f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 742:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 749:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 74d:	74 17                	je     766 <printint+0x2a>
 74f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 753:	79 11                	jns    766 <printint+0x2a>
    neg = 1;
 755:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 75c:	8b 45 0c             	mov    0xc(%ebp),%eax
 75f:	f7 d8                	neg    %eax
 761:	89 45 ec             	mov    %eax,-0x14(%ebp)
 764:	eb 06                	jmp    76c <printint+0x30>
  } else {
    x = xx;
 766:	8b 45 0c             	mov    0xc(%ebp),%eax
 769:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 76c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 773:	8b 4d 10             	mov    0x10(%ebp),%ecx
 776:	8b 45 ec             	mov    -0x14(%ebp),%eax
 779:	ba 00 00 00 00       	mov    $0x0,%edx
 77e:	f7 f1                	div    %ecx
 780:	89 d0                	mov    %edx,%eax
 782:	0f b6 90 6c 0f 00 00 	movzbl 0xf6c(%eax),%edx
 789:	8d 45 dc             	lea    -0x24(%ebp),%eax
 78c:	03 45 f4             	add    -0xc(%ebp),%eax
 78f:	88 10                	mov    %dl,(%eax)
 791:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 795:	8b 55 10             	mov    0x10(%ebp),%edx
 798:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 79b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 79e:	ba 00 00 00 00       	mov    $0x0,%edx
 7a3:	f7 75 d4             	divl   -0x2c(%ebp)
 7a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7ad:	75 c4                	jne    773 <printint+0x37>
  if(neg)
 7af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b3:	74 2a                	je     7df <printint+0xa3>
    buf[i++] = '-';
 7b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 7b8:	03 45 f4             	add    -0xc(%ebp),%eax
 7bb:	c6 00 2d             	movb   $0x2d,(%eax)
 7be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 7c2:	eb 1b                	jmp    7df <printint+0xa3>
    putc(fd, buf[i]);
 7c4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 7c7:	03 45 f4             	add    -0xc(%ebp),%eax
 7ca:	0f b6 00             	movzbl (%eax),%eax
 7cd:	0f be c0             	movsbl %al,%eax
 7d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d4:	8b 45 08             	mov    0x8(%ebp),%eax
 7d7:	89 04 24             	mov    %eax,(%esp)
 7da:	e8 35 ff ff ff       	call   714 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e7:	79 db                	jns    7c4 <printint+0x88>
    putc(fd, buf[i]);
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    

000007eb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7eb:	55                   	push   %ebp
 7ec:	89 e5                	mov    %esp,%ebp
 7ee:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7f8:	8d 45 0c             	lea    0xc(%ebp),%eax
 7fb:	83 c0 04             	add    $0x4,%eax
 7fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 801:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 808:	e9 7d 01 00 00       	jmp    98a <printf+0x19f>
    c = fmt[i] & 0xff;
 80d:	8b 55 0c             	mov    0xc(%ebp),%edx
 810:	8b 45 f0             	mov    -0x10(%ebp),%eax
 813:	01 d0                	add    %edx,%eax
 815:	0f b6 00             	movzbl (%eax),%eax
 818:	0f be c0             	movsbl %al,%eax
 81b:	25 ff 00 00 00       	and    $0xff,%eax
 820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 823:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 827:	75 2c                	jne    855 <printf+0x6a>
      if(c == '%'){
 829:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 82d:	75 0c                	jne    83b <printf+0x50>
        state = '%';
 82f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 836:	e9 4b 01 00 00       	jmp    986 <printf+0x19b>
      } else {
        putc(fd, c);
 83b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83e:	0f be c0             	movsbl %al,%eax
 841:	89 44 24 04          	mov    %eax,0x4(%esp)
 845:	8b 45 08             	mov    0x8(%ebp),%eax
 848:	89 04 24             	mov    %eax,(%esp)
 84b:	e8 c4 fe ff ff       	call   714 <putc>
 850:	e9 31 01 00 00       	jmp    986 <printf+0x19b>
      }
    } else if(state == '%'){
 855:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 859:	0f 85 27 01 00 00    	jne    986 <printf+0x19b>
      if(c == 'd'){
 85f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 863:	75 2d                	jne    892 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 865:	8b 45 e8             	mov    -0x18(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 871:	00 
 872:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 879:	00 
 87a:	89 44 24 04          	mov    %eax,0x4(%esp)
 87e:	8b 45 08             	mov    0x8(%ebp),%eax
 881:	89 04 24             	mov    %eax,(%esp)
 884:	e8 b3 fe ff ff       	call   73c <printint>
        ap++;
 889:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88d:	e9 ed 00 00 00       	jmp    97f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 892:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 896:	74 06                	je     89e <printf+0xb3>
 898:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 89c:	75 2d                	jne    8cb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 89e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a1:	8b 00                	mov    (%eax),%eax
 8a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 8aa:	00 
 8ab:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8b2:	00 
 8b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ba:	89 04 24             	mov    %eax,(%esp)
 8bd:	e8 7a fe ff ff       	call   73c <printint>
        ap++;
 8c2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8c6:	e9 b4 00 00 00       	jmp    97f <printf+0x194>
      } else if(c == 's'){
 8cb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8cf:	75 46                	jne    917 <printf+0x12c>
        s = (char*)*ap;
 8d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e1:	75 27                	jne    90a <printf+0x11f>
          s = "(null)";
 8e3:	c7 45 f4 e5 0c 00 00 	movl   $0xce5,-0xc(%ebp)
        while(*s != 0){
 8ea:	eb 1e                	jmp    90a <printf+0x11f>
          putc(fd, *s);
 8ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ef:	0f b6 00             	movzbl (%eax),%eax
 8f2:	0f be c0             	movsbl %al,%eax
 8f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f9:	8b 45 08             	mov    0x8(%ebp),%eax
 8fc:	89 04 24             	mov    %eax,(%esp)
 8ff:	e8 10 fe ff ff       	call   714 <putc>
          s++;
 904:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 908:	eb 01                	jmp    90b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 90a:	90                   	nop
 90b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90e:	0f b6 00             	movzbl (%eax),%eax
 911:	84 c0                	test   %al,%al
 913:	75 d7                	jne    8ec <printf+0x101>
 915:	eb 68                	jmp    97f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 917:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 91b:	75 1d                	jne    93a <printf+0x14f>
        putc(fd, *ap);
 91d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 920:	8b 00                	mov    (%eax),%eax
 922:	0f be c0             	movsbl %al,%eax
 925:	89 44 24 04          	mov    %eax,0x4(%esp)
 929:	8b 45 08             	mov    0x8(%ebp),%eax
 92c:	89 04 24             	mov    %eax,(%esp)
 92f:	e8 e0 fd ff ff       	call   714 <putc>
        ap++;
 934:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 938:	eb 45                	jmp    97f <printf+0x194>
      } else if(c == '%'){
 93a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 93e:	75 17                	jne    957 <printf+0x16c>
        putc(fd, c);
 940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 943:	0f be c0             	movsbl %al,%eax
 946:	89 44 24 04          	mov    %eax,0x4(%esp)
 94a:	8b 45 08             	mov    0x8(%ebp),%eax
 94d:	89 04 24             	mov    %eax,(%esp)
 950:	e8 bf fd ff ff       	call   714 <putc>
 955:	eb 28                	jmp    97f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 957:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 95e:	00 
 95f:	8b 45 08             	mov    0x8(%ebp),%eax
 962:	89 04 24             	mov    %eax,(%esp)
 965:	e8 aa fd ff ff       	call   714 <putc>
        putc(fd, c);
 96a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 96d:	0f be c0             	movsbl %al,%eax
 970:	89 44 24 04          	mov    %eax,0x4(%esp)
 974:	8b 45 08             	mov    0x8(%ebp),%eax
 977:	89 04 24             	mov    %eax,(%esp)
 97a:	e8 95 fd ff ff       	call   714 <putc>
      }
      state = 0;
 97f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 986:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 98a:	8b 55 0c             	mov    0xc(%ebp),%edx
 98d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 990:	01 d0                	add    %edx,%eax
 992:	0f b6 00             	movzbl (%eax),%eax
 995:	84 c0                	test   %al,%al
 997:	0f 85 70 fe ff ff    	jne    80d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 99d:	c9                   	leave  
 99e:	c3                   	ret    
 99f:	90                   	nop

000009a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9a0:	55                   	push   %ebp
 9a1:	89 e5                	mov    %esp,%ebp
 9a3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9a6:	8b 45 08             	mov    0x8(%ebp),%eax
 9a9:	83 e8 08             	sub    $0x8,%eax
 9ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9af:	a1 88 0f 00 00       	mov    0xf88,%eax
 9b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9b7:	eb 24                	jmp    9dd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bc:	8b 00                	mov    (%eax),%eax
 9be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c1:	77 12                	ja     9d5 <free+0x35>
 9c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c9:	77 24                	ja     9ef <free+0x4f>
 9cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ce:	8b 00                	mov    (%eax),%eax
 9d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9d3:	77 1a                	ja     9ef <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d8:	8b 00                	mov    (%eax),%eax
 9da:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e3:	76 d4                	jbe    9b9 <free+0x19>
 9e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e8:	8b 00                	mov    (%eax),%eax
 9ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9ed:	76 ca                	jbe    9b9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 9ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f2:	8b 40 04             	mov    0x4(%eax),%eax
 9f5:	c1 e0 03             	shl    $0x3,%eax
 9f8:	89 c2                	mov    %eax,%edx
 9fa:	03 55 f8             	add    -0x8(%ebp),%edx
 9fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a00:	8b 00                	mov    (%eax),%eax
 a02:	39 c2                	cmp    %eax,%edx
 a04:	75 24                	jne    a2a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 a06:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a09:	8b 50 04             	mov    0x4(%eax),%edx
 a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0f:	8b 00                	mov    (%eax),%eax
 a11:	8b 40 04             	mov    0x4(%eax),%eax
 a14:	01 c2                	add    %eax,%edx
 a16:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a19:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1f:	8b 00                	mov    (%eax),%eax
 a21:	8b 10                	mov    (%eax),%edx
 a23:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a26:	89 10                	mov    %edx,(%eax)
 a28:	eb 0a                	jmp    a34 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2d:	8b 10                	mov    (%eax),%edx
 a2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a32:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a37:	8b 40 04             	mov    0x4(%eax),%eax
 a3a:	c1 e0 03             	shl    $0x3,%eax
 a3d:	03 45 fc             	add    -0x4(%ebp),%eax
 a40:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a43:	75 20                	jne    a65 <free+0xc5>
    p->s.size += bp->s.size;
 a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a48:	8b 50 04             	mov    0x4(%eax),%edx
 a4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a4e:	8b 40 04             	mov    0x4(%eax),%eax
 a51:	01 c2                	add    %eax,%edx
 a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a56:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a59:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5c:	8b 10                	mov    (%eax),%edx
 a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a61:	89 10                	mov    %edx,(%eax)
 a63:	eb 08                	jmp    a6d <free+0xcd>
  } else
    p->s.ptr = bp;
 a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a68:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a6b:	89 10                	mov    %edx,(%eax)
  freep = p;
 a6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a70:	a3 88 0f 00 00       	mov    %eax,0xf88
}
 a75:	c9                   	leave  
 a76:	c3                   	ret    

00000a77 <morecore>:

static Header*
morecore(uint nu)
{
 a77:	55                   	push   %ebp
 a78:	89 e5                	mov    %esp,%ebp
 a7a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a7d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a84:	77 07                	ja     a8d <morecore+0x16>
    nu = 4096;
 a86:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a8d:	8b 45 08             	mov    0x8(%ebp),%eax
 a90:	c1 e0 03             	shl    $0x3,%eax
 a93:	89 04 24             	mov    %eax,(%esp)
 a96:	e8 49 fc ff ff       	call   6e4 <sbrk>
 a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a9e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 aa2:	75 07                	jne    aab <morecore+0x34>
    return 0;
 aa4:	b8 00 00 00 00       	mov    $0x0,%eax
 aa9:	eb 22                	jmp    acd <morecore+0x56>
  hp = (Header*)p;
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab4:	8b 55 08             	mov    0x8(%ebp),%edx
 ab7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abd:	83 c0 08             	add    $0x8,%eax
 ac0:	89 04 24             	mov    %eax,(%esp)
 ac3:	e8 d8 fe ff ff       	call   9a0 <free>
  return freep;
 ac8:	a1 88 0f 00 00       	mov    0xf88,%eax
}
 acd:	c9                   	leave  
 ace:	c3                   	ret    

00000acf <malloc>:

void*
malloc(uint nbytes)
{
 acf:	55                   	push   %ebp
 ad0:	89 e5                	mov    %esp,%ebp
 ad2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ad5:	8b 45 08             	mov    0x8(%ebp),%eax
 ad8:	83 c0 07             	add    $0x7,%eax
 adb:	c1 e8 03             	shr    $0x3,%eax
 ade:	83 c0 01             	add    $0x1,%eax
 ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ae4:	a1 88 0f 00 00       	mov    0xf88,%eax
 ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 af0:	75 23                	jne    b15 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 af2:	c7 45 f0 80 0f 00 00 	movl   $0xf80,-0x10(%ebp)
 af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 afc:	a3 88 0f 00 00       	mov    %eax,0xf88
 b01:	a1 88 0f 00 00       	mov    0xf88,%eax
 b06:	a3 80 0f 00 00       	mov    %eax,0xf80
    base.s.size = 0;
 b0b:	c7 05 84 0f 00 00 00 	movl   $0x0,0xf84
 b12:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b18:	8b 00                	mov    (%eax),%eax
 b1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b20:	8b 40 04             	mov    0x4(%eax),%eax
 b23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b26:	72 4d                	jb     b75 <malloc+0xa6>
      if(p->s.size == nunits)
 b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2b:	8b 40 04             	mov    0x4(%eax),%eax
 b2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b31:	75 0c                	jne    b3f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b36:	8b 10                	mov    (%eax),%edx
 b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3b:	89 10                	mov    %edx,(%eax)
 b3d:	eb 26                	jmp    b65 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b42:	8b 40 04             	mov    0x4(%eax),%eax
 b45:	89 c2                	mov    %eax,%edx
 b47:	2b 55 ec             	sub    -0x14(%ebp),%edx
 b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b53:	8b 40 04             	mov    0x4(%eax),%eax
 b56:	c1 e0 03             	shl    $0x3,%eax
 b59:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b62:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b68:	a3 88 0f 00 00       	mov    %eax,0xf88
      return (void*)(p + 1);
 b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b70:	83 c0 08             	add    $0x8,%eax
 b73:	eb 38                	jmp    bad <malloc+0xde>
    }
    if(p == freep)
 b75:	a1 88 0f 00 00       	mov    0xf88,%eax
 b7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b7d:	75 1b                	jne    b9a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 b7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b82:	89 04 24             	mov    %eax,(%esp)
 b85:	e8 ed fe ff ff       	call   a77 <morecore>
 b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b91:	75 07                	jne    b9a <malloc+0xcb>
        return 0;
 b93:	b8 00 00 00 00       	mov    $0x0,%eax
 b98:	eb 13                	jmp    bad <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba3:	8b 00                	mov    (%eax),%eax
 ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ba8:	e9 70 ff ff ff       	jmp    b1d <malloc+0x4e>
}
 bad:	c9                   	leave  
 bae:	c3                   	ret    
