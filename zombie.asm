
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 72 02 00 00       	call   280 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 fa 02 00 00       	call   318 <sleep>
  exit();
  1e:	e8 65 02 00 00       	call   288 <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	0f b6 10             	movzbl (%eax),%edx
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	88 10                	mov    %dl,(%eax)
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	0f b6 00             	movzbl (%eax),%eax
  67:	84 c0                	test   %al,%al
  69:	0f 95 c0             	setne  %al
  6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  74:	84 c0                	test   %al,%al
  76:	75 de                	jne    56 <strcpy+0xd>
    ;
  return os;
  78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7b:	c9                   	leave  
  7c:	c3                   	ret    

0000007d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  80:	eb 08                	jmp    8a <strcmp+0xd>
    p++, q++;
  82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	0f b6 00             	movzbl (%eax),%eax
  90:	84 c0                	test   %al,%al
  92:	74 10                	je     a4 <strcmp+0x27>
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	0f b6 10             	movzbl (%eax),%edx
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 00             	movzbl (%eax),%eax
  a0:	38 c2                	cmp    %al,%dl
  a2:	74 de                	je     82 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	0f b6 00             	movzbl (%eax),%eax
  aa:	0f b6 d0             	movzbl %al,%edx
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	0f b6 c0             	movzbl %al,%eax
  b6:	89 d1                	mov    %edx,%ecx
  b8:	29 c1                	sub    %eax,%ecx
  ba:	89 c8                	mov    %ecx,%eax
}
  bc:	5d                   	pop    %ebp
  bd:	c3                   	ret    

000000be <strlen>:

uint
strlen(char *s)
{
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  cb:	eb 04                	jmp    d1 <strlen+0x13>
  cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  d4:	03 45 08             	add    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	84 c0                	test   %al,%al
  dc:	75 ef                	jne    cd <strlen+0xf>
    ;
  return n;
  de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  e9:	8b 45 10             	mov    0x10(%ebp),%eax
  ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	89 04 24             	mov    %eax,(%esp)
  fd:	e8 22 ff ff ff       	call   24 <stosb>
  return dst;
 102:	8b 45 08             	mov    0x8(%ebp),%eax
}
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <strchr>:

char*
strchr(const char *s, char c)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 04             	sub    $0x4,%esp
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 113:	eb 14                	jmp    129 <strchr+0x22>
    if(*s == c)
 115:	8b 45 08             	mov    0x8(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 11e:	75 05                	jne    125 <strchr+0x1e>
      return (char*)s;
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	eb 13                	jmp    138 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 125:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	0f b6 00             	movzbl (%eax),%eax
 12f:	84 c0                	test   %al,%al
 131:	75 e2                	jne    115 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 133:	b8 00 00 00 00       	mov    $0x0,%eax
}
 138:	c9                   	leave  
 139:	c3                   	ret    

0000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 140:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 147:	eb 44                	jmp    18d <gets+0x53>
    cc = read(0, &c, 1);
 149:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 150:	00 
 151:	8d 45 ef             	lea    -0x11(%ebp),%eax
 154:	89 44 24 04          	mov    %eax,0x4(%esp)
 158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 15f:	e8 3c 01 00 00       	call   2a0 <read>
 164:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 167:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 16b:	7e 2d                	jle    19a <gets+0x60>
      break;
    buf[i++] = c;
 16d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 170:	03 45 08             	add    0x8(%ebp),%eax
 173:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 177:	88 10                	mov    %dl,(%eax)
 179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 17d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 181:	3c 0a                	cmp    $0xa,%al
 183:	74 16                	je     19b <gets+0x61>
 185:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 189:	3c 0d                	cmp    $0xd,%al
 18b:	74 0e                	je     19b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	83 c0 01             	add    $0x1,%eax
 193:	3b 45 0c             	cmp    0xc(%ebp),%eax
 196:	7c b1                	jl     149 <gets+0xf>
 198:	eb 01                	jmp    19b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 19a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	03 45 08             	add    0x8(%ebp),%eax
 1a1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a7:	c9                   	leave  
 1a8:	c3                   	ret    

000001a9 <stat>:

