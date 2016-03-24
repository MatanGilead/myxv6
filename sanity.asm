
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <getStatistics>:
#define IO "I\\O"



void
getStatistics(int n){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 68             	sub    $0x68,%esp
  int i;
  int CPUtotalRetime=0;
   6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int SCPUtotalRetime=0;
   d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int IOtotalRetime=0;
  14:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

  int CPUtotalRutime=0;
  1b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  int SCPUtotalRutime=0;
  22:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  int IOtotalRutime=0;
  29:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)

  int CPUtotalStime=0;
  30:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  int SCPUtotalStime=0;
  37:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  int IOtotalStime=0;
  3e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 for (i=0; i<3*n;i++){
  45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4c:	e9 e9 00 00 00       	jmp    13a <getStatistics+0x13a>
    int retime;
    int rutime;
    int stime;
    int pid=wait2(&retime,&rutime,&stime);
  51:	8d 45 bc             	lea    -0x44(%ebp),%eax
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8d 45 c0             	lea    -0x40(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
  62:	89 04 24             	mov    %eax,(%esp)
  65:	e8 06 07 00 00       	call   770 <wait2>
  6a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    char* type;

    if (pid%3==0){
  6d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  70:	ba 56 55 55 55       	mov    $0x55555556,%edx
  75:	89 c8                	mov    %ecx,%eax
  77:	f7 ea                	imul   %edx
  79:	89 c8                	mov    %ecx,%eax
  7b:	c1 f8 1f             	sar    $0x1f,%eax
  7e:	29 c2                	sub    %eax,%edx
  80:	89 d0                	mov    %edx,%eax
  82:	01 c0                	add    %eax,%eax
  84:	01 d0                	add    %edx,%eax
  86:	89 ca                	mov    %ecx,%edx
  88:	29 c2                	sub    %eax,%edx
  8a:	85 d2                	test   %edx,%edx
  8c:	75 1b                	jne    a9 <getStatistics+0xa9>
      type=CPU;
  8e:	c7 45 cc 24 0c 00 00 	movl   $0xc24,-0x34(%ebp)
      CPUtotalRetime+=retime;
  95:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  98:	01 45 f0             	add    %eax,-0x10(%ebp)
      CPUtotalRutime+=rutime;
  9b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  9e:	01 45 e4             	add    %eax,-0x1c(%ebp)
      CPUtotalStime+=stime;
  a1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  a4:	01 45 d8             	add    %eax,-0x28(%ebp)
  a7:	eb 56                	jmp    ff <getStatistics+0xff>
    }
    else if (pid%3==1) {
  a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  ac:	ba 56 55 55 55       	mov    $0x55555556,%edx
  b1:	89 c8                	mov    %ecx,%eax
  b3:	f7 ea                	imul   %edx
  b5:	89 c8                	mov    %ecx,%eax
  b7:	c1 f8 1f             	sar    $0x1f,%eax
  ba:	29 c2                	sub    %eax,%edx
  bc:	89 d0                	mov    %edx,%eax
  be:	01 c0                	add    %eax,%eax
  c0:	01 d0                	add    %edx,%eax
  c2:	89 ca                	mov    %ecx,%edx
  c4:	29 c2                	sub    %eax,%edx
  c6:	83 fa 01             	cmp    $0x1,%edx
  c9:	75 1b                	jne    e6 <getStatistics+0xe6>
      type=SCPU;
  cb:	c7 45 cc 28 0c 00 00 	movl   $0xc28,-0x34(%ebp)
      SCPUtotalRetime+=retime;
  d2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  d5:	01 45 ec             	add    %eax,-0x14(%ebp)
      SCPUtotalRutime+=rutime;
  d8:	8b 45 c0             	mov    -0x40(%ebp),%eax
  db:	01 45 e0             	add    %eax,-0x20(%ebp)
      SCPUtotalStime+=stime;
  de:	8b 45 bc             	mov    -0x44(%ebp),%eax
  e1:	01 45 d4             	add    %eax,-0x2c(%ebp)
  e4:	eb 19                	jmp    ff <getStatistics+0xff>
    }
    else {
    type=IO;
  e6:	c7 45 cc 2e 0c 00 00 	movl   $0xc2e,-0x34(%ebp)
    IOtotalRetime+=retime;
  ed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  f0:	01 45 e8             	add    %eax,-0x18(%ebp)
    IOtotalRutime+=rutime;
  f3:	8b 45 c0             	mov    -0x40(%ebp),%eax
  f6:	01 45 dc             	add    %eax,-0x24(%ebp)
    IOtotalStime+=stime;
  f9:	8b 45 bc             	mov    -0x44(%ebp),%eax
  fc:	01 45 d0             	add    %eax,-0x30(%ebp)
    }
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  ff:	8b 4d bc             	mov    -0x44(%ebp),%ecx
 102:	8b 55 c0             	mov    -0x40(%ebp),%edx
 105:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 108:	89 4c 24 18          	mov    %ecx,0x18(%esp)
 10c:	89 54 24 14          	mov    %edx,0x14(%esp)
 110:	89 44 24 10          	mov    %eax,0x10(%esp)
 114:	8b 45 cc             	mov    -0x34(%ebp),%eax
 117:	89 44 24 0c          	mov    %eax,0xc(%esp)
 11b:	8b 45 c8             	mov    -0x38(%ebp),%eax
 11e:	89 44 24 08          	mov    %eax,0x8(%esp)
 122:	c7 44 24 04 34 0c 00 	movl   $0xc34,0x4(%esp)
 129:	00 
 12a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 131:	e8 29 07 00 00       	call   85f <printf>
  int IOtotalRutime=0;

  int CPUtotalStime=0;
  int SCPUtotalStime=0;
  int IOtotalStime=0;
 for (i=0; i<3*n;i++){
 136:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 13a:	8b 55 08             	mov    0x8(%ebp),%edx
 13d:	89 d0                	mov    %edx,%eax
 13f:	01 c0                	add    %eax,%eax
 141:	01 d0                	add    %edx,%eax
 143:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 146:	0f 8f 05 ff ff ff    	jg     51 <getStatistics+0x51>
    IOtotalRutime+=rutime;
    IOtotalStime+=stime;
    }
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  }
  printf(1, "CPU  Avg. Ready Time: %d\n", CPUtotalRetime/3*n);
 14c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 14f:	ba 56 55 55 55       	mov    $0x55555556,%edx
 154:	89 c8                	mov    %ecx,%eax
 156:	f7 ea                	imul   %edx
 158:	89 c8                	mov    %ecx,%eax
 15a:	c1 f8 1f             	sar    $0x1f,%eax
 15d:	89 d1                	mov    %edx,%ecx
 15f:	29 c1                	sub    %eax,%ecx
 161:	89 c8                	mov    %ecx,%eax
 163:	0f af 45 08          	imul   0x8(%ebp),%eax
 167:	89 44 24 08          	mov    %eax,0x8(%esp)
 16b:	c7 44 24 04 72 0c 00 	movl   $0xc72,0x4(%esp)
 172:	00 
 173:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17a:	e8 e0 06 00 00       	call   85f <printf>
  printf(1, "SCPU Avg. Ready Time: %d\n", SCPUtotalRetime/3*n);
 17f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 182:	ba 56 55 55 55       	mov    $0x55555556,%edx
 187:	89 c8                	mov    %ecx,%eax
 189:	f7 ea                	imul   %edx
 18b:	89 c8                	mov    %ecx,%eax
 18d:	c1 f8 1f             	sar    $0x1f,%eax
 190:	89 d1                	mov    %edx,%ecx
 192:	29 c1                	sub    %eax,%ecx
 194:	89 c8                	mov    %ecx,%eax
 196:	0f af 45 08          	imul   0x8(%ebp),%eax
 19a:	89 44 24 08          	mov    %eax,0x8(%esp)
 19e:	c7 44 24 04 8c 0c 00 	movl   $0xc8c,0x4(%esp)
 1a5:	00 
 1a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ad:	e8 ad 06 00 00       	call   85f <printf>
  printf(1, "IO   Avg. Ready Time: %d\n\n", IOtotalRetime/3*n);
 1b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 1b5:	ba 56 55 55 55       	mov    $0x55555556,%edx
 1ba:	89 c8                	mov    %ecx,%eax
 1bc:	f7 ea                	imul   %edx
 1be:	89 c8                	mov    %ecx,%eax
 1c0:	c1 f8 1f             	sar    $0x1f,%eax
 1c3:	89 d1                	mov    %edx,%ecx
 1c5:	29 c1                	sub    %eax,%ecx
 1c7:	89 c8                	mov    %ecx,%eax
 1c9:	0f af 45 08          	imul   0x8(%ebp),%eax
 1cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d1:	c7 44 24 04 a6 0c 00 	movl   $0xca6,0x4(%esp)
 1d8:	00 
 1d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e0:	e8 7a 06 00 00       	call   85f <printf>

  printf(1, "CPU  Avg. Run Time: %d\n", CPUtotalRutime/3*n);
 1e5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 1e8:	ba 56 55 55 55       	mov    $0x55555556,%edx
 1ed:	89 c8                	mov    %ecx,%eax
 1ef:	f7 ea                	imul   %edx
 1f1:	89 c8                	mov    %ecx,%eax
 1f3:	c1 f8 1f             	sar    $0x1f,%eax
 1f6:	89 d1                	mov    %edx,%ecx
 1f8:	29 c1                	sub    %eax,%ecx
 1fa:	89 c8                	mov    %ecx,%eax
 1fc:	0f af 45 08          	imul   0x8(%ebp),%eax
 200:	89 44 24 08          	mov    %eax,0x8(%esp)
 204:	c7 44 24 04 c1 0c 00 	movl   $0xcc1,0x4(%esp)
 20b:	00 
 20c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 213:	e8 47 06 00 00       	call   85f <printf>
  printf(1, "SCPU Avg. Run Time: %d\n", SCPUtotalRutime/3*n);
 218:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 21b:	ba 56 55 55 55       	mov    $0x55555556,%edx
 220:	89 c8                	mov    %ecx,%eax
 222:	f7 ea                	imul   %edx
 224:	89 c8                	mov    %ecx,%eax
 226:	c1 f8 1f             	sar    $0x1f,%eax
 229:	89 d1                	mov    %edx,%ecx
 22b:	29 c1                	sub    %eax,%ecx
 22d:	89 c8                	mov    %ecx,%eax
 22f:	0f af 45 08          	imul   0x8(%ebp),%eax
 233:	89 44 24 08          	mov    %eax,0x8(%esp)
 237:	c7 44 24 04 d9 0c 00 	movl   $0xcd9,0x4(%esp)
 23e:	00 
 23f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 246:	e8 14 06 00 00       	call   85f <printf>
  printf(1, "IO   Avg. Run Time: %d\n\n", IOtotalRutime/3*n);
 24b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
 24e:	ba 56 55 55 55       	mov    $0x55555556,%edx
 253:	89 c8                	mov    %ecx,%eax
 255:	f7 ea                	imul   %edx
 257:	89 c8                	mov    %ecx,%eax
 259:	c1 f8 1f             	sar    $0x1f,%eax
 25c:	89 d1                	mov    %edx,%ecx
 25e:	29 c1                	sub    %eax,%ecx
 260:	89 c8                	mov    %ecx,%eax
 262:	0f af 45 08          	imul   0x8(%ebp),%eax
 266:	89 44 24 08          	mov    %eax,0x8(%esp)
 26a:	c7 44 24 04 f1 0c 00 	movl   $0xcf1,0x4(%esp)
 271:	00 
 272:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 279:	e8 e1 05 00 00       	call   85f <printf>

  printf(1, "CPU  Avg. Sleep Time: %d\n", (CPUtotalStime+CPUtotalRutime+CPUtotalRetime)/3*n);
 27e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 281:	8b 55 d8             	mov    -0x28(%ebp),%edx
 284:	01 d0                	add    %edx,%eax
 286:	89 c1                	mov    %eax,%ecx
 288:	03 4d f0             	add    -0x10(%ebp),%ecx
 28b:	ba 56 55 55 55       	mov    $0x55555556,%edx
 290:	89 c8                	mov    %ecx,%eax
 292:	f7 ea                	imul   %edx
 294:	89 c8                	mov    %ecx,%eax
 296:	c1 f8 1f             	sar    $0x1f,%eax
 299:	89 d1                	mov    %edx,%ecx
 29b:	29 c1                	sub    %eax,%ecx
 29d:	89 c8                	mov    %ecx,%eax
 29f:	0f af 45 08          	imul   0x8(%ebp),%eax
 2a3:	89 44 24 08          	mov    %eax,0x8(%esp)
 2a7:	c7 44 24 04 0a 0d 00 	movl   $0xd0a,0x4(%esp)
 2ae:	00 
 2af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b6:	e8 a4 05 00 00       	call   85f <printf>
  printf(1, "SCPU Avg. Sleep Time: %d\n", (SCPUtotalStime+SCPUtotalRutime+SCPUtotalRetime)/3*n);
 2bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
 2be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 2c1:	01 d0                	add    %edx,%eax
 2c3:	89 c1                	mov    %eax,%ecx
 2c5:	03 4d ec             	add    -0x14(%ebp),%ecx
 2c8:	ba 56 55 55 55       	mov    $0x55555556,%edx
 2cd:	89 c8                	mov    %ecx,%eax
 2cf:	f7 ea                	imul   %edx
 2d1:	89 c8                	mov    %ecx,%eax
 2d3:	c1 f8 1f             	sar    $0x1f,%eax
 2d6:	89 d1                	mov    %edx,%ecx
 2d8:	29 c1                	sub    %eax,%ecx
 2da:	89 c8                	mov    %ecx,%eax
 2dc:	0f af 45 08          	imul   0x8(%ebp),%eax
 2e0:	89 44 24 08          	mov    %eax,0x8(%esp)
 2e4:	c7 44 24 04 24 0d 00 	movl   $0xd24,0x4(%esp)
 2eb:	00 
 2ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f3:	e8 67 05 00 00       	call   85f <printf>
  printf(1, "IO   Avg. Sleep Time: %d\n\n", (IOtotalStime+IOtotalRutime+IOtotalRetime)/3*n);
 2f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
 2fe:	01 d0                	add    %edx,%eax
 300:	89 c1                	mov    %eax,%ecx
 302:	03 4d e8             	add    -0x18(%ebp),%ecx
 305:	ba 56 55 55 55       	mov    $0x55555556,%edx
 30a:	89 c8                	mov    %ecx,%eax
 30c:	f7 ea                	imul   %edx
 30e:	89 c8                	mov    %ecx,%eax
 310:	c1 f8 1f             	sar    $0x1f,%eax
 313:	89 d1                	mov    %edx,%ecx
 315:	29 c1                	sub    %eax,%ecx
 317:	89 c8                	mov    %ecx,%eax
 319:	0f af 45 08          	imul   0x8(%ebp),%eax
 31d:	89 44 24 08          	mov    %eax,0x8(%esp)
 321:	c7 44 24 04 3e 0d 00 	movl   $0xd3e,0x4(%esp)
 328:	00 
 329:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 330:	e8 2a 05 00 00       	call   85f <printf>
}
 335:	c9                   	leave  
 336:	c3                   	ret    

