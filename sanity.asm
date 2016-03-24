
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <getStatistics>:
#define IO "I\\O"



void
getStatistics(int n){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 58             	sub    $0x58,%esp
  int i;
  int totalRetime=0;
   6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int totalRutime=0;
   d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int totalStime=0;
  14:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 for (i=0; i<3*n;i++){
  1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  22:	e9 c5 00 00 00       	jmp    ec <getStatistics+0xec>
    int retime;
    int rutime;
    int stime;
    int pid=wait2(&retime,&rutime,&stime);
  27:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  2e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  31:	89 44 24 04          	mov    %eax,0x4(%esp)
  35:	8d 45 dc             	lea    -0x24(%ebp),%eax
  38:	89 04 24             	mov    %eax,(%esp)
  3b:	e8 90 05 00 00       	call   5d0 <wait2>
  40:	89 45 e0             	mov    %eax,-0x20(%ebp)
    char* type;
    totalRetime+=retime;
  43:	8b 45 dc             	mov    -0x24(%ebp),%eax
  46:	01 45 f0             	add    %eax,-0x10(%ebp)
    totalRutime+=rutime;
  49:	8b 45 d8             	mov    -0x28(%ebp),%eax
  4c:	01 45 ec             	add    %eax,-0x14(%ebp)
    totalStime+=stime;
  4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  52:	01 45 e8             	add    %eax,-0x18(%ebp)
    if (pid%3==0){
  55:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  58:	ba 56 55 55 55       	mov    $0x55555556,%edx
  5d:	89 c8                	mov    %ecx,%eax
  5f:	f7 ea                	imul   %edx
  61:	89 c8                	mov    %ecx,%eax
  63:	c1 f8 1f             	sar    $0x1f,%eax
  66:	29 c2                	sub    %eax,%edx
  68:	89 d0                	mov    %edx,%eax
  6a:	01 c0                	add    %eax,%eax
  6c:	01 d0                	add    %edx,%eax
  6e:	89 ca                	mov    %ecx,%edx
  70:	29 c2                	sub    %eax,%edx
  72:	85 d2                	test   %edx,%edx
  74:	75 09                	jne    7f <getStatistics+0x7f>
      type=CPU;
  76:	c7 45 e4 84 0a 00 00 	movl   $0xa84,-0x1c(%ebp)
  7d:	eb 32                	jmp    b1 <getStatistics+0xb1>
    }
    else if (pid%3==1) {
  7f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  82:	ba 56 55 55 55       	mov    $0x55555556,%edx
  87:	89 c8                	mov    %ecx,%eax
  89:	f7 ea                	imul   %edx
  8b:	89 c8                	mov    %ecx,%eax
  8d:	c1 f8 1f             	sar    $0x1f,%eax
  90:	29 c2                	sub    %eax,%edx
  92:	89 d0                	mov    %edx,%eax
  94:	01 c0                	add    %eax,%eax
  96:	01 d0                	add    %edx,%eax
  98:	89 ca                	mov    %ecx,%edx
  9a:	29 c2                	sub    %eax,%edx
  9c:	83 fa 01             	cmp    $0x1,%edx
  9f:	75 09                	jne    aa <getStatistics+0xaa>
      type=SCPU;
  a1:	c7 45 e4 88 0a 00 00 	movl   $0xa88,-0x1c(%ebp)
  a8:	eb 07                	jmp    b1 <getStatistics+0xb1>
    }
    else type=IO;
  aa:	c7 45 e4 8e 0a 00 00 	movl   $0xa8e,-0x1c(%ebp)
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  b1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  ba:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  be:	89 54 24 14          	mov    %edx,0x14(%esp)
  c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  d4:	c7 44 24 04 94 0a 00 	movl   $0xa94,0x4(%esp)
  db:	00 
  dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e3:	e8 d7 05 00 00       	call   6bf <printf>
getStatistics(int n){
  int i;
  int totalRetime=0;
  int totalRutime=0;
  int totalStime=0;
 for (i=0; i<3*n;i++){
  e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  ec:	8b 55 08             	mov    0x8(%ebp),%edx
  ef:	89 d0                	mov    %edx,%eax
  f1:	01 c0                	add    %eax,%eax
  f3:	01 d0                	add    %edx,%eax
  f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  f8:	0f 8f 29 ff ff ff    	jg     27 <getStatistics+0x27>
      type=SCPU;
    }
    else type=IO;
  printf(1,"Process PID: %d, Type: %s, Wait: %d  Running: %d   Sleep: %d\n",pid,type,retime,rutime,stime);
  }
  printf(1, "Avg. Ready Time: %d\n", totalRetime/3*n);
  fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 101:	ba 56 55 55 55       	mov    $0x55555556,%edx
 106:	89 c8                	mov    %ecx,%eax
 108:	f7 ea                	imul   %edx
 10a:	89 c8                	mov    %ecx,%eax
 10c:	c1 f8 1f             	sar    $0x1f,%eax
 10f:	89 d1                	mov    %edx,%ecx
 111:	29 c1                	sub    %eax,%ecx
 113:	89 c8                	mov    %ecx,%eax
 115:	0f af 45 08          	imul   0x8(%ebp),%eax
 119:	89 44 24 08          	mov    %eax,0x8(%esp)
 11d:	c7 44 24 04 d2 0a 00 	movl   $0xad2,0x4(%esp)
 124:	00 
 125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12c:	e8 8e 05 00 00       	call   6bf <printf>
  printf(1, "Avg. Run Time: %d\n", totalRutime/3*n);
 131:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 134:	ba 56 55 55 55       	mov    $0x55555556,%edx
 139:	89 c8                	mov    %ecx,%eax
 13b:	f7 ea                	imul   %edx
 13d:	89 c8                	mov    %ecx,%eax
 13f:	c1 f8 1f             	sar    $0x1f,%eax
 142:	89 d1                	mov    %edx,%ecx
 144:	29 c1                	sub    %eax,%ecx
 146:	89 c8                	mov    %ecx,%eax
 148:	0f af 45 08          	imul   0x8(%ebp),%eax
 14c:	89 44 24 08          	mov    %eax,0x8(%esp)
 150:	c7 44 24 04 e7 0a 00 	movl   $0xae7,0x4(%esp)
 157:	00 
 158:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 15f:	e8 5b 05 00 00       	call   6bf <printf>
  printf(1, "Avg. Sleep Time: %d\n", totalStime/3*n);
 164:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 167:	ba 56 55 55 55       	mov    $0x55555556,%edx
 16c:	89 c8                	mov    %ecx,%eax
 16e:	f7 ea                	imul   %edx
 170:	89 c8                	mov    %ecx,%eax
 172:	c1 f8 1f             	sar    $0x1f,%eax
 175:	89 d1                	mov    %edx,%ecx
 177:	29 c1                	sub    %eax,%ecx
 179:	89 c8                	mov    %ecx,%eax
 17b:	0f af 45 08          	imul   0x8(%ebp),%eax
 17f:	89 44 24 08          	mov    %eax,0x8(%esp)
 183:	c7 44 24 04 fa 0a 00 	movl   $0xafa,0x4(%esp)
 18a:	00 
 18b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 192:	e8 28 05 00 00       	call   6bf <printf>
}
 197:	c9                   	leave  
 198:	c3                   	ret    

00000199 <runSanity>:


void
runSanity(){
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	53                   	push   %ebx
 19d:	83 ec 24             	sub    $0x24,%esp
  int pid=getpid();
 1a0:	e8 0b 04 00 00       	call   5b0 <getpid>
 1a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  int j;
  switch (pid%3){
 1a8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 1ab:	ba 56 55 55 55       	mov    $0x55555556,%edx
 1b0:	89 c8                	mov    %ecx,%eax
 1b2:	f7 ea                	imul   %edx
 1b4:	89 c8                	mov    %ecx,%eax
 1b6:	c1 f8 1f             	sar    $0x1f,%eax
 1b9:	89 d3                	mov    %edx,%ebx
 1bb:	29 c3                	sub    %eax,%ebx
 1bd:	89 d8                	mov    %ebx,%eax
 1bf:	89 c2                	mov    %eax,%edx
 1c1:	01 d2                	add    %edx,%edx
 1c3:	01 c2                	add    %eax,%edx
 1c5:	89 c8                	mov    %ecx,%eax
 1c7:	29 d0                	sub    %edx,%eax
 1c9:	83 f8 01             	cmp    $0x1,%eax
 1cc:	74 34                	je     202 <runSanity+0x69>
 1ce:	83 f8 02             	cmp    $0x2,%eax
 1d1:	74 5f                	je     232 <runSanity+0x99>
 1d3:	85 c0                	test   %eax,%eax
 1d5:	75 7c                	jne    253 <runSanity+0xba>
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 1d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1de:	eb 1a                	jmp    1fa <runSanity+0x61>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
 1e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1e7:	eb 04                	jmp    1ed <runSanity+0x54>
 1e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 1ed:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 1f4:	7e f3                	jle    1e9 <runSanity+0x50>
  int pid=getpid();
  int i;
  int j;
  switch (pid%3){
    case 0:
      for (i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 1f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1fa:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1fe:	7e e0                	jle    1e0 <runSanity+0x47>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;
 200:	eb 52                	jmp    254 <runSanity+0xbb>

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 202:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 209:	eb 1f                	jmp    22a <runSanity+0x91>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
 20b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 212:	eb 04                	jmp    218 <runSanity+0x7f>
 214:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 218:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
 21f:	7e f3                	jle    214 <runSanity+0x7b>
        yield();
 221:	e8 ba 03 00 00       	call   5e0 <yield>
        for (j=0;j<NUM_OF_ITERATIONS;j++){}
      }
      break;

    case 1:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 226:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 22a:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 22e:	7e db                	jle    20b <runSanity+0x72>
        for(j=0;j<NUM_OF_ITERATIONS;j++){}
        yield();
      }
      break;
 230:	eb 22                	jmp    254 <runSanity+0xbb>

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 239:	eb 10                	jmp    24b <runSanity+0xb2>
        sleep(TIME_TO_SLEEP);
 23b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 242:	e8 79 03 00 00       	call   5c0 <sleep>
        yield();
      }
      break;

    case 2:
      for(i=0;i<NUM_OF_DUMMY_LOOPS;i++){
 247:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 24b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 24f:	7e ea                	jle    23b <runSanity+0xa2>
        sleep(TIME_TO_SLEEP);
      }
      break;
 251:	eb 01                	jmp    254 <runSanity+0xbb>

    default:
        break;
 253:	90                   	nop
  }
}
 254:	83 c4 24             	add    $0x24,%esp
 257:	5b                   	pop    %ebx
 258:	5d                   	pop    %ebp
 259:	c3                   	ret    