int
stat(char *n, struct stat *st)
{
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1b6:	00 
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 06 01 00 00       	call   2c8 <open>
 1c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c9:	79 07                	jns    1d2 <stat+0x29>
    return -1;
 1cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d0:	eb 23                	jmp    1f5 <stat+0x4c>
  r = fstat(fd, st);
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	89 04 24             	mov    %eax,(%esp)
 1df:	e8 fc 00 00 00       	call   2e0 <fstat>
 1e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	89 04 24             	mov    %eax,(%esp)
 1ed:	e8 be 00 00 00       	call   2b0 <close>
  return r;
 1f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <atoi>:

int
atoi(const char *s)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 204:	eb 23                	jmp    229 <atoi+0x32>
    n = n*10 + *s++ - '0';
 206:	8b 55 fc             	mov    -0x4(%ebp),%edx
 209:	89 d0                	mov    %edx,%eax
 20b:	c1 e0 02             	shl    $0x2,%eax
 20e:	01 d0                	add    %edx,%eax
 210:	01 c0                	add    %eax,%eax
 212:	89 c2                	mov    %eax,%edx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	0f be c0             	movsbl %al,%eax
 21d:	01 d0                	add    %edx,%eax
 21f:	83 e8 30             	sub    $0x30,%eax
 222:	89 45 fc             	mov    %eax,-0x4(%ebp)
 225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	3c 2f                	cmp    $0x2f,%al
 231:	7e 0a                	jle    23d <atoi+0x46>
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	3c 39                	cmp    $0x39,%al
 23b:	7e c9                	jle    206 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 23d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 240:	c9                   	leave  
 241:	c3                   	ret    

00000242 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 254:	eb 13                	jmp    269 <memmove+0x27>
    *dst++ = *src++;
 256:	8b 45 f8             	mov    -0x8(%ebp),%eax
 259:	0f b6 10             	movzbl (%eax),%edx
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25f:	88 10                	mov    %dl,(%eax)
 261:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 265:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 269:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 26d:	0f 9f c0             	setg   %al
 270:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 274:	84 c0                	test   %al,%al
 276:	75 de                	jne    256 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 278:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27b:	c9                   	leave  
 27c:	c3                   	ret    
 27d:	90                   	nop
 27e:	90                   	nop
 27f:	90                   	nop

00000280 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 280:	b8 01 00 00 00       	mov    $0x1,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <exit>:
SYSCALL(exit)
 288:	b8 02 00 00 00       	mov    $0x2,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <wait>:
SYSCALL(wait)
 290:	b8 03 00 00 00       	mov    $0x3,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <pipe>:
SYSCALL(pipe)
 298:	b8 04 00 00 00       	mov    $0x4,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <read>:
SYSCALL(read)
 2a0:	b8 05 00 00 00       	mov    $0x5,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <write>:
SYSCALL(write)
 2a8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <close>:
SYSCALL(close)
 2b0:	b8 15 00 00 00       	mov    $0x15,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <kill>:
SYSCALL(kill)
 2b8:	b8 06 00 00 00       	mov    $0x6,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exec>:
SYSCALL(exec)
 2c0:	b8 07 00 00 00       	mov    $0x7,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <open>:
SYSCALL(open)
 2c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <mknod>:
SYSCALL(mknod)
 2d0:	b8 11 00 00 00       	mov    $0x11,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <unlink>:
SYSCALL(unlink)
 2d8:	b8 12 00 00 00       	mov    $0x12,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <fstat>:
SYSCALL(fstat)
 2e0:	b8 08 00 00 00       	mov    $0x8,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <link>:
SYSCALL(link)
 2e8:	b8 13 00 00 00       	mov    $0x13,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <mkdir>:
SYSCALL(mkdir)
 2f0:	b8 14 00 00 00       	mov    $0x14,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <chdir>:
SYSCALL(chdir)
 2f8:	b8 09 00 00 00       	mov    $0x9,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <dup>:
SYSCALL(dup)
 300:	b8 0a 00 00 00       	mov    $0xa,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <getpid>:
SYSCALL(getpid)
 308:	b8 0b 00 00 00       	mov    $0xb,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <sbrk>:
SYSCALL(sbrk)
 310:	b8 0c 00 00 00       	mov    $0xc,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <sleep>:
SYSCALL(sleep)
 318:	b8 0d 00 00 00       	mov    $0xd,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <uptime>:
SYSCALL(uptime)
 320:	b8 0e 00 00 00       	mov    $0xe,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <wait2>:
SYSCALL(wait2)
 328:	b8 16 00 00 00       	mov    $0x16,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <set_prio>:
SYSCALL(set_prio)
 330:	b8 17 00 00 00       	mov    $0x17,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <yield>:
SYSCALL(yield)
 338:	b8 18 00 00 00       	mov    $0x18,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	83 ec 28             	sub    $0x28,%esp
 346:	8b 45 0c             	mov    0xc(%ebp),%eax
 349:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 34c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 353:	00 
 354:	8d 45 f4             	lea    -0xc(%ebp),%eax
 357:	89 44 24 04          	mov    %eax,0x4(%esp)
 35b:	8b 45 08             	mov    0x8(%ebp),%eax
 35e:	89 04 24             	mov    %eax,(%esp)
 361:	e8 42 ff ff ff       	call   2a8 <write>
}
 366:	c9                   	leave  
 367:	c3                   	ret    