00000337 <runSanity>:


void
runSanity(){
 337:	55                   	push   %ebp
 338:	89 e5                	mov    %esp,%ebp
 33a:	53                   	push   %ebx
 33b:	83 ec 24             	sub    $0x24,%esp
  int pid=getpid();
 33e:	e8 0d 04 00 00       	call   750 <getpid>
 343:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  int j;
  switch (pid%3){
 346:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 349:	ba 56 55 55 55       	mov    $0x55555556,%edx
 34e:	89 c8                	mov    %ecx,%eax
 350:	f7 ea                	imul   %edx
 352:	89 c8                	mov    %ecx,%eax
 354:	c1 f8 1f             	sar    $0x1f,%eax
 357:	89 d3                	mov    %edx,%ebx
 359:	29 c3                	sub    %eax,%ebx
 35b:	89 d8                	mov    %ebx,%eax
 35d:	89 c2                	mov    %eax,%edx
 35f:	01 d2                	add    %edx,%edx
 361:	01 c2                	add    %eax,%edx
 363:	89 c8                	mov    %ecx,%eax
 365:	29 d0                	sub    %edx,%eax
 367:	83 f8 01             	cmp    $0x1,%eax
 36a:	74 34                	je     3a0 <runSanity+0x69>
 36c:	83 f8 02             	cmp    $0x2,%eax
 36f:	74 5f                	je     3d0 <runSanity+0x99>
 371:	85 c0                	test   %eax,%eax
 373:	75 7c                	jne    3f1 <runSanity+0xba>
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 375:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 37c:	eb 1a                	jmp    398 <runSanity+0x61>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
 37e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 385:	eb 04                	jmp    38b <runSanity+0x54>
 387:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 38b:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 392:	7e f3                	jle    387 <runSanity+0x50>
  int pid=getpid();
  int i;
  int j;
  switch (pid%3){
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 394:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 398:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 39c:	7e e0                	jle    37e <runSanity+0x47>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;
 39e:	eb 52                	jmp    3f2 <runSanity+0xbb>

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3a7:	eb 1f                	jmp    3c8 <runSanity+0x91>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
 3a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 3b0:	eb 04                	jmp    3b6 <runSanity+0x7f>
 3b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 3b6:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 3bd:	7e f3                	jle    3b2 <runSanity+0x7b>
        yield();
 3bf:	e8 bc 03 00 00       	call   780 <yield>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3c8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 3cc:	7e db                	jle    3a9 <runSanity+0x72>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
        yield();
      }
      break;
 3ce:	eb 22                	jmp    3f2 <runSanity+0xbb>

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3d7:	eb 10                	jmp    3e9 <runSanity+0xb2>
        sleep(TIME_TO_SLEEP);
 3d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3e0:	e8 7b 03 00 00       	call   760 <sleep>
        yield();
      }
      break;

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 3e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3e9:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 3ed:	7e ea                	jle    3d9 <runSanity+0xa2>
        sleep(TIME_TO_SLEEP);
      }
      break;
 3ef:	eb 01                	jmp    3f2 <runSanity+0xbb>

    default:
        break;
 3f1:	90                   	nop
  }
}
 3f2:	83 c4 24             	add    $0x24,%esp
 3f5:	5b                   	pop    %ebx
 3f6:	5d                   	pop    %ebp
 3f7:	c3                   	ret    