0000025a <main>:

int
main(int argc, char *argv[])
{
 25a:	55                   	push   %ebp
 25b:	89 e5                	mov    %esp,%ebp
 25d:	83 e4 f0             	and    $0xfffffff0,%esp
 260:	83 ec 20             	sub    $0x20,%esp
  int i;
  if(argc != 2)
 263:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 267:	74 05                	je     26e <main+0x14>
    exit();
 269:	e8 c2 02 00 00       	call   530 <exit>
  int n=atoi(argv[1]);
 26e:	8b 45 0c             	mov    0xc(%ebp),%eax
 271:	83 c0 04             	add    $0x4,%eax
 274:	8b 00                	mov    (%eax),%eax
 276:	89 04 24             	mov    %eax,(%esp)
 279:	e8 21 02 00 00       	call   49f <atoi>
 27e:	89 44 24 18          	mov    %eax,0x18(%esp)

  for (i=0; i<3*n;i++){
 282:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
 289:	00 
 28a:	eb 1f                	jmp    2ab <main+0x51>
    int pid=fork();
 28c:	e8 97 02 00 00       	call   528 <fork>
 291:	89 44 24 14          	mov    %eax,0x14(%esp)
    if (pid==0) {
 295:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 29a:	75 0a                	jne    2a6 <main+0x4c>
      runSanity();
 29c:	e8 f8 fe ff ff       	call   199 <runSanity>
      exit();
 2a1:	e8 8a 02 00 00       	call   530 <exit>
  int i;
  if(argc != 2)
    exit();
  int n=atoi(argv[1]);

  for (i=0; i<3*n;i++){
 2a6:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 2ab:	8b 54 24 18          	mov    0x18(%esp),%edx
 2af:	89 d0                	mov    %edx,%eax
 2b1:	01 c0                	add    %eax,%eax
 2b3:	01 d0                	add    %edx,%eax
 2b5:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 2b9:	7f d1                	jg     28c <main+0x32>
      exit();
    }
  }


getStatistics(n);
 2bb:	8b 44 24 18          	mov    0x18(%esp),%eax
 2bf:	89 04 24             	mov    %eax,(%esp)
 2c2:	e8 39 fd ff ff       	call   0 <getStatistics>
  exit();
 2c7:	e8 64 02 00 00       	call   530 <exit>

000002cc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2cc:	55                   	push   %ebp
 2cd:	89 e5                	mov    %esp,%ebp
 2cf:	57                   	push   %edi
 2d0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2d4:	8b 55 10             	mov    0x10(%ebp),%edx
 2d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2da:	89 cb                	mov    %ecx,%ebx
 2dc:	89 df                	mov    %ebx,%edi
 2de:	89 d1                	mov    %edx,%ecx
 2e0:	fc                   	cld    
 2e1:	f3 aa                	rep stos %al,%es:(%edi)
 2e3:	89 ca                	mov    %ecx,%edx
 2e5:	89 fb                	mov    %edi,%ebx
 2e7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2ea:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2ed:	5b                   	pop    %ebx
 2ee:	5f                   	pop    %edi
 2ef:	5d                   	pop    %ebp
 2f0:	c3                   	ret    

000002f1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2f1:	55                   	push   %ebp
 2f2:	89 e5                	mov    %esp,%ebp
 2f4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2fd:	90                   	nop
 2fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 301:	0f b6 10             	movzbl (%eax),%edx
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	88 10                	mov    %dl,(%eax)
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	84 c0                	test   %al,%al
 311:	0f 95 c0             	setne  %al
 314:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 318:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 31c:	84 c0                	test   %al,%al
 31e:	75 de                	jne    2fe <strcpy+0xd>
    ;
  return os;
 320:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 328:	eb 08                	jmp    332 <strcmp+0xd>
    p++, q++;
 32a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 32e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	0f b6 00             	movzbl (%eax),%eax
 338:	84 c0                	test   %al,%al
 33a:	74 10                	je     34c <strcmp+0x27>
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	0f b6 10             	movzbl (%eax),%edx
 342:	8b 45 0c             	mov    0xc(%ebp),%eax
 345:	0f b6 00             	movzbl (%eax),%eax
 348:	38 c2                	cmp    %al,%dl
 34a:	74 de                	je     32a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	0f b6 d0             	movzbl %al,%edx
 355:	8b 45 0c             	mov    0xc(%ebp),%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	0f b6 c0             	movzbl %al,%eax
 35e:	89 d1                	mov    %edx,%ecx
 360:	29 c1                	sub    %eax,%ecx
 362:	89 c8                	mov    %ecx,%eax
}
 364:	5d                   	pop    %ebp
 365:	c3                   	ret    

00000366 <strlen>:

uint
strlen(char *s)
{
 366:	55                   	push   %ebp
 367:	89 e5                	mov    %esp,%ebp
 369:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 36c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 373:	eb 04                	jmp    379 <strlen+0x13>
 375:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 379:	8b 45 fc             	mov    -0x4(%ebp),%eax
 37c:	03 45 08             	add    0x8(%ebp),%eax
 37f:	0f b6 00             	movzbl (%eax),%eax
 382:	84 c0                	test   %al,%al
 384:	75 ef                	jne    375 <strlen+0xf>
    ;
  return n;
 386:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 389:	c9                   	leave  
 38a:	c3                   	ret    

0000038b <memset>:

void*
memset(void *dst, int c, uint n)
{
 38b:	55                   	push   %ebp
 38c:	89 e5                	mov    %esp,%ebp
 38e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 391:	8b 45 10             	mov    0x10(%ebp),%eax
 394:	89 44 24 08          	mov    %eax,0x8(%esp)
 398:	8b 45 0c             	mov    0xc(%ebp),%eax
 39b:	89 44 24 04          	mov    %eax,0x4(%esp)
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	89 04 24             	mov    %eax,(%esp)
 3a5:	e8 22 ff ff ff       	call   2cc <stosb>
  return dst;
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ad:	c9                   	leave  
 3ae:	c3                   	ret    

000003af <strchr>:

char*
strchr(const char *s, char c)
{
 3af:	55                   	push   %ebp
 3b0:	89 e5                	mov    %esp,%ebp
 3b2:	83 ec 04             	sub    $0x4,%esp
 3b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3bb:	eb 14                	jmp    3d1 <strchr+0x22>
    if(*s == c)
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3c6:	75 05                	jne    3cd <strchr+0x1e>
      return (char*)s;
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	eb 13                	jmp    3e0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	84 c0                	test   %al,%al
 3d9:	75 e2                	jne    3bd <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3db:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <gets>:

char*
gets(char *buf, int max)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3ef:	eb 44                	jmp    435 <gets+0x53>
    cc = read(0, &c, 1);
 3f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f8:	00 
 3f9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 400:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 407:	e8 3c 01 00 00       	call   548 <read>
 40c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 40f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 413:	7e 2d                	jle    442 <gets+0x60>
      break;
    buf[i++] = c;
 415:	8b 45 f4             	mov    -0xc(%ebp),%eax
 418:	03 45 08             	add    0x8(%ebp),%eax
 41b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 41f:	88 10                	mov    %dl,(%eax)
 421:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 425:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 429:	3c 0a                	cmp    $0xa,%al
 42b:	74 16                	je     443 <gets+0x61>
 42d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 431:	3c 0d                	cmp    $0xd,%al
 433:	74 0e                	je     443 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 435:	8b 45 f4             	mov    -0xc(%ebp),%eax
 438:	83 c0 01             	add    $0x1,%eax
 43b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 43e:	7c b1                	jl     3f1 <gets+0xf>
 440:	eb 01                	jmp    443 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 442:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 443:	8b 45 f4             	mov    -0xc(%ebp),%eax
 446:	03 45 08             	add    0x8(%ebp),%eax
 449:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 44f:	c9                   	leave  
 450:	c3                   	ret    

00000451 <stat>:

int
stat(char *n, struct stat *st)
{
 451:	55                   	push   %ebp
 452:	89 e5                	mov    %esp,%ebp
 454:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 457:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 45e:	00 
 45f:	8b 45 08             	mov    0x8(%ebp),%eax
 462:	89 04 24             	mov    %eax,(%esp)
 465:	e8 06 01 00 00       	call   570 <open>
 46a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 46d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 471:	79 07                	jns    47a <stat+0x29>
    return -1;
 473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 478:	eb 23                	jmp    49d <stat+0x4c>
  r = fstat(fd, st);
 47a:	8b 45 0c             	mov    0xc(%ebp),%eax
 47d:	89 44 24 04          	mov    %eax,0x4(%esp)
 481:	8b 45 f4             	mov    -0xc(%ebp),%eax
 484:	89 04 24             	mov    %eax,(%esp)
 487:	e8 fc 00 00 00       	call   588 <fstat>
 48c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	89 04 24             	mov    %eax,(%esp)
 495:	e8 be 00 00 00       	call   558 <close>
  return r;
 49a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 49d:	c9                   	leave  
 49e:	c3                   	ret    

0000049f <atoi>:

int
atoi(const char *s)
{
 49f:	55                   	push   %ebp
 4a0:	89 e5                	mov    %esp,%ebp
 4a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ac:	eb 23                	jmp    4d1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4b1:	89 d0                	mov    %edx,%eax
 4b3:	c1 e0 02             	shl    $0x2,%eax
 4b6:	01 d0                	add    %edx,%eax
 4b8:	01 c0                	add    %eax,%eax
 4ba:	89 c2                	mov    %eax,%edx
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	0f b6 00             	movzbl (%eax),%eax
 4c2:	0f be c0             	movsbl %al,%eax
 4c5:	01 d0                	add    %edx,%eax
 4c7:	83 e8 30             	sub    $0x30,%eax
 4ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	3c 2f                	cmp    $0x2f,%al
 4d9:	7e 0a                	jle    4e5 <atoi+0x46>
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	0f b6 00             	movzbl (%eax),%eax
 4e1:	3c 39                	cmp    $0x39,%al
 4e3:	7e c9                	jle    4ae <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e8:	c9                   	leave  
 4e9:	c3                   	ret    

000004ea <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4ea:	55                   	push   %ebp
 4eb:	89 e5                	mov    %esp,%ebp
 4ed:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4fc:	eb 13                	jmp    511 <memmove+0x27>
    *dst++ = *src++;
 4fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 501:	0f b6 10             	movzbl (%eax),%edx
 504:	8b 45 fc             	mov    -0x4(%ebp),%eax
 507:	88 10                	mov    %dl,(%eax)
 509:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 50d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 511:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 515:	0f 9f c0             	setg   %al
 518:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 51c:	84 c0                	test   %al,%al
 51e:	75 de                	jne    4fe <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 520:	8b 45 08             	mov    0x8(%ebp),%eax
}
 523:	c9                   	leave  
 524:	c3                   	ret    
 525:	90                   	nop
 526:	90                   	nop
 527:	90                   	nop

00000528 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 528:	b8 01 00 00 00       	mov    $0x1,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <exit>:
SYSCALL(exit)
 530:	b8 02 00 00 00       	mov    $0x2,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <wait>:
SYSCALL(wait)
 538:	b8 03 00 00 00       	mov    $0x3,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <pipe>:
SYSCALL(pipe)
 540:	b8 04 00 00 00       	mov    $0x4,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <read>:
SYSCALL(read)
 548:	b8 05 00 00 00       	mov    $0x5,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <write>:
SYSCALL(write)
 550:	b8 10 00 00 00       	mov    $0x10,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <close>:
SYSCALL(close)
 558:	b8 15 00 00 00       	mov    $0x15,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <kill>:
SYSCALL(kill)
 560:	b8 06 00 00 00       	mov    $0x6,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <exec>:
SYSCALL(exec)
 568:	b8 07 00 00 00       	mov    $0x7,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <open>:
SYSCALL(open)
 570:	b8 0f 00 00 00       	mov    $0xf,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <mknod>:
SYSCALL(mknod)
 578:	b8 11 00 00 00       	mov    $0x11,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <unlink>:
SYSCALL(unlink)
 580:	b8 12 00 00 00       	mov    $0x12,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <fstat>:
SYSCALL(fstat)
 588:	b8 08 00 00 00       	mov    $0x8,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <link>:
SYSCALL(link)
 590:	b8 13 00 00 00       	mov    $0x13,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <mkdir>:
SYSCALL(mkdir)
 598:	b8 14 00 00 00       	mov    $0x14,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <chdir>:
SYSCALL(chdir)
 5a0:	b8 09 00 00 00       	mov    $0x9,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <dup>:
SYSCALL(dup)
 5a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <getpid>:
SYSCALL(getpid)
 5b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <sbrk>:
SYSCALL(sbrk)
 5b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <sleep>:
SYSCALL(sleep)
 5c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <uptime>:
SYSCALL(uptime)
 5c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <wait2>:
SYSCALL(wait2)
 5d0:	b8 16 00 00 00       	mov    $0x16,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <set_prio>:
SYSCALL(set_prio)
 5d8:	b8 17 00 00 00       	mov    $0x17,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <yield>:
SYSCALL(yield)
 5e0:	b8 18 00 00 00       	mov    $0x18,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e8:	55                   	push   %ebp
 5e9:	89 e5                	mov    %esp,%ebp
 5eb:	83 ec 28             	sub    $0x28,%esp
 5ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5f4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5fb:	00 
 5fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 603:	8b 45 08             	mov    0x8(%ebp),%eax
 606:	89 04 24             	mov    %eax,(%esp)
 609:	e8 42 ff ff ff       	call   550 <write>
}
 60e:	c9                   	leave  
 60f:	c3                   	ret    

00000610 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 616:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 61d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 621:	74 17                	je     63a <printint+0x2a>
 623:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 627:	79 11                	jns    63a <printint+0x2a>
    neg = 1;
 629:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 630:	8b 45 0c             	mov    0xc(%ebp),%eax
 633:	f7 d8                	neg    %eax
 635:	89 45 ec             	mov    %eax,-0x14(%ebp)
 638:	eb 06                	jmp    640 <printint+0x30>
  } else {
    x = xx;
 63a:	8b 45 0c             	mov    0xc(%ebp),%eax
 63d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 640:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 647:	8b 4d 10             	mov    0x10(%ebp),%ecx
 64a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64d:	ba 00 00 00 00       	mov    $0x0,%edx
 652:	f7 f1                	div    %ecx
 654:	89 d0                	mov    %edx,%eax
 656:	0f b6 90 98 0d 00 00 	movzbl 0xd98(%eax),%edx
 65d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 660:	03 45 f4             	add    -0xc(%ebp),%eax
 663:	88 10                	mov    %dl,(%eax)
 665:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 669:	8b 55 10             	mov    0x10(%ebp),%edx
 66c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 66f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 672:	ba 00 00 00 00       	mov    $0x0,%edx
 677:	f7 75 d4             	divl   -0x2c(%ebp)
 67a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 681:	75 c4                	jne    647 <printint+0x37>
  if(neg)
 683:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 687:	74 2a                	je     6b3 <printint+0xa3>
    buf[i++] = '-';
 689:	8d 45 dc             	lea    -0x24(%ebp),%eax
 68c:	03 45 f4             	add    -0xc(%ebp),%eax
 68f:	c6 00 2d             	movb   $0x2d,(%eax)
 692:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 696:	eb 1b                	jmp    6b3 <printint+0xa3>
    putc(fd, buf[i]);
 698:	8d 45 dc             	lea    -0x24(%ebp),%eax
 69b:	03 45 f4             	add    -0xc(%ebp),%eax
 69e:	0f b6 00             	movzbl (%eax),%eax
 6a1:	0f be c0             	movsbl %al,%eax
 6a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	89 04 24             	mov    %eax,(%esp)
 6ae:	e8 35 ff ff ff       	call   5e8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6b3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6bb:	79 db                	jns    698 <printint+0x88>
    putc(fd, buf[i]);
}
 6bd:	c9                   	leave  
 6be:	c3                   	ret    

000006bf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6bf:	55                   	push   %ebp
 6c0:	89 e5                	mov    %esp,%ebp
 6c2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6cc:	8d 45 0c             	lea    0xc(%ebp),%eax
 6cf:	83 c0 04             	add    $0x4,%eax
 6d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6dc:	e9 7d 01 00 00       	jmp    85e <printf+0x19f>
    c = fmt[i] & 0xff;
 6e1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e7:	01 d0                	add    %edx,%eax
 6e9:	0f b6 00             	movzbl (%eax),%eax
 6ec:	0f be c0             	movsbl %al,%eax
 6ef:	25 ff 00 00 00       	and    $0xff,%eax
 6f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6fb:	75 2c                	jne    729 <printf+0x6a>
      if(c == '%'){
 6fd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 701:	75 0c                	jne    70f <printf+0x50>
        state = '%';
 703:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 70a:	e9 4b 01 00 00       	jmp    85a <printf+0x19b>
      } else {
        putc(fd, c);
 70f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 712:	0f be c0             	movsbl %al,%eax
 715:	89 44 24 04          	mov    %eax,0x4(%esp)
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	89 04 24             	mov    %eax,(%esp)
 71f:	e8 c4 fe ff ff       	call   5e8 <putc>
 724:	e9 31 01 00 00       	jmp    85a <printf+0x19b>
      }
    } else if(state == '%'){
 729:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 72d:	0f 85 27 01 00 00    	jne    85a <printf+0x19b>
      if(c == 'd'){
 733:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 737:	75 2d                	jne    766 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 739:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 745:	00 
 746:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 74d:	00 
 74e:	89 44 24 04          	mov    %eax,0x4(%esp)
 752:	8b 45 08             	mov    0x8(%ebp),%eax
 755:	89 04 24             	mov    %eax,(%esp)
 758:	e8 b3 fe ff ff       	call   610 <printint>
        ap++;
 75d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 761:	e9 ed 00 00 00       	jmp    853 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 766:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 76a:	74 06                	je     772 <printf+0xb3>
 76c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 770:	75 2d                	jne    79f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 772:	8b 45 e8             	mov    -0x18(%ebp),%eax
 775:	8b 00                	mov    (%eax),%eax
 777:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 77e:	00 
 77f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 786:	00 
 787:	89 44 24 04          	mov    %eax,0x4(%esp)
 78b:	8b 45 08             	mov    0x8(%ebp),%eax
 78e:	89 04 24             	mov    %eax,(%esp)
 791:	e8 7a fe ff ff       	call   610 <printint>
        ap++;
 796:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79a:	e9 b4 00 00 00       	jmp    853 <printf+0x194>
      } else if(c == 's'){
 79f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7a3:	75 46                	jne    7eb <printf+0x12c>
        s = (char*)*ap;
 7a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b5:	75 27                	jne    7de <printf+0x11f>
          s = "(null)";
 7b7:	c7 45 f4 0f 0b 00 00 	movl   $0xb0f,-0xc(%ebp)
        while(*s != 0){
 7be:	eb 1e                	jmp    7de <printf+0x11f>
          putc(fd, *s);
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	0f b6 00             	movzbl (%eax),%eax
 7c6:	0f be c0             	movsbl %al,%eax
 7c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cd:	8b 45 08             	mov    0x8(%ebp),%eax
 7d0:	89 04 24             	mov    %eax,(%esp)
 7d3:	e8 10 fe ff ff       	call   5e8 <putc>
          s++;
 7d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7dc:	eb 01                	jmp    7df <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7de:	90                   	nop
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	0f b6 00             	movzbl (%eax),%eax
 7e5:	84 c0                	test   %al,%al
 7e7:	75 d7                	jne    7c0 <printf+0x101>
 7e9:	eb 68                	jmp    853 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7eb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7ef:	75 1d                	jne    80e <printf+0x14f>
        putc(fd, *ap);
 7f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	0f be c0             	movsbl %al,%eax
 7f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7fd:	8b 45 08             	mov    0x8(%ebp),%eax
 800:	89 04 24             	mov    %eax,(%esp)
 803:	e8 e0 fd ff ff       	call   5e8 <putc>
        ap++;
 808:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80c:	eb 45                	jmp    853 <printf+0x194>
      } else if(c == '%'){
 80e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 812:	75 17                	jne    82b <printf+0x16c>
        putc(fd, c);
 814:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 817:	0f be c0             	movsbl %al,%eax
 81a:	89 44 24 04          	mov    %eax,0x4(%esp)
 81e:	8b 45 08             	mov    0x8(%ebp),%eax
 821:	89 04 24             	mov    %eax,(%esp)
 824:	e8 bf fd ff ff       	call   5e8 <putc>
 829:	eb 28                	jmp    853 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 82b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 832:	00 
 833:	8b 45 08             	mov    0x8(%ebp),%eax
 836:	89 04 24             	mov    %eax,(%esp)
 839:	e8 aa fd ff ff       	call   5e8 <putc>
        putc(fd, c);
 83e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 841:	0f be c0             	movsbl %al,%eax
 844:	89 44 24 04          	mov    %eax,0x4(%esp)
 848:	8b 45 08             	mov    0x8(%ebp),%eax
 84b:	89 04 24             	mov    %eax,(%esp)
 84e:	e8 95 fd ff ff       	call   5e8 <putc>
      }
      state = 0;
 853:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 85a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 85e:	8b 55 0c             	mov    0xc(%ebp),%edx
 861:	8b 45 f0             	mov    -0x10(%ebp),%eax
 864:	01 d0                	add    %edx,%eax
 866:	0f b6 00             	movzbl (%eax),%eax
 869:	84 c0                	test   %al,%al
 86b:	0f 85 70 fe ff ff    	jne    6e1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 871:	c9                   	leave  
 872:	c3                   	ret    
 873:	90                   	nop

00000874 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 874:	55                   	push   %ebp
 875:	89 e5                	mov    %esp,%ebp
 877:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87a:	8b 45 08             	mov    0x8(%ebp),%eax
 87d:	83 e8 08             	sub    $0x8,%eax
 880:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 883:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 888:	89 45 fc             	mov    %eax,-0x4(%ebp)
 88b:	eb 24                	jmp    8b1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 895:	77 12                	ja     8a9 <free+0x35>
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 89d:	77 24                	ja     8c3 <free+0x4f>
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 00                	mov    (%eax),%eax
 8a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8a7:	77 1a                	ja     8c3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 00                	mov    (%eax),%eax
 8ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8b7:	76 d4                	jbe    88d <free+0x19>
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	8b 00                	mov    (%eax),%eax
 8be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8c1:	76 ca                	jbe    88d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c6:	8b 40 04             	mov    0x4(%eax),%eax
 8c9:	c1 e0 03             	shl    $0x3,%eax
 8cc:	89 c2                	mov    %eax,%edx
 8ce:	03 55 f8             	add    -0x8(%ebp),%edx
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	39 c2                	cmp    %eax,%edx
 8d8:	75 24                	jne    8fe <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dd:	8b 50 04             	mov    0x4(%eax),%edx
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	8b 40 04             	mov    0x4(%eax),%eax
 8e8:	01 c2                	add    %eax,%edx
 8ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ed:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f3:	8b 00                	mov    (%eax),%eax
 8f5:	8b 10                	mov    (%eax),%edx
 8f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fa:	89 10                	mov    %edx,(%eax)
 8fc:	eb 0a                	jmp    908 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 901:	8b 10                	mov    (%eax),%edx
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 40 04             	mov    0x4(%eax),%eax
 90e:	c1 e0 03             	shl    $0x3,%eax
 911:	03 45 fc             	add    -0x4(%ebp),%eax
 914:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 917:	75 20                	jne    939 <free+0xc5>
    p->s.size += bp->s.size;
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 50 04             	mov    0x4(%eax),%edx
 91f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 922:	8b 40 04             	mov    0x4(%eax),%eax
 925:	01 c2                	add    %eax,%edx
 927:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 92d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 930:	8b 10                	mov    (%eax),%edx
 932:	8b 45 fc             	mov    -0x4(%ebp),%eax
 935:	89 10                	mov    %edx,(%eax)
 937:	eb 08                	jmp    941 <free+0xcd>
  } else
    p->s.ptr = bp;
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 93f:	89 10                	mov    %edx,(%eax)
  freep = p;
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	a3 b4 0d 00 00       	mov    %eax,0xdb4
}
 949:	c9                   	leave  
 94a:	c3                   	ret    

0000094b <morecore>:

static Header*
morecore(uint nu)
{
 94b:	55                   	push   %ebp
 94c:	89 e5                	mov    %esp,%ebp
 94e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 951:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 958:	77 07                	ja     961 <morecore+0x16>
    nu = 4096;
 95a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 961:	8b 45 08             	mov    0x8(%ebp),%eax
 964:	c1 e0 03             	shl    $0x3,%eax
 967:	89 04 24             	mov    %eax,(%esp)
 96a:	e8 49 fc ff ff       	call   5b8 <sbrk>
 96f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 972:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 976:	75 07                	jne    97f <morecore+0x34>
    return 0;
 978:	b8 00 00 00 00       	mov    $0x0,%eax
 97d:	eb 22                	jmp    9a1 <morecore+0x56>
  hp = (Header*)p;
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 985:	8b 45 f0             	mov    -0x10(%ebp),%eax
 988:	8b 55 08             	mov    0x8(%ebp),%edx
 98b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 98e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 991:	83 c0 08             	add    $0x8,%eax
 994:	89 04 24             	mov    %eax,(%esp)
 997:	e8 d8 fe ff ff       	call   874 <free>
  return freep;
 99c:	a1 b4 0d 00 00       	mov    0xdb4,%eax
}
 9a1:	c9                   	leave  
 9a2:	c3                   	ret    

000009a3 <malloc>:

void*
malloc(uint nbytes)
{
 9a3:	55                   	push   %ebp
 9a4:	89 e5                	mov    %esp,%ebp
 9a6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9a9:	8b 45 08             	mov    0x8(%ebp),%eax
 9ac:	83 c0 07             	add    $0x7,%eax
 9af:	c1 e8 03             	shr    $0x3,%eax
 9b2:	83 c0 01             	add    $0x1,%eax
 9b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9b8:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 9bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9c4:	75 23                	jne    9e9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9c6:	c7 45 f0 ac 0d 00 00 	movl   $0xdac,-0x10(%ebp)
 9cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d0:	a3 b4 0d 00 00       	mov    %eax,0xdb4
 9d5:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 9da:	a3 ac 0d 00 00       	mov    %eax,0xdac
    base.s.size = 0;
 9df:	c7 05 b0 0d 00 00 00 	movl   $0x0,0xdb0
 9e6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ec:	8b 00                	mov    (%eax),%eax
 9ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9fa:	72 4d                	jb     a49 <malloc+0xa6>
      if(p->s.size == nunits)
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 40 04             	mov    0x4(%eax),%eax
 a02:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a05:	75 0c                	jne    a13 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8b 10                	mov    (%eax),%edx
 a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0f:	89 10                	mov    %edx,(%eax)
 a11:	eb 26                	jmp    a39 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a16:	8b 40 04             	mov    0x4(%eax),%eax
 a19:	89 c2                	mov    %eax,%edx
 a1b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a21:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 40 04             	mov    0x4(%eax),%eax
 a2a:	c1 e0 03             	shl    $0x3,%eax
 a2d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a36:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3c:	a3 b4 0d 00 00       	mov    %eax,0xdb4
      return (void*)(p + 1);
 a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a44:	83 c0 08             	add    $0x8,%eax
 a47:	eb 38                	jmp    a81 <malloc+0xde>
    }
    if(p == freep)
 a49:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 a4e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a51:	75 1b                	jne    a6e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a56:	89 04 24             	mov    %eax,(%esp)
 a59:	e8 ed fe ff ff       	call   94b <morecore>
 a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a65:	75 07                	jne    a6e <malloc+0xcb>
        return 0;
 a67:	b8 00 00 00 00       	mov    $0x0,%eax
 a6c:	eb 13                	jmp    a81 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a71:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	8b 00                	mov    (%eax),%eax
 a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a7c:	e9 70 ff ff ff       	jmp    9f1 <malloc+0x4e>
}
 a81:	c9                   	leave  
 a82:	c3                   	ret    