00000368 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 36e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 375:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 379:	74 17                	je     392 <printint+0x2a>
 37b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 37f:	79 11                	jns    392 <printint+0x2a>
    neg = 1;
 381:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 388:	8b 45 0c             	mov    0xc(%ebp),%eax
 38b:	f7 d8                	neg    %eax
 38d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 390:	eb 06                	jmp    398 <printint+0x30>
  } else {
    x = xx;
 392:	8b 45 0c             	mov    0xc(%ebp),%eax
 395:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 398:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 39f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3a5:	ba 00 00 00 00       	mov    $0x0,%edx
 3aa:	f7 f1                	div    %ecx
 3ac:	89 d0                	mov    %edx,%eax
 3ae:	0f b6 90 20 0a 00 00 	movzbl 0xa20(%eax),%edx
 3b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3b8:	03 45 f4             	add    -0xc(%ebp),%eax
 3bb:	88 10                	mov    %dl,(%eax)
 3bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3c1:	8b 55 10             	mov    0x10(%ebp),%edx
 3c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ca:	ba 00 00 00 00       	mov    $0x0,%edx
 3cf:	f7 75 d4             	divl   -0x2c(%ebp)
 3d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3d9:	75 c4                	jne    39f <printint+0x37>
  if(neg)
 3db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3df:	74 2a                	je     40b <printint+0xa3>
    buf[i++] = '-';
 3e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3e4:	03 45 f4             	add    -0xc(%ebp),%eax
 3e7:	c6 00 2d             	movb   $0x2d,(%eax)
 3ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3ee:	eb 1b                	jmp    40b <printint+0xa3>
    putc(fd, buf[i]);
 3f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3f3:	03 45 f4             	add    -0xc(%ebp),%eax
 3f6:	0f b6 00             	movzbl (%eax),%eax
 3f9:	0f be c0             	movsbl %al,%eax
 3fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	89 04 24             	mov    %eax,(%esp)
 406:	e8 35 ff ff ff       	call   340 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 40b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 40f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 413:	79 db                	jns    3f0 <printint+0x88>
    putc(fd, buf[i]);
}
 415:	c9                   	leave  
 416:	c3                   	ret    

