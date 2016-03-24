
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
   d:	e9 ca 00 00 00       	jmp    dc <grep+0xdc>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    buf[m] = '\0';
  18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1b:	05 60 0e 00 00       	add    $0xe60,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 60 0e 00 00 	movl   $0xe60,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  2a:	eb 53                	jmp    7f <grep+0x7f>
      *q = 0;
  2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  2f:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  35:	89 44 24 04          	mov    %eax,0x4(%esp)
  39:	8b 45 08             	mov    0x8(%ebp),%eax
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 af 01 00 00       	call   1f3 <match>
  44:	85 c0                	test   %eax,%eax
  46:	74 2e                	je     76 <grep+0x76>
        *q = '\n';
  48:	8b 45 e8             	mov    -0x18(%ebp),%eax
  4b:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  51:	83 c0 01             	add    $0x1,%eax
  54:	89 c2                	mov    %eax,%edx
  56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  59:	89 d1                	mov    %edx,%ecx
  5b:	29 c1                	sub    %eax,%ecx
  5d:	89 c8                	mov    %ecx,%eax
  5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  66:	89 44 24 04          	mov    %eax,0x4(%esp)
  6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  71:	e8 6a 05 00 00       	call   5e0 <write>
      }
      p = q+1;
  76:	8b 45 e8             	mov    -0x18(%ebp),%eax
  79:	83 c0 01             	add    $0x1,%eax
  7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
    m += n;
    buf[m] = '\0';
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  7f:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  86:	00 
  87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8a:	89 04 24             	mov    %eax,(%esp)
  8d:	e8 ad 03 00 00       	call   43f <strchr>
  92:	89 45 e8             	mov    %eax,-0x18(%ebp)
  95:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  99:	75 91                	jne    2c <grep+0x2c>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  9b:	81 7d f0 60 0e 00 00 	cmpl   $0xe60,-0x10(%ebp)
  a2:	75 07                	jne    ab <grep+0xab>
      m = 0;
  a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  af:	7e 2b                	jle    dc <grep+0xdc>
      m -= p - buf;
  b1:	ba 60 0e 00 00       	mov    $0xe60,%edx
  b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b9:	89 d1                	mov    %edx,%ecx
  bb:	29 c1                	sub    %eax,%ecx
  bd:	89 c8                	mov    %ecx,%eax
  bf:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  d0:	c7 04 24 60 0e 00 00 	movl   $0xe60,(%esp)
  d7:	e8 9e 04 00 00       	call   57a <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
  dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  df:	ba ff 03 00 00       	mov    $0x3ff,%edx
  e4:	89 d1                	mov    %edx,%ecx
  e6:	29 c1                	sub    %eax,%ecx
  e8:	89 c8                	mov    %ecx,%eax
  ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ed:	81 c2 60 0e 00 00    	add    $0xe60,%edx
  f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 d2 04 00 00       	call   5d8 <read>
 106:	89 45 ec             	mov    %eax,-0x14(%ebp)
 109:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 10d:	0f 8f ff fe ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 113:	c9                   	leave  
 114:	c3                   	ret    

00000115 <main>:

int
main(int argc, char *argv[])
{
 115:	55                   	push   %ebp
 116:	89 e5                	mov    %esp,%ebp
 118:	83 e4 f0             	and    $0xfffffff0,%esp
 11b:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 11e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 122:	7f 19                	jg     13d <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 124:	c7 44 24 04 14 0b 00 	movl   $0xb14,0x4(%esp)
 12b:	00 
 12c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 133:	e8 17 06 00 00       	call   74f <printf>
    exit();
 138:	e8 83 04 00 00       	call   5c0 <exit>
  }
  pattern = argv[1];
 13d:	8b 45 0c             	mov    0xc(%ebp),%eax
 140:	8b 40 04             	mov    0x4(%eax),%eax
 143:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 147:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 14b:	7f 19                	jg     166 <main+0x51>
    grep(pattern, 0);
 14d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 154:	00 
 155:	8b 44 24 18          	mov    0x18(%esp),%eax
 159:	89 04 24             	mov    %eax,(%esp)
 15c:	e8 9f fe ff ff       	call   0 <grep>
    exit();
 161:	e8 5a 04 00 00       	call   5c0 <exit>
  }

  for(i = 2; i < argc; i++){
 166:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 16d:	00 
 16e:	eb 75                	jmp    1e5 <main+0xd0>
    if((fd = open(argv[i], 0)) < 0){
 170:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 174:	c1 e0 02             	shl    $0x2,%eax
 177:	03 45 0c             	add    0xc(%ebp),%eax
 17a:	8b 00                	mov    (%eax),%eax
 17c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 183:	00 
 184:	89 04 24             	mov    %eax,(%esp)
 187:	e8 74 04 00 00       	call   600 <open>
 18c:	89 44 24 14          	mov    %eax,0x14(%esp)
 190:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 195:	79 29                	jns    1c0 <main+0xab>
      printf(1, "grep: cannot open %s\n", argv[i]);
 197:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 19b:	c1 e0 02             	shl    $0x2,%eax
 19e:	03 45 0c             	add    0xc(%ebp),%eax
 1a1:	8b 00                	mov    (%eax),%eax
 1a3:	89 44 24 08          	mov    %eax,0x8(%esp)
 1a7:	c7 44 24 04 34 0b 00 	movl   $0xb34,0x4(%esp)
 1ae:	00 
 1af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b6:	e8 94 05 00 00       	call   74f <printf>
      exit();
 1bb:	e8 00 04 00 00       	call   5c0 <exit>
    }
    grep(pattern, fd);
 1c0:	8b 44 24 14          	mov    0x14(%esp),%eax
 1c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c8:	8b 44 24 18          	mov    0x18(%esp),%eax
 1cc:	89 04 24             	mov    %eax,(%esp)
 1cf:	e8 2c fe ff ff       	call   0 <grep>
    close(fd);
 1d4:	8b 44 24 14          	mov    0x14(%esp),%eax
 1d8:	89 04 24             	mov    %eax,(%esp)
 1db:	e8 08 04 00 00       	call   5e8 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1e0:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1e5:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1e9:	3b 45 08             	cmp    0x8(%ebp),%eax
 1ec:	7c 82                	jl     170 <main+0x5b>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1ee:	e8 cd 03 00 00       	call   5c0 <exit>

000001f3 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	0f b6 00             	movzbl (%eax),%eax
 1ff:	3c 5e                	cmp    $0x5e,%al
 201:	75 17                	jne    21a <match+0x27>
    return matchhere(re+1, text);
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	8d 50 01             	lea    0x1(%eax),%edx
 209:	8b 45 0c             	mov    0xc(%ebp),%eax
 20c:	89 44 24 04          	mov    %eax,0x4(%esp)
 210:	89 14 24             	mov    %edx,(%esp)
 213:	e8 39 00 00 00       	call   251 <matchhere>
 218:	eb 35                	jmp    24f <match+0x5c>
  do{  // must look at empty string
    if(matchhere(re, text))
 21a:	8b 45 0c             	mov    0xc(%ebp),%eax
 21d:	89 44 24 04          	mov    %eax,0x4(%esp)
 221:	8b 45 08             	mov    0x8(%ebp),%eax
 224:	89 04 24             	mov    %eax,(%esp)
 227:	e8 25 00 00 00       	call   251 <matchhere>
 22c:	85 c0                	test   %eax,%eax
 22e:	74 07                	je     237 <match+0x44>
      return 1;
 230:	b8 01 00 00 00       	mov    $0x1,%eax
 235:	eb 18                	jmp    24f <match+0x5c>
  }while(*text++ != '\0');
 237:	8b 45 0c             	mov    0xc(%ebp),%eax
 23a:	0f b6 00             	movzbl (%eax),%eax
 23d:	84 c0                	test   %al,%al
 23f:	0f 95 c0             	setne  %al
 242:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 246:	84 c0                	test   %al,%al
 248:	75 d0                	jne    21a <match+0x27>
  return 0;
 24a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24f:	c9                   	leave  
 250:	c3                   	ret    

00000251 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 257:	8b 45 08             	mov    0x8(%ebp),%eax
 25a:	0f b6 00             	movzbl (%eax),%eax
 25d:	84 c0                	test   %al,%al
 25f:	75 0a                	jne    26b <matchhere+0x1a>
    return 1;
 261:	b8 01 00 00 00       	mov    $0x1,%eax
 266:	e9 9b 00 00 00       	jmp    306 <matchhere+0xb5>
  if(re[1] == '*')
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	83 c0 01             	add    $0x1,%eax
 271:	0f b6 00             	movzbl (%eax),%eax
 274:	3c 2a                	cmp    $0x2a,%al
 276:	75 24                	jne    29c <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	8d 48 02             	lea    0x2(%eax),%ecx
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	0f b6 00             	movzbl (%eax),%eax
 284:	0f be c0             	movsbl %al,%eax
 287:	8b 55 0c             	mov    0xc(%ebp),%edx
 28a:	89 54 24 08          	mov    %edx,0x8(%esp)
 28e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 292:	89 04 24             	mov    %eax,(%esp)
 295:	e8 6e 00 00 00       	call   308 <matchstar>
 29a:	eb 6a                	jmp    306 <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	0f b6 00             	movzbl (%eax),%eax
 2a2:	3c 24                	cmp    $0x24,%al
 2a4:	75 1d                	jne    2c3 <matchhere+0x72>
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	83 c0 01             	add    $0x1,%eax
 2ac:	0f b6 00             	movzbl (%eax),%eax
 2af:	84 c0                	test   %al,%al
 2b1:	75 10                	jne    2c3 <matchhere+0x72>
    return *text == '\0';
 2b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b6:	0f b6 00             	movzbl (%eax),%eax
 2b9:	84 c0                	test   %al,%al
 2bb:	0f 94 c0             	sete   %al
 2be:	0f b6 c0             	movzbl %al,%eax
 2c1:	eb 43                	jmp    306 <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c6:	0f b6 00             	movzbl (%eax),%eax
 2c9:	84 c0                	test   %al,%al
 2cb:	74 34                	je     301 <matchhere+0xb0>
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	0f b6 00             	movzbl (%eax),%eax
 2d3:	3c 2e                	cmp    $0x2e,%al
 2d5:	74 10                	je     2e7 <matchhere+0x96>
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	0f b6 10             	movzbl (%eax),%edx
 2dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e0:	0f b6 00             	movzbl (%eax),%eax
 2e3:	38 c2                	cmp    %al,%dl
 2e5:	75 1a                	jne    301 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ea:	8d 50 01             	lea    0x1(%eax),%edx
 2ed:	8b 45 08             	mov    0x8(%ebp),%eax
 2f0:	83 c0 01             	add    $0x1,%eax
 2f3:	89 54 24 04          	mov    %edx,0x4(%esp)
 2f7:	89 04 24             	mov    %eax,(%esp)
 2fa:	e8 52 ff ff ff       	call   251 <matchhere>
 2ff:	eb 05                	jmp    306 <matchhere+0xb5>
  return 0;
 301:	b8 00 00 00 00       	mov    $0x0,%eax
}
 306:	c9                   	leave  
 307:	c3                   	ret    