000003f8 <main>:

int
main(int argc, char *argv[])
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	83 e4 f0             	and    $0xfffffff0,%esp
 3fe:	83 ec 20             	sub    $0x20,%esp
  int i;
  if(argc != 2)
 401:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 405:	74 05                	je     40c <main+0x14>
    exit();
 407:	e8 c4 02 00 00       	call   6d0 <exit>
  int n=atoi(argv[1]);
 40c:	8b 45 0c             	mov    0xc(%ebp),%eax
 40f:	83 c0 04             	add    $0x4,%eax
 412:	8b 00                	mov    (%eax),%eax
 414:	89 04 24             	mov    %eax,(%esp)
 417:	e8 23 02 00 00       	call   63f <atoi>
 41c:	89 44 24 18          	mov    %eax,0x18(%esp)

  for (i=0; i<3*n;i++){
 420:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
 427:	00 
 428:	eb 1f                	jmp    449 <main+0x51>
    int pid=fork();
 42a:	e8 99 02 00 00       	call   6c8 <fork>
 42f:	89 44 24 14          	mov    %eax,0x14(%esp)
    if (pid==0) {
 433:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 438:	75 0a                	jne    444 <main+0x4c>
      runSanity();
 43a:	e8 f8 fe ff ff       	call   337 <runSanity>
      exit();
 43f:	e8 8c 02 00 00       	call   6d0 <exit>
  int i;
  if(argc != 2)
    exit();
  int n=atoi(argv[1]);

  for (i=0; i<3*n;i++){
 444:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 449:	8b 54 24 18          	mov    0x18(%esp),%edx
 44d:	89 d0                	mov    %edx,%eax
 44f:	01 c0                	add    %eax,%eax
 451:	01 d0                	add    %edx,%eax
 453:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 457:	7f d1                	jg     42a <main+0x32>
      exit();
    }
  }


getStatistics(n);
 459:	8b 44 24 18          	mov    0x18(%esp),%eax
 45d:	89 04 24             	mov    %eax,(%esp)
 460:	e8 9b fb ff ff       	call   0 <getStatistics>
  exit();
 465:	e8 66 02 00 00       	call   6d0 <exit>
 46a:	90                   	nop
 46b:	90                   	nop

0000046c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 46c:	55                   	push   %ebp
 46d:	89 e5                	mov    %esp,%ebp
 46f:	57                   	push   %edi
 470:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 471:	8b 4d 08             	mov    0x8(%ebp),%ecx
 474:	8b 55 10             	mov    0x10(%ebp),%edx
 477:	8b 45 0c             	mov    0xc(%ebp),%eax
 47a:	89 cb                	mov    %ecx,%ebx
 47c:	89 df                	mov    %ebx,%edi
 47e:	89 d1                	mov    %edx,%ecx
 480:	fc                   	cld    
 481:	f3 aa                	rep stos %al,%es:(%edi)
 483:	89 ca                	mov    %ecx,%edx
 485:	89 fb                	mov    %edi,%ebx
 487:	89 5d 08             	mov    %ebx,0x8(%ebp)
 48a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 48d:	5b                   	pop    %ebx
 48e:	5f                   	pop    %edi
 48f:	5d                   	pop    %ebp
 490:	c3                   	ret    

00000491 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 491:	55                   	push   %ebp
 492:	89 e5                	mov    %esp,%ebp
 494:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 497:	8b 45 08             	mov    0x8(%ebp),%eax
 49a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 49d:	90                   	nop
 49e:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a1:	0f b6 10             	movzbl (%eax),%edx
 4a4:	8b 45 08             	mov    0x8(%ebp),%eax
 4a7:	88 10                	mov    %dl,(%eax)
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	0f b6 00             	movzbl (%eax),%eax
 4af:	84 c0                	test   %al,%al
 4b1:	0f 95 c0             	setne  %al
 4b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4b8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4bc:	84 c0                	test   %al,%al
 4be:	75 de                	jne    49e <strcpy+0xd>
    ;
  return os;
 4c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c3:	c9                   	leave  
 4c4:	c3                   	ret    

000004c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4c5:	55                   	push   %ebp
 4c6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4c8:	eb 08                	jmp    4d2 <strcmp+0xd>
    p++, q++;
 4ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ce:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4d2:	8b 45 08             	mov    0x8(%ebp),%eax
 4d5:	0f b6 00             	movzbl (%eax),%eax
 4d8:	84 c0                	test   %al,%al
 4da:	74 10                	je     4ec <strcmp+0x27>
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	0f b6 10             	movzbl (%eax),%edx
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	0f b6 00             	movzbl (%eax),%eax
 4e8:	38 c2                	cmp    %al,%dl
 4ea:	74 de                	je     4ca <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 4ec:	8b 45 08             	mov    0x8(%ebp),%eax
 4ef:	0f b6 00             	movzbl (%eax),%eax
 4f2:	0f b6 d0             	movzbl %al,%edx
 4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f8:	0f b6 00             	movzbl (%eax),%eax
 4fb:	0f b6 c0             	movzbl %al,%eax
 4fe:	89 d1                	mov    %edx,%ecx
 500:	29 c1                	sub    %eax,%ecx
 502:	89 c8                	mov    %ecx,%eax
}
 504:	5d                   	pop    %ebp
 505:	c3                   	ret    