00000417 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 417:	55                   	push   %ebp
 418:	89 e5                	mov    %esp,%ebp
 41a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 41d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 424:	8d 45 0c             	lea    0xc(%ebp),%eax
 427:	83 c0 04             	add    $0x4,%eax
 42a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 42d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 434:	e9 7d 01 00 00       	jmp    5b6 <printf+0x19f>
    c = fmt[i] & 0xff;
 439:	8b 55 0c             	mov    0xc(%ebp),%edx
 43c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 43f:	01 d0                	add    %edx,%eax
 441:	0f b6 00             	movzbl (%eax),%eax
 444:	0f be c0             	movsbl %al,%eax
 447:	25 ff 00 00 00       	and    $0xff,%eax
 44c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 44f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 453:	75 2c                	jne    481 <printf+0x6a>
      if(c == '%'){
 455:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 459:	75 0c                	jne    467 <printf+0x50>
        state = '%';
 45b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 462:	e9 4b 01 00 00       	jmp    5b2 <printf+0x19b>
      } else {
        putc(fd, c);
 467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 46a:	0f be c0             	movsbl %al,%eax
 46d:	89 44 24 04          	mov    %eax,0x4(%esp)
 471:	8b 45 08             	mov    0x8(%ebp),%eax
 474:	89 04 24             	mov    %eax,(%esp)
 477:	e8 c4 fe ff ff       	call   340 <putc>
 47c:	e9 31 01 00 00       	jmp    5b2 <printf+0x19b>
      }
    } else if(state == '%'){
 481:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 485:	0f 85 27 01 00 00    	jne    5b2 <printf+0x19b>
      if(c == 'd'){
 48b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 48f:	75 2d                	jne    4be <printf+0xa7>
        printint(fd, *ap, 10, 1);
 491:	8b 45 e8             	mov    -0x18(%ebp),%eax
 494:	8b 00                	mov    (%eax),%eax
 496:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 49d:	00 
 49e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4a5:	00 
 4a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4aa:	8b 45 08             	mov    0x8(%ebp),%eax
 4ad:	89 04 24             	mov    %eax,(%esp)
 4b0:	e8 b3 fe ff ff       	call   368 <printint>
        ap++;
 4b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4b9:	e9 ed 00 00 00       	jmp    5ab <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4be:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4c2:	74 06                	je     4ca <printf+0xb3>
 4c4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4c8:	75 2d                	jne    4f7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4cd:	8b 00                	mov    (%eax),%eax
 4cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4d6:	00 
 4d7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4de:	00 
 4df:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
 4e6:	89 04 24             	mov    %eax,(%esp)
 4e9:	e8 7a fe ff ff       	call   368 <printint>
        ap++;
 4ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f2:	e9 b4 00 00 00       	jmp    5ab <printf+0x194>
      } else if(c == 's'){
 4f7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4fb:	75 46                	jne    543 <printf+0x12c>
        s = (char*)*ap;
 4fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 500:	8b 00                	mov    (%eax),%eax
 502:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 505:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 509:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50d:	75 27                	jne    536 <printf+0x11f>
          s = "(null)";
 50f:	c7 45 f4 db 07 00 00 	movl   $0x7db,-0xc(%ebp)
        while(*s != 0){
 516:	eb 1e                	jmp    536 <printf+0x11f>
          putc(fd, *s);
 518:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51b:	0f b6 00             	movzbl (%eax),%eax
 51e:	0f be c0             	movsbl %al,%eax
 521:	89 44 24 04          	mov    %eax,0x4(%esp)
 525:	8b 45 08             	mov    0x8(%ebp),%eax
 528:	89 04 24             	mov    %eax,(%esp)
 52b:	e8 10 fe ff ff       	call   340 <putc>
          s++;
 530:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 534:	eb 01                	jmp    537 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 536:	90                   	nop
 537:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53a:	0f b6 00             	movzbl (%eax),%eax
 53d:	84 c0                	test   %al,%al
 53f:	75 d7                	jne    518 <printf+0x101>
 541:	eb 68                	jmp    5ab <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 543:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 547:	75 1d                	jne    566 <printf+0x14f>
        putc(fd, *ap);
 549:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54c:	8b 00                	mov    (%eax),%eax
 54e:	0f be c0             	movsbl %al,%eax
 551:	89 44 24 04          	mov    %eax,0x4(%esp)
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	89 04 24             	mov    %eax,(%esp)
 55b:	e8 e0 fd ff ff       	call   340 <putc>
        ap++;
 560:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 564:	eb 45                	jmp    5ab <printf+0x194>
      } else if(c == '%'){
 566:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56a:	75 17                	jne    583 <printf+0x16c>
        putc(fd, c);
 56c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56f:	0f be c0             	movsbl %al,%eax
 572:	89 44 24 04          	mov    %eax,0x4(%esp)
 576:	8b 45 08             	mov    0x8(%ebp),%eax
 579:	89 04 24             	mov    %eax,(%esp)
 57c:	e8 bf fd ff ff       	call   340 <putc>
 581:	eb 28                	jmp    5ab <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 583:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 58a:	00 
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	89 04 24             	mov    %eax,(%esp)
 591:	e8 aa fd ff ff       	call   340 <putc>
        putc(fd, c);
 596:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 599:	0f be c0             	movsbl %al,%eax
 59c:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a0:	8b 45 08             	mov    0x8(%ebp),%eax
 5a3:	89 04 24             	mov    %eax,(%esp)
 5a6:	e8 95 fd ff ff       	call   340 <putc>
      }
      state = 0;
 5ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5bc:	01 d0                	add    %edx,%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	84 c0                	test   %al,%al
 5c3:	0f 85 70 fe ff ff    	jne    439 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5c9:	c9                   	leave  
 5ca:	c3                   	ret    
 5cb:	90                   	nop

000005cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5cc:	55                   	push   %ebp
 5cd:	89 e5                	mov    %esp,%ebp
 5cf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5d2:	8b 45 08             	mov    0x8(%ebp),%eax
 5d5:	83 e8 08             	sub    $0x8,%eax
 5d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5db:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 5e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e3:	eb 24                	jmp    609 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e8:	8b 00                	mov    (%eax),%eax
 5ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5ed:	77 12                	ja     601 <free+0x35>
 5ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f5:	77 24                	ja     61b <free+0x4f>
 5f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fa:	8b 00                	mov    (%eax),%eax
 5fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5ff:	77 1a                	ja     61b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 601:	8b 45 fc             	mov    -0x4(%ebp),%eax
 604:	8b 00                	mov    (%eax),%eax
 606:	89 45 fc             	mov    %eax,-0x4(%ebp)
 609:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60f:	76 d4                	jbe    5e5 <free+0x19>
 611:	8b 45 fc             	mov    -0x4(%ebp),%eax
 614:	8b 00                	mov    (%eax),%eax
 616:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 619:	76 ca                	jbe    5e5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 61b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61e:	8b 40 04             	mov    0x4(%eax),%eax
 621:	c1 e0 03             	shl    $0x3,%eax
 624:	89 c2                	mov    %eax,%edx
 626:	03 55 f8             	add    -0x8(%ebp),%edx
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	39 c2                	cmp    %eax,%edx
 630:	75 24                	jne    656 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 632:	8b 45 f8             	mov    -0x8(%ebp),%eax
 635:	8b 50 04             	mov    0x4(%eax),%edx
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	8b 40 04             	mov    0x4(%eax),%eax
 640:	01 c2                	add    %eax,%edx
 642:	8b 45 f8             	mov    -0x8(%ebp),%eax
 645:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 00                	mov    (%eax),%eax
 64d:	8b 10                	mov    (%eax),%edx
 64f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 652:	89 10                	mov    %edx,(%eax)
 654:	eb 0a                	jmp    660 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 656:	8b 45 fc             	mov    -0x4(%ebp),%eax
 659:	8b 10                	mov    (%eax),%edx
 65b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 40 04             	mov    0x4(%eax),%eax
 666:	c1 e0 03             	shl    $0x3,%eax
 669:	03 45 fc             	add    -0x4(%ebp),%eax
 66c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 66f:	75 20                	jne    691 <free+0xc5>
    p->s.size += bp->s.size;
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 50 04             	mov    0x4(%eax),%edx
 677:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67a:	8b 40 04             	mov    0x4(%eax),%eax
 67d:	01 c2                	add    %eax,%edx
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 685:	8b 45 f8             	mov    -0x8(%ebp),%eax
 688:	8b 10                	mov    (%eax),%edx
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	89 10                	mov    %edx,(%eax)
 68f:	eb 08                	jmp    699 <free+0xcd>
  } else
    p->s.ptr = bp;
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 55 f8             	mov    -0x8(%ebp),%edx
 697:	89 10                	mov    %edx,(%eax)
  freep = p;
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	a3 3c 0a 00 00       	mov    %eax,0xa3c
}
 6a1:	c9                   	leave  
 6a2:	c3                   	ret    