00000308 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 308:	55                   	push   %ebp
 309:	89 e5                	mov    %esp,%ebp
 30b:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 30e:	8b 45 10             	mov    0x10(%ebp),%eax
 311:	89 44 24 04          	mov    %eax,0x4(%esp)
 315:	8b 45 0c             	mov    0xc(%ebp),%eax
 318:	89 04 24             	mov    %eax,(%esp)
 31b:	e8 31 ff ff ff       	call   251 <matchhere>
 320:	85 c0                	test   %eax,%eax
 322:	74 07                	je     32b <matchstar+0x23>
      return 1;
 324:	b8 01 00 00 00       	mov    $0x1,%eax
 329:	eb 2c                	jmp    357 <matchstar+0x4f>
  }while(*text!='\0' && (*text++==c || c=='.'));
 32b:	8b 45 10             	mov    0x10(%ebp),%eax
 32e:	0f b6 00             	movzbl (%eax),%eax
 331:	84 c0                	test   %al,%al
 333:	74 1d                	je     352 <matchstar+0x4a>
 335:	8b 45 10             	mov    0x10(%ebp),%eax
 338:	0f b6 00             	movzbl (%eax),%eax
 33b:	0f be c0             	movsbl %al,%eax
 33e:	3b 45 08             	cmp    0x8(%ebp),%eax
 341:	0f 94 c0             	sete   %al
 344:	83 45 10 01          	addl   $0x1,0x10(%ebp)
 348:	84 c0                	test   %al,%al
 34a:	75 c2                	jne    30e <matchstar+0x6>
 34c:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 350:	74 bc                	je     30e <matchstar+0x6>
  return 0;
 352:	b8 00 00 00 00       	mov    $0x0,%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    
 359:	90                   	nop
 35a:	90                   	nop
 35b:	90                   	nop

0000035c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	57                   	push   %edi
 360:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 361:	8b 4d 08             	mov    0x8(%ebp),%ecx
 364:	8b 55 10             	mov    0x10(%ebp),%edx
 367:	8b 45 0c             	mov    0xc(%ebp),%eax
 36a:	89 cb                	mov    %ecx,%ebx
 36c:	89 df                	mov    %ebx,%edi
 36e:	89 d1                	mov    %edx,%ecx
 370:	fc                   	cld    
 371:	f3 aa                	rep stos %al,%es:(%edi)
 373:	89 ca                	mov    %ecx,%edx
 375:	89 fb                	mov    %edi,%ebx
 377:	89 5d 08             	mov    %ebx,0x8(%ebp)
 37a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 37d:	5b                   	pop    %ebx
 37e:	5f                   	pop    %edi
 37f:	5d                   	pop    %ebp
 380:	c3                   	ret    

00000381 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 381:	55                   	push   %ebp
 382:	89 e5                	mov    %esp,%ebp
 384:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 38d:	90                   	nop
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	0f b6 10             	movzbl (%eax),%edx
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	88 10                	mov    %dl,(%eax)
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	0f b6 00             	movzbl (%eax),%eax
 39f:	84 c0                	test   %al,%al
 3a1:	0f 95 c0             	setne  %al
 3a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3ac:	84 c0                	test   %al,%al
 3ae:	75 de                	jne    38e <strcpy+0xd>
    ;
  return os;
 3b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b3:	c9                   	leave  
 3b4:	c3                   	ret    