00000506 <strlen>:

uint
strlen(char *s)
{
 506:	55                   	push   %ebp
 507:	89 e5                	mov    %esp,%ebp
 509:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 50c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 513:	eb 04                	jmp    519 <strlen+0x13>
 515:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 519:	8b 45 fc             	mov    -0x4(%ebp),%eax
 51c:	03 45 08             	add    0x8(%ebp),%eax
 51f:	0f b6 00             	movzbl (%eax),%eax
 522:	84 c0                	test   %al,%al
 524:	75 ef                	jne    515 <strlen+0xf>
    ;
  return n;
 526:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 529:	c9                   	leave  
 52a:	c3                   	ret    

0000052b <memset>:

void*
memset(void *dst, int c, uint n)
{
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 531:	8b 45 10             	mov    0x10(%ebp),%eax
 534:	89 44 24 08          	mov    %eax,0x8(%esp)
 538:	8b 45 0c             	mov    0xc(%ebp),%eax
 53b:	89 44 24 04          	mov    %eax,0x4(%esp)
 53f:	8b 45 08             	mov    0x8(%ebp),%eax
 542:	89 04 24             	mov    %eax,(%esp)
 545:	e8 22 ff ff ff       	call   46c <stosb>
  return dst;
 54a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 54d:	c9                   	leave  
 54e:	c3                   	ret    

0000054f <strchr>:

char*
strchr(const char *s, char c)
{
 54f:	55                   	push   %ebp
 550:	89 e5                	mov    %esp,%ebp
 552:	83 ec 04             	sub    $0x4,%esp
 555:	8b 45 0c             	mov    0xc(%ebp),%eax
 558:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 55b:	eb 14                	jmp    571 <strchr+0x22>
    if(*s == c)
 55d:	8b 45 08             	mov    0x8(%ebp),%eax
 560:	0f b6 00             	movzbl (%eax),%eax
 563:	3a 45 fc             	cmp    -0x4(%ebp),%al
 566:	75 05                	jne    56d <strchr+0x1e>
      return (char*)s;
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	eb 13                	jmp    580 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 56d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	0f b6 00             	movzbl (%eax),%eax
 577:	84 c0                	test   %al,%al
 579:	75 e2                	jne    55d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 57b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 580:	c9                   	leave  
 581:	c3                   	ret    

00000582 <gets>:

char*
gets(char *buf, int max)
{
 582:	55                   	push   %ebp
 583:	89 e5                	mov    %esp,%ebp
 585:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 588:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 58f:	eb 44                	jmp    5d5 <gets+0x53>
    cc = read(0, &c, 1);
 591:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 598:	00 
 599:	8d 45 ef             	lea    -0x11(%ebp),%eax
 59c:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5a7:	e8 3c 01 00 00       	call   6e8 <read>
 5ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5b3:	7e 2d                	jle    5e2 <gets+0x60>
      break;
    buf[i++] = c;
 5b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b8:	03 45 08             	add    0x8(%ebp),%eax
 5bb:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 5bf:	88 10                	mov    %dl,(%eax)
 5c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 5c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5c9:	3c 0a                	cmp    $0xa,%al
 5cb:	74 16                	je     5e3 <gets+0x61>
 5cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5d1:	3c 0d                	cmp    $0xd,%al
 5d3:	74 0e                	je     5e3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d8:	83 c0 01             	add    $0x1,%eax
 5db:	3b 45 0c             	cmp    0xc(%ebp),%eax
 5de:	7c b1                	jl     591 <gets+0xf>
 5e0:	eb 01                	jmp    5e3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 5e2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 5e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e6:	03 45 08             	add    0x8(%ebp),%eax
 5e9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ef:	c9                   	leave  
 5f0:	c3                   	ret    

000005f1 <stat>:

int
stat(char *n, struct stat *st)
{
 5f1:	55                   	push   %ebp
 5f2:	89 e5                	mov    %esp,%ebp
 5f4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 5fe:	00 
 5ff:	8b 45 08             	mov    0x8(%ebp),%eax
 602:	89 04 24             	mov    %eax,(%esp)
 605:	e8 06 01 00 00       	call   710 <open>
 60a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 60d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 611:	79 07                	jns    61a <stat+0x29>
    return -1;
 613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 618:	eb 23                	jmp    63d <stat+0x4c>
  r = fstat(fd, st);
 61a:	8b 45 0c             	mov    0xc(%ebp),%eax
 61d:	89 44 24 04          	mov    %eax,0x4(%esp)
 621:	8b 45 f4             	mov    -0xc(%ebp),%eax
 624:	89 04 24             	mov    %eax,(%esp)
 627:	e8 fc 00 00 00       	call   728 <fstat>
 62c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 62f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 632:	89 04 24             	mov    %eax,(%esp)
 635:	e8 be 00 00 00       	call   6f8 <close>
  return r;
 63a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 63d:	c9                   	leave  
 63e:	c3                   	ret    

0000063f <atoi>:

int
atoi(const char *s)
{
 63f:	55                   	push   %ebp
 640:	89 e5                	mov    %esp,%ebp
 642:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 645:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 64c:	eb 23                	jmp    671 <atoi+0x32>
    n = n*10 + *s++ - '0';
 64e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 651:	89 d0                	mov    %edx,%eax
 653:	c1 e0 02             	shl    $0x2,%eax
 656:	01 d0                	add    %edx,%eax
 658:	01 c0                	add    %eax,%eax
 65a:	89 c2                	mov    %eax,%edx
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	0f b6 00             	movzbl (%eax),%eax
 662:	0f be c0             	movsbl %al,%eax
 665:	01 d0                	add    %edx,%eax
 667:	83 e8 30             	sub    $0x30,%eax
 66a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 66d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 671:	8b 45 08             	mov    0x8(%ebp),%eax
 674:	0f b6 00             	movzbl (%eax),%eax
 677:	3c 2f                	cmp    $0x2f,%al
 679:	7e 0a                	jle    685 <atoi+0x46>
 67b:	8b 45 08             	mov    0x8(%ebp),%eax
 67e:	0f b6 00             	movzbl (%eax),%eax
 681:	3c 39                	cmp    $0x39,%al
 683:	7e c9                	jle    64e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 688:	c9                   	leave  
 689:	c3                   	ret    

0000068a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 68a:	55                   	push   %ebp
 68b:	89 e5                	mov    %esp,%ebp
 68d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 696:	8b 45 0c             	mov    0xc(%ebp),%eax
 699:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 69c:	eb 13                	jmp    6b1 <memmove+0x27>
    *dst++ = *src++;
 69e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a1:	0f b6 10             	movzbl (%eax),%edx
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	88 10                	mov    %dl,(%eax)
 6a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 6ad:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6b5:	0f 9f c0             	setg   %al
 6b8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6bc:	84 c0                	test   %al,%al
 6be:	75 de                	jne    69e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6c3:	c9                   	leave  
 6c4:	c3                   	ret    
 6c5:	90                   	nop
 6c6:	90                   	nop
 6c7:	90                   	nop

000006c8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6c8:	b8 01 00 00 00       	mov    $0x1,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <exit>:
SYSCALL(exit)
 6d0:	b8 02 00 00 00       	mov    $0x2,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <wait>:
SYSCALL(wait)
 6d8:	b8 03 00 00 00       	mov    $0x3,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <pipe>:
SYSCALL(pipe)
 6e0:	b8 04 00 00 00       	mov    $0x4,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <read>:
SYSCALL(read)
 6e8:	b8 05 00 00 00       	mov    $0x5,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <write>:
SYSCALL(write)
 6f0:	b8 10 00 00 00       	mov    $0x10,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <close>:
SYSCALL(close)
 6f8:	b8 15 00 00 00       	mov    $0x15,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <kill>:
SYSCALL(kill)
 700:	b8 06 00 00 00       	mov    $0x6,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <exec>:
SYSCALL(exec)
 708:	b8 07 00 00 00       	mov    $0x7,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <open>:
SYSCALL(open)
 710:	b8 0f 00 00 00       	mov    $0xf,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <mknod>:
SYSCALL(mknod)
 718:	b8 11 00 00 00       	mov    $0x11,%eax
 71d:	cd 40                	int    $0x40
 71f:	c3                   	ret    

00000720 <unlink>:
SYSCALL(unlink)
 720:	b8 12 00 00 00       	mov    $0x12,%eax
 725:	cd 40                	int    $0x40
 727:	c3                   	ret    

00000728 <fstat>:
SYSCALL(fstat)
 728:	b8 08 00 00 00       	mov    $0x8,%eax
 72d:	cd 40                	int    $0x40
 72f:	c3                   	ret    

00000730 <link>:
SYSCALL(link)
 730:	b8 13 00 00 00       	mov    $0x13,%eax
 735:	cd 40                	int    $0x40
 737:	c3                   	ret    

00000738 <mkdir>:
SYSCALL(mkdir)
 738:	b8 14 00 00 00       	mov    $0x14,%eax
 73d:	cd 40                	int    $0x40
 73f:	c3                   	ret    

00000740 <chdir>:
SYSCALL(chdir)
 740:	b8 09 00 00 00       	mov    $0x9,%eax
 745:	cd 40                	int    $0x40
 747:	c3                   	ret    

00000748 <dup>:
SYSCALL(dup)
 748:	b8 0a 00 00 00       	mov    $0xa,%eax
 74d:	cd 40                	int    $0x40
 74f:	c3                   	ret    

00000750 <getpid>:
SYSCALL(getpid)
 750:	b8 0b 00 00 00       	mov    $0xb,%eax
 755:	cd 40                	int    $0x40
 757:	c3                   	ret    

00000758 <sbrk>:
SYSCALL(sbrk)
 758:	b8 0c 00 00 00       	mov    $0xc,%eax
 75d:	cd 40                	int    $0x40
 75f:	c3                   	ret    

00000760 <sleep>:
SYSCALL(sleep)
 760:	b8 0d 00 00 00       	mov    $0xd,%eax
 765:	cd 40                	int    $0x40
 767:	c3                   	ret    

00000768 <uptime>:
SYSCALL(uptime)
 768:	b8 0e 00 00 00       	mov    $0xe,%eax
 76d:	cd 40                	int    $0x40
 76f:	c3                   	ret    

00000770 <wait2>:
SYSCALL(wait2)
 770:	b8 16 00 00 00       	mov    $0x16,%eax
 775:	cd 40                	int    $0x40
 777:	c3                   	ret    

00000778 <set_prio>:
SYSCALL(set_prio)
 778:	b8 17 00 00 00       	mov    $0x17,%eax
 77d:	cd 40                	int    $0x40
 77f:	c3                   	ret    

00000780 <yield>:
SYSCALL(yield)
 780:	b8 18 00 00 00       	mov    $0x18,%eax
 785:	cd 40                	int    $0x40
 787:	c3                   	ret    

00000788 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 788:	55                   	push   %ebp
 789:	89 e5                	mov    %esp,%ebp
 78b:	83 ec 28             	sub    $0x28,%esp
 78e:	8b 45 0c             	mov    0xc(%ebp),%eax
 791:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 794:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 79b:	00 
 79c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 79f:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a3:	8b 45 08             	mov    0x8(%ebp),%eax
 7a6:	89 04 24             	mov    %eax,(%esp)
 7a9:	e8 42 ff ff ff       	call   6f0 <write>
}
 7ae:	c9                   	leave  
 7af:	c3                   	ret    

000007b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7bd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7c1:	74 17                	je     7da <printint+0x2a>
 7c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7c7:	79 11                	jns    7da <printint+0x2a>
    neg = 1;
 7c9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 7d3:	f7 d8                	neg    %eax
 7d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7d8:	eb 06                	jmp    7e0 <printint+0x30>
  } else {
    x = xx;
 7da:	8b 45 0c             	mov    0xc(%ebp),%eax
 7dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ed:	ba 00 00 00 00       	mov    $0x0,%edx
 7f2:	f7 f1                	div    %ecx
 7f4:	89 d0                	mov    %edx,%eax
 7f6:	0f b6 90 e0 0f 00 00 	movzbl 0xfe0(%eax),%edx
 7fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 800:	03 45 f4             	add    -0xc(%ebp),%eax
 803:	88 10                	mov    %dl,(%eax)
 805:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 809:	8b 55 10             	mov    0x10(%ebp),%edx
 80c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 80f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 812:	ba 00 00 00 00       	mov    $0x0,%edx
 817:	f7 75 d4             	divl   -0x2c(%ebp)
 81a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 81d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 821:	75 c4                	jne    7e7 <printint+0x37>
  if(neg)
 823:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 827:	74 2a                	je     853 <printint+0xa3>
    buf[i++] = '-';
 829:	8d 45 dc             	lea    -0x24(%ebp),%eax
 82c:	03 45 f4             	add    -0xc(%ebp),%eax
 82f:	c6 00 2d             	movb   $0x2d,(%eax)
 832:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 836:	eb 1b                	jmp    853 <printint+0xa3>
    putc(fd, buf[i]);
 838:	8d 45 dc             	lea    -0x24(%ebp),%eax
 83b:	03 45 f4             	add    -0xc(%ebp),%eax
 83e:	0f b6 00             	movzbl (%eax),%eax
 841:	0f be c0             	movsbl %al,%eax
 844:	89 44 24 04          	mov    %eax,0x4(%esp)
 848:	8b 45 08             	mov    0x8(%ebp),%eax
 84b:	89 04 24             	mov    %eax,(%esp)
 84e:	e8 35 ff ff ff       	call   788 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 853:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 85b:	79 db                	jns    838 <printint+0x88>
    putc(fd, buf[i]);
}
 85d:	c9                   	leave  
 85e:	c3                   	ret    

0000085f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 85f:	55                   	push   %ebp
 860:	89 e5                	mov    %esp,%ebp
 862:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 865:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 86c:	8d 45 0c             	lea    0xc(%ebp),%eax
 86f:	83 c0 04             	add    $0x4,%eax
 872:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 875:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 87c:	e9 7d 01 00 00       	jmp    9fe <printf+0x19f>
    c = fmt[i] & 0xff;
 881:	8b 55 0c             	mov    0xc(%ebp),%edx
 884:	8b 45 f0             	mov    -0x10(%ebp),%eax
 887:	01 d0                	add    %edx,%eax
 889:	0f b6 00             	movzbl (%eax),%eax
 88c:	0f be c0             	movsbl %al,%eax
 88f:	25 ff 00 00 00       	and    $0xff,%eax
 894:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 897:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 89b:	75 2c                	jne    8c9 <printf+0x6a>
      if(c == '%'){
 89d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8a1:	75 0c                	jne    8af <printf+0x50>
        state = '%';
 8a3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8aa:	e9 4b 01 00 00       	jmp    9fa <printf+0x19b>
      } else {
        putc(fd, c);
 8af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b2:	0f be c0             	movsbl %al,%eax
 8b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b9:	8b 45 08             	mov    0x8(%ebp),%eax
 8bc:	89 04 24             	mov    %eax,(%esp)
 8bf:	e8 c4 fe ff ff       	call   788 <putc>
 8c4:	e9 31 01 00 00       	jmp    9fa <printf+0x19b>
      }
    } else if(state == '%'){
 8c9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8cd:	0f 85 27 01 00 00    	jne    9fa <printf+0x19b>
      if(c == 'd'){
 8d3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8d7:	75 2d                	jne    906 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 8d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8dc:	8b 00                	mov    (%eax),%eax
 8de:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 8e5:	00 
 8e6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 8ed:	00 
 8ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f2:	8b 45 08             	mov    0x8(%ebp),%eax
 8f5:	89 04 24             	mov    %eax,(%esp)
 8f8:	e8 b3 fe ff ff       	call   7b0 <printint>
        ap++;
 8fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 901:	e9 ed 00 00 00       	jmp    9f3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 906:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 90a:	74 06                	je     912 <printf+0xb3>
 90c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 910:	75 2d                	jne    93f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 912:	8b 45 e8             	mov    -0x18(%ebp),%eax
 915:	8b 00                	mov    (%eax),%eax
 917:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 91e:	00 
 91f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 926:	00 
 927:	89 44 24 04          	mov    %eax,0x4(%esp)
 92b:	8b 45 08             	mov    0x8(%ebp),%eax
 92e:	89 04 24             	mov    %eax,(%esp)
 931:	e8 7a fe ff ff       	call   7b0 <printint>
        ap++;
 936:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 93a:	e9 b4 00 00 00       	jmp    9f3 <printf+0x194>
      } else if(c == 's'){
 93f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 943:	75 46                	jne    98b <printf+0x12c>
        s = (char*)*ap;
 945:	8b 45 e8             	mov    -0x18(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 94d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 951:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 955:	75 27                	jne    97e <printf+0x11f>
          s = "(null)";
 957:	c7 45 f4 59 0d 00 00 	movl   $0xd59,-0xc(%ebp)
        while(*s != 0){
 95e:	eb 1e                	jmp    97e <printf+0x11f>
          putc(fd, *s);
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	0f b6 00             	movzbl (%eax),%eax
 966:	0f be c0             	movsbl %al,%eax
 969:	89 44 24 04          	mov    %eax,0x4(%esp)
 96d:	8b 45 08             	mov    0x8(%ebp),%eax
 970:	89 04 24             	mov    %eax,(%esp)
 973:	e8 10 fe ff ff       	call   788 <putc>
          s++;
 978:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 97c:	eb 01                	jmp    97f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 97e:	90                   	nop
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	0f b6 00             	movzbl (%eax),%eax
 985:	84 c0                	test   %al,%al
 987:	75 d7                	jne    960 <printf+0x101>
 989:	eb 68                	jmp    9f3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 98b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 98f:	75 1d                	jne    9ae <printf+0x14f>
        putc(fd, *ap);
 991:	8b 45 e8             	mov    -0x18(%ebp),%eax
 994:	8b 00                	mov    (%eax),%eax
 996:	0f be c0             	movsbl %al,%eax
 999:	89 44 24 04          	mov    %eax,0x4(%esp)
 99d:	8b 45 08             	mov    0x8(%ebp),%eax
 9a0:	89 04 24             	mov    %eax,(%esp)
 9a3:	e8 e0 fd ff ff       	call   788 <putc>
        ap++;
 9a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9ac:	eb 45                	jmp    9f3 <printf+0x194>
      } else if(c == '%'){
 9ae:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9b2:	75 17                	jne    9cb <printf+0x16c>
        putc(fd, c);
 9b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9b7:	0f be c0             	movsbl %al,%eax
 9ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 9be:	8b 45 08             	mov    0x8(%ebp),%eax
 9c1:	89 04 24             	mov    %eax,(%esp)
 9c4:	e8 bf fd ff ff       	call   788 <putc>
 9c9:	eb 28                	jmp    9f3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9cb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 9d2:	00 
 9d3:	8b 45 08             	mov    0x8(%ebp),%eax
 9d6:	89 04 24             	mov    %eax,(%esp)
 9d9:	e8 aa fd ff ff       	call   788 <putc>
        putc(fd, c);
 9de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9e1:	0f be c0             	movsbl %al,%eax
 9e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 9e8:	8b 45 08             	mov    0x8(%ebp),%eax
 9eb:	89 04 24             	mov    %eax,(%esp)
 9ee:	e8 95 fd ff ff       	call   788 <putc>
      }
      state = 0;
 9f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 9fa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9fe:	8b 55 0c             	mov    0xc(%ebp),%edx
 a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a04:	01 d0                	add    %edx,%eax
 a06:	0f b6 00             	movzbl (%eax),%eax
 a09:	84 c0                	test   %al,%al
 a0b:	0f 85 70 fe ff ff    	jne    881 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a11:	c9                   	leave  
 a12:	c3                   	ret    
 a13:	90                   	nop

00000a14 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a14:	55                   	push   %ebp
 a15:	89 e5                	mov    %esp,%ebp
 a17:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a1a:	8b 45 08             	mov    0x8(%ebp),%eax
 a1d:	83 e8 08             	sub    $0x8,%eax
 a20:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a23:	a1 fc 0f 00 00       	mov    0xffc,%eax
 a28:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a2b:	eb 24                	jmp    a51 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a30:	8b 00                	mov    (%eax),%eax
 a32:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a35:	77 12                	ja     a49 <free+0x35>
 a37:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a3a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a3d:	77 24                	ja     a63 <free+0x4f>
 a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a42:	8b 00                	mov    (%eax),%eax
 a44:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a47:	77 1a                	ja     a63 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4c:	8b 00                	mov    (%eax),%eax
 a4e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a51:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a54:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a57:	76 d4                	jbe    a2d <free+0x19>
 a59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5c:	8b 00                	mov    (%eax),%eax
 a5e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a61:	76 ca                	jbe    a2d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a63:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a66:	8b 40 04             	mov    0x4(%eax),%eax
 a69:	c1 e0 03             	shl    $0x3,%eax
 a6c:	89 c2                	mov    %eax,%edx
 a6e:	03 55 f8             	add    -0x8(%ebp),%edx
 a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a74:	8b 00                	mov    (%eax),%eax
 a76:	39 c2                	cmp    %eax,%edx
 a78:	75 24                	jne    a9e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 a7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a7d:	8b 50 04             	mov    0x4(%eax),%edx
 a80:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a83:	8b 00                	mov    (%eax),%eax
 a85:	8b 40 04             	mov    0x4(%eax),%eax
 a88:	01 c2                	add    %eax,%edx
 a8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a90:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a93:	8b 00                	mov    (%eax),%eax
 a95:	8b 10                	mov    (%eax),%edx
 a97:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a9a:	89 10                	mov    %edx,(%eax)
 a9c:	eb 0a                	jmp    aa8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 a9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa1:	8b 10                	mov    (%eax),%edx
 aa3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 aa8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aab:	8b 40 04             	mov    0x4(%eax),%eax
 aae:	c1 e0 03             	shl    $0x3,%eax
 ab1:	03 45 fc             	add    -0x4(%ebp),%eax
 ab4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ab7:	75 20                	jne    ad9 <free+0xc5>
    p->s.size += bp->s.size;
 ab9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abc:	8b 50 04             	mov    0x4(%eax),%edx
 abf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac2:	8b 40 04             	mov    0x4(%eax),%eax
 ac5:	01 c2                	add    %eax,%edx
 ac7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aca:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 acd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad0:	8b 10                	mov    (%eax),%edx
 ad2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad5:	89 10                	mov    %edx,(%eax)
 ad7:	eb 08                	jmp    ae1 <free+0xcd>
  } else
    p->s.ptr = bp;
 ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 adc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 adf:	89 10                	mov    %edx,(%eax)
  freep = p;
 ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae4:	a3 fc 0f 00 00       	mov    %eax,0xffc
}
 ae9:	c9                   	leave  
 aea:	c3                   	ret    

00000aeb <morecore>:

static Header*
morecore(uint nu)
{
 aeb:	55                   	push   %ebp
 aec:	89 e5                	mov    %esp,%ebp
 aee:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 af1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 af8:	77 07                	ja     b01 <morecore+0x16>
    nu = 4096;
 afa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b01:	8b 45 08             	mov    0x8(%ebp),%eax
 b04:	c1 e0 03             	shl    $0x3,%eax
 b07:	89 04 24             	mov    %eax,(%esp)
 b0a:	e8 49 fc ff ff       	call   758 <sbrk>
 b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b12:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b16:	75 07                	jne    b1f <morecore+0x34>
    return 0;
 b18:	b8 00 00 00 00       	mov    $0x0,%eax
 b1d:	eb 22                	jmp    b41 <morecore+0x56>
  hp = (Header*)p;
 b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b28:	8b 55 08             	mov    0x8(%ebp),%edx
 b2b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b31:	83 c0 08             	add    $0x8,%eax
 b34:	89 04 24             	mov    %eax,(%esp)
 b37:	e8 d8 fe ff ff       	call   a14 <free>
  return freep;
 b3c:	a1 fc 0f 00 00       	mov    0xffc,%eax
}
 b41:	c9                   	leave  
 b42:	c3                   	ret    

00000b43 <malloc>:

void*
malloc(uint nbytes)
{
 b43:	55                   	push   %ebp
 b44:	89 e5                	mov    %esp,%ebp
 b46:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b49:	8b 45 08             	mov    0x8(%ebp),%eax
 b4c:	83 c0 07             	add    $0x7,%eax
 b4f:	c1 e8 03             	shr    $0x3,%eax
 b52:	83 c0 01             	add    $0x1,%eax
 b55:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b58:	a1 fc 0f 00 00       	mov    0xffc,%eax
 b5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b64:	75 23                	jne    b89 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b66:	c7 45 f0 f4 0f 00 00 	movl   $0xff4,-0x10(%ebp)
 b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b70:	a3 fc 0f 00 00       	mov    %eax,0xffc
 b75:	a1 fc 0f 00 00       	mov    0xffc,%eax
 b7a:	a3 f4 0f 00 00       	mov    %eax,0xff4
    base.s.size = 0;
 b7f:	c7 05 f8 0f 00 00 00 	movl   $0x0,0xff8
 b86:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b8c:	8b 00                	mov    (%eax),%eax
 b8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b94:	8b 40 04             	mov    0x4(%eax),%eax
 b97:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b9a:	72 4d                	jb     be9 <malloc+0xa6>
      if(p->s.size == nunits)
 b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9f:	8b 40 04             	mov    0x4(%eax),%eax
 ba2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ba5:	75 0c                	jne    bb3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 baa:	8b 10                	mov    (%eax),%edx
 bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 baf:	89 10                	mov    %edx,(%eax)
 bb1:	eb 26                	jmp    bd9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb6:	8b 40 04             	mov    0x4(%eax),%eax
 bb9:	89 c2                	mov    %eax,%edx
 bbb:	2b 55 ec             	sub    -0x14(%ebp),%edx
 bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc7:	8b 40 04             	mov    0x4(%eax),%eax
 bca:	c1 e0 03             	shl    $0x3,%eax
 bcd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bd6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bdc:	a3 fc 0f 00 00       	mov    %eax,0xffc
      return (void*)(p + 1);
 be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be4:	83 c0 08             	add    $0x8,%eax
 be7:	eb 38                	jmp    c21 <malloc+0xde>
    }
    if(p == freep)
 be9:	a1 fc 0f 00 00       	mov    0xffc,%eax
 bee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 bf1:	75 1b                	jne    c0e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 bf6:	89 04 24             	mov    %eax,(%esp)
 bf9:	e8 ed fe ff ff       	call   aeb <morecore>
 bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c05:	75 07                	jne    c0e <malloc+0xcb>
        return 0;
 c07:	b8 00 00 00 00       	mov    $0x0,%eax
 c0c:	eb 13                	jmp    c21 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c11:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c17:	8b 00                	mov    (%eax),%eax
 c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c1c:	e9 70 ff ff ff       	jmp    b91 <malloc+0x4e>
}
 c21:	c9                   	leave  
 c22:	c3                   	ret    