000006a3 <morecore>:

static Header*
morecore(uint nu)
{
 6a3:	55                   	push   %ebp
 6a4:	89 e5                	mov    %esp,%ebp
 6a6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6a9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6b0:	77 07                	ja     6b9 <morecore+0x16>
    nu = 4096;
 6b2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6b9:	8b 45 08             	mov    0x8(%ebp),%eax
 6bc:	c1 e0 03             	shl    $0x3,%eax
 6bf:	89 04 24             	mov    %eax,(%esp)
 6c2:	e8 49 fc ff ff       	call   310 <sbrk>
 6c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ca:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ce:	75 07                	jne    6d7 <morecore+0x34>
    return 0;
 6d0:	b8 00 00 00 00       	mov    $0x0,%eax
 6d5:	eb 22                	jmp    6f9 <morecore+0x56>
  hp = (Header*)p;
 6d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e0:	8b 55 08             	mov    0x8(%ebp),%edx
 6e3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e9:	83 c0 08             	add    $0x8,%eax
 6ec:	89 04 24             	mov    %eax,(%esp)
 6ef:	e8 d8 fe ff ff       	call   5cc <free>
  return freep;
 6f4:	a1 3c 0a 00 00       	mov    0xa3c,%eax
}
 6f9:	c9                   	leave  
 6fa:	c3                   	ret    