000003b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b8:	eb 08                	jmp    3c2 <strcmp+0xd>
    p++, q++;
 3ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	0f b6 00             	movzbl (%eax),%eax
 3c8:	84 c0                	test   %al,%al
 3ca:	74 10                	je     3dc <strcmp+0x27>
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	0f b6 10             	movzbl (%eax),%edx
 3d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	38 c2                	cmp    %al,%dl
 3da:	74 de                	je     3ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	0f b6 d0             	movzbl %al,%edx
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	0f b6 c0             	movzbl %al,%eax
 3ee:	89 d1                	mov    %edx,%ecx
 3f0:	29 c1                	sub    %eax,%ecx
 3f2:	89 c8                	mov    %ecx,%eax
}
 3f4:	5d                   	pop    %ebp
 3f5:	c3                   	ret    

000003f6 <strlen>:

uint
strlen(char *s)
{
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 403:	eb 04                	jmp    409 <strlen+0x13>
 405:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 409:	8b 45 fc             	mov    -0x4(%ebp),%eax
 40c:	03 45 08             	add    0x8(%ebp),%eax
 40f:	0f b6 00             	movzbl (%eax),%eax
 412:	84 c0                	test   %al,%al
 414:	75 ef                	jne    405 <strlen+0xf>
    ;
  return n;
 416:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 419:	c9                   	leave  
 41a:	c3                   	ret    

0000041b <memset>:

void*
memset(void *dst, int c, uint n)
{
 41b:	55                   	push   %ebp
 41c:	89 e5                	mov    %esp,%ebp
 41e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 421:	8b 45 10             	mov    0x10(%ebp),%eax
 424:	89 44 24 08          	mov    %eax,0x8(%esp)
 428:	8b 45 0c             	mov    0xc(%ebp),%eax
 42b:	89 44 24 04          	mov    %eax,0x4(%esp)
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	89 04 24             	mov    %eax,(%esp)
 435:	e8 22 ff ff ff       	call   35c <stosb>
  return dst;
 43a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43d:	c9                   	leave  
 43e:	c3                   	ret    

0000043f <strchr>:

char*
strchr(const char *s, char c)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 04             	sub    $0x4,%esp
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 44b:	eb 14                	jmp    461 <strchr+0x22>
    if(*s == c)
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	0f b6 00             	movzbl (%eax),%eax
 453:	3a 45 fc             	cmp    -0x4(%ebp),%al
 456:	75 05                	jne    45d <strchr+0x1e>
      return (char*)s;
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	eb 13                	jmp    470 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 45d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	84 c0                	test   %al,%al
 469:	75 e2                	jne    44d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 46b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 470:	c9                   	leave  
 471:	c3                   	ret    

00000472 <gets>:

char*
gets(char *buf, int max)
{
 472:	55                   	push   %ebp
 473:	89 e5                	mov    %esp,%ebp
 475:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 478:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 47f:	eb 44                	jmp    4c5 <gets+0x53>
    cc = read(0, &c, 1);
 481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 488:	00 
 489:	8d 45 ef             	lea    -0x11(%ebp),%eax
 48c:	89 44 24 04          	mov    %eax,0x4(%esp)
 490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 497:	e8 3c 01 00 00       	call   5d8 <read>
 49c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 49f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4a3:	7e 2d                	jle    4d2 <gets+0x60>
      break;
    buf[i++] = c;
 4a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a8:	03 45 08             	add    0x8(%ebp),%eax
 4ab:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4af:	88 10                	mov    %dl,(%eax)
 4b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4b5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b9:	3c 0a                	cmp    $0xa,%al
 4bb:	74 16                	je     4d3 <gets+0x61>
 4bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c1:	3c 0d                	cmp    $0xd,%al
 4c3:	74 0e                	je     4d3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c8:	83 c0 01             	add    $0x1,%eax
 4cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4ce:	7c b1                	jl     481 <gets+0xf>
 4d0:	eb 01                	jmp    4d3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4d2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d6:	03 45 08             	add    0x8(%ebp),%eax
 4d9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4df:	c9                   	leave  
 4e0:	c3                   	ret    

000004e1 <stat>:

int
stat(char *n, struct stat *st)
{
 4e1:	55                   	push   %ebp
 4e2:	89 e5                	mov    %esp,%ebp
 4e4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4ee:	00 
 4ef:	8b 45 08             	mov    0x8(%ebp),%eax
 4f2:	89 04 24             	mov    %eax,(%esp)
 4f5:	e8 06 01 00 00       	call   600 <open>
 4fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 501:	79 07                	jns    50a <stat+0x29>
    return -1;
 503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 508:	eb 23                	jmp    52d <stat+0x4c>
  r = fstat(fd, st);
 50a:	8b 45 0c             	mov    0xc(%ebp),%eax
 50d:	89 44 24 04          	mov    %eax,0x4(%esp)
 511:	8b 45 f4             	mov    -0xc(%ebp),%eax
 514:	89 04 24             	mov    %eax,(%esp)
 517:	e8 fc 00 00 00       	call   618 <fstat>
 51c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 51f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 522:	89 04 24             	mov    %eax,(%esp)
 525:	e8 be 00 00 00       	call   5e8 <close>
  return r;
 52a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <atoi>:

int
atoi(const char *s)
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
 532:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 535:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 53c:	eb 23                	jmp    561 <atoi+0x32>
    n = n*10 + *s++ - '0';
 53e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 541:	89 d0                	mov    %edx,%eax
 543:	c1 e0 02             	shl    $0x2,%eax
 546:	01 d0                	add    %edx,%eax
 548:	01 c0                	add    %eax,%eax
 54a:	89 c2                	mov    %eax,%edx
 54c:	8b 45 08             	mov    0x8(%ebp),%eax
 54f:	0f b6 00             	movzbl (%eax),%eax
 552:	0f be c0             	movsbl %al,%eax
 555:	01 d0                	add    %edx,%eax
 557:	83 e8 30             	sub    $0x30,%eax
 55a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 55d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	0f b6 00             	movzbl (%eax),%eax
 567:	3c 2f                	cmp    $0x2f,%al
 569:	7e 0a                	jle    575 <atoi+0x46>
 56b:	8b 45 08             	mov    0x8(%ebp),%eax
 56e:	0f b6 00             	movzbl (%eax),%eax
 571:	3c 39                	cmp    $0x39,%al
 573:	7e c9                	jle    53e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 575:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 578:	c9                   	leave  
 579:	c3                   	ret    

0000057a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 57a:	55                   	push   %ebp
 57b:	89 e5                	mov    %esp,%ebp
 57d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 580:	8b 45 08             	mov    0x8(%ebp),%eax
 583:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 586:	8b 45 0c             	mov    0xc(%ebp),%eax
 589:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 58c:	eb 13                	jmp    5a1 <memmove+0x27>
    *dst++ = *src++;
 58e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 591:	0f b6 10             	movzbl (%eax),%edx
 594:	8b 45 fc             	mov    -0x4(%ebp),%eax
 597:	88 10                	mov    %dl,(%eax)
 599:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 59d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 5a5:	0f 9f c0             	setg   %al
 5a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5ac:	84 c0                	test   %al,%al
 5ae:	75 de                	jne    58e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5b3:	c9                   	leave  
 5b4:	c3                   	ret    
 5b5:	90                   	nop
 5b6:	90                   	nop
 5b7:	90                   	nop

000005b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b8:	b8 01 00 00 00       	mov    $0x1,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <exit>:
SYSCALL(exit)
 5c0:	b8 02 00 00 00       	mov    $0x2,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <wait>:
SYSCALL(wait)
 5c8:	b8 03 00 00 00       	mov    $0x3,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <pipe>:
SYSCALL(pipe)
 5d0:	b8 04 00 00 00       	mov    $0x4,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <read>:
SYSCALL(read)
 5d8:	b8 05 00 00 00       	mov    $0x5,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <write>:
SYSCALL(write)
 5e0:	b8 10 00 00 00       	mov    $0x10,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <close>:
SYSCALL(close)
 5e8:	b8 15 00 00 00       	mov    $0x15,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <kill>:
SYSCALL(kill)
 5f0:	b8 06 00 00 00       	mov    $0x6,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <exec>:
SYSCALL(exec)
 5f8:	b8 07 00 00 00       	mov    $0x7,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <open>:
SYSCALL(open)
 600:	b8 0f 00 00 00       	mov    $0xf,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <mknod>:
SYSCALL(mknod)
 608:	b8 11 00 00 00       	mov    $0x11,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <unlink>:
SYSCALL(unlink)
 610:	b8 12 00 00 00       	mov    $0x12,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <fstat>:
SYSCALL(fstat)
 618:	b8 08 00 00 00       	mov    $0x8,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <link>:
SYSCALL(link)
 620:	b8 13 00 00 00       	mov    $0x13,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <mkdir>:
SYSCALL(mkdir)
 628:	b8 14 00 00 00       	mov    $0x14,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <chdir>:
SYSCALL(chdir)
 630:	b8 09 00 00 00       	mov    $0x9,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <dup>:
SYSCALL(dup)
 638:	b8 0a 00 00 00       	mov    $0xa,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <getpid>:
SYSCALL(getpid)
 640:	b8 0b 00 00 00       	mov    $0xb,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <sbrk>:
SYSCALL(sbrk)
 648:	b8 0c 00 00 00       	mov    $0xc,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <sleep>:
SYSCALL(sleep)
 650:	b8 0d 00 00 00       	mov    $0xd,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <uptime>:
SYSCALL(uptime)
 658:	b8 0e 00 00 00       	mov    $0xe,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <wait2>:
SYSCALL(wait2)
 660:	b8 16 00 00 00       	mov    $0x16,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <set_prio>:
SYSCALL(set_prio)
 668:	b8 17 00 00 00       	mov    $0x17,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <yield>:
SYSCALL(yield)
 670:	b8 18 00 00 00       	mov    $0x18,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
 67b:	83 ec 28             	sub    $0x28,%esp
 67e:	8b 45 0c             	mov    0xc(%ebp),%eax
 681:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 684:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 68b:	00 
 68c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68f:	89 44 24 04          	mov    %eax,0x4(%esp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	89 04 24             	mov    %eax,(%esp)
 699:	e8 42 ff ff ff       	call   5e0 <write>
}
 69e:	c9                   	leave  
 69f:	c3                   	ret    

000006a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b1:	74 17                	je     6ca <printint+0x2a>
 6b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b7:	79 11                	jns    6ca <printint+0x2a>
    neg = 1;
 6b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c3:	f7 d8                	neg    %eax
 6c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c8:	eb 06                	jmp    6d0 <printint+0x30>
  } else {
    x = xx;
 6ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6dd:	ba 00 00 00 00       	mov    $0x0,%edx
 6e2:	f7 f1                	div    %ecx
 6e4:	89 d0                	mov    %edx,%eax
 6e6:	0f b6 90 10 0e 00 00 	movzbl 0xe10(%eax),%edx
 6ed:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6f0:	03 45 f4             	add    -0xc(%ebp),%eax
 6f3:	88 10                	mov    %dl,(%eax)
 6f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6f9:	8b 55 10             	mov    0x10(%ebp),%edx
 6fc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 702:	ba 00 00 00 00       	mov    $0x0,%edx
 707:	f7 75 d4             	divl   -0x2c(%ebp)
 70a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 711:	75 c4                	jne    6d7 <printint+0x37>
  if(neg)
 713:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 717:	74 2a                	je     743 <printint+0xa3>
    buf[i++] = '-';
 719:	8d 45 dc             	lea    -0x24(%ebp),%eax
 71c:	03 45 f4             	add    -0xc(%ebp),%eax
 71f:	c6 00 2d             	movb   $0x2d,(%eax)
 722:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 726:	eb 1b                	jmp    743 <printint+0xa3>
    putc(fd, buf[i]);
 728:	8d 45 dc             	lea    -0x24(%ebp),%eax
 72b:	03 45 f4             	add    -0xc(%ebp),%eax
 72e:	0f b6 00             	movzbl (%eax),%eax
 731:	0f be c0             	movsbl %al,%eax
 734:	89 44 24 04          	mov    %eax,0x4(%esp)
 738:	8b 45 08             	mov    0x8(%ebp),%eax
 73b:	89 04 24             	mov    %eax,(%esp)
 73e:	e8 35 ff ff ff       	call   678 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 743:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74b:	79 db                	jns    728 <printint+0x88>
    putc(fd, buf[i]);
}
 74d:	c9                   	leave  
 74e:	c3                   	ret    

0000074f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 74f:	55                   	push   %ebp
 750:	89 e5                	mov    %esp,%ebp
 752:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 755:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 75c:	8d 45 0c             	lea    0xc(%ebp),%eax
 75f:	83 c0 04             	add    $0x4,%eax
 762:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 765:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 76c:	e9 7d 01 00 00       	jmp    8ee <printf+0x19f>
    c = fmt[i] & 0xff;
 771:	8b 55 0c             	mov    0xc(%ebp),%edx
 774:	8b 45 f0             	mov    -0x10(%ebp),%eax
 777:	01 d0                	add    %edx,%eax
 779:	0f b6 00             	movzbl (%eax),%eax
 77c:	0f be c0             	movsbl %al,%eax
 77f:	25 ff 00 00 00       	and    $0xff,%eax
 784:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 787:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 78b:	75 2c                	jne    7b9 <printf+0x6a>
      if(c == '%'){
 78d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 791:	75 0c                	jne    79f <printf+0x50>
        state = '%';
 793:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 79a:	e9 4b 01 00 00       	jmp    8ea <printf+0x19b>
      } else {
        putc(fd, c);
 79f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a2:	0f be c0             	movsbl %al,%eax
 7a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ac:	89 04 24             	mov    %eax,(%esp)
 7af:	e8 c4 fe ff ff       	call   678 <putc>
 7b4:	e9 31 01 00 00       	jmp    8ea <printf+0x19b>
      }
    } else if(state == '%'){
 7b9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7bd:	0f 85 27 01 00 00    	jne    8ea <printf+0x19b>
      if(c == 'd'){
 7c3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c7:	75 2d                	jne    7f6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7d5:	00 
 7d6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7dd:	00 
 7de:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e2:	8b 45 08             	mov    0x8(%ebp),%eax
 7e5:	89 04 24             	mov    %eax,(%esp)
 7e8:	e8 b3 fe ff ff       	call   6a0 <printint>
        ap++;
 7ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f1:	e9 ed 00 00 00       	jmp    8e3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7f6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7fa:	74 06                	je     802 <printf+0xb3>
 7fc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 800:	75 2d                	jne    82f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 802:	8b 45 e8             	mov    -0x18(%ebp),%eax
 805:	8b 00                	mov    (%eax),%eax
 807:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 80e:	00 
 80f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 816:	00 
 817:	89 44 24 04          	mov    %eax,0x4(%esp)
 81b:	8b 45 08             	mov    0x8(%ebp),%eax
 81e:	89 04 24             	mov    %eax,(%esp)
 821:	e8 7a fe ff ff       	call   6a0 <printint>
        ap++;
 826:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82a:	e9 b4 00 00 00       	jmp    8e3 <printf+0x194>
      } else if(c == 's'){
 82f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 833:	75 46                	jne    87b <printf+0x12c>
        s = (char*)*ap;
 835:	8b 45 e8             	mov    -0x18(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 83d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 841:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 845:	75 27                	jne    86e <printf+0x11f>
          s = "(null)";
 847:	c7 45 f4 4a 0b 00 00 	movl   $0xb4a,-0xc(%ebp)
        while(*s != 0){
 84e:	eb 1e                	jmp    86e <printf+0x11f>
          putc(fd, *s);
 850:	8b 45 f4             	mov    -0xc(%ebp),%eax
 853:	0f b6 00             	movzbl (%eax),%eax
 856:	0f be c0             	movsbl %al,%eax
 859:	89 44 24 04          	mov    %eax,0x4(%esp)
 85d:	8b 45 08             	mov    0x8(%ebp),%eax
 860:	89 04 24             	mov    %eax,(%esp)
 863:	e8 10 fe ff ff       	call   678 <putc>
          s++;
 868:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 86c:	eb 01                	jmp    86f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 86e:	90                   	nop
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	0f b6 00             	movzbl (%eax),%eax
 875:	84 c0                	test   %al,%al
 877:	75 d7                	jne    850 <printf+0x101>
 879:	eb 68                	jmp    8e3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 87b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 87f:	75 1d                	jne    89e <printf+0x14f>
        putc(fd, *ap);
 881:	8b 45 e8             	mov    -0x18(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	0f be c0             	movsbl %al,%eax
 889:	89 44 24 04          	mov    %eax,0x4(%esp)
 88d:	8b 45 08             	mov    0x8(%ebp),%eax
 890:	89 04 24             	mov    %eax,(%esp)
 893:	e8 e0 fd ff ff       	call   678 <putc>
        ap++;
 898:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 89c:	eb 45                	jmp    8e3 <printf+0x194>
      } else if(c == '%'){
 89e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8a2:	75 17                	jne    8bb <printf+0x16c>
        putc(fd, c);
 8a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a7:	0f be c0             	movsbl %al,%eax
 8aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ae:	8b 45 08             	mov    0x8(%ebp),%eax
 8b1:	89 04 24             	mov    %eax,(%esp)
 8b4:	e8 bf fd ff ff       	call   678 <putc>
 8b9:	eb 28                	jmp    8e3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8bb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8c2:	00 
 8c3:	8b 45 08             	mov    0x8(%ebp),%eax
 8c6:	89 04 24             	mov    %eax,(%esp)
 8c9:	e8 aa fd ff ff       	call   678 <putc>
        putc(fd, c);
 8ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d1:	0f be c0             	movsbl %al,%eax
 8d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d8:	8b 45 08             	mov    0x8(%ebp),%eax
 8db:	89 04 24             	mov    %eax,(%esp)
 8de:	e8 95 fd ff ff       	call   678 <putc>
      }
      state = 0;
 8e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	01 d0                	add    %edx,%eax
 8f6:	0f b6 00             	movzbl (%eax),%eax
 8f9:	84 c0                	test   %al,%al
 8fb:	0f 85 70 fe ff ff    	jne    771 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 901:	c9                   	leave  
 902:	c3                   	ret    
 903:	90                   	nop

00000904 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 904:	55                   	push   %ebp
 905:	89 e5                	mov    %esp,%ebp
 907:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 90a:	8b 45 08             	mov    0x8(%ebp),%eax
 90d:	83 e8 08             	sub    $0x8,%eax
 910:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 913:	a1 48 0e 00 00       	mov    0xe48,%eax
 918:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91b:	eb 24                	jmp    941 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	8b 00                	mov    (%eax),%eax
 922:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 925:	77 12                	ja     939 <free+0x35>
 927:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 92d:	77 24                	ja     953 <free+0x4f>
 92f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 932:	8b 00                	mov    (%eax),%eax
 934:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 937:	77 1a                	ja     953 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 941:	8b 45 f8             	mov    -0x8(%ebp),%eax
 944:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 947:	76 d4                	jbe    91d <free+0x19>
 949:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94c:	8b 00                	mov    (%eax),%eax
 94e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 951:	76 ca                	jbe    91d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 953:	8b 45 f8             	mov    -0x8(%ebp),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	c1 e0 03             	shl    $0x3,%eax
 95c:	89 c2                	mov    %eax,%edx
 95e:	03 55 f8             	add    -0x8(%ebp),%edx
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	39 c2                	cmp    %eax,%edx
 968:	75 24                	jne    98e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	8b 50 04             	mov    0x4(%eax),%edx
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	8b 40 04             	mov    0x4(%eax),%eax
 978:	01 c2                	add    %eax,%edx
 97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 980:	8b 45 fc             	mov    -0x4(%ebp),%eax
 983:	8b 00                	mov    (%eax),%eax
 985:	8b 10                	mov    (%eax),%edx
 987:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98a:	89 10                	mov    %edx,(%eax)
 98c:	eb 0a                	jmp    998 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 991:	8b 10                	mov    (%eax),%edx
 993:	8b 45 f8             	mov    -0x8(%ebp),%eax
 996:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 998:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99b:	8b 40 04             	mov    0x4(%eax),%eax
 99e:	c1 e0 03             	shl    $0x3,%eax
 9a1:	03 45 fc             	add    -0x4(%ebp),%eax
 9a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9a7:	75 20                	jne    9c9 <free+0xc5>
    p->s.size += bp->s.size;
 9a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ac:	8b 50 04             	mov    0x4(%eax),%edx
 9af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b2:	8b 40 04             	mov    0x4(%eax),%eax
 9b5:	01 c2                	add    %eax,%edx
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c0:	8b 10                	mov    (%eax),%edx
 9c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c5:	89 10                	mov    %edx,(%eax)
 9c7:	eb 08                	jmp    9d1 <free+0xcd>
  } else
    p->s.ptr = bp;
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9cf:	89 10                	mov    %edx,(%eax)
  freep = p;
 9d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d4:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 9d9:	c9                   	leave  
 9da:	c3                   	ret    

000009db <morecore>:

static Header*
morecore(uint nu)
{
 9db:	55                   	push   %ebp
 9dc:	89 e5                	mov    %esp,%ebp
 9de:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9e1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9e8:	77 07                	ja     9f1 <morecore+0x16>
    nu = 4096;
 9ea:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9f1:	8b 45 08             	mov    0x8(%ebp),%eax
 9f4:	c1 e0 03             	shl    $0x3,%eax
 9f7:	89 04 24             	mov    %eax,(%esp)
 9fa:	e8 49 fc ff ff       	call   648 <sbrk>
 9ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a02:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a06:	75 07                	jne    a0f <morecore+0x34>
    return 0;
 a08:	b8 00 00 00 00       	mov    $0x0,%eax
 a0d:	eb 22                	jmp    a31 <morecore+0x56>
  hp = (Header*)p;
 a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a18:	8b 55 08             	mov    0x8(%ebp),%edx
 a1b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a21:	83 c0 08             	add    $0x8,%eax
 a24:	89 04 24             	mov    %eax,(%esp)
 a27:	e8 d8 fe ff ff       	call   904 <free>
  return freep;
 a2c:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 a31:	c9                   	leave  
 a32:	c3                   	ret    

00000a33 <malloc>:

void*
malloc(uint nbytes)
{
 a33:	55                   	push   %ebp
 a34:	89 e5                	mov    %esp,%ebp
 a36:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a39:	8b 45 08             	mov    0x8(%ebp),%eax
 a3c:	83 c0 07             	add    $0x7,%eax
 a3f:	c1 e8 03             	shr    $0x3,%eax
 a42:	83 c0 01             	add    $0x1,%eax
 a45:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a48:	a1 48 0e 00 00       	mov    0xe48,%eax
 a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a54:	75 23                	jne    a79 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a56:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a60:	a3 48 0e 00 00       	mov    %eax,0xe48
 a65:	a1 48 0e 00 00       	mov    0xe48,%eax
 a6a:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 a6f:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 a76:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7c:	8b 00                	mov    (%eax),%eax
 a7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a84:	8b 40 04             	mov    0x4(%eax),%eax
 a87:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a8a:	72 4d                	jb     ad9 <malloc+0xa6>
      if(p->s.size == nunits)
 a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8f:	8b 40 04             	mov    0x4(%eax),%eax
 a92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a95:	75 0c                	jne    aa3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	8b 10                	mov    (%eax),%edx
 a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a9f:	89 10                	mov    %edx,(%eax)
 aa1:	eb 26                	jmp    ac9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa6:	8b 40 04             	mov    0x4(%eax),%eax
 aa9:	89 c2                	mov    %eax,%edx
 aab:	2b 55 ec             	sub    -0x14(%ebp),%edx
 aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	8b 40 04             	mov    0x4(%eax),%eax
 aba:	c1 e0 03             	shl    $0x3,%eax
 abd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ac6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acc:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad4:	83 c0 08             	add    $0x8,%eax
 ad7:	eb 38                	jmp    b11 <malloc+0xde>
    }
    if(p == freep)
 ad9:	a1 48 0e 00 00       	mov    0xe48,%eax
 ade:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae1:	75 1b                	jne    afe <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ae6:	89 04 24             	mov    %eax,(%esp)
 ae9:	e8 ed fe ff ff       	call   9db <morecore>
 aee:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 af5:	75 07                	jne    afe <malloc+0xcb>
        return 0;
 af7:	b8 00 00 00 00       	mov    $0x0,%eax
 afc:	eb 13                	jmp    b11 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b07:	8b 00                	mov    (%eax),%eax
 b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b0c:	e9 70 ff ff ff       	jmp    a81 <malloc+0x4e>
}
 b11:	c9                   	leave  
 b12:	c3                   	ret    