000006fb <malloc>:

void*
malloc(uint nbytes)
{
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	83 c0 07             	add    $0x7,%eax
 707:	c1 e8 03             	shr    $0x3,%eax
 70a:	83 c0 01             	add    $0x1,%eax
 70d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 710:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 715:	89 45 f0             	mov    %eax,-0x10(%ebp)
 718:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 71c:	75 23                	jne    741 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 71e:	c7 45 f0 34 0a 00 00 	movl   $0xa34,-0x10(%ebp)
 725:	8b 45 f0             	mov    -0x10(%ebp),%eax
 728:	a3 3c 0a 00 00       	mov    %eax,0xa3c
 72d:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 732:	a3 34 0a 00 00       	mov    %eax,0xa34
    base.s.size = 0;
 737:	c7 05 38 0a 00 00 00 	movl   $0x0,0xa38
 73e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 741:	8b 45 f0             	mov    -0x10(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	8b 40 04             	mov    0x4(%eax),%eax
 74f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 752:	72 4d                	jb     7a1 <malloc+0xa6>
      if(p->s.size == nunits)
 754:	8b 45 f4             	mov    -0xc(%ebp),%eax
 757:	8b 40 04             	mov    0x4(%eax),%eax
 75a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 75d:	75 0c                	jne    76b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	8b 10                	mov    (%eax),%edx
 764:	8b 45 f0             	mov    -0x10(%ebp),%eax
 767:	89 10                	mov    %edx,(%eax)
 769:	eb 26                	jmp    791 <malloc+0x96>
      else {
        p->s.size -= nunits;
 76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76e:	8b 40 04             	mov    0x4(%eax),%eax
 771:	89 c2                	mov    %eax,%edx
 773:	2b 55 ec             	sub    -0x14(%ebp),%edx
 776:	8b 45 f4             	mov    -0xc(%ebp),%eax
 779:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 77c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77f:	8b 40 04             	mov    0x4(%eax),%eax
 782:	c1 e0 03             	shl    $0x3,%eax
 785:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 788:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 78e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	a3 3c 0a 00 00       	mov    %eax,0xa3c
      return (void*)(p + 1);
 799:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79c:	83 c0 08             	add    $0x8,%eax
 79f:	eb 38                	jmp    7d9 <malloc+0xde>
    }
    if(p == freep)
 7a1:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 7a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7a9:	75 1b                	jne    7c6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ae:	89 04 24             	mov    %eax,(%esp)
 7b1:	e8 ed fe ff ff       	call   6a3 <morecore>
 7b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7bd:	75 07                	jne    7c6 <malloc+0xcb>
        return 0;
 7bf:	b8 00 00 00 00       	mov    $0x0,%eax
 7c4:	eb 13                	jmp    7d9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 00                	mov    (%eax),%eax
 7d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7d4:	e9 70 ff ff ff       	jmp    749 <malloc+0x4e>
}
 7d9:	c9                   	leave  
 7da:	c3                   	ret    
