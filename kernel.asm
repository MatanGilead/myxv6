
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 1f 40 10 80       	mov    $0x8010401f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 28 91 10 	movl   $0x80109128,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 f4 59 00 00       	call   80105a42 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 15 11 80       	mov    0x80111574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 a1 59 00 00       	call   80105a63 <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 15 11 80       	mov    0x80111574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 bc 59 00 00       	call   80105ac5 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 4d 55 00 00       	call   80105671 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 15 11 80       	mov    0x80111570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 44 59 00 00       	call   80105ac5 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 2f 91 10 80 	movl   $0x8010912f,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 a7 2e 00 00       	call   8010307f <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 40 91 10 80 	movl   $0x80109140,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 6a 2e 00 00       	call   8010307f <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 47 91 10 80 	movl   $0x80109147,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 22 58 00 00       	call   80105a63 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 15 11 80       	mov    0x80111574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 ab 54 00 00       	call   8010574d <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 17 58 00 00       	call   80105ac5 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 2d 07 00 00       	call   80100ac2 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bc:	e8 a2 56 00 00       	call   80105a63 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 4e 91 10 80 	movl   $0x8010914e,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 cb 06 00 00       	call   80100ac2 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 57 91 10 80 	movl   $0x80109157,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 f9 05 00 00       	call   80100ac2 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 da 05 00 00       	call   80100ac2 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 cc 05 00 00       	call   80100ac2 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 c1 05 00 00       	call   80100ac2 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100536:	e8 8a 55 00 00       	call   80105ac5 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 5e 91 10 80 	movl   $0x8010915e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 6d 91 10 80 	movl   $0x8010916d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 7d 55 00 00       	call   80105b14 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 6f 91 10 80 	movl   $0x8010916f,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 ac c5 10 80 01 	movl   $0x1,0x8010c5ac
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <modThatDealsWithNegatives>:
static int tmpPos = 0;
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory


int
modThatDealsWithNegatives(int num1, int num2){
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 10             	sub    $0x10,%esp
  int r = num1 % num2;
801005d3:	8b 45 08             	mov    0x8(%ebp),%eax
801005d6:	89 c2                	mov    %eax,%edx
801005d8:	c1 fa 1f             	sar    $0x1f,%edx
801005db:	f7 7d 0c             	idivl  0xc(%ebp)
801005de:	89 55 fc             	mov    %edx,-0x4(%ebp)
  if(r<0)
801005e1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801005e5:	79 0a                	jns    801005f1 <modThatDealsWithNegatives+0x24>
    return r+num2;
801005e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801005ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
801005ed:	01 d0                	add    %edx,%eax
801005ef:	eb 03                	jmp    801005f4 <modThatDealsWithNegatives+0x27>
  else return r;
801005f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801005f4:	c9                   	leave  
801005f5:	c3                   	ret    

801005f6 <cgaputc>:


static void
cgaputc(int c)
{
801005f6:	55                   	push   %ebp
801005f7:	89 e5                	mov    %esp,%ebp
801005f9:	53                   	push   %ebx
801005fa:	83 ec 44             	sub    $0x44,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100604:	00 
80100605:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060c:	e8 c9 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
80100611:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100618:	e8 93 fc ff ff       	call   801002b0 <inb>
8010061d:	0f b6 c0             	movzbl %al,%eax
80100620:	c1 e0 08             	shl    $0x8,%eax
80100623:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100626:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010062d:	00 
8010062e:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100635:	e8 a0 fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
8010063a:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100641:	e8 6a fc ff ff       	call   801002b0 <inb>
80100646:	0f b6 c0             	movzbl %al,%eax
80100649:	09 45 f4             	or     %eax,-0xc(%ebp)


  if(c == '\n'){
8010064c:	8b 45 08             	mov    0x8(%ebp),%eax
8010064f:	83 f8 0a             	cmp    $0xa,%eax
80100652:	75 3d                	jne    80100691 <cgaputc+0x9b>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	89 ca                	mov    %ecx,%edx
80100676:	29 c2                	sub    %eax,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
    tmpPos = 0; // tmpPos means the offset to the right, means how many you need to go right to get to the end
80100682:	c7 05 f8 c5 10 80 00 	movl   $0x0,0x8010c5f8
80100689:	00 00 00 
8010068c:	e9 2e 03 00 00       	jmp    801009bf <cgaputc+0x3c9>
  }
  else if(c == BACKSPACE){
80100691:	8b 45 08             	mov    0x8(%ebp),%eax
80100694:	3d 00 01 00 00       	cmp    $0x100,%eax
80100699:	75 7a                	jne    80100715 <cgaputc+0x11f>
     if(pos > 0) {
8010069b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010069f:	0f 8e 1a 03 00 00    	jle    801009bf <cgaputc+0x3c9>
      --pos;
801006a5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
      int startingPos = pos;
801006a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i;
      for (i = 0 ; i < tmpPos ; i++){
801006af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801006b6:	eb 37                	jmp    801006ef <cgaputc+0xf9>
  memmove(crt+startingPos, crt+startingPos+1, 1); // take the rest of the line on the right 1 place to the left
801006b8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801006c0:	83 c2 01             	add    $0x1,%edx
801006c3:	01 d2                	add    %edx,%edx
801006c5:	01 c2                	add    %eax,%edx
801006c7:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006cc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801006cf:	01 c9                	add    %ecx,%ecx
801006d1:	01 c8                	add    %ecx,%eax
801006d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801006da:	00 
801006db:	89 54 24 04          	mov    %edx,0x4(%esp)
801006df:	89 04 24             	mov    %eax,(%esp)
801006e2:	e8 9e 56 00 00       	call   80105d85 <memmove>
  startingPos++;
801006e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  else if(c == BACKSPACE){
     if(pos > 0) {
      --pos;
      int startingPos = pos;
      int i;
      for (i = 0 ; i < tmpPos ; i++){
801006eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801006ef:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
801006f4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801006f7:	7c bf                	jl     801006b8 <cgaputc+0xc2>
  memmove(crt+startingPos, crt+startingPos+1, 1); // take the rest of the line on the right 1 place to the left
  startingPos++;
      }
     crt[pos+tmpPos] = ' ' | 0x0700; // the last place which held the last char should now be blank
801006f9:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801006ff:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
80100704:	03 45 f4             	add    -0xc(%ebp),%eax
80100707:	01 c0                	add    %eax,%eax
80100709:	01 d0                	add    %edx,%eax
8010070b:	66 c7 00 20 07       	movw   $0x720,(%eax)
80100710:	e9 aa 02 00 00       	jmp    801009bf <cgaputc+0x3c9>
    }
  }
  else  if (c == KEY_LF) {
80100715:	8b 45 08             	mov    0x8(%ebp),%eax
80100718:	3d e4 00 00 00       	cmp    $0xe4,%eax
8010071d:	75 20                	jne    8010073f <cgaputc+0x149>
    if (pos > 0) {
8010071f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100723:	0f 8e 96 02 00 00    	jle    801009bf <cgaputc+0x3c9>
      --pos;
80100729:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
      tmpPos++; // counter for how left are we from the last char in the line
8010072d:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
80100732:	83 c0 01             	add    $0x1,%eax
80100735:	a3 f8 c5 10 80       	mov    %eax,0x8010c5f8
8010073a:	e9 80 02 00 00       	jmp    801009bf <cgaputc+0x3c9>
    }
  }
  else if (c == KEY_RT) {
8010073f:	8b 45 08             	mov    0x8(%ebp),%eax
80100742:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100747:	75 23                	jne    8010076c <cgaputc+0x176>
    if (tmpPos > 0) {
80100749:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
8010074e:	85 c0                	test   %eax,%eax
80100750:	0f 8e 69 02 00 00    	jle    801009bf <cgaputc+0x3c9>
      ++pos;
80100756:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      tmpPos--; // counter for how left are we from the last char in the line
8010075a:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
8010075f:	83 e8 01             	sub    $0x1,%eax
80100762:	a3 f8 c5 10 80       	mov    %eax,0x8010c5f8
80100767:	e9 53 02 00 00       	jmp    801009bf <cgaputc+0x3c9>
    }
  }
  else if(c == KEY_UP) { // take the historyCommand of calculated current index and copy it to crt, command not executed gets deleted once pressing up
8010076c:	8b 45 08             	mov    0x8(%ebp),%eax
8010076f:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100774:	0f 85 cd 00 00 00    	jne    80100847 <cgaputc+0x251>
      int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
8010077a:	8b 15 a0 c5 10 80    	mov    0x8010c5a0,%edx
80100780:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100785:	89 d1                	mov    %edx,%ecx
80100787:	29 c1                	sub    %eax,%ecx
80100789:	89 c8                	mov    %ecx,%eax
8010078b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100792:	00 
80100793:	89 04 24             	mov    %eax,(%esp)
80100796:	e8 32 fe ff ff       	call   801005cd <modThatDealsWithNegatives>
8010079b:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int i;
      for (i = 0; i < strlen(historyArray[historyIndex])-1 ; i++) {
8010079e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
801007a5:	eb 5b                	jmp    80100802 <cgaputc+0x20c>
        c = historyArray[historyIndex][i];
801007a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801007aa:	c1 e0 07             	shl    $0x7,%eax
801007ad:	03 45 e8             	add    -0x18(%ebp),%eax
801007b0:	05 40 18 11 80       	add    $0x80111840,%eax
801007b5:	0f b6 00             	movzbl (%eax),%eax
801007b8:	0f be c0             	movsbl %al,%eax
801007bb:	89 45 08             	mov    %eax,0x8(%ebp)
        memmove(crt+pos, &c, 1);
801007be:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007c6:	01 d2                	add    %edx,%edx
801007c8:	01 d0                	add    %edx,%eax
801007ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801007d1:	00 
801007d2:	8d 55 08             	lea    0x8(%ebp),%edx
801007d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801007d9:	89 04 24             	mov    %eax,(%esp)
801007dc:	e8 a4 55 00 00       	call   80105d85 <memmove>
        crt[pos++] = (c&0xff) | 0x0700;  // black on white
801007e1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007e9:	01 d2                	add    %edx,%edx
801007eb:	01 c2                	add    %eax,%edx
801007ed:	8b 45 08             	mov    0x8(%ebp),%eax
801007f0:	66 25 ff 00          	and    $0xff,%ax
801007f4:	80 cc 07             	or     $0x7,%ah
801007f7:	66 89 02             	mov    %ax,(%edx)
801007fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
  }
  else if(c == KEY_UP) { // take the historyCommand of calculated current index and copy it to crt, command not executed gets deleted once pressing up
      int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
      int i;
      for (i = 0; i < strlen(historyArray[historyIndex])-1 ; i++) {
801007fe:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80100802:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100805:	c1 e0 07             	shl    $0x7,%eax
80100808:	05 40 18 11 80       	add    $0x80111840,%eax
8010080d:	89 04 24             	mov    %eax,(%esp)
80100810:	e8 1b 57 00 00       	call   80105f30 <strlen>
80100815:	83 e8 01             	sub    $0x1,%eax
80100818:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010081b:	7f 8a                	jg     801007a7 <cgaputc+0x1b1>
        c = historyArray[historyIndex][i];
        memmove(crt+pos, &c, 1);
        crt[pos++] = (c&0xff) | 0x0700;  // black on white
      }
      crt[pos+strlen(historyArray[historyIndex])] = ' ' | 0x0700;
8010081d:	8b 1d 00 a0 10 80    	mov    0x8010a000,%ebx
80100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100826:	c1 e0 07             	shl    $0x7,%eax
80100829:	05 40 18 11 80       	add    $0x80111840,%eax
8010082e:	89 04 24             	mov    %eax,(%esp)
80100831:	e8 fa 56 00 00       	call   80105f30 <strlen>
80100836:	03 45 f4             	add    -0xc(%ebp),%eax
80100839:	01 c0                	add    %eax,%eax
8010083b:	01 d8                	add    %ebx,%eax
8010083d:	66 c7 00 20 07       	movw   $0x720,(%eax)
80100842:	e9 78 01 00 00       	jmp    801009bf <cgaputc+0x3c9>

  }
  else if(c == KEY_DN) {
80100847:	8b 45 08             	mov    0x8(%ebp),%eax
8010084a:	3d e3 00 00 00       	cmp    $0xe3,%eax
8010084f:	0f 85 cd 00 00 00    	jne    80100922 <cgaputc+0x32c>
     int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
80100855:	8b 15 a0 c5 10 80    	mov    0x8010c5a0,%edx
8010085b:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100860:	89 d1                	mov    %edx,%ecx
80100862:	29 c1                	sub    %eax,%ecx
80100864:	89 c8                	mov    %ecx,%eax
80100866:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010086d:	00 
8010086e:	89 04 24             	mov    %eax,(%esp)
80100871:	e8 57 fd ff ff       	call   801005cd <modThatDealsWithNegatives>
80100876:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      int i2;
      for (i2 = 0; i2 < strlen(historyArray[historyIndex])-1 ; i2++) {
80100879:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100880:	eb 5b                	jmp    801008dd <cgaputc+0x2e7>
        c = historyArray[historyIndex][i2];
80100882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100885:	c1 e0 07             	shl    $0x7,%eax
80100888:	03 45 e4             	add    -0x1c(%ebp),%eax
8010088b:	05 40 18 11 80       	add    $0x80111840,%eax
80100890:	0f b6 00             	movzbl (%eax),%eax
80100893:	0f be c0             	movsbl %al,%eax
80100896:	89 45 08             	mov    %eax,0x8(%ebp)
        memmove(crt+pos, &c, 1);
80100899:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010089e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008a1:	01 d2                	add    %edx,%edx
801008a3:	01 d0                	add    %edx,%eax
801008a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801008ac:	00 
801008ad:	8d 55 08             	lea    0x8(%ebp),%edx
801008b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801008b4:	89 04 24             	mov    %eax,(%esp)
801008b7:	e8 c9 54 00 00       	call   80105d85 <memmove>
        crt[pos++] = (c&0xff) | 0x0700;
801008bc:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801008c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008c4:	01 d2                	add    %edx,%edx
801008c6:	01 c2                	add    %eax,%edx
801008c8:	8b 45 08             	mov    0x8(%ebp),%eax
801008cb:	66 25 ff 00          	and    $0xff,%ax
801008cf:	80 cc 07             	or     $0x7,%ah
801008d2:	66 89 02             	mov    %ax,(%edx)
801008d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  }
  else if(c == KEY_DN) {
     int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
      int i2;
      for (i2 = 0; i2 < strlen(historyArray[historyIndex])-1 ; i2++) {
801008d9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801008dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801008e0:	c1 e0 07             	shl    $0x7,%eax
801008e3:	05 40 18 11 80       	add    $0x80111840,%eax
801008e8:	89 04 24             	mov    %eax,(%esp)
801008eb:	e8 40 56 00 00       	call   80105f30 <strlen>
801008f0:	83 e8 01             	sub    $0x1,%eax
801008f3:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801008f6:	7f 8a                	jg     80100882 <cgaputc+0x28c>
        c = historyArray[historyIndex][i2];
        memmove(crt+pos, &c, 1);
        crt[pos++] = (c&0xff) | 0x0700;
      }
      crt[pos+strlen(historyArray[historyIndex])] = ' ' | 0x0700;
801008f8:	8b 1d 00 a0 10 80    	mov    0x8010a000,%ebx
801008fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100901:	c1 e0 07             	shl    $0x7,%eax
80100904:	05 40 18 11 80       	add    $0x80111840,%eax
80100909:	89 04 24             	mov    %eax,(%esp)
8010090c:	e8 1f 56 00 00       	call   80105f30 <strlen>
80100911:	03 45 f4             	add    -0xc(%ebp),%eax
80100914:	01 c0                	add    %eax,%eax
80100916:	01 d8                	add    %ebx,%eax
80100918:	66 c7 00 20 07       	movw   $0x720,(%eax)
8010091d:	e9 9d 00 00 00       	jmp    801009bf <cgaputc+0x3c9>
  }
  else
    if ( !tmpPos ) { // if we are at the end of the line, just write c to crt (tmpPos = 0 => the most right, !tmpPos=1 means we can write regular)
80100922:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
80100927:	85 c0                	test   %eax,%eax
80100929:	75 1f                	jne    8010094a <cgaputc+0x354>
      crt[pos++] = (c&0xff) | 0x0700;
8010092b:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100930:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100933:	01 d2                	add    %edx,%edx
80100935:	01 c2                	add    %eax,%edx
80100937:	8b 45 08             	mov    0x8(%ebp),%eax
8010093a:	66 25 ff 00          	and    $0xff,%ax
8010093e:	80 cc 07             	or     $0x7,%ah
80100941:	66 89 02             	mov    %ax,(%edx)
80100944:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100948:	eb 75                	jmp    801009bf <cgaputc+0x3c9>
    }
    else { // if we're typing in the middle of the command, we shift the remaining right sentene from tmpPos to the right and write c
      int endPos = pos + tmpPos -1; // go to the end of the line
8010094a:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
8010094f:	03 45 f4             	add    -0xc(%ebp),%eax
80100952:	83 e8 01             	sub    $0x1,%eax
80100955:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int i;
      for (i = 0; i < tmpPos ; i++) {
80100958:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010095f:	eb 37                	jmp    80100998 <cgaputc+0x3a2>
        memmove(crt+endPos+1, crt+endPos, 1); // go backwards and copy forward in the process
80100961:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100966:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100969:	01 d2                	add    %edx,%edx
8010096b:	01 c2                	add    %eax,%edx
8010096d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100972:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80100975:	83 c1 01             	add    $0x1,%ecx
80100978:	01 c9                	add    %ecx,%ecx
8010097a:	01 c8                	add    %ecx,%eax
8010097c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100983:	00 
80100984:	89 54 24 04          	mov    %edx,0x4(%esp)
80100988:	89 04 24             	mov    %eax,(%esp)
8010098b:	e8 f5 53 00 00       	call   80105d85 <memmove>
        endPos--;
80100990:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
      crt[pos++] = (c&0xff) | 0x0700;
    }
    else { // if we're typing in the middle of the command, we shift the remaining right sentene from tmpPos to the right and write c
      int endPos = pos + tmpPos -1; // go to the end of the line
      int i;
      for (i = 0; i < tmpPos ; i++) {
80100994:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80100998:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
8010099d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
801009a0:	7c bf                	jl     80100961 <cgaputc+0x36b>
        memmove(crt+endPos+1, crt+endPos, 1); // go backwards and copy forward in the process
        endPos--;
      }
      crt[pos++] = (c&0xff) | 0x0700;
801009a2:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801009a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009aa:	01 d2                	add    %edx,%edx
801009ac:	01 c2                	add    %eax,%edx
801009ae:	8b 45 08             	mov    0x8(%ebp),%eax
801009b1:	66 25 ff 00          	and    $0xff,%ax
801009b5:	80 cc 07             	or     $0x7,%ah
801009b8:	66 89 02             	mov    %ax,(%edx)
801009bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }

  if((pos/80) >= 24){  // Scroll up.
801009bf:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801009c6:	7e 53                	jle    80100a1b <cgaputc+0x425>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801009c8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801009cd:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801009d3:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801009d8:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801009df:	00 
801009e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801009e4:	89 04 24             	mov    %eax,(%esp)
801009e7:	e8 99 53 00 00       	call   80105d85 <memmove>
    pos -= 80;
801009ec:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801009f0:	b8 80 07 00 00       	mov    $0x780,%eax
801009f5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801009f8:	01 c0                	add    %eax,%eax
801009fa:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
80100a00:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100a03:	01 c9                	add    %ecx,%ecx
80100a05:	01 ca                	add    %ecx,%edx
80100a07:	89 44 24 08          	mov    %eax,0x8(%esp)
80100a0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100a12:	00 
80100a13:	89 14 24             	mov    %edx,(%esp)
80100a16:	e8 97 52 00 00       	call   80105cb2 <memset>
  }

  outb(CRTPORT, 14);
80100a1b:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100a22:	00 
80100a23:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100a2a:	e8 ab f8 ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a32:	c1 f8 08             	sar    $0x8,%eax
80100a35:	0f b6 c0             	movzbl %al,%eax
80100a38:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a3c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100a43:	e8 92 f8 ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100a48:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100a4f:	00 
80100a50:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100a57:	e8 7e f8 ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a5f:	0f b6 c0             	movzbl %al,%eax
80100a62:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a66:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100a6d:	e8 68 f8 ff ff       	call   801002da <outb>

  if (c != KEY_LF && c != KEY_RT && c != KEY_UP && c != KEY_DN && c != '\n' && !tmpPos )
80100a72:	8b 45 08             	mov    0x8(%ebp),%eax
80100a75:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100a7a:	74 40                	je     80100abc <cgaputc+0x4c6>
80100a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a7f:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100a84:	74 36                	je     80100abc <cgaputc+0x4c6>
80100a86:	8b 45 08             	mov    0x8(%ebp),%eax
80100a89:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100a8e:	74 2c                	je     80100abc <cgaputc+0x4c6>
80100a90:	8b 45 08             	mov    0x8(%ebp),%eax
80100a93:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100a98:	74 22                	je     80100abc <cgaputc+0x4c6>
80100a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100a9d:	83 f8 0a             	cmp    $0xa,%eax
80100aa0:	74 1a                	je     80100abc <cgaputc+0x4c6>
80100aa2:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
80100aa7:	85 c0                	test   %eax,%eax
80100aa9:	75 11                	jne    80100abc <cgaputc+0x4c6>
    crt[pos] = ' ' | 0x0700;
80100aab:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100ab0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab3:	01 d2                	add    %edx,%edx
80100ab5:	01 d0                	add    %edx,%eax
80100ab7:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100abc:	83 c4 44             	add    $0x44,%esp
80100abf:	5b                   	pop    %ebx
80100ac0:	5d                   	pop    %ebp
80100ac1:	c3                   	ret    

80100ac2 <consputc>:

void
consputc(int c)
{
80100ac2:	55                   	push   %ebp
80100ac3:	89 e5                	mov    %esp,%ebp
80100ac5:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100ac8:	a1 ac c5 10 80       	mov    0x8010c5ac,%eax
80100acd:	85 c0                	test   %eax,%eax
80100acf:	74 07                	je     80100ad8 <consputc+0x16>
    cli();
80100ad1:	e8 22 f8 ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100ad6:	eb fe                	jmp    80100ad6 <consputc+0x14>
  }

  switch(c) {
80100ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80100adb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100ae0:	75 26                	jne    80100b08 <consputc+0x46>
    case BACKSPACE:
      uartputc('\b'); uartputc(' '); uartputc('\b'); break;
80100ae2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100ae9:	e8 8b 6c 00 00       	call   80107779 <uartputc>
80100aee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100af5:	e8 7f 6c 00 00       	call   80107779 <uartputc>
80100afa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100b01:	e8 73 6c 00 00       	call   80107779 <uartputc>
80100b06:	eb 0b                	jmp    80100b13 <consputc+0x51>
    default:
      uartputc(c);
80100b08:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0b:	89 04 24             	mov    %eax,(%esp)
80100b0e:	e8 66 6c 00 00       	call   80107779 <uartputc>
  }
  cgaputc(c);
80100b13:	8b 45 08             	mov    0x8(%ebp),%eax
80100b16:	89 04 24             	mov    %eax,(%esp)
80100b19:	e8 d8 fa ff ff       	call   801005f6 <cgaputc>
}
80100b1e:	c9                   	leave  
80100b1f:	c3                   	ret    

80100b20 <DeleteCurrentUnfinishedCommand>:
#define C(x)  ((x)-'@')  // Control-x


void
DeleteCurrentUnfinishedCommand()
{
80100b20:	55                   	push   %ebp
80100b21:	89 e5                	mov    %esp,%ebp
80100b23:	83 ec 18             	sub    $0x18,%esp
  while(input.w < input.e) { // if we're in the middle of the command - go to the right
80100b26:	eb 19                	jmp    80100b41 <DeleteCurrentUnfinishedCommand+0x21>
        input.w++;
80100b28:	a1 38 18 11 80       	mov    0x80111838,%eax
80100b2d:	83 c0 01             	add    $0x1,%eax
80100b30:	a3 38 18 11 80       	mov    %eax,0x80111838
        consputc(KEY_RT);
80100b35:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100b3c:	e8 81 ff ff ff       	call   80100ac2 <consputc>


void
DeleteCurrentUnfinishedCommand()
{
  while(input.w < input.e) { // if we're in the middle of the command - go to the right
80100b41:	8b 15 38 18 11 80    	mov    0x80111838,%edx
80100b47:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100b4c:	39 c2                	cmp    %eax,%edx
80100b4e:	72 d8                	jb     80100b28 <DeleteCurrentUnfinishedCommand+0x8>
        input.w++;
        consputc(KEY_RT);
  }
  while(input.e != input.r && input.buf[(input.e-1) % INPUT_BUF] != '\n'){ // same as BACKSPACE: do it for entire line
80100b50:	eb 35                	jmp    80100b87 <DeleteCurrentUnfinishedCommand+0x67>
    input.e--;
80100b52:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100b57:	83 e8 01             	sub    $0x1,%eax
80100b5a:	a3 3c 18 11 80       	mov    %eax,0x8011183c
    if(input.w != input.r)
80100b5f:	8b 15 38 18 11 80    	mov    0x80111838,%edx
80100b65:	a1 34 18 11 80       	mov    0x80111834,%eax
80100b6a:	39 c2                	cmp    %eax,%edx
80100b6c:	74 0d                	je     80100b7b <DeleteCurrentUnfinishedCommand+0x5b>
      input.w--;
80100b6e:	a1 38 18 11 80       	mov    0x80111838,%eax
80100b73:	83 e8 01             	sub    $0x1,%eax
80100b76:	a3 38 18 11 80       	mov    %eax,0x80111838
      consputc(BACKSPACE);
80100b7b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100b82:	e8 3b ff ff ff       	call   80100ac2 <consputc>
{
  while(input.w < input.e) { // if we're in the middle of the command - go to the right
        input.w++;
        consputc(KEY_RT);
  }
  while(input.e != input.r && input.buf[(input.e-1) % INPUT_BUF] != '\n'){ // same as BACKSPACE: do it for entire line
80100b87:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100b8d:	a1 34 18 11 80       	mov    0x80111834,%eax
80100b92:	39 c2                	cmp    %eax,%edx
80100b94:	74 16                	je     80100bac <DeleteCurrentUnfinishedCommand+0x8c>
80100b96:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100b9b:	83 e8 01             	sub    $0x1,%eax
80100b9e:	83 e0 7f             	and    $0x7f,%eax
80100ba1:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
80100ba8:	3c 0a                	cmp    $0xa,%al
80100baa:	75 a6                	jne    80100b52 <DeleteCurrentUnfinishedCommand+0x32>
    input.e--;
    if(input.w != input.r)
      input.w--;
      consputc(BACKSPACE);
  }
}
80100bac:	c9                   	leave  
80100bad:	c3                   	ret    

80100bae <consoleintr>:



void
consoleintr(int (*getc)(void))
{
80100bae:	55                   	push   %ebp
80100baf:	89 e5                	mov    %esp,%ebp
80100bb1:	53                   	push   %ebx
80100bb2:	83 ec 44             	sub    $0x44,%esp
  int c;

  acquire(&input.lock);
80100bb5:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100bbc:	e8 a2 4e 00 00       	call   80105a63 <acquire>
  while((c = getc()) >= 0){
80100bc1:	e9 5a 05 00 00       	jmp    80101120 <consoleintr+0x572>
    switch(c){
80100bc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc9:	83 f8 7f             	cmp    $0x7f,%eax
80100bcc:	0f 84 ae 00 00 00    	je     80100c80 <consoleintr+0xd2>
80100bd2:	83 f8 7f             	cmp    $0x7f,%eax
80100bd5:	7f 18                	jg     80100bef <consoleintr+0x41>
80100bd7:	83 f8 10             	cmp    $0x10,%eax
80100bda:	74 50                	je     80100c2c <consoleintr+0x7e>
80100bdc:	83 f8 15             	cmp    $0x15,%eax
80100bdf:	74 70                	je     80100c51 <consoleintr+0xa3>
80100be1:	83 f8 08             	cmp    $0x8,%eax
80100be4:	0f 84 96 00 00 00    	je     80100c80 <consoleintr+0xd2>
80100bea:	e9 5e 03 00 00       	jmp    80100f4d <consoleintr+0x39f>
80100bef:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100bf4:	0f 84 75 02 00 00    	je     80100e6f <consoleintr+0x2c1>
80100bfa:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100bff:	7f 10                	jg     80100c11 <consoleintr+0x63>
80100c01:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100c06:	0f 84 6b 01 00 00    	je     80100d77 <consoleintr+0x1c9>
80100c0c:	e9 3c 03 00 00       	jmp    80100f4d <consoleintr+0x39f>
80100c11:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100c16:	0f 84 f9 00 00 00    	je     80100d15 <consoleintr+0x167>
80100c1c:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100c21:	0f 84 1f 01 00 00    	je     80100d46 <consoleintr+0x198>
80100c27:	e9 21 03 00 00       	jmp    80100f4d <consoleintr+0x39f>
    case C('P'):  // Process listing.
      procdump();
80100c2c:	e8 c2 4b 00 00       	call   801057f3 <procdump>
      break;
80100c31:	e9 ea 04 00 00       	jmp    80101120 <consoleintr+0x572>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100c36:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100c3b:	83 e8 01             	sub    $0x1,%eax
80100c3e:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(BACKSPACE);
80100c43:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100c4a:	e8 73 fe ff ff       	call   80100ac2 <consputc>
80100c4f:	eb 01                	jmp    80100c52 <consoleintr+0xa4>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100c51:	90                   	nop
80100c52:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100c58:	a1 38 18 11 80       	mov    0x80111838,%eax
80100c5d:	39 c2                	cmp    %eax,%edx
80100c5f:	0f 84 a5 04 00 00    	je     8010110a <consoleintr+0x55c>
80100c65:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100c6a:	83 e8 01             	sub    $0x1,%eax
80100c6d:	83 e0 7f             	and    $0x7f,%eax
80100c70:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
80100c77:	3c 0a                	cmp    $0xa,%al
80100c79:	75 bb                	jne    80100c36 <consoleintr+0x88>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c7b:	e9 8a 04 00 00       	jmp    8010110a <consoleintr+0x55c>
    case C('H'): case '\x7f':  // Backspace
      if(input.w != input.r) {
80100c80:	8b 15 38 18 11 80    	mov    0x80111838,%edx
80100c86:	a1 34 18 11 80       	mov    0x80111834,%eax
80100c8b:	39 c2                	cmp    %eax,%edx
80100c8d:	0f 84 7a 04 00 00    	je     8010110d <consoleintr+0x55f>
  int forwardPos = input.w;
80100c93:	a1 38 18 11 80       	mov    0x80111838,%eax
80100c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int j;
  for (j = 0 ; j < input.e-input.w ; j++){ // take the rest of the line on the right 1 place to the left
80100c9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80100ca2:	eb 2d                	jmp    80100cd1 <consoleintr+0x123>
    input.buf[forwardPos-1 % INPUT_BUF] = input.buf[forwardPos % INPUT_BUF];
80100ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ca7:	8d 48 ff             	lea    -0x1(%eax),%ecx
80100caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100cad:	89 c2                	mov    %eax,%edx
80100caf:	c1 fa 1f             	sar    $0x1f,%edx
80100cb2:	c1 ea 19             	shr    $0x19,%edx
80100cb5:	01 d0                	add    %edx,%eax
80100cb7:	83 e0 7f             	and    $0x7f,%eax
80100cba:	29 d0                	sub    %edx,%eax
80100cbc:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
80100cc3:	88 81 b4 17 11 80    	mov    %al,-0x7feee84c(%ecx)
    forwardPos++;
80100cc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.w != input.r) {
  int forwardPos = input.w;
  int j;
  for (j = 0 ; j < input.e-input.w ; j++){ // take the rest of the line on the right 1 place to the left
80100ccd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cd4:	8b 0d 3c 18 11 80    	mov    0x8011183c,%ecx
80100cda:	8b 15 38 18 11 80    	mov    0x80111838,%edx
80100ce0:	89 cb                	mov    %ecx,%ebx
80100ce2:	29 d3                	sub    %edx,%ebx
80100ce4:	89 da                	mov    %ebx,%edx
80100ce6:	39 d0                	cmp    %edx,%eax
80100ce8:	72 ba                	jb     80100ca4 <consoleintr+0xf6>
    input.buf[forwardPos-1 % INPUT_BUF] = input.buf[forwardPos % INPUT_BUF];
    forwardPos++;
  }
  input.e--;
80100cea:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100cef:	83 e8 01             	sub    $0x1,%eax
80100cf2:	a3 3c 18 11 80       	mov    %eax,0x8011183c
  input.w--;
80100cf7:	a1 38 18 11 80       	mov    0x80111838,%eax
80100cfc:	83 e8 01             	sub    $0x1,%eax
80100cff:	a3 38 18 11 80       	mov    %eax,0x80111838
        consputc(BACKSPACE);
80100d04:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100d0b:	e8 b2 fd ff ff       	call   80100ac2 <consputc>
      }
      break;
80100d10:	e9 f8 03 00 00       	jmp    8010110d <consoleintr+0x55f>
    case KEY_LF:
      if(input.r < input.w) {
80100d15:	8b 15 34 18 11 80    	mov    0x80111834,%edx
80100d1b:	a1 38 18 11 80       	mov    0x80111838,%eax
80100d20:	39 c2                	cmp    %eax,%edx
80100d22:	0f 83 e8 03 00 00    	jae    80101110 <consoleintr+0x562>
        input.w--;
80100d28:	a1 38 18 11 80       	mov    0x80111838,%eax
80100d2d:	83 e8 01             	sub    $0x1,%eax
80100d30:	a3 38 18 11 80       	mov    %eax,0x80111838
        consputc(KEY_LF);
80100d35:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100d3c:	e8 81 fd ff ff       	call   80100ac2 <consputc>
      }
      break;
80100d41:	e9 ca 03 00 00       	jmp    80101110 <consoleintr+0x562>
    case KEY_RT:
      if(input.w < input.e) {
80100d46:	8b 15 38 18 11 80    	mov    0x80111838,%edx
80100d4c:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100d51:	39 c2                	cmp    %eax,%edx
80100d53:	0f 83 ba 03 00 00    	jae    80101113 <consoleintr+0x565>
        input.w++;
80100d59:	a1 38 18 11 80       	mov    0x80111838,%eax
80100d5e:	83 c0 01             	add    $0x1,%eax
80100d61:	a3 38 18 11 80       	mov    %eax,0x80111838
        consputc(KEY_RT);
80100d66:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100d6d:	e8 50 fd ff ff       	call   80100ac2 <consputc>
      }
      break;
80100d72:	e9 9c 03 00 00       	jmp    80101113 <consoleintr+0x565>
    case KEY_UP:
      if (commandExecuted == 0 && historyArrayIsFull == 0) { // no history yet, nothing been executed
80100d77:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100d7c:	85 c0                	test   %eax,%eax
80100d7e:	75 0d                	jne    80100d8d <consoleintr+0x1df>
80100d80:	a1 a4 c5 10 80       	mov    0x8010c5a4,%eax
80100d85:	85 c0                	test   %eax,%eax
80100d87:	0f 84 93 03 00 00    	je     80101120 <consoleintr+0x572>
        break;
      }
      else if (commandExecuted-currentHistoryPos == 0 && historyArrayIsFull==0) { // we are at the last command executed, can't go up
80100d8d:	8b 15 a0 c5 10 80    	mov    0x8010c5a0,%edx
80100d93:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100d98:	39 c2                	cmp    %eax,%edx
80100d9a:	75 0d                	jne    80100da9 <consoleintr+0x1fb>
80100d9c:	a1 a4 c5 10 80       	mov    0x8010c5a4,%eax
80100da1:	85 c0                	test   %eax,%eax
80100da3:	0f 84 77 03 00 00    	je     80101120 <consoleintr+0x572>
        break;
      }
      else if (currentHistoryPos != MAX_HISTORY) { // can perform history execution.
80100da9:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100dae:	83 f8 10             	cmp    $0x10,%eax
80100db1:	0f 84 5f 03 00 00    	je     80101116 <consoleintr+0x568>
  if(currentHistoryPos < MAX_HISTORY){
80100db7:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100dbc:	83 f8 0f             	cmp    $0xf,%eax
80100dbf:	7f 0d                	jg     80100dce <consoleintr+0x220>
    currentHistoryPos = currentHistoryPos + 1;
80100dc1:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100dc6:	83 c0 01             	add    $0x1,%eax
80100dc9:	a3 a8 c5 10 80       	mov    %eax,0x8010c5a8
  }
        DeleteCurrentUnfinishedCommand();
80100dce:	e8 4d fd ff ff       	call   80100b20 <DeleteCurrentUnfinishedCommand>
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
80100dd3:	8b 15 a0 c5 10 80    	mov    0x8010c5a0,%edx
80100dd9:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100dde:	89 d1                	mov    %edx,%ecx
80100de0:	29 c1                	sub    %eax,%ecx
80100de2:	89 c8                	mov    %ecx,%eax
80100de4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100deb:	00 
80100dec:	89 04 24             	mov    %eax,(%esp)
80100def:	e8 d9 f7 ff ff       	call   801005cd <modThatDealsWithNegatives>
80100df4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
80100df7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100dfe:	eb 43                	jmp    80100e43 <consoleintr+0x295>
    c = historyArray[tmpIndex][j];
80100e00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e03:	c1 e0 07             	shl    $0x7,%eax
80100e06:	03 45 ec             	add    -0x14(%ebp),%eax
80100e09:	05 40 18 11 80       	add    $0x80111840,%eax
80100e0e:	0f b6 00             	movzbl (%eax),%eax
80100e11:	0f be c0             	movsbl %al,%eax
80100e14:	89 45 d8             	mov    %eax,-0x28(%ebp)
          input.buf[input.w++ % INPUT_BUF] = c;
80100e17:	a1 38 18 11 80       	mov    0x80111838,%eax
80100e1c:	89 c1                	mov    %eax,%ecx
80100e1e:	83 e1 7f             	and    $0x7f,%ecx
80100e21:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100e24:	88 91 b4 17 11 80    	mov    %dl,-0x7feee84c(%ecx)
80100e2a:	83 c0 01             	add    $0x1,%eax
80100e2d:	a3 38 18 11 80       	mov    %eax,0x80111838
    input.e++;
80100e32:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100e37:	83 c0 01             	add    $0x1,%eax
80100e3a:	a3 3c 18 11 80       	mov    %eax,0x8011183c
    currentHistoryPos = currentHistoryPos + 1;
  }
        DeleteCurrentUnfinishedCommand();
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
80100e3f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e46:	c1 e0 07             	shl    $0x7,%eax
80100e49:	05 40 18 11 80       	add    $0x80111840,%eax
80100e4e:	89 04 24             	mov    %eax,(%esp)
80100e51:	e8 da 50 00 00       	call   80105f30 <strlen>
80100e56:	83 e8 01             	sub    $0x1,%eax
80100e59:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e5c:	7f a2                	jg     80100e00 <consoleintr+0x252>
    c = historyArray[tmpIndex][j];
          input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
        consputc(KEY_UP);
80100e5e:	c7 04 24 e2 00 00 00 	movl   $0xe2,(%esp)
80100e65:	e8 58 fc ff ff       	call   80100ac2 <consputc>
      }
      break;
80100e6a:	e9 a7 02 00 00       	jmp    80101116 <consoleintr+0x568>

    case KEY_DN:
      if (commandExecuted == 0 && historyArrayIsFull == 0) {
80100e6f:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100e74:	85 c0                	test   %eax,%eax
80100e76:	75 0d                	jne    80100e85 <consoleintr+0x2d7>
80100e78:	a1 a4 c5 10 80       	mov    0x8010c5a4,%eax
80100e7d:	85 c0                	test   %eax,%eax
80100e7f:	0f 84 9b 02 00 00    	je     80101120 <consoleintr+0x572>
        break;
      }
      else if (currentHistoryPos==0 ) {
80100e85:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100e8a:	85 c0                	test   %eax,%eax
80100e8c:	0f 84 87 02 00 00    	je     80101119 <consoleintr+0x56b>
        break;
      }
      else if (currentHistoryPos) {
80100e92:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100e97:	85 c0                	test   %eax,%eax
80100e99:	0f 84 7d 02 00 00    	je     8010111c <consoleintr+0x56e>
  currentHistoryPos = currentHistoryPos - 1;
80100e9f:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100ea4:	83 e8 01             	sub    $0x1,%eax
80100ea7:	a3 a8 c5 10 80       	mov    %eax,0x8010c5a8
        DeleteCurrentUnfinishedCommand();
80100eac:	e8 6f fc ff ff       	call   80100b20 <DeleteCurrentUnfinishedCommand>
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
80100eb1:	8b 15 a0 c5 10 80    	mov    0x8010c5a0,%edx
80100eb7:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100ebc:	89 d3                	mov    %edx,%ebx
80100ebe:	29 c3                	sub    %eax,%ebx
80100ec0:	89 d8                	mov    %ebx,%eax
80100ec2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100ec9:	00 
80100eca:	89 04 24             	mov    %eax,(%esp)
80100ecd:	e8 fb f6 ff ff       	call   801005cd <modThatDealsWithNegatives>
80100ed2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
80100ed5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80100edc:	eb 43                	jmp    80100f21 <consoleintr+0x373>
    c = historyArray[tmpIndex][j];
80100ede:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee1:	c1 e0 07             	shl    $0x7,%eax
80100ee4:	03 45 e8             	add    -0x18(%ebp),%eax
80100ee7:	05 40 18 11 80       	add    $0x80111840,%eax
80100eec:	0f b6 00             	movzbl (%eax),%eax
80100eef:	0f be c0             	movsbl %al,%eax
80100ef2:	89 45 d8             	mov    %eax,-0x28(%ebp)
          input.buf[input.w++ % INPUT_BUF] = c;
80100ef5:	a1 38 18 11 80       	mov    0x80111838,%eax
80100efa:	89 c1                	mov    %eax,%ecx
80100efc:	83 e1 7f             	and    $0x7f,%ecx
80100eff:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f02:	88 91 b4 17 11 80    	mov    %dl,-0x7feee84c(%ecx)
80100f08:	83 c0 01             	add    $0x1,%eax
80100f0b:	a3 38 18 11 80       	mov    %eax,0x80111838
    input.e++;
80100f10:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100f15:	83 c0 01             	add    $0x1,%eax
80100f18:	a3 3c 18 11 80       	mov    %eax,0x8011183c
      else if (currentHistoryPos) {
  currentHistoryPos = currentHistoryPos - 1;
        DeleteCurrentUnfinishedCommand();
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
80100f1d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	c1 e0 07             	shl    $0x7,%eax
80100f27:	05 40 18 11 80       	add    $0x80111840,%eax
80100f2c:	89 04 24             	mov    %eax,(%esp)
80100f2f:	e8 fc 4f 00 00       	call   80105f30 <strlen>
80100f34:	83 e8 01             	sub    $0x1,%eax
80100f37:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80100f3a:	7f a2                	jg     80100ede <consoleintr+0x330>
    c = historyArray[tmpIndex][j];
          input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
        consputc(KEY_DN);
80100f3c:	c7 04 24 e3 00 00 00 	movl   $0xe3,(%esp)
80100f43:	e8 7a fb ff ff       	call   80100ac2 <consputc>
      }
      break;
80100f48:	e9 cf 01 00 00       	jmp    8010111c <consoleintr+0x56e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100f4d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f51:	0f 84 c8 01 00 00    	je     8010111f <consoleintr+0x571>
80100f57:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100f5d:	a1 34 18 11 80       	mov    0x80111834,%eax
80100f62:	89 d1                	mov    %edx,%ecx
80100f64:	29 c1                	sub    %eax,%ecx
80100f66:	89 c8                	mov    %ecx,%eax
80100f68:	83 f8 7f             	cmp    $0x7f,%eax
80100f6b:	0f 87 ae 01 00 00    	ja     8010111f <consoleintr+0x571>
        c = (c == '\r') ? '\n' : c;
80100f71:	83 7d d8 0d          	cmpl   $0xd,-0x28(%ebp)
80100f75:	74 05                	je     80100f7c <consoleintr+0x3ce>
80100f77:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f7a:	eb 05                	jmp    80100f81 <consoleintr+0x3d3>
80100f7c:	b8 0a 00 00 00       	mov    $0xa,%eax
80100f81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (c != '\n') { // regular write, not execute
80100f84:	83 7d d8 0a          	cmpl   $0xa,-0x28(%ebp)
80100f88:	0f 84 81 00 00 00    	je     8010100f <consoleintr+0x461>
    int forwardPos = input.e;
80100f8e:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100f93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int j;
    for (j = 0 ; j<input.e-input.w ; j++){
80100f96:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80100f9d:	eb 2d                	jmp    80100fcc <consoleintr+0x41e>
      input.buf[forwardPos % INPUT_BUF] = input.buf[forwardPos-1 % INPUT_BUF];
80100f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa2:	89 c2                	mov    %eax,%edx
80100fa4:	c1 fa 1f             	sar    $0x1f,%edx
80100fa7:	c1 ea 19             	shr    $0x19,%edx
80100faa:	01 d0                	add    %edx,%eax
80100fac:	83 e0 7f             	and    $0x7f,%eax
80100faf:	29 d0                	sub    %edx,%eax
80100fb1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80100fb4:	83 ea 01             	sub    $0x1,%edx
80100fb7:	0f b6 92 b4 17 11 80 	movzbl -0x7feee84c(%edx),%edx
80100fbe:	88 90 b4 17 11 80    	mov    %dl,-0x7feee84c(%eax)
      forwardPos--;
80100fc4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
  if (c != '\n') { // regular write, not execute
    int forwardPos = input.e;
    int j;
    for (j = 0 ; j<input.e-input.w ; j++){
80100fc8:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80100fcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fcf:	8b 0d 3c 18 11 80    	mov    0x8011183c,%ecx
80100fd5:	8b 15 38 18 11 80    	mov    0x80111838,%edx
80100fdb:	89 cb                	mov    %ecx,%ebx
80100fdd:	29 d3                	sub    %edx,%ebx
80100fdf:	89 da                	mov    %ebx,%edx
80100fe1:	39 d0                	cmp    %edx,%eax
80100fe3:	72 ba                	jb     80100f9f <consoleintr+0x3f1>
      input.buf[forwardPos % INPUT_BUF] = input.buf[forwardPos-1 % INPUT_BUF];
      forwardPos--;
    }
    input.buf[input.w++ % INPUT_BUF] = c;
80100fe5:	a1 38 18 11 80       	mov    0x80111838,%eax
80100fea:	89 c1                	mov    %eax,%ecx
80100fec:	83 e1 7f             	and    $0x7f,%ecx
80100fef:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100ff2:	88 91 b4 17 11 80    	mov    %dl,-0x7feee84c(%ecx)
80100ff8:	83 c0 01             	add    $0x1,%eax
80100ffb:	a3 38 18 11 80       	mov    %eax,0x80111838
    input.e++;
80101000:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80101005:	83 c0 01             	add    $0x1,%eax
80101008:	a3 3c 18 11 80       	mov    %eax,0x8011183c
8010100d:	eb 1b                	jmp    8010102a <consoleintr+0x47c>
  }
  else {
    input.buf[input.e++ % INPUT_BUF] = c;
8010100f:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80101014:	89 c1                	mov    %eax,%ecx
80101016:	83 e1 7f             	and    $0x7f,%ecx
80101019:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010101c:	88 91 b4 17 11 80    	mov    %dl,-0x7feee84c(%ecx)
80101022:	83 c0 01             	add    $0x1,%eax
80101025:	a3 3c 18 11 80       	mov    %eax,0x8011183c
  }
        consputc(c);
8010102a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010102d:	89 04 24             	mov    %eax,(%esp)
80101030:	e8 8d fa ff ff       	call   80100ac2 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80101035:	83 7d d8 0a          	cmpl   $0xa,-0x28(%ebp)
80101039:	74 1c                	je     80101057 <consoleintr+0x4a9>
8010103b:	83 7d d8 04          	cmpl   $0x4,-0x28(%ebp)
8010103f:	74 16                	je     80101057 <consoleintr+0x4a9>
80101041:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80101046:	8b 15 34 18 11 80    	mov    0x80111834,%edx
8010104c:	83 ea 80             	sub    $0xffffff80,%edx
8010104f:	39 d0                	cmp    %edx,%eax
80101051:	0f 85 c8 00 00 00    	jne    8010111f <consoleintr+0x571>
    currentHistoryPos=0;
80101057:	c7 05 a8 c5 10 80 00 	movl   $0x0,0x8010c5a8
8010105e:	00 00 00 
          int tmpHistoryIndex;
    for (tmpHistoryIndex = 0 ; tmpHistoryIndex < input.e-input.r ; tmpHistoryIndex++){ // copy the command from the buffer to the historyArray at current position
80101061:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80101068:	eb 3b                	jmp    801010a5 <consoleintr+0x4f7>
      historyArray[commandExecuted][tmpHistoryIndex] = input.buf[input.r+tmpHistoryIndex % INPUT_BUF]; // copy chars from buffer to array
8010106a:	8b 0d a0 c5 10 80    	mov    0x8010c5a0,%ecx
80101070:	8b 1d 34 18 11 80    	mov    0x80111834,%ebx
80101076:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101079:	89 c2                	mov    %eax,%edx
8010107b:	c1 fa 1f             	sar    $0x1f,%edx
8010107e:	c1 ea 19             	shr    $0x19,%edx
80101081:	01 d0                	add    %edx,%eax
80101083:	83 e0 7f             	and    $0x7f,%eax
80101086:	29 d0                	sub    %edx,%eax
80101088:	01 d8                	add    %ebx,%eax
8010108a:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
80101091:	89 ca                	mov    %ecx,%edx
80101093:	c1 e2 07             	shl    $0x7,%edx
80101096:	03 55 dc             	add    -0x24(%ebp),%edx
80101099:	81 c2 40 18 11 80    	add    $0x80111840,%edx
8010109f:	88 02                	mov    %al,(%edx)
  }
        consputc(c);
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
    currentHistoryPos=0;
          int tmpHistoryIndex;
    for (tmpHistoryIndex = 0 ; tmpHistoryIndex < input.e-input.r ; tmpHistoryIndex++){ // copy the command from the buffer to the historyArray at current position
801010a1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801010a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010a8:	8b 0d 3c 18 11 80    	mov    0x8011183c,%ecx
801010ae:	8b 15 34 18 11 80    	mov    0x80111834,%edx
801010b4:	89 cb                	mov    %ecx,%ebx
801010b6:	29 d3                	sub    %edx,%ebx
801010b8:	89 da                	mov    %ebx,%edx
801010ba:	39 d0                	cmp    %edx,%eax
801010bc:	72 ac                	jb     8010106a <consoleintr+0x4bc>
      historyArray[commandExecuted][tmpHistoryIndex] = input.buf[input.r+tmpHistoryIndex % INPUT_BUF]; // copy chars from buffer to array
    }

          if (commandExecuted == MAX_HISTORY-1)
801010be:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
801010c3:	83 f8 0f             	cmp    $0xf,%eax
801010c6:	75 0a                	jne    801010d2 <consoleintr+0x524>
            historyArrayIsFull = 1;
801010c8:	c7 05 a4 c5 10 80 01 	movl   $0x1,0x8010c5a4
801010cf:	00 00 00 
    commandExecuted = (commandExecuted+1) % MAX_HISTORY;
801010d2:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
801010d7:	8d 50 01             	lea    0x1(%eax),%edx
801010da:	89 d0                	mov    %edx,%eax
801010dc:	c1 f8 1f             	sar    $0x1f,%eax
801010df:	c1 e8 1c             	shr    $0x1c,%eax
801010e2:	01 c2                	add    %eax,%edx
801010e4:	83 e2 0f             	and    $0xf,%edx
801010e7:	89 d1                	mov    %edx,%ecx
801010e9:	29 c1                	sub    %eax,%ecx
801010eb:	89 c8                	mov    %ecx,%eax
801010ed:	a3 a0 c5 10 80       	mov    %eax,0x8010c5a0

          input.w = input.e;
801010f2:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801010f7:	a3 38 18 11 80       	mov    %eax,0x80111838
          wakeup(&input.r);
801010fc:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
80101103:	e8 45 46 00 00       	call   8010574d <wakeup>
        }
      }
      break;
80101108:	eb 15                	jmp    8010111f <consoleintr+0x571>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010110a:	90                   	nop
8010110b:	eb 13                	jmp    80101120 <consoleintr+0x572>
  }
  input.e--;
  input.w--;
        consputc(BACKSPACE);
      }
      break;
8010110d:	90                   	nop
8010110e:	eb 10                	jmp    80101120 <consoleintr+0x572>
    case KEY_LF:
      if(input.r < input.w) {
        input.w--;
        consputc(KEY_LF);
      }
      break;
80101110:	90                   	nop
80101111:	eb 0d                	jmp    80101120 <consoleintr+0x572>
    case KEY_RT:
      if(input.w < input.e) {
        input.w++;
        consputc(KEY_RT);
      }
      break;
80101113:	90                   	nop
80101114:	eb 0a                	jmp    80101120 <consoleintr+0x572>
          input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
        consputc(KEY_UP);
      }
      break;
80101116:	90                   	nop
80101117:	eb 07                	jmp    80101120 <consoleintr+0x572>
    case KEY_DN:
      if (commandExecuted == 0 && historyArrayIsFull == 0) {
        break;
      }
      else if (currentHistoryPos==0 ) {
        break;
80101119:	90                   	nop
8010111a:	eb 04                	jmp    80101120 <consoleintr+0x572>
          input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
        consputc(KEY_DN);
      }
      break;
8010111c:	90                   	nop
8010111d:	eb 01                	jmp    80101120 <consoleintr+0x572>

          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
8010111f:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80101120:	8b 45 08             	mov    0x8(%ebp),%eax
80101123:	ff d0                	call   *%eax
80101125:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101128:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010112c:	0f 89 94 fa ff ff    	jns    80100bc6 <consoleintr+0x18>
        }
      }
      break;
    }
  }
  release(&input.lock);
80101132:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80101139:	e8 87 49 00 00       	call   80105ac5 <release>
}
8010113e:	83 c4 44             	add    $0x44,%esp
80101141:	5b                   	pop    %ebx
80101142:	5d                   	pop    %ebp
80101143:	c3                   	ret    

80101144 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80101144:	55                   	push   %ebp
80101145:	89 e5                	mov    %esp,%ebp
80101147:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010114a:	8b 45 08             	mov    0x8(%ebp),%eax
8010114d:	89 04 24             	mov    %eax,(%esp)
80101150:	e8 f4 10 00 00       	call   80102249 <iunlock>
  target = n;
80101155:	8b 45 10             	mov    0x10(%ebp),%eax
80101158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010115b:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80101162:	e8 fc 48 00 00       	call   80105a63 <acquire>
  while(n > 0){
80101167:	e9 a8 00 00 00       	jmp    80101214 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010116c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101172:	8b 40 24             	mov    0x24(%eax),%eax
80101175:	85 c0                	test   %eax,%eax
80101177:	74 21                	je     8010119a <consoleread+0x56>
        release(&input.lock);
80101179:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80101180:	e8 40 49 00 00       	call   80105ac5 <release>
        ilock(ip);
80101185:	8b 45 08             	mov    0x8(%ebp),%eax
80101188:	89 04 24             	mov    %eax,(%esp)
8010118b:	e8 65 0f 00 00       	call   801020f5 <ilock>
        return -1;
80101190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101195:	e9 a9 00 00 00       	jmp    80101243 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010119a:	c7 44 24 04 80 17 11 	movl   $0x80111780,0x4(%esp)
801011a1:	80 
801011a2:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
801011a9:	e8 c3 44 00 00       	call   80105671 <sleep>
801011ae:	eb 01                	jmp    801011b1 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801011b0:	90                   	nop
801011b1:	8b 15 34 18 11 80    	mov    0x80111834,%edx
801011b7:	a1 38 18 11 80       	mov    0x80111838,%eax
801011bc:	39 c2                	cmp    %eax,%edx
801011be:	74 ac                	je     8010116c <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801011c0:	a1 34 18 11 80       	mov    0x80111834,%eax
801011c5:	89 c2                	mov    %eax,%edx
801011c7:	83 e2 7f             	and    $0x7f,%edx
801011ca:	0f b6 92 b4 17 11 80 	movzbl -0x7feee84c(%edx),%edx
801011d1:	0f be d2             	movsbl %dl,%edx
801011d4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011d7:	83 c0 01             	add    $0x1,%eax
801011da:	a3 34 18 11 80       	mov    %eax,0x80111834
    if(c == C('D')){  // EOF
801011df:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801011e3:	75 17                	jne    801011fc <consoleread+0xb8>
      if(n < target){
801011e5:	8b 45 10             	mov    0x10(%ebp),%eax
801011e8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801011eb:	73 2f                	jae    8010121c <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801011ed:	a1 34 18 11 80       	mov    0x80111834,%eax
801011f2:	83 e8 01             	sub    $0x1,%eax
801011f5:	a3 34 18 11 80       	mov    %eax,0x80111834
      }
      break;
801011fa:	eb 20                	jmp    8010121c <consoleread+0xd8>
    }
    *dst++ = c;
801011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011ff:	89 c2                	mov    %eax,%edx
80101201:	8b 45 0c             	mov    0xc(%ebp),%eax
80101204:	88 10                	mov    %dl,(%eax)
80101206:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
8010120a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
8010120e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80101212:	74 0b                	je     8010121f <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80101214:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101218:	7f 96                	jg     801011b0 <consoleread+0x6c>
8010121a:	eb 04                	jmp    80101220 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
8010121c:	90                   	nop
8010121d:	eb 01                	jmp    80101220 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
8010121f:	90                   	nop
  }
  release(&input.lock);
80101220:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80101227:	e8 99 48 00 00       	call   80105ac5 <release>
  ilock(ip);
8010122c:	8b 45 08             	mov    0x8(%ebp),%eax
8010122f:	89 04 24             	mov    %eax,(%esp)
80101232:	e8 be 0e 00 00       	call   801020f5 <ilock>

  return target - n;
80101237:	8b 45 10             	mov    0x10(%ebp),%eax
8010123a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010123d:	89 d1                	mov    %edx,%ecx
8010123f:	29 c1                	sub    %eax,%ecx
80101241:	89 c8                	mov    %ecx,%eax
}
80101243:	c9                   	leave  
80101244:	c3                   	ret    

80101245 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80101245:	55                   	push   %ebp
80101246:	89 e5                	mov    %esp,%ebp
80101248:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
8010124b:	8b 45 08             	mov    0x8(%ebp),%eax
8010124e:	89 04 24             	mov    %eax,(%esp)
80101251:	e8 f3 0f 00 00       	call   80102249 <iunlock>
  acquire(&cons.lock);
80101256:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
8010125d:	e8 01 48 00 00       	call   80105a63 <acquire>
  for(i = 0; i < n; i++)
80101262:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101269:	eb 1d                	jmp    80101288 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	03 45 0c             	add    0xc(%ebp),%eax
80101271:	0f b6 00             	movzbl (%eax),%eax
80101274:	0f be c0             	movsbl %al,%eax
80101277:	25 ff 00 00 00       	and    $0xff,%eax
8010127c:	89 04 24             	mov    %eax,(%esp)
8010127f:	e8 3e f8 ff ff       	call   80100ac2 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80101284:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010128e:	7c db                	jl     8010126b <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80101290:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80101297:	e8 29 48 00 00       	call   80105ac5 <release>
  ilock(ip);
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 4e 0e 00 00       	call   801020f5 <ilock>

  return n;
801012a7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801012aa:	c9                   	leave  
801012ab:	c3                   	ret    

801012ac <consoleinit>:

void
consoleinit(void)
{
801012ac:	55                   	push   %ebp
801012ad:	89 e5                	mov    %esp,%ebp
801012af:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
801012b2:	c7 44 24 04 73 91 10 	movl   $0x80109173,0x4(%esp)
801012b9:	80 
801012ba:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801012c1:	e8 7c 47 00 00       	call   80105a42 <initlock>
  initlock(&input.lock, "input");
801012c6:	c7 44 24 04 7b 91 10 	movl   $0x8010917b,0x4(%esp)
801012cd:	80 
801012ce:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
801012d5:	e8 68 47 00 00       	call   80105a42 <initlock>

  devsw[CONSOLE].write = consolewrite;
801012da:	c7 05 ec 29 11 80 45 	movl   $0x80101245,0x801129ec
801012e1:	12 10 80 
  devsw[CONSOLE].read = consoleread;
801012e4:	c7 05 e8 29 11 80 44 	movl   $0x80101144,0x801129e8
801012eb:	11 10 80 
  cons.locking = 1;
801012ee:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
801012f5:	00 00 00 

  picenable(IRQ_KBD);
801012f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801012ff:	e8 c1 33 00 00       	call   801046c5 <picenable>
  ioapicenable(IRQ_KBD, 0);
80101304:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010130b:	00 
8010130c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80101313:	e8 26 1f 00 00       	call   8010323e <ioapicenable>
}
80101318:	c9                   	leave  
80101319:	c3                   	ret    
	...

8010131c <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
8010131c:	55                   	push   %ebp
8010131d:	89 e5                	mov    %esp,%ebp
8010131f:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80101325:	e8 e7 29 00 00       	call   80103d11 <begin_op>
  if((ip = namei(path)) == 0){
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 68 19 00 00       	call   80102c9d <namei>
80101335:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101338:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010133c:	75 0f                	jne    8010134d <exec+0x31>
    end_op();
8010133e:	e8 4f 2a 00 00       	call   80103d92 <end_op>
    return -1;
80101343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101348:	e9 dd 03 00 00       	jmp    8010172a <exec+0x40e>
  }
  ilock(ip);
8010134d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101350:	89 04 24             	mov    %eax,(%esp)
80101353:	e8 9d 0d 00 00       	call   801020f5 <ilock>
  pgdir = 0;
80101358:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
8010135f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80101366:	00 
80101367:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010136e:	00 
8010136f:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80101375:	89 44 24 04          	mov    %eax,0x4(%esp)
80101379:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010137c:	89 04 24             	mov    %eax,(%esp)
8010137f:	e8 6d 12 00 00       	call   801025f1 <readi>
80101384:	83 f8 33             	cmp    $0x33,%eax
80101387:	0f 86 52 03 00 00    	jbe    801016df <exec+0x3c3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
8010138d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80101393:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80101398:	0f 85 44 03 00 00    	jne    801016e2 <exec+0x3c6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
8010139e:	e8 1a 75 00 00       	call   801088bd <setupkvm>
801013a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801013a6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801013aa:	0f 84 35 03 00 00    	je     801016e5 <exec+0x3c9>
    goto bad;

  // Load program into memory.
  sz = 0;
801013b0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801013b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801013be:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
801013c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013c7:	e9 c5 00 00 00       	jmp    80101491 <exec+0x175>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801013cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013cf:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
801013d6:	00 
801013d7:	89 44 24 08          	mov    %eax,0x8(%esp)
801013db:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
801013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801013e8:	89 04 24             	mov    %eax,(%esp)
801013eb:	e8 01 12 00 00       	call   801025f1 <readi>
801013f0:	83 f8 20             	cmp    $0x20,%eax
801013f3:	0f 85 ef 02 00 00    	jne    801016e8 <exec+0x3cc>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
801013f9:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
801013ff:	83 f8 01             	cmp    $0x1,%eax
80101402:	75 7f                	jne    80101483 <exec+0x167>
      continue;
    if(ph.memsz < ph.filesz)
80101404:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
8010140a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80101410:	39 c2                	cmp    %eax,%edx
80101412:	0f 82 d3 02 00 00    	jb     801016eb <exec+0x3cf>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80101418:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
8010141e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80101424:	01 d0                	add    %edx,%eax
80101426:	89 44 24 08          	mov    %eax,0x8(%esp)
8010142a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010142d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101431:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101434:	89 04 24             	mov    %eax,(%esp)
80101437:	e8 53 78 00 00       	call   80108c8f <allocuvm>
8010143c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010143f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101443:	0f 84 a5 02 00 00    	je     801016ee <exec+0x3d2>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80101449:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
8010144f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80101455:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
8010145b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010145f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101463:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101466:	89 54 24 08          	mov    %edx,0x8(%esp)
8010146a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010146e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101471:	89 04 24             	mov    %eax,(%esp)
80101474:	e8 27 77 00 00       	call   80108ba0 <loaduvm>
80101479:	85 c0                	test   %eax,%eax
8010147b:	0f 88 70 02 00 00    	js     801016f1 <exec+0x3d5>
80101481:	eb 01                	jmp    80101484 <exec+0x168>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80101483:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80101484:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80101488:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010148b:	83 c0 20             	add    $0x20,%eax
8010148e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101491:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80101498:	0f b7 c0             	movzwl %ax,%eax
8010149b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010149e:	0f 8f 28 ff ff ff    	jg     801013cc <exec+0xb0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
801014a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a7:	89 04 24             	mov    %eax,(%esp)
801014aa:	e8 d0 0e 00 00       	call   8010237f <iunlockput>
  end_op();
801014af:	e8 de 28 00 00       	call   80103d92 <end_op>
  ip = 0;
801014b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
801014bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014be:	05 ff 0f 00 00       	add    $0xfff,%eax
801014c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801014c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
801014cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014ce:	05 00 20 00 00       	add    $0x2000,%eax
801014d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801014d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014da:	89 44 24 04          	mov    %eax,0x4(%esp)
801014de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801014e1:	89 04 24             	mov    %eax,(%esp)
801014e4:	e8 a6 77 00 00       	call   80108c8f <allocuvm>
801014e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801014ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801014f0:	0f 84 fe 01 00 00    	je     801016f4 <exec+0x3d8>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
801014f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014f9:	2d 00 20 00 00       	sub    $0x2000,%eax
801014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80101502:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101505:	89 04 24             	mov    %eax,(%esp)
80101508:	e8 a6 79 00 00       	call   80108eb3 <clearpteu>
  sp = sz;
8010150d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101510:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101513:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010151a:	e9 81 00 00 00       	jmp    801015a0 <exec+0x284>
    if(argc >= MAXARG)
8010151f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101523:	0f 87 ce 01 00 00    	ja     801016f7 <exec+0x3db>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010152c:	c1 e0 02             	shl    $0x2,%eax
8010152f:	03 45 0c             	add    0xc(%ebp),%eax
80101532:	8b 00                	mov    (%eax),%eax
80101534:	89 04 24             	mov    %eax,(%esp)
80101537:	e8 f4 49 00 00       	call   80105f30 <strlen>
8010153c:	f7 d0                	not    %eax
8010153e:	03 45 dc             	add    -0x24(%ebp),%eax
80101541:	83 e0 fc             	and    $0xfffffffc,%eax
80101544:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010154a:	c1 e0 02             	shl    $0x2,%eax
8010154d:	03 45 0c             	add    0xc(%ebp),%eax
80101550:	8b 00                	mov    (%eax),%eax
80101552:	89 04 24             	mov    %eax,(%esp)
80101555:	e8 d6 49 00 00       	call   80105f30 <strlen>
8010155a:	83 c0 01             	add    $0x1,%eax
8010155d:	89 c2                	mov    %eax,%edx
8010155f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101562:	c1 e0 02             	shl    $0x2,%eax
80101565:	03 45 0c             	add    0xc(%ebp),%eax
80101568:	8b 00                	mov    (%eax),%eax
8010156a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010156e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101572:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101575:	89 44 24 04          	mov    %eax,0x4(%esp)
80101579:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010157c:	89 04 24             	mov    %eax,(%esp)
8010157f:	e8 f4 7a 00 00       	call   80109078 <copyout>
80101584:	85 c0                	test   %eax,%eax
80101586:	0f 88 6e 01 00 00    	js     801016fa <exec+0x3de>
      goto bad;
    ustack[3+argc] = sp;
8010158c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010158f:	8d 50 03             	lea    0x3(%eax),%edx
80101592:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101595:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010159c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801015a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015a3:	c1 e0 02             	shl    $0x2,%eax
801015a6:	03 45 0c             	add    0xc(%ebp),%eax
801015a9:	8b 00                	mov    (%eax),%eax
801015ab:	85 c0                	test   %eax,%eax
801015ad:	0f 85 6c ff ff ff    	jne    8010151f <exec+0x203>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801015b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015b6:	83 c0 03             	add    $0x3,%eax
801015b9:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
801015c0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801015c4:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801015cb:	ff ff ff 
  ustack[1] = argc;
801015ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015d1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
801015d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015da:	83 c0 01             	add    $0x1,%eax
801015dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801015e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801015e7:	29 d0                	sub    %edx,%eax
801015e9:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
801015ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015f2:	83 c0 04             	add    $0x4,%eax
801015f5:	c1 e0 02             	shl    $0x2,%eax
801015f8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
801015fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015fe:	83 c0 04             	add    $0x4,%eax
80101601:	c1 e0 02             	shl    $0x2,%eax
80101604:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101608:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010160e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101612:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101615:	89 44 24 04          	mov    %eax,0x4(%esp)
80101619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010161c:	89 04 24             	mov    %eax,(%esp)
8010161f:	e8 54 7a 00 00       	call   80109078 <copyout>
80101624:	85 c0                	test   %eax,%eax
80101626:	0f 88 d1 00 00 00    	js     801016fd <exec+0x3e1>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010162c:	8b 45 08             	mov    0x8(%ebp),%eax
8010162f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101635:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101638:	eb 17                	jmp    80101651 <exec+0x335>
    if(*s == '/')
8010163a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010163d:	0f b6 00             	movzbl (%eax),%eax
80101640:	3c 2f                	cmp    $0x2f,%al
80101642:	75 09                	jne    8010164d <exec+0x331>
      last = s+1;
80101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101647:	83 c0 01             	add    $0x1,%eax
8010164a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010164d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101654:	0f b6 00             	movzbl (%eax),%eax
80101657:	84 c0                	test   %al,%al
80101659:	75 df                	jne    8010163a <exec+0x31e>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010165b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101661:	8d 50 6c             	lea    0x6c(%eax),%edx
80101664:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010166b:	00 
8010166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010166f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101673:	89 14 24             	mov    %edx,(%esp)
80101676:	e8 67 48 00 00       	call   80105ee2 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
8010167b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101681:	8b 40 04             	mov    0x4(%eax),%eax
80101684:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80101687:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010168d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101690:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80101693:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101699:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010169c:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
8010169e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801016a4:	8b 40 18             	mov    0x18(%eax),%eax
801016a7:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801016ad:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801016b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801016b6:	8b 40 18             	mov    0x18(%eax),%eax
801016b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801016bc:	89 50 44             	mov    %edx,0x44(%eax)
  #if SCHEDFLAG == DML
  proc->priority=DEF_PRIORITY;
  #endif
  switchuvm(proc);
801016bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801016c5:	89 04 24             	mov    %eax,(%esp)
801016c8:	e8 e1 72 00 00       	call   801089ae <switchuvm>
  freevm(oldpgdir);
801016cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801016d0:	89 04 24             	mov    %eax,(%esp)
801016d3:	e8 4d 77 00 00       	call   80108e25 <freevm>
  return 0;
801016d8:	b8 00 00 00 00       	mov    $0x0,%eax
801016dd:	eb 4b                	jmp    8010172a <exec+0x40e>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
801016df:	90                   	nop
801016e0:	eb 1c                	jmp    801016fe <exec+0x3e2>
  if(elf.magic != ELF_MAGIC)
    goto bad;
801016e2:	90                   	nop
801016e3:	eb 19                	jmp    801016fe <exec+0x3e2>

  if((pgdir = setupkvm()) == 0)
    goto bad;
801016e5:	90                   	nop
801016e6:	eb 16                	jmp    801016fe <exec+0x3e2>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
801016e8:	90                   	nop
801016e9:	eb 13                	jmp    801016fe <exec+0x3e2>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
801016eb:	90                   	nop
801016ec:	eb 10                	jmp    801016fe <exec+0x3e2>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801016ee:	90                   	nop
801016ef:	eb 0d                	jmp    801016fe <exec+0x3e2>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
801016f1:	90                   	nop
801016f2:	eb 0a                	jmp    801016fe <exec+0x3e2>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
801016f4:	90                   	nop
801016f5:	eb 07                	jmp    801016fe <exec+0x3e2>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801016f7:	90                   	nop
801016f8:	eb 04                	jmp    801016fe <exec+0x3e2>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801016fa:	90                   	nop
801016fb:	eb 01                	jmp    801016fe <exec+0x3e2>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801016fd:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
801016fe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101702:	74 0b                	je     8010170f <exec+0x3f3>
    freevm(pgdir);
80101704:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101707:	89 04 24             	mov    %eax,(%esp)
8010170a:	e8 16 77 00 00       	call   80108e25 <freevm>
  if(ip){
8010170f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101713:	74 10                	je     80101725 <exec+0x409>
    iunlockput(ip);
80101715:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101718:	89 04 24             	mov    %eax,(%esp)
8010171b:	e8 5f 0c 00 00       	call   8010237f <iunlockput>
    end_op();
80101720:	e8 6d 26 00 00       	call   80103d92 <end_op>
  }
  return -1;
80101725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010172a:	c9                   	leave  
8010172b:	c3                   	ret    

8010172c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010172c:	55                   	push   %ebp
8010172d:	89 e5                	mov    %esp,%ebp
8010172f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80101732:	c7 44 24 04 81 91 10 	movl   $0x80109181,0x4(%esp)
80101739:	80 
8010173a:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101741:	e8 fc 42 00 00       	call   80105a42 <initlock>
}
80101746:	c9                   	leave  
80101747:	c3                   	ret    

80101748 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101748:	55                   	push   %ebp
80101749:	89 e5                	mov    %esp,%ebp
8010174b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010174e:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101755:	e8 09 43 00 00       	call   80105a63 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010175a:	c7 45 f4 74 20 11 80 	movl   $0x80112074,-0xc(%ebp)
80101761:	eb 29                	jmp    8010178c <filealloc+0x44>
    if(f->ref == 0){
80101763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101766:	8b 40 04             	mov    0x4(%eax),%eax
80101769:	85 c0                	test   %eax,%eax
8010176b:	75 1b                	jne    80101788 <filealloc+0x40>
      f->ref = 1;
8010176d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101770:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101777:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
8010177e:	e8 42 43 00 00       	call   80105ac5 <release>
      return f;
80101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101786:	eb 1e                	jmp    801017a6 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101788:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010178c:	81 7d f4 d4 29 11 80 	cmpl   $0x801129d4,-0xc(%ebp)
80101793:	72 ce                	jb     80101763 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101795:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
8010179c:	e8 24 43 00 00       	call   80105ac5 <release>
  return 0;
801017a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801017a6:	c9                   	leave  
801017a7:	c3                   	ret    

801017a8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801017a8:	55                   	push   %ebp
801017a9:	89 e5                	mov    %esp,%ebp
801017ab:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801017ae:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801017b5:	e8 a9 42 00 00       	call   80105a63 <acquire>
  if(f->ref < 1)
801017ba:	8b 45 08             	mov    0x8(%ebp),%eax
801017bd:	8b 40 04             	mov    0x4(%eax),%eax
801017c0:	85 c0                	test   %eax,%eax
801017c2:	7f 0c                	jg     801017d0 <filedup+0x28>
    panic("filedup");
801017c4:	c7 04 24 88 91 10 80 	movl   $0x80109188,(%esp)
801017cb:	e8 6d ed ff ff       	call   8010053d <panic>
  f->ref++;
801017d0:	8b 45 08             	mov    0x8(%ebp),%eax
801017d3:	8b 40 04             	mov    0x4(%eax),%eax
801017d6:	8d 50 01             	lea    0x1(%eax),%edx
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801017df:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801017e6:	e8 da 42 00 00       	call   80105ac5 <release>
  return f;
801017eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801017ee:	c9                   	leave  
801017ef:	c3                   	ret    

801017f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801017f0:	55                   	push   %ebp
801017f1:	89 e5                	mov    %esp,%ebp
801017f3:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801017f6:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801017fd:	e8 61 42 00 00       	call   80105a63 <acquire>
  if(f->ref < 1)
80101802:	8b 45 08             	mov    0x8(%ebp),%eax
80101805:	8b 40 04             	mov    0x4(%eax),%eax
80101808:	85 c0                	test   %eax,%eax
8010180a:	7f 0c                	jg     80101818 <fileclose+0x28>
    panic("fileclose");
8010180c:	c7 04 24 90 91 10 80 	movl   $0x80109190,(%esp)
80101813:	e8 25 ed ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101818:	8b 45 08             	mov    0x8(%ebp),%eax
8010181b:	8b 40 04             	mov    0x4(%eax),%eax
8010181e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101821:	8b 45 08             	mov    0x8(%ebp),%eax
80101824:	89 50 04             	mov    %edx,0x4(%eax)
80101827:	8b 45 08             	mov    0x8(%ebp),%eax
8010182a:	8b 40 04             	mov    0x4(%eax),%eax
8010182d:	85 c0                	test   %eax,%eax
8010182f:	7e 11                	jle    80101842 <fileclose+0x52>
    release(&ftable.lock);
80101831:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101838:	e8 88 42 00 00       	call   80105ac5 <release>
    return;
8010183d:	e9 82 00 00 00       	jmp    801018c4 <fileclose+0xd4>
  }
  ff = *f;
80101842:	8b 45 08             	mov    0x8(%ebp),%eax
80101845:	8b 10                	mov    (%eax),%edx
80101847:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010184a:	8b 50 04             	mov    0x4(%eax),%edx
8010184d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101850:	8b 50 08             	mov    0x8(%eax),%edx
80101853:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101856:	8b 50 0c             	mov    0xc(%eax),%edx
80101859:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010185c:	8b 50 10             	mov    0x10(%eax),%edx
8010185f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101862:	8b 40 14             	mov    0x14(%eax),%eax
80101865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101868:	8b 45 08             	mov    0x8(%ebp),%eax
8010186b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101872:	8b 45 08             	mov    0x8(%ebp),%eax
80101875:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010187b:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101882:	e8 3e 42 00 00       	call   80105ac5 <release>
  
  if(ff.type == FD_PIPE)
80101887:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010188a:	83 f8 01             	cmp    $0x1,%eax
8010188d:	75 18                	jne    801018a7 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010188f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101893:	0f be d0             	movsbl %al,%edx
80101896:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101899:	89 54 24 04          	mov    %edx,0x4(%esp)
8010189d:	89 04 24             	mov    %eax,(%esp)
801018a0:	e8 da 30 00 00       	call   8010497f <pipeclose>
801018a5:	eb 1d                	jmp    801018c4 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801018a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801018aa:	83 f8 02             	cmp    $0x2,%eax
801018ad:	75 15                	jne    801018c4 <fileclose+0xd4>
    begin_op();
801018af:	e8 5d 24 00 00       	call   80103d11 <begin_op>
    iput(ff.ip);
801018b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b7:	89 04 24             	mov    %eax,(%esp)
801018ba:	e8 ef 09 00 00       	call   801022ae <iput>
    end_op();
801018bf:	e8 ce 24 00 00       	call   80103d92 <end_op>
  }
}
801018c4:	c9                   	leave  
801018c5:	c3                   	ret    

801018c6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801018c6:	55                   	push   %ebp
801018c7:	89 e5                	mov    %esp,%ebp
801018c9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801018cc:	8b 45 08             	mov    0x8(%ebp),%eax
801018cf:	8b 00                	mov    (%eax),%eax
801018d1:	83 f8 02             	cmp    $0x2,%eax
801018d4:	75 38                	jne    8010190e <filestat+0x48>
    ilock(f->ip);
801018d6:	8b 45 08             	mov    0x8(%ebp),%eax
801018d9:	8b 40 10             	mov    0x10(%eax),%eax
801018dc:	89 04 24             	mov    %eax,(%esp)
801018df:	e8 11 08 00 00       	call   801020f5 <ilock>
    stati(f->ip, st);
801018e4:	8b 45 08             	mov    0x8(%ebp),%eax
801018e7:	8b 40 10             	mov    0x10(%eax),%eax
801018ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801018ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801018f1:	89 04 24             	mov    %eax,(%esp)
801018f4:	e8 b3 0c 00 00       	call   801025ac <stati>
    iunlock(f->ip);
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8b 40 10             	mov    0x10(%eax),%eax
801018ff:	89 04 24             	mov    %eax,(%esp)
80101902:	e8 42 09 00 00       	call   80102249 <iunlock>
    return 0;
80101907:	b8 00 00 00 00       	mov    $0x0,%eax
8010190c:	eb 05                	jmp    80101913 <filestat+0x4d>
  }
  return -1;
8010190e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101913:	c9                   	leave  
80101914:	c3                   	ret    

80101915 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101915:	55                   	push   %ebp
80101916:	89 e5                	mov    %esp,%ebp
80101918:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010191b:	8b 45 08             	mov    0x8(%ebp),%eax
8010191e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101922:	84 c0                	test   %al,%al
80101924:	75 0a                	jne    80101930 <fileread+0x1b>
    return -1;
80101926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010192b:	e9 9f 00 00 00       	jmp    801019cf <fileread+0xba>
  if(f->type == FD_PIPE)
80101930:	8b 45 08             	mov    0x8(%ebp),%eax
80101933:	8b 00                	mov    (%eax),%eax
80101935:	83 f8 01             	cmp    $0x1,%eax
80101938:	75 1e                	jne    80101958 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010193a:	8b 45 08             	mov    0x8(%ebp),%eax
8010193d:	8b 40 0c             	mov    0xc(%eax),%eax
80101940:	8b 55 10             	mov    0x10(%ebp),%edx
80101943:	89 54 24 08          	mov    %edx,0x8(%esp)
80101947:	8b 55 0c             	mov    0xc(%ebp),%edx
8010194a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010194e:	89 04 24             	mov    %eax,(%esp)
80101951:	e8 ab 31 00 00       	call   80104b01 <piperead>
80101956:	eb 77                	jmp    801019cf <fileread+0xba>
  if(f->type == FD_INODE){
80101958:	8b 45 08             	mov    0x8(%ebp),%eax
8010195b:	8b 00                	mov    (%eax),%eax
8010195d:	83 f8 02             	cmp    $0x2,%eax
80101960:	75 61                	jne    801019c3 <fileread+0xae>
    ilock(f->ip);
80101962:	8b 45 08             	mov    0x8(%ebp),%eax
80101965:	8b 40 10             	mov    0x10(%eax),%eax
80101968:	89 04 24             	mov    %eax,(%esp)
8010196b:	e8 85 07 00 00       	call   801020f5 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101970:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101973:	8b 45 08             	mov    0x8(%ebp),%eax
80101976:	8b 50 14             	mov    0x14(%eax),%edx
80101979:	8b 45 08             	mov    0x8(%ebp),%eax
8010197c:	8b 40 10             	mov    0x10(%eax),%eax
8010197f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101983:	89 54 24 08          	mov    %edx,0x8(%esp)
80101987:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010198e:	89 04 24             	mov    %eax,(%esp)
80101991:	e8 5b 0c 00 00       	call   801025f1 <readi>
80101996:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101999:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010199d:	7e 11                	jle    801019b0 <fileread+0x9b>
      f->off += r;
8010199f:	8b 45 08             	mov    0x8(%ebp),%eax
801019a2:	8b 50 14             	mov    0x14(%eax),%edx
801019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a8:	01 c2                	add    %eax,%edx
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801019b0:	8b 45 08             	mov    0x8(%ebp),%eax
801019b3:	8b 40 10             	mov    0x10(%eax),%eax
801019b6:	89 04 24             	mov    %eax,(%esp)
801019b9:	e8 8b 08 00 00       	call   80102249 <iunlock>
    return r;
801019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c1:	eb 0c                	jmp    801019cf <fileread+0xba>
  }
  panic("fileread");
801019c3:	c7 04 24 9a 91 10 80 	movl   $0x8010919a,(%esp)
801019ca:	e8 6e eb ff ff       	call   8010053d <panic>
}
801019cf:	c9                   	leave  
801019d0:	c3                   	ret    

801019d1 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801019d1:	55                   	push   %ebp
801019d2:	89 e5                	mov    %esp,%ebp
801019d4:	53                   	push   %ebx
801019d5:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801019df:	84 c0                	test   %al,%al
801019e1:	75 0a                	jne    801019ed <filewrite+0x1c>
    return -1;
801019e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019e8:	e9 23 01 00 00       	jmp    80101b10 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
801019f0:	8b 00                	mov    (%eax),%eax
801019f2:	83 f8 01             	cmp    $0x1,%eax
801019f5:	75 21                	jne    80101a18 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801019f7:	8b 45 08             	mov    0x8(%ebp),%eax
801019fa:	8b 40 0c             	mov    0xc(%eax),%eax
801019fd:	8b 55 10             	mov    0x10(%ebp),%edx
80101a00:	89 54 24 08          	mov    %edx,0x8(%esp)
80101a04:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a07:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a0b:	89 04 24             	mov    %eax,(%esp)
80101a0e:	e8 fe 2f 00 00       	call   80104a11 <pipewrite>
80101a13:	e9 f8 00 00 00       	jmp    80101b10 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101a18:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1b:	8b 00                	mov    (%eax),%eax
80101a1d:	83 f8 02             	cmp    $0x2,%eax
80101a20:	0f 85 de 00 00 00    	jne    80101b04 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101a26:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101a2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101a34:	e9 a8 00 00 00       	jmp    80101ae1 <filewrite+0x110>
      int n1 = n - i;
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3c:	8b 55 10             	mov    0x10(%ebp),%edx
80101a3f:	89 d1                	mov    %edx,%ecx
80101a41:	29 c1                	sub    %eax,%ecx
80101a43:	89 c8                	mov    %ecx,%eax
80101a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101a4e:	7e 06                	jle    80101a56 <filewrite+0x85>
        n1 = max;
80101a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a53:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101a56:	e8 b6 22 00 00       	call   80103d11 <begin_op>
      ilock(f->ip);
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 10             	mov    0x10(%eax),%eax
80101a61:	89 04 24             	mov    %eax,(%esp)
80101a64:	e8 8c 06 00 00       	call   801020f5 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101a69:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	8b 48 14             	mov    0x14(%eax),%ecx
80101a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a75:	89 c2                	mov    %eax,%edx
80101a77:	03 55 0c             	add    0xc(%ebp),%edx
80101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7d:	8b 40 10             	mov    0x10(%eax),%eax
80101a80:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101a84:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101a88:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a8c:	89 04 24             	mov    %eax,(%esp)
80101a8f:	e8 c8 0c 00 00       	call   8010275c <writei>
80101a94:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101a97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101a9b:	7e 11                	jle    80101aae <filewrite+0xdd>
        f->off += r;
80101a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa0:	8b 50 14             	mov    0x14(%eax),%edx
80101aa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101aa6:	01 c2                	add    %eax,%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 10             	mov    0x10(%eax),%eax
80101ab4:	89 04 24             	mov    %eax,(%esp)
80101ab7:	e8 8d 07 00 00       	call   80102249 <iunlock>
      end_op();
80101abc:	e8 d1 22 00 00       	call   80103d92 <end_op>

      if(r < 0)
80101ac1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101ac5:	78 28                	js     80101aef <filewrite+0x11e>
        break;
      if(r != n1)
80101ac7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101aca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101acd:	74 0c                	je     80101adb <filewrite+0x10a>
        panic("short filewrite");
80101acf:	c7 04 24 a3 91 10 80 	movl   $0x801091a3,(%esp)
80101ad6:	e8 62 ea ff ff       	call   8010053d <panic>
      i += r;
80101adb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ade:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ae7:	0f 8c 4c ff ff ff    	jl     80101a39 <filewrite+0x68>
80101aed:	eb 01                	jmp    80101af0 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101aef:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af3:	3b 45 10             	cmp    0x10(%ebp),%eax
80101af6:	75 05                	jne    80101afd <filewrite+0x12c>
80101af8:	8b 45 10             	mov    0x10(%ebp),%eax
80101afb:	eb 05                	jmp    80101b02 <filewrite+0x131>
80101afd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b02:	eb 0c                	jmp    80101b10 <filewrite+0x13f>
  }
  panic("filewrite");
80101b04:	c7 04 24 b3 91 10 80 	movl   $0x801091b3,(%esp)
80101b0b:	e8 2d ea ff ff       	call   8010053d <panic>
}
80101b10:	83 c4 24             	add    $0x24,%esp
80101b13:	5b                   	pop    %ebx
80101b14:	5d                   	pop    %ebp
80101b15:	c3                   	ret    
	...

80101b18 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101b18:	55                   	push   %ebp
80101b19:	89 e5                	mov    %esp,%ebp
80101b1b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101b28:	00 
80101b29:	89 04 24             	mov    %eax,(%esp)
80101b2c:	e8 75 e6 ff ff       	call   801001a6 <bread>
80101b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b37:	83 c0 18             	add    $0x18,%eax
80101b3a:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101b41:	00 
80101b42:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b49:	89 04 24             	mov    %eax,(%esp)
80101b4c:	e8 34 42 00 00       	call   80105d85 <memmove>
  brelse(bp);
80101b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b54:	89 04 24             	mov    %eax,(%esp)
80101b57:	e8 bb e6 ff ff       	call   80100217 <brelse>
}
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101b64:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b67:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b6e:	89 04 24             	mov    %eax,(%esp)
80101b71:	e8 30 e6 ff ff       	call   801001a6 <bread>
80101b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7c:	83 c0 18             	add    $0x18,%eax
80101b7f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101b86:	00 
80101b87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101b8e:	00 
80101b8f:	89 04 24             	mov    %eax,(%esp)
80101b92:	e8 1b 41 00 00       	call   80105cb2 <memset>
  log_write(bp);
80101b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b9a:	89 04 24             	mov    %eax,(%esp)
80101b9d:	e8 74 23 00 00       	call   80103f16 <log_write>
  brelse(bp);
80101ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba5:	89 04 24             	mov    %eax,(%esp)
80101ba8:	e8 6a e6 ff ff       	call   80100217 <brelse>
}
80101bad:	c9                   	leave  
80101bae:	c3                   	ret    

80101baf <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101baf:	55                   	push   %ebp
80101bb0:	89 e5                	mov    %esp,%ebp
80101bb2:	53                   	push   %ebx
80101bb3:	83 ec 24             	sub    $0x24,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101bb6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101bbd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101bc4:	e9 11 01 00 00       	jmp    80101cda <balloc+0x12b>
    bp = bread(dev, BBLOCK(b, sb));
80101bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bcc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101bd2:	85 c0                	test   %eax,%eax
80101bd4:	0f 48 c2             	cmovs  %edx,%eax
80101bd7:	c1 f8 0c             	sar    $0xc,%eax
80101bda:	89 c2                	mov    %eax,%edx
80101bdc:	a1 58 2a 11 80       	mov    0x80112a58,%eax
80101be1:	01 d0                	add    %edx,%eax
80101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	89 04 24             	mov    %eax,(%esp)
80101bed:	e8 b4 e5 ff ff       	call   801001a6 <bread>
80101bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101bf5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101bfc:	e9 a7 00 00 00       	jmp    80101ca8 <balloc+0xf9>
      m = 1 << (bi % 8);
80101c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c04:	89 c2                	mov    %eax,%edx
80101c06:	c1 fa 1f             	sar    $0x1f,%edx
80101c09:	c1 ea 1d             	shr    $0x1d,%edx
80101c0c:	01 d0                	add    %edx,%eax
80101c0e:	83 e0 07             	and    $0x7,%eax
80101c11:	29 d0                	sub    %edx,%eax
80101c13:	ba 01 00 00 00       	mov    $0x1,%edx
80101c18:	89 d3                	mov    %edx,%ebx
80101c1a:	89 c1                	mov    %eax,%ecx
80101c1c:	d3 e3                	shl    %cl,%ebx
80101c1e:	89 d8                	mov    %ebx,%eax
80101c20:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c26:	8d 50 07             	lea    0x7(%eax),%edx
80101c29:	85 c0                	test   %eax,%eax
80101c2b:	0f 48 c2             	cmovs  %edx,%eax
80101c2e:	c1 f8 03             	sar    $0x3,%eax
80101c31:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c34:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101c39:	0f b6 c0             	movzbl %al,%eax
80101c3c:	23 45 e8             	and    -0x18(%ebp),%eax
80101c3f:	85 c0                	test   %eax,%eax
80101c41:	75 61                	jne    80101ca4 <balloc+0xf5>
        bp->data[bi/8] |= m;  // Mark block in use.
80101c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c46:	8d 50 07             	lea    0x7(%eax),%edx
80101c49:	85 c0                	test   %eax,%eax
80101c4b:	0f 48 c2             	cmovs  %edx,%eax
80101c4e:	c1 f8 03             	sar    $0x3,%eax
80101c51:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c54:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101c59:	89 d1                	mov    %edx,%ecx
80101c5b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101c5e:	09 ca                	or     %ecx,%edx
80101c60:	89 d1                	mov    %edx,%ecx
80101c62:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c65:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c6c:	89 04 24             	mov    %eax,(%esp)
80101c6f:	e8 a2 22 00 00       	call   80103f16 <log_write>
        brelse(bp);
80101c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c77:	89 04 24             	mov    %eax,(%esp)
80101c7a:	e8 98 e5 ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c85:	01 c2                	add    %eax,%edx
80101c87:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c8e:	89 04 24             	mov    %eax,(%esp)
80101c91:	e8 c8 fe ff ff       	call   80101b5e <bzero>
        return b + bi;
80101c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c9c:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101c9e:	83 c4 24             	add    $0x24,%esp
80101ca1:	5b                   	pop    %ebx
80101ca2:	5d                   	pop    %ebp
80101ca3:	c3                   	ret    
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101ca4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ca8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101caf:	7f 17                	jg     80101cc8 <balloc+0x119>
80101cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb7:	01 d0                	add    %edx,%eax
80101cb9:	89 c2                	mov    %eax,%edx
80101cbb:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101cc0:	39 c2                	cmp    %eax,%edx
80101cc2:	0f 82 39 ff ff ff    	jb     80101c01 <balloc+0x52>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101cc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ccb:	89 04 24             	mov    %eax,(%esp)
80101cce:	e8 44 e5 ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101cd3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101cda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cdd:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101ce2:	39 c2                	cmp    %eax,%edx
80101ce4:	0f 82 df fe ff ff    	jb     80101bc9 <balloc+0x1a>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101cea:	c7 04 24 c0 91 10 80 	movl   $0x801091c0,(%esp)
80101cf1:	e8 47 e8 ff ff       	call   8010053d <panic>

80101cf6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101cf6:	55                   	push   %ebp
80101cf7:	89 e5                	mov    %esp,%ebp
80101cf9:	53                   	push   %ebx
80101cfa:	83 ec 24             	sub    $0x24,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101cfd:	c7 44 24 04 40 2a 11 	movl   $0x80112a40,0x4(%esp)
80101d04:	80 
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	89 04 24             	mov    %eax,(%esp)
80101d0b:	e8 08 fe ff ff       	call   80101b18 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101d10:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d13:	89 c2                	mov    %eax,%edx
80101d15:	c1 ea 0c             	shr    $0xc,%edx
80101d18:	a1 58 2a 11 80       	mov    0x80112a58,%eax
80101d1d:	01 c2                	add    %eax,%edx
80101d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d22:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d26:	89 04 24             	mov    %eax,(%esp)
80101d29:	e8 78 e4 ff ff       	call   801001a6 <bread>
80101d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101d31:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d34:	25 ff 0f 00 00       	and    $0xfff,%eax
80101d39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d3f:	89 c2                	mov    %eax,%edx
80101d41:	c1 fa 1f             	sar    $0x1f,%edx
80101d44:	c1 ea 1d             	shr    $0x1d,%edx
80101d47:	01 d0                	add    %edx,%eax
80101d49:	83 e0 07             	and    $0x7,%eax
80101d4c:	29 d0                	sub    %edx,%eax
80101d4e:	ba 01 00 00 00       	mov    $0x1,%edx
80101d53:	89 d3                	mov    %edx,%ebx
80101d55:	89 c1                	mov    %eax,%ecx
80101d57:	d3 e3                	shl    %cl,%ebx
80101d59:	89 d8                	mov    %ebx,%eax
80101d5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d61:	8d 50 07             	lea    0x7(%eax),%edx
80101d64:	85 c0                	test   %eax,%eax
80101d66:	0f 48 c2             	cmovs  %edx,%eax
80101d69:	c1 f8 03             	sar    $0x3,%eax
80101d6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6f:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101d74:	0f b6 c0             	movzbl %al,%eax
80101d77:	23 45 ec             	and    -0x14(%ebp),%eax
80101d7a:	85 c0                	test   %eax,%eax
80101d7c:	75 0c                	jne    80101d8a <bfree+0x94>
    panic("freeing free block");
80101d7e:	c7 04 24 d6 91 10 80 	movl   $0x801091d6,(%esp)
80101d85:	e8 b3 e7 ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8d:	8d 50 07             	lea    0x7(%eax),%edx
80101d90:	85 c0                	test   %eax,%eax
80101d92:	0f 48 c2             	cmovs  %edx,%eax
80101d95:	c1 f8 03             	sar    $0x3,%eax
80101d98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9b:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101da0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101da3:	f7 d1                	not    %ecx
80101da5:	21 ca                	and    %ecx,%edx
80101da7:	89 d1                	mov    %edx,%ecx
80101da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dac:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101db3:	89 04 24             	mov    %eax,(%esp)
80101db6:	e8 5b 21 00 00       	call   80103f16 <log_write>
  brelse(bp);
80101dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dbe:	89 04 24             	mov    %eax,(%esp)
80101dc1:	e8 51 e4 ff ff       	call   80100217 <brelse>
}
80101dc6:	83 c4 24             	add    $0x24,%esp
80101dc9:	5b                   	pop    %ebx
80101dca:	5d                   	pop    %ebp
80101dcb:	c3                   	ret    

80101dcc <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101dcc:	55                   	push   %ebp
80101dcd:	89 e5                	mov    %esp,%ebp
80101dcf:	57                   	push   %edi
80101dd0:	56                   	push   %esi
80101dd1:	53                   	push   %ebx
80101dd2:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
80101dd5:	c7 44 24 04 e9 91 10 	movl   $0x801091e9,0x4(%esp)
80101ddc:	80 
80101ddd:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101de4:	e8 59 3c 00 00       	call   80105a42 <initlock>
  readsb(dev, &sb);
80101de9:	c7 44 24 04 40 2a 11 	movl   $0x80112a40,0x4(%esp)
80101df0:	80 
80101df1:	8b 45 08             	mov    0x8(%ebp),%eax
80101df4:	89 04 24             	mov    %eax,(%esp)
80101df7:	e8 1c fd ff ff       	call   80101b18 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101dfc:	a1 58 2a 11 80       	mov    0x80112a58,%eax
80101e01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101e04:	8b 3d 54 2a 11 80    	mov    0x80112a54,%edi
80101e0a:	8b 35 50 2a 11 80    	mov    0x80112a50,%esi
80101e10:	8b 1d 4c 2a 11 80    	mov    0x80112a4c,%ebx
80101e16:	8b 0d 48 2a 11 80    	mov    0x80112a48,%ecx
80101e1c:	8b 15 44 2a 11 80    	mov    0x80112a44,%edx
80101e22:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101e27:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101e2d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101e31:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101e35:	89 74 24 14          	mov    %esi,0x14(%esp)
80101e39:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101e3d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101e41:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101e48:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e4c:	c7 04 24 f0 91 10 80 	movl   $0x801091f0,(%esp)
80101e53:	e8 49 e5 ff ff       	call   801003a1 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101e58:	83 c4 3c             	add    $0x3c,%esp
80101e5b:	5b                   	pop    %ebx
80101e5c:	5e                   	pop    %esi
80101e5d:	5f                   	pop    %edi
80101e5e:	5d                   	pop    %ebp
80101e5f:	c3                   	ret    

80101e60 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101e60:	55                   	push   %ebp
80101e61:	89 e5                	mov    %esp,%ebp
80101e63:	83 ec 38             	sub    $0x38,%esp
80101e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e69:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101e6d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101e74:	e9 9e 00 00 00       	jmp    80101f17 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e7c:	89 c2                	mov    %eax,%edx
80101e7e:	c1 ea 03             	shr    $0x3,%edx
80101e81:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101e86:	01 d0                	add    %edx,%eax
80101e88:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8f:	89 04 24             	mov    %eax,(%esp)
80101e92:	e8 0f e3 ff ff       	call   801001a6 <bread>
80101e97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e9d:	8d 50 18             	lea    0x18(%eax),%edx
80101ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea3:	83 e0 07             	and    $0x7,%eax
80101ea6:	c1 e0 06             	shl    $0x6,%eax
80101ea9:	01 d0                	add    %edx,%eax
80101eab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb1:	0f b7 00             	movzwl (%eax),%eax
80101eb4:	66 85 c0             	test   %ax,%ax
80101eb7:	75 4f                	jne    80101f08 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101eb9:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101ec0:	00 
80101ec1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101ec8:	00 
80101ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecc:	89 04 24             	mov    %eax,(%esp)
80101ecf:	e8 de 3d 00 00       	call   80105cb2 <memset>
      dip->type = type;
80101ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101edb:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee1:	89 04 24             	mov    %eax,(%esp)
80101ee4:	e8 2d 20 00 00       	call   80103f16 <log_write>
      brelse(bp);
80101ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eec:	89 04 24             	mov    %eax,(%esp)
80101eef:	e8 23 e3 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	89 04 24             	mov    %eax,(%esp)
80101f01:	e8 eb 00 00 00       	call   80101ff1 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101f06:	c9                   	leave  
80101f07:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f0b:	89 04 24             	mov    %eax,(%esp)
80101f0e:	e8 04 e3 ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101f13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f1a:	a1 48 2a 11 80       	mov    0x80112a48,%eax
80101f1f:	39 c2                	cmp    %eax,%edx
80101f21:	0f 82 52 ff ff ff    	jb     80101e79 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101f27:	c7 04 24 43 92 10 80 	movl   $0x80109243,(%esp)
80101f2e:	e8 0a e6 ff ff       	call   8010053d <panic>

80101f33 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101f33:	55                   	push   %ebp
80101f34:	89 e5                	mov    %esp,%ebp
80101f36:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101f39:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3c:	8b 40 04             	mov    0x4(%eax),%eax
80101f3f:	89 c2                	mov    %eax,%edx
80101f41:	c1 ea 03             	shr    $0x3,%edx
80101f44:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101f49:	01 c2                	add    %eax,%edx
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 00                	mov    (%eax),%eax
80101f50:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f54:	89 04 24             	mov    %eax,(%esp)
80101f57:	e8 4a e2 ff ff       	call   801001a6 <bread>
80101f5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f62:	8d 50 18             	lea    0x18(%eax),%edx
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	8b 40 04             	mov    0x4(%eax),%eax
80101f6b:	83 e0 07             	and    $0x7,%eax
80101f6e:	c1 e0 06             	shl    $0x6,%eax
80101f71:	01 d0                	add    %edx,%eax
80101f73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101f76:	8b 45 08             	mov    0x8(%ebp),%eax
80101f79:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f80:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f8d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9b:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fa9:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101fad:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb0:	8b 50 18             	mov    0x18(%eax),%edx
80101fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbc:	8d 50 1c             	lea    0x1c(%eax),%edx
80101fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc2:	83 c0 0c             	add    $0xc,%eax
80101fc5:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101fcc:	00 
80101fcd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fd1:	89 04 24             	mov    %eax,(%esp)
80101fd4:	e8 ac 3d 00 00       	call   80105d85 <memmove>
  log_write(bp);
80101fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fdc:	89 04 24             	mov    %eax,(%esp)
80101fdf:	e8 32 1f 00 00       	call   80103f16 <log_write>
  brelse(bp);
80101fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fe7:	89 04 24             	mov    %eax,(%esp)
80101fea:	e8 28 e2 ff ff       	call   80100217 <brelse>
}
80101fef:	c9                   	leave  
80101ff0:	c3                   	ret    

80101ff1 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101ff1:	55                   	push   %ebp
80101ff2:	89 e5                	mov    %esp,%ebp
80101ff4:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101ff7:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101ffe:	e8 60 3a 00 00       	call   80105a63 <acquire>

  // Is the inode already cached?
  empty = 0;
80102003:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010200a:	c7 45 f4 94 2a 11 80 	movl   $0x80112a94,-0xc(%ebp)
80102011:	eb 59                	jmp    8010206c <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80102013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102016:	8b 40 08             	mov    0x8(%eax),%eax
80102019:	85 c0                	test   %eax,%eax
8010201b:	7e 35                	jle    80102052 <iget+0x61>
8010201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102020:	8b 00                	mov    (%eax),%eax
80102022:	3b 45 08             	cmp    0x8(%ebp),%eax
80102025:	75 2b                	jne    80102052 <iget+0x61>
80102027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010202a:	8b 40 04             	mov    0x4(%eax),%eax
8010202d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102030:	75 20                	jne    80102052 <iget+0x61>
      ip->ref++;
80102032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102035:	8b 40 08             	mov    0x8(%eax),%eax
80102038:	8d 50 01             	lea    0x1(%eax),%edx
8010203b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010203e:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80102041:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102048:	e8 78 3a 00 00       	call   80105ac5 <release>
      return ip;
8010204d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102050:	eb 6f                	jmp    801020c1 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80102052:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102056:	75 10                	jne    80102068 <iget+0x77>
80102058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010205b:	8b 40 08             	mov    0x8(%eax),%eax
8010205e:	85 c0                	test   %eax,%eax
80102060:	75 06                	jne    80102068 <iget+0x77>
      empty = ip;
80102062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102065:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80102068:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010206c:	81 7d f4 34 3a 11 80 	cmpl   $0x80113a34,-0xc(%ebp)
80102073:	72 9e                	jb     80102013 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80102075:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102079:	75 0c                	jne    80102087 <iget+0x96>
    panic("iget: no inodes");
8010207b:	c7 04 24 55 92 10 80 	movl   $0x80109255,(%esp)
80102082:	e8 b6 e4 ff ff       	call   8010053d <panic>

  ip = empty;
80102087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102090:	8b 55 08             	mov    0x8(%ebp),%edx
80102093:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80102095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102098:	8b 55 0c             	mov    0xc(%ebp),%edx
8010209b:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010209e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ab:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801020b2:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801020b9:	e8 07 3a 00 00       	call   80105ac5 <release>

  return ip;
801020be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801020c1:	c9                   	leave  
801020c2:	c3                   	ret    

801020c3 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801020c3:	55                   	push   %ebp
801020c4:	89 e5                	mov    %esp,%ebp
801020c6:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801020c9:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801020d0:	e8 8e 39 00 00       	call   80105a63 <acquire>
  ip->ref++;
801020d5:	8b 45 08             	mov    0x8(%ebp),%eax
801020d8:	8b 40 08             	mov    0x8(%eax),%eax
801020db:	8d 50 01             	lea    0x1(%eax),%edx
801020de:	8b 45 08             	mov    0x8(%ebp),%eax
801020e1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801020e4:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801020eb:	e8 d5 39 00 00       	call   80105ac5 <release>
  return ip;
801020f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801020f3:	c9                   	leave  
801020f4:	c3                   	ret    

801020f5 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801020f5:	55                   	push   %ebp
801020f6:	89 e5                	mov    %esp,%ebp
801020f8:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801020fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801020ff:	74 0a                	je     8010210b <ilock+0x16>
80102101:	8b 45 08             	mov    0x8(%ebp),%eax
80102104:	8b 40 08             	mov    0x8(%eax),%eax
80102107:	85 c0                	test   %eax,%eax
80102109:	7f 0c                	jg     80102117 <ilock+0x22>
    panic("ilock");
8010210b:	c7 04 24 65 92 10 80 	movl   $0x80109265,(%esp)
80102112:	e8 26 e4 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102117:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
8010211e:	e8 40 39 00 00       	call   80105a63 <acquire>
  while(ip->flags & I_BUSY)
80102123:	eb 13                	jmp    80102138 <ilock+0x43>
    sleep(ip, &icache.lock);
80102125:	c7 44 24 04 60 2a 11 	movl   $0x80112a60,0x4(%esp)
8010212c:	80 
8010212d:	8b 45 08             	mov    0x8(%ebp),%eax
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	e8 39 35 00 00       	call   80105671 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80102138:	8b 45 08             	mov    0x8(%ebp),%eax
8010213b:	8b 40 0c             	mov    0xc(%eax),%eax
8010213e:	83 e0 01             	and    $0x1,%eax
80102141:	84 c0                	test   %al,%al
80102143:	75 e0                	jne    80102125 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80102145:	8b 45 08             	mov    0x8(%ebp),%eax
80102148:	8b 40 0c             	mov    0xc(%eax),%eax
8010214b:	89 c2                	mov    %eax,%edx
8010214d:	83 ca 01             	or     $0x1,%edx
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80102156:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
8010215d:	e8 63 39 00 00       	call   80105ac5 <release>

  if(!(ip->flags & I_VALID)){
80102162:	8b 45 08             	mov    0x8(%ebp),%eax
80102165:	8b 40 0c             	mov    0xc(%eax),%eax
80102168:	83 e0 02             	and    $0x2,%eax
8010216b:	85 c0                	test   %eax,%eax
8010216d:	0f 85 d4 00 00 00    	jne    80102247 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80102173:	8b 45 08             	mov    0x8(%ebp),%eax
80102176:	8b 40 04             	mov    0x4(%eax),%eax
80102179:	89 c2                	mov    %eax,%edx
8010217b:	c1 ea 03             	shr    $0x3,%edx
8010217e:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80102183:	01 c2                	add    %eax,%edx
80102185:	8b 45 08             	mov    0x8(%ebp),%eax
80102188:	8b 00                	mov    (%eax),%eax
8010218a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010218e:	89 04 24             	mov    %eax,(%esp)
80102191:	e8 10 e0 ff ff       	call   801001a6 <bread>
80102196:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80102199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219c:	8d 50 18             	lea    0x18(%eax),%edx
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	8b 40 04             	mov    0x4(%eax),%eax
801021a5:	83 e0 07             	and    $0x7,%eax
801021a8:	c1 e0 06             	shl    $0x6,%eax
801021ab:	01 d0                	add    %edx,%eax
801021ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801021b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021b3:	0f b7 10             	movzwl (%eax),%edx
801021b6:	8b 45 08             	mov    0x8(%ebp),%eax
801021b9:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801021bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021c0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801021c4:	8b 45 08             	mov    0x8(%ebp),%eax
801021c7:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801021cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ce:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801021d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021dc:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801021e0:	8b 45 08             	mov    0x8(%ebp),%eax
801021e3:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801021e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ea:	8b 50 08             	mov    0x8(%eax),%edx
801021ed:	8b 45 08             	mov    0x8(%ebp),%eax
801021f0:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801021f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f6:	8d 50 0c             	lea    0xc(%eax),%edx
801021f9:	8b 45 08             	mov    0x8(%ebp),%eax
801021fc:	83 c0 1c             	add    $0x1c,%eax
801021ff:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80102206:	00 
80102207:	89 54 24 04          	mov    %edx,0x4(%esp)
8010220b:	89 04 24             	mov    %eax,(%esp)
8010220e:	e8 72 3b 00 00       	call   80105d85 <memmove>
    brelse(bp);
80102213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102216:	89 04 24             	mov    %eax,(%esp)
80102219:	e8 f9 df ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	8b 40 0c             	mov    0xc(%eax),%eax
80102224:	89 c2                	mov    %eax,%edx
80102226:	83 ca 02             	or     $0x2,%edx
80102229:	8b 45 08             	mov    0x8(%ebp),%eax
8010222c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010222f:	8b 45 08             	mov    0x8(%ebp),%eax
80102232:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102236:	66 85 c0             	test   %ax,%ax
80102239:	75 0c                	jne    80102247 <ilock+0x152>
      panic("ilock: no type");
8010223b:	c7 04 24 6b 92 10 80 	movl   $0x8010926b,(%esp)
80102242:	e8 f6 e2 ff ff       	call   8010053d <panic>
  }
}
80102247:	c9                   	leave  
80102248:	c3                   	ret    

80102249 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80102249:	55                   	push   %ebp
8010224a:	89 e5                	mov    %esp,%ebp
8010224c:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
8010224f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102253:	74 17                	je     8010226c <iunlock+0x23>
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 40 0c             	mov    0xc(%eax),%eax
8010225b:	83 e0 01             	and    $0x1,%eax
8010225e:	85 c0                	test   %eax,%eax
80102260:	74 0a                	je     8010226c <iunlock+0x23>
80102262:	8b 45 08             	mov    0x8(%ebp),%eax
80102265:	8b 40 08             	mov    0x8(%eax),%eax
80102268:	85 c0                	test   %eax,%eax
8010226a:	7f 0c                	jg     80102278 <iunlock+0x2f>
    panic("iunlock");
8010226c:	c7 04 24 7a 92 10 80 	movl   $0x8010927a,(%esp)
80102273:	e8 c5 e2 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102278:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
8010227f:	e8 df 37 00 00       	call   80105a63 <acquire>
  ip->flags &= ~I_BUSY;
80102284:	8b 45 08             	mov    0x8(%ebp),%eax
80102287:	8b 40 0c             	mov    0xc(%eax),%eax
8010228a:	89 c2                	mov    %eax,%edx
8010228c:	83 e2 fe             	and    $0xfffffffe,%edx
8010228f:	8b 45 08             	mov    0x8(%ebp),%eax
80102292:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80102295:	8b 45 08             	mov    0x8(%ebp),%eax
80102298:	89 04 24             	mov    %eax,(%esp)
8010229b:	e8 ad 34 00 00       	call   8010574d <wakeup>
  release(&icache.lock);
801022a0:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801022a7:	e8 19 38 00 00       	call   80105ac5 <release>
}
801022ac:	c9                   	leave  
801022ad:	c3                   	ret    

801022ae <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
801022ae:	55                   	push   %ebp
801022af:	89 e5                	mov    %esp,%ebp
801022b1:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801022b4:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801022bb:	e8 a3 37 00 00       	call   80105a63 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
801022c0:	8b 45 08             	mov    0x8(%ebp),%eax
801022c3:	8b 40 08             	mov    0x8(%eax),%eax
801022c6:	83 f8 01             	cmp    $0x1,%eax
801022c9:	0f 85 93 00 00 00    	jne    80102362 <iput+0xb4>
801022cf:	8b 45 08             	mov    0x8(%ebp),%eax
801022d2:	8b 40 0c             	mov    0xc(%eax),%eax
801022d5:	83 e0 02             	and    $0x2,%eax
801022d8:	85 c0                	test   %eax,%eax
801022da:	0f 84 82 00 00 00    	je     80102362 <iput+0xb4>
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801022e7:	66 85 c0             	test   %ax,%ax
801022ea:	75 76                	jne    80102362 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
801022ec:	8b 45 08             	mov    0x8(%ebp),%eax
801022ef:	8b 40 0c             	mov    0xc(%eax),%eax
801022f2:	83 e0 01             	and    $0x1,%eax
801022f5:	84 c0                	test   %al,%al
801022f7:	74 0c                	je     80102305 <iput+0x57>
      panic("iput busy");
801022f9:	c7 04 24 82 92 10 80 	movl   $0x80109282,(%esp)
80102300:	e8 38 e2 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	8b 40 0c             	mov    0xc(%eax),%eax
8010230b:	89 c2                	mov    %eax,%edx
8010230d:	83 ca 01             	or     $0x1,%edx
80102310:	8b 45 08             	mov    0x8(%ebp),%eax
80102313:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80102316:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
8010231d:	e8 a3 37 00 00       	call   80105ac5 <release>
    itrunc(ip);
80102322:	8b 45 08             	mov    0x8(%ebp),%eax
80102325:	89 04 24             	mov    %eax,(%esp)
80102328:	e8 72 01 00 00       	call   8010249f <itrunc>
    ip->type = 0;
8010232d:	8b 45 08             	mov    0x8(%ebp),%eax
80102330:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	89 04 24             	mov    %eax,(%esp)
8010233c:	e8 f2 fb ff ff       	call   80101f33 <iupdate>
    acquire(&icache.lock);
80102341:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102348:	e8 16 37 00 00       	call   80105a63 <acquire>
    ip->flags = 0;
8010234d:	8b 45 08             	mov    0x8(%ebp),%eax
80102350:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80102357:	8b 45 08             	mov    0x8(%ebp),%eax
8010235a:	89 04 24             	mov    %eax,(%esp)
8010235d:	e8 eb 33 00 00       	call   8010574d <wakeup>
  }
  ip->ref--;
80102362:	8b 45 08             	mov    0x8(%ebp),%eax
80102365:	8b 40 08             	mov    0x8(%eax),%eax
80102368:	8d 50 ff             	lea    -0x1(%eax),%edx
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80102371:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102378:	e8 48 37 00 00       	call   80105ac5 <release>
}
8010237d:	c9                   	leave  
8010237e:	c3                   	ret    

8010237f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
8010237f:	55                   	push   %ebp
80102380:	89 e5                	mov    %esp,%ebp
80102382:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 04 24             	mov    %eax,(%esp)
8010238b:	e8 b9 fe ff ff       	call   80102249 <iunlock>
  iput(ip);
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	89 04 24             	mov    %eax,(%esp)
80102396:	e8 13 ff ff ff       	call   801022ae <iput>
}
8010239b:	c9                   	leave  
8010239c:	c3                   	ret    

8010239d <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
8010239d:	55                   	push   %ebp
8010239e:	89 e5                	mov    %esp,%ebp
801023a0:	53                   	push   %ebx
801023a1:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801023a4:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
801023a8:	77 3e                	ja     801023e8 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
801023aa:	8b 45 08             	mov    0x8(%ebp),%eax
801023ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801023b0:	83 c2 04             	add    $0x4,%edx
801023b3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801023b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801023be:	75 20                	jne    801023e0 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
801023c0:	8b 45 08             	mov    0x8(%ebp),%eax
801023c3:	8b 00                	mov    (%eax),%eax
801023c5:	89 04 24             	mov    %eax,(%esp)
801023c8:	e8 e2 f7 ff ff       	call   80101baf <balloc>
801023cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023d0:	8b 45 08             	mov    0x8(%ebp),%eax
801023d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801023d6:	8d 4a 04             	lea    0x4(%edx),%ecx
801023d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023dc:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
801023e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e3:	e9 b1 00 00 00       	jmp    80102499 <bmap+0xfc>
  }
  bn -= NDIRECT;
801023e8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
801023ec:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801023f0:	0f 87 97 00 00 00    	ja     8010248d <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801023f6:	8b 45 08             	mov    0x8(%ebp),%eax
801023f9:	8b 40 4c             	mov    0x4c(%eax),%eax
801023fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102403:	75 19                	jne    8010241e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
80102408:	8b 00                	mov    (%eax),%eax
8010240a:	89 04 24             	mov    %eax,(%esp)
8010240d:	e8 9d f7 ff ff       	call   80101baf <balloc>
80102412:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102415:	8b 45 08             	mov    0x8(%ebp),%eax
80102418:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010241b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
8010241e:	8b 45 08             	mov    0x8(%ebp),%eax
80102421:	8b 00                	mov    (%eax),%eax
80102423:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102426:	89 54 24 04          	mov    %edx,0x4(%esp)
8010242a:	89 04 24             	mov    %eax,(%esp)
8010242d:	e8 74 dd ff ff       	call   801001a6 <bread>
80102432:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80102435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102438:	83 c0 18             	add    $0x18,%eax
8010243b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
8010243e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102441:	c1 e0 02             	shl    $0x2,%eax
80102444:	03 45 ec             	add    -0x14(%ebp),%eax
80102447:	8b 00                	mov    (%eax),%eax
80102449:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010244c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102450:	75 2b                	jne    8010247d <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80102452:	8b 45 0c             	mov    0xc(%ebp),%eax
80102455:	c1 e0 02             	shl    $0x2,%eax
80102458:	89 c3                	mov    %eax,%ebx
8010245a:	03 5d ec             	add    -0x14(%ebp),%ebx
8010245d:	8b 45 08             	mov    0x8(%ebp),%eax
80102460:	8b 00                	mov    (%eax),%eax
80102462:	89 04 24             	mov    %eax,(%esp)
80102465:	e8 45 f7 ff ff       	call   80101baf <balloc>
8010246a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102470:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80102472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102475:	89 04 24             	mov    %eax,(%esp)
80102478:	e8 99 1a 00 00       	call   80103f16 <log_write>
    }
    brelse(bp);
8010247d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102480:	89 04 24             	mov    %eax,(%esp)
80102483:	e8 8f dd ff ff       	call   80100217 <brelse>
    return addr;
80102488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010248b:	eb 0c                	jmp    80102499 <bmap+0xfc>
  }

  panic("bmap: out of range");
8010248d:	c7 04 24 8c 92 10 80 	movl   $0x8010928c,(%esp)
80102494:	e8 a4 e0 ff ff       	call   8010053d <panic>
}
80102499:	83 c4 24             	add    $0x24,%esp
8010249c:	5b                   	pop    %ebx
8010249d:	5d                   	pop    %ebp
8010249e:	c3                   	ret    

8010249f <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
8010249f:	55                   	push   %ebp
801024a0:	89 e5                	mov    %esp,%ebp
801024a2:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801024a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024ac:	eb 44                	jmp    801024f2 <itrunc+0x53>
    if(ip->addrs[i]){
801024ae:	8b 45 08             	mov    0x8(%ebp),%eax
801024b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024b4:	83 c2 04             	add    $0x4,%edx
801024b7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801024bb:	85 c0                	test   %eax,%eax
801024bd:	74 2f                	je     801024ee <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
801024c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024c5:	83 c2 04             	add    $0x4,%edx
801024c8:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
801024cc:	8b 45 08             	mov    0x8(%ebp),%eax
801024cf:	8b 00                	mov    (%eax),%eax
801024d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801024d5:	89 04 24             	mov    %eax,(%esp)
801024d8:	e8 19 f8 ff ff       	call   80101cf6 <bfree>
      ip->addrs[i] = 0;
801024dd:	8b 45 08             	mov    0x8(%ebp),%eax
801024e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024e3:	83 c2 04             	add    $0x4,%edx
801024e6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801024ed:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801024ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801024f2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
801024f6:	7e b6                	jle    801024ae <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
801024f8:	8b 45 08             	mov    0x8(%ebp),%eax
801024fb:	8b 40 4c             	mov    0x4c(%eax),%eax
801024fe:	85 c0                	test   %eax,%eax
80102500:	0f 84 8f 00 00 00    	je     80102595 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102506:	8b 45 08             	mov    0x8(%ebp),%eax
80102509:	8b 50 4c             	mov    0x4c(%eax),%edx
8010250c:	8b 45 08             	mov    0x8(%ebp),%eax
8010250f:	8b 00                	mov    (%eax),%eax
80102511:	89 54 24 04          	mov    %edx,0x4(%esp)
80102515:	89 04 24             	mov    %eax,(%esp)
80102518:	e8 89 dc ff ff       	call   801001a6 <bread>
8010251d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80102520:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102523:	83 c0 18             	add    $0x18,%eax
80102526:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80102529:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102530:	eb 2f                	jmp    80102561 <itrunc+0xc2>
      if(a[j])
80102532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102535:	c1 e0 02             	shl    $0x2,%eax
80102538:	03 45 e8             	add    -0x18(%ebp),%eax
8010253b:	8b 00                	mov    (%eax),%eax
8010253d:	85 c0                	test   %eax,%eax
8010253f:	74 1c                	je     8010255d <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102544:	c1 e0 02             	shl    $0x2,%eax
80102547:	03 45 e8             	add    -0x18(%ebp),%eax
8010254a:	8b 10                	mov    (%eax),%edx
8010254c:	8b 45 08             	mov    0x8(%ebp),%eax
8010254f:	8b 00                	mov    (%eax),%eax
80102551:	89 54 24 04          	mov    %edx,0x4(%esp)
80102555:	89 04 24             	mov    %eax,(%esp)
80102558:	e8 99 f7 ff ff       	call   80101cf6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010255d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102561:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102564:	83 f8 7f             	cmp    $0x7f,%eax
80102567:	76 c9                	jbe    80102532 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80102569:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010256c:	89 04 24             	mov    %eax,(%esp)
8010256f:	e8 a3 dc ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102574:	8b 45 08             	mov    0x8(%ebp),%eax
80102577:	8b 50 4c             	mov    0x4c(%eax),%edx
8010257a:	8b 45 08             	mov    0x8(%ebp),%eax
8010257d:	8b 00                	mov    (%eax),%eax
8010257f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102583:	89 04 24             	mov    %eax,(%esp)
80102586:	e8 6b f7 ff ff       	call   80101cf6 <bfree>
    ip->addrs[NDIRECT] = 0;
8010258b:	8b 45 08             	mov    0x8(%ebp),%eax
8010258e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102595:	8b 45 08             	mov    0x8(%ebp),%eax
80102598:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
8010259f:	8b 45 08             	mov    0x8(%ebp),%eax
801025a2:	89 04 24             	mov    %eax,(%esp)
801025a5:	e8 89 f9 ff ff       	call   80101f33 <iupdate>
}
801025aa:	c9                   	leave  
801025ab:	c3                   	ret    

801025ac <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
801025ac:	55                   	push   %ebp
801025ad:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
801025af:	8b 45 08             	mov    0x8(%ebp),%eax
801025b2:	8b 00                	mov    (%eax),%eax
801025b4:	89 c2                	mov    %eax,%edx
801025b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
801025bc:	8b 45 08             	mov    0x8(%ebp),%eax
801025bf:	8b 50 04             	mov    0x4(%eax),%edx
801025c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801025c8:	8b 45 08             	mov    0x8(%ebp),%eax
801025cb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801025cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801025d2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801025d5:	8b 45 08             	mov    0x8(%ebp),%eax
801025d8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801025dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801025df:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801025e3:	8b 45 08             	mov    0x8(%ebp),%eax
801025e6:	8b 50 18             	mov    0x18(%eax),%edx
801025e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ec:	89 50 10             	mov    %edx,0x10(%eax)
}
801025ef:	5d                   	pop    %ebp
801025f0:	c3                   	ret    

801025f1 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801025f1:	55                   	push   %ebp
801025f2:	89 e5                	mov    %esp,%ebp
801025f4:	53                   	push   %ebx
801025f5:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801025f8:	8b 45 08             	mov    0x8(%ebp),%eax
801025fb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025ff:	66 83 f8 03          	cmp    $0x3,%ax
80102603:	75 60                	jne    80102665 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102605:	8b 45 08             	mov    0x8(%ebp),%eax
80102608:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010260c:	66 85 c0             	test   %ax,%ax
8010260f:	78 20                	js     80102631 <readi+0x40>
80102611:	8b 45 08             	mov    0x8(%ebp),%eax
80102614:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102618:	66 83 f8 09          	cmp    $0x9,%ax
8010261c:	7f 13                	jg     80102631 <readi+0x40>
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102625:	98                   	cwtl   
80102626:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
8010262d:	85 c0                	test   %eax,%eax
8010262f:	75 0a                	jne    8010263b <readi+0x4a>
      return -1;
80102631:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102636:	e9 1b 01 00 00       	jmp    80102756 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
8010263b:	8b 45 08             	mov    0x8(%ebp),%eax
8010263e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102642:	98                   	cwtl   
80102643:	8b 14 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%edx
8010264a:	8b 45 14             	mov    0x14(%ebp),%eax
8010264d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102651:	8b 45 0c             	mov    0xc(%ebp),%eax
80102654:	89 44 24 04          	mov    %eax,0x4(%esp)
80102658:	8b 45 08             	mov    0x8(%ebp),%eax
8010265b:	89 04 24             	mov    %eax,(%esp)
8010265e:	ff d2                	call   *%edx
80102660:	e9 f1 00 00 00       	jmp    80102756 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80102665:	8b 45 08             	mov    0x8(%ebp),%eax
80102668:	8b 40 18             	mov    0x18(%eax),%eax
8010266b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010266e:	72 0d                	jb     8010267d <readi+0x8c>
80102670:	8b 45 14             	mov    0x14(%ebp),%eax
80102673:	8b 55 10             	mov    0x10(%ebp),%edx
80102676:	01 d0                	add    %edx,%eax
80102678:	3b 45 10             	cmp    0x10(%ebp),%eax
8010267b:	73 0a                	jae    80102687 <readi+0x96>
    return -1;
8010267d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102682:	e9 cf 00 00 00       	jmp    80102756 <readi+0x165>
  if(off + n > ip->size)
80102687:	8b 45 14             	mov    0x14(%ebp),%eax
8010268a:	8b 55 10             	mov    0x10(%ebp),%edx
8010268d:	01 c2                	add    %eax,%edx
8010268f:	8b 45 08             	mov    0x8(%ebp),%eax
80102692:	8b 40 18             	mov    0x18(%eax),%eax
80102695:	39 c2                	cmp    %eax,%edx
80102697:	76 0c                	jbe    801026a5 <readi+0xb4>
    n = ip->size - off;
80102699:	8b 45 08             	mov    0x8(%ebp),%eax
8010269c:	8b 40 18             	mov    0x18(%eax),%eax
8010269f:	2b 45 10             	sub    0x10(%ebp),%eax
801026a2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801026a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026ac:	e9 96 00 00 00       	jmp    80102747 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801026b1:	8b 45 10             	mov    0x10(%ebp),%eax
801026b4:	c1 e8 09             	shr    $0x9,%eax
801026b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bb:	8b 45 08             	mov    0x8(%ebp),%eax
801026be:	89 04 24             	mov    %eax,(%esp)
801026c1:	e8 d7 fc ff ff       	call   8010239d <bmap>
801026c6:	8b 55 08             	mov    0x8(%ebp),%edx
801026c9:	8b 12                	mov    (%edx),%edx
801026cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801026cf:	89 14 24             	mov    %edx,(%esp)
801026d2:	e8 cf da ff ff       	call   801001a6 <bread>
801026d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801026da:	8b 45 10             	mov    0x10(%ebp),%eax
801026dd:	89 c2                	mov    %eax,%edx
801026df:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801026e5:	b8 00 02 00 00       	mov    $0x200,%eax
801026ea:	89 c1                	mov    %eax,%ecx
801026ec:	29 d1                	sub    %edx,%ecx
801026ee:	89 ca                	mov    %ecx,%edx
801026f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
801026f6:	89 cb                	mov    %ecx,%ebx
801026f8:	29 c3                	sub    %eax,%ebx
801026fa:	89 d8                	mov    %ebx,%eax
801026fc:	39 c2                	cmp    %eax,%edx
801026fe:	0f 46 c2             	cmovbe %edx,%eax
80102701:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102704:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102707:	8d 50 18             	lea    0x18(%eax),%edx
8010270a:	8b 45 10             	mov    0x10(%ebp),%eax
8010270d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102712:	01 c2                	add    %eax,%edx
80102714:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102717:	89 44 24 08          	mov    %eax,0x8(%esp)
8010271b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010271f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102722:	89 04 24             	mov    %eax,(%esp)
80102725:	e8 5b 36 00 00       	call   80105d85 <memmove>
    brelse(bp);
8010272a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010272d:	89 04 24             	mov    %eax,(%esp)
80102730:	e8 e2 da ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102735:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102738:	01 45 f4             	add    %eax,-0xc(%ebp)
8010273b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010273e:	01 45 10             	add    %eax,0x10(%ebp)
80102741:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102744:	01 45 0c             	add    %eax,0xc(%ebp)
80102747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010274d:	0f 82 5e ff ff ff    	jb     801026b1 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102753:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102756:	83 c4 24             	add    $0x24,%esp
80102759:	5b                   	pop    %ebx
8010275a:	5d                   	pop    %ebp
8010275b:	c3                   	ret    

8010275c <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010275c:	55                   	push   %ebp
8010275d:	89 e5                	mov    %esp,%ebp
8010275f:	53                   	push   %ebx
80102760:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102763:	8b 45 08             	mov    0x8(%ebp),%eax
80102766:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010276a:	66 83 f8 03          	cmp    $0x3,%ax
8010276e:	75 60                	jne    801027d0 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102770:	8b 45 08             	mov    0x8(%ebp),%eax
80102773:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102777:	66 85 c0             	test   %ax,%ax
8010277a:	78 20                	js     8010279c <writei+0x40>
8010277c:	8b 45 08             	mov    0x8(%ebp),%eax
8010277f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102783:	66 83 f8 09          	cmp    $0x9,%ax
80102787:	7f 13                	jg     8010279c <writei+0x40>
80102789:	8b 45 08             	mov    0x8(%ebp),%eax
8010278c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102790:	98                   	cwtl   
80102791:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
80102798:	85 c0                	test   %eax,%eax
8010279a:	75 0a                	jne    801027a6 <writei+0x4a>
      return -1;
8010279c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027a1:	e9 46 01 00 00       	jmp    801028ec <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
801027a6:	8b 45 08             	mov    0x8(%ebp),%eax
801027a9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027ad:	98                   	cwtl   
801027ae:	8b 14 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%edx
801027b5:	8b 45 14             	mov    0x14(%ebp),%eax
801027b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801027bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801027bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801027c3:	8b 45 08             	mov    0x8(%ebp),%eax
801027c6:	89 04 24             	mov    %eax,(%esp)
801027c9:	ff d2                	call   *%edx
801027cb:	e9 1c 01 00 00       	jmp    801028ec <writei+0x190>
  }

  if(off > ip->size || off + n < off)
801027d0:	8b 45 08             	mov    0x8(%ebp),%eax
801027d3:	8b 40 18             	mov    0x18(%eax),%eax
801027d6:	3b 45 10             	cmp    0x10(%ebp),%eax
801027d9:	72 0d                	jb     801027e8 <writei+0x8c>
801027db:	8b 45 14             	mov    0x14(%ebp),%eax
801027de:	8b 55 10             	mov    0x10(%ebp),%edx
801027e1:	01 d0                	add    %edx,%eax
801027e3:	3b 45 10             	cmp    0x10(%ebp),%eax
801027e6:	73 0a                	jae    801027f2 <writei+0x96>
    return -1;
801027e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027ed:	e9 fa 00 00 00       	jmp    801028ec <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801027f2:	8b 45 14             	mov    0x14(%ebp),%eax
801027f5:	8b 55 10             	mov    0x10(%ebp),%edx
801027f8:	01 d0                	add    %edx,%eax
801027fa:	3d 00 18 01 00       	cmp    $0x11800,%eax
801027ff:	76 0a                	jbe    8010280b <writei+0xaf>
    return -1;
80102801:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102806:	e9 e1 00 00 00       	jmp    801028ec <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010280b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102812:	e9 a1 00 00 00       	jmp    801028b8 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102817:	8b 45 10             	mov    0x10(%ebp),%eax
8010281a:	c1 e8 09             	shr    $0x9,%eax
8010281d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102821:	8b 45 08             	mov    0x8(%ebp),%eax
80102824:	89 04 24             	mov    %eax,(%esp)
80102827:	e8 71 fb ff ff       	call   8010239d <bmap>
8010282c:	8b 55 08             	mov    0x8(%ebp),%edx
8010282f:	8b 12                	mov    (%edx),%edx
80102831:	89 44 24 04          	mov    %eax,0x4(%esp)
80102835:	89 14 24             	mov    %edx,(%esp)
80102838:	e8 69 d9 ff ff       	call   801001a6 <bread>
8010283d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102840:	8b 45 10             	mov    0x10(%ebp),%eax
80102843:	89 c2                	mov    %eax,%edx
80102845:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010284b:	b8 00 02 00 00       	mov    $0x200,%eax
80102850:	89 c1                	mov    %eax,%ecx
80102852:	29 d1                	sub    %edx,%ecx
80102854:	89 ca                	mov    %ecx,%edx
80102856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102859:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010285c:	89 cb                	mov    %ecx,%ebx
8010285e:	29 c3                	sub    %eax,%ebx
80102860:	89 d8                	mov    %ebx,%eax
80102862:	39 c2                	cmp    %eax,%edx
80102864:	0f 46 c2             	cmovbe %edx,%eax
80102867:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010286a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010286d:	8d 50 18             	lea    0x18(%eax),%edx
80102870:	8b 45 10             	mov    0x10(%ebp),%eax
80102873:	25 ff 01 00 00       	and    $0x1ff,%eax
80102878:	01 c2                	add    %eax,%edx
8010287a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010287d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102881:	8b 45 0c             	mov    0xc(%ebp),%eax
80102884:	89 44 24 04          	mov    %eax,0x4(%esp)
80102888:	89 14 24             	mov    %edx,(%esp)
8010288b:	e8 f5 34 00 00       	call   80105d85 <memmove>
    log_write(bp);
80102890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102893:	89 04 24             	mov    %eax,(%esp)
80102896:	e8 7b 16 00 00       	call   80103f16 <log_write>
    brelse(bp);
8010289b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010289e:	89 04 24             	mov    %eax,(%esp)
801028a1:	e8 71 d9 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801028a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028a9:	01 45 f4             	add    %eax,-0xc(%ebp)
801028ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028af:	01 45 10             	add    %eax,0x10(%ebp)
801028b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028b5:	01 45 0c             	add    %eax,0xc(%ebp)
801028b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bb:	3b 45 14             	cmp    0x14(%ebp),%eax
801028be:	0f 82 53 ff ff ff    	jb     80102817 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801028c4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801028c8:	74 1f                	je     801028e9 <writei+0x18d>
801028ca:	8b 45 08             	mov    0x8(%ebp),%eax
801028cd:	8b 40 18             	mov    0x18(%eax),%eax
801028d0:	3b 45 10             	cmp    0x10(%ebp),%eax
801028d3:	73 14                	jae    801028e9 <writei+0x18d>
    ip->size = off;
801028d5:	8b 45 08             	mov    0x8(%ebp),%eax
801028d8:	8b 55 10             	mov    0x10(%ebp),%edx
801028db:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801028de:	8b 45 08             	mov    0x8(%ebp),%eax
801028e1:	89 04 24             	mov    %eax,(%esp)
801028e4:	e8 4a f6 ff ff       	call   80101f33 <iupdate>
  }
  return n;
801028e9:	8b 45 14             	mov    0x14(%ebp),%eax
}
801028ec:	83 c4 24             	add    $0x24,%esp
801028ef:	5b                   	pop    %ebx
801028f0:	5d                   	pop    %ebp
801028f1:	c3                   	ret    

801028f2 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801028f2:	55                   	push   %ebp
801028f3:	89 e5                	mov    %esp,%ebp
801028f5:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801028f8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801028ff:	00 
80102900:	8b 45 0c             	mov    0xc(%ebp),%eax
80102903:	89 44 24 04          	mov    %eax,0x4(%esp)
80102907:	8b 45 08             	mov    0x8(%ebp),%eax
8010290a:	89 04 24             	mov    %eax,(%esp)
8010290d:	e8 17 35 00 00       	call   80105e29 <strncmp>
}
80102912:	c9                   	leave  
80102913:	c3                   	ret    

80102914 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102914:	55                   	push   %ebp
80102915:	89 e5                	mov    %esp,%ebp
80102917:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010291a:	8b 45 08             	mov    0x8(%ebp),%eax
8010291d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102921:	66 83 f8 01          	cmp    $0x1,%ax
80102925:	74 0c                	je     80102933 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102927:	c7 04 24 9f 92 10 80 	movl   $0x8010929f,(%esp)
8010292e:	e8 0a dc ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102933:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010293a:	e9 87 00 00 00       	jmp    801029c6 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010293f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102946:	00 
80102947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010294e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102951:	89 44 24 04          	mov    %eax,0x4(%esp)
80102955:	8b 45 08             	mov    0x8(%ebp),%eax
80102958:	89 04 24             	mov    %eax,(%esp)
8010295b:	e8 91 fc ff ff       	call   801025f1 <readi>
80102960:	83 f8 10             	cmp    $0x10,%eax
80102963:	74 0c                	je     80102971 <dirlookup+0x5d>
      panic("dirlink read");
80102965:	c7 04 24 b1 92 10 80 	movl   $0x801092b1,(%esp)
8010296c:	e8 cc db ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102971:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102975:	66 85 c0             	test   %ax,%ax
80102978:	74 47                	je     801029c1 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010297a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010297d:	83 c0 02             	add    $0x2,%eax
80102980:	89 44 24 04          	mov    %eax,0x4(%esp)
80102984:	8b 45 0c             	mov    0xc(%ebp),%eax
80102987:	89 04 24             	mov    %eax,(%esp)
8010298a:	e8 63 ff ff ff       	call   801028f2 <namecmp>
8010298f:	85 c0                	test   %eax,%eax
80102991:	75 2f                	jne    801029c2 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102993:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102997:	74 08                	je     801029a1 <dirlookup+0x8d>
        *poff = off;
80102999:	8b 45 10             	mov    0x10(%ebp),%eax
8010299c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010299f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801029a1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801029a5:	0f b7 c0             	movzwl %ax,%eax
801029a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801029ab:	8b 45 08             	mov    0x8(%ebp),%eax
801029ae:	8b 00                	mov    (%eax),%eax
801029b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801029b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801029b7:	89 04 24             	mov    %eax,(%esp)
801029ba:	e8 32 f6 ff ff       	call   80101ff1 <iget>
801029bf:	eb 19                	jmp    801029da <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
801029c1:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801029c2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801029c6:	8b 45 08             	mov    0x8(%ebp),%eax
801029c9:	8b 40 18             	mov    0x18(%eax),%eax
801029cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801029cf:	0f 87 6a ff ff ff    	ja     8010293f <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801029d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029da:	c9                   	leave  
801029db:	c3                   	ret    

801029dc <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801029dc:	55                   	push   %ebp
801029dd:	89 e5                	mov    %esp,%ebp
801029df:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801029e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801029e9:	00 
801029ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f1:	8b 45 08             	mov    0x8(%ebp),%eax
801029f4:	89 04 24             	mov    %eax,(%esp)
801029f7:	e8 18 ff ff ff       	call   80102914 <dirlookup>
801029fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801029ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102a03:	74 15                	je     80102a1a <dirlink+0x3e>
    iput(ip);
80102a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a08:	89 04 24             	mov    %eax,(%esp)
80102a0b:	e8 9e f8 ff ff       	call   801022ae <iput>
    return -1;
80102a10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a15:	e9 b8 00 00 00       	jmp    80102ad2 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a21:	eb 44                	jmp    80102a67 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a26:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102a2d:	00 
80102a2e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102a32:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a39:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3c:	89 04 24             	mov    %eax,(%esp)
80102a3f:	e8 ad fb ff ff       	call   801025f1 <readi>
80102a44:	83 f8 10             	cmp    $0x10,%eax
80102a47:	74 0c                	je     80102a55 <dirlink+0x79>
      panic("dirlink read");
80102a49:	c7 04 24 b1 92 10 80 	movl   $0x801092b1,(%esp)
80102a50:	e8 e8 da ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102a55:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102a59:	66 85 c0             	test   %ax,%ax
80102a5c:	74 18                	je     80102a76 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a61:	83 c0 10             	add    $0x10,%eax
80102a64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6d:	8b 40 18             	mov    0x18(%eax),%eax
80102a70:	39 c2                	cmp    %eax,%edx
80102a72:	72 af                	jb     80102a23 <dirlink+0x47>
80102a74:	eb 01                	jmp    80102a77 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102a76:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102a77:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102a7e:	00 
80102a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a86:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a89:	83 c0 02             	add    $0x2,%eax
80102a8c:	89 04 24             	mov    %eax,(%esp)
80102a8f:	e8 ed 33 00 00       	call   80105e81 <strncpy>
  de.inum = inum;
80102a94:	8b 45 10             	mov    0x10(%ebp),%eax
80102a97:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102aa5:	00 
80102aa6:	89 44 24 08          	mov    %eax,0x8(%esp)
80102aaa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102aad:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab4:	89 04 24             	mov    %eax,(%esp)
80102ab7:	e8 a0 fc ff ff       	call   8010275c <writei>
80102abc:	83 f8 10             	cmp    $0x10,%eax
80102abf:	74 0c                	je     80102acd <dirlink+0xf1>
    panic("dirlink");
80102ac1:	c7 04 24 be 92 10 80 	movl   $0x801092be,(%esp)
80102ac8:	e8 70 da ff ff       	call   8010053d <panic>
  
  return 0;
80102acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ad2:	c9                   	leave  
80102ad3:	c3                   	ret    

80102ad4 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102ad4:	55                   	push   %ebp
80102ad5:	89 e5                	mov    %esp,%ebp
80102ad7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102ada:	eb 04                	jmp    80102ae0 <skipelem+0xc>
    path++;
80102adc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	0f b6 00             	movzbl (%eax),%eax
80102ae6:	3c 2f                	cmp    $0x2f,%al
80102ae8:	74 f2                	je     80102adc <skipelem+0x8>
    path++;
  if(*path == 0)
80102aea:	8b 45 08             	mov    0x8(%ebp),%eax
80102aed:	0f b6 00             	movzbl (%eax),%eax
80102af0:	84 c0                	test   %al,%al
80102af2:	75 0a                	jne    80102afe <skipelem+0x2a>
    return 0;
80102af4:	b8 00 00 00 00       	mov    $0x0,%eax
80102af9:	e9 86 00 00 00       	jmp    80102b84 <skipelem+0xb0>
  s = path;
80102afe:	8b 45 08             	mov    0x8(%ebp),%eax
80102b01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102b04:	eb 04                	jmp    80102b0a <skipelem+0x36>
    path++;
80102b06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0d:	0f b6 00             	movzbl (%eax),%eax
80102b10:	3c 2f                	cmp    $0x2f,%al
80102b12:	74 0a                	je     80102b1e <skipelem+0x4a>
80102b14:	8b 45 08             	mov    0x8(%ebp),%eax
80102b17:	0f b6 00             	movzbl (%eax),%eax
80102b1a:	84 c0                	test   %al,%al
80102b1c:	75 e8                	jne    80102b06 <skipelem+0x32>
    path++;
  len = path - s;
80102b1e:	8b 55 08             	mov    0x8(%ebp),%edx
80102b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b24:	89 d1                	mov    %edx,%ecx
80102b26:	29 c1                	sub    %eax,%ecx
80102b28:	89 c8                	mov    %ecx,%eax
80102b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102b2d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102b31:	7e 1c                	jle    80102b4f <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102b33:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102b3a:	00 
80102b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b42:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b45:	89 04 24             	mov    %eax,(%esp)
80102b48:	e8 38 32 00 00       	call   80105d85 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102b4d:	eb 28                	jmp    80102b77 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b52:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b59:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b60:	89 04 24             	mov    %eax,(%esp)
80102b63:	e8 1d 32 00 00       	call   80105d85 <memmove>
    name[len] = 0;
80102b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b6b:	03 45 0c             	add    0xc(%ebp),%eax
80102b6e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102b71:	eb 04                	jmp    80102b77 <skipelem+0xa3>
    path++;
80102b73:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	0f b6 00             	movzbl (%eax),%eax
80102b7d:	3c 2f                	cmp    $0x2f,%al
80102b7f:	74 f2                	je     80102b73 <skipelem+0x9f>
    path++;
  return path;
80102b81:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102b84:	c9                   	leave  
80102b85:	c3                   	ret    

80102b86 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102b86:	55                   	push   %ebp
80102b87:	89 e5                	mov    %esp,%ebp
80102b89:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8f:	0f b6 00             	movzbl (%eax),%eax
80102b92:	3c 2f                	cmp    $0x2f,%al
80102b94:	75 1c                	jne    80102bb2 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102b96:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b9d:	00 
80102b9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ba5:	e8 47 f4 ff ff       	call   80101ff1 <iget>
80102baa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102bad:	e9 af 00 00 00       	jmp    80102c61 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102bb2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102bb8:	8b 40 68             	mov    0x68(%eax),%eax
80102bbb:	89 04 24             	mov    %eax,(%esp)
80102bbe:	e8 00 f5 ff ff       	call   801020c3 <idup>
80102bc3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102bc6:	e9 96 00 00 00       	jmp    80102c61 <namex+0xdb>
    ilock(ip);
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	89 04 24             	mov    %eax,(%esp)
80102bd1:	e8 1f f5 ff ff       	call   801020f5 <ilock>
    if(ip->type != T_DIR){
80102bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102bdd:	66 83 f8 01          	cmp    $0x1,%ax
80102be1:	74 15                	je     80102bf8 <namex+0x72>
      iunlockput(ip);
80102be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be6:	89 04 24             	mov    %eax,(%esp)
80102be9:	e8 91 f7 ff ff       	call   8010237f <iunlockput>
      return 0;
80102bee:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf3:	e9 a3 00 00 00       	jmp    80102c9b <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102bf8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bfc:	74 1d                	je     80102c1b <namex+0x95>
80102bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80102c01:	0f b6 00             	movzbl (%eax),%eax
80102c04:	84 c0                	test   %al,%al
80102c06:	75 13                	jne    80102c1b <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0b:	89 04 24             	mov    %eax,(%esp)
80102c0e:	e8 36 f6 ff ff       	call   80102249 <iunlock>
      return ip;
80102c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c16:	e9 80 00 00 00       	jmp    80102c9b <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102c22:	00 
80102c23:	8b 45 10             	mov    0x10(%ebp),%eax
80102c26:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2d:	89 04 24             	mov    %eax,(%esp)
80102c30:	e8 df fc ff ff       	call   80102914 <dirlookup>
80102c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102c38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102c3c:	75 12                	jne    80102c50 <namex+0xca>
      iunlockput(ip);
80102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c41:	89 04 24             	mov    %eax,(%esp)
80102c44:	e8 36 f7 ff ff       	call   8010237f <iunlockput>
      return 0;
80102c49:	b8 00 00 00 00       	mov    $0x0,%eax
80102c4e:	eb 4b                	jmp    80102c9b <namex+0x115>
    }
    iunlockput(ip);
80102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c53:	89 04 24             	mov    %eax,(%esp)
80102c56:	e8 24 f7 ff ff       	call   8010237f <iunlockput>
    ip = next;
80102c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102c61:	8b 45 10             	mov    0x10(%ebp),%eax
80102c64:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c68:	8b 45 08             	mov    0x8(%ebp),%eax
80102c6b:	89 04 24             	mov    %eax,(%esp)
80102c6e:	e8 61 fe ff ff       	call   80102ad4 <skipelem>
80102c73:	89 45 08             	mov    %eax,0x8(%ebp)
80102c76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102c7a:	0f 85 4b ff ff ff    	jne    80102bcb <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102c80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c84:	74 12                	je     80102c98 <namex+0x112>
    iput(ip);
80102c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c89:	89 04 24             	mov    %eax,(%esp)
80102c8c:	e8 1d f6 ff ff       	call   801022ae <iput>
    return 0;
80102c91:	b8 00 00 00 00       	mov    $0x0,%eax
80102c96:	eb 03                	jmp    80102c9b <namex+0x115>
  }
  return ip;
80102c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c9b:	c9                   	leave  
80102c9c:	c3                   	ret    

80102c9d <namei>:

struct inode*
namei(char *path)
{
80102c9d:	55                   	push   %ebp
80102c9e:	89 e5                	mov    %esp,%ebp
80102ca0:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102ca3:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102ca6:	89 44 24 08          	mov    %eax,0x8(%esp)
80102caa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb1:	00 
80102cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb5:	89 04 24             	mov    %eax,(%esp)
80102cb8:	e8 c9 fe ff ff       	call   80102b86 <namex>
}
80102cbd:	c9                   	leave  
80102cbe:	c3                   	ret    

80102cbf <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
80102ccc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102cd3:	00 
80102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd7:	89 04 24             	mov    %eax,(%esp)
80102cda:	e8 a7 fe ff ff       	call   80102b86 <namex>
}
80102cdf:	c9                   	leave  
80102ce0:	c3                   	ret    
80102ce1:	00 00                	add    %al,(%eax)
	...

80102ce4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ce4:	55                   	push   %ebp
80102ce5:	89 e5                	mov    %esp,%ebp
80102ce7:	53                   	push   %ebx
80102ce8:	83 ec 14             	sub    $0x14,%esp
80102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cee:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102cf6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102cfa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102cfe:	ec                   	in     (%dx),%al
80102cff:	89 c3                	mov    %eax,%ebx
80102d01:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d04:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d08:	83 c4 14             	add    $0x14,%esp
80102d0b:	5b                   	pop    %ebx
80102d0c:	5d                   	pop    %ebp
80102d0d:	c3                   	ret    

80102d0e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d0e:	55                   	push   %ebp
80102d0f:	89 e5                	mov    %esp,%ebp
80102d11:	57                   	push   %edi
80102d12:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d13:	8b 55 08             	mov    0x8(%ebp),%edx
80102d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d19:	8b 45 10             	mov    0x10(%ebp),%eax
80102d1c:	89 cb                	mov    %ecx,%ebx
80102d1e:	89 df                	mov    %ebx,%edi
80102d20:	89 c1                	mov    %eax,%ecx
80102d22:	fc                   	cld    
80102d23:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d25:	89 c8                	mov    %ecx,%eax
80102d27:	89 fb                	mov    %edi,%ebx
80102d29:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d2c:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d2f:	5b                   	pop    %ebx
80102d30:	5f                   	pop    %edi
80102d31:	5d                   	pop    %ebp
80102d32:	c3                   	ret    

80102d33 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d33:	55                   	push   %ebp
80102d34:	89 e5                	mov    %esp,%ebp
80102d36:	83 ec 08             	sub    $0x8,%esp
80102d39:	8b 55 08             	mov    0x8(%ebp),%edx
80102d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d3f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d43:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d46:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d4a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d4e:	ee                   	out    %al,(%dx)
}
80102d4f:	c9                   	leave  
80102d50:	c3                   	ret    

80102d51 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102d51:	55                   	push   %ebp
80102d52:	89 e5                	mov    %esp,%ebp
80102d54:	56                   	push   %esi
80102d55:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102d56:	8b 55 08             	mov    0x8(%ebp),%edx
80102d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d5c:	8b 45 10             	mov    0x10(%ebp),%eax
80102d5f:	89 cb                	mov    %ecx,%ebx
80102d61:	89 de                	mov    %ebx,%esi
80102d63:	89 c1                	mov    %eax,%ecx
80102d65:	fc                   	cld    
80102d66:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102d68:	89 c8                	mov    %ecx,%eax
80102d6a:	89 f3                	mov    %esi,%ebx
80102d6c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d6f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102d72:	5b                   	pop    %ebx
80102d73:	5e                   	pop    %esi
80102d74:	5d                   	pop    %ebp
80102d75:	c3                   	ret    

80102d76 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102d76:	55                   	push   %ebp
80102d77:	89 e5                	mov    %esp,%ebp
80102d79:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102d7c:	90                   	nop
80102d7d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102d84:	e8 5b ff ff ff       	call   80102ce4 <inb>
80102d89:	0f b6 c0             	movzbl %al,%eax
80102d8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d92:	25 c0 00 00 00       	and    $0xc0,%eax
80102d97:	83 f8 40             	cmp    $0x40,%eax
80102d9a:	75 e1                	jne    80102d7d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d9c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102da0:	74 11                	je     80102db3 <idewait+0x3d>
80102da2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da5:	83 e0 21             	and    $0x21,%eax
80102da8:	85 c0                	test   %eax,%eax
80102daa:	74 07                	je     80102db3 <idewait+0x3d>
    return -1;
80102dac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102db1:	eb 05                	jmp    80102db8 <idewait+0x42>
  return 0;
80102db3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102db8:	c9                   	leave  
80102db9:	c3                   	ret    

80102dba <ideinit>:

void
ideinit(void)
{
80102dba:	55                   	push   %ebp
80102dbb:	89 e5                	mov    %esp,%ebp
80102dbd:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102dc0:	c7 44 24 04 c6 92 10 	movl   $0x801092c6,0x4(%esp)
80102dc7:	80 
80102dc8:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102dcf:	e8 6e 2c 00 00       	call   80105a42 <initlock>
  picenable(IRQ_IDE);
80102dd4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102ddb:	e8 e5 18 00 00       	call   801046c5 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102de0:	a1 60 41 11 80       	mov    0x80114160,%eax
80102de5:	83 e8 01             	sub    $0x1,%eax
80102de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dec:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102df3:	e8 46 04 00 00       	call   8010323e <ioapicenable>
  idewait(0);
80102df8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102dff:	e8 72 ff ff ff       	call   80102d76 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e04:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102e0b:	00 
80102e0c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102e13:	e8 1b ff ff ff       	call   80102d33 <outb>
  for(i=0; i<1000; i++){
80102e18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e1f:	eb 20                	jmp    80102e41 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102e21:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102e28:	e8 b7 fe ff ff       	call   80102ce4 <inb>
80102e2d:	84 c0                	test   %al,%al
80102e2f:	74 0c                	je     80102e3d <ideinit+0x83>
      havedisk1 = 1;
80102e31:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102e38:	00 00 00 
      break;
80102e3b:	eb 0d                	jmp    80102e4a <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102e3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e41:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102e48:	7e d7                	jle    80102e21 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102e4a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102e51:	00 
80102e52:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102e59:	e8 d5 fe ff ff       	call   80102d33 <outb>
}
80102e5e:	c9                   	leave  
80102e5f:	c3                   	ret    

80102e60 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102e60:	55                   	push   %ebp
80102e61:	89 e5                	mov    %esp,%ebp
80102e63:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102e66:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e6a:	75 0c                	jne    80102e78 <idestart+0x18>
    panic("idestart");
80102e6c:	c7 04 24 ca 92 10 80 	movl   $0x801092ca,(%esp)
80102e73:	e8 c5 d6 ff ff       	call   8010053d <panic>
  if(b->blockno >= FSSIZE)
80102e78:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7b:	8b 40 08             	mov    0x8(%eax),%eax
80102e7e:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e83:	76 0c                	jbe    80102e91 <idestart+0x31>
    panic("incorrect blockno");
80102e85:	c7 04 24 d3 92 10 80 	movl   $0x801092d3,(%esp)
80102e8c:	e8 ac d6 ff ff       	call   8010053d <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e91:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102e98:	8b 45 08             	mov    0x8(%ebp),%eax
80102e9b:	8b 50 08             	mov    0x8(%eax),%edx
80102e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea1:	0f af c2             	imul   %edx,%eax
80102ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102ea7:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102eab:	7e 0c                	jle    80102eb9 <idestart+0x59>
80102ead:	c7 04 24 ca 92 10 80 	movl   $0x801092ca,(%esp)
80102eb4:	e8 84 d6 ff ff       	call   8010053d <panic>
  
  idewait(0);
80102eb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102ec0:	e8 b1 fe ff ff       	call   80102d76 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102ec5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ecc:	00 
80102ecd:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102ed4:	e8 5a fe ff ff       	call   80102d33 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102edc:	0f b6 c0             	movzbl %al,%eax
80102edf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ee3:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102eea:	e8 44 fe ff ff       	call   80102d33 <outb>
  outb(0x1f3, sector & 0xff);
80102eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ef2:	0f b6 c0             	movzbl %al,%eax
80102ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ef9:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102f00:	e8 2e fe ff ff       	call   80102d33 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f08:	c1 f8 08             	sar    $0x8,%eax
80102f0b:	0f b6 c0             	movzbl %al,%eax
80102f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f12:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102f19:	e8 15 fe ff ff       	call   80102d33 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f21:	c1 f8 10             	sar    $0x10,%eax
80102f24:	0f b6 c0             	movzbl %al,%eax
80102f27:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f2b:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102f32:	e8 fc fd ff ff       	call   80102d33 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102f37:	8b 45 08             	mov    0x8(%ebp),%eax
80102f3a:	8b 40 04             	mov    0x4(%eax),%eax
80102f3d:	83 e0 01             	and    $0x1,%eax
80102f40:	89 c2                	mov    %eax,%edx
80102f42:	c1 e2 04             	shl    $0x4,%edx
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	c1 f8 18             	sar    $0x18,%eax
80102f4b:	83 e0 0f             	and    $0xf,%eax
80102f4e:	09 d0                	or     %edx,%eax
80102f50:	83 c8 e0             	or     $0xffffffe0,%eax
80102f53:	0f b6 c0             	movzbl %al,%eax
80102f56:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f5a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102f61:	e8 cd fd ff ff       	call   80102d33 <outb>
  if(b->flags & B_DIRTY){
80102f66:	8b 45 08             	mov    0x8(%ebp),%eax
80102f69:	8b 00                	mov    (%eax),%eax
80102f6b:	83 e0 04             	and    $0x4,%eax
80102f6e:	85 c0                	test   %eax,%eax
80102f70:	74 34                	je     80102fa6 <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
80102f72:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102f79:	00 
80102f7a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102f81:	e8 ad fd ff ff       	call   80102d33 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102f86:	8b 45 08             	mov    0x8(%ebp),%eax
80102f89:	83 c0 18             	add    $0x18,%eax
80102f8c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102f93:	00 
80102f94:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f98:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102f9f:	e8 ad fd ff ff       	call   80102d51 <outsl>
80102fa4:	eb 14                	jmp    80102fba <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102fa6:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102fad:	00 
80102fae:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102fb5:	e8 79 fd ff ff       	call   80102d33 <outb>
  }
}
80102fba:	c9                   	leave  
80102fbb:	c3                   	ret    

80102fbc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102fbc:	55                   	push   %ebp
80102fbd:	89 e5                	mov    %esp,%ebp
80102fbf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102fc2:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102fc9:	e8 95 2a 00 00       	call   80105a63 <acquire>
  if((b = idequeue) == 0){
80102fce:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102fd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102fda:	75 11                	jne    80102fed <ideintr+0x31>
    release(&idelock);
80102fdc:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102fe3:	e8 dd 2a 00 00       	call   80105ac5 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102fe8:	e9 90 00 00 00       	jmp    8010307d <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ff0:	8b 40 14             	mov    0x14(%eax),%eax
80102ff3:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ffb:	8b 00                	mov    (%eax),%eax
80102ffd:	83 e0 04             	and    $0x4,%eax
80103000:	85 c0                	test   %eax,%eax
80103002:	75 2e                	jne    80103032 <ideintr+0x76>
80103004:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010300b:	e8 66 fd ff ff       	call   80102d76 <idewait>
80103010:	85 c0                	test   %eax,%eax
80103012:	78 1e                	js     80103032 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80103014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103017:	83 c0 18             	add    $0x18,%eax
8010301a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80103021:	00 
80103022:	89 44 24 04          	mov    %eax,0x4(%esp)
80103026:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010302d:	e8 dc fc ff ff       	call   80102d0e <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80103032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103035:	8b 00                	mov    (%eax),%eax
80103037:	89 c2                	mov    %eax,%edx
80103039:	83 ca 02             	or     $0x2,%edx
8010303c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303f:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80103041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103044:	8b 00                	mov    (%eax),%eax
80103046:	89 c2                	mov    %eax,%edx
80103048:	83 e2 fb             	and    $0xfffffffb,%edx
8010304b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010304e:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80103050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103053:	89 04 24             	mov    %eax,(%esp)
80103056:	e8 f2 26 00 00       	call   8010574d <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010305b:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103060:	85 c0                	test   %eax,%eax
80103062:	74 0d                	je     80103071 <ideintr+0xb5>
    idestart(idequeue);
80103064:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103069:	89 04 24             	mov    %eax,(%esp)
8010306c:	e8 ef fd ff ff       	call   80102e60 <idestart>

  release(&idelock);
80103071:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80103078:	e8 48 2a 00 00       	call   80105ac5 <release>
}
8010307d:	c9                   	leave  
8010307e:	c3                   	ret    

8010307f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010307f:	55                   	push   %ebp
80103080:	89 e5                	mov    %esp,%ebp
80103082:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103085:	8b 45 08             	mov    0x8(%ebp),%eax
80103088:	8b 00                	mov    (%eax),%eax
8010308a:	83 e0 01             	and    $0x1,%eax
8010308d:	85 c0                	test   %eax,%eax
8010308f:	75 0c                	jne    8010309d <iderw+0x1e>
    panic("iderw: buf not busy");
80103091:	c7 04 24 e5 92 10 80 	movl   $0x801092e5,(%esp)
80103098:	e8 a0 d4 ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010309d:	8b 45 08             	mov    0x8(%ebp),%eax
801030a0:	8b 00                	mov    (%eax),%eax
801030a2:	83 e0 06             	and    $0x6,%eax
801030a5:	83 f8 02             	cmp    $0x2,%eax
801030a8:	75 0c                	jne    801030b6 <iderw+0x37>
    panic("iderw: nothing to do");
801030aa:	c7 04 24 f9 92 10 80 	movl   $0x801092f9,(%esp)
801030b1:	e8 87 d4 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801030b6:	8b 45 08             	mov    0x8(%ebp),%eax
801030b9:	8b 40 04             	mov    0x4(%eax),%eax
801030bc:	85 c0                	test   %eax,%eax
801030be:	74 15                	je     801030d5 <iderw+0x56>
801030c0:	a1 38 c6 10 80       	mov    0x8010c638,%eax
801030c5:	85 c0                	test   %eax,%eax
801030c7:	75 0c                	jne    801030d5 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801030c9:	c7 04 24 0e 93 10 80 	movl   $0x8010930e,(%esp)
801030d0:	e8 68 d4 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
801030d5:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801030dc:	e8 82 29 00 00       	call   80105a63 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801030e1:	8b 45 08             	mov    0x8(%ebp),%eax
801030e4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801030eb:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
801030f2:	eb 0b                	jmp    801030ff <iderw+0x80>
801030f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030f7:	8b 00                	mov    (%eax),%eax
801030f9:	83 c0 14             	add    $0x14,%eax
801030fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801030ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103102:	8b 00                	mov    (%eax),%eax
80103104:	85 c0                	test   %eax,%eax
80103106:	75 ec                	jne    801030f4 <iderw+0x75>
    ;
  *pp = b;
80103108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310b:	8b 55 08             	mov    0x8(%ebp),%edx
8010310e:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80103110:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103115:	3b 45 08             	cmp    0x8(%ebp),%eax
80103118:	75 22                	jne    8010313c <iderw+0xbd>
    idestart(b);
8010311a:	8b 45 08             	mov    0x8(%ebp),%eax
8010311d:	89 04 24             	mov    %eax,(%esp)
80103120:	e8 3b fd ff ff       	call   80102e60 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103125:	eb 15                	jmp    8010313c <iderw+0xbd>
    sleep(b, &idelock);
80103127:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
8010312e:	80 
8010312f:	8b 45 08             	mov    0x8(%ebp),%eax
80103132:	89 04 24             	mov    %eax,(%esp)
80103135:	e8 37 25 00 00       	call   80105671 <sleep>
8010313a:	eb 01                	jmp    8010313d <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010313c:	90                   	nop
8010313d:	8b 45 08             	mov    0x8(%ebp),%eax
80103140:	8b 00                	mov    (%eax),%eax
80103142:	83 e0 06             	and    $0x6,%eax
80103145:	83 f8 02             	cmp    $0x2,%eax
80103148:	75 dd                	jne    80103127 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
8010314a:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80103151:	e8 6f 29 00 00       	call   80105ac5 <release>
}
80103156:	c9                   	leave  
80103157:	c3                   	ret    

80103158 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103158:	55                   	push   %ebp
80103159:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010315b:	a1 34 3a 11 80       	mov    0x80113a34,%eax
80103160:	8b 55 08             	mov    0x8(%ebp),%edx
80103163:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103165:	a1 34 3a 11 80       	mov    0x80113a34,%eax
8010316a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010316d:	5d                   	pop    %ebp
8010316e:	c3                   	ret    

8010316f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010316f:	55                   	push   %ebp
80103170:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103172:	a1 34 3a 11 80       	mov    0x80113a34,%eax
80103177:	8b 55 08             	mov    0x8(%ebp),%edx
8010317a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010317c:	a1 34 3a 11 80       	mov    0x80113a34,%eax
80103181:	8b 55 0c             	mov    0xc(%ebp),%edx
80103184:	89 50 10             	mov    %edx,0x10(%eax)
}
80103187:	5d                   	pop    %ebp
80103188:	c3                   	ret    

80103189 <ioapicinit>:

void
ioapicinit(void)
{
80103189:	55                   	push   %ebp
8010318a:	89 e5                	mov    %esp,%ebp
8010318c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010318f:	a1 64 3b 11 80       	mov    0x80113b64,%eax
80103194:	85 c0                	test   %eax,%eax
80103196:	0f 84 9f 00 00 00    	je     8010323b <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010319c:	c7 05 34 3a 11 80 00 	movl   $0xfec00000,0x80113a34
801031a3:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801031a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031ad:	e8 a6 ff ff ff       	call   80103158 <ioapicread>
801031b2:	c1 e8 10             	shr    $0x10,%eax
801031b5:	25 ff 00 00 00       	and    $0xff,%eax
801031ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801031bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801031c4:	e8 8f ff ff ff       	call   80103158 <ioapicread>
801031c9:	c1 e8 18             	shr    $0x18,%eax
801031cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801031cf:	0f b6 05 60 3b 11 80 	movzbl 0x80113b60,%eax
801031d6:	0f b6 c0             	movzbl %al,%eax
801031d9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801031dc:	74 0c                	je     801031ea <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801031de:	c7 04 24 2c 93 10 80 	movl   $0x8010932c,(%esp)
801031e5:	e8 b7 d1 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031f1:	eb 3e                	jmp    80103231 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801031f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031f6:	83 c0 20             	add    $0x20,%eax
801031f9:	0d 00 00 01 00       	or     $0x10000,%eax
801031fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103201:	83 c2 08             	add    $0x8,%edx
80103204:	01 d2                	add    %edx,%edx
80103206:	89 44 24 04          	mov    %eax,0x4(%esp)
8010320a:	89 14 24             	mov    %edx,(%esp)
8010320d:	e8 5d ff ff ff       	call   8010316f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80103212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103215:	83 c0 08             	add    $0x8,%eax
80103218:	01 c0                	add    %eax,%eax
8010321a:	83 c0 01             	add    $0x1,%eax
8010321d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103224:	00 
80103225:	89 04 24             	mov    %eax,(%esp)
80103228:	e8 42 ff ff ff       	call   8010316f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010322d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103234:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103237:	7e ba                	jle    801031f3 <ioapicinit+0x6a>
80103239:	eb 01                	jmp    8010323c <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
8010323b:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010323c:	c9                   	leave  
8010323d:	c3                   	ret    

8010323e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010323e:	55                   	push   %ebp
8010323f:	89 e5                	mov    %esp,%ebp
80103241:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80103244:	a1 64 3b 11 80       	mov    0x80113b64,%eax
80103249:	85 c0                	test   %eax,%eax
8010324b:	74 39                	je     80103286 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010324d:	8b 45 08             	mov    0x8(%ebp),%eax
80103250:	83 c0 20             	add    $0x20,%eax
80103253:	8b 55 08             	mov    0x8(%ebp),%edx
80103256:	83 c2 08             	add    $0x8,%edx
80103259:	01 d2                	add    %edx,%edx
8010325b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010325f:	89 14 24             	mov    %edx,(%esp)
80103262:	e8 08 ff ff ff       	call   8010316f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103267:	8b 45 0c             	mov    0xc(%ebp),%eax
8010326a:	c1 e0 18             	shl    $0x18,%eax
8010326d:	8b 55 08             	mov    0x8(%ebp),%edx
80103270:	83 c2 08             	add    $0x8,%edx
80103273:	01 d2                	add    %edx,%edx
80103275:	83 c2 01             	add    $0x1,%edx
80103278:	89 44 24 04          	mov    %eax,0x4(%esp)
8010327c:	89 14 24             	mov    %edx,(%esp)
8010327f:	e8 eb fe ff ff       	call   8010316f <ioapicwrite>
80103284:	eb 01                	jmp    80103287 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103286:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103287:	c9                   	leave  
80103288:	c3                   	ret    
80103289:	00 00                	add    %al,(%eax)
	...

8010328c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010328c:	55                   	push   %ebp
8010328d:	89 e5                	mov    %esp,%ebp
8010328f:	8b 45 08             	mov    0x8(%ebp),%eax
80103292:	05 00 00 00 80       	add    $0x80000000,%eax
80103297:	5d                   	pop    %ebp
80103298:	c3                   	ret    

80103299 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103299:	55                   	push   %ebp
8010329a:	89 e5                	mov    %esp,%ebp
8010329c:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
8010329f:	c7 44 24 04 5e 93 10 	movl   $0x8010935e,0x4(%esp)
801032a6:	80 
801032a7:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801032ae:	e8 8f 27 00 00       	call   80105a42 <initlock>
  kmem.use_lock = 0;
801032b3:	c7 05 74 3a 11 80 00 	movl   $0x0,0x80113a74
801032ba:	00 00 00 
  freerange(vstart, vend);
801032bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801032c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c4:	8b 45 08             	mov    0x8(%ebp),%eax
801032c7:	89 04 24             	mov    %eax,(%esp)
801032ca:	e8 26 00 00 00       	call   801032f5 <freerange>
}
801032cf:	c9                   	leave  
801032d0:	c3                   	ret    

801032d1 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801032d1:	55                   	push   %ebp
801032d2:	89 e5                	mov    %esp,%ebp
801032d4:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801032d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801032da:	89 44 24 04          	mov    %eax,0x4(%esp)
801032de:	8b 45 08             	mov    0x8(%ebp),%eax
801032e1:	89 04 24             	mov    %eax,(%esp)
801032e4:	e8 0c 00 00 00       	call   801032f5 <freerange>
  kmem.use_lock = 1;
801032e9:	c7 05 74 3a 11 80 01 	movl   $0x1,0x80113a74
801032f0:	00 00 00 
}
801032f3:	c9                   	leave  
801032f4:	c3                   	ret    

801032f5 <freerange>:

void
freerange(void *vstart, void *vend)
{
801032f5:	55                   	push   %ebp
801032f6:	89 e5                	mov    %esp,%ebp
801032f8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801032fb:	8b 45 08             	mov    0x8(%ebp),%eax
801032fe:	05 ff 0f 00 00       	add    $0xfff,%eax
80103303:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103308:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010330b:	eb 12                	jmp    8010331f <freerange+0x2a>
    kfree(p);
8010330d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103310:	89 04 24             	mov    %eax,(%esp)
80103313:	e8 16 00 00 00       	call   8010332e <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103318:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010331f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103322:	05 00 10 00 00       	add    $0x1000,%eax
80103327:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010332a:	76 e1                	jbe    8010330d <freerange+0x18>
    kfree(p);
}
8010332c:	c9                   	leave  
8010332d:	c3                   	ret    

8010332e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010332e:	55                   	push   %ebp
8010332f:	89 e5                	mov    %esp,%ebp
80103331:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80103334:	8b 45 08             	mov    0x8(%ebp),%eax
80103337:	25 ff 0f 00 00       	and    $0xfff,%eax
8010333c:	85 c0                	test   %eax,%eax
8010333e:	75 1b                	jne    8010335b <kfree+0x2d>
80103340:	81 7d 08 5c 6e 11 80 	cmpl   $0x80116e5c,0x8(%ebp)
80103347:	72 12                	jb     8010335b <kfree+0x2d>
80103349:	8b 45 08             	mov    0x8(%ebp),%eax
8010334c:	89 04 24             	mov    %eax,(%esp)
8010334f:	e8 38 ff ff ff       	call   8010328c <v2p>
80103354:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103359:	76 0c                	jbe    80103367 <kfree+0x39>
    panic("kfree");
8010335b:	c7 04 24 63 93 10 80 	movl   $0x80109363,(%esp)
80103362:	e8 d6 d1 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103367:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010336e:	00 
8010336f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103376:	00 
80103377:	8b 45 08             	mov    0x8(%ebp),%eax
8010337a:	89 04 24             	mov    %eax,(%esp)
8010337d:	e8 30 29 00 00       	call   80105cb2 <memset>

  if(kmem.use_lock)
80103382:	a1 74 3a 11 80       	mov    0x80113a74,%eax
80103387:	85 c0                	test   %eax,%eax
80103389:	74 0c                	je     80103397 <kfree+0x69>
    acquire(&kmem.lock);
8010338b:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
80103392:	e8 cc 26 00 00       	call   80105a63 <acquire>
  r = (struct run*)v;
80103397:	8b 45 08             	mov    0x8(%ebp),%eax
8010339a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010339d:	8b 15 78 3a 11 80    	mov    0x80113a78,%edx
801033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a6:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801033a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ab:	a3 78 3a 11 80       	mov    %eax,0x80113a78
  if(kmem.use_lock)
801033b0:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801033b5:	85 c0                	test   %eax,%eax
801033b7:	74 0c                	je     801033c5 <kfree+0x97>
    release(&kmem.lock);
801033b9:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801033c0:	e8 00 27 00 00       	call   80105ac5 <release>
}
801033c5:	c9                   	leave  
801033c6:	c3                   	ret    

801033c7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801033c7:	55                   	push   %ebp
801033c8:	89 e5                	mov    %esp,%ebp
801033ca:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
801033cd:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801033d2:	85 c0                	test   %eax,%eax
801033d4:	74 0c                	je     801033e2 <kalloc+0x1b>
    acquire(&kmem.lock);
801033d6:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801033dd:	e8 81 26 00 00       	call   80105a63 <acquire>
  r = kmem.freelist;
801033e2:	a1 78 3a 11 80       	mov    0x80113a78,%eax
801033e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801033ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801033ee:	74 0a                	je     801033fa <kalloc+0x33>
    kmem.freelist = r->next;
801033f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033f3:	8b 00                	mov    (%eax),%eax
801033f5:	a3 78 3a 11 80       	mov    %eax,0x80113a78
  if(kmem.use_lock)
801033fa:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801033ff:	85 c0                	test   %eax,%eax
80103401:	74 0c                	je     8010340f <kalloc+0x48>
    release(&kmem.lock);
80103403:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
8010340a:	e8 b6 26 00 00       	call   80105ac5 <release>
  return (char*)r;
8010340f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103412:	c9                   	leave  
80103413:	c3                   	ret    

80103414 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103414:	55                   	push   %ebp
80103415:	89 e5                	mov    %esp,%ebp
80103417:	53                   	push   %ebx
80103418:	83 ec 14             	sub    $0x14,%esp
8010341b:	8b 45 08             	mov    0x8(%ebp),%eax
8010341e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103422:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103426:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010342a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010342e:	ec                   	in     (%dx),%al
8010342f:	89 c3                	mov    %eax,%ebx
80103431:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103434:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103438:	83 c4 14             	add    $0x14,%esp
8010343b:	5b                   	pop    %ebx
8010343c:	5d                   	pop    %ebp
8010343d:	c3                   	ret    

8010343e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010343e:	55                   	push   %ebp
8010343f:	89 e5                	mov    %esp,%ebp
80103441:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103444:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010344b:	e8 c4 ff ff ff       	call   80103414 <inb>
80103450:	0f b6 c0             	movzbl %al,%eax
80103453:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103459:	83 e0 01             	and    $0x1,%eax
8010345c:	85 c0                	test   %eax,%eax
8010345e:	75 0a                	jne    8010346a <kbdgetc+0x2c>
    return -1;
80103460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103465:	e9 23 01 00 00       	jmp    8010358d <kbdgetc+0x14f>
  data = inb(KBDATAP);
8010346a:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80103471:	e8 9e ff ff ff       	call   80103414 <inb>
80103476:	0f b6 c0             	movzbl %al,%eax
80103479:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010347c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103483:	75 17                	jne    8010349c <kbdgetc+0x5e>
    shift |= E0ESC;
80103485:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010348a:	83 c8 40             	or     $0x40,%eax
8010348d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103492:	b8 00 00 00 00       	mov    $0x0,%eax
80103497:	e9 f1 00 00 00       	jmp    8010358d <kbdgetc+0x14f>
  } else if(data & 0x80){
8010349c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010349f:	25 80 00 00 00       	and    $0x80,%eax
801034a4:	85 c0                	test   %eax,%eax
801034a6:	74 45                	je     801034ed <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801034a8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034ad:	83 e0 40             	and    $0x40,%eax
801034b0:	85 c0                	test   %eax,%eax
801034b2:	75 08                	jne    801034bc <kbdgetc+0x7e>
801034b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034b7:	83 e0 7f             	and    $0x7f,%eax
801034ba:	eb 03                	jmp    801034bf <kbdgetc+0x81>
801034bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801034c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034c5:	05 20 a0 10 80       	add    $0x8010a020,%eax
801034ca:	0f b6 00             	movzbl (%eax),%eax
801034cd:	83 c8 40             	or     $0x40,%eax
801034d0:	0f b6 c0             	movzbl %al,%eax
801034d3:	f7 d0                	not    %eax
801034d5:	89 c2                	mov    %eax,%edx
801034d7:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034dc:	21 d0                	and    %edx,%eax
801034de:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
801034e3:	b8 00 00 00 00       	mov    $0x0,%eax
801034e8:	e9 a0 00 00 00       	jmp    8010358d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
801034ed:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034f2:	83 e0 40             	and    $0x40,%eax
801034f5:	85 c0                	test   %eax,%eax
801034f7:	74 14                	je     8010350d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801034f9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103500:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103505:	83 e0 bf             	and    $0xffffffbf,%eax
80103508:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
8010350d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103510:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103515:	0f b6 00             	movzbl (%eax),%eax
80103518:	0f b6 d0             	movzbl %al,%edx
8010351b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103520:	09 d0                	or     %edx,%eax
80103522:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80103527:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010352a:	05 20 a1 10 80       	add    $0x8010a120,%eax
8010352f:	0f b6 00             	movzbl (%eax),%eax
80103532:	0f b6 d0             	movzbl %al,%edx
80103535:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010353a:	31 d0                	xor    %edx,%eax
8010353c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80103541:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103546:	83 e0 03             	and    $0x3,%eax
80103549:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80103550:	03 45 fc             	add    -0x4(%ebp),%eax
80103553:	0f b6 00             	movzbl (%eax),%eax
80103556:	0f b6 c0             	movzbl %al,%eax
80103559:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010355c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103561:	83 e0 08             	and    $0x8,%eax
80103564:	85 c0                	test   %eax,%eax
80103566:	74 22                	je     8010358a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80103568:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010356c:	76 0c                	jbe    8010357a <kbdgetc+0x13c>
8010356e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103572:	77 06                	ja     8010357a <kbdgetc+0x13c>
      c += 'A' - 'a';
80103574:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103578:	eb 10                	jmp    8010358a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
8010357a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010357e:	76 0a                	jbe    8010358a <kbdgetc+0x14c>
80103580:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103584:	77 04                	ja     8010358a <kbdgetc+0x14c>
      c += 'a' - 'A';
80103586:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010358a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010358d:	c9                   	leave  
8010358e:	c3                   	ret    

8010358f <kbdintr>:

void
kbdintr(void)
{
8010358f:	55                   	push   %ebp
80103590:	89 e5                	mov    %esp,%ebp
80103592:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103595:	c7 04 24 3e 34 10 80 	movl   $0x8010343e,(%esp)
8010359c:	e8 0d d6 ff ff       	call   80100bae <consoleintr>
}
801035a1:	c9                   	leave  
801035a2:	c3                   	ret    
	...

801035a4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801035a4:	55                   	push   %ebp
801035a5:	89 e5                	mov    %esp,%ebp
801035a7:	53                   	push   %ebx
801035a8:	83 ec 14             	sub    $0x14,%esp
801035ab:	8b 45 08             	mov    0x8(%ebp),%eax
801035ae:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801035b6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801035ba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801035be:	ec                   	in     (%dx),%al
801035bf:	89 c3                	mov    %eax,%ebx
801035c1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801035c4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801035c8:	83 c4 14             	add    $0x14,%esp
801035cb:	5b                   	pop    %ebx
801035cc:	5d                   	pop    %ebp
801035cd:	c3                   	ret    

801035ce <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 08             	sub    $0x8,%esp
801035d4:	8b 55 08             	mov    0x8(%ebp),%edx
801035d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801035da:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801035de:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035e1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801035e5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801035e9:	ee                   	out    %al,(%dx)
}
801035ea:	c9                   	leave  
801035eb:	c3                   	ret    

801035ec <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
801035ef:	53                   	push   %ebx
801035f0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035f3:	9c                   	pushf  
801035f4:	5b                   	pop    %ebx
801035f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
801035f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801035fb:	83 c4 10             	add    $0x10,%esp
801035fe:	5b                   	pop    %ebx
801035ff:	5d                   	pop    %ebp
80103600:	c3                   	ret    

80103601 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103601:	55                   	push   %ebp
80103602:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103604:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
80103609:	8b 55 08             	mov    0x8(%ebp),%edx
8010360c:	c1 e2 02             	shl    $0x2,%edx
8010360f:	01 c2                	add    %eax,%edx
80103611:	8b 45 0c             	mov    0xc(%ebp),%eax
80103614:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103616:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
8010361b:	83 c0 20             	add    $0x20,%eax
8010361e:	8b 00                	mov    (%eax),%eax
}
80103620:	5d                   	pop    %ebp
80103621:	c3                   	ret    

80103622 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80103622:	55                   	push   %ebp
80103623:	89 e5                	mov    %esp,%ebp
80103625:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103628:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
8010362d:	85 c0                	test   %eax,%eax
8010362f:	0f 84 47 01 00 00    	je     8010377c <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103635:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010363c:	00 
8010363d:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103644:	e8 b8 ff ff ff       	call   80103601 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103649:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103650:	00 
80103651:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103658:	e8 a4 ff ff ff       	call   80103601 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010365d:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103664:	00 
80103665:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010366c:	e8 90 ff ff ff       	call   80103601 <lapicw>
  lapicw(TICR, 10000000); 
80103671:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103678:	00 
80103679:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80103680:	e8 7c ff ff ff       	call   80103601 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103685:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010368c:	00 
8010368d:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103694:	e8 68 ff ff ff       	call   80103601 <lapicw>
  lapicw(LINT1, MASKED);
80103699:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801036a0:	00 
801036a1:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801036a8:	e8 54 ff ff ff       	call   80103601 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801036ad:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801036b2:	83 c0 30             	add    $0x30,%eax
801036b5:	8b 00                	mov    (%eax),%eax
801036b7:	c1 e8 10             	shr    $0x10,%eax
801036ba:	25 ff 00 00 00       	and    $0xff,%eax
801036bf:	83 f8 03             	cmp    $0x3,%eax
801036c2:	76 14                	jbe    801036d8 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801036c4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801036cb:	00 
801036cc:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801036d3:	e8 29 ff ff ff       	call   80103601 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801036d8:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801036df:	00 
801036e0:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801036e7:	e8 15 ff ff ff       	call   80103601 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801036ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801036f3:	00 
801036f4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801036fb:	e8 01 ff ff ff       	call   80103601 <lapicw>
  lapicw(ESR, 0);
80103700:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103707:	00 
80103708:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010370f:	e8 ed fe ff ff       	call   80103601 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103714:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010371b:	00 
8010371c:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103723:	e8 d9 fe ff ff       	call   80103601 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103728:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010372f:	00 
80103730:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103737:	e8 c5 fe ff ff       	call   80103601 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010373c:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103743:	00 
80103744:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010374b:	e8 b1 fe ff ff       	call   80103601 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103750:	90                   	nop
80103751:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
80103756:	05 00 03 00 00       	add    $0x300,%eax
8010375b:	8b 00                	mov    (%eax),%eax
8010375d:	25 00 10 00 00       	and    $0x1000,%eax
80103762:	85 c0                	test   %eax,%eax
80103764:	75 eb                	jne    80103751 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103766:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010376d:	00 
8010376e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103775:	e8 87 fe ff ff       	call   80103601 <lapicw>
8010377a:	eb 01                	jmp    8010377d <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010377c:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010377d:	c9                   	leave  
8010377e:	c3                   	ret    

8010377f <cpunum>:

int
cpunum(void)
{
8010377f:	55                   	push   %ebp
80103780:	89 e5                	mov    %esp,%ebp
80103782:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103785:	e8 62 fe ff ff       	call   801035ec <readeflags>
8010378a:	25 00 02 00 00       	and    $0x200,%eax
8010378f:	85 c0                	test   %eax,%eax
80103791:	74 29                	je     801037bc <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80103793:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80103798:	85 c0                	test   %eax,%eax
8010379a:	0f 94 c2             	sete   %dl
8010379d:	83 c0 01             	add    $0x1,%eax
801037a0:	a3 40 c6 10 80       	mov    %eax,0x8010c640
801037a5:	84 d2                	test   %dl,%dl
801037a7:	74 13                	je     801037bc <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801037a9:	8b 45 04             	mov    0x4(%ebp),%eax
801037ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b0:	c7 04 24 6c 93 10 80 	movl   $0x8010936c,(%esp)
801037b7:	e8 e5 cb ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801037bc:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801037c1:	85 c0                	test   %eax,%eax
801037c3:	74 0f                	je     801037d4 <cpunum+0x55>
    return lapic[ID]>>24;
801037c5:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801037ca:	83 c0 20             	add    $0x20,%eax
801037cd:	8b 00                	mov    (%eax),%eax
801037cf:	c1 e8 18             	shr    $0x18,%eax
801037d2:	eb 05                	jmp    801037d9 <cpunum+0x5a>
  return 0;
801037d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801037d9:	c9                   	leave  
801037da:	c3                   	ret    

801037db <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801037db:	55                   	push   %ebp
801037dc:	89 e5                	mov    %esp,%ebp
801037de:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801037e1:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801037e6:	85 c0                	test   %eax,%eax
801037e8:	74 14                	je     801037fe <lapiceoi+0x23>
    lapicw(EOI, 0);
801037ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801037f1:	00 
801037f2:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801037f9:	e8 03 fe ff ff       	call   80103601 <lapicw>
}
801037fe:	c9                   	leave  
801037ff:	c3                   	ret    

80103800 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103800:	55                   	push   %ebp
80103801:	89 e5                	mov    %esp,%ebp
}
80103803:	5d                   	pop    %ebp
80103804:	c3                   	ret    

80103805 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103805:	55                   	push   %ebp
80103806:	89 e5                	mov    %esp,%ebp
80103808:	83 ec 1c             	sub    $0x1c,%esp
8010380b:	8b 45 08             	mov    0x8(%ebp),%eax
8010380e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103811:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103818:	00 
80103819:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103820:	e8 a9 fd ff ff       	call   801035ce <outb>
  outb(CMOS_PORT+1, 0x0A);
80103825:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010382c:	00 
8010382d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103834:	e8 95 fd ff ff       	call   801035ce <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103839:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103840:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103843:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103848:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010384b:	8d 50 02             	lea    0x2(%eax),%edx
8010384e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103851:	c1 e8 04             	shr    $0x4,%eax
80103854:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103857:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010385b:	c1 e0 18             	shl    $0x18,%eax
8010385e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103862:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103869:	e8 93 fd ff ff       	call   80103601 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010386e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103875:	00 
80103876:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010387d:	e8 7f fd ff ff       	call   80103601 <lapicw>
  microdelay(200);
80103882:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103889:	e8 72 ff ff ff       	call   80103800 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010388e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103895:	00 
80103896:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010389d:	e8 5f fd ff ff       	call   80103601 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038a2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801038a9:	e8 52 ff ff ff       	call   80103800 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038b5:	eb 40                	jmp    801038f7 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801038b7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038bb:	c1 e0 18             	shl    $0x18,%eax
801038be:	89 44 24 04          	mov    %eax,0x4(%esp)
801038c2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801038c9:	e8 33 fd ff ff       	call   80103601 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801038ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801038d1:	c1 e8 0c             	shr    $0xc,%eax
801038d4:	80 cc 06             	or     $0x6,%ah
801038d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801038db:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801038e2:	e8 1a fd ff ff       	call   80103601 <lapicw>
    microdelay(200);
801038e7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801038ee:	e8 0d ff ff ff       	call   80103800 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801038f7:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801038fb:	7e ba                	jle    801038b7 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801038fd:	c9                   	leave  
801038fe:	c3                   	ret    

801038ff <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801038ff:	55                   	push   %ebp
80103900:	89 e5                	mov    %esp,%ebp
80103902:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103905:	8b 45 08             	mov    0x8(%ebp),%eax
80103908:	0f b6 c0             	movzbl %al,%eax
8010390b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010390f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103916:	e8 b3 fc ff ff       	call   801035ce <outb>
  microdelay(200);
8010391b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103922:	e8 d9 fe ff ff       	call   80103800 <microdelay>

  return inb(CMOS_RETURN);
80103927:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010392e:	e8 71 fc ff ff       	call   801035a4 <inb>
80103933:	0f b6 c0             	movzbl %al,%eax
}
80103936:	c9                   	leave  
80103937:	c3                   	ret    

80103938 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103938:	55                   	push   %ebp
80103939:	89 e5                	mov    %esp,%ebp
8010393b:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010393e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103945:	e8 b5 ff ff ff       	call   801038ff <cmos_read>
8010394a:	8b 55 08             	mov    0x8(%ebp),%edx
8010394d:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010394f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103956:	e8 a4 ff ff ff       	call   801038ff <cmos_read>
8010395b:	8b 55 08             	mov    0x8(%ebp),%edx
8010395e:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103961:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103968:	e8 92 ff ff ff       	call   801038ff <cmos_read>
8010396d:	8b 55 08             	mov    0x8(%ebp),%edx
80103970:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103973:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010397a:	e8 80 ff ff ff       	call   801038ff <cmos_read>
8010397f:	8b 55 08             	mov    0x8(%ebp),%edx
80103982:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103985:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010398c:	e8 6e ff ff ff       	call   801038ff <cmos_read>
80103991:	8b 55 08             	mov    0x8(%ebp),%edx
80103994:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103997:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010399e:	e8 5c ff ff ff       	call   801038ff <cmos_read>
801039a3:	8b 55 08             	mov    0x8(%ebp),%edx
801039a6:	89 42 14             	mov    %eax,0x14(%edx)
}
801039a9:	c9                   	leave  
801039aa:	c3                   	ret    

801039ab <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039ab:	55                   	push   %ebp
801039ac:	89 e5                	mov    %esp,%ebp
801039ae:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039b1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801039b8:	e8 42 ff ff ff       	call   801038ff <cmos_read>
801039bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c3:	83 e0 04             	and    $0x4,%eax
801039c6:	85 c0                	test   %eax,%eax
801039c8:	0f 94 c0             	sete   %al
801039cb:	0f b6 c0             	movzbl %al,%eax
801039ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
801039d1:	eb 01                	jmp    801039d4 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801039d3:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039d4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039d7:	89 04 24             	mov    %eax,(%esp)
801039da:	e8 59 ff ff ff       	call   80103938 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801039df:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801039e6:	e8 14 ff ff ff       	call   801038ff <cmos_read>
801039eb:	25 80 00 00 00       	and    $0x80,%eax
801039f0:	85 c0                	test   %eax,%eax
801039f2:	75 2b                	jne    80103a1f <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
801039f4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801039f7:	89 04 24             	mov    %eax,(%esp)
801039fa:	e8 39 ff ff ff       	call   80103938 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801039ff:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103a06:	00 
80103a07:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a11:	89 04 24             	mov    %eax,(%esp)
80103a14:	e8 10 23 00 00       	call   80105d29 <memcmp>
80103a19:	85 c0                	test   %eax,%eax
80103a1b:	75 b6                	jne    801039d3 <cmostime+0x28>
      break;
80103a1d:	eb 03                	jmp    80103a22 <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a1f:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a20:	eb b1                	jmp    801039d3 <cmostime+0x28>

  // convert
  if (bcd) {
80103a22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a26:	0f 84 a8 00 00 00    	je     80103ad4 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a2c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a2f:	89 c2                	mov    %eax,%edx
80103a31:	c1 ea 04             	shr    $0x4,%edx
80103a34:	89 d0                	mov    %edx,%eax
80103a36:	c1 e0 02             	shl    $0x2,%eax
80103a39:	01 d0                	add    %edx,%eax
80103a3b:	01 c0                	add    %eax,%eax
80103a3d:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103a40:	83 e2 0f             	and    $0xf,%edx
80103a43:	01 d0                	add    %edx,%eax
80103a45:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a48:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a4b:	89 c2                	mov    %eax,%edx
80103a4d:	c1 ea 04             	shr    $0x4,%edx
80103a50:	89 d0                	mov    %edx,%eax
80103a52:	c1 e0 02             	shl    $0x2,%eax
80103a55:	01 d0                	add    %edx,%eax
80103a57:	01 c0                	add    %eax,%eax
80103a59:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103a5c:	83 e2 0f             	and    $0xf,%edx
80103a5f:	01 d0                	add    %edx,%eax
80103a61:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a67:	89 c2                	mov    %eax,%edx
80103a69:	c1 ea 04             	shr    $0x4,%edx
80103a6c:	89 d0                	mov    %edx,%eax
80103a6e:	c1 e0 02             	shl    $0x2,%eax
80103a71:	01 d0                	add    %edx,%eax
80103a73:	01 c0                	add    %eax,%eax
80103a75:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103a78:	83 e2 0f             	and    $0xf,%edx
80103a7b:	01 d0                	add    %edx,%eax
80103a7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103a80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a83:	89 c2                	mov    %eax,%edx
80103a85:	c1 ea 04             	shr    $0x4,%edx
80103a88:	89 d0                	mov    %edx,%eax
80103a8a:	c1 e0 02             	shl    $0x2,%eax
80103a8d:	01 d0                	add    %edx,%eax
80103a8f:	01 c0                	add    %eax,%eax
80103a91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103a94:	83 e2 0f             	and    $0xf,%edx
80103a97:	01 d0                	add    %edx,%eax
80103a99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a9f:	89 c2                	mov    %eax,%edx
80103aa1:	c1 ea 04             	shr    $0x4,%edx
80103aa4:	89 d0                	mov    %edx,%eax
80103aa6:	c1 e0 02             	shl    $0x2,%eax
80103aa9:	01 d0                	add    %edx,%eax
80103aab:	01 c0                	add    %eax,%eax
80103aad:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103ab0:	83 e2 0f             	and    $0xf,%edx
80103ab3:	01 d0                	add    %edx,%eax
80103ab5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103ab8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103abb:	89 c2                	mov    %eax,%edx
80103abd:	c1 ea 04             	shr    $0x4,%edx
80103ac0:	89 d0                	mov    %edx,%eax
80103ac2:	c1 e0 02             	shl    $0x2,%eax
80103ac5:	01 d0                	add    %edx,%eax
80103ac7:	01 c0                	add    %eax,%eax
80103ac9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103acc:	83 e2 0f             	and    $0xf,%edx
80103acf:	01 d0                	add    %edx,%eax
80103ad1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103ada:	89 10                	mov    %edx,(%eax)
80103adc:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103adf:	89 50 04             	mov    %edx,0x4(%eax)
80103ae2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103ae5:	89 50 08             	mov    %edx,0x8(%eax)
80103ae8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103aeb:	89 50 0c             	mov    %edx,0xc(%eax)
80103aee:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103af1:	89 50 10             	mov    %edx,0x10(%eax)
80103af4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103af7:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103afa:	8b 45 08             	mov    0x8(%ebp),%eax
80103afd:	8b 40 14             	mov    0x14(%eax),%eax
80103b00:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b06:	8b 45 08             	mov    0x8(%ebp),%eax
80103b09:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b0c:	c9                   	leave  
80103b0d:	c3                   	ret    
	...

80103b10 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
80103b13:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103b16:	c7 44 24 04 98 93 10 	movl   $0x80109398,0x4(%esp)
80103b1d:	80 
80103b1e:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103b25:	e8 18 1f 00 00       	call   80105a42 <initlock>
  readsb(dev, &sb);
80103b2a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b31:	8b 45 08             	mov    0x8(%ebp),%eax
80103b34:	89 04 24             	mov    %eax,(%esp)
80103b37:	e8 dc df ff ff       	call   80101b18 <readsb>
  log.start = sb.logstart;
80103b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b3f:	a3 b4 3a 11 80       	mov    %eax,0x80113ab4
  log.size = sb.nlog;
80103b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b47:	a3 b8 3a 11 80       	mov    %eax,0x80113ab8
  log.dev = dev;
80103b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b4f:	a3 c4 3a 11 80       	mov    %eax,0x80113ac4
  recover_from_log();
80103b54:	e8 97 01 00 00       	call   80103cf0 <recover_from_log>
}
80103b59:	c9                   	leave  
80103b5a:	c3                   	ret    

80103b5b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103b5b:	55                   	push   %ebp
80103b5c:	89 e5                	mov    %esp,%ebp
80103b5e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b68:	e9 89 00 00 00       	jmp    80103bf6 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103b6d:	a1 b4 3a 11 80       	mov    0x80113ab4,%eax
80103b72:	03 45 f4             	add    -0xc(%ebp),%eax
80103b75:	83 c0 01             	add    $0x1,%eax
80103b78:	89 c2                	mov    %eax,%edx
80103b7a:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b83:	89 04 24             	mov    %eax,(%esp)
80103b86:	e8 1b c6 ff ff       	call   801001a6 <bread>
80103b8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b91:	83 c0 10             	add    $0x10,%eax
80103b94:	8b 04 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%eax
80103b9b:	89 c2                	mov    %eax,%edx
80103b9d:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103ba2:	89 54 24 04          	mov    %edx,0x4(%esp)
80103ba6:	89 04 24             	mov    %eax,(%esp)
80103ba9:	e8 f8 c5 ff ff       	call   801001a6 <bread>
80103bae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb4:	8d 50 18             	lea    0x18(%eax),%edx
80103bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bba:	83 c0 18             	add    $0x18,%eax
80103bbd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103bc4:	00 
80103bc5:	89 54 24 04          	mov    %edx,0x4(%esp)
80103bc9:	89 04 24             	mov    %eax,(%esp)
80103bcc:	e8 b4 21 00 00       	call   80105d85 <memmove>
    bwrite(dbuf);  // write dst to disk
80103bd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd4:	89 04 24             	mov    %eax,(%esp)
80103bd7:	e8 01 c6 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdf:	89 04 24             	mov    %eax,(%esp)
80103be2:	e8 30 c6 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bea:	89 04 24             	mov    %eax,(%esp)
80103bed:	e8 25 c6 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103bf2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bf6:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103bfb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bfe:	0f 8f 69 ff ff ff    	jg     80103b6d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103c04:	c9                   	leave  
80103c05:	c3                   	ret    

80103c06 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103c06:	55                   	push   %ebp
80103c07:	89 e5                	mov    %esp,%ebp
80103c09:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103c0c:	a1 b4 3a 11 80       	mov    0x80113ab4,%eax
80103c11:	89 c2                	mov    %eax,%edx
80103c13:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103c18:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c1c:	89 04 24             	mov    %eax,(%esp)
80103c1f:	e8 82 c5 ff ff       	call   801001a6 <bread>
80103c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2a:	83 c0 18             	add    $0x18,%eax
80103c2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103c30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c33:	8b 00                	mov    (%eax),%eax
80103c35:	a3 c8 3a 11 80       	mov    %eax,0x80113ac8
  for (i = 0; i < log.lh.n; i++) {
80103c3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c41:	eb 1b                	jmp    80103c5e <read_head+0x58>
    log.lh.block[i] = lh->block[i];
80103c43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c49:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c50:	83 c2 10             	add    $0x10,%edx
80103c53:	89 04 95 8c 3a 11 80 	mov    %eax,-0x7feec574(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103c5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c5e:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103c63:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c66:	7f db                	jg     80103c43 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6b:	89 04 24             	mov    %eax,(%esp)
80103c6e:	e8 a4 c5 ff ff       	call   80100217 <brelse>
}
80103c73:	c9                   	leave  
80103c74:	c3                   	ret    

80103c75 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103c75:	55                   	push   %ebp
80103c76:	89 e5                	mov    %esp,%ebp
80103c78:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103c7b:	a1 b4 3a 11 80       	mov    0x80113ab4,%eax
80103c80:	89 c2                	mov    %eax,%edx
80103c82:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103c87:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c8b:	89 04 24             	mov    %eax,(%esp)
80103c8e:	e8 13 c5 ff ff       	call   801001a6 <bread>
80103c93:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c99:	83 c0 18             	add    $0x18,%eax
80103c9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103c9f:	8b 15 c8 3a 11 80    	mov    0x80113ac8,%edx
80103ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ca8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103caa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103cb1:	eb 1b                	jmp    80103cce <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	83 c0 10             	add    $0x10,%eax
80103cb9:	8b 0c 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%ecx
80103cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cc6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103cca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cce:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103cd3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cd6:	7f db                	jg     80103cb3 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdb:	89 04 24             	mov    %eax,(%esp)
80103cde:	e8 fa c4 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce6:	89 04 24             	mov    %eax,(%esp)
80103ce9:	e8 29 c5 ff ff       	call   80100217 <brelse>
}
80103cee:	c9                   	leave  
80103cef:	c3                   	ret    

80103cf0 <recover_from_log>:

static void
recover_from_log(void)
{
80103cf0:	55                   	push   %ebp
80103cf1:	89 e5                	mov    %esp,%ebp
80103cf3:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103cf6:	e8 0b ff ff ff       	call   80103c06 <read_head>
  install_trans(); // if committed, copy from log to disk
80103cfb:	e8 5b fe ff ff       	call   80103b5b <install_trans>
  log.lh.n = 0;
80103d00:	c7 05 c8 3a 11 80 00 	movl   $0x0,0x80113ac8
80103d07:	00 00 00 
  write_head(); // clear the log
80103d0a:	e8 66 ff ff ff       	call   80103c75 <write_head>
}
80103d0f:	c9                   	leave  
80103d10:	c3                   	ret    

80103d11 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103d11:	55                   	push   %ebp
80103d12:	89 e5                	mov    %esp,%ebp
80103d14:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103d17:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d1e:	e8 40 1d 00 00       	call   80105a63 <acquire>
  while(1){
    if(log.committing){
80103d23:	a1 c0 3a 11 80       	mov    0x80113ac0,%eax
80103d28:	85 c0                	test   %eax,%eax
80103d2a:	74 16                	je     80103d42 <begin_op+0x31>
      sleep(&log, &log.lock);
80103d2c:	c7 44 24 04 80 3a 11 	movl   $0x80113a80,0x4(%esp)
80103d33:	80 
80103d34:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d3b:	e8 31 19 00 00       	call   80105671 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103d40:	eb e1                	jmp    80103d23 <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103d42:	8b 0d c8 3a 11 80    	mov    0x80113ac8,%ecx
80103d48:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103d4d:	8d 50 01             	lea    0x1(%eax),%edx
80103d50:	89 d0                	mov    %edx,%eax
80103d52:	c1 e0 02             	shl    $0x2,%eax
80103d55:	01 d0                	add    %edx,%eax
80103d57:	01 c0                	add    %eax,%eax
80103d59:	01 c8                	add    %ecx,%eax
80103d5b:	83 f8 1e             	cmp    $0x1e,%eax
80103d5e:	7e 16                	jle    80103d76 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103d60:	c7 44 24 04 80 3a 11 	movl   $0x80113a80,0x4(%esp)
80103d67:	80 
80103d68:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d6f:	e8 fd 18 00 00       	call   80105671 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103d74:	eb ad                	jmp    80103d23 <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80103d76:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103d7b:	83 c0 01             	add    $0x1,%eax
80103d7e:	a3 bc 3a 11 80       	mov    %eax,0x80113abc
      release(&log.lock);
80103d83:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d8a:	e8 36 1d 00 00       	call   80105ac5 <release>
      break;
80103d8f:	90                   	nop
    }
  }
}
80103d90:	c9                   	leave  
80103d91:	c3                   	ret    

80103d92 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103d92:	55                   	push   %ebp
80103d93:	89 e5                	mov    %esp,%ebp
80103d95:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103d98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103d9f:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103da6:	e8 b8 1c 00 00       	call   80105a63 <acquire>
  log.outstanding -= 1;
80103dab:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103db0:	83 e8 01             	sub    $0x1,%eax
80103db3:	a3 bc 3a 11 80       	mov    %eax,0x80113abc
  if(log.committing)
80103db8:	a1 c0 3a 11 80       	mov    0x80113ac0,%eax
80103dbd:	85 c0                	test   %eax,%eax
80103dbf:	74 0c                	je     80103dcd <end_op+0x3b>
    panic("log.committing");
80103dc1:	c7 04 24 9c 93 10 80 	movl   $0x8010939c,(%esp)
80103dc8:	e8 70 c7 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
80103dcd:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	75 13                	jne    80103de9 <end_op+0x57>
    do_commit = 1;
80103dd6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103ddd:	c7 05 c0 3a 11 80 01 	movl   $0x1,0x80113ac0
80103de4:	00 00 00 
80103de7:	eb 0c                	jmp    80103df5 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103de9:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103df0:	e8 58 19 00 00       	call   8010574d <wakeup>
  }
  release(&log.lock);
80103df5:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103dfc:	e8 c4 1c 00 00       	call   80105ac5 <release>

  if(do_commit){
80103e01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e05:	74 33                	je     80103e3a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103e07:	e8 db 00 00 00       	call   80103ee7 <commit>
    acquire(&log.lock);
80103e0c:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103e13:	e8 4b 1c 00 00       	call   80105a63 <acquire>
    log.committing = 0;
80103e18:	c7 05 c0 3a 11 80 00 	movl   $0x0,0x80113ac0
80103e1f:	00 00 00 
    wakeup(&log);
80103e22:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103e29:	e8 1f 19 00 00       	call   8010574d <wakeup>
    release(&log.lock);
80103e2e:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103e35:	e8 8b 1c 00 00       	call   80105ac5 <release>
  }
}
80103e3a:	c9                   	leave  
80103e3b:	c3                   	ret    

80103e3c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103e3c:	55                   	push   %ebp
80103e3d:	89 e5                	mov    %esp,%ebp
80103e3f:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e49:	e9 89 00 00 00       	jmp    80103ed7 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103e4e:	a1 b4 3a 11 80       	mov    0x80113ab4,%eax
80103e53:	03 45 f4             	add    -0xc(%ebp),%eax
80103e56:	83 c0 01             	add    $0x1,%eax
80103e59:	89 c2                	mov    %eax,%edx
80103e5b:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103e60:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e64:	89 04 24             	mov    %eax,(%esp)
80103e67:	e8 3a c3 ff ff       	call   801001a6 <bread>
80103e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e72:	83 c0 10             	add    $0x10,%eax
80103e75:	8b 04 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%eax
80103e7c:	89 c2                	mov    %eax,%edx
80103e7e:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103e83:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e87:	89 04 24             	mov    %eax,(%esp)
80103e8a:	e8 17 c3 ff ff       	call   801001a6 <bread>
80103e8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103e92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e95:	8d 50 18             	lea    0x18(%eax),%edx
80103e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e9b:	83 c0 18             	add    $0x18,%eax
80103e9e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103ea5:	00 
80103ea6:	89 54 24 04          	mov    %edx,0x4(%esp)
80103eaa:	89 04 24             	mov    %eax,(%esp)
80103ead:	e8 d3 1e 00 00       	call   80105d85 <memmove>
    bwrite(to);  // write the log
80103eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb5:	89 04 24             	mov    %eax,(%esp)
80103eb8:	e8 20 c3 ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103ebd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ec0:	89 04 24             	mov    %eax,(%esp)
80103ec3:	e8 4f c3 ff ff       	call   80100217 <brelse>
    brelse(to);
80103ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ecb:	89 04 24             	mov    %eax,(%esp)
80103ece:	e8 44 c3 ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103ed3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ed7:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103edc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103edf:	0f 8f 69 ff ff ff    	jg     80103e4e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103ee5:	c9                   	leave  
80103ee6:	c3                   	ret    

80103ee7 <commit>:

static void
commit()
{
80103ee7:	55                   	push   %ebp
80103ee8:	89 e5                	mov    %esp,%ebp
80103eea:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103eed:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103ef2:	85 c0                	test   %eax,%eax
80103ef4:	7e 1e                	jle    80103f14 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103ef6:	e8 41 ff ff ff       	call   80103e3c <write_log>
    write_head();    // Write header to disk -- the real commit
80103efb:	e8 75 fd ff ff       	call   80103c75 <write_head>
    install_trans(); // Now install writes to home locations
80103f00:	e8 56 fc ff ff       	call   80103b5b <install_trans>
    log.lh.n = 0; 
80103f05:	c7 05 c8 3a 11 80 00 	movl   $0x0,0x80113ac8
80103f0c:	00 00 00 
    write_head();    // Erase the transaction from the log
80103f0f:	e8 61 fd ff ff       	call   80103c75 <write_head>
  }
}
80103f14:	c9                   	leave  
80103f15:	c3                   	ret    

80103f16 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103f16:	55                   	push   %ebp
80103f17:	89 e5                	mov    %esp,%ebp
80103f19:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103f1c:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103f21:	83 f8 1d             	cmp    $0x1d,%eax
80103f24:	7f 12                	jg     80103f38 <log_write+0x22>
80103f26:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103f2b:	8b 15 b8 3a 11 80    	mov    0x80113ab8,%edx
80103f31:	83 ea 01             	sub    $0x1,%edx
80103f34:	39 d0                	cmp    %edx,%eax
80103f36:	7c 0c                	jl     80103f44 <log_write+0x2e>
    panic("too big a transaction");
80103f38:	c7 04 24 ab 93 10 80 	movl   $0x801093ab,(%esp)
80103f3f:	e8 f9 c5 ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103f44:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103f49:	85 c0                	test   %eax,%eax
80103f4b:	7f 0c                	jg     80103f59 <log_write+0x43>
    panic("log_write outside of trans");
80103f4d:	c7 04 24 c1 93 10 80 	movl   $0x801093c1,(%esp)
80103f54:	e8 e4 c5 ff ff       	call   8010053d <panic>

  acquire(&log.lock);
80103f59:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103f60:	e8 fe 1a 00 00       	call   80105a63 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103f65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f6c:	eb 1d                	jmp    80103f8b <log_write+0x75>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f71:	83 c0 10             	add    $0x10,%eax
80103f74:	8b 04 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%eax
80103f7b:	89 c2                	mov    %eax,%edx
80103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f80:	8b 40 08             	mov    0x8(%eax),%eax
80103f83:	39 c2                	cmp    %eax,%edx
80103f85:	74 10                	je     80103f97 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103f87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f8b:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103f90:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f93:	7f d9                	jg     80103f6e <log_write+0x58>
80103f95:	eb 01                	jmp    80103f98 <log_write+0x82>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103f97:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103f98:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9b:	8b 40 08             	mov    0x8(%eax),%eax
80103f9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa1:	83 c2 10             	add    $0x10,%edx
80103fa4:	89 04 95 8c 3a 11 80 	mov    %eax,-0x7feec574(,%edx,4)
  if (i == log.lh.n)
80103fab:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103fb0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103fb3:	75 0d                	jne    80103fc2 <log_write+0xac>
    log.lh.n++;
80103fb5:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103fba:	83 c0 01             	add    $0x1,%eax
80103fbd:	a3 c8 3a 11 80       	mov    %eax,0x80113ac8
  b->flags |= B_DIRTY; // prevent eviction
80103fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc5:	8b 00                	mov    (%eax),%eax
80103fc7:	89 c2                	mov    %eax,%edx
80103fc9:	83 ca 04             	or     $0x4,%edx
80103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcf:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103fd1:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103fd8:	e8 e8 1a 00 00       	call   80105ac5 <release>
}
80103fdd:	c9                   	leave  
80103fde:	c3                   	ret    
	...

80103fe0 <v2p>:
80103fe0:	55                   	push   %ebp
80103fe1:	89 e5                	mov    %esp,%ebp
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	05 00 00 00 80       	add    $0x80000000,%eax
80103feb:	5d                   	pop    %ebp
80103fec:	c3                   	ret    

80103fed <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103fed:	55                   	push   %ebp
80103fee:	89 e5                	mov    %esp,%ebp
80103ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff3:	05 00 00 00 80       	add    $0x80000000,%eax
80103ff8:	5d                   	pop    %ebp
80103ff9:	c3                   	ret    

80103ffa <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103ffa:	55                   	push   %ebp
80103ffb:	89 e5                	mov    %esp,%ebp
80103ffd:	53                   	push   %ebx
80103ffe:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104001:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104004:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104007:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010400a:	89 c3                	mov    %eax,%ebx
8010400c:	89 d8                	mov    %ebx,%eax
8010400e:	f0 87 02             	lock xchg %eax,(%edx)
80104011:	89 c3                	mov    %eax,%ebx
80104013:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104016:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104019:	83 c4 10             	add    $0x10,%esp
8010401c:	5b                   	pop    %ebx
8010401d:	5d                   	pop    %ebp
8010401e:	c3                   	ret    

8010401f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010401f:	55                   	push   %ebp
80104020:	89 e5                	mov    %esp,%ebp
80104022:	83 e4 f0             	and    $0xfffffff0,%esp
80104025:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80104028:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010402f:	80 
80104030:	c7 04 24 5c 6e 11 80 	movl   $0x80116e5c,(%esp)
80104037:	e8 5d f2 ff ff       	call   80103299 <kinit1>
  kvmalloc();      // kernel page table
8010403c:	e8 39 49 00 00       	call   8010897a <kvmalloc>
  mpinit();        // collect info about this machine
80104041:	e8 4f 04 00 00       	call   80104495 <mpinit>
  lapicinit();
80104046:	e8 d7 f5 ff ff       	call   80103622 <lapicinit>
  seginit();       // set up segments
8010404b:	e8 cd 42 00 00       	call   8010831d <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80104050:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104056:	0f b6 00             	movzbl (%eax),%eax
80104059:	0f b6 c0             	movzbl %al,%eax
8010405c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104060:	c7 04 24 dc 93 10 80 	movl   $0x801093dc,(%esp)
80104067:	e8 35 c3 ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010406c:	e8 89 06 00 00       	call   801046fa <picinit>
  ioapicinit();    // another interrupt controller
80104071:	e8 13 f1 ff ff       	call   80103189 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104076:	e8 31 d2 ff ff       	call   801012ac <consoleinit>
  uartinit();      // serial port
8010407b:	e8 e8 35 00 00       	call   80107668 <uartinit>
  pinit();         // process table
80104080:	e8 8a 0b 00 00       	call   80104c0f <pinit>
  tvinit();        // trap vectors
80104085:	e8 59 31 00 00       	call   801071e3 <tvinit>
  binit();         // buffer cache
8010408a:	e8 a5 bf ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010408f:	e8 98 d6 ff ff       	call   8010172c <fileinit>
  ideinit();       // disk
80104094:	e8 21 ed ff ff       	call   80102dba <ideinit>
  if(!ismp)
80104099:	a1 64 3b 11 80       	mov    0x80113b64,%eax
8010409e:	85 c0                	test   %eax,%eax
801040a0:	75 05                	jne    801040a7 <main+0x88>
    timerinit();   // uniprocessor timer
801040a2:	e8 7f 30 00 00       	call   80107126 <timerinit>
  startothers();   // start other processors
801040a7:	e8 7f 00 00 00       	call   8010412b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801040ac:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801040b3:	8e 
801040b4:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801040bb:	e8 11 f2 ff ff       	call   801032d1 <kinit2>
  userinit();      // first user process
801040c0:	e8 75 0c 00 00       	call   80104d3a <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801040c5:	e8 1a 00 00 00       	call   801040e4 <mpmain>

801040ca <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801040ca:	55                   	push   %ebp
801040cb:	89 e5                	mov    %esp,%ebp
801040cd:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801040d0:	e8 bc 48 00 00       	call   80108991 <switchkvm>
  seginit();
801040d5:	e8 43 42 00 00       	call   8010831d <seginit>
  lapicinit();
801040da:	e8 43 f5 ff ff       	call   80103622 <lapicinit>
  mpmain();
801040df:	e8 00 00 00 00       	call   801040e4 <mpmain>

801040e4 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801040e4:	55                   	push   %ebp
801040e5:	89 e5                	mov    %esp,%ebp
801040e7:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801040ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801040f0:	0f b6 00             	movzbl (%eax),%eax
801040f3:	0f b6 c0             	movzbl %al,%eax
801040f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801040fa:	c7 04 24 f3 93 10 80 	movl   $0x801093f3,(%esp)
80104101:	e8 9b c2 ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80104106:	e8 4c 32 00 00       	call   80107357 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010410b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104111:	05 a8 00 00 00       	add    $0xa8,%eax
80104116:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010411d:	00 
8010411e:	89 04 24             	mov    %eax,(%esp)
80104121:	e8 d4 fe ff ff       	call   80103ffa <xchg>
  scheduler();     // start running processes
80104126:	e8 18 14 00 00       	call   80105543 <scheduler>

8010412b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010412b:	55                   	push   %ebp
8010412c:	89 e5                	mov    %esp,%ebp
8010412e:	53                   	push   %ebx
8010412f:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80104132:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80104139:	e8 af fe ff ff       	call   80103fed <p2v>
8010413e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80104141:	b8 8a 00 00 00       	mov    $0x8a,%eax
80104146:	89 44 24 08          	mov    %eax,0x8(%esp)
8010414a:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
80104151:	80 
80104152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104155:	89 04 24             	mov    %eax,(%esp)
80104158:	e8 28 1c 00 00       	call   80105d85 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010415d:	c7 45 f4 80 3b 11 80 	movl   $0x80113b80,-0xc(%ebp)
80104164:	e9 86 00 00 00       	jmp    801041ef <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80104169:	e8 11 f6 ff ff       	call   8010377f <cpunum>
8010416e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104174:	05 80 3b 11 80       	add    $0x80113b80,%eax
80104179:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010417c:	74 69                	je     801041e7 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010417e:	e8 44 f2 ff ff       	call   801033c7 <kalloc>
80104183:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104189:	83 e8 04             	sub    $0x4,%eax
8010418c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010418f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104195:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104197:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419a:	83 e8 08             	sub    $0x8,%eax
8010419d:	c7 00 ca 40 10 80    	movl   $0x801040ca,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801041a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a6:	8d 58 f4             	lea    -0xc(%eax),%ebx
801041a9:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
801041b0:	e8 2b fe ff ff       	call   80103fe0 <v2p>
801041b5:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801041b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041ba:	89 04 24             	mov    %eax,(%esp)
801041bd:	e8 1e fe ff ff       	call   80103fe0 <v2p>
801041c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c5:	0f b6 12             	movzbl (%edx),%edx
801041c8:	0f b6 d2             	movzbl %dl,%edx
801041cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801041cf:	89 14 24             	mov    %edx,(%esp)
801041d2:	e8 2e f6 ff ff       	call   80103805 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801041d7:	90                   	nop
801041d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041db:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801041e1:	85 c0                	test   %eax,%eax
801041e3:	74 f3                	je     801041d8 <startothers+0xad>
801041e5:	eb 01                	jmp    801041e8 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801041e7:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801041e8:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801041ef:	a1 60 41 11 80       	mov    0x80114160,%eax
801041f4:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041fa:	05 80 3b 11 80       	add    $0x80113b80,%eax
801041ff:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104202:	0f 87 61 ff ff ff    	ja     80104169 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80104208:	83 c4 24             	add    $0x24,%esp
8010420b:	5b                   	pop    %ebx
8010420c:	5d                   	pop    %ebp
8010420d:	c3                   	ret    
	...

80104210 <p2v>:
80104210:	55                   	push   %ebp
80104211:	89 e5                	mov    %esp,%ebp
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	05 00 00 00 80       	add    $0x80000000,%eax
8010421b:	5d                   	pop    %ebp
8010421c:	c3                   	ret    

8010421d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010421d:	55                   	push   %ebp
8010421e:	89 e5                	mov    %esp,%ebp
80104220:	53                   	push   %ebx
80104221:	83 ec 14             	sub    $0x14,%esp
80104224:	8b 45 08             	mov    0x8(%ebp),%eax
80104227:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010422b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010422f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80104233:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80104237:	ec                   	in     (%dx),%al
80104238:	89 c3                	mov    %eax,%ebx
8010423a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010423d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80104241:	83 c4 14             	add    $0x14,%esp
80104244:	5b                   	pop    %ebx
80104245:	5d                   	pop    %ebp
80104246:	c3                   	ret    

80104247 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104247:	55                   	push   %ebp
80104248:	89 e5                	mov    %esp,%ebp
8010424a:	83 ec 08             	sub    $0x8,%esp
8010424d:	8b 55 08             	mov    0x8(%ebp),%edx
80104250:	8b 45 0c             	mov    0xc(%ebp),%eax
80104253:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104257:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010425a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010425e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104262:	ee                   	out    %al,(%dx)
}
80104263:	c9                   	leave  
80104264:	c3                   	ret    

80104265 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80104265:	55                   	push   %ebp
80104266:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104268:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010426d:	89 c2                	mov    %eax,%edx
8010426f:	b8 80 3b 11 80       	mov    $0x80113b80,%eax
80104274:	89 d1                	mov    %edx,%ecx
80104276:	29 c1                	sub    %eax,%ecx
80104278:	89 c8                	mov    %ecx,%eax
8010427a:	c1 f8 02             	sar    $0x2,%eax
8010427d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104283:	5d                   	pop    %ebp
80104284:	c3                   	ret    

80104285 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010428b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104292:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104299:	eb 13                	jmp    801042ae <sum+0x29>
    sum += addr[i];
8010429b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010429e:	03 45 08             	add    0x8(%ebp),%eax
801042a1:	0f b6 00             	movzbl (%eax),%eax
801042a4:	0f b6 c0             	movzbl %al,%eax
801042a7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801042aa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801042ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801042b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801042b4:	7c e5                	jl     8010429b <sum+0x16>
    sum += addr[i];
  return sum;
801042b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801042b9:	c9                   	leave  
801042ba:	c3                   	ret    

801042bb <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801042bb:	55                   	push   %ebp
801042bc:	89 e5                	mov    %esp,%ebp
801042be:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801042c1:	8b 45 08             	mov    0x8(%ebp),%eax
801042c4:	89 04 24             	mov    %eax,(%esp)
801042c7:	e8 44 ff ff ff       	call   80104210 <p2v>
801042cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801042cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d2:	03 45 f0             	add    -0x10(%ebp),%eax
801042d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801042d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042de:	eb 3f                	jmp    8010431f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801042e0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801042e7:	00 
801042e8:	c7 44 24 04 04 94 10 	movl   $0x80109404,0x4(%esp)
801042ef:	80 
801042f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f3:	89 04 24             	mov    %eax,(%esp)
801042f6:	e8 2e 1a 00 00       	call   80105d29 <memcmp>
801042fb:	85 c0                	test   %eax,%eax
801042fd:	75 1c                	jne    8010431b <mpsearch1+0x60>
801042ff:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80104306:	00 
80104307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430a:	89 04 24             	mov    %eax,(%esp)
8010430d:	e8 73 ff ff ff       	call   80104285 <sum>
80104312:	84 c0                	test   %al,%al
80104314:	75 05                	jne    8010431b <mpsearch1+0x60>
      return (struct mp*)p;
80104316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104319:	eb 11                	jmp    8010432c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010431b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104322:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104325:	72 b9                	jb     801042e0 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80104327:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010432c:	c9                   	leave  
8010432d:	c3                   	ret    

8010432e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010432e:	55                   	push   %ebp
8010432f:	89 e5                	mov    %esp,%ebp
80104331:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80104334:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010433b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433e:	83 c0 0f             	add    $0xf,%eax
80104341:	0f b6 00             	movzbl (%eax),%eax
80104344:	0f b6 c0             	movzbl %al,%eax
80104347:	89 c2                	mov    %eax,%edx
80104349:	c1 e2 08             	shl    $0x8,%edx
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	83 c0 0e             	add    $0xe,%eax
80104352:	0f b6 00             	movzbl (%eax),%eax
80104355:	0f b6 c0             	movzbl %al,%eax
80104358:	09 d0                	or     %edx,%eax
8010435a:	c1 e0 04             	shl    $0x4,%eax
8010435d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104360:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104364:	74 21                	je     80104387 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80104366:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010436d:	00 
8010436e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104371:	89 04 24             	mov    %eax,(%esp)
80104374:	e8 42 ff ff ff       	call   801042bb <mpsearch1>
80104379:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010437c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104380:	74 50                	je     801043d2 <mpsearch+0xa4>
      return mp;
80104382:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104385:	eb 5f                	jmp    801043e6 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438a:	83 c0 14             	add    $0x14,%eax
8010438d:	0f b6 00             	movzbl (%eax),%eax
80104390:	0f b6 c0             	movzbl %al,%eax
80104393:	89 c2                	mov    %eax,%edx
80104395:	c1 e2 08             	shl    $0x8,%edx
80104398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439b:	83 c0 13             	add    $0x13,%eax
8010439e:	0f b6 00             	movzbl (%eax),%eax
801043a1:	0f b6 c0             	movzbl %al,%eax
801043a4:	09 d0                	or     %edx,%eax
801043a6:	c1 e0 0a             	shl    $0xa,%eax
801043a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801043ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043af:	2d 00 04 00 00       	sub    $0x400,%eax
801043b4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801043bb:	00 
801043bc:	89 04 24             	mov    %eax,(%esp)
801043bf:	e8 f7 fe ff ff       	call   801042bb <mpsearch1>
801043c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801043c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801043cb:	74 05                	je     801043d2 <mpsearch+0xa4>
      return mp;
801043cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043d0:	eb 14                	jmp    801043e6 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801043d2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801043d9:	00 
801043da:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801043e1:	e8 d5 fe ff ff       	call   801042bb <mpsearch1>
}
801043e6:	c9                   	leave  
801043e7:	c3                   	ret    

801043e8 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801043e8:	55                   	push   %ebp
801043e9:	89 e5                	mov    %esp,%ebp
801043eb:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801043ee:	e8 3b ff ff ff       	call   8010432e <mpsearch>
801043f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043fa:	74 0a                	je     80104406 <mpconfig+0x1e>
801043fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ff:	8b 40 04             	mov    0x4(%eax),%eax
80104402:	85 c0                	test   %eax,%eax
80104404:	75 0a                	jne    80104410 <mpconfig+0x28>
    return 0;
80104406:	b8 00 00 00 00       	mov    $0x0,%eax
8010440b:	e9 83 00 00 00       	jmp    80104493 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 40 04             	mov    0x4(%eax),%eax
80104416:	89 04 24             	mov    %eax,(%esp)
80104419:	e8 f2 fd ff ff       	call   80104210 <p2v>
8010441e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80104421:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104428:	00 
80104429:	c7 44 24 04 09 94 10 	movl   $0x80109409,0x4(%esp)
80104430:	80 
80104431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104434:	89 04 24             	mov    %eax,(%esp)
80104437:	e8 ed 18 00 00       	call   80105d29 <memcmp>
8010443c:	85 c0                	test   %eax,%eax
8010443e:	74 07                	je     80104447 <mpconfig+0x5f>
    return 0;
80104440:	b8 00 00 00 00       	mov    $0x0,%eax
80104445:	eb 4c                	jmp    80104493 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80104447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010444a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010444e:	3c 01                	cmp    $0x1,%al
80104450:	74 12                	je     80104464 <mpconfig+0x7c>
80104452:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104455:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104459:	3c 04                	cmp    $0x4,%al
8010445b:	74 07                	je     80104464 <mpconfig+0x7c>
    return 0;
8010445d:	b8 00 00 00 00       	mov    $0x0,%eax
80104462:	eb 2f                	jmp    80104493 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80104464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104467:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010446b:	0f b7 c0             	movzwl %ax,%eax
8010446e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104475:	89 04 24             	mov    %eax,(%esp)
80104478:	e8 08 fe ff ff       	call   80104285 <sum>
8010447d:	84 c0                	test   %al,%al
8010447f:	74 07                	je     80104488 <mpconfig+0xa0>
    return 0;
80104481:	b8 00 00 00 00       	mov    $0x0,%eax
80104486:	eb 0b                	jmp    80104493 <mpconfig+0xab>
  *pmp = mp;
80104488:	8b 45 08             	mov    0x8(%ebp),%eax
8010448b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010448e:	89 10                	mov    %edx,(%eax)
  return conf;
80104490:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104493:	c9                   	leave  
80104494:	c3                   	ret    

80104495 <mpinit>:

void
mpinit(void)
{
80104495:	55                   	push   %ebp
80104496:	89 e5                	mov    %esp,%ebp
80104498:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
8010449b:	c7 05 44 c6 10 80 80 	movl   $0x80113b80,0x8010c644
801044a2:	3b 11 80 
  if((conf = mpconfig(&mp)) == 0)
801044a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044a8:	89 04 24             	mov    %eax,(%esp)
801044ab:	e8 38 ff ff ff       	call   801043e8 <mpconfig>
801044b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801044b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044b7:	0f 84 9c 01 00 00    	je     80104659 <mpinit+0x1c4>
    return;
  ismp = 1;
801044bd:	c7 05 64 3b 11 80 01 	movl   $0x1,0x80113b64
801044c4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801044c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ca:	8b 40 24             	mov    0x24(%eax),%eax
801044cd:	a3 7c 3a 11 80       	mov    %eax,0x80113a7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801044d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d5:	83 c0 2c             	add    $0x2c,%eax
801044d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044de:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801044e2:	0f b7 c0             	movzwl %ax,%eax
801044e5:	03 45 f0             	add    -0x10(%ebp),%eax
801044e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044eb:	e9 f4 00 00 00       	jmp    801045e4 <mpinit+0x14f>
    switch(*p){
801044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f3:	0f b6 00             	movzbl (%eax),%eax
801044f6:	0f b6 c0             	movzbl %al,%eax
801044f9:	83 f8 04             	cmp    $0x4,%eax
801044fc:	0f 87 bf 00 00 00    	ja     801045c1 <mpinit+0x12c>
80104502:	8b 04 85 4c 94 10 80 	mov    -0x7fef6bb4(,%eax,4),%eax
80104509:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010450b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104511:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104514:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104518:	0f b6 d0             	movzbl %al,%edx
8010451b:	a1 60 41 11 80       	mov    0x80114160,%eax
80104520:	39 c2                	cmp    %eax,%edx
80104522:	74 2d                	je     80104551 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104524:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104527:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010452b:	0f b6 d0             	movzbl %al,%edx
8010452e:	a1 60 41 11 80       	mov    0x80114160,%eax
80104533:	89 54 24 08          	mov    %edx,0x8(%esp)
80104537:	89 44 24 04          	mov    %eax,0x4(%esp)
8010453b:	c7 04 24 0e 94 10 80 	movl   $0x8010940e,(%esp)
80104542:	e8 5a be ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80104547:	c7 05 64 3b 11 80 00 	movl   $0x0,0x80113b64
8010454e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104551:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104554:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104558:	0f b6 c0             	movzbl %al,%eax
8010455b:	83 e0 02             	and    $0x2,%eax
8010455e:	85 c0                	test   %eax,%eax
80104560:	74 15                	je     80104577 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80104562:	a1 60 41 11 80       	mov    0x80114160,%eax
80104567:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010456d:	05 80 3b 11 80       	add    $0x80113b80,%eax
80104572:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104577:	8b 15 60 41 11 80    	mov    0x80114160,%edx
8010457d:	a1 60 41 11 80       	mov    0x80114160,%eax
80104582:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80104588:	81 c2 80 3b 11 80    	add    $0x80113b80,%edx
8010458e:	88 02                	mov    %al,(%edx)
      ncpu++;
80104590:	a1 60 41 11 80       	mov    0x80114160,%eax
80104595:	83 c0 01             	add    $0x1,%eax
80104598:	a3 60 41 11 80       	mov    %eax,0x80114160
      p += sizeof(struct mpproc);
8010459d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801045a1:	eb 41                	jmp    801045e4 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801045a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801045ac:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801045b0:	a2 60 3b 11 80       	mov    %al,0x80113b60
      p += sizeof(struct mpioapic);
801045b5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801045b9:	eb 29                	jmp    801045e4 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801045bb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801045bf:	eb 23                	jmp    801045e4 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c4:	0f b6 00             	movzbl (%eax),%eax
801045c7:	0f b6 c0             	movzbl %al,%eax
801045ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801045ce:	c7 04 24 2c 94 10 80 	movl   $0x8010942c,(%esp)
801045d5:	e8 c7 bd ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801045da:	c7 05 64 3b 11 80 00 	movl   $0x0,0x80113b64
801045e1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801045ea:	0f 82 00 ff ff ff    	jb     801044f0 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801045f0:	a1 64 3b 11 80       	mov    0x80113b64,%eax
801045f5:	85 c0                	test   %eax,%eax
801045f7:	75 1d                	jne    80104616 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801045f9:	c7 05 60 41 11 80 01 	movl   $0x1,0x80114160
80104600:	00 00 00 
    lapic = 0;
80104603:	c7 05 7c 3a 11 80 00 	movl   $0x0,0x80113a7c
8010460a:	00 00 00 
    ioapicid = 0;
8010460d:	c6 05 60 3b 11 80 00 	movb   $0x0,0x80113b60
    return;
80104614:	eb 44                	jmp    8010465a <mpinit+0x1c5>
  }

  if(mp->imcrp){
80104616:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104619:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010461d:	84 c0                	test   %al,%al
8010461f:	74 39                	je     8010465a <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104621:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104628:	00 
80104629:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104630:	e8 12 fc ff ff       	call   80104247 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104635:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010463c:	e8 dc fb ff ff       	call   8010421d <inb>
80104641:	83 c8 01             	or     $0x1,%eax
80104644:	0f b6 c0             	movzbl %al,%eax
80104647:	89 44 24 04          	mov    %eax,0x4(%esp)
8010464b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104652:	e8 f0 fb ff ff       	call   80104247 <outb>
80104657:	eb 01                	jmp    8010465a <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104659:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010465a:	c9                   	leave  
8010465b:	c3                   	ret    

8010465c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010465c:	55                   	push   %ebp
8010465d:	89 e5                	mov    %esp,%ebp
8010465f:	83 ec 08             	sub    $0x8,%esp
80104662:	8b 55 08             	mov    0x8(%ebp),%edx
80104665:	8b 45 0c             	mov    0xc(%ebp),%eax
80104668:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010466c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010466f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104673:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104677:	ee                   	out    %al,(%dx)
}
80104678:	c9                   	leave  
80104679:	c3                   	ret    

8010467a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
8010467a:	55                   	push   %ebp
8010467b:	89 e5                	mov    %esp,%ebp
8010467d:	83 ec 0c             	sub    $0xc,%esp
80104680:	8b 45 08             	mov    0x8(%ebp),%eax
80104683:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104687:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010468b:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104691:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104695:	0f b6 c0             	movzbl %al,%eax
80104698:	89 44 24 04          	mov    %eax,0x4(%esp)
8010469c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801046a3:	e8 b4 ff ff ff       	call   8010465c <outb>
  outb(IO_PIC2+1, mask >> 8);
801046a8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801046ac:	66 c1 e8 08          	shr    $0x8,%ax
801046b0:	0f b6 c0             	movzbl %al,%eax
801046b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801046b7:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801046be:	e8 99 ff ff ff       	call   8010465c <outb>
}
801046c3:	c9                   	leave  
801046c4:	c3                   	ret    

801046c5 <picenable>:

void
picenable(int irq)
{
801046c5:	55                   	push   %ebp
801046c6:	89 e5                	mov    %esp,%ebp
801046c8:	53                   	push   %ebx
801046c9:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
801046cc:	8b 45 08             	mov    0x8(%ebp),%eax
801046cf:	ba 01 00 00 00       	mov    $0x1,%edx
801046d4:	89 d3                	mov    %edx,%ebx
801046d6:	89 c1                	mov    %eax,%ecx
801046d8:	d3 e3                	shl    %cl,%ebx
801046da:	89 d8                	mov    %ebx,%eax
801046dc:	89 c2                	mov    %eax,%edx
801046de:	f7 d2                	not    %edx
801046e0:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801046e7:	21 d0                	and    %edx,%eax
801046e9:	0f b7 c0             	movzwl %ax,%eax
801046ec:	89 04 24             	mov    %eax,(%esp)
801046ef:	e8 86 ff ff ff       	call   8010467a <picsetmask>
}
801046f4:	83 c4 04             	add    $0x4,%esp
801046f7:	5b                   	pop    %ebx
801046f8:	5d                   	pop    %ebp
801046f9:	c3                   	ret    

801046fa <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801046fa:	55                   	push   %ebp
801046fb:	89 e5                	mov    %esp,%ebp
801046fd:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104700:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104707:	00 
80104708:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010470f:	e8 48 ff ff ff       	call   8010465c <outb>
  outb(IO_PIC2+1, 0xFF);
80104714:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
8010471b:	00 
8010471c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104723:	e8 34 ff ff ff       	call   8010465c <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104728:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010472f:	00 
80104730:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104737:	e8 20 ff ff ff       	call   8010465c <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010473c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80104743:	00 
80104744:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010474b:	e8 0c ff ff ff       	call   8010465c <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104750:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104757:	00 
80104758:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010475f:	e8 f8 fe ff ff       	call   8010465c <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104764:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010476b:	00 
8010476c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104773:	e8 e4 fe ff ff       	call   8010465c <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104778:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010477f:	00 
80104780:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104787:	e8 d0 fe ff ff       	call   8010465c <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010478c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80104793:	00 
80104794:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010479b:	e8 bc fe ff ff       	call   8010465c <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801047a0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801047a7:	00 
801047a8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801047af:	e8 a8 fe ff ff       	call   8010465c <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801047b4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801047bb:	00 
801047bc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801047c3:	e8 94 fe ff ff       	call   8010465c <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801047c8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801047cf:	00 
801047d0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801047d7:	e8 80 fe ff ff       	call   8010465c <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
801047dc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801047e3:	00 
801047e4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801047eb:	e8 6c fe ff ff       	call   8010465c <outb>

  outb(IO_PIC2, 0x68);             // OCW3
801047f0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801047f7:	00 
801047f8:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801047ff:	e8 58 fe ff ff       	call   8010465c <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104804:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010480b:	00 
8010480c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104813:	e8 44 fe ff ff       	call   8010465c <outb>

  if(irqmask != 0xFFFF)
80104818:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010481f:	66 83 f8 ff          	cmp    $0xffff,%ax
80104823:	74 12                	je     80104837 <picinit+0x13d>
    picsetmask(irqmask);
80104825:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010482c:	0f b7 c0             	movzwl %ax,%eax
8010482f:	89 04 24             	mov    %eax,(%esp)
80104832:	e8 43 fe ff ff       	call   8010467a <picsetmask>
}
80104837:	c9                   	leave  
80104838:	c3                   	ret    
80104839:	00 00                	add    %al,(%eax)
	...

8010483c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010483c:	55                   	push   %ebp
8010483d:	89 e5                	mov    %esp,%ebp
8010483f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104849:	8b 45 0c             	mov    0xc(%ebp),%eax
8010484c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104852:	8b 45 0c             	mov    0xc(%ebp),%eax
80104855:	8b 10                	mov    (%eax),%edx
80104857:	8b 45 08             	mov    0x8(%ebp),%eax
8010485a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010485c:	e8 e7 ce ff ff       	call   80101748 <filealloc>
80104861:	8b 55 08             	mov    0x8(%ebp),%edx
80104864:	89 02                	mov    %eax,(%edx)
80104866:	8b 45 08             	mov    0x8(%ebp),%eax
80104869:	8b 00                	mov    (%eax),%eax
8010486b:	85 c0                	test   %eax,%eax
8010486d:	0f 84 c8 00 00 00    	je     8010493b <pipealloc+0xff>
80104873:	e8 d0 ce ff ff       	call   80101748 <filealloc>
80104878:	8b 55 0c             	mov    0xc(%ebp),%edx
8010487b:	89 02                	mov    %eax,(%edx)
8010487d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104880:	8b 00                	mov    (%eax),%eax
80104882:	85 c0                	test   %eax,%eax
80104884:	0f 84 b1 00 00 00    	je     8010493b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010488a:	e8 38 eb ff ff       	call   801033c7 <kalloc>
8010488f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104892:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104896:	0f 84 9e 00 00 00    	je     8010493a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
8010489c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801048a6:	00 00 00 
  p->writeopen = 1;
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801048b3:	00 00 00 
  p->nwrite = 0;
801048b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801048c0:	00 00 00 
  p->nread = 0;
801048c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801048cd:	00 00 00 
  initlock(&p->lock, "pipe");
801048d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d3:	c7 44 24 04 60 94 10 	movl   $0x80109460,0x4(%esp)
801048da:	80 
801048db:	89 04 24             	mov    %eax,(%esp)
801048de:	e8 5f 11 00 00       	call   80105a42 <initlock>
  (*f0)->type = FD_PIPE;
801048e3:	8b 45 08             	mov    0x8(%ebp),%eax
801048e6:	8b 00                	mov    (%eax),%eax
801048e8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801048ee:	8b 45 08             	mov    0x8(%ebp),%eax
801048f1:	8b 00                	mov    (%eax),%eax
801048f3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801048f7:	8b 45 08             	mov    0x8(%ebp),%eax
801048fa:	8b 00                	mov    (%eax),%eax
801048fc:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104900:	8b 45 08             	mov    0x8(%ebp),%eax
80104903:	8b 00                	mov    (%eax),%eax
80104905:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104908:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010490b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010490e:	8b 00                	mov    (%eax),%eax
80104910:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104916:	8b 45 0c             	mov    0xc(%ebp),%eax
80104919:	8b 00                	mov    (%eax),%eax
8010491b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010491f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104922:	8b 00                	mov    (%eax),%eax
80104924:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104928:	8b 45 0c             	mov    0xc(%ebp),%eax
8010492b:	8b 00                	mov    (%eax),%eax
8010492d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104930:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104933:	b8 00 00 00 00       	mov    $0x0,%eax
80104938:	eb 43                	jmp    8010497d <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010493a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010493b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010493f:	74 0b                	je     8010494c <pipealloc+0x110>
    kfree((char*)p);
80104941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104944:	89 04 24             	mov    %eax,(%esp)
80104947:	e8 e2 e9 ff ff       	call   8010332e <kfree>
  if(*f0)
8010494c:	8b 45 08             	mov    0x8(%ebp),%eax
8010494f:	8b 00                	mov    (%eax),%eax
80104951:	85 c0                	test   %eax,%eax
80104953:	74 0d                	je     80104962 <pipealloc+0x126>
    fileclose(*f0);
80104955:	8b 45 08             	mov    0x8(%ebp),%eax
80104958:	8b 00                	mov    (%eax),%eax
8010495a:	89 04 24             	mov    %eax,(%esp)
8010495d:	e8 8e ce ff ff       	call   801017f0 <fileclose>
  if(*f1)
80104962:	8b 45 0c             	mov    0xc(%ebp),%eax
80104965:	8b 00                	mov    (%eax),%eax
80104967:	85 c0                	test   %eax,%eax
80104969:	74 0d                	je     80104978 <pipealloc+0x13c>
    fileclose(*f1);
8010496b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010496e:	8b 00                	mov    (%eax),%eax
80104970:	89 04 24             	mov    %eax,(%esp)
80104973:	e8 78 ce ff ff       	call   801017f0 <fileclose>
  return -1;
80104978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010497d:	c9                   	leave  
8010497e:	c3                   	ret    

8010497f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010497f:	55                   	push   %ebp
80104980:	89 e5                	mov    %esp,%ebp
80104982:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104985:	8b 45 08             	mov    0x8(%ebp),%eax
80104988:	89 04 24             	mov    %eax,(%esp)
8010498b:	e8 d3 10 00 00       	call   80105a63 <acquire>
  if(writable){
80104990:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104994:	74 1f                	je     801049b5 <pipeclose+0x36>
    p->writeopen = 0;
80104996:	8b 45 08             	mov    0x8(%ebp),%eax
80104999:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801049a0:	00 00 00 
    wakeup(&p->nread);
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
801049a6:	05 34 02 00 00       	add    $0x234,%eax
801049ab:	89 04 24             	mov    %eax,(%esp)
801049ae:	e8 9a 0d 00 00       	call   8010574d <wakeup>
801049b3:	eb 1d                	jmp    801049d2 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801049b5:	8b 45 08             	mov    0x8(%ebp),%eax
801049b8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801049bf:	00 00 00 
    wakeup(&p->nwrite);
801049c2:	8b 45 08             	mov    0x8(%ebp),%eax
801049c5:	05 38 02 00 00       	add    $0x238,%eax
801049ca:	89 04 24             	mov    %eax,(%esp)
801049cd:	e8 7b 0d 00 00       	call   8010574d <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801049d2:	8b 45 08             	mov    0x8(%ebp),%eax
801049d5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801049db:	85 c0                	test   %eax,%eax
801049dd:	75 25                	jne    80104a04 <pipeclose+0x85>
801049df:	8b 45 08             	mov    0x8(%ebp),%eax
801049e2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801049e8:	85 c0                	test   %eax,%eax
801049ea:	75 18                	jne    80104a04 <pipeclose+0x85>
    release(&p->lock);
801049ec:	8b 45 08             	mov    0x8(%ebp),%eax
801049ef:	89 04 24             	mov    %eax,(%esp)
801049f2:	e8 ce 10 00 00       	call   80105ac5 <release>
    kfree((char*)p);
801049f7:	8b 45 08             	mov    0x8(%ebp),%eax
801049fa:	89 04 24             	mov    %eax,(%esp)
801049fd:	e8 2c e9 ff ff       	call   8010332e <kfree>
80104a02:	eb 0b                	jmp    80104a0f <pipeclose+0x90>
  } else
    release(&p->lock);
80104a04:	8b 45 08             	mov    0x8(%ebp),%eax
80104a07:	89 04 24             	mov    %eax,(%esp)
80104a0a:	e8 b6 10 00 00       	call   80105ac5 <release>
}
80104a0f:	c9                   	leave  
80104a10:	c3                   	ret    

80104a11 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104a11:	55                   	push   %ebp
80104a12:	89 e5                	mov    %esp,%ebp
80104a14:	53                   	push   %ebx
80104a15:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104a18:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1b:	89 04 24             	mov    %eax,(%esp)
80104a1e:	e8 40 10 00 00       	call   80105a63 <acquire>
  for(i = 0; i < n; i++){
80104a23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a2a:	e9 a6 00 00 00       	jmp    80104ad5 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a32:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104a38:	85 c0                	test   %eax,%eax
80104a3a:	74 0d                	je     80104a49 <pipewrite+0x38>
80104a3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a42:	8b 40 24             	mov    0x24(%eax),%eax
80104a45:	85 c0                	test   %eax,%eax
80104a47:	74 15                	je     80104a5e <pipewrite+0x4d>
        release(&p->lock);
80104a49:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4c:	89 04 24             	mov    %eax,(%esp)
80104a4f:	e8 71 10 00 00       	call   80105ac5 <release>
        return -1;
80104a54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a59:	e9 9d 00 00 00       	jmp    80104afb <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a61:	05 34 02 00 00       	add    $0x234,%eax
80104a66:	89 04 24             	mov    %eax,(%esp)
80104a69:	e8 df 0c 00 00       	call   8010574d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a71:	8b 55 08             	mov    0x8(%ebp),%edx
80104a74:	81 c2 38 02 00 00    	add    $0x238,%edx
80104a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a7e:	89 14 24             	mov    %edx,(%esp)
80104a81:	e8 eb 0b 00 00       	call   80105671 <sleep>
80104a86:	eb 01                	jmp    80104a89 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104a88:	90                   	nop
80104a89:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104a92:	8b 45 08             	mov    0x8(%ebp),%eax
80104a95:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104a9b:	05 00 02 00 00       	add    $0x200,%eax
80104aa0:	39 c2                	cmp    %eax,%edx
80104aa2:	74 8b                	je     80104a2f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104aad:	89 c3                	mov    %eax,%ebx
80104aaf:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104ab5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ab8:	03 55 0c             	add    0xc(%ebp),%edx
80104abb:	0f b6 0a             	movzbl (%edx),%ecx
80104abe:	8b 55 08             	mov    0x8(%ebp),%edx
80104ac1:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104ac5:	8d 50 01             	lea    0x1(%eax),%edx
80104ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80104acb:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104ad1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad8:	3b 45 10             	cmp    0x10(%ebp),%eax
80104adb:	7c ab                	jl     80104a88 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104add:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae0:	05 34 02 00 00       	add    $0x234,%eax
80104ae5:	89 04 24             	mov    %eax,(%esp)
80104ae8:	e8 60 0c 00 00       	call   8010574d <wakeup>
  release(&p->lock);
80104aed:	8b 45 08             	mov    0x8(%ebp),%eax
80104af0:	89 04 24             	mov    %eax,(%esp)
80104af3:	e8 cd 0f 00 00       	call   80105ac5 <release>
  return n;
80104af8:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104afb:	83 c4 24             	add    $0x24,%esp
80104afe:	5b                   	pop    %ebx
80104aff:	5d                   	pop    %ebp
80104b00:	c3                   	ret    

80104b01 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104b01:	55                   	push   %ebp
80104b02:	89 e5                	mov    %esp,%ebp
80104b04:	53                   	push   %ebx
80104b05:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104b08:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0b:	89 04 24             	mov    %eax,(%esp)
80104b0e:	e8 50 0f 00 00       	call   80105a63 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104b13:	eb 3a                	jmp    80104b4f <piperead+0x4e>
    if(proc->killed){
80104b15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1b:	8b 40 24             	mov    0x24(%eax),%eax
80104b1e:	85 c0                	test   %eax,%eax
80104b20:	74 15                	je     80104b37 <piperead+0x36>
      release(&p->lock);
80104b22:	8b 45 08             	mov    0x8(%ebp),%eax
80104b25:	89 04 24             	mov    %eax,(%esp)
80104b28:	e8 98 0f 00 00       	call   80105ac5 <release>
      return -1;
80104b2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b32:	e9 b6 00 00 00       	jmp    80104bed <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104b37:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3a:	8b 55 08             	mov    0x8(%ebp),%edx
80104b3d:	81 c2 34 02 00 00    	add    $0x234,%edx
80104b43:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b47:	89 14 24             	mov    %edx,(%esp)
80104b4a:	e8 22 0b 00 00       	call   80105671 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b52:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104b58:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104b61:	39 c2                	cmp    %eax,%edx
80104b63:	75 0d                	jne    80104b72 <piperead+0x71>
80104b65:	8b 45 08             	mov    0x8(%ebp),%eax
80104b68:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104b6e:	85 c0                	test   %eax,%eax
80104b70:	75 a3                	jne    80104b15 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104b72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b79:	eb 49                	jmp    80104bc4 <piperead+0xc3>
    if(p->nread == p->nwrite)
80104b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104b84:	8b 45 08             	mov    0x8(%ebp),%eax
80104b87:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104b8d:	39 c2                	cmp    %eax,%edx
80104b8f:	74 3d                	je     80104bce <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b94:	89 c2                	mov    %eax,%edx
80104b96:	03 55 0c             	add    0xc(%ebp),%edx
80104b99:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104ba2:	89 c3                	mov    %eax,%ebx
80104ba4:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bad:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104bb2:	88 0a                	mov    %cl,(%edx)
80104bb4:	8d 50 01             	lea    0x1(%eax),%edx
80104bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bba:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104bc0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc7:	3b 45 10             	cmp    0x10(%ebp),%eax
80104bca:	7c af                	jl     80104b7b <piperead+0x7a>
80104bcc:	eb 01                	jmp    80104bcf <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104bce:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd2:	05 38 02 00 00       	add    $0x238,%eax
80104bd7:	89 04 24             	mov    %eax,(%esp)
80104bda:	e8 6e 0b 00 00       	call   8010574d <wakeup>
  release(&p->lock);
80104bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104be2:	89 04 24             	mov    %eax,(%esp)
80104be5:	e8 db 0e 00 00       	call   80105ac5 <release>
  return i;
80104bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bed:	83 c4 24             	add    $0x24,%esp
80104bf0:	5b                   	pop    %ebx
80104bf1:	5d                   	pop    %ebp
80104bf2:	c3                   	ret    
	...

80104bf4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104bf4:	55                   	push   %ebp
80104bf5:	89 e5                	mov    %esp,%ebp
80104bf7:	53                   	push   %ebx
80104bf8:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104bfb:	9c                   	pushf  
80104bfc:	5b                   	pop    %ebx
80104bfd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104c00:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104c03:	83 c4 10             	add    $0x10,%esp
80104c06:	5b                   	pop    %ebx
80104c07:	5d                   	pop    %ebp
80104c08:	c3                   	ret    

80104c09 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104c09:	55                   	push   %ebp
80104c0a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104c0c:	fb                   	sti    
}
80104c0d:	5d                   	pop    %ebp
80104c0e:	c3                   	ret    

80104c0f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104c0f:	55                   	push   %ebp
80104c10:	89 e5                	mov    %esp,%ebp
80104c12:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104c15:	c7 44 24 04 65 94 10 	movl   $0x80109465,0x4(%esp)
80104c1c:	80 
80104c1d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104c24:	e8 19 0e 00 00       	call   80105a42 <initlock>
}
80104c29:	c9                   	leave  
80104c2a:	c3                   	ret    

80104c2b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104c2b:	55                   	push   %ebp
80104c2c:	89 e5                	mov    %esp,%ebp
80104c2e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104c31:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104c38:	e8 26 0e 00 00       	call   80105a63 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c3d:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80104c44:	eb 11                	jmp    80104c57 <allocproc+0x2c>
    if(p->state == UNUSED)
80104c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c49:	8b 40 0c             	mov    0xc(%eax),%eax
80104c4c:	85 c0                	test   %eax,%eax
80104c4e:	74 26                	je     80104c76 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c50:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104c57:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
80104c5e:	72 e6                	jb     80104c46 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104c60:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104c67:	e8 59 0e 00 00       	call   80105ac5 <release>
  return 0;
80104c6c:	b8 00 00 00 00       	mov    $0x0,%eax
80104c71:	e9 c2 00 00 00       	jmp    80104d38 <allocproc+0x10d>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104c76:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104c81:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c89:	89 42 10             	mov    %eax,0x10(%edx)
80104c8c:	83 c0 01             	add    $0x1,%eax
80104c8f:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  p->priority=DEF_PRIORITY;
80104c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c97:	c7 80 8c 00 00 00 02 	movl   $0x2,0x8c(%eax)
80104c9e:	00 00 00 
  release(&ptable.lock);
80104ca1:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104ca8:	e8 18 0e 00 00       	call   80105ac5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104cad:	e8 15 e7 ff ff       	call   801033c7 <kalloc>
80104cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cb5:	89 42 08             	mov    %eax,0x8(%edx)
80104cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbb:	8b 40 08             	mov    0x8(%eax),%eax
80104cbe:	85 c0                	test   %eax,%eax
80104cc0:	75 11                	jne    80104cd3 <allocproc+0xa8>
    p->state = UNUSED;
80104cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104ccc:	b8 00 00 00 00       	mov    $0x0,%eax
80104cd1:	eb 65                	jmp    80104d38 <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
80104cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd6:	8b 40 08             	mov    0x8(%eax),%eax
80104cd9:	05 00 10 00 00       	add    $0x1000,%eax
80104cde:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104ce1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ceb:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104cee:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104cf2:	ba 98 71 10 80       	mov    $0x80107198,%edx
80104cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cfa:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104cfc:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d06:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d0f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104d16:	00 
80104d17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104d1e:	00 
80104d1f:	89 04 24             	mov    %eax,(%esp)
80104d22:	e8 8b 0f 00 00       	call   80105cb2 <memset>
  p->context->eip = (uint)forkret;
80104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d2d:	ba 32 56 10 80       	mov    $0x80105632,%edx
80104d32:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d38:	c9                   	leave  
80104d39:	c3                   	ret    

80104d3a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104d3a:	55                   	push   %ebp
80104d3b:	89 e5                	mov    %esp,%ebp
80104d3d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104d40:	e8 e6 fe ff ff       	call   80104c2b <allocproc>
80104d45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4b:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80104d50:	e8 68 3b 00 00       	call   801088bd <setupkvm>
80104d55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d58:	89 42 04             	mov    %eax,0x4(%edx)
80104d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5e:	8b 40 04             	mov    0x4(%eax),%eax
80104d61:	85 c0                	test   %eax,%eax
80104d63:	75 0c                	jne    80104d71 <userinit+0x37>
    panic("userinit: out of memory?");
80104d65:	c7 04 24 6c 94 10 80 	movl   $0x8010946c,(%esp)
80104d6c:	e8 cc b7 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104d71:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	8b 40 04             	mov    0x4(%eax),%eax
80104d7c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d80:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
80104d87:	80 
80104d88:	89 04 24             	mov    %eax,(%esp)
80104d8b:	e8 85 3d 00 00       	call   80108b15 <inituvm>
  p->sz = PGSIZE;
80104d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d93:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9c:	8b 40 18             	mov    0x18(%eax),%eax
80104d9f:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104da6:	00 
80104da7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104dae:	00 
80104daf:	89 04 24             	mov    %eax,(%esp)
80104db2:	e8 fb 0e 00 00       	call   80105cb2 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dba:	8b 40 18             	mov    0x18(%eax),%eax
80104dbd:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc6:	8b 40 18             	mov    0x18(%eax),%eax
80104dc9:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd2:	8b 40 18             	mov    0x18(%eax),%eax
80104dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dd8:	8b 52 18             	mov    0x18(%edx),%edx
80104ddb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ddf:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de6:	8b 40 18             	mov    0x18(%eax),%eax
80104de9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dec:	8b 52 18             	mov    0x18(%edx),%edx
80104def:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104df3:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfa:	8b 40 18             	mov    0x18(%eax),%eax
80104dfd:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e07:	8b 40 18             	mov    0x18(%eax),%eax
80104e0a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e14:	8b 40 18             	mov    0x18(%eax),%eax
80104e17:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e21:	83 c0 6c             	add    $0x6c,%eax
80104e24:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104e2b:	00 
80104e2c:	c7 44 24 04 85 94 10 	movl   $0x80109485,0x4(%esp)
80104e33:	80 
80104e34:	89 04 24             	mov    %eax,(%esp)
80104e37:	e8 a6 10 00 00       	call   80105ee2 <safestrcpy>
  p->cwd = namei("/");
80104e3c:	c7 04 24 8e 94 10 80 	movl   $0x8010948e,(%esp)
80104e43:	e8 55 de ff ff       	call   80102c9d <namei>
80104e48:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e4b:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e51:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104e58:	c9                   	leave  
80104e59:	c3                   	ret    

80104e5a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104e5a:	55                   	push   %ebp
80104e5b:	89 e5                	mov    %esp,%ebp
80104e5d:	83 ec 28             	sub    $0x28,%esp
  uint sz;

  sz = proc->sz;
80104e60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e66:	8b 00                	mov    (%eax),%eax
80104e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104e6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104e6f:	7e 34                	jle    80104ea5 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104e71:	8b 45 08             	mov    0x8(%ebp),%eax
80104e74:	89 c2                	mov    %eax,%edx
80104e76:	03 55 f4             	add    -0xc(%ebp),%edx
80104e79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7f:	8b 40 04             	mov    0x4(%eax),%eax
80104e82:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e89:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e8d:	89 04 24             	mov    %eax,(%esp)
80104e90:	e8 fa 3d 00 00       	call   80108c8f <allocuvm>
80104e95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e9c:	75 41                	jne    80104edf <growproc+0x85>
      return -1;
80104e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ea3:	eb 58                	jmp    80104efd <growproc+0xa3>
  } else if(n < 0){
80104ea5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104ea9:	79 34                	jns    80104edf <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104eab:	8b 45 08             	mov    0x8(%ebp),%eax
80104eae:	89 c2                	mov    %eax,%edx
80104eb0:	03 55 f4             	add    -0xc(%ebp),%edx
80104eb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eb9:	8b 40 04             	mov    0x4(%eax),%eax
80104ebc:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ec3:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ec7:	89 04 24             	mov    %eax,(%esp)
80104eca:	e8 9a 3e 00 00       	call   80108d69 <deallocuvm>
80104ecf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ed2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ed6:	75 07                	jne    80104edf <growproc+0x85>
      return -1;
80104ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104edd:	eb 1e                	jmp    80104efd <growproc+0xa3>
  }
  proc->sz = sz;
80104edf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ee8:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104eea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef0:	89 04 24             	mov    %eax,(%esp)
80104ef3:	e8 b6 3a 00 00       	call   801089ae <switchuvm>
  return 0;
80104ef8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104efd:	c9                   	leave  
80104efe:	c3                   	ret    

80104eff <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104eff:	55                   	push   %ebp
80104f00:	89 e5                	mov    %esp,%ebp
80104f02:	57                   	push   %edi
80104f03:	56                   	push   %esi
80104f04:	53                   	push   %ebx
80104f05:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f08:	e8 1e fd ff ff       	call   80104c2b <allocproc>
80104f0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104f10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104f14:	75 0a                	jne    80104f20 <fork+0x21>
    return -1;
80104f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f1b:	e9 67 01 00 00       	jmp    80105087 <fork+0x188>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f26:	8b 10                	mov    (%eax),%edx
80104f28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f2e:	8b 40 04             	mov    0x4(%eax),%eax
80104f31:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f35:	89 04 24             	mov    %eax,(%esp)
80104f38:	e8 bc 3f 00 00       	call   80108ef9 <copyuvm>
80104f3d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104f40:	89 42 04             	mov    %eax,0x4(%edx)
80104f43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f46:	8b 40 04             	mov    0x4(%eax),%eax
80104f49:	85 c0                	test   %eax,%eax
80104f4b:	75 2c                	jne    80104f79 <fork+0x7a>
    kfree(np->kstack);
80104f4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f50:	8b 40 08             	mov    0x8(%eax),%eax
80104f53:	89 04 24             	mov    %eax,(%esp)
80104f56:	e8 d3 e3 ff ff       	call   8010332e <kfree>
    np->kstack = 0;
80104f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f5e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f68:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f74:	e9 0e 01 00 00       	jmp    80105087 <fork+0x188>
  }
  np->sz = proc->sz;
80104f79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f7f:	8b 10                	mov    (%eax),%edx
80104f81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f84:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104f86:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f90:	89 50 14             	mov    %edx,0x14(%eax)
  np->priority=proc->priority;
80104f93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f99:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104f9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa2:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
  *np->tf = *proc->tf;
80104fa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fab:	8b 50 18             	mov    0x18(%eax),%edx
80104fae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb4:	8b 40 18             	mov    0x18(%eax),%eax
80104fb7:	89 c3                	mov    %eax,%ebx
80104fb9:	b8 13 00 00 00       	mov    $0x13,%eax
80104fbe:	89 d7                	mov    %edx,%edi
80104fc0:	89 de                	mov    %ebx,%esi
80104fc2:	89 c1                	mov    %eax,%ecx
80104fc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fc9:	8b 40 18             	mov    0x18(%eax),%eax
80104fcc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104fd3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104fda:	eb 3d                	jmp    80105019 <fork+0x11a>
    if(proc->ofile[i])
80104fdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104fe5:	83 c2 08             	add    $0x8,%edx
80104fe8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fec:	85 c0                	test   %eax,%eax
80104fee:	74 25                	je     80105015 <fork+0x116>
      np->ofile[i] = filedup(proc->ofile[i]);
80104ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ff9:	83 c2 08             	add    $0x8,%edx
80104ffc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105000:	89 04 24             	mov    %eax,(%esp)
80105003:	e8 a0 c7 ff ff       	call   801017a8 <filedup>
80105008:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010500b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010500e:	83 c1 08             	add    $0x8,%ecx
80105011:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105015:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105019:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010501d:	7e bd                	jle    80104fdc <fork+0xdd>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010501f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105025:	8b 40 68             	mov    0x68(%eax),%eax
80105028:	89 04 24             	mov    %eax,(%esp)
8010502b:	e8 93 d0 ff ff       	call   801020c3 <idup>
80105030:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105033:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80105036:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010503c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010503f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105042:	83 c0 6c             	add    $0x6c,%eax
80105045:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010504c:	00 
8010504d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105051:	89 04 24             	mov    %eax,(%esp)
80105054:	e8 89 0e 00 00       	call   80105ee2 <safestrcpy>

  pid = np->pid;
80105059:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010505c:	8b 40 10             	mov    0x10(%eax),%eax
8010505f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80105062:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105069:	e8 f5 09 00 00       	call   80105a63 <acquire>
  np->state = RUNNABLE;
8010506e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105071:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105078:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010507f:	e8 41 0a 00 00       	call   80105ac5 <release>

  return pid;
80105084:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105087:	83 c4 2c             	add    $0x2c,%esp
8010508a:	5b                   	pop    %ebx
8010508b:	5e                   	pop    %esi
8010508c:	5f                   	pop    %edi
8010508d:	5d                   	pop    %ebp
8010508e:	c3                   	ret    

8010508f <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010508f:	55                   	push   %ebp
80105090:	89 e5                	mov    %esp,%ebp
80105092:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105095:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010509c:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801050a1:	39 c2                	cmp    %eax,%edx
801050a3:	75 0c                	jne    801050b1 <exit+0x22>
    panic("init exiting");
801050a5:	c7 04 24 90 94 10 80 	movl   $0x80109490,(%esp)
801050ac:	e8 8c b4 ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801050b8:	eb 44                	jmp    801050fe <exit+0x6f>
    if(proc->ofile[fd]){
801050ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050c3:	83 c2 08             	add    $0x8,%edx
801050c6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050ca:	85 c0                	test   %eax,%eax
801050cc:	74 2c                	je     801050fa <exit+0x6b>
      fileclose(proc->ofile[fd]);
801050ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050d7:	83 c2 08             	add    $0x8,%edx
801050da:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050de:	89 04 24             	mov    %eax,(%esp)
801050e1:	e8 0a c7 ff ff       	call   801017f0 <fileclose>
      proc->ofile[fd] = 0;
801050e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050ef:	83 c2 08             	add    $0x8,%edx
801050f2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801050f9:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050fa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801050fe:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105102:	7e b6                	jle    801050ba <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80105104:	e8 08 ec ff ff       	call   80103d11 <begin_op>
  iput(proc->cwd);
80105109:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010510f:	8b 40 68             	mov    0x68(%eax),%eax
80105112:	89 04 24             	mov    %eax,(%esp)
80105115:	e8 94 d1 ff ff       	call   801022ae <iput>
  end_op();
8010511a:	e8 73 ec ff ff       	call   80103d92 <end_op>
  proc->cwd = 0;
8010511f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105125:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010512c:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105133:	e8 2b 09 00 00       	call   80105a63 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105138:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513e:	8b 40 14             	mov    0x14(%eax),%eax
80105141:	89 04 24             	mov    %eax,(%esp)
80105144:	e8 c3 05 00 00       	call   8010570c <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105149:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80105150:	eb 3b                	jmp    8010518d <exit+0xfe>
    if(p->parent == proc){
80105152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105155:	8b 50 14             	mov    0x14(%eax),%edx
80105158:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515e:	39 c2                	cmp    %eax,%edx
80105160:	75 24                	jne    80105186 <exit+0xf7>
      p->parent = initproc;
80105162:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80105168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010516e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105171:	8b 40 0c             	mov    0xc(%eax),%eax
80105174:	83 f8 05             	cmp    $0x5,%eax
80105177:	75 0d                	jne    80105186 <exit+0xf7>
        wakeup1(initproc);
80105179:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010517e:	89 04 24             	mov    %eax,(%esp)
80105181:	e8 86 05 00 00       	call   8010570c <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105186:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010518d:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
80105194:	72 bc                	jb     80105152 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105196:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010519c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801051a3:	e8 a6 03 00 00       	call   8010554e <sched>
  panic("zombie exit");
801051a8:	c7 04 24 9d 94 10 80 	movl   $0x8010949d,(%esp)
801051af:	e8 89 b3 ff ff       	call   8010053d <panic>

801051b4 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801051b4:	55                   	push   %ebp
801051b5:	89 e5                	mov    %esp,%ebp
801051b7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801051ba:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801051c1:	e8 9d 08 00 00       	call   80105a63 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801051c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051cd:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
801051d4:	e9 9d 00 00 00       	jmp    80105276 <wait+0xc2>
      if(p->parent != proc)
801051d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051dc:	8b 50 14             	mov    0x14(%eax),%edx
801051df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e5:	39 c2                	cmp    %eax,%edx
801051e7:	0f 85 81 00 00 00    	jne    8010526e <wait+0xba>
        continue;
      havekids = 1;
801051ed:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801051f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f7:	8b 40 0c             	mov    0xc(%eax),%eax
801051fa:	83 f8 05             	cmp    $0x5,%eax
801051fd:	75 70                	jne    8010526f <wait+0xbb>
        // Found one.
        pid = p->pid;
801051ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105202:	8b 40 10             	mov    0x10(%eax),%eax
80105205:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520b:	8b 40 08             	mov    0x8(%eax),%eax
8010520e:	89 04 24             	mov    %eax,(%esp)
80105211:	e8 18 e1 ff ff       	call   8010332e <kfree>
        p->kstack = 0;
80105216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105219:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105223:	8b 40 04             	mov    0x4(%eax),%eax
80105226:	89 04 24             	mov    %eax,(%esp)
80105229:	e8 f7 3b 00 00       	call   80108e25 <freevm>
        p->state = UNUSED;
8010522e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105231:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105245:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010524c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105256:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010525d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105264:	e8 5c 08 00 00       	call   80105ac5 <release>
        return pid;
80105269:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010526c:	eb 56                	jmp    801052c4 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010526e:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010526f:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105276:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
8010527d:	0f 82 56 ff ff ff    	jb     801051d9 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105283:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105287:	74 0d                	je     80105296 <wait+0xe2>
80105289:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528f:	8b 40 24             	mov    0x24(%eax),%eax
80105292:	85 c0                	test   %eax,%eax
80105294:	74 13                	je     801052a9 <wait+0xf5>
      release(&ptable.lock);
80105296:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010529d:	e8 23 08 00 00       	call   80105ac5 <release>
      return -1;
801052a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a7:	eb 1b                	jmp    801052c4 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801052a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052af:	c7 44 24 04 80 41 11 	movl   $0x80114180,0x4(%esp)
801052b6:	80 
801052b7:	89 04 24             	mov    %eax,(%esp)
801052ba:	e8 b2 03 00 00       	call   80105671 <sleep>
  }
801052bf:	e9 02 ff ff ff       	jmp    801051c6 <wait+0x12>
}
801052c4:	c9                   	leave  
801052c5:	c3                   	ret    

801052c6 <scheduler_def>:
//  - eventually that process transfers control
//      via swtch back to the scheduler.


void
scheduler_def(void) {
801052c6:	55                   	push   %ebp
801052c7:	89 e5                	mov    %esp,%ebp
801052c9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801052cc:	e8 38 f9 ff ff       	call   80104c09 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801052d1:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801052d8:	e8 86 07 00 00       	call   80105a63 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052dd:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
801052e4:	eb 62                	jmp    80105348 <scheduler_def+0x82>
      if(p->state != RUNNABLE)
801052e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e9:	8b 40 0c             	mov    0xc(%eax),%eax
801052ec:	83 f8 03             	cmp    $0x3,%eax
801052ef:	75 4f                	jne    80105340 <scheduler_def+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801052f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f4:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801052fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fd:	89 04 24             	mov    %eax,(%esp)
80105300:	e8 a9 36 00 00       	call   801089ae <switchuvm>
      p->state = RUNNING;
80105305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105308:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
8010530f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105315:	8b 40 1c             	mov    0x1c(%eax),%eax
80105318:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010531f:	83 c2 04             	add    $0x4,%edx
80105322:	89 44 24 04          	mov    %eax,0x4(%esp)
80105326:	89 14 24             	mov    %edx,(%esp)
80105329:	e8 2a 0c 00 00       	call   80105f58 <swtch>
      switchkvm();
8010532e:	e8 5e 36 00 00       	call   80108991 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105333:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010533a:	00 00 00 00 
8010533e:	eb 01                	jmp    80105341 <scheduler_def+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105340:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105341:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105348:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
8010534f:	72 95                	jb     801052e6 <scheduler_def+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105351:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105358:	e8 68 07 00 00       	call   80105ac5 <release>

  }
8010535d:	e9 6a ff ff ff       	jmp    801052cc <scheduler_def+0x6>

80105362 <scheduler_fcfs>:
}


void
scheduler_fcfs(void) {
80105362:	55                   	push   %ebp
80105363:	89 e5                	mov    %esp,%ebp
80105365:	83 ec 28             	sub    $0x28,%esp
  struct proc *p,*chosenProc;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80105368:	e8 9c f8 ff ff       	call   80104c09 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010536d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105374:	e8 ea 06 00 00       	call   80105a63 <acquire>
    chosenProc=0;
80105379:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    //Set chosenProc to the runnable proc with the minimum creation time.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105380:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80105387:	eb 2e                	jmp    801053b7 <scheduler_fcfs+0x55>
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime <= chosenProc->ctime)))
80105389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538c:	8b 40 0c             	mov    0xc(%eax),%eax
8010538f:	83 f8 03             	cmp    $0x3,%eax
80105392:	75 1c                	jne    801053b0 <scheduler_fcfs+0x4e>
80105394:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105398:	74 10                	je     801053aa <scheduler_fcfs+0x48>
8010539a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539d:	8b 50 7c             	mov    0x7c(%eax),%edx
801053a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a3:	8b 40 7c             	mov    0x7c(%eax),%eax
801053a6:	39 c2                	cmp    %eax,%edx
801053a8:	77 06                	ja     801053b0 <scheduler_fcfs+0x4e>
        chosenProc=p;
801053aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    chosenProc=0;

    //Set chosenProc to the runnable proc with the minimum creation time.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053b0:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801053b7:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
801053be:	72 c9                	jb     80105389 <scheduler_fcfs+0x27>
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime <= chosenProc->ctime)))
        chosenProc=p;
    }

    if (!chosenProc) continue;
801053c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053c4:	74 6e                	je     80105434 <scheduler_fcfs+0xd2>

    // Switch to chosen process.  It is the process's job
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    proc=chosenProc;
801053c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c9:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4

    //run process untill its no longer need cpu time
    while(proc->state==RUNNABLE) {
801053cf:	eb 39                	jmp    8010540a <scheduler_fcfs+0xa8>
      switchuvm(chosenProc);
801053d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d4:	89 04 24             	mov    %eax,(%esp)
801053d7:	e8 d2 35 00 00       	call   801089ae <switchuvm>
      chosenProc->state = RUNNING;
801053dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053df:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801053e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ec:	8b 40 1c             	mov    0x1c(%eax),%eax
801053ef:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801053f6:	83 c2 04             	add    $0x4,%edx
801053f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801053fd:	89 14 24             	mov    %edx,(%esp)
80105400:	e8 53 0b 00 00       	call   80105f58 <swtch>
      switchkvm();
80105405:	e8 87 35 00 00       	call   80108991 <switchkvm>
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    proc=chosenProc;

    //run process untill its no longer need cpu time
    while(proc->state==RUNNABLE) {
8010540a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105410:	8b 40 0c             	mov    0xc(%eax),%eax
80105413:	83 f8 03             	cmp    $0x3,%eax
80105416:	74 b9                	je     801053d1 <scheduler_fcfs+0x6f>
      switchkvm();
   }

    // Process is done running for now.
    // It should have changed its p->state before coming back.
    proc = 0;
80105418:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010541f:	00 00 00 00 
    release(&ptable.lock);
80105423:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010542a:	e8 96 06 00 00       	call   80105ac5 <release>
  }
8010542f:	e9 34 ff ff ff       	jmp    80105368 <scheduler_fcfs+0x6>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime <= chosenProc->ctime)))
        chosenProc=p;
    }

    if (!chosenProc) continue;
80105434:	90                   	nop

    // Process is done running for now.
    // It should have changed its p->state before coming back.
    proc = 0;
    release(&ptable.lock);
  }
80105435:	e9 2e ff ff ff       	jmp    80105368 <scheduler_fcfs+0x6>

8010543a <scheduler_sml>:
}

void
scheduler_sml(void) {
8010543a:	55                   	push   %ebp
8010543b:	89 e5                	mov    %esp,%ebp
8010543d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p,*chosenProc;
  int priority;
  int beenInside=0;
80105440:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

  for(;;){
    //we start at MAX_PRIORITY, if we didnt find a process then we decrease the priority. if we found one, we resets it to max priority.
    if (beenInside && !chosenProc && priority>MIN_PRIORITY)
80105447:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010544b:	74 12                	je     8010545f <scheduler_sml+0x25>
8010544d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105451:	75 0c                	jne    8010545f <scheduler_sml+0x25>
80105453:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
80105457:	7e 06                	jle    8010545f <scheduler_sml+0x25>
        priority--;
80105459:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
8010545d:	eb 07                	jmp    80105466 <scheduler_sml+0x2c>
    else priority=MAX_PRIORITY;
8010545f:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)

    // Enable interrupts on this processor.
    sti();
80105466:	e8 9e f7 ff ff       	call   80104c09 <sti>
    chosenProc=0;
8010546b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    beenInside=1;
80105472:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105479:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105480:	e8 de 05 00 00       	call   80105a63 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105485:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
8010548c:	e9 8f 00 00 00       	jmp    80105520 <scheduler_sml+0xe6>
      if(p->state != RUNNABLE && p->priority!=priority)
80105491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105494:	8b 40 0c             	mov    0xc(%eax),%eax
80105497:	83 f8 03             	cmp    $0x3,%eax
8010549a:	74 10                	je     801054ac <scheduler_sml+0x72>
8010549c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010549f:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801054a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054a8:	39 c2                	cmp    %eax,%edx
801054aa:	75 6c                	jne    80105518 <scheduler_sml+0xde>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      chosenProc=p;
801054ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054af:	89 45 f0             	mov    %eax,-0x10(%ebp)
      proc = p;
801054b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b5:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801054bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054be:	89 04 24             	mov    %eax,(%esp)
801054c1:	e8 e8 34 00 00       	call   801089ae <switchuvm>
      p->state = RUNNING;
801054c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c9:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801054d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d6:	8b 40 1c             	mov    0x1c(%eax),%eax
801054d9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801054e0:	83 c2 04             	add    $0x4,%edx
801054e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801054e7:	89 14 24             	mov    %edx,(%esp)
801054ea:	e8 69 0a 00 00       	call   80105f58 <swtch>
      switchkvm();
801054ef:	e8 9d 34 00 00       	call   80108991 <switchkvm>

      if (p->priority>priority)
801054f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f7:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801054fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105500:	39 c2                	cmp    %eax,%edx
80105502:	76 07                	jbe    8010550b <scheduler_sml+0xd1>
        priority=MAX_PRIORITY;
80105504:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010550b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105512:	00 00 00 00 
80105516:	eb 01                	jmp    80105519 <scheduler_sml+0xdf>
    beenInside=1;
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE && p->priority!=priority)
        continue;
80105518:	90                   	nop
    sti();
    chosenProc=0;
    beenInside=1;
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105519:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105520:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
80105527:	0f 82 64 ff ff ff    	jb     80105491 <scheduler_sml+0x57>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010552d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105534:	e8 8c 05 00 00       	call   80105ac5 <release>

  }
80105539:	e9 09 ff ff ff       	jmp    80105447 <scheduler_sml+0xd>

8010553e <scheduler_dml>:
}


void
scheduler_dml(void) {
8010553e:	55                   	push   %ebp
8010553f:	89 e5                	mov    %esp,%ebp
  for (;;){}
80105541:	eb fe                	jmp    80105541 <scheduler_dml+0x3>

80105543 <scheduler>:
}

void
scheduler(void)
{
80105543:	55                   	push   %ebp
80105544:	89 e5                	mov    %esp,%ebp
80105546:	83 ec 08             	sub    $0x8,%esp
#if SCHEDFLAG == DEFAULT
  scheduler_def();
80105549:	e8 78 fd ff ff       	call   801052c6 <scheduler_def>

8010554e <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010554e:	55                   	push   %ebp
8010554f:	89 e5                	mov    %esp,%ebp
80105551:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80105554:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010555b:	e8 21 06 00 00       	call   80105b81 <holding>
80105560:	85 c0                	test   %eax,%eax
80105562:	75 0c                	jne    80105570 <sched+0x22>
    panic("sched ptable.lock");
80105564:	c7 04 24 a9 94 10 80 	movl   $0x801094a9,(%esp)
8010556b:	e8 cd af ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80105570:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105576:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010557c:	83 f8 01             	cmp    $0x1,%eax
8010557f:	74 0c                	je     8010558d <sched+0x3f>
    panic("sched locks");
80105581:	c7 04 24 bb 94 10 80 	movl   $0x801094bb,(%esp)
80105588:	e8 b0 af ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
8010558d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105593:	8b 40 0c             	mov    0xc(%eax),%eax
80105596:	83 f8 04             	cmp    $0x4,%eax
80105599:	75 0c                	jne    801055a7 <sched+0x59>
    panic("sched running");
8010559b:	c7 04 24 c7 94 10 80 	movl   $0x801094c7,(%esp)
801055a2:	e8 96 af ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
801055a7:	e8 48 f6 ff ff       	call   80104bf4 <readeflags>
801055ac:	25 00 02 00 00       	and    $0x200,%eax
801055b1:	85 c0                	test   %eax,%eax
801055b3:	74 0c                	je     801055c1 <sched+0x73>
    panic("sched interruptible");
801055b5:	c7 04 24 d5 94 10 80 	movl   $0x801094d5,(%esp)
801055bc:	e8 7c af ff ff       	call   8010053d <panic>
  intena = cpu->intena;
801055c1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055c7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801055cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801055d0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055d6:	8b 40 04             	mov    0x4(%eax),%eax
801055d9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801055e0:	83 c2 1c             	add    $0x1c,%edx
801055e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801055e7:	89 14 24             	mov    %edx,(%esp)
801055ea:	e8 69 09 00 00       	call   80105f58 <swtch>
  cpu->intena = intena;
801055ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055f8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801055fe:	c9                   	leave  
801055ff:	c3                   	ret    

80105600 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105606:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010560d:	e8 51 04 00 00       	call   80105a63 <acquire>
  proc->state = RUNNABLE;
80105612:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105618:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010561f:	e8 2a ff ff ff       	call   8010554e <sched>
  release(&ptable.lock);
80105624:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010562b:	e8 95 04 00 00       	call   80105ac5 <release>
}
80105630:	c9                   	leave  
80105631:	c3                   	ret    

80105632 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105632:	55                   	push   %ebp
80105633:	89 e5                	mov    %esp,%ebp
80105635:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105638:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010563f:	e8 81 04 00 00       	call   80105ac5 <release>

  if (first) {
80105644:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80105649:	85 c0                	test   %eax,%eax
8010564b:	74 22                	je     8010566f <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010564d:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80105654:	00 00 00 
    iinit(ROOTDEV);
80105657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010565e:	e8 69 c7 ff ff       	call   80101dcc <iinit>
    initlog(ROOTDEV);
80105663:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010566a:	e8 a1 e4 ff ff       	call   80103b10 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010566f:	c9                   	leave  
80105670:	c3                   	ret    

80105671 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105671:	55                   	push   %ebp
80105672:	89 e5                	mov    %esp,%ebp
80105674:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80105677:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567d:	85 c0                	test   %eax,%eax
8010567f:	75 0c                	jne    8010568d <sleep+0x1c>
    panic("sleep");
80105681:	c7 04 24 e9 94 10 80 	movl   $0x801094e9,(%esp)
80105688:	e8 b0 ae ff ff       	call   8010053d <panic>

  if(lk == 0)
8010568d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105691:	75 0c                	jne    8010569f <sleep+0x2e>
    panic("sleep without lk");
80105693:	c7 04 24 ef 94 10 80 	movl   $0x801094ef,(%esp)
8010569a:	e8 9e ae ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010569f:	81 7d 0c 80 41 11 80 	cmpl   $0x80114180,0xc(%ebp)
801056a6:	74 17                	je     801056bf <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801056a8:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801056af:	e8 af 03 00 00       	call   80105a63 <acquire>
    release(lk);
801056b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b7:	89 04 24             	mov    %eax,(%esp)
801056ba:	e8 06 04 00 00       	call   80105ac5 <release>
  }

  // Go to sleep.
  proc->chan = chan;
801056bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c5:	8b 55 08             	mov    0x8(%ebp),%edx
801056c8:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801056cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d1:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801056d8:	e8 71 fe ff ff       	call   8010554e <sched>

  // Tidy up.
  proc->chan = 0;
801056dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801056ea:	81 7d 0c 80 41 11 80 	cmpl   $0x80114180,0xc(%ebp)
801056f1:	74 17                	je     8010570a <sleep+0x99>
    release(&ptable.lock);
801056f3:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801056fa:	e8 c6 03 00 00       	call   80105ac5 <release>
    acquire(lk);
801056ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105702:	89 04 24             	mov    %eax,(%esp)
80105705:	e8 59 03 00 00       	call   80105a63 <acquire>
  }
}
8010570a:	c9                   	leave  
8010570b:	c3                   	ret    

8010570c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010570c:	55                   	push   %ebp
8010570d:	89 e5                	mov    %esp,%ebp
8010570f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105712:	c7 45 fc b4 41 11 80 	movl   $0x801141b4,-0x4(%ebp)
80105719:	eb 27                	jmp    80105742 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010571b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010571e:	8b 40 0c             	mov    0xc(%eax),%eax
80105721:	83 f8 02             	cmp    $0x2,%eax
80105724:	75 15                	jne    8010573b <wakeup1+0x2f>
80105726:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105729:	8b 40 20             	mov    0x20(%eax),%eax
8010572c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010572f:	75 0a                	jne    8010573b <wakeup1+0x2f>
      p->state = RUNNABLE;
80105731:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105734:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010573b:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80105742:	81 7d fc b4 65 11 80 	cmpl   $0x801165b4,-0x4(%ebp)
80105749:	72 d0                	jb     8010571b <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010574b:	c9                   	leave  
8010574c:	c3                   	ret    

8010574d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010574d:	55                   	push   %ebp
8010574e:	89 e5                	mov    %esp,%ebp
80105750:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105753:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010575a:	e8 04 03 00 00       	call   80105a63 <acquire>
  wakeup1(chan);
8010575f:	8b 45 08             	mov    0x8(%ebp),%eax
80105762:	89 04 24             	mov    %eax,(%esp)
80105765:	e8 a2 ff ff ff       	call   8010570c <wakeup1>
  release(&ptable.lock);
8010576a:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105771:	e8 4f 03 00 00       	call   80105ac5 <release>
}
80105776:	c9                   	leave  
80105777:	c3                   	ret    

80105778 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105778:	55                   	push   %ebp
80105779:	89 e5                	mov    %esp,%ebp
8010577b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010577e:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105785:	e8 d9 02 00 00       	call   80105a63 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010578a:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80105791:	eb 44                	jmp    801057d7 <kill+0x5f>
    if(p->pid == pid){
80105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105796:	8b 40 10             	mov    0x10(%eax),%eax
80105799:	3b 45 08             	cmp    0x8(%ebp),%eax
8010579c:	75 32                	jne    801057d0 <kill+0x58>
      p->killed = 1;
8010579e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801057a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ab:	8b 40 0c             	mov    0xc(%eax),%eax
801057ae:	83 f8 02             	cmp    $0x2,%eax
801057b1:	75 0a                	jne    801057bd <kill+0x45>
        p->state = RUNNABLE;
801057b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801057bd:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801057c4:	e8 fc 02 00 00       	call   80105ac5 <release>
      return 0;
801057c9:	b8 00 00 00 00       	mov    $0x0,%eax
801057ce:	eb 21                	jmp    801057f1 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057d0:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801057d7:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
801057de:	72 b3                	jb     80105793 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801057e0:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801057e7:	e8 d9 02 00 00       	call   80105ac5 <release>
  return -1;
801057ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057f1:	c9                   	leave  
801057f2:	c3                   	ret    

801057f3 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801057f3:	55                   	push   %ebp
801057f4:	89 e5                	mov    %esp,%ebp
801057f6:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057f9:	c7 45 f0 b4 41 11 80 	movl   $0x801141b4,-0x10(%ebp)
80105800:	e9 db 00 00 00       	jmp    801058e0 <procdump+0xed>
    if(p->state == UNUSED)
80105805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105808:	8b 40 0c             	mov    0xc(%eax),%eax
8010580b:	85 c0                	test   %eax,%eax
8010580d:	0f 84 c5 00 00 00    	je     801058d8 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105816:	8b 40 0c             	mov    0xc(%eax),%eax
80105819:	83 f8 05             	cmp    $0x5,%eax
8010581c:	77 23                	ja     80105841 <procdump+0x4e>
8010581e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105821:	8b 40 0c             	mov    0xc(%eax),%eax
80105824:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010582b:	85 c0                	test   %eax,%eax
8010582d:	74 12                	je     80105841 <procdump+0x4e>
      state = states[p->state];
8010582f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105832:	8b 40 0c             	mov    0xc(%eax),%eax
80105835:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010583c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010583f:	eb 07                	jmp    80105848 <procdump+0x55>
    else
      state = "???";
80105841:	c7 45 ec 00 95 10 80 	movl   $0x80109500,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010584e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105851:	8b 40 10             	mov    0x10(%eax),%eax
80105854:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105858:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010585b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010585f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105863:	c7 04 24 04 95 10 80 	movl   $0x80109504,(%esp)
8010586a:	e8 32 ab ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
8010586f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105872:	8b 40 0c             	mov    0xc(%eax),%eax
80105875:	83 f8 02             	cmp    $0x2,%eax
80105878:	75 50                	jne    801058ca <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105880:	8b 40 0c             	mov    0xc(%eax),%eax
80105883:	83 c0 08             	add    $0x8,%eax
80105886:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105889:	89 54 24 04          	mov    %edx,0x4(%esp)
8010588d:	89 04 24             	mov    %eax,(%esp)
80105890:	e8 7f 02 00 00       	call   80105b14 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105895:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010589c:	eb 1b                	jmp    801058b9 <procdump+0xc6>
        cprintf(" %p", pc[i]);
8010589e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801058a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a9:	c7 04 24 0d 95 10 80 	movl   $0x8010950d,(%esp)
801058b0:	e8 ec aa ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801058b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058b9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801058bd:	7f 0b                	jg     801058ca <procdump+0xd7>
801058bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801058c6:	85 c0                	test   %eax,%eax
801058c8:	75 d4                	jne    8010589e <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801058ca:	c7 04 24 11 95 10 80 	movl   $0x80109511,(%esp)
801058d1:	e8 cb aa ff ff       	call   801003a1 <cprintf>
801058d6:	eb 01                	jmp    801058d9 <procdump+0xe6>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801058d8:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801058d9:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
801058e0:	81 7d f0 b4 65 11 80 	cmpl   $0x801165b4,-0x10(%ebp)
801058e7:	0f 82 18 ff ff ff    	jb     80105805 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801058ed:	c9                   	leave  
801058ee:	c3                   	ret    

801058ef <updateTimes>:


void
updateTimes()
{
801058ef:	55                   	push   %ebp
801058f0:	89 e5                	mov    %esp,%ebp
801058f2:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801058f5:	c7 45 fc b4 41 11 80 	movl   $0x801141b4,-0x4(%ebp)
801058fc:	eb 47                	jmp    80105945 <updateTimes+0x56>
    if(p->state == RUNNING)
801058fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105901:	8b 40 0c             	mov    0xc(%eax),%eax
80105904:	83 f8 04             	cmp    $0x4,%eax
80105907:	75 15                	jne    8010591e <updateTimes+0x2f>
      p->rutime++;
80105909:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010590c:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105912:	8d 50 01             	lea    0x1(%eax),%edx
80105915:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105918:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    if(p->state == SLEEPING)
8010591e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105921:	8b 40 0c             	mov    0xc(%eax),%eax
80105924:	83 f8 02             	cmp    $0x2,%eax
80105927:	75 15                	jne    8010593e <updateTimes+0x4f>
      p->stime++;
80105929:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010592c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105932:	8d 50 01             	lea    0x1(%eax),%edx
80105935:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105938:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

void
updateTimes()
{
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010593e:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80105945:	81 7d fc b4 65 11 80 	cmpl   $0x801165b4,-0x4(%ebp)
8010594c:	72 b0                	jb     801058fe <updateTimes+0xf>
    if(p->state == RUNNING)
      p->rutime++;
    if(p->state == SLEEPING)
      p->stime++;
    }
}
8010594e:	c9                   	leave  
8010594f:	c3                   	ret    

80105950 <wait2>:

int
wait2(int *retime, int *rutime, int* stime) {
80105950:	55                   	push   %ebp
80105951:	89 e5                	mov    %esp,%ebp
80105953:	83 ec 18             	sub    $0x18,%esp
 int childPid=wait();
80105956:	e8 59 f8 ff ff       	call   801051b4 <wait>
8010595b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 struct proc* p;
 if (childPid<0)
8010595e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105962:	79 05                	jns    80105969 <wait2+0x19>
  return childPid;
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	eb 5a                	jmp    801059c3 <wait2+0x73>
 for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105969:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80105970:	eb 45                	jmp    801059b7 <wait2+0x67>
      if(p->pid != childPid)
80105972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105975:	8b 40 10             	mov    0x10(%eax),%eax
80105978:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010597b:	75 32                	jne    801059af <wait2+0x5f>
        continue;
    *retime=p->retime;
8010597d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105980:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105986:	89 c2                	mov    %eax,%edx
80105988:	8b 45 08             	mov    0x8(%ebp),%eax
8010598b:	89 10                	mov    %edx,(%eax)
    *rutime=p->rutime;
8010598d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105990:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105996:	89 c2                	mov    %eax,%edx
80105998:	8b 45 0c             	mov    0xc(%ebp),%eax
8010599b:	89 10                	mov    %edx,(%eax)
    *stime=p->stime;
8010599d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801059a6:	89 c2                	mov    %eax,%edx
801059a8:	8b 45 10             	mov    0x10(%ebp),%eax
801059ab:	89 10                	mov    %edx,(%eax)
801059ad:	eb 01                	jmp    801059b0 <wait2+0x60>
 struct proc* p;
 if (childPid<0)
  return childPid;
 for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->pid != childPid)
        continue;
801059af:	90                   	nop
wait2(int *retime, int *rutime, int* stime) {
 int childPid=wait();
 struct proc* p;
 if (childPid<0)
  return childPid;
 for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059b0:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801059b7:	81 7d f4 b4 65 11 80 	cmpl   $0x801165b4,-0xc(%ebp)
801059be:	72 b2                	jb     80105972 <wait2+0x22>
        continue;
    *retime=p->retime;
    *rutime=p->rutime;
    *stime=p->stime;
  }
 return childPid;
801059c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801059c3:	c9                   	leave  
801059c4:	c3                   	ret    

801059c5 <set_prio>:

int
set_prio(int priority){
801059c5:	55                   	push   %ebp
801059c6:	89 e5                	mov    %esp,%ebp
  #if SCHEDFLAG == SML
  return -1;
  #endif
  if ((priority>MAX_PRIORITY) | (priority<MIN_PRIORITY))
801059c8:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
801059cc:	0f 9f c2             	setg   %dl
801059cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801059d3:	0f 9e c0             	setle  %al
801059d6:	09 d0                	or     %edx,%eax
801059d8:	84 c0                	test   %al,%al
801059da:	74 07                	je     801059e3 <set_prio+0x1e>
    return -1;
801059dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e1:	eb 14                	jmp    801059f7 <set_prio+0x32>
  proc->priority=priority;
801059e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e9:	8b 55 08             	mov    0x8(%ebp),%edx
801059ec:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
  return 0;
801059f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059f7:	5d                   	pop    %ebp
801059f8:	c3                   	ret    
801059f9:	00 00                	add    %al,(%eax)
	...

801059fc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801059fc:	55                   	push   %ebp
801059fd:	89 e5                	mov    %esp,%ebp
801059ff:	53                   	push   %ebx
80105a00:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105a03:	9c                   	pushf  
80105a04:	5b                   	pop    %ebx
80105a05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105a08:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105a0b:	83 c4 10             	add    $0x10,%esp
80105a0e:	5b                   	pop    %ebx
80105a0f:	5d                   	pop    %ebp
80105a10:	c3                   	ret    

80105a11 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105a11:	55                   	push   %ebp
80105a12:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105a14:	fa                   	cli    
}
80105a15:	5d                   	pop    %ebp
80105a16:	c3                   	ret    

80105a17 <sti>:

static inline void
sti(void)
{
80105a17:	55                   	push   %ebp
80105a18:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105a1a:	fb                   	sti    
}
80105a1b:	5d                   	pop    %ebp
80105a1c:	c3                   	ret    

80105a1d <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105a1d:	55                   	push   %ebp
80105a1e:	89 e5                	mov    %esp,%ebp
80105a20:	53                   	push   %ebx
80105a21:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105a24:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105a27:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105a2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105a2d:	89 c3                	mov    %eax,%ebx
80105a2f:	89 d8                	mov    %ebx,%eax
80105a31:	f0 87 02             	lock xchg %eax,(%edx)
80105a34:	89 c3                	mov    %eax,%ebx
80105a36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105a39:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105a3c:	83 c4 10             	add    $0x10,%esp
80105a3f:	5b                   	pop    %ebx
80105a40:	5d                   	pop    %ebp
80105a41:	c3                   	ret    

80105a42 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105a42:	55                   	push   %ebp
80105a43:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105a45:	8b 45 08             	mov    0x8(%ebp),%eax
80105a48:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a4b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105a57:	8b 45 08             	mov    0x8(%ebp),%eax
80105a5a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105a61:	5d                   	pop    %ebp
80105a62:	c3                   	ret    

80105a63 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105a63:	55                   	push   %ebp
80105a64:	89 e5                	mov    %esp,%ebp
80105a66:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105a69:	e8 3d 01 00 00       	call   80105bab <pushcli>
  if(holding(lk))
80105a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a71:	89 04 24             	mov    %eax,(%esp)
80105a74:	e8 08 01 00 00       	call   80105b81 <holding>
80105a79:	85 c0                	test   %eax,%eax
80105a7b:	74 0c                	je     80105a89 <acquire+0x26>
    panic("acquire");
80105a7d:	c7 04 24 3d 95 10 80 	movl   $0x8010953d,(%esp)
80105a84:	e8 b4 aa ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105a89:	90                   	nop
80105a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a8d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105a94:	00 
80105a95:	89 04 24             	mov    %eax,(%esp)
80105a98:	e8 80 ff ff ff       	call   80105a1d <xchg>
80105a9d:	85 c0                	test   %eax,%eax
80105a9f:	75 e9                	jne    80105a8a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80105aa4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105aab:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105aae:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab1:	83 c0 0c             	add    $0xc,%eax
80105ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab8:	8d 45 08             	lea    0x8(%ebp),%eax
80105abb:	89 04 24             	mov    %eax,(%esp)
80105abe:	e8 51 00 00 00       	call   80105b14 <getcallerpcs>
}
80105ac3:	c9                   	leave  
80105ac4:	c3                   	ret    

80105ac5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105ac5:	55                   	push   %ebp
80105ac6:	89 e5                	mov    %esp,%ebp
80105ac8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105acb:	8b 45 08             	mov    0x8(%ebp),%eax
80105ace:	89 04 24             	mov    %eax,(%esp)
80105ad1:	e8 ab 00 00 00       	call   80105b81 <holding>
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	75 0c                	jne    80105ae6 <release+0x21>
    panic("release");
80105ada:	c7 04 24 45 95 10 80 	movl   $0x80109545,(%esp)
80105ae1:	e8 57 aa ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105af0:	8b 45 08             	mov    0x8(%ebp),%eax
80105af3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105afa:	8b 45 08             	mov    0x8(%ebp),%eax
80105afd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b04:	00 
80105b05:	89 04 24             	mov    %eax,(%esp)
80105b08:	e8 10 ff ff ff       	call   80105a1d <xchg>

  popcli();
80105b0d:	e8 e1 00 00 00       	call   80105bf3 <popcli>
}
80105b12:	c9                   	leave  
80105b13:	c3                   	ret    

80105b14 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105b14:	55                   	push   %ebp
80105b15:	89 e5                	mov    %esp,%ebp
80105b17:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b1d:	83 e8 08             	sub    $0x8,%eax
80105b20:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105b23:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105b2a:	eb 32                	jmp    80105b5e <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105b2c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105b30:	74 47                	je     80105b79 <getcallerpcs+0x65>
80105b32:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105b39:	76 3e                	jbe    80105b79 <getcallerpcs+0x65>
80105b3b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105b3f:	74 38                	je     80105b79 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105b41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b44:	c1 e0 02             	shl    $0x2,%eax
80105b47:	03 45 0c             	add    0xc(%ebp),%eax
80105b4a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b4d:	8b 52 04             	mov    0x4(%edx),%edx
80105b50:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b55:	8b 00                	mov    (%eax),%eax
80105b57:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105b5a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105b5e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105b62:	7e c8                	jle    80105b2c <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105b64:	eb 13                	jmp    80105b79 <getcallerpcs+0x65>
    pcs[i] = 0;
80105b66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b69:	c1 e0 02             	shl    $0x2,%eax
80105b6c:	03 45 0c             	add    0xc(%ebp),%eax
80105b6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105b75:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105b79:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105b7d:	7e e7                	jle    80105b66 <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105b7f:	c9                   	leave  
80105b80:	c3                   	ret    

80105b81 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105b81:	55                   	push   %ebp
80105b82:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105b84:	8b 45 08             	mov    0x8(%ebp),%eax
80105b87:	8b 00                	mov    (%eax),%eax
80105b89:	85 c0                	test   %eax,%eax
80105b8b:	74 17                	je     80105ba4 <holding+0x23>
80105b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105b90:	8b 50 08             	mov    0x8(%eax),%edx
80105b93:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b99:	39 c2                	cmp    %eax,%edx
80105b9b:	75 07                	jne    80105ba4 <holding+0x23>
80105b9d:	b8 01 00 00 00       	mov    $0x1,%eax
80105ba2:	eb 05                	jmp    80105ba9 <holding+0x28>
80105ba4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba9:	5d                   	pop    %ebp
80105baa:	c3                   	ret    

80105bab <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105bab:	55                   	push   %ebp
80105bac:	89 e5                	mov    %esp,%ebp
80105bae:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105bb1:	e8 46 fe ff ff       	call   801059fc <readeflags>
80105bb6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105bb9:	e8 53 fe ff ff       	call   80105a11 <cli>
  if(cpu->ncli++ == 0)
80105bbe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105bc4:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105bca:	85 d2                	test   %edx,%edx
80105bcc:	0f 94 c1             	sete   %cl
80105bcf:	83 c2 01             	add    $0x1,%edx
80105bd2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105bd8:	84 c9                	test   %cl,%cl
80105bda:	74 15                	je     80105bf1 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105bdc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105be2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105be5:	81 e2 00 02 00 00    	and    $0x200,%edx
80105beb:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105bf1:	c9                   	leave  
80105bf2:	c3                   	ret    

80105bf3 <popcli>:

void
popcli(void)
{
80105bf3:	55                   	push   %ebp
80105bf4:	89 e5                	mov    %esp,%ebp
80105bf6:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105bf9:	e8 fe fd ff ff       	call   801059fc <readeflags>
80105bfe:	25 00 02 00 00       	and    $0x200,%eax
80105c03:	85 c0                	test   %eax,%eax
80105c05:	74 0c                	je     80105c13 <popcli+0x20>
    panic("popcli - interruptible");
80105c07:	c7 04 24 4d 95 10 80 	movl   $0x8010954d,(%esp)
80105c0e:	e8 2a a9 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105c13:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c19:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105c1f:	83 ea 01             	sub    $0x1,%edx
80105c22:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105c28:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105c2e:	85 c0                	test   %eax,%eax
80105c30:	79 0c                	jns    80105c3e <popcli+0x4b>
    panic("popcli");
80105c32:	c7 04 24 64 95 10 80 	movl   $0x80109564,(%esp)
80105c39:	e8 ff a8 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105c3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c44:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105c4a:	85 c0                	test   %eax,%eax
80105c4c:	75 15                	jne    80105c63 <popcli+0x70>
80105c4e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c54:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105c5a:	85 c0                	test   %eax,%eax
80105c5c:	74 05                	je     80105c63 <popcli+0x70>
    sti();
80105c5e:	e8 b4 fd ff ff       	call   80105a17 <sti>
}
80105c63:	c9                   	leave  
80105c64:	c3                   	ret    
80105c65:	00 00                	add    %al,(%eax)
	...

80105c68 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105c68:	55                   	push   %ebp
80105c69:	89 e5                	mov    %esp,%ebp
80105c6b:	57                   	push   %edi
80105c6c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105c6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c70:	8b 55 10             	mov    0x10(%ebp),%edx
80105c73:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c76:	89 cb                	mov    %ecx,%ebx
80105c78:	89 df                	mov    %ebx,%edi
80105c7a:	89 d1                	mov    %edx,%ecx
80105c7c:	fc                   	cld    
80105c7d:	f3 aa                	rep stos %al,%es:(%edi)
80105c7f:	89 ca                	mov    %ecx,%edx
80105c81:	89 fb                	mov    %edi,%ebx
80105c83:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105c86:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105c89:	5b                   	pop    %ebx
80105c8a:	5f                   	pop    %edi
80105c8b:	5d                   	pop    %ebp
80105c8c:	c3                   	ret    

80105c8d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105c8d:	55                   	push   %ebp
80105c8e:	89 e5                	mov    %esp,%ebp
80105c90:	57                   	push   %edi
80105c91:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c95:	8b 55 10             	mov    0x10(%ebp),%edx
80105c98:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c9b:	89 cb                	mov    %ecx,%ebx
80105c9d:	89 df                	mov    %ebx,%edi
80105c9f:	89 d1                	mov    %edx,%ecx
80105ca1:	fc                   	cld    
80105ca2:	f3 ab                	rep stos %eax,%es:(%edi)
80105ca4:	89 ca                	mov    %ecx,%edx
80105ca6:	89 fb                	mov    %edi,%ebx
80105ca8:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105cab:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105cae:	5b                   	pop    %ebx
80105caf:	5f                   	pop    %edi
80105cb0:	5d                   	pop    %ebp
80105cb1:	c3                   	ret    

80105cb2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105cb2:	55                   	push   %ebp
80105cb3:	89 e5                	mov    %esp,%ebp
80105cb5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80105cbb:	83 e0 03             	and    $0x3,%eax
80105cbe:	85 c0                	test   %eax,%eax
80105cc0:	75 49                	jne    80105d0b <memset+0x59>
80105cc2:	8b 45 10             	mov    0x10(%ebp),%eax
80105cc5:	83 e0 03             	and    $0x3,%eax
80105cc8:	85 c0                	test   %eax,%eax
80105cca:	75 3f                	jne    80105d0b <memset+0x59>
    c &= 0xFF;
80105ccc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105cd3:	8b 45 10             	mov    0x10(%ebp),%eax
80105cd6:	c1 e8 02             	shr    $0x2,%eax
80105cd9:	89 c2                	mov    %eax,%edx
80105cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cde:	89 c1                	mov    %eax,%ecx
80105ce0:	c1 e1 18             	shl    $0x18,%ecx
80105ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ce6:	c1 e0 10             	shl    $0x10,%eax
80105ce9:	09 c1                	or     %eax,%ecx
80105ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cee:	c1 e0 08             	shl    $0x8,%eax
80105cf1:	09 c8                	or     %ecx,%eax
80105cf3:	0b 45 0c             	or     0xc(%ebp),%eax
80105cf6:	89 54 24 08          	mov    %edx,0x8(%esp)
80105cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 84 ff ff ff       	call   80105c8d <stosl>
80105d09:	eb 19                	jmp    80105d24 <memset+0x72>
  } else
    stosb(dst, c, n);
80105d0b:	8b 45 10             	mov    0x10(%ebp),%eax
80105d0e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d15:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d19:	8b 45 08             	mov    0x8(%ebp),%eax
80105d1c:	89 04 24             	mov    %eax,(%esp)
80105d1f:	e8 44 ff ff ff       	call   80105c68 <stosb>
  return dst;
80105d24:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105d27:	c9                   	leave  
80105d28:	c3                   	ret    

80105d29 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105d29:	55                   	push   %ebp
80105d2a:	89 e5                	mov    %esp,%ebp
80105d2c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105d35:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105d3b:	eb 32                	jmp    80105d6f <memcmp+0x46>
    if(*s1 != *s2)
80105d3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d40:	0f b6 10             	movzbl (%eax),%edx
80105d43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d46:	0f b6 00             	movzbl (%eax),%eax
80105d49:	38 c2                	cmp    %al,%dl
80105d4b:	74 1a                	je     80105d67 <memcmp+0x3e>
      return *s1 - *s2;
80105d4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d50:	0f b6 00             	movzbl (%eax),%eax
80105d53:	0f b6 d0             	movzbl %al,%edx
80105d56:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d59:	0f b6 00             	movzbl (%eax),%eax
80105d5c:	0f b6 c0             	movzbl %al,%eax
80105d5f:	89 d1                	mov    %edx,%ecx
80105d61:	29 c1                	sub    %eax,%ecx
80105d63:	89 c8                	mov    %ecx,%eax
80105d65:	eb 1c                	jmp    80105d83 <memcmp+0x5a>
    s1++, s2++;
80105d67:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d6b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105d6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d73:	0f 95 c0             	setne  %al
80105d76:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105d7a:	84 c0                	test   %al,%al
80105d7c:	75 bf                	jne    80105d3d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d83:	c9                   	leave  
80105d84:	c3                   	ret    

80105d85 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105d85:	55                   	push   %ebp
80105d86:	89 e5                	mov    %esp,%ebp
80105d88:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105d91:	8b 45 08             	mov    0x8(%ebp),%eax
80105d94:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105d97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d9a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d9d:	73 54                	jae    80105df3 <memmove+0x6e>
80105d9f:	8b 45 10             	mov    0x10(%ebp),%eax
80105da2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105da5:	01 d0                	add    %edx,%eax
80105da7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105daa:	76 47                	jbe    80105df3 <memmove+0x6e>
    s += n;
80105dac:	8b 45 10             	mov    0x10(%ebp),%eax
80105daf:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105db2:	8b 45 10             	mov    0x10(%ebp),%eax
80105db5:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105db8:	eb 13                	jmp    80105dcd <memmove+0x48>
      *--d = *--s;
80105dba:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105dbe:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dc5:	0f b6 10             	movzbl (%eax),%edx
80105dc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105dcb:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105dcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dd1:	0f 95 c0             	setne  %al
80105dd4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105dd8:	84 c0                	test   %al,%al
80105dda:	75 de                	jne    80105dba <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105ddc:	eb 25                	jmp    80105e03 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105dde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105de1:	0f b6 10             	movzbl (%eax),%edx
80105de4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105de7:	88 10                	mov    %dl,(%eax)
80105de9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105ded:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105df1:	eb 01                	jmp    80105df4 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105df3:	90                   	nop
80105df4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105df8:	0f 95 c0             	setne  %al
80105dfb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105dff:	84 c0                	test   %al,%al
80105e01:	75 db                	jne    80105dde <memmove+0x59>
      *d++ = *s++;

  return dst;
80105e03:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e06:	c9                   	leave  
80105e07:	c3                   	ret    

80105e08 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105e08:	55                   	push   %ebp
80105e09:	89 e5                	mov    %esp,%ebp
80105e0b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105e0e:	8b 45 10             	mov    0x10(%ebp),%eax
80105e11:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e15:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e18:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105e1f:	89 04 24             	mov    %eax,(%esp)
80105e22:	e8 5e ff ff ff       	call   80105d85 <memmove>
}
80105e27:	c9                   	leave  
80105e28:	c3                   	ret    

80105e29 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105e29:	55                   	push   %ebp
80105e2a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105e2c:	eb 0c                	jmp    80105e3a <strncmp+0x11>
    n--, p++, q++;
80105e2e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105e32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105e36:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105e3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e3e:	74 1a                	je     80105e5a <strncmp+0x31>
80105e40:	8b 45 08             	mov    0x8(%ebp),%eax
80105e43:	0f b6 00             	movzbl (%eax),%eax
80105e46:	84 c0                	test   %al,%al
80105e48:	74 10                	je     80105e5a <strncmp+0x31>
80105e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e4d:	0f b6 10             	movzbl (%eax),%edx
80105e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e53:	0f b6 00             	movzbl (%eax),%eax
80105e56:	38 c2                	cmp    %al,%dl
80105e58:	74 d4                	je     80105e2e <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105e5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e5e:	75 07                	jne    80105e67 <strncmp+0x3e>
    return 0;
80105e60:	b8 00 00 00 00       	mov    $0x0,%eax
80105e65:	eb 18                	jmp    80105e7f <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105e67:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6a:	0f b6 00             	movzbl (%eax),%eax
80105e6d:	0f b6 d0             	movzbl %al,%edx
80105e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e73:	0f b6 00             	movzbl (%eax),%eax
80105e76:	0f b6 c0             	movzbl %al,%eax
80105e79:	89 d1                	mov    %edx,%ecx
80105e7b:	29 c1                	sub    %eax,%ecx
80105e7d:	89 c8                	mov    %ecx,%eax
}
80105e7f:	5d                   	pop    %ebp
80105e80:	c3                   	ret    

80105e81 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105e81:	55                   	push   %ebp
80105e82:	89 e5                	mov    %esp,%ebp
80105e84:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105e87:	8b 45 08             	mov    0x8(%ebp),%eax
80105e8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105e8d:	90                   	nop
80105e8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e92:	0f 9f c0             	setg   %al
80105e95:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105e99:	84 c0                	test   %al,%al
80105e9b:	74 30                	je     80105ecd <strncpy+0x4c>
80105e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea0:	0f b6 10             	movzbl (%eax),%edx
80105ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea6:	88 10                	mov    %dl,(%eax)
80105ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80105eab:	0f b6 00             	movzbl (%eax),%eax
80105eae:	84 c0                	test   %al,%al
80105eb0:	0f 95 c0             	setne  %al
80105eb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105eb7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105ebb:	84 c0                	test   %al,%al
80105ebd:	75 cf                	jne    80105e8e <strncpy+0xd>
    ;
  while(n-- > 0)
80105ebf:	eb 0c                	jmp    80105ecd <strncpy+0x4c>
    *s++ = 0;
80105ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec4:	c6 00 00             	movb   $0x0,(%eax)
80105ec7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105ecb:	eb 01                	jmp    80105ece <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105ecd:	90                   	nop
80105ece:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ed2:	0f 9f c0             	setg   %al
80105ed5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105ed9:	84 c0                	test   %al,%al
80105edb:	75 e4                	jne    80105ec1 <strncpy+0x40>
    *s++ = 0;
  return os;
80105edd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ee0:	c9                   	leave  
80105ee1:	c3                   	ret    

80105ee2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105ee2:	55                   	push   %ebp
80105ee3:	89 e5                	mov    %esp,%ebp
80105ee5:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80105eeb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105eee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ef2:	7f 05                	jg     80105ef9 <safestrcpy+0x17>
    return os;
80105ef4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ef7:	eb 35                	jmp    80105f2e <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105ef9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105efd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f01:	7e 22                	jle    80105f25 <safestrcpy+0x43>
80105f03:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f06:	0f b6 10             	movzbl (%eax),%edx
80105f09:	8b 45 08             	mov    0x8(%ebp),%eax
80105f0c:	88 10                	mov    %dl,(%eax)
80105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f11:	0f b6 00             	movzbl (%eax),%eax
80105f14:	84 c0                	test   %al,%al
80105f16:	0f 95 c0             	setne  %al
80105f19:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f1d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105f21:	84 c0                	test   %al,%al
80105f23:	75 d4                	jne    80105ef9 <safestrcpy+0x17>
    ;
  *s = 0;
80105f25:	8b 45 08             	mov    0x8(%ebp),%eax
80105f28:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105f2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f2e:	c9                   	leave  
80105f2f:	c3                   	ret    

80105f30 <strlen>:

int
strlen(const char *s)
{
80105f30:	55                   	push   %ebp
80105f31:	89 e5                	mov    %esp,%ebp
80105f33:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105f36:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105f3d:	eb 04                	jmp    80105f43 <strlen+0x13>
80105f3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f46:	03 45 08             	add    0x8(%ebp),%eax
80105f49:	0f b6 00             	movzbl (%eax),%eax
80105f4c:	84 c0                	test   %al,%al
80105f4e:	75 ef                	jne    80105f3f <strlen+0xf>
    ;
  return n;
80105f50:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f53:	c9                   	leave  
80105f54:	c3                   	ret    
80105f55:	00 00                	add    %al,(%eax)
	...

80105f58 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105f58:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105f5c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105f60:	55                   	push   %ebp
  pushl %ebx
80105f61:	53                   	push   %ebx
  pushl %esi
80105f62:	56                   	push   %esi
  pushl %edi
80105f63:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105f64:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105f66:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105f68:	5f                   	pop    %edi
  popl %esi
80105f69:	5e                   	pop    %esi
  popl %ebx
80105f6a:	5b                   	pop    %ebx
  popl %ebp
80105f6b:	5d                   	pop    %ebp
  ret
80105f6c:	c3                   	ret    
80105f6d:	00 00                	add    %al,(%eax)
	...

80105f70 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105f73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f79:	8b 00                	mov    (%eax),%eax
80105f7b:	3b 45 08             	cmp    0x8(%ebp),%eax
80105f7e:	76 12                	jbe    80105f92 <fetchint+0x22>
80105f80:	8b 45 08             	mov    0x8(%ebp),%eax
80105f83:	8d 50 04             	lea    0x4(%eax),%edx
80105f86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f8c:	8b 00                	mov    (%eax),%eax
80105f8e:	39 c2                	cmp    %eax,%edx
80105f90:	76 07                	jbe    80105f99 <fetchint+0x29>
    return -1;
80105f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f97:	eb 0f                	jmp    80105fa8 <fetchint+0x38>
  *ip = *(int*)(addr);
80105f99:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9c:	8b 10                	mov    (%eax),%edx
80105f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fa1:	89 10                	mov    %edx,(%eax)
  return 0;
80105fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fa8:	5d                   	pop    %ebp
80105fa9:	c3                   	ret    

80105faa <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105faa:	55                   	push   %ebp
80105fab:	89 e5                	mov    %esp,%ebp
80105fad:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105fb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fb6:	8b 00                	mov    (%eax),%eax
80105fb8:	3b 45 08             	cmp    0x8(%ebp),%eax
80105fbb:	77 07                	ja     80105fc4 <fetchstr+0x1a>
    return -1;
80105fbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc2:	eb 48                	jmp    8010600c <fetchstr+0x62>
  *pp = (char*)addr;
80105fc4:	8b 55 08             	mov    0x8(%ebp),%edx
80105fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fca:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105fcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fd2:	8b 00                	mov    (%eax),%eax
80105fd4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fda:	8b 00                	mov    (%eax),%eax
80105fdc:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105fdf:	eb 1e                	jmp    80105fff <fetchstr+0x55>
    if(*s == 0)
80105fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fe4:	0f b6 00             	movzbl (%eax),%eax
80105fe7:	84 c0                	test   %al,%al
80105fe9:	75 10                	jne    80105ffb <fetchstr+0x51>
      return s - *pp;
80105feb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ff1:	8b 00                	mov    (%eax),%eax
80105ff3:	89 d1                	mov    %edx,%ecx
80105ff5:	29 c1                	sub    %eax,%ecx
80105ff7:	89 c8                	mov    %ecx,%eax
80105ff9:	eb 11                	jmp    8010600c <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105ffb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105fff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106002:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106005:	72 da                	jb     80105fe1 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106007:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010600c:	c9                   	leave  
8010600d:	c3                   	ret    

8010600e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010600e:	55                   	push   %ebp
8010600f:	89 e5                	mov    %esp,%ebp
80106011:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106014:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010601a:	8b 40 18             	mov    0x18(%eax),%eax
8010601d:	8b 50 44             	mov    0x44(%eax),%edx
80106020:	8b 45 08             	mov    0x8(%ebp),%eax
80106023:	c1 e0 02             	shl    $0x2,%eax
80106026:	01 d0                	add    %edx,%eax
80106028:	8d 50 04             	lea    0x4(%eax),%edx
8010602b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010602e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106032:	89 14 24             	mov    %edx,(%esp)
80106035:	e8 36 ff ff ff       	call   80105f70 <fetchint>
}
8010603a:	c9                   	leave  
8010603b:	c3                   	ret    

8010603c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010603c:	55                   	push   %ebp
8010603d:	89 e5                	mov    %esp,%ebp
8010603f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(argint(n, &i) < 0)
80106042:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106045:	89 44 24 04          	mov    %eax,0x4(%esp)
80106049:	8b 45 08             	mov    0x8(%ebp),%eax
8010604c:	89 04 24             	mov    %eax,(%esp)
8010604f:	e8 ba ff ff ff       	call   8010600e <argint>
80106054:	85 c0                	test   %eax,%eax
80106056:	79 07                	jns    8010605f <argptr+0x23>
    return -1;
80106058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605d:	eb 3d                	jmp    8010609c <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010605f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106062:	89 c2                	mov    %eax,%edx
80106064:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010606a:	8b 00                	mov    (%eax),%eax
8010606c:	39 c2                	cmp    %eax,%edx
8010606e:	73 16                	jae    80106086 <argptr+0x4a>
80106070:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106073:	89 c2                	mov    %eax,%edx
80106075:	8b 45 10             	mov    0x10(%ebp),%eax
80106078:	01 c2                	add    %eax,%edx
8010607a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106080:	8b 00                	mov    (%eax),%eax
80106082:	39 c2                	cmp    %eax,%edx
80106084:	76 07                	jbe    8010608d <argptr+0x51>
    return -1;
80106086:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608b:	eb 0f                	jmp    8010609c <argptr+0x60>
  *pp = (char*)i;
8010608d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106090:	89 c2                	mov    %eax,%edx
80106092:	8b 45 0c             	mov    0xc(%ebp),%eax
80106095:	89 10                	mov    %edx,(%eax)
  return 0;
80106097:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010609c:	c9                   	leave  
8010609d:	c3                   	ret    

8010609e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010609e:	55                   	push   %ebp
8010609f:	89 e5                	mov    %esp,%ebp
801060a1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801060a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
801060a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ab:	8b 45 08             	mov    0x8(%ebp),%eax
801060ae:	89 04 24             	mov    %eax,(%esp)
801060b1:	e8 58 ff ff ff       	call   8010600e <argint>
801060b6:	85 c0                	test   %eax,%eax
801060b8:	79 07                	jns    801060c1 <argstr+0x23>
    return -1;
801060ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060bf:	eb 12                	jmp    801060d3 <argstr+0x35>
  return fetchstr(addr, pp);
801060c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801060c7:	89 54 24 04          	mov    %edx,0x4(%esp)
801060cb:	89 04 24             	mov    %eax,(%esp)
801060ce:	e8 d7 fe ff ff       	call   80105faa <fetchstr>
}
801060d3:	c9                   	leave  
801060d4:	c3                   	ret    

801060d5 <syscall>:
[SYS_set_prio] sys_set_prio,
};

void
syscall(void)
{
801060d5:	55                   	push   %ebp
801060d6:	89 e5                	mov    %esp,%ebp
801060d8:	53                   	push   %ebx
801060d9:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801060dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060e2:	8b 40 18             	mov    0x18(%eax),%eax
801060e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801060e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801060eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ef:	7e 30                	jle    80106121 <syscall+0x4c>
801060f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f4:	83 f8 17             	cmp    $0x17,%eax
801060f7:	77 28                	ja     80106121 <syscall+0x4c>
801060f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fc:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106103:	85 c0                	test   %eax,%eax
80106105:	74 1a                	je     80106121 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010610d:	8b 58 18             	mov    0x18(%eax),%ebx
80106110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106113:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010611a:	ff d0                	call   *%eax
8010611c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010611f:	eb 3d                	jmp    8010615e <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106121:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106127:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010612a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106130:	8b 40 10             	mov    0x10(%eax),%eax
80106133:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106136:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010613a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010613e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106142:	c7 04 24 6b 95 10 80 	movl   $0x8010956b,(%esp)
80106149:	e8 53 a2 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010614e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106154:	8b 40 18             	mov    0x18(%eax),%eax
80106157:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010615e:	83 c4 24             	add    $0x24,%esp
80106161:	5b                   	pop    %ebx
80106162:	5d                   	pop    %ebp
80106163:	c3                   	ret    

80106164 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106164:	55                   	push   %ebp
80106165:	89 e5                	mov    %esp,%ebp
80106167:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010616a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010616d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106171:	8b 45 08             	mov    0x8(%ebp),%eax
80106174:	89 04 24             	mov    %eax,(%esp)
80106177:	e8 92 fe ff ff       	call   8010600e <argint>
8010617c:	85 c0                	test   %eax,%eax
8010617e:	79 07                	jns    80106187 <argfd+0x23>
    return -1;
80106180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106185:	eb 50                	jmp    801061d7 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106187:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618a:	85 c0                	test   %eax,%eax
8010618c:	78 21                	js     801061af <argfd+0x4b>
8010618e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106191:	83 f8 0f             	cmp    $0xf,%eax
80106194:	7f 19                	jg     801061af <argfd+0x4b>
80106196:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010619c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010619f:	83 c2 08             	add    $0x8,%edx
801061a2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801061a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061ad:	75 07                	jne    801061b6 <argfd+0x52>
    return -1;
801061af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b4:	eb 21                	jmp    801061d7 <argfd+0x73>
  if(pfd)
801061b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801061ba:	74 08                	je     801061c4 <argfd+0x60>
    *pfd = fd;
801061bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c2:	89 10                	mov    %edx,(%eax)
  if(pf)
801061c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801061c8:	74 08                	je     801061d2 <argfd+0x6e>
    *pf = f;
801061ca:	8b 45 10             	mov    0x10(%ebp),%eax
801061cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061d0:	89 10                	mov    %edx,(%eax)
  return 0;
801061d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d7:	c9                   	leave  
801061d8:	c3                   	ret    

801061d9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801061d9:	55                   	push   %ebp
801061da:	89 e5                	mov    %esp,%ebp
801061dc:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801061df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801061e6:	eb 30                	jmp    80106218 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801061e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061f1:	83 c2 08             	add    $0x8,%edx
801061f4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801061f8:	85 c0                	test   %eax,%eax
801061fa:	75 18                	jne    80106214 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801061fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106202:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106205:	8d 4a 08             	lea    0x8(%edx),%ecx
80106208:	8b 55 08             	mov    0x8(%ebp),%edx
8010620b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010620f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106212:	eb 0f                	jmp    80106223 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106214:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106218:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010621c:	7e ca                	jle    801061e8 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010621e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106223:	c9                   	leave  
80106224:	c3                   	ret    

80106225 <sys_dup>:

int
sys_dup(void)
{
80106225:	55                   	push   %ebp
80106226:	89 e5                	mov    %esp,%ebp
80106228:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010622b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010622e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106232:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106239:	00 
8010623a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106241:	e8 1e ff ff ff       	call   80106164 <argfd>
80106246:	85 c0                	test   %eax,%eax
80106248:	79 07                	jns    80106251 <sys_dup+0x2c>
    return -1;
8010624a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624f:	eb 29                	jmp    8010627a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	89 04 24             	mov    %eax,(%esp)
80106257:	e8 7d ff ff ff       	call   801061d9 <fdalloc>
8010625c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010625f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106263:	79 07                	jns    8010626c <sys_dup+0x47>
    return -1;
80106265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626a:	eb 0e                	jmp    8010627a <sys_dup+0x55>
  filedup(f);
8010626c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626f:	89 04 24             	mov    %eax,(%esp)
80106272:	e8 31 b5 ff ff       	call   801017a8 <filedup>
  return fd;
80106277:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010627a:	c9                   	leave  
8010627b:	c3                   	ret    

8010627c <sys_read>:

int
sys_read(void)
{
8010627c:	55                   	push   %ebp
8010627d:	89 e5                	mov    %esp,%ebp
8010627f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106282:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106285:	89 44 24 08          	mov    %eax,0x8(%esp)
80106289:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106290:	00 
80106291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106298:	e8 c7 fe ff ff       	call   80106164 <argfd>
8010629d:	85 c0                	test   %eax,%eax
8010629f:	78 35                	js     801062d6 <sys_read+0x5a>
801062a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062af:	e8 5a fd ff ff       	call   8010600e <argint>
801062b4:	85 c0                	test   %eax,%eax
801062b6:	78 1e                	js     801062d6 <sys_read+0x5a>
801062b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bb:	89 44 24 08          	mov    %eax,0x8(%esp)
801062bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062cd:	e8 6a fd ff ff       	call   8010603c <argptr>
801062d2:	85 c0                	test   %eax,%eax
801062d4:	79 07                	jns    801062dd <sys_read+0x61>
    return -1;
801062d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062db:	eb 19                	jmp    801062f6 <sys_read+0x7a>
  return fileread(f, p, n);
801062dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801062e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801062e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801062ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801062ee:	89 04 24             	mov    %eax,(%esp)
801062f1:	e8 1f b6 ff ff       	call   80101915 <fileread>
}
801062f6:	c9                   	leave  
801062f7:	c3                   	ret    

801062f8 <sys_write>:

int
sys_write(void)
{
801062f8:	55                   	push   %ebp
801062f9:	89 e5                	mov    %esp,%ebp
801062fb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801062fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106301:	89 44 24 08          	mov    %eax,0x8(%esp)
80106305:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010630c:	00 
8010630d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106314:	e8 4b fe ff ff       	call   80106164 <argfd>
80106319:	85 c0                	test   %eax,%eax
8010631b:	78 35                	js     80106352 <sys_write+0x5a>
8010631d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106320:	89 44 24 04          	mov    %eax,0x4(%esp)
80106324:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010632b:	e8 de fc ff ff       	call   8010600e <argint>
80106330:	85 c0                	test   %eax,%eax
80106332:	78 1e                	js     80106352 <sys_write+0x5a>
80106334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106337:	89 44 24 08          	mov    %eax,0x8(%esp)
8010633b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010633e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106342:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106349:	e8 ee fc ff ff       	call   8010603c <argptr>
8010634e:	85 c0                	test   %eax,%eax
80106350:	79 07                	jns    80106359 <sys_write+0x61>
    return -1;
80106352:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106357:	eb 19                	jmp    80106372 <sys_write+0x7a>
  return filewrite(f, p, n);
80106359:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010635c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010635f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106362:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106366:	89 54 24 04          	mov    %edx,0x4(%esp)
8010636a:	89 04 24             	mov    %eax,(%esp)
8010636d:	e8 5f b6 ff ff       	call   801019d1 <filewrite>
}
80106372:	c9                   	leave  
80106373:	c3                   	ret    

80106374 <sys_close>:

int
sys_close(void)
{
80106374:	55                   	push   %ebp
80106375:	89 e5                	mov    %esp,%ebp
80106377:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010637a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010637d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106381:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106384:	89 44 24 04          	mov    %eax,0x4(%esp)
80106388:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010638f:	e8 d0 fd ff ff       	call   80106164 <argfd>
80106394:	85 c0                	test   %eax,%eax
80106396:	79 07                	jns    8010639f <sys_close+0x2b>
    return -1;
80106398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639d:	eb 24                	jmp    801063c3 <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010639f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063a8:	83 c2 08             	add    $0x8,%edx
801063ab:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063b2:	00 
  fileclose(f);
801063b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b6:	89 04 24             	mov    %eax,(%esp)
801063b9:	e8 32 b4 ff ff       	call   801017f0 <fileclose>
  return 0;
801063be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063c3:	c9                   	leave  
801063c4:	c3                   	ret    

801063c5 <sys_fstat>:

int
sys_fstat(void)
{
801063c5:	55                   	push   %ebp
801063c6:	89 e5                	mov    %esp,%ebp
801063c8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801063cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801063d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063d9:	00 
801063da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e1:	e8 7e fd ff ff       	call   80106164 <argfd>
801063e6:	85 c0                	test   %eax,%eax
801063e8:	78 1f                	js     80106409 <sys_fstat+0x44>
801063ea:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801063f1:	00 
801063f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106400:	e8 37 fc ff ff       	call   8010603c <argptr>
80106405:	85 c0                	test   %eax,%eax
80106407:	79 07                	jns    80106410 <sys_fstat+0x4b>
    return -1;
80106409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640e:	eb 12                	jmp    80106422 <sys_fstat+0x5d>
  return filestat(f, st);
80106410:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106416:	89 54 24 04          	mov    %edx,0x4(%esp)
8010641a:	89 04 24             	mov    %eax,(%esp)
8010641d:	e8 a4 b4 ff ff       	call   801018c6 <filestat>
}
80106422:	c9                   	leave  
80106423:	c3                   	ret    

80106424 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106424:	55                   	push   %ebp
80106425:	89 e5                	mov    %esp,%ebp
80106427:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010642a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010642d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106438:	e8 61 fc ff ff       	call   8010609e <argstr>
8010643d:	85 c0                	test   %eax,%eax
8010643f:	78 17                	js     80106458 <sys_link+0x34>
80106441:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106444:	89 44 24 04          	mov    %eax,0x4(%esp)
80106448:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010644f:	e8 4a fc ff ff       	call   8010609e <argstr>
80106454:	85 c0                	test   %eax,%eax
80106456:	79 0a                	jns    80106462 <sys_link+0x3e>
    return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	e9 41 01 00 00       	jmp    801065a3 <sys_link+0x17f>

  begin_op();
80106462:	e8 aa d8 ff ff       	call   80103d11 <begin_op>
  if((ip = namei(old)) == 0){
80106467:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010646a:	89 04 24             	mov    %eax,(%esp)
8010646d:	e8 2b c8 ff ff       	call   80102c9d <namei>
80106472:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106475:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106479:	75 0f                	jne    8010648a <sys_link+0x66>
    end_op();
8010647b:	e8 12 d9 ff ff       	call   80103d92 <end_op>
    return -1;
80106480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106485:	e9 19 01 00 00       	jmp    801065a3 <sys_link+0x17f>
  }

  ilock(ip);
8010648a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648d:	89 04 24             	mov    %eax,(%esp)
80106490:	e8 60 bc ff ff       	call   801020f5 <ilock>
  if(ip->type == T_DIR){
80106495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106498:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010649c:	66 83 f8 01          	cmp    $0x1,%ax
801064a0:	75 1a                	jne    801064bc <sys_link+0x98>
    iunlockput(ip);
801064a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a5:	89 04 24             	mov    %eax,(%esp)
801064a8:	e8 d2 be ff ff       	call   8010237f <iunlockput>
    end_op();
801064ad:	e8 e0 d8 ff ff       	call   80103d92 <end_op>
    return -1;
801064b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b7:	e9 e7 00 00 00       	jmp    801065a3 <sys_link+0x17f>
  }

  ip->nlink++;
801064bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064c3:	8d 50 01             	lea    0x1(%eax),%edx
801064c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801064cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d0:	89 04 24             	mov    %eax,(%esp)
801064d3:	e8 5b ba ff ff       	call   80101f33 <iupdate>
  iunlock(ip);
801064d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064db:	89 04 24             	mov    %eax,(%esp)
801064de:	e8 66 bd ff ff       	call   80102249 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801064e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064e6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801064e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801064ed:	89 04 24             	mov    %eax,(%esp)
801064f0:	e8 ca c7 ff ff       	call   80102cbf <nameiparent>
801064f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064fc:	74 68                	je     80106566 <sys_link+0x142>
    goto bad;
  ilock(dp);
801064fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106501:	89 04 24             	mov    %eax,(%esp)
80106504:	e8 ec bb ff ff       	call   801020f5 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650c:	8b 10                	mov    (%eax),%edx
8010650e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106511:	8b 00                	mov    (%eax),%eax
80106513:	39 c2                	cmp    %eax,%edx
80106515:	75 20                	jne    80106537 <sys_link+0x113>
80106517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651a:	8b 40 04             	mov    0x4(%eax),%eax
8010651d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106521:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106524:	89 44 24 04          	mov    %eax,0x4(%esp)
80106528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010652b:	89 04 24             	mov    %eax,(%esp)
8010652e:	e8 a9 c4 ff ff       	call   801029dc <dirlink>
80106533:	85 c0                	test   %eax,%eax
80106535:	79 0d                	jns    80106544 <sys_link+0x120>
    iunlockput(dp);
80106537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653a:	89 04 24             	mov    %eax,(%esp)
8010653d:	e8 3d be ff ff       	call   8010237f <iunlockput>
    goto bad;
80106542:	eb 23                	jmp    80106567 <sys_link+0x143>
  }
  iunlockput(dp);
80106544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106547:	89 04 24             	mov    %eax,(%esp)
8010654a:	e8 30 be ff ff       	call   8010237f <iunlockput>
  iput(ip);
8010654f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106552:	89 04 24             	mov    %eax,(%esp)
80106555:	e8 54 bd ff ff       	call   801022ae <iput>

  end_op();
8010655a:	e8 33 d8 ff ff       	call   80103d92 <end_op>

  return 0;
8010655f:	b8 00 00 00 00       	mov    $0x0,%eax
80106564:	eb 3d                	jmp    801065a3 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106566:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656a:	89 04 24             	mov    %eax,(%esp)
8010656d:	e8 83 bb ff ff       	call   801020f5 <ilock>
  ip->nlink--;
80106572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106575:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106579:	8d 50 ff             	lea    -0x1(%eax),%edx
8010657c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106586:	89 04 24             	mov    %eax,(%esp)
80106589:	e8 a5 b9 ff ff       	call   80101f33 <iupdate>
  iunlockput(ip);
8010658e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106591:	89 04 24             	mov    %eax,(%esp)
80106594:	e8 e6 bd ff ff       	call   8010237f <iunlockput>
  end_op();
80106599:	e8 f4 d7 ff ff       	call   80103d92 <end_op>
  return -1;
8010659e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065a3:	c9                   	leave  
801065a4:	c3                   	ret    

801065a5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801065a5:	55                   	push   %ebp
801065a6:	89 e5                	mov    %esp,%ebp
801065a8:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801065ab:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801065b2:	eb 4b                	jmp    801065ff <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801065be:	00 
801065bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801065c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ca:	8b 45 08             	mov    0x8(%ebp),%eax
801065cd:	89 04 24             	mov    %eax,(%esp)
801065d0:	e8 1c c0 ff ff       	call   801025f1 <readi>
801065d5:	83 f8 10             	cmp    $0x10,%eax
801065d8:	74 0c                	je     801065e6 <isdirempty+0x41>
      panic("isdirempty: readi");
801065da:	c7 04 24 87 95 10 80 	movl   $0x80109587,(%esp)
801065e1:	e8 57 9f ff ff       	call   8010053d <panic>
    if(de.inum != 0)
801065e6:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801065ea:	66 85 c0             	test   %ax,%ax
801065ed:	74 07                	je     801065f6 <isdirempty+0x51>
      return 0;
801065ef:	b8 00 00 00 00       	mov    $0x0,%eax
801065f4:	eb 1b                	jmp    80106611 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801065f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f9:	83 c0 10             	add    $0x10,%eax
801065fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106602:	8b 45 08             	mov    0x8(%ebp),%eax
80106605:	8b 40 18             	mov    0x18(%eax),%eax
80106608:	39 c2                	cmp    %eax,%edx
8010660a:	72 a8                	jb     801065b4 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010660c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106611:	c9                   	leave  
80106612:	c3                   	ret    

80106613 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106613:	55                   	push   %ebp
80106614:	89 e5                	mov    %esp,%ebp
80106616:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106619:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010661c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106627:	e8 72 fa ff ff       	call   8010609e <argstr>
8010662c:	85 c0                	test   %eax,%eax
8010662e:	79 0a                	jns    8010663a <sys_unlink+0x27>
    return -1;
80106630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106635:	e9 af 01 00 00       	jmp    801067e9 <sys_unlink+0x1d6>

  begin_op();
8010663a:	e8 d2 d6 ff ff       	call   80103d11 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010663f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106642:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106645:	89 54 24 04          	mov    %edx,0x4(%esp)
80106649:	89 04 24             	mov    %eax,(%esp)
8010664c:	e8 6e c6 ff ff       	call   80102cbf <nameiparent>
80106651:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106654:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106658:	75 0f                	jne    80106669 <sys_unlink+0x56>
    end_op();
8010665a:	e8 33 d7 ff ff       	call   80103d92 <end_op>
    return -1;
8010665f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106664:	e9 80 01 00 00       	jmp    801067e9 <sys_unlink+0x1d6>
  }

  ilock(dp);
80106669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666c:	89 04 24             	mov    %eax,(%esp)
8010666f:	e8 81 ba ff ff       	call   801020f5 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106674:	c7 44 24 04 99 95 10 	movl   $0x80109599,0x4(%esp)
8010667b:	80 
8010667c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010667f:	89 04 24             	mov    %eax,(%esp)
80106682:	e8 6b c2 ff ff       	call   801028f2 <namecmp>
80106687:	85 c0                	test   %eax,%eax
80106689:	0f 84 45 01 00 00    	je     801067d4 <sys_unlink+0x1c1>
8010668f:	c7 44 24 04 9b 95 10 	movl   $0x8010959b,0x4(%esp)
80106696:	80 
80106697:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010669a:	89 04 24             	mov    %eax,(%esp)
8010669d:	e8 50 c2 ff ff       	call   801028f2 <namecmp>
801066a2:	85 c0                	test   %eax,%eax
801066a4:	0f 84 2a 01 00 00    	je     801067d4 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801066aa:	8d 45 c8             	lea    -0x38(%ebp),%eax
801066ad:	89 44 24 08          	mov    %eax,0x8(%esp)
801066b1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bb:	89 04 24             	mov    %eax,(%esp)
801066be:	e8 51 c2 ff ff       	call   80102914 <dirlookup>
801066c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066ca:	0f 84 03 01 00 00    	je     801067d3 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
801066d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d3:	89 04 24             	mov    %eax,(%esp)
801066d6:	e8 1a ba ff ff       	call   801020f5 <ilock>

  if(ip->nlink < 1)
801066db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066de:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066e2:	66 85 c0             	test   %ax,%ax
801066e5:	7f 0c                	jg     801066f3 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
801066e7:	c7 04 24 9e 95 10 80 	movl   $0x8010959e,(%esp)
801066ee:	e8 4a 9e ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801066f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066f6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801066fa:	66 83 f8 01          	cmp    $0x1,%ax
801066fe:	75 1f                	jne    8010671f <sys_unlink+0x10c>
80106700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106703:	89 04 24             	mov    %eax,(%esp)
80106706:	e8 9a fe ff ff       	call   801065a5 <isdirempty>
8010670b:	85 c0                	test   %eax,%eax
8010670d:	75 10                	jne    8010671f <sys_unlink+0x10c>
    iunlockput(ip);
8010670f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106712:	89 04 24             	mov    %eax,(%esp)
80106715:	e8 65 bc ff ff       	call   8010237f <iunlockput>
    goto bad;
8010671a:	e9 b5 00 00 00       	jmp    801067d4 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
8010671f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106726:	00 
80106727:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010672e:	00 
8010672f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106732:	89 04 24             	mov    %eax,(%esp)
80106735:	e8 78 f5 ff ff       	call   80105cb2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010673a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010673d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106744:	00 
80106745:	89 44 24 08          	mov    %eax,0x8(%esp)
80106749:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010674c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106753:	89 04 24             	mov    %eax,(%esp)
80106756:	e8 01 c0 ff ff       	call   8010275c <writei>
8010675b:	83 f8 10             	cmp    $0x10,%eax
8010675e:	74 0c                	je     8010676c <sys_unlink+0x159>
    panic("unlink: writei");
80106760:	c7 04 24 b0 95 10 80 	movl   $0x801095b0,(%esp)
80106767:	e8 d1 9d ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
8010676c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010676f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106773:	66 83 f8 01          	cmp    $0x1,%ax
80106777:	75 1c                	jne    80106795 <sys_unlink+0x182>
    dp->nlink--;
80106779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106780:	8d 50 ff             	lea    -0x1(%eax),%edx
80106783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106786:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010678a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678d:	89 04 24             	mov    %eax,(%esp)
80106790:	e8 9e b7 ff ff       	call   80101f33 <iupdate>
  }
  iunlockput(dp);
80106795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106798:	89 04 24             	mov    %eax,(%esp)
8010679b:	e8 df bb ff ff       	call   8010237f <iunlockput>

  ip->nlink--;
801067a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801067aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ad:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801067b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b4:	89 04 24             	mov    %eax,(%esp)
801067b7:	e8 77 b7 ff ff       	call   80101f33 <iupdate>
  iunlockput(ip);
801067bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067bf:	89 04 24             	mov    %eax,(%esp)
801067c2:	e8 b8 bb ff ff       	call   8010237f <iunlockput>

  end_op();
801067c7:	e8 c6 d5 ff ff       	call   80103d92 <end_op>

  return 0;
801067cc:	b8 00 00 00 00       	mov    $0x0,%eax
801067d1:	eb 16                	jmp    801067e9 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801067d3:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801067d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d7:	89 04 24             	mov    %eax,(%esp)
801067da:	e8 a0 bb ff ff       	call   8010237f <iunlockput>
  end_op();
801067df:	e8 ae d5 ff ff       	call   80103d92 <end_op>
  return -1;
801067e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801067e9:	c9                   	leave  
801067ea:	c3                   	ret    

801067eb <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801067eb:	55                   	push   %ebp
801067ec:	89 e5                	mov    %esp,%ebp
801067ee:	83 ec 48             	sub    $0x48,%esp
801067f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801067f4:	8b 55 10             	mov    0x10(%ebp),%edx
801067f7:	8b 45 14             	mov    0x14(%ebp),%eax
801067fa:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801067fe:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106802:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106806:	8d 45 de             	lea    -0x22(%ebp),%eax
80106809:	89 44 24 04          	mov    %eax,0x4(%esp)
8010680d:	8b 45 08             	mov    0x8(%ebp),%eax
80106810:	89 04 24             	mov    %eax,(%esp)
80106813:	e8 a7 c4 ff ff       	call   80102cbf <nameiparent>
80106818:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010681b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010681f:	75 0a                	jne    8010682b <create+0x40>
    return 0;
80106821:	b8 00 00 00 00       	mov    $0x0,%eax
80106826:	e9 7e 01 00 00       	jmp    801069a9 <create+0x1be>
  ilock(dp);
8010682b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682e:	89 04 24             	mov    %eax,(%esp)
80106831:	e8 bf b8 ff ff       	call   801020f5 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106836:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106839:	89 44 24 08          	mov    %eax,0x8(%esp)
8010683d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106840:	89 44 24 04          	mov    %eax,0x4(%esp)
80106844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106847:	89 04 24             	mov    %eax,(%esp)
8010684a:	e8 c5 c0 ff ff       	call   80102914 <dirlookup>
8010684f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106852:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106856:	74 47                	je     8010689f <create+0xb4>
    iunlockput(dp);
80106858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685b:	89 04 24             	mov    %eax,(%esp)
8010685e:	e8 1c bb ff ff       	call   8010237f <iunlockput>
    ilock(ip);
80106863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106866:	89 04 24             	mov    %eax,(%esp)
80106869:	e8 87 b8 ff ff       	call   801020f5 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010686e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106873:	75 15                	jne    8010688a <create+0x9f>
80106875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106878:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010687c:	66 83 f8 02          	cmp    $0x2,%ax
80106880:	75 08                	jne    8010688a <create+0x9f>
      return ip;
80106882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106885:	e9 1f 01 00 00       	jmp    801069a9 <create+0x1be>
    iunlockput(ip);
8010688a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010688d:	89 04 24             	mov    %eax,(%esp)
80106890:	e8 ea ba ff ff       	call   8010237f <iunlockput>
    return 0;
80106895:	b8 00 00 00 00       	mov    $0x0,%eax
8010689a:	e9 0a 01 00 00       	jmp    801069a9 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010689f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801068a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a6:	8b 00                	mov    (%eax),%eax
801068a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801068ac:	89 04 24             	mov    %eax,(%esp)
801068af:	e8 ac b5 ff ff       	call   80101e60 <ialloc>
801068b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068bb:	75 0c                	jne    801068c9 <create+0xde>
    panic("create: ialloc");
801068bd:	c7 04 24 bf 95 10 80 	movl   $0x801095bf,(%esp)
801068c4:	e8 74 9c ff ff       	call   8010053d <panic>

  ilock(ip);
801068c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068cc:	89 04 24             	mov    %eax,(%esp)
801068cf:	e8 21 b8 ff ff       	call   801020f5 <ilock>
  ip->major = major;
801068d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068d7:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801068db:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801068df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e2:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801068e6:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801068ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ed:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801068f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f6:	89 04 24             	mov    %eax,(%esp)
801068f9:	e8 35 b6 ff ff       	call   80101f33 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801068fe:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106903:	75 6a                	jne    8010696f <create+0x184>
    dp->nlink++;  // for ".."
80106905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106908:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010690c:	8d 50 01             	lea    0x1(%eax),%edx
8010690f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106912:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106919:	89 04 24             	mov    %eax,(%esp)
8010691c:	e8 12 b6 ff ff       	call   80101f33 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106921:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106924:	8b 40 04             	mov    0x4(%eax),%eax
80106927:	89 44 24 08          	mov    %eax,0x8(%esp)
8010692b:	c7 44 24 04 99 95 10 	movl   $0x80109599,0x4(%esp)
80106932:	80 
80106933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106936:	89 04 24             	mov    %eax,(%esp)
80106939:	e8 9e c0 ff ff       	call   801029dc <dirlink>
8010693e:	85 c0                	test   %eax,%eax
80106940:	78 21                	js     80106963 <create+0x178>
80106942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106945:	8b 40 04             	mov    0x4(%eax),%eax
80106948:	89 44 24 08          	mov    %eax,0x8(%esp)
8010694c:	c7 44 24 04 9b 95 10 	movl   $0x8010959b,0x4(%esp)
80106953:	80 
80106954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106957:	89 04 24             	mov    %eax,(%esp)
8010695a:	e8 7d c0 ff ff       	call   801029dc <dirlink>
8010695f:	85 c0                	test   %eax,%eax
80106961:	79 0c                	jns    8010696f <create+0x184>
      panic("create dots");
80106963:	c7 04 24 ce 95 10 80 	movl   $0x801095ce,(%esp)
8010696a:	e8 ce 9b ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010696f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106972:	8b 40 04             	mov    0x4(%eax),%eax
80106975:	89 44 24 08          	mov    %eax,0x8(%esp)
80106979:	8d 45 de             	lea    -0x22(%ebp),%eax
8010697c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106983:	89 04 24             	mov    %eax,(%esp)
80106986:	e8 51 c0 ff ff       	call   801029dc <dirlink>
8010698b:	85 c0                	test   %eax,%eax
8010698d:	79 0c                	jns    8010699b <create+0x1b0>
    panic("create: dirlink");
8010698f:	c7 04 24 da 95 10 80 	movl   $0x801095da,(%esp)
80106996:	e8 a2 9b ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010699b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699e:	89 04 24             	mov    %eax,(%esp)
801069a1:	e8 d9 b9 ff ff       	call   8010237f <iunlockput>

  return ip;
801069a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801069a9:	c9                   	leave  
801069aa:	c3                   	ret    

801069ab <sys_open>:

int
sys_open(void)
{
801069ab:	55                   	push   %ebp
801069ac:	89 e5                	mov    %esp,%ebp
801069ae:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801069b1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801069b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801069b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069bf:	e8 da f6 ff ff       	call   8010609e <argstr>
801069c4:	85 c0                	test   %eax,%eax
801069c6:	78 17                	js     801069df <sys_open+0x34>
801069c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801069cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801069cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069d6:	e8 33 f6 ff ff       	call   8010600e <argint>
801069db:	85 c0                	test   %eax,%eax
801069dd:	79 0a                	jns    801069e9 <sys_open+0x3e>
    return -1;
801069df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e4:	e9 5a 01 00 00       	jmp    80106b43 <sys_open+0x198>

  begin_op();
801069e9:	e8 23 d3 ff ff       	call   80103d11 <begin_op>

  if(omode & O_CREATE){
801069ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069f1:	25 00 02 00 00       	and    $0x200,%eax
801069f6:	85 c0                	test   %eax,%eax
801069f8:	74 3b                	je     80106a35 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801069fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801069fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106a04:	00 
80106a05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106a0c:	00 
80106a0d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106a14:	00 
80106a15:	89 04 24             	mov    %eax,(%esp)
80106a18:	e8 ce fd ff ff       	call   801067eb <create>
80106a1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106a20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a24:	75 6b                	jne    80106a91 <sys_open+0xe6>
      end_op();
80106a26:	e8 67 d3 ff ff       	call   80103d92 <end_op>
      return -1;
80106a2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a30:	e9 0e 01 00 00       	jmp    80106b43 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80106a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a38:	89 04 24             	mov    %eax,(%esp)
80106a3b:	e8 5d c2 ff ff       	call   80102c9d <namei>
80106a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a47:	75 0f                	jne    80106a58 <sys_open+0xad>
      end_op();
80106a49:	e8 44 d3 ff ff       	call   80103d92 <end_op>
      return -1;
80106a4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a53:	e9 eb 00 00 00       	jmp    80106b43 <sys_open+0x198>
    }
    ilock(ip);
80106a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5b:	89 04 24             	mov    %eax,(%esp)
80106a5e:	e8 92 b6 ff ff       	call   801020f5 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a66:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a6a:	66 83 f8 01          	cmp    $0x1,%ax
80106a6e:	75 21                	jne    80106a91 <sys_open+0xe6>
80106a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a73:	85 c0                	test   %eax,%eax
80106a75:	74 1a                	je     80106a91 <sys_open+0xe6>
      iunlockput(ip);
80106a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7a:	89 04 24             	mov    %eax,(%esp)
80106a7d:	e8 fd b8 ff ff       	call   8010237f <iunlockput>
      end_op();
80106a82:	e8 0b d3 ff ff       	call   80103d92 <end_op>
      return -1;
80106a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8c:	e9 b2 00 00 00       	jmp    80106b43 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106a91:	e8 b2 ac ff ff       	call   80101748 <filealloc>
80106a96:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a9d:	74 14                	je     80106ab3 <sys_open+0x108>
80106a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aa2:	89 04 24             	mov    %eax,(%esp)
80106aa5:	e8 2f f7 ff ff       	call   801061d9 <fdalloc>
80106aaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106aad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106ab1:	79 28                	jns    80106adb <sys_open+0x130>
    if(f)
80106ab3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ab7:	74 0b                	je     80106ac4 <sys_open+0x119>
      fileclose(f);
80106ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106abc:	89 04 24             	mov    %eax,(%esp)
80106abf:	e8 2c ad ff ff       	call   801017f0 <fileclose>
    iunlockput(ip);
80106ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac7:	89 04 24             	mov    %eax,(%esp)
80106aca:	e8 b0 b8 ff ff       	call   8010237f <iunlockput>
    end_op();
80106acf:	e8 be d2 ff ff       	call   80103d92 <end_op>
    return -1;
80106ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad9:	eb 68                	jmp    80106b43 <sys_open+0x198>
  }
  iunlock(ip);
80106adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ade:	89 04 24             	mov    %eax,(%esp)
80106ae1:	e8 63 b7 ff ff       	call   80102249 <iunlock>
  end_op();
80106ae6:	e8 a7 d2 ff ff       	call   80103d92 <end_op>

  f->type = FD_INODE;
80106aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aee:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106afa:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b00:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b0a:	83 e0 01             	and    $0x1,%eax
80106b0d:	85 c0                	test   %eax,%eax
80106b0f:	0f 94 c2             	sete   %dl
80106b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b15:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b1b:	83 e0 01             	and    $0x1,%eax
80106b1e:	84 c0                	test   %al,%al
80106b20:	75 0a                	jne    80106b2c <sys_open+0x181>
80106b22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b25:	83 e0 02             	and    $0x2,%eax
80106b28:	85 c0                	test   %eax,%eax
80106b2a:	74 07                	je     80106b33 <sys_open+0x188>
80106b2c:	b8 01 00 00 00       	mov    $0x1,%eax
80106b31:	eb 05                	jmp    80106b38 <sys_open+0x18d>
80106b33:	b8 00 00 00 00       	mov    $0x0,%eax
80106b38:	89 c2                	mov    %eax,%edx
80106b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b3d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106b43:	c9                   	leave  
80106b44:	c3                   	ret    

80106b45 <sys_mkdir>:

int
sys_mkdir(void)
{
80106b45:	55                   	push   %ebp
80106b46:	89 e5                	mov    %esp,%ebp
80106b48:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106b4b:	e8 c1 d1 ff ff       	call   80103d11 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106b50:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b53:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b5e:	e8 3b f5 ff ff       	call   8010609e <argstr>
80106b63:	85 c0                	test   %eax,%eax
80106b65:	78 2c                	js     80106b93 <sys_mkdir+0x4e>
80106b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106b71:	00 
80106b72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106b79:	00 
80106b7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106b81:	00 
80106b82:	89 04 24             	mov    %eax,(%esp)
80106b85:	e8 61 fc ff ff       	call   801067eb <create>
80106b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b91:	75 0c                	jne    80106b9f <sys_mkdir+0x5a>
    end_op();
80106b93:	e8 fa d1 ff ff       	call   80103d92 <end_op>
    return -1;
80106b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b9d:	eb 15                	jmp    80106bb4 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba2:	89 04 24             	mov    %eax,(%esp)
80106ba5:	e8 d5 b7 ff ff       	call   8010237f <iunlockput>
  end_op();
80106baa:	e8 e3 d1 ff ff       	call   80103d92 <end_op>
  return 0;
80106baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bb4:	c9                   	leave  
80106bb5:	c3                   	ret    

80106bb6 <sys_mknod>:

int
sys_mknod(void)
{
80106bb6:	55                   	push   %ebp
80106bb7:	89 e5                	mov    %esp,%ebp
80106bb9:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106bbc:	e8 50 d1 ff ff       	call   80103d11 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106bc1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bcf:	e8 ca f4 ff ff       	call   8010609e <argstr>
80106bd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bdb:	78 5e                	js     80106c3b <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106bdd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106be0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106be4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106beb:	e8 1e f4 ff ff       	call   8010600e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106bf0:	85 c0                	test   %eax,%eax
80106bf2:	78 47                	js     80106c3b <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106bf4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bfb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106c02:	e8 07 f4 ff ff       	call   8010600e <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106c07:	85 c0                	test   %eax,%eax
80106c09:	78 30                	js     80106c3b <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106c0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c0e:	0f bf c8             	movswl %ax,%ecx
80106c11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c14:	0f bf d0             	movswl %ax,%edx
80106c17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106c1a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c1e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c22:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c29:	00 
80106c2a:	89 04 24             	mov    %eax,(%esp)
80106c2d:	e8 b9 fb ff ff       	call   801067eb <create>
80106c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c39:	75 0c                	jne    80106c47 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106c3b:	e8 52 d1 ff ff       	call   80103d92 <end_op>
    return -1;
80106c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c45:	eb 15                	jmp    80106c5c <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c4a:	89 04 24             	mov    %eax,(%esp)
80106c4d:	e8 2d b7 ff ff       	call   8010237f <iunlockput>
  end_op();
80106c52:	e8 3b d1 ff ff       	call   80103d92 <end_op>
  return 0;
80106c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c5c:	c9                   	leave  
80106c5d:	c3                   	ret    

80106c5e <sys_chdir>:

int
sys_chdir(void)
{
80106c5e:	55                   	push   %ebp
80106c5f:	89 e5                	mov    %esp,%ebp
80106c61:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106c64:	e8 a8 d0 ff ff       	call   80103d11 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c77:	e8 22 f4 ff ff       	call   8010609e <argstr>
80106c7c:	85 c0                	test   %eax,%eax
80106c7e:	78 14                	js     80106c94 <sys_chdir+0x36>
80106c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c83:	89 04 24             	mov    %eax,(%esp)
80106c86:	e8 12 c0 ff ff       	call   80102c9d <namei>
80106c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c92:	75 0c                	jne    80106ca0 <sys_chdir+0x42>
    end_op();
80106c94:	e8 f9 d0 ff ff       	call   80103d92 <end_op>
    return -1;
80106c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9e:	eb 61                	jmp    80106d01 <sys_chdir+0xa3>
  }
  ilock(ip);
80106ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca3:	89 04 24             	mov    %eax,(%esp)
80106ca6:	e8 4a b4 ff ff       	call   801020f5 <ilock>
  if(ip->type != T_DIR){
80106cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106cb2:	66 83 f8 01          	cmp    $0x1,%ax
80106cb6:	74 17                	je     80106ccf <sys_chdir+0x71>
    iunlockput(ip);
80106cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cbb:	89 04 24             	mov    %eax,(%esp)
80106cbe:	e8 bc b6 ff ff       	call   8010237f <iunlockput>
    end_op();
80106cc3:	e8 ca d0 ff ff       	call   80103d92 <end_op>
    return -1;
80106cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ccd:	eb 32                	jmp    80106d01 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd2:	89 04 24             	mov    %eax,(%esp)
80106cd5:	e8 6f b5 ff ff       	call   80102249 <iunlock>
  iput(proc->cwd);
80106cda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce0:	8b 40 68             	mov    0x68(%eax),%eax
80106ce3:	89 04 24             	mov    %eax,(%esp)
80106ce6:	e8 c3 b5 ff ff       	call   801022ae <iput>
  end_op();
80106ceb:	e8 a2 d0 ff ff       	call   80103d92 <end_op>
  proc->cwd = ip;
80106cf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106cf9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106cfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d01:	c9                   	leave  
80106d02:	c3                   	ret    

80106d03 <sys_exec>:

int
sys_exec(void)
{
80106d03:	55                   	push   %ebp
80106d04:	89 e5                	mov    %esp,%ebp
80106d06:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106d0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d1a:	e8 7f f3 ff ff       	call   8010609e <argstr>
80106d1f:	85 c0                	test   %eax,%eax
80106d21:	78 1a                	js     80106d3d <sys_exec+0x3a>
80106d23:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106d29:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d34:	e8 d5 f2 ff ff       	call   8010600e <argint>
80106d39:	85 c0                	test   %eax,%eax
80106d3b:	79 0a                	jns    80106d47 <sys_exec+0x44>
    return -1;
80106d3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d42:	e9 cc 00 00 00       	jmp    80106e13 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80106d47:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106d4e:	00 
80106d4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d56:	00 
80106d57:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106d5d:	89 04 24             	mov    %eax,(%esp)
80106d60:	e8 4d ef ff ff       	call   80105cb2 <memset>
  for(i=0;; i++){
80106d65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d6f:	83 f8 1f             	cmp    $0x1f,%eax
80106d72:	76 0a                	jbe    80106d7e <sys_exec+0x7b>
      return -1;
80106d74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d79:	e9 95 00 00 00       	jmp    80106e13 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d81:	c1 e0 02             	shl    $0x2,%eax
80106d84:	89 c2                	mov    %eax,%edx
80106d86:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106d8c:	01 c2                	add    %eax,%edx
80106d8e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106d94:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d98:	89 14 24             	mov    %edx,(%esp)
80106d9b:	e8 d0 f1 ff ff       	call   80105f70 <fetchint>
80106da0:	85 c0                	test   %eax,%eax
80106da2:	79 07                	jns    80106dab <sys_exec+0xa8>
      return -1;
80106da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da9:	eb 68                	jmp    80106e13 <sys_exec+0x110>
    if(uarg == 0){
80106dab:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106db1:	85 c0                	test   %eax,%eax
80106db3:	75 26                	jne    80106ddb <sys_exec+0xd8>
      argv[i] = 0;
80106db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106dbf:	00 00 00 00 
      break;
80106dc3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106dcd:	89 54 24 04          	mov    %edx,0x4(%esp)
80106dd1:	89 04 24             	mov    %eax,(%esp)
80106dd4:	e8 43 a5 ff ff       	call   8010131c <exec>
80106dd9:	eb 38                	jmp    80106e13 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106de5:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106deb:	01 c2                	add    %eax,%edx
80106ded:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106df3:	89 54 24 04          	mov    %edx,0x4(%esp)
80106df7:	89 04 24             	mov    %eax,(%esp)
80106dfa:	e8 ab f1 ff ff       	call   80105faa <fetchstr>
80106dff:	85 c0                	test   %eax,%eax
80106e01:	79 07                	jns    80106e0a <sys_exec+0x107>
      return -1;
80106e03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e08:	eb 09                	jmp    80106e13 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106e0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106e0e:	e9 59 ff ff ff       	jmp    80106d6c <sys_exec+0x69>
  return exec(path, argv);
}
80106e13:	c9                   	leave  
80106e14:	c3                   	ret    

80106e15 <sys_pipe>:

int
sys_pipe(void)
{
80106e15:	55                   	push   %ebp
80106e16:	89 e5                	mov    %esp,%ebp
80106e18:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106e1b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106e22:	00 
80106e23:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e26:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e31:	e8 06 f2 ff ff       	call   8010603c <argptr>
80106e36:	85 c0                	test   %eax,%eax
80106e38:	79 0a                	jns    80106e44 <sys_pipe+0x2f>
    return -1;
80106e3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e3f:	e9 9b 00 00 00       	jmp    80106edf <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106e44:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e47:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e4b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e4e:	89 04 24             	mov    %eax,(%esp)
80106e51:	e8 e6 d9 ff ff       	call   8010483c <pipealloc>
80106e56:	85 c0                	test   %eax,%eax
80106e58:	79 07                	jns    80106e61 <sys_pipe+0x4c>
    return -1;
80106e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e5f:	eb 7e                	jmp    80106edf <sys_pipe+0xca>
  fd0 = -1;
80106e61:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106e68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e6b:	89 04 24             	mov    %eax,(%esp)
80106e6e:	e8 66 f3 ff ff       	call   801061d9 <fdalloc>
80106e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e7a:	78 14                	js     80106e90 <sys_pipe+0x7b>
80106e7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e7f:	89 04 24             	mov    %eax,(%esp)
80106e82:	e8 52 f3 ff ff       	call   801061d9 <fdalloc>
80106e87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e8e:	79 37                	jns    80106ec7 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106e90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e94:	78 14                	js     80106eaa <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106e96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e9f:	83 c2 08             	add    $0x8,%edx
80106ea2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106ea9:	00 
    fileclose(rf);
80106eaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ead:	89 04 24             	mov    %eax,(%esp)
80106eb0:	e8 3b a9 ff ff       	call   801017f0 <fileclose>
    fileclose(wf);
80106eb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106eb8:	89 04 24             	mov    %eax,(%esp)
80106ebb:	e8 30 a9 ff ff       	call   801017f0 <fileclose>
    return -1;
80106ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ec5:	eb 18                	jmp    80106edf <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106eca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ecd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106ed2:	8d 50 04             	lea    0x4(%eax),%edx
80106ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ed8:	89 02                	mov    %eax,(%edx)
  return 0;
80106eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106edf:	c9                   	leave  
80106ee0:	c3                   	ret    
80106ee1:	00 00                	add    %al,(%eax)
	...

80106ee4 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106ee4:	55                   	push   %ebp
80106ee5:	89 e5                	mov    %esp,%ebp
80106ee7:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106eea:	e8 10 e0 ff ff       	call   80104eff <fork>
}
80106eef:	c9                   	leave  
80106ef0:	c3                   	ret    

80106ef1 <sys_exit>:

int
sys_exit(void)
{
80106ef1:	55                   	push   %ebp
80106ef2:	89 e5                	mov    %esp,%ebp
80106ef4:	83 ec 08             	sub    $0x8,%esp
  exit();
80106ef7:	e8 93 e1 ff ff       	call   8010508f <exit>
  return 0;  // not reached
80106efc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f01:	c9                   	leave  
80106f02:	c3                   	ret    

80106f03 <sys_wait>:

int
sys_wait(void)
{
80106f03:	55                   	push   %ebp
80106f04:	89 e5                	mov    %esp,%ebp
80106f06:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106f09:	e8 a6 e2 ff ff       	call   801051b4 <wait>
}
80106f0e:	c9                   	leave  
80106f0f:	c3                   	ret    

80106f10 <sys_kill>:

int
sys_kill(void)
{
80106f10:	55                   	push   %ebp
80106f11:	89 e5                	mov    %esp,%ebp
80106f13:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f19:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f24:	e8 e5 f0 ff ff       	call   8010600e <argint>
80106f29:	85 c0                	test   %eax,%eax
80106f2b:	79 07                	jns    80106f34 <sys_kill+0x24>
    return -1;
80106f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f32:	eb 0b                	jmp    80106f3f <sys_kill+0x2f>
  return kill(pid);
80106f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f37:	89 04 24             	mov    %eax,(%esp)
80106f3a:	e8 39 e8 ff ff       	call   80105778 <kill>
}
80106f3f:	c9                   	leave  
80106f40:	c3                   	ret    

80106f41 <sys_getpid>:

int
sys_getpid(void)
{
80106f41:	55                   	push   %ebp
80106f42:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106f44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80106f4d:	5d                   	pop    %ebp
80106f4e:	c3                   	ret    

80106f4f <sys_sbrk>:

int
sys_sbrk(void)
{
80106f4f:	55                   	push   %ebp
80106f50:	89 e5                	mov    %esp,%ebp
80106f52:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106f55:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f58:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f63:	e8 a6 f0 ff ff       	call   8010600e <argint>
80106f68:	85 c0                	test   %eax,%eax
80106f6a:	79 07                	jns    80106f73 <sys_sbrk+0x24>
    return -1;
80106f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f71:	eb 24                	jmp    80106f97 <sys_sbrk+0x48>
  addr = proc->sz;
80106f73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f79:	8b 00                	mov    (%eax),%eax
80106f7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f81:	89 04 24             	mov    %eax,(%esp)
80106f84:	e8 d1 de ff ff       	call   80104e5a <growproc>
80106f89:	85 c0                	test   %eax,%eax
80106f8b:	79 07                	jns    80106f94 <sys_sbrk+0x45>
    return -1;
80106f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f92:	eb 03                	jmp    80106f97 <sys_sbrk+0x48>
  return addr;
80106f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106f97:	c9                   	leave  
80106f98:	c3                   	ret    

80106f99 <sys_sleep>:

int
sys_sleep(void)
{
80106f99:	55                   	push   %ebp
80106f9a:	89 e5                	mov    %esp,%ebp
80106f9c:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106f9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fad:	e8 5c f0 ff ff       	call   8010600e <argint>
80106fb2:	85 c0                	test   %eax,%eax
80106fb4:	79 07                	jns    80106fbd <sys_sleep+0x24>
    return -1;
80106fb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fbb:	eb 6c                	jmp    80107029 <sys_sleep+0x90>
  acquire(&tickslock);
80106fbd:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
80106fc4:	e8 9a ea ff ff       	call   80105a63 <acquire>
  ticks0 = ticks;
80106fc9:	a1 00 6e 11 80       	mov    0x80116e00,%eax
80106fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106fd1:	eb 34                	jmp    80107007 <sys_sleep+0x6e>
    if(proc->killed){
80106fd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fd9:	8b 40 24             	mov    0x24(%eax),%eax
80106fdc:	85 c0                	test   %eax,%eax
80106fde:	74 13                	je     80106ff3 <sys_sleep+0x5a>
      release(&tickslock);
80106fe0:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
80106fe7:	e8 d9 ea ff ff       	call   80105ac5 <release>
      return -1;
80106fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff1:	eb 36                	jmp    80107029 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106ff3:	c7 44 24 04 c0 65 11 	movl   $0x801165c0,0x4(%esp)
80106ffa:	80 
80106ffb:	c7 04 24 00 6e 11 80 	movl   $0x80116e00,(%esp)
80107002:	e8 6a e6 ff ff       	call   80105671 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107007:	a1 00 6e 11 80       	mov    0x80116e00,%eax
8010700c:	89 c2                	mov    %eax,%edx
8010700e:	2b 55 f4             	sub    -0xc(%ebp),%edx
80107011:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107014:	39 c2                	cmp    %eax,%edx
80107016:	72 bb                	jb     80106fd3 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107018:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
8010701f:	e8 a1 ea ff ff       	call   80105ac5 <release>
  return 0;
80107024:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107029:	c9                   	leave  
8010702a:	c3                   	ret    

8010702b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010702b:	55                   	push   %ebp
8010702c:	89 e5                	mov    %esp,%ebp
8010702e:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80107031:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
80107038:	e8 26 ea ff ff       	call   80105a63 <acquire>
  xticks = ticks;
8010703d:	a1 00 6e 11 80       	mov    0x80116e00,%eax
80107042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107045:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
8010704c:	e8 74 ea ff ff       	call   80105ac5 <release>
  return xticks;
80107051:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107054:	c9                   	leave  
80107055:	c3                   	ret    

80107056 <sys_wait2>:

int
sys_wait2(void)
{
80107056:	55                   	push   %ebp
80107057:	89 e5                	mov    %esp,%ebp
80107059:	83 ec 28             	sub    $0x28,%esp
  int retime;
  int rutime;
  int stime;
  if(argint(0,&retime) < 0)
8010705c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010705f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010706a:	e8 9f ef ff ff       	call   8010600e <argint>
8010706f:	85 c0                	test   %eax,%eax
80107071:	79 07                	jns    8010707a <sys_wait2+0x24>
    return -1;
80107073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107078:	eb 59                	jmp    801070d3 <sys_wait2+0x7d>
  if(argint(1,&rutime) < 0)
8010707a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010707d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107081:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107088:	e8 81 ef ff ff       	call   8010600e <argint>
8010708d:	85 c0                	test   %eax,%eax
8010708f:	79 07                	jns    80107098 <sys_wait2+0x42>
    return -1;
80107091:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107096:	eb 3b                	jmp    801070d3 <sys_wait2+0x7d>
  if(argint(2,&stime) < 0)
80107098:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010709b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010709f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801070a6:	e8 63 ef ff ff       	call   8010600e <argint>
801070ab:	85 c0                	test   %eax,%eax
801070ad:	79 07                	jns    801070b6 <sys_wait2+0x60>
    return -1;
801070af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b4:	eb 1d                	jmp    801070d3 <sys_wait2+0x7d>
  return wait2((int*)retime, (int*)rutime, (int*)stime);
801070b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070b9:	89 c1                	mov    %eax,%ecx
801070bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070be:	89 c2                	mov    %eax,%edx
801070c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801070c7:	89 54 24 04          	mov    %edx,0x4(%esp)
801070cb:	89 04 24             	mov    %eax,(%esp)
801070ce:	e8 7d e8 ff ff       	call   80105950 <wait2>
}
801070d3:	c9                   	leave  
801070d4:	c3                   	ret    

801070d5 <sys_set_prio>:


int
sys_set_prio(void)
{
801070d5:	55                   	push   %ebp
801070d6:	89 e5                	mov    %esp,%ebp
801070d8:	83 ec 28             	sub    $0x28,%esp
  int priority;
  if (argint(0,&priority) <0)
801070db:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070de:	89 44 24 04          	mov    %eax,0x4(%esp)
801070e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070e9:	e8 20 ef ff ff       	call   8010600e <argint>
801070ee:	85 c0                	test   %eax,%eax
801070f0:	79 07                	jns    801070f9 <sys_set_prio+0x24>
    return -1;
801070f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f7:	eb 0b                	jmp    80107104 <sys_set_prio+0x2f>
  return set_prio(priority);
801070f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fc:	89 04 24             	mov    %eax,(%esp)
801070ff:	e8 c1 e8 ff ff       	call   801059c5 <set_prio>
}
80107104:	c9                   	leave  
80107105:	c3                   	ret    
	...

80107108 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107108:	55                   	push   %ebp
80107109:	89 e5                	mov    %esp,%ebp
8010710b:	83 ec 08             	sub    $0x8,%esp
8010710e:	8b 55 08             	mov    0x8(%ebp),%edx
80107111:	8b 45 0c             	mov    0xc(%ebp),%eax
80107114:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107118:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010711b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010711f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107123:	ee                   	out    %al,(%dx)
}
80107124:	c9                   	leave  
80107125:	c3                   	ret    

80107126 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107126:	55                   	push   %ebp
80107127:	89 e5                	mov    %esp,%ebp
80107129:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010712c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80107133:	00 
80107134:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010713b:	e8 c8 ff ff ff       	call   80107108 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107140:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80107147:	00 
80107148:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010714f:	e8 b4 ff ff ff       	call   80107108 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107154:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010715b:	00 
8010715c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80107163:	e8 a0 ff ff ff       	call   80107108 <outb>
  picenable(IRQ_TIMER);
80107168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010716f:	e8 51 d5 ff ff       	call   801046c5 <picenable>
}
80107174:	c9                   	leave  
80107175:	c3                   	ret    
	...

80107178 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107178:	1e                   	push   %ds
  pushl %es
80107179:	06                   	push   %es
  pushl %fs
8010717a:	0f a0                	push   %fs
  pushl %gs
8010717c:	0f a8                	push   %gs
  pushal
8010717e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010717f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107183:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107185:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107187:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010718b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010718d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010718f:	54                   	push   %esp
  call trap
80107190:	e8 de 01 00 00       	call   80107373 <trap>
  addl $4, %esp
80107195:	83 c4 04             	add    $0x4,%esp

80107198 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107198:	61                   	popa   
  popl %gs
80107199:	0f a9                	pop    %gs
  popl %fs
8010719b:	0f a1                	pop    %fs
  popl %es
8010719d:	07                   	pop    %es
  popl %ds
8010719e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010719f:	83 c4 08             	add    $0x8,%esp
  iret
801071a2:	cf                   	iret   
	...

801071a4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071a4:	55                   	push   %ebp
801071a5:	89 e5                	mov    %esp,%ebp
801071a7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801071ad:	83 e8 01             	sub    $0x1,%eax
801071b0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071b4:	8b 45 08             	mov    0x8(%ebp),%eax
801071b7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071bb:	8b 45 08             	mov    0x8(%ebp),%eax
801071be:	c1 e8 10             	shr    $0x10,%eax
801071c1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801071c5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071c8:	0f 01 18             	lidtl  (%eax)
}
801071cb:	c9                   	leave  
801071cc:	c3                   	ret    

801071cd <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801071cd:	55                   	push   %ebp
801071ce:	89 e5                	mov    %esp,%ebp
801071d0:	53                   	push   %ebx
801071d1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801071d4:	0f 20 d3             	mov    %cr2,%ebx
801071d7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801071da:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801071dd:	83 c4 10             	add    $0x10,%esp
801071e0:	5b                   	pop    %ebx
801071e1:	5d                   	pop    %ebp
801071e2:	c3                   	ret    

801071e3 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801071e3:	55                   	push   %ebp
801071e4:	89 e5                	mov    %esp,%ebp
801071e6:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801071e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801071f0:	e9 c3 00 00 00       	jmp    801072b8 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801071f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f8:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
801071ff:	89 c2                	mov    %eax,%edx
80107201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107204:	66 89 14 c5 00 66 11 	mov    %dx,-0x7fee9a00(,%eax,8)
8010720b:	80 
8010720c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720f:	66 c7 04 c5 02 66 11 	movw   $0x8,-0x7fee99fe(,%eax,8)
80107216:	80 08 00 
80107219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721c:	0f b6 14 c5 04 66 11 	movzbl -0x7fee99fc(,%eax,8),%edx
80107223:	80 
80107224:	83 e2 e0             	and    $0xffffffe0,%edx
80107227:	88 14 c5 04 66 11 80 	mov    %dl,-0x7fee99fc(,%eax,8)
8010722e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107231:	0f b6 14 c5 04 66 11 	movzbl -0x7fee99fc(,%eax,8),%edx
80107238:	80 
80107239:	83 e2 1f             	and    $0x1f,%edx
8010723c:	88 14 c5 04 66 11 80 	mov    %dl,-0x7fee99fc(,%eax,8)
80107243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107246:	0f b6 14 c5 05 66 11 	movzbl -0x7fee99fb(,%eax,8),%edx
8010724d:	80 
8010724e:	83 e2 f0             	and    $0xfffffff0,%edx
80107251:	83 ca 0e             	or     $0xe,%edx
80107254:	88 14 c5 05 66 11 80 	mov    %dl,-0x7fee99fb(,%eax,8)
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725e:	0f b6 14 c5 05 66 11 	movzbl -0x7fee99fb(,%eax,8),%edx
80107265:	80 
80107266:	83 e2 ef             	and    $0xffffffef,%edx
80107269:	88 14 c5 05 66 11 80 	mov    %dl,-0x7fee99fb(,%eax,8)
80107270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107273:	0f b6 14 c5 05 66 11 	movzbl -0x7fee99fb(,%eax,8),%edx
8010727a:	80 
8010727b:	83 e2 9f             	and    $0xffffff9f,%edx
8010727e:	88 14 c5 05 66 11 80 	mov    %dl,-0x7fee99fb(,%eax,8)
80107285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107288:	0f b6 14 c5 05 66 11 	movzbl -0x7fee99fb(,%eax,8),%edx
8010728f:	80 
80107290:	83 ca 80             	or     $0xffffff80,%edx
80107293:	88 14 c5 05 66 11 80 	mov    %dl,-0x7fee99fb(,%eax,8)
8010729a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729d:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
801072a4:	c1 e8 10             	shr    $0x10,%eax
801072a7:	89 c2                	mov    %eax,%edx
801072a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ac:	66 89 14 c5 06 66 11 	mov    %dx,-0x7fee99fa(,%eax,8)
801072b3:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801072b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801072b8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801072bf:	0f 8e 30 ff ff ff    	jle    801071f5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801072c5:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
801072ca:	66 a3 00 68 11 80    	mov    %ax,0x80116800
801072d0:	66 c7 05 02 68 11 80 	movw   $0x8,0x80116802
801072d7:	08 00 
801072d9:	0f b6 05 04 68 11 80 	movzbl 0x80116804,%eax
801072e0:	83 e0 e0             	and    $0xffffffe0,%eax
801072e3:	a2 04 68 11 80       	mov    %al,0x80116804
801072e8:	0f b6 05 04 68 11 80 	movzbl 0x80116804,%eax
801072ef:	83 e0 1f             	and    $0x1f,%eax
801072f2:	a2 04 68 11 80       	mov    %al,0x80116804
801072f7:	0f b6 05 05 68 11 80 	movzbl 0x80116805,%eax
801072fe:	83 c8 0f             	or     $0xf,%eax
80107301:	a2 05 68 11 80       	mov    %al,0x80116805
80107306:	0f b6 05 05 68 11 80 	movzbl 0x80116805,%eax
8010730d:	83 e0 ef             	and    $0xffffffef,%eax
80107310:	a2 05 68 11 80       	mov    %al,0x80116805
80107315:	0f b6 05 05 68 11 80 	movzbl 0x80116805,%eax
8010731c:	83 c8 60             	or     $0x60,%eax
8010731f:	a2 05 68 11 80       	mov    %al,0x80116805
80107324:	0f b6 05 05 68 11 80 	movzbl 0x80116805,%eax
8010732b:	83 c8 80             	or     $0xffffff80,%eax
8010732e:	a2 05 68 11 80       	mov    %al,0x80116805
80107333:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80107338:	c1 e8 10             	shr    $0x10,%eax
8010733b:	66 a3 06 68 11 80    	mov    %ax,0x80116806

  initlock(&tickslock, "time");
80107341:	c7 44 24 04 ec 95 10 	movl   $0x801095ec,0x4(%esp)
80107348:	80 
80107349:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
80107350:	e8 ed e6 ff ff       	call   80105a42 <initlock>
}
80107355:	c9                   	leave  
80107356:	c3                   	ret    

80107357 <idtinit>:

void
idtinit(void)
{
80107357:	55                   	push   %ebp
80107358:	89 e5                	mov    %esp,%ebp
8010735a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010735d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107364:	00 
80107365:	c7 04 24 00 66 11 80 	movl   $0x80116600,(%esp)
8010736c:	e8 33 fe ff ff       	call   801071a4 <lidt>
}
80107371:	c9                   	leave  
80107372:	c3                   	ret    

80107373 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107373:	55                   	push   %ebp
80107374:	89 e5                	mov    %esp,%ebp
80107376:	57                   	push   %edi
80107377:	56                   	push   %esi
80107378:	53                   	push   %ebx
80107379:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010737c:	8b 45 08             	mov    0x8(%ebp),%eax
8010737f:	8b 40 30             	mov    0x30(%eax),%eax
80107382:	83 f8 40             	cmp    $0x40,%eax
80107385:	75 3e                	jne    801073c5 <trap+0x52>
    if(proc->killed)
80107387:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010738d:	8b 40 24             	mov    0x24(%eax),%eax
80107390:	85 c0                	test   %eax,%eax
80107392:	74 05                	je     80107399 <trap+0x26>
      exit();
80107394:	e8 f6 dc ff ff       	call   8010508f <exit>
    proc->tf = tf;
80107399:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010739f:	8b 55 08             	mov    0x8(%ebp),%edx
801073a2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801073a5:	e8 2b ed ff ff       	call   801060d5 <syscall>
    if(proc->killed)
801073aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073b0:	8b 40 24             	mov    0x24(%eax),%eax
801073b3:	85 c0                	test   %eax,%eax
801073b5:	0f 84 5a 02 00 00    	je     80107615 <trap+0x2a2>
      exit();
801073bb:	e8 cf dc ff ff       	call   8010508f <exit>
    return;
801073c0:	e9 50 02 00 00       	jmp    80107615 <trap+0x2a2>
  }

  switch(tf->trapno){
801073c5:	8b 45 08             	mov    0x8(%ebp),%eax
801073c8:	8b 40 30             	mov    0x30(%eax),%eax
801073cb:	83 e8 20             	sub    $0x20,%eax
801073ce:	83 f8 1f             	cmp    $0x1f,%eax
801073d1:	0f 87 c1 00 00 00    	ja     80107498 <trap+0x125>
801073d7:	8b 04 85 94 96 10 80 	mov    -0x7fef696c(,%eax,4),%eax
801073de:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801073e0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801073e6:	0f b6 00             	movzbl (%eax),%eax
801073e9:	84 c0                	test   %al,%al
801073eb:	75 36                	jne    80107423 <trap+0xb0>
      acquire(&tickslock);
801073ed:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
801073f4:	e8 6a e6 ff ff       	call   80105a63 <acquire>
      ticks++;
801073f9:	a1 00 6e 11 80       	mov    0x80116e00,%eax
801073fe:	83 c0 01             	add    $0x1,%eax
80107401:	a3 00 6e 11 80       	mov    %eax,0x80116e00
      updateTimes(); // after every tick - updates the times
80107406:	e8 e4 e4 ff ff       	call   801058ef <updateTimes>
      wakeup(&ticks);
8010740b:	c7 04 24 00 6e 11 80 	movl   $0x80116e00,(%esp)
80107412:	e8 36 e3 ff ff       	call   8010574d <wakeup>
      release(&tickslock);
80107417:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
8010741e:	e8 a2 e6 ff ff       	call   80105ac5 <release>
    }
    lapiceoi();
80107423:	e8 b3 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107428:	e9 41 01 00 00       	jmp    8010756e <trap+0x1fb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010742d:	e8 8a bb ff ff       	call   80102fbc <ideintr>
    lapiceoi();
80107432:	e8 a4 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107437:	e9 32 01 00 00       	jmp    8010756e <trap+0x1fb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010743c:	e8 4e c1 ff ff       	call   8010358f <kbdintr>
    lapiceoi();
80107441:	e8 95 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107446:	e9 23 01 00 00       	jmp    8010756e <trap+0x1fb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010744b:	e8 cc 03 00 00       	call   8010781c <uartintr>
    lapiceoi();
80107450:	e8 86 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107455:	e9 14 01 00 00       	jmp    8010756e <trap+0x1fb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
8010745a:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010745d:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107460:	8b 45 08             	mov    0x8(%ebp),%eax
80107463:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107467:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010746a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107470:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107473:	0f b6 c0             	movzbl %al,%eax
80107476:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010747a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010747e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107482:	c7 04 24 f4 95 10 80 	movl   $0x801095f4,(%esp)
80107489:	e8 13 8f ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010748e:	e8 48 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107493:	e9 d6 00 00 00       	jmp    8010756e <trap+0x1fb>

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107498:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010749e:	85 c0                	test   %eax,%eax
801074a0:	74 11                	je     801074b3 <trap+0x140>
801074a2:	8b 45 08             	mov    0x8(%ebp),%eax
801074a5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801074a9:	0f b7 c0             	movzwl %ax,%eax
801074ac:	83 e0 03             	and    $0x3,%eax
801074af:	85 c0                	test   %eax,%eax
801074b1:	75 46                	jne    801074f9 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074b3:	e8 15 fd ff ff       	call   801071cd <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
801074b8:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074bb:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801074be:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801074c5:	0f b6 12             	movzbl (%edx),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074c8:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801074cb:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074ce:	8b 52 30             	mov    0x30(%edx),%edx
801074d1:	89 44 24 10          	mov    %eax,0x10(%esp)
801074d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801074d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801074dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801074e1:	c7 04 24 18 96 10 80 	movl   $0x80109618,(%esp)
801074e8:	e8 b4 8e ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801074ed:	c7 04 24 4a 96 10 80 	movl   $0x8010964a,(%esp)
801074f4:	e8 44 90 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801074f9:	e8 cf fc ff ff       	call   801071cd <rcr2>
801074fe:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107500:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107503:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107506:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010750c:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010750f:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107512:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107515:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107518:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010751b:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010751e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107524:	83 c0 6c             	add    $0x6c,%eax
80107527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010752a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107530:	8b 40 10             	mov    0x10(%eax),%eax
80107533:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80107537:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010753b:	89 74 24 14          	mov    %esi,0x14(%esp)
8010753f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107543:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107547:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010754a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010754e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107552:	c7 04 24 50 96 10 80 	movl   $0x80109650,(%esp)
80107559:	e8 43 8e ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
8010755e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107564:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010756b:	eb 01                	jmp    8010756e <trap+0x1fb>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010756d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010756e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107574:	85 c0                	test   %eax,%eax
80107576:	74 24                	je     8010759c <trap+0x229>
80107578:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010757e:	8b 40 24             	mov    0x24(%eax),%eax
80107581:	85 c0                	test   %eax,%eax
80107583:	74 17                	je     8010759c <trap+0x229>
80107585:	8b 45 08             	mov    0x8(%ebp),%eax
80107588:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010758c:	0f b7 c0             	movzwl %ax,%eax
8010758f:	83 e0 03             	and    $0x3,%eax
80107592:	83 f8 03             	cmp    $0x3,%eax
80107595:	75 05                	jne    8010759c <trap+0x229>
    exit();
80107597:	e8 f3 da ff ff       	call   8010508f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && ticks%QUANTA==0)
8010759c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075a2:	85 c0                	test   %eax,%eax
801075a4:	74 3f                	je     801075e5 <trap+0x272>
801075a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075ac:	8b 40 0c             	mov    0xc(%eax),%eax
801075af:	83 f8 04             	cmp    $0x4,%eax
801075b2:	75 31                	jne    801075e5 <trap+0x272>
801075b4:	8b 45 08             	mov    0x8(%ebp),%eax
801075b7:	8b 40 30             	mov    0x30(%eax),%eax
801075ba:	83 f8 20             	cmp    $0x20,%eax
801075bd:	75 26                	jne    801075e5 <trap+0x272>
801075bf:	8b 0d 00 6e 11 80    	mov    0x80116e00,%ecx
801075c5:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801075ca:	89 c8                	mov    %ecx,%eax
801075cc:	f7 e2                	mul    %edx
801075ce:	c1 ea 02             	shr    $0x2,%edx
801075d1:	89 d0                	mov    %edx,%eax
801075d3:	c1 e0 02             	shl    $0x2,%eax
801075d6:	01 d0                	add    %edx,%eax
801075d8:	89 ca                	mov    %ecx,%edx
801075da:	29 c2                	sub    %eax,%edx
801075dc:	85 d2                	test   %edx,%edx
801075de:	75 05                	jne    801075e5 <trap+0x272>
    yield();
801075e0:	e8 1b e0 ff ff       	call   80105600 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801075e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075eb:	85 c0                	test   %eax,%eax
801075ed:	74 27                	je     80107616 <trap+0x2a3>
801075ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f5:	8b 40 24             	mov    0x24(%eax),%eax
801075f8:	85 c0                	test   %eax,%eax
801075fa:	74 1a                	je     80107616 <trap+0x2a3>
801075fc:	8b 45 08             	mov    0x8(%ebp),%eax
801075ff:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107603:	0f b7 c0             	movzwl %ax,%eax
80107606:	83 e0 03             	and    $0x3,%eax
80107609:	83 f8 03             	cmp    $0x3,%eax
8010760c:	75 08                	jne    80107616 <trap+0x2a3>
    exit();
8010760e:	e8 7c da ff ff       	call   8010508f <exit>
80107613:	eb 01                	jmp    80107616 <trap+0x2a3>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107615:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107616:	83 c4 3c             	add    $0x3c,%esp
80107619:	5b                   	pop    %ebx
8010761a:	5e                   	pop    %esi
8010761b:	5f                   	pop    %edi
8010761c:	5d                   	pop    %ebp
8010761d:	c3                   	ret    
	...

80107620 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107620:	55                   	push   %ebp
80107621:	89 e5                	mov    %esp,%ebp
80107623:	53                   	push   %ebx
80107624:	83 ec 14             	sub    $0x14,%esp
80107627:	8b 45 08             	mov    0x8(%ebp),%eax
8010762a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010762e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80107632:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80107636:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010763a:	ec                   	in     (%dx),%al
8010763b:	89 c3                	mov    %eax,%ebx
8010763d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80107640:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80107644:	83 c4 14             	add    $0x14,%esp
80107647:	5b                   	pop    %ebx
80107648:	5d                   	pop    %ebp
80107649:	c3                   	ret    

8010764a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010764a:	55                   	push   %ebp
8010764b:	89 e5                	mov    %esp,%ebp
8010764d:	83 ec 08             	sub    $0x8,%esp
80107650:	8b 55 08             	mov    0x8(%ebp),%edx
80107653:	8b 45 0c             	mov    0xc(%ebp),%eax
80107656:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010765a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010765d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107661:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107665:	ee                   	out    %al,(%dx)
}
80107666:	c9                   	leave  
80107667:	c3                   	ret    

80107668 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107668:	55                   	push   %ebp
80107669:	89 e5                	mov    %esp,%ebp
8010766b:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010766e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107675:	00 
80107676:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010767d:	e8 c8 ff ff ff       	call   8010764a <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107682:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107689:	00 
8010768a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107691:	e8 b4 ff ff ff       	call   8010764a <outb>
  outb(COM1+0, 115200/9600);
80107696:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
8010769d:	00 
8010769e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801076a5:	e8 a0 ff ff ff       	call   8010764a <outb>
  outb(COM1+1, 0);
801076aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801076b1:	00 
801076b2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801076b9:	e8 8c ff ff ff       	call   8010764a <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801076be:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801076c5:	00 
801076c6:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801076cd:	e8 78 ff ff ff       	call   8010764a <outb>
  outb(COM1+4, 0);
801076d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801076d9:	00 
801076da:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801076e1:	e8 64 ff ff ff       	call   8010764a <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801076e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801076ed:	00 
801076ee:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801076f5:	e8 50 ff ff ff       	call   8010764a <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801076fa:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107701:	e8 1a ff ff ff       	call   80107620 <inb>
80107706:	3c ff                	cmp    $0xff,%al
80107708:	74 6c                	je     80107776 <uartinit+0x10e>
    return;
  uart = 1;
8010770a:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107711:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107714:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010771b:	e8 00 ff ff ff       	call   80107620 <inb>
  inb(COM1+0);
80107720:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107727:	e8 f4 fe ff ff       	call   80107620 <inb>
  picenable(IRQ_COM1);
8010772c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107733:	e8 8d cf ff ff       	call   801046c5 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107738:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010773f:	00 
80107740:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107747:	e8 f2 ba ff ff       	call   8010323e <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010774c:	c7 45 f4 14 97 10 80 	movl   $0x80109714,-0xc(%ebp)
80107753:	eb 15                	jmp    8010776a <uartinit+0x102>
    uartputc(*p);
80107755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107758:	0f b6 00             	movzbl (%eax),%eax
8010775b:	0f be c0             	movsbl %al,%eax
8010775e:	89 04 24             	mov    %eax,(%esp)
80107761:	e8 13 00 00 00       	call   80107779 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107766:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010776a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776d:	0f b6 00             	movzbl (%eax),%eax
80107770:	84 c0                	test   %al,%al
80107772:	75 e1                	jne    80107755 <uartinit+0xed>
80107774:	eb 01                	jmp    80107777 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107776:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107777:	c9                   	leave  
80107778:	c3                   	ret    

80107779 <uartputc>:

void
uartputc(int c)
{
80107779:	55                   	push   %ebp
8010777a:	89 e5                	mov    %esp,%ebp
8010777c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010777f:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107784:	85 c0                	test   %eax,%eax
80107786:	74 4d                	je     801077d5 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107788:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010778f:	eb 10                	jmp    801077a1 <uartputc+0x28>
    microdelay(10);
80107791:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107798:	e8 63 c0 ff ff       	call   80103800 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010779d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077a1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801077a5:	7f 16                	jg     801077bd <uartputc+0x44>
801077a7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801077ae:	e8 6d fe ff ff       	call   80107620 <inb>
801077b3:	0f b6 c0             	movzbl %al,%eax
801077b6:	83 e0 20             	and    $0x20,%eax
801077b9:	85 c0                	test   %eax,%eax
801077bb:	74 d4                	je     80107791 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801077bd:	8b 45 08             	mov    0x8(%ebp),%eax
801077c0:	0f b6 c0             	movzbl %al,%eax
801077c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801077c7:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801077ce:	e8 77 fe ff ff       	call   8010764a <outb>
801077d3:	eb 01                	jmp    801077d6 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801077d5:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801077d6:	c9                   	leave  
801077d7:	c3                   	ret    

801077d8 <uartgetc>:

static int
uartgetc(void)
{
801077d8:	55                   	push   %ebp
801077d9:	89 e5                	mov    %esp,%ebp
801077db:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801077de:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801077e3:	85 c0                	test   %eax,%eax
801077e5:	75 07                	jne    801077ee <uartgetc+0x16>
    return -1;
801077e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077ec:	eb 2c                	jmp    8010781a <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801077ee:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801077f5:	e8 26 fe ff ff       	call   80107620 <inb>
801077fa:	0f b6 c0             	movzbl %al,%eax
801077fd:	83 e0 01             	and    $0x1,%eax
80107800:	85 c0                	test   %eax,%eax
80107802:	75 07                	jne    8010780b <uartgetc+0x33>
    return -1;
80107804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107809:	eb 0f                	jmp    8010781a <uartgetc+0x42>
  return inb(COM1+0);
8010780b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107812:	e8 09 fe ff ff       	call   80107620 <inb>
80107817:	0f b6 c0             	movzbl %al,%eax
}
8010781a:	c9                   	leave  
8010781b:	c3                   	ret    

8010781c <uartintr>:

void
uartintr(void)
{
8010781c:	55                   	push   %ebp
8010781d:	89 e5                	mov    %esp,%ebp
8010781f:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107822:	c7 04 24 d8 77 10 80 	movl   $0x801077d8,(%esp)
80107829:	e8 80 93 ff ff       	call   80100bae <consoleintr>
}
8010782e:	c9                   	leave  
8010782f:	c3                   	ret    

80107830 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $0
80107832:	6a 00                	push   $0x0
  jmp alltraps
80107834:	e9 3f f9 ff ff       	jmp    80107178 <alltraps>

80107839 <vector1>:
.globl vector1
vector1:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $1
8010783b:	6a 01                	push   $0x1
  jmp alltraps
8010783d:	e9 36 f9 ff ff       	jmp    80107178 <alltraps>

80107842 <vector2>:
.globl vector2
vector2:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $2
80107844:	6a 02                	push   $0x2
  jmp alltraps
80107846:	e9 2d f9 ff ff       	jmp    80107178 <alltraps>

8010784b <vector3>:
.globl vector3
vector3:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $3
8010784d:	6a 03                	push   $0x3
  jmp alltraps
8010784f:	e9 24 f9 ff ff       	jmp    80107178 <alltraps>

80107854 <vector4>:
.globl vector4
vector4:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $4
80107856:	6a 04                	push   $0x4
  jmp alltraps
80107858:	e9 1b f9 ff ff       	jmp    80107178 <alltraps>

8010785d <vector5>:
.globl vector5
vector5:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $5
8010785f:	6a 05                	push   $0x5
  jmp alltraps
80107861:	e9 12 f9 ff ff       	jmp    80107178 <alltraps>

80107866 <vector6>:
.globl vector6
vector6:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $6
80107868:	6a 06                	push   $0x6
  jmp alltraps
8010786a:	e9 09 f9 ff ff       	jmp    80107178 <alltraps>

8010786f <vector7>:
.globl vector7
vector7:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $7
80107871:	6a 07                	push   $0x7
  jmp alltraps
80107873:	e9 00 f9 ff ff       	jmp    80107178 <alltraps>

80107878 <vector8>:
.globl vector8
vector8:
  pushl $8
80107878:	6a 08                	push   $0x8
  jmp alltraps
8010787a:	e9 f9 f8 ff ff       	jmp    80107178 <alltraps>

8010787f <vector9>:
.globl vector9
vector9:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $9
80107881:	6a 09                	push   $0x9
  jmp alltraps
80107883:	e9 f0 f8 ff ff       	jmp    80107178 <alltraps>

80107888 <vector10>:
.globl vector10
vector10:
  pushl $10
80107888:	6a 0a                	push   $0xa
  jmp alltraps
8010788a:	e9 e9 f8 ff ff       	jmp    80107178 <alltraps>

8010788f <vector11>:
.globl vector11
vector11:
  pushl $11
8010788f:	6a 0b                	push   $0xb
  jmp alltraps
80107891:	e9 e2 f8 ff ff       	jmp    80107178 <alltraps>

80107896 <vector12>:
.globl vector12
vector12:
  pushl $12
80107896:	6a 0c                	push   $0xc
  jmp alltraps
80107898:	e9 db f8 ff ff       	jmp    80107178 <alltraps>

8010789d <vector13>:
.globl vector13
vector13:
  pushl $13
8010789d:	6a 0d                	push   $0xd
  jmp alltraps
8010789f:	e9 d4 f8 ff ff       	jmp    80107178 <alltraps>

801078a4 <vector14>:
.globl vector14
vector14:
  pushl $14
801078a4:	6a 0e                	push   $0xe
  jmp alltraps
801078a6:	e9 cd f8 ff ff       	jmp    80107178 <alltraps>

801078ab <vector15>:
.globl vector15
vector15:
  pushl $0
801078ab:	6a 00                	push   $0x0
  pushl $15
801078ad:	6a 0f                	push   $0xf
  jmp alltraps
801078af:	e9 c4 f8 ff ff       	jmp    80107178 <alltraps>

801078b4 <vector16>:
.globl vector16
vector16:
  pushl $0
801078b4:	6a 00                	push   $0x0
  pushl $16
801078b6:	6a 10                	push   $0x10
  jmp alltraps
801078b8:	e9 bb f8 ff ff       	jmp    80107178 <alltraps>

801078bd <vector17>:
.globl vector17
vector17:
  pushl $17
801078bd:	6a 11                	push   $0x11
  jmp alltraps
801078bf:	e9 b4 f8 ff ff       	jmp    80107178 <alltraps>

801078c4 <vector18>:
.globl vector18
vector18:
  pushl $0
801078c4:	6a 00                	push   $0x0
  pushl $18
801078c6:	6a 12                	push   $0x12
  jmp alltraps
801078c8:	e9 ab f8 ff ff       	jmp    80107178 <alltraps>

801078cd <vector19>:
.globl vector19
vector19:
  pushl $0
801078cd:	6a 00                	push   $0x0
  pushl $19
801078cf:	6a 13                	push   $0x13
  jmp alltraps
801078d1:	e9 a2 f8 ff ff       	jmp    80107178 <alltraps>

801078d6 <vector20>:
.globl vector20
vector20:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $20
801078d8:	6a 14                	push   $0x14
  jmp alltraps
801078da:	e9 99 f8 ff ff       	jmp    80107178 <alltraps>

801078df <vector21>:
.globl vector21
vector21:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $21
801078e1:	6a 15                	push   $0x15
  jmp alltraps
801078e3:	e9 90 f8 ff ff       	jmp    80107178 <alltraps>

801078e8 <vector22>:
.globl vector22
vector22:
  pushl $0
801078e8:	6a 00                	push   $0x0
  pushl $22
801078ea:	6a 16                	push   $0x16
  jmp alltraps
801078ec:	e9 87 f8 ff ff       	jmp    80107178 <alltraps>

801078f1 <vector23>:
.globl vector23
vector23:
  pushl $0
801078f1:	6a 00                	push   $0x0
  pushl $23
801078f3:	6a 17                	push   $0x17
  jmp alltraps
801078f5:	e9 7e f8 ff ff       	jmp    80107178 <alltraps>

801078fa <vector24>:
.globl vector24
vector24:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $24
801078fc:	6a 18                	push   $0x18
  jmp alltraps
801078fe:	e9 75 f8 ff ff       	jmp    80107178 <alltraps>

80107903 <vector25>:
.globl vector25
vector25:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $25
80107905:	6a 19                	push   $0x19
  jmp alltraps
80107907:	e9 6c f8 ff ff       	jmp    80107178 <alltraps>

8010790c <vector26>:
.globl vector26
vector26:
  pushl $0
8010790c:	6a 00                	push   $0x0
  pushl $26
8010790e:	6a 1a                	push   $0x1a
  jmp alltraps
80107910:	e9 63 f8 ff ff       	jmp    80107178 <alltraps>

80107915 <vector27>:
.globl vector27
vector27:
  pushl $0
80107915:	6a 00                	push   $0x0
  pushl $27
80107917:	6a 1b                	push   $0x1b
  jmp alltraps
80107919:	e9 5a f8 ff ff       	jmp    80107178 <alltraps>

8010791e <vector28>:
.globl vector28
vector28:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $28
80107920:	6a 1c                	push   $0x1c
  jmp alltraps
80107922:	e9 51 f8 ff ff       	jmp    80107178 <alltraps>

80107927 <vector29>:
.globl vector29
vector29:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $29
80107929:	6a 1d                	push   $0x1d
  jmp alltraps
8010792b:	e9 48 f8 ff ff       	jmp    80107178 <alltraps>

80107930 <vector30>:
.globl vector30
vector30:
  pushl $0
80107930:	6a 00                	push   $0x0
  pushl $30
80107932:	6a 1e                	push   $0x1e
  jmp alltraps
80107934:	e9 3f f8 ff ff       	jmp    80107178 <alltraps>

80107939 <vector31>:
.globl vector31
vector31:
  pushl $0
80107939:	6a 00                	push   $0x0
  pushl $31
8010793b:	6a 1f                	push   $0x1f
  jmp alltraps
8010793d:	e9 36 f8 ff ff       	jmp    80107178 <alltraps>

80107942 <vector32>:
.globl vector32
vector32:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $32
80107944:	6a 20                	push   $0x20
  jmp alltraps
80107946:	e9 2d f8 ff ff       	jmp    80107178 <alltraps>

8010794b <vector33>:
.globl vector33
vector33:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $33
8010794d:	6a 21                	push   $0x21
  jmp alltraps
8010794f:	e9 24 f8 ff ff       	jmp    80107178 <alltraps>

80107954 <vector34>:
.globl vector34
vector34:
  pushl $0
80107954:	6a 00                	push   $0x0
  pushl $34
80107956:	6a 22                	push   $0x22
  jmp alltraps
80107958:	e9 1b f8 ff ff       	jmp    80107178 <alltraps>

8010795d <vector35>:
.globl vector35
vector35:
  pushl $0
8010795d:	6a 00                	push   $0x0
  pushl $35
8010795f:	6a 23                	push   $0x23
  jmp alltraps
80107961:	e9 12 f8 ff ff       	jmp    80107178 <alltraps>

80107966 <vector36>:
.globl vector36
vector36:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $36
80107968:	6a 24                	push   $0x24
  jmp alltraps
8010796a:	e9 09 f8 ff ff       	jmp    80107178 <alltraps>

8010796f <vector37>:
.globl vector37
vector37:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $37
80107971:	6a 25                	push   $0x25
  jmp alltraps
80107973:	e9 00 f8 ff ff       	jmp    80107178 <alltraps>

80107978 <vector38>:
.globl vector38
vector38:
  pushl $0
80107978:	6a 00                	push   $0x0
  pushl $38
8010797a:	6a 26                	push   $0x26
  jmp alltraps
8010797c:	e9 f7 f7 ff ff       	jmp    80107178 <alltraps>

80107981 <vector39>:
.globl vector39
vector39:
  pushl $0
80107981:	6a 00                	push   $0x0
  pushl $39
80107983:	6a 27                	push   $0x27
  jmp alltraps
80107985:	e9 ee f7 ff ff       	jmp    80107178 <alltraps>

8010798a <vector40>:
.globl vector40
vector40:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $40
8010798c:	6a 28                	push   $0x28
  jmp alltraps
8010798e:	e9 e5 f7 ff ff       	jmp    80107178 <alltraps>

80107993 <vector41>:
.globl vector41
vector41:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $41
80107995:	6a 29                	push   $0x29
  jmp alltraps
80107997:	e9 dc f7 ff ff       	jmp    80107178 <alltraps>

8010799c <vector42>:
.globl vector42
vector42:
  pushl $0
8010799c:	6a 00                	push   $0x0
  pushl $42
8010799e:	6a 2a                	push   $0x2a
  jmp alltraps
801079a0:	e9 d3 f7 ff ff       	jmp    80107178 <alltraps>

801079a5 <vector43>:
.globl vector43
vector43:
  pushl $0
801079a5:	6a 00                	push   $0x0
  pushl $43
801079a7:	6a 2b                	push   $0x2b
  jmp alltraps
801079a9:	e9 ca f7 ff ff       	jmp    80107178 <alltraps>

801079ae <vector44>:
.globl vector44
vector44:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $44
801079b0:	6a 2c                	push   $0x2c
  jmp alltraps
801079b2:	e9 c1 f7 ff ff       	jmp    80107178 <alltraps>

801079b7 <vector45>:
.globl vector45
vector45:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $45
801079b9:	6a 2d                	push   $0x2d
  jmp alltraps
801079bb:	e9 b8 f7 ff ff       	jmp    80107178 <alltraps>

801079c0 <vector46>:
.globl vector46
vector46:
  pushl $0
801079c0:	6a 00                	push   $0x0
  pushl $46
801079c2:	6a 2e                	push   $0x2e
  jmp alltraps
801079c4:	e9 af f7 ff ff       	jmp    80107178 <alltraps>

801079c9 <vector47>:
.globl vector47
vector47:
  pushl $0
801079c9:	6a 00                	push   $0x0
  pushl $47
801079cb:	6a 2f                	push   $0x2f
  jmp alltraps
801079cd:	e9 a6 f7 ff ff       	jmp    80107178 <alltraps>

801079d2 <vector48>:
.globl vector48
vector48:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $48
801079d4:	6a 30                	push   $0x30
  jmp alltraps
801079d6:	e9 9d f7 ff ff       	jmp    80107178 <alltraps>

801079db <vector49>:
.globl vector49
vector49:
  pushl $0
801079db:	6a 00                	push   $0x0
  pushl $49
801079dd:	6a 31                	push   $0x31
  jmp alltraps
801079df:	e9 94 f7 ff ff       	jmp    80107178 <alltraps>

801079e4 <vector50>:
.globl vector50
vector50:
  pushl $0
801079e4:	6a 00                	push   $0x0
  pushl $50
801079e6:	6a 32                	push   $0x32
  jmp alltraps
801079e8:	e9 8b f7 ff ff       	jmp    80107178 <alltraps>

801079ed <vector51>:
.globl vector51
vector51:
  pushl $0
801079ed:	6a 00                	push   $0x0
  pushl $51
801079ef:	6a 33                	push   $0x33
  jmp alltraps
801079f1:	e9 82 f7 ff ff       	jmp    80107178 <alltraps>

801079f6 <vector52>:
.globl vector52
vector52:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $52
801079f8:	6a 34                	push   $0x34
  jmp alltraps
801079fa:	e9 79 f7 ff ff       	jmp    80107178 <alltraps>

801079ff <vector53>:
.globl vector53
vector53:
  pushl $0
801079ff:	6a 00                	push   $0x0
  pushl $53
80107a01:	6a 35                	push   $0x35
  jmp alltraps
80107a03:	e9 70 f7 ff ff       	jmp    80107178 <alltraps>

80107a08 <vector54>:
.globl vector54
vector54:
  pushl $0
80107a08:	6a 00                	push   $0x0
  pushl $54
80107a0a:	6a 36                	push   $0x36
  jmp alltraps
80107a0c:	e9 67 f7 ff ff       	jmp    80107178 <alltraps>

80107a11 <vector55>:
.globl vector55
vector55:
  pushl $0
80107a11:	6a 00                	push   $0x0
  pushl $55
80107a13:	6a 37                	push   $0x37
  jmp alltraps
80107a15:	e9 5e f7 ff ff       	jmp    80107178 <alltraps>

80107a1a <vector56>:
.globl vector56
vector56:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $56
80107a1c:	6a 38                	push   $0x38
  jmp alltraps
80107a1e:	e9 55 f7 ff ff       	jmp    80107178 <alltraps>

80107a23 <vector57>:
.globl vector57
vector57:
  pushl $0
80107a23:	6a 00                	push   $0x0
  pushl $57
80107a25:	6a 39                	push   $0x39
  jmp alltraps
80107a27:	e9 4c f7 ff ff       	jmp    80107178 <alltraps>

80107a2c <vector58>:
.globl vector58
vector58:
  pushl $0
80107a2c:	6a 00                	push   $0x0
  pushl $58
80107a2e:	6a 3a                	push   $0x3a
  jmp alltraps
80107a30:	e9 43 f7 ff ff       	jmp    80107178 <alltraps>

80107a35 <vector59>:
.globl vector59
vector59:
  pushl $0
80107a35:	6a 00                	push   $0x0
  pushl $59
80107a37:	6a 3b                	push   $0x3b
  jmp alltraps
80107a39:	e9 3a f7 ff ff       	jmp    80107178 <alltraps>

80107a3e <vector60>:
.globl vector60
vector60:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $60
80107a40:	6a 3c                	push   $0x3c
  jmp alltraps
80107a42:	e9 31 f7 ff ff       	jmp    80107178 <alltraps>

80107a47 <vector61>:
.globl vector61
vector61:
  pushl $0
80107a47:	6a 00                	push   $0x0
  pushl $61
80107a49:	6a 3d                	push   $0x3d
  jmp alltraps
80107a4b:	e9 28 f7 ff ff       	jmp    80107178 <alltraps>

80107a50 <vector62>:
.globl vector62
vector62:
  pushl $0
80107a50:	6a 00                	push   $0x0
  pushl $62
80107a52:	6a 3e                	push   $0x3e
  jmp alltraps
80107a54:	e9 1f f7 ff ff       	jmp    80107178 <alltraps>

80107a59 <vector63>:
.globl vector63
vector63:
  pushl $0
80107a59:	6a 00                	push   $0x0
  pushl $63
80107a5b:	6a 3f                	push   $0x3f
  jmp alltraps
80107a5d:	e9 16 f7 ff ff       	jmp    80107178 <alltraps>

80107a62 <vector64>:
.globl vector64
vector64:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $64
80107a64:	6a 40                	push   $0x40
  jmp alltraps
80107a66:	e9 0d f7 ff ff       	jmp    80107178 <alltraps>

80107a6b <vector65>:
.globl vector65
vector65:
  pushl $0
80107a6b:	6a 00                	push   $0x0
  pushl $65
80107a6d:	6a 41                	push   $0x41
  jmp alltraps
80107a6f:	e9 04 f7 ff ff       	jmp    80107178 <alltraps>

80107a74 <vector66>:
.globl vector66
vector66:
  pushl $0
80107a74:	6a 00                	push   $0x0
  pushl $66
80107a76:	6a 42                	push   $0x42
  jmp alltraps
80107a78:	e9 fb f6 ff ff       	jmp    80107178 <alltraps>

80107a7d <vector67>:
.globl vector67
vector67:
  pushl $0
80107a7d:	6a 00                	push   $0x0
  pushl $67
80107a7f:	6a 43                	push   $0x43
  jmp alltraps
80107a81:	e9 f2 f6 ff ff       	jmp    80107178 <alltraps>

80107a86 <vector68>:
.globl vector68
vector68:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $68
80107a88:	6a 44                	push   $0x44
  jmp alltraps
80107a8a:	e9 e9 f6 ff ff       	jmp    80107178 <alltraps>

80107a8f <vector69>:
.globl vector69
vector69:
  pushl $0
80107a8f:	6a 00                	push   $0x0
  pushl $69
80107a91:	6a 45                	push   $0x45
  jmp alltraps
80107a93:	e9 e0 f6 ff ff       	jmp    80107178 <alltraps>

80107a98 <vector70>:
.globl vector70
vector70:
  pushl $0
80107a98:	6a 00                	push   $0x0
  pushl $70
80107a9a:	6a 46                	push   $0x46
  jmp alltraps
80107a9c:	e9 d7 f6 ff ff       	jmp    80107178 <alltraps>

80107aa1 <vector71>:
.globl vector71
vector71:
  pushl $0
80107aa1:	6a 00                	push   $0x0
  pushl $71
80107aa3:	6a 47                	push   $0x47
  jmp alltraps
80107aa5:	e9 ce f6 ff ff       	jmp    80107178 <alltraps>

80107aaa <vector72>:
.globl vector72
vector72:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $72
80107aac:	6a 48                	push   $0x48
  jmp alltraps
80107aae:	e9 c5 f6 ff ff       	jmp    80107178 <alltraps>

80107ab3 <vector73>:
.globl vector73
vector73:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $73
80107ab5:	6a 49                	push   $0x49
  jmp alltraps
80107ab7:	e9 bc f6 ff ff       	jmp    80107178 <alltraps>

80107abc <vector74>:
.globl vector74
vector74:
  pushl $0
80107abc:	6a 00                	push   $0x0
  pushl $74
80107abe:	6a 4a                	push   $0x4a
  jmp alltraps
80107ac0:	e9 b3 f6 ff ff       	jmp    80107178 <alltraps>

80107ac5 <vector75>:
.globl vector75
vector75:
  pushl $0
80107ac5:	6a 00                	push   $0x0
  pushl $75
80107ac7:	6a 4b                	push   $0x4b
  jmp alltraps
80107ac9:	e9 aa f6 ff ff       	jmp    80107178 <alltraps>

80107ace <vector76>:
.globl vector76
vector76:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $76
80107ad0:	6a 4c                	push   $0x4c
  jmp alltraps
80107ad2:	e9 a1 f6 ff ff       	jmp    80107178 <alltraps>

80107ad7 <vector77>:
.globl vector77
vector77:
  pushl $0
80107ad7:	6a 00                	push   $0x0
  pushl $77
80107ad9:	6a 4d                	push   $0x4d
  jmp alltraps
80107adb:	e9 98 f6 ff ff       	jmp    80107178 <alltraps>

80107ae0 <vector78>:
.globl vector78
vector78:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $78
80107ae2:	6a 4e                	push   $0x4e
  jmp alltraps
80107ae4:	e9 8f f6 ff ff       	jmp    80107178 <alltraps>

80107ae9 <vector79>:
.globl vector79
vector79:
  pushl $0
80107ae9:	6a 00                	push   $0x0
  pushl $79
80107aeb:	6a 4f                	push   $0x4f
  jmp alltraps
80107aed:	e9 86 f6 ff ff       	jmp    80107178 <alltraps>

80107af2 <vector80>:
.globl vector80
vector80:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $80
80107af4:	6a 50                	push   $0x50
  jmp alltraps
80107af6:	e9 7d f6 ff ff       	jmp    80107178 <alltraps>

80107afb <vector81>:
.globl vector81
vector81:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $81
80107afd:	6a 51                	push   $0x51
  jmp alltraps
80107aff:	e9 74 f6 ff ff       	jmp    80107178 <alltraps>

80107b04 <vector82>:
.globl vector82
vector82:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $82
80107b06:	6a 52                	push   $0x52
  jmp alltraps
80107b08:	e9 6b f6 ff ff       	jmp    80107178 <alltraps>

80107b0d <vector83>:
.globl vector83
vector83:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $83
80107b0f:	6a 53                	push   $0x53
  jmp alltraps
80107b11:	e9 62 f6 ff ff       	jmp    80107178 <alltraps>

80107b16 <vector84>:
.globl vector84
vector84:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $84
80107b18:	6a 54                	push   $0x54
  jmp alltraps
80107b1a:	e9 59 f6 ff ff       	jmp    80107178 <alltraps>

80107b1f <vector85>:
.globl vector85
vector85:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $85
80107b21:	6a 55                	push   $0x55
  jmp alltraps
80107b23:	e9 50 f6 ff ff       	jmp    80107178 <alltraps>

80107b28 <vector86>:
.globl vector86
vector86:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $86
80107b2a:	6a 56                	push   $0x56
  jmp alltraps
80107b2c:	e9 47 f6 ff ff       	jmp    80107178 <alltraps>

80107b31 <vector87>:
.globl vector87
vector87:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $87
80107b33:	6a 57                	push   $0x57
  jmp alltraps
80107b35:	e9 3e f6 ff ff       	jmp    80107178 <alltraps>

80107b3a <vector88>:
.globl vector88
vector88:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $88
80107b3c:	6a 58                	push   $0x58
  jmp alltraps
80107b3e:	e9 35 f6 ff ff       	jmp    80107178 <alltraps>

80107b43 <vector89>:
.globl vector89
vector89:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $89
80107b45:	6a 59                	push   $0x59
  jmp alltraps
80107b47:	e9 2c f6 ff ff       	jmp    80107178 <alltraps>

80107b4c <vector90>:
.globl vector90
vector90:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $90
80107b4e:	6a 5a                	push   $0x5a
  jmp alltraps
80107b50:	e9 23 f6 ff ff       	jmp    80107178 <alltraps>

80107b55 <vector91>:
.globl vector91
vector91:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $91
80107b57:	6a 5b                	push   $0x5b
  jmp alltraps
80107b59:	e9 1a f6 ff ff       	jmp    80107178 <alltraps>

80107b5e <vector92>:
.globl vector92
vector92:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $92
80107b60:	6a 5c                	push   $0x5c
  jmp alltraps
80107b62:	e9 11 f6 ff ff       	jmp    80107178 <alltraps>

80107b67 <vector93>:
.globl vector93
vector93:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $93
80107b69:	6a 5d                	push   $0x5d
  jmp alltraps
80107b6b:	e9 08 f6 ff ff       	jmp    80107178 <alltraps>

80107b70 <vector94>:
.globl vector94
vector94:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $94
80107b72:	6a 5e                	push   $0x5e
  jmp alltraps
80107b74:	e9 ff f5 ff ff       	jmp    80107178 <alltraps>

80107b79 <vector95>:
.globl vector95
vector95:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $95
80107b7b:	6a 5f                	push   $0x5f
  jmp alltraps
80107b7d:	e9 f6 f5 ff ff       	jmp    80107178 <alltraps>

80107b82 <vector96>:
.globl vector96
vector96:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $96
80107b84:	6a 60                	push   $0x60
  jmp alltraps
80107b86:	e9 ed f5 ff ff       	jmp    80107178 <alltraps>

80107b8b <vector97>:
.globl vector97
vector97:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $97
80107b8d:	6a 61                	push   $0x61
  jmp alltraps
80107b8f:	e9 e4 f5 ff ff       	jmp    80107178 <alltraps>

80107b94 <vector98>:
.globl vector98
vector98:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $98
80107b96:	6a 62                	push   $0x62
  jmp alltraps
80107b98:	e9 db f5 ff ff       	jmp    80107178 <alltraps>

80107b9d <vector99>:
.globl vector99
vector99:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $99
80107b9f:	6a 63                	push   $0x63
  jmp alltraps
80107ba1:	e9 d2 f5 ff ff       	jmp    80107178 <alltraps>

80107ba6 <vector100>:
.globl vector100
vector100:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $100
80107ba8:	6a 64                	push   $0x64
  jmp alltraps
80107baa:	e9 c9 f5 ff ff       	jmp    80107178 <alltraps>

80107baf <vector101>:
.globl vector101
vector101:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $101
80107bb1:	6a 65                	push   $0x65
  jmp alltraps
80107bb3:	e9 c0 f5 ff ff       	jmp    80107178 <alltraps>

80107bb8 <vector102>:
.globl vector102
vector102:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $102
80107bba:	6a 66                	push   $0x66
  jmp alltraps
80107bbc:	e9 b7 f5 ff ff       	jmp    80107178 <alltraps>

80107bc1 <vector103>:
.globl vector103
vector103:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $103
80107bc3:	6a 67                	push   $0x67
  jmp alltraps
80107bc5:	e9 ae f5 ff ff       	jmp    80107178 <alltraps>

80107bca <vector104>:
.globl vector104
vector104:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $104
80107bcc:	6a 68                	push   $0x68
  jmp alltraps
80107bce:	e9 a5 f5 ff ff       	jmp    80107178 <alltraps>

80107bd3 <vector105>:
.globl vector105
vector105:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $105
80107bd5:	6a 69                	push   $0x69
  jmp alltraps
80107bd7:	e9 9c f5 ff ff       	jmp    80107178 <alltraps>

80107bdc <vector106>:
.globl vector106
vector106:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $106
80107bde:	6a 6a                	push   $0x6a
  jmp alltraps
80107be0:	e9 93 f5 ff ff       	jmp    80107178 <alltraps>

80107be5 <vector107>:
.globl vector107
vector107:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $107
80107be7:	6a 6b                	push   $0x6b
  jmp alltraps
80107be9:	e9 8a f5 ff ff       	jmp    80107178 <alltraps>

80107bee <vector108>:
.globl vector108
vector108:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $108
80107bf0:	6a 6c                	push   $0x6c
  jmp alltraps
80107bf2:	e9 81 f5 ff ff       	jmp    80107178 <alltraps>

80107bf7 <vector109>:
.globl vector109
vector109:
  pushl $0
80107bf7:	6a 00                	push   $0x0
  pushl $109
80107bf9:	6a 6d                	push   $0x6d
  jmp alltraps
80107bfb:	e9 78 f5 ff ff       	jmp    80107178 <alltraps>

80107c00 <vector110>:
.globl vector110
vector110:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $110
80107c02:	6a 6e                	push   $0x6e
  jmp alltraps
80107c04:	e9 6f f5 ff ff       	jmp    80107178 <alltraps>

80107c09 <vector111>:
.globl vector111
vector111:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $111
80107c0b:	6a 6f                	push   $0x6f
  jmp alltraps
80107c0d:	e9 66 f5 ff ff       	jmp    80107178 <alltraps>

80107c12 <vector112>:
.globl vector112
vector112:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $112
80107c14:	6a 70                	push   $0x70
  jmp alltraps
80107c16:	e9 5d f5 ff ff       	jmp    80107178 <alltraps>

80107c1b <vector113>:
.globl vector113
vector113:
  pushl $0
80107c1b:	6a 00                	push   $0x0
  pushl $113
80107c1d:	6a 71                	push   $0x71
  jmp alltraps
80107c1f:	e9 54 f5 ff ff       	jmp    80107178 <alltraps>

80107c24 <vector114>:
.globl vector114
vector114:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $114
80107c26:	6a 72                	push   $0x72
  jmp alltraps
80107c28:	e9 4b f5 ff ff       	jmp    80107178 <alltraps>

80107c2d <vector115>:
.globl vector115
vector115:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $115
80107c2f:	6a 73                	push   $0x73
  jmp alltraps
80107c31:	e9 42 f5 ff ff       	jmp    80107178 <alltraps>

80107c36 <vector116>:
.globl vector116
vector116:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $116
80107c38:	6a 74                	push   $0x74
  jmp alltraps
80107c3a:	e9 39 f5 ff ff       	jmp    80107178 <alltraps>

80107c3f <vector117>:
.globl vector117
vector117:
  pushl $0
80107c3f:	6a 00                	push   $0x0
  pushl $117
80107c41:	6a 75                	push   $0x75
  jmp alltraps
80107c43:	e9 30 f5 ff ff       	jmp    80107178 <alltraps>

80107c48 <vector118>:
.globl vector118
vector118:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $118
80107c4a:	6a 76                	push   $0x76
  jmp alltraps
80107c4c:	e9 27 f5 ff ff       	jmp    80107178 <alltraps>

80107c51 <vector119>:
.globl vector119
vector119:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $119
80107c53:	6a 77                	push   $0x77
  jmp alltraps
80107c55:	e9 1e f5 ff ff       	jmp    80107178 <alltraps>

80107c5a <vector120>:
.globl vector120
vector120:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $120
80107c5c:	6a 78                	push   $0x78
  jmp alltraps
80107c5e:	e9 15 f5 ff ff       	jmp    80107178 <alltraps>

80107c63 <vector121>:
.globl vector121
vector121:
  pushl $0
80107c63:	6a 00                	push   $0x0
  pushl $121
80107c65:	6a 79                	push   $0x79
  jmp alltraps
80107c67:	e9 0c f5 ff ff       	jmp    80107178 <alltraps>

80107c6c <vector122>:
.globl vector122
vector122:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $122
80107c6e:	6a 7a                	push   $0x7a
  jmp alltraps
80107c70:	e9 03 f5 ff ff       	jmp    80107178 <alltraps>

80107c75 <vector123>:
.globl vector123
vector123:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $123
80107c77:	6a 7b                	push   $0x7b
  jmp alltraps
80107c79:	e9 fa f4 ff ff       	jmp    80107178 <alltraps>

80107c7e <vector124>:
.globl vector124
vector124:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $124
80107c80:	6a 7c                	push   $0x7c
  jmp alltraps
80107c82:	e9 f1 f4 ff ff       	jmp    80107178 <alltraps>

80107c87 <vector125>:
.globl vector125
vector125:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $125
80107c89:	6a 7d                	push   $0x7d
  jmp alltraps
80107c8b:	e9 e8 f4 ff ff       	jmp    80107178 <alltraps>

80107c90 <vector126>:
.globl vector126
vector126:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $126
80107c92:	6a 7e                	push   $0x7e
  jmp alltraps
80107c94:	e9 df f4 ff ff       	jmp    80107178 <alltraps>

80107c99 <vector127>:
.globl vector127
vector127:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $127
80107c9b:	6a 7f                	push   $0x7f
  jmp alltraps
80107c9d:	e9 d6 f4 ff ff       	jmp    80107178 <alltraps>

80107ca2 <vector128>:
.globl vector128
vector128:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $128
80107ca4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107ca9:	e9 ca f4 ff ff       	jmp    80107178 <alltraps>

80107cae <vector129>:
.globl vector129
vector129:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $129
80107cb0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107cb5:	e9 be f4 ff ff       	jmp    80107178 <alltraps>

80107cba <vector130>:
.globl vector130
vector130:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $130
80107cbc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107cc1:	e9 b2 f4 ff ff       	jmp    80107178 <alltraps>

80107cc6 <vector131>:
.globl vector131
vector131:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $131
80107cc8:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107ccd:	e9 a6 f4 ff ff       	jmp    80107178 <alltraps>

80107cd2 <vector132>:
.globl vector132
vector132:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $132
80107cd4:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107cd9:	e9 9a f4 ff ff       	jmp    80107178 <alltraps>

80107cde <vector133>:
.globl vector133
vector133:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $133
80107ce0:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107ce5:	e9 8e f4 ff ff       	jmp    80107178 <alltraps>

80107cea <vector134>:
.globl vector134
vector134:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $134
80107cec:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107cf1:	e9 82 f4 ff ff       	jmp    80107178 <alltraps>

80107cf6 <vector135>:
.globl vector135
vector135:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $135
80107cf8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107cfd:	e9 76 f4 ff ff       	jmp    80107178 <alltraps>

80107d02 <vector136>:
.globl vector136
vector136:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $136
80107d04:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107d09:	e9 6a f4 ff ff       	jmp    80107178 <alltraps>

80107d0e <vector137>:
.globl vector137
vector137:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $137
80107d10:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107d15:	e9 5e f4 ff ff       	jmp    80107178 <alltraps>

80107d1a <vector138>:
.globl vector138
vector138:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $138
80107d1c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107d21:	e9 52 f4 ff ff       	jmp    80107178 <alltraps>

80107d26 <vector139>:
.globl vector139
vector139:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $139
80107d28:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107d2d:	e9 46 f4 ff ff       	jmp    80107178 <alltraps>

80107d32 <vector140>:
.globl vector140
vector140:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $140
80107d34:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107d39:	e9 3a f4 ff ff       	jmp    80107178 <alltraps>

80107d3e <vector141>:
.globl vector141
vector141:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $141
80107d40:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107d45:	e9 2e f4 ff ff       	jmp    80107178 <alltraps>

80107d4a <vector142>:
.globl vector142
vector142:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $142
80107d4c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107d51:	e9 22 f4 ff ff       	jmp    80107178 <alltraps>

80107d56 <vector143>:
.globl vector143
vector143:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $143
80107d58:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107d5d:	e9 16 f4 ff ff       	jmp    80107178 <alltraps>

80107d62 <vector144>:
.globl vector144
vector144:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $144
80107d64:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107d69:	e9 0a f4 ff ff       	jmp    80107178 <alltraps>

80107d6e <vector145>:
.globl vector145
vector145:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $145
80107d70:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107d75:	e9 fe f3 ff ff       	jmp    80107178 <alltraps>

80107d7a <vector146>:
.globl vector146
vector146:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $146
80107d7c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107d81:	e9 f2 f3 ff ff       	jmp    80107178 <alltraps>

80107d86 <vector147>:
.globl vector147
vector147:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $147
80107d88:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107d8d:	e9 e6 f3 ff ff       	jmp    80107178 <alltraps>

80107d92 <vector148>:
.globl vector148
vector148:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $148
80107d94:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107d99:	e9 da f3 ff ff       	jmp    80107178 <alltraps>

80107d9e <vector149>:
.globl vector149
vector149:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $149
80107da0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107da5:	e9 ce f3 ff ff       	jmp    80107178 <alltraps>

80107daa <vector150>:
.globl vector150
vector150:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $150
80107dac:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107db1:	e9 c2 f3 ff ff       	jmp    80107178 <alltraps>

80107db6 <vector151>:
.globl vector151
vector151:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $151
80107db8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107dbd:	e9 b6 f3 ff ff       	jmp    80107178 <alltraps>

80107dc2 <vector152>:
.globl vector152
vector152:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $152
80107dc4:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107dc9:	e9 aa f3 ff ff       	jmp    80107178 <alltraps>

80107dce <vector153>:
.globl vector153
vector153:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $153
80107dd0:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107dd5:	e9 9e f3 ff ff       	jmp    80107178 <alltraps>

80107dda <vector154>:
.globl vector154
vector154:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $154
80107ddc:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107de1:	e9 92 f3 ff ff       	jmp    80107178 <alltraps>

80107de6 <vector155>:
.globl vector155
vector155:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $155
80107de8:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107ded:	e9 86 f3 ff ff       	jmp    80107178 <alltraps>

80107df2 <vector156>:
.globl vector156
vector156:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $156
80107df4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107df9:	e9 7a f3 ff ff       	jmp    80107178 <alltraps>

80107dfe <vector157>:
.globl vector157
vector157:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $157
80107e00:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107e05:	e9 6e f3 ff ff       	jmp    80107178 <alltraps>

80107e0a <vector158>:
.globl vector158
vector158:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $158
80107e0c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107e11:	e9 62 f3 ff ff       	jmp    80107178 <alltraps>

80107e16 <vector159>:
.globl vector159
vector159:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $159
80107e18:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107e1d:	e9 56 f3 ff ff       	jmp    80107178 <alltraps>

80107e22 <vector160>:
.globl vector160
vector160:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $160
80107e24:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107e29:	e9 4a f3 ff ff       	jmp    80107178 <alltraps>

80107e2e <vector161>:
.globl vector161
vector161:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $161
80107e30:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107e35:	e9 3e f3 ff ff       	jmp    80107178 <alltraps>

80107e3a <vector162>:
.globl vector162
vector162:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $162
80107e3c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107e41:	e9 32 f3 ff ff       	jmp    80107178 <alltraps>

80107e46 <vector163>:
.globl vector163
vector163:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $163
80107e48:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107e4d:	e9 26 f3 ff ff       	jmp    80107178 <alltraps>

80107e52 <vector164>:
.globl vector164
vector164:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $164
80107e54:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107e59:	e9 1a f3 ff ff       	jmp    80107178 <alltraps>

80107e5e <vector165>:
.globl vector165
vector165:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $165
80107e60:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107e65:	e9 0e f3 ff ff       	jmp    80107178 <alltraps>

80107e6a <vector166>:
.globl vector166
vector166:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $166
80107e6c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107e71:	e9 02 f3 ff ff       	jmp    80107178 <alltraps>

80107e76 <vector167>:
.globl vector167
vector167:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $167
80107e78:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107e7d:	e9 f6 f2 ff ff       	jmp    80107178 <alltraps>

80107e82 <vector168>:
.globl vector168
vector168:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $168
80107e84:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107e89:	e9 ea f2 ff ff       	jmp    80107178 <alltraps>

80107e8e <vector169>:
.globl vector169
vector169:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $169
80107e90:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107e95:	e9 de f2 ff ff       	jmp    80107178 <alltraps>

80107e9a <vector170>:
.globl vector170
vector170:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $170
80107e9c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107ea1:	e9 d2 f2 ff ff       	jmp    80107178 <alltraps>

80107ea6 <vector171>:
.globl vector171
vector171:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $171
80107ea8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107ead:	e9 c6 f2 ff ff       	jmp    80107178 <alltraps>

80107eb2 <vector172>:
.globl vector172
vector172:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $172
80107eb4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107eb9:	e9 ba f2 ff ff       	jmp    80107178 <alltraps>

80107ebe <vector173>:
.globl vector173
vector173:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $173
80107ec0:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107ec5:	e9 ae f2 ff ff       	jmp    80107178 <alltraps>

80107eca <vector174>:
.globl vector174
vector174:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $174
80107ecc:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107ed1:	e9 a2 f2 ff ff       	jmp    80107178 <alltraps>

80107ed6 <vector175>:
.globl vector175
vector175:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $175
80107ed8:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107edd:	e9 96 f2 ff ff       	jmp    80107178 <alltraps>

80107ee2 <vector176>:
.globl vector176
vector176:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $176
80107ee4:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107ee9:	e9 8a f2 ff ff       	jmp    80107178 <alltraps>

80107eee <vector177>:
.globl vector177
vector177:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $177
80107ef0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107ef5:	e9 7e f2 ff ff       	jmp    80107178 <alltraps>

80107efa <vector178>:
.globl vector178
vector178:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $178
80107efc:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107f01:	e9 72 f2 ff ff       	jmp    80107178 <alltraps>

80107f06 <vector179>:
.globl vector179
vector179:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $179
80107f08:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107f0d:	e9 66 f2 ff ff       	jmp    80107178 <alltraps>

80107f12 <vector180>:
.globl vector180
vector180:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $180
80107f14:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107f19:	e9 5a f2 ff ff       	jmp    80107178 <alltraps>

80107f1e <vector181>:
.globl vector181
vector181:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $181
80107f20:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107f25:	e9 4e f2 ff ff       	jmp    80107178 <alltraps>

80107f2a <vector182>:
.globl vector182
vector182:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $182
80107f2c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107f31:	e9 42 f2 ff ff       	jmp    80107178 <alltraps>

80107f36 <vector183>:
.globl vector183
vector183:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $183
80107f38:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107f3d:	e9 36 f2 ff ff       	jmp    80107178 <alltraps>

80107f42 <vector184>:
.globl vector184
vector184:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $184
80107f44:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107f49:	e9 2a f2 ff ff       	jmp    80107178 <alltraps>

80107f4e <vector185>:
.globl vector185
vector185:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $185
80107f50:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107f55:	e9 1e f2 ff ff       	jmp    80107178 <alltraps>

80107f5a <vector186>:
.globl vector186
vector186:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $186
80107f5c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107f61:	e9 12 f2 ff ff       	jmp    80107178 <alltraps>

80107f66 <vector187>:
.globl vector187
vector187:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $187
80107f68:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107f6d:	e9 06 f2 ff ff       	jmp    80107178 <alltraps>

80107f72 <vector188>:
.globl vector188
vector188:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $188
80107f74:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107f79:	e9 fa f1 ff ff       	jmp    80107178 <alltraps>

80107f7e <vector189>:
.globl vector189
vector189:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $189
80107f80:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107f85:	e9 ee f1 ff ff       	jmp    80107178 <alltraps>

80107f8a <vector190>:
.globl vector190
vector190:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $190
80107f8c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107f91:	e9 e2 f1 ff ff       	jmp    80107178 <alltraps>

80107f96 <vector191>:
.globl vector191
vector191:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $191
80107f98:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107f9d:	e9 d6 f1 ff ff       	jmp    80107178 <alltraps>

80107fa2 <vector192>:
.globl vector192
vector192:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $192
80107fa4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107fa9:	e9 ca f1 ff ff       	jmp    80107178 <alltraps>

80107fae <vector193>:
.globl vector193
vector193:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $193
80107fb0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107fb5:	e9 be f1 ff ff       	jmp    80107178 <alltraps>

80107fba <vector194>:
.globl vector194
vector194:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $194
80107fbc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107fc1:	e9 b2 f1 ff ff       	jmp    80107178 <alltraps>

80107fc6 <vector195>:
.globl vector195
vector195:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $195
80107fc8:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107fcd:	e9 a6 f1 ff ff       	jmp    80107178 <alltraps>

80107fd2 <vector196>:
.globl vector196
vector196:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $196
80107fd4:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107fd9:	e9 9a f1 ff ff       	jmp    80107178 <alltraps>

80107fde <vector197>:
.globl vector197
vector197:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $197
80107fe0:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107fe5:	e9 8e f1 ff ff       	jmp    80107178 <alltraps>

80107fea <vector198>:
.globl vector198
vector198:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $198
80107fec:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107ff1:	e9 82 f1 ff ff       	jmp    80107178 <alltraps>

80107ff6 <vector199>:
.globl vector199
vector199:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $199
80107ff8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107ffd:	e9 76 f1 ff ff       	jmp    80107178 <alltraps>

80108002 <vector200>:
.globl vector200
vector200:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $200
80108004:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108009:	e9 6a f1 ff ff       	jmp    80107178 <alltraps>

8010800e <vector201>:
.globl vector201
vector201:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $201
80108010:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108015:	e9 5e f1 ff ff       	jmp    80107178 <alltraps>

8010801a <vector202>:
.globl vector202
vector202:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $202
8010801c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108021:	e9 52 f1 ff ff       	jmp    80107178 <alltraps>

80108026 <vector203>:
.globl vector203
vector203:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $203
80108028:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010802d:	e9 46 f1 ff ff       	jmp    80107178 <alltraps>

80108032 <vector204>:
.globl vector204
vector204:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $204
80108034:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108039:	e9 3a f1 ff ff       	jmp    80107178 <alltraps>

8010803e <vector205>:
.globl vector205
vector205:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $205
80108040:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108045:	e9 2e f1 ff ff       	jmp    80107178 <alltraps>

8010804a <vector206>:
.globl vector206
vector206:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $206
8010804c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108051:	e9 22 f1 ff ff       	jmp    80107178 <alltraps>

80108056 <vector207>:
.globl vector207
vector207:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $207
80108058:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010805d:	e9 16 f1 ff ff       	jmp    80107178 <alltraps>

80108062 <vector208>:
.globl vector208
vector208:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $208
80108064:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108069:	e9 0a f1 ff ff       	jmp    80107178 <alltraps>

8010806e <vector209>:
.globl vector209
vector209:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $209
80108070:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108075:	e9 fe f0 ff ff       	jmp    80107178 <alltraps>

8010807a <vector210>:
.globl vector210
vector210:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $210
8010807c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108081:	e9 f2 f0 ff ff       	jmp    80107178 <alltraps>

80108086 <vector211>:
.globl vector211
vector211:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $211
80108088:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010808d:	e9 e6 f0 ff ff       	jmp    80107178 <alltraps>

80108092 <vector212>:
.globl vector212
vector212:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $212
80108094:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108099:	e9 da f0 ff ff       	jmp    80107178 <alltraps>

8010809e <vector213>:
.globl vector213
vector213:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $213
801080a0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801080a5:	e9 ce f0 ff ff       	jmp    80107178 <alltraps>

801080aa <vector214>:
.globl vector214
vector214:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $214
801080ac:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801080b1:	e9 c2 f0 ff ff       	jmp    80107178 <alltraps>

801080b6 <vector215>:
.globl vector215
vector215:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $215
801080b8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801080bd:	e9 b6 f0 ff ff       	jmp    80107178 <alltraps>

801080c2 <vector216>:
.globl vector216
vector216:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $216
801080c4:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801080c9:	e9 aa f0 ff ff       	jmp    80107178 <alltraps>

801080ce <vector217>:
.globl vector217
vector217:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $217
801080d0:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801080d5:	e9 9e f0 ff ff       	jmp    80107178 <alltraps>

801080da <vector218>:
.globl vector218
vector218:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $218
801080dc:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801080e1:	e9 92 f0 ff ff       	jmp    80107178 <alltraps>

801080e6 <vector219>:
.globl vector219
vector219:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $219
801080e8:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801080ed:	e9 86 f0 ff ff       	jmp    80107178 <alltraps>

801080f2 <vector220>:
.globl vector220
vector220:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $220
801080f4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801080f9:	e9 7a f0 ff ff       	jmp    80107178 <alltraps>

801080fe <vector221>:
.globl vector221
vector221:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $221
80108100:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108105:	e9 6e f0 ff ff       	jmp    80107178 <alltraps>

8010810a <vector222>:
.globl vector222
vector222:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $222
8010810c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108111:	e9 62 f0 ff ff       	jmp    80107178 <alltraps>

80108116 <vector223>:
.globl vector223
vector223:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $223
80108118:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010811d:	e9 56 f0 ff ff       	jmp    80107178 <alltraps>

80108122 <vector224>:
.globl vector224
vector224:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $224
80108124:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108129:	e9 4a f0 ff ff       	jmp    80107178 <alltraps>

8010812e <vector225>:
.globl vector225
vector225:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $225
80108130:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108135:	e9 3e f0 ff ff       	jmp    80107178 <alltraps>

8010813a <vector226>:
.globl vector226
vector226:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $226
8010813c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108141:	e9 32 f0 ff ff       	jmp    80107178 <alltraps>

80108146 <vector227>:
.globl vector227
vector227:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $227
80108148:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010814d:	e9 26 f0 ff ff       	jmp    80107178 <alltraps>

80108152 <vector228>:
.globl vector228
vector228:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $228
80108154:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108159:	e9 1a f0 ff ff       	jmp    80107178 <alltraps>

8010815e <vector229>:
.globl vector229
vector229:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $229
80108160:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108165:	e9 0e f0 ff ff       	jmp    80107178 <alltraps>

8010816a <vector230>:
.globl vector230
vector230:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $230
8010816c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108171:	e9 02 f0 ff ff       	jmp    80107178 <alltraps>

80108176 <vector231>:
.globl vector231
vector231:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $231
80108178:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010817d:	e9 f6 ef ff ff       	jmp    80107178 <alltraps>

80108182 <vector232>:
.globl vector232
vector232:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $232
80108184:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108189:	e9 ea ef ff ff       	jmp    80107178 <alltraps>

8010818e <vector233>:
.globl vector233
vector233:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $233
80108190:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108195:	e9 de ef ff ff       	jmp    80107178 <alltraps>

8010819a <vector234>:
.globl vector234
vector234:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $234
8010819c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801081a1:	e9 d2 ef ff ff       	jmp    80107178 <alltraps>

801081a6 <vector235>:
.globl vector235
vector235:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $235
801081a8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801081ad:	e9 c6 ef ff ff       	jmp    80107178 <alltraps>

801081b2 <vector236>:
.globl vector236
vector236:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $236
801081b4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801081b9:	e9 ba ef ff ff       	jmp    80107178 <alltraps>

801081be <vector237>:
.globl vector237
vector237:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $237
801081c0:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801081c5:	e9 ae ef ff ff       	jmp    80107178 <alltraps>

801081ca <vector238>:
.globl vector238
vector238:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $238
801081cc:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801081d1:	e9 a2 ef ff ff       	jmp    80107178 <alltraps>

801081d6 <vector239>:
.globl vector239
vector239:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $239
801081d8:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801081dd:	e9 96 ef ff ff       	jmp    80107178 <alltraps>

801081e2 <vector240>:
.globl vector240
vector240:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $240
801081e4:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801081e9:	e9 8a ef ff ff       	jmp    80107178 <alltraps>

801081ee <vector241>:
.globl vector241
vector241:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $241
801081f0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801081f5:	e9 7e ef ff ff       	jmp    80107178 <alltraps>

801081fa <vector242>:
.globl vector242
vector242:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $242
801081fc:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108201:	e9 72 ef ff ff       	jmp    80107178 <alltraps>

80108206 <vector243>:
.globl vector243
vector243:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $243
80108208:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010820d:	e9 66 ef ff ff       	jmp    80107178 <alltraps>

80108212 <vector244>:
.globl vector244
vector244:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $244
80108214:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108219:	e9 5a ef ff ff       	jmp    80107178 <alltraps>

8010821e <vector245>:
.globl vector245
vector245:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $245
80108220:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108225:	e9 4e ef ff ff       	jmp    80107178 <alltraps>

8010822a <vector246>:
.globl vector246
vector246:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $246
8010822c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108231:	e9 42 ef ff ff       	jmp    80107178 <alltraps>

80108236 <vector247>:
.globl vector247
vector247:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $247
80108238:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010823d:	e9 36 ef ff ff       	jmp    80107178 <alltraps>

80108242 <vector248>:
.globl vector248
vector248:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $248
80108244:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108249:	e9 2a ef ff ff       	jmp    80107178 <alltraps>

8010824e <vector249>:
.globl vector249
vector249:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $249
80108250:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108255:	e9 1e ef ff ff       	jmp    80107178 <alltraps>

8010825a <vector250>:
.globl vector250
vector250:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $250
8010825c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108261:	e9 12 ef ff ff       	jmp    80107178 <alltraps>

80108266 <vector251>:
.globl vector251
vector251:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $251
80108268:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010826d:	e9 06 ef ff ff       	jmp    80107178 <alltraps>

80108272 <vector252>:
.globl vector252
vector252:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $252
80108274:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108279:	e9 fa ee ff ff       	jmp    80107178 <alltraps>

8010827e <vector253>:
.globl vector253
vector253:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $253
80108280:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108285:	e9 ee ee ff ff       	jmp    80107178 <alltraps>

8010828a <vector254>:
.globl vector254
vector254:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $254
8010828c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108291:	e9 e2 ee ff ff       	jmp    80107178 <alltraps>

80108296 <vector255>:
.globl vector255
vector255:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $255
80108298:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010829d:	e9 d6 ee ff ff       	jmp    80107178 <alltraps>
	...

801082a4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801082a4:	55                   	push   %ebp
801082a5:	89 e5                	mov    %esp,%ebp
801082a7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801082aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ad:	83 e8 01             	sub    $0x1,%eax
801082b0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801082b4:	8b 45 08             	mov    0x8(%ebp),%eax
801082b7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801082bb:	8b 45 08             	mov    0x8(%ebp),%eax
801082be:	c1 e8 10             	shr    $0x10,%eax
801082c1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801082c5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801082c8:	0f 01 10             	lgdtl  (%eax)
}
801082cb:	c9                   	leave  
801082cc:	c3                   	ret    

801082cd <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801082cd:	55                   	push   %ebp
801082ce:	89 e5                	mov    %esp,%ebp
801082d0:	83 ec 04             	sub    $0x4,%esp
801082d3:	8b 45 08             	mov    0x8(%ebp),%eax
801082d6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801082da:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801082de:	0f 00 d8             	ltr    %ax
}
801082e1:	c9                   	leave  
801082e2:	c3                   	ret    

801082e3 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801082e3:	55                   	push   %ebp
801082e4:	89 e5                	mov    %esp,%ebp
801082e6:	83 ec 04             	sub    $0x4,%esp
801082e9:	8b 45 08             	mov    0x8(%ebp),%eax
801082ec:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801082f0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801082f4:	8e e8                	mov    %eax,%gs
}
801082f6:	c9                   	leave  
801082f7:	c3                   	ret    

801082f8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801082f8:	55                   	push   %ebp
801082f9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801082fb:	8b 45 08             	mov    0x8(%ebp),%eax
801082fe:	0f 22 d8             	mov    %eax,%cr3
}
80108301:	5d                   	pop    %ebp
80108302:	c3                   	ret    

80108303 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108303:	55                   	push   %ebp
80108304:	89 e5                	mov    %esp,%ebp
80108306:	8b 45 08             	mov    0x8(%ebp),%eax
80108309:	05 00 00 00 80       	add    $0x80000000,%eax
8010830e:	5d                   	pop    %ebp
8010830f:	c3                   	ret    

80108310 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108310:	55                   	push   %ebp
80108311:	89 e5                	mov    %esp,%ebp
80108313:	8b 45 08             	mov    0x8(%ebp),%eax
80108316:	05 00 00 00 80       	add    $0x80000000,%eax
8010831b:	5d                   	pop    %ebp
8010831c:	c3                   	ret    

8010831d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010831d:	55                   	push   %ebp
8010831e:	89 e5                	mov    %esp,%ebp
80108320:	53                   	push   %ebx
80108321:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108324:	e8 56 b4 ff ff       	call   8010377f <cpunum>
80108329:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010832f:	05 80 3b 11 80       	add    $0x80113b80,%eax
80108334:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108343:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108353:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108357:	83 e2 f0             	and    $0xfffffff0,%edx
8010835a:	83 ca 0a             	or     $0xa,%edx
8010835d:	88 50 7d             	mov    %dl,0x7d(%eax)
80108360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108363:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108367:	83 ca 10             	or     $0x10,%edx
8010836a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010836d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108370:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108374:	83 e2 9f             	and    $0xffffff9f,%edx
80108377:	88 50 7d             	mov    %dl,0x7d(%eax)
8010837a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108381:	83 ca 80             	or     $0xffffff80,%edx
80108384:	88 50 7d             	mov    %dl,0x7d(%eax)
80108387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010838e:	83 ca 0f             	or     $0xf,%edx
80108391:	88 50 7e             	mov    %dl,0x7e(%eax)
80108394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108397:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010839b:	83 e2 ef             	and    $0xffffffef,%edx
8010839e:	88 50 7e             	mov    %dl,0x7e(%eax)
801083a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083a8:	83 e2 df             	and    $0xffffffdf,%edx
801083ab:	88 50 7e             	mov    %dl,0x7e(%eax)
801083ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083b5:	83 ca 40             	or     $0x40,%edx
801083b8:	88 50 7e             	mov    %dl,0x7e(%eax)
801083bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083be:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083c2:	83 ca 80             	or     $0xffffff80,%edx
801083c5:	88 50 7e             	mov    %dl,0x7e(%eax)
801083c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cb:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801083cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801083d9:	ff ff 
801083db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083de:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801083e5:	00 00 
801083e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ea:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801083f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801083fb:	83 e2 f0             	and    $0xfffffff0,%edx
801083fe:	83 ca 02             	or     $0x2,%edx
80108401:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108411:	83 ca 10             	or     $0x10,%edx
80108414:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010841a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108424:	83 e2 9f             	and    $0xffffff9f,%edx
80108427:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010842d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108430:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108437:	83 ca 80             	or     $0xffffff80,%edx
8010843a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108443:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010844a:	83 ca 0f             	or     $0xf,%edx
8010844d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108456:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010845d:	83 e2 ef             	and    $0xffffffef,%edx
80108460:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108469:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108470:	83 e2 df             	and    $0xffffffdf,%edx
80108473:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108483:	83 ca 40             	or     $0x40,%edx
80108486:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010848c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108496:	83 ca 80             	or     $0xffffff80,%edx
80108499:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010849f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801084a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ac:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801084b3:	ff ff 
801084b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b8:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801084bf:	00 00 
801084c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c4:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801084cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ce:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801084d5:	83 e2 f0             	and    $0xfffffff0,%edx
801084d8:	83 ca 0a             	or     $0xa,%edx
801084db:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801084eb:	83 ca 10             	or     $0x10,%edx
801084ee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801084fe:	83 ca 60             	or     $0x60,%edx
80108501:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108511:	83 ca 80             	or     $0xffffff80,%edx
80108514:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010851a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108524:	83 ca 0f             	or     $0xf,%edx
80108527:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010852d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108530:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108537:	83 e2 ef             	and    $0xffffffef,%edx
8010853a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108543:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010854a:	83 e2 df             	and    $0xffffffdf,%edx
8010854d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108556:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010855d:	83 ca 40             	or     $0x40,%edx
80108560:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108569:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108570:	83 ca 80             	or     $0xffffff80,%edx
80108573:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108586:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010858d:	ff ff 
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108599:	00 00 
8010859b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801085a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801085af:	83 e2 f0             	and    $0xfffffff0,%edx
801085b2:	83 ca 02             	or     $0x2,%edx
801085b5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801085bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085be:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801085c5:	83 ca 10             	or     $0x10,%edx
801085c8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801085ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801085d8:	83 ca 60             	or     $0x60,%edx
801085db:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801085e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801085eb:	83 ca 80             	or     $0xffffff80,%edx
801085ee:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801085f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801085fe:	83 ca 0f             	or     $0xf,%edx
80108601:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108611:	83 e2 ef             	and    $0xffffffef,%edx
80108614:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010861a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108624:	83 e2 df             	and    $0xffffffdf,%edx
80108627:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010862d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108630:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108637:	83 ca 40             	or     $0x40,%edx
8010863a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108643:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010864a:	83 ca 80             	or     $0xffffff80,%edx
8010864d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108660:	05 b4 00 00 00       	add    $0xb4,%eax
80108665:	89 c3                	mov    %eax,%ebx
80108667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866a:	05 b4 00 00 00       	add    $0xb4,%eax
8010866f:	c1 e8 10             	shr    $0x10,%eax
80108672:	89 c1                	mov    %eax,%ecx
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	05 b4 00 00 00       	add    $0xb4,%eax
8010867c:	c1 e8 18             	shr    $0x18,%eax
8010867f:	89 c2                	mov    %eax,%edx
80108681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108684:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010868b:	00 00 
8010868d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108690:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801086a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801086aa:	83 e1 f0             	and    $0xfffffff0,%ecx
801086ad:	83 c9 02             	or     $0x2,%ecx
801086b0:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801086b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b9:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801086c0:	83 c9 10             	or     $0x10,%ecx
801086c3:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801086c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cc:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801086d3:	83 e1 9f             	and    $0xffffff9f,%ecx
801086d6:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801086dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086df:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801086e6:	83 c9 80             	or     $0xffffff80,%ecx
801086e9:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801086ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801086f9:	83 e1 f0             	and    $0xfffffff0,%ecx
801086fc:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010870c:	83 e1 ef             	and    $0xffffffef,%ecx
8010870f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010871f:	83 e1 df             	and    $0xffffffdf,%ecx
80108722:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108732:	83 c9 40             	or     $0x40,%ecx
80108735:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108745:	83 c9 80             	or     $0xffffff80,%ecx
80108748:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875a:	83 c0 70             	add    $0x70,%eax
8010875d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108764:	00 
80108765:	89 04 24             	mov    %eax,(%esp)
80108768:	e8 37 fb ff ff       	call   801082a4 <lgdt>
  loadgs(SEG_KCPU << 3);
8010876d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108774:	e8 6a fb ff ff       	call   801082e3 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80108779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108782:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108789:	00 00 00 00 
}
8010878d:	83 c4 24             	add    $0x24,%esp
80108790:	5b                   	pop    %ebx
80108791:	5d                   	pop    %ebp
80108792:	c3                   	ret    

80108793 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108793:	55                   	push   %ebp
80108794:	89 e5                	mov    %esp,%ebp
80108796:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010879c:	c1 e8 16             	shr    $0x16,%eax
8010879f:	c1 e0 02             	shl    $0x2,%eax
801087a2:	03 45 08             	add    0x8(%ebp),%eax
801087a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801087a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ab:	8b 00                	mov    (%eax),%eax
801087ad:	83 e0 01             	and    $0x1,%eax
801087b0:	84 c0                	test   %al,%al
801087b2:	74 17                	je     801087cb <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801087b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b7:	8b 00                	mov    (%eax),%eax
801087b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087be:	89 04 24             	mov    %eax,(%esp)
801087c1:	e8 4a fb ff ff       	call   80108310 <p2v>
801087c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087c9:	eb 4b                	jmp    80108816 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801087cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801087cf:	74 0e                	je     801087df <walkpgdir+0x4c>
801087d1:	e8 f1 ab ff ff       	call   801033c7 <kalloc>
801087d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087dd:	75 07                	jne    801087e6 <walkpgdir+0x53>
      return 0;
801087df:	b8 00 00 00 00       	mov    $0x0,%eax
801087e4:	eb 41                	jmp    80108827 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801087e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087ed:	00 
801087ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087f5:	00 
801087f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f9:	89 04 24             	mov    %eax,(%esp)
801087fc:	e8 b1 d4 ff ff       	call   80105cb2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108804:	89 04 24             	mov    %eax,(%esp)
80108807:	e8 f7 fa ff ff       	call   80108303 <v2p>
8010880c:	89 c2                	mov    %eax,%edx
8010880e:	83 ca 07             	or     $0x7,%edx
80108811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108814:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108816:	8b 45 0c             	mov    0xc(%ebp),%eax
80108819:	c1 e8 0c             	shr    $0xc,%eax
8010881c:	25 ff 03 00 00       	and    $0x3ff,%eax
80108821:	c1 e0 02             	shl    $0x2,%eax
80108824:	03 45 f4             	add    -0xc(%ebp),%eax
}
80108827:	c9                   	leave  
80108828:	c3                   	ret    

80108829 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108829:	55                   	push   %ebp
8010882a:	89 e5                	mov    %esp,%ebp
8010882c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010882f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108832:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010883a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010883d:	03 45 10             	add    0x10(%ebp),%eax
80108840:	83 e8 01             	sub    $0x1,%eax
80108843:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108848:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010884b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108852:	00 
80108853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108856:	89 44 24 04          	mov    %eax,0x4(%esp)
8010885a:	8b 45 08             	mov    0x8(%ebp),%eax
8010885d:	89 04 24             	mov    %eax,(%esp)
80108860:	e8 2e ff ff ff       	call   80108793 <walkpgdir>
80108865:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108868:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010886c:	75 07                	jne    80108875 <mappages+0x4c>
      return -1;
8010886e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108873:	eb 46                	jmp    801088bb <mappages+0x92>
    if(*pte & PTE_P)
80108875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108878:	8b 00                	mov    (%eax),%eax
8010887a:	83 e0 01             	and    $0x1,%eax
8010887d:	84 c0                	test   %al,%al
8010887f:	74 0c                	je     8010888d <mappages+0x64>
      panic("remap");
80108881:	c7 04 24 1c 97 10 80 	movl   $0x8010971c,(%esp)
80108888:	e8 b0 7c ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
8010888d:	8b 45 18             	mov    0x18(%ebp),%eax
80108890:	0b 45 14             	or     0x14(%ebp),%eax
80108893:	89 c2                	mov    %eax,%edx
80108895:	83 ca 01             	or     $0x1,%edx
80108898:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010889b:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010889d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801088a3:	74 10                	je     801088b5 <mappages+0x8c>
      break;
    a += PGSIZE;
801088a5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801088ac:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801088b3:	eb 96                	jmp    8010884b <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801088b5:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801088b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088bb:	c9                   	leave  
801088bc:	c3                   	ret    

801088bd <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801088bd:	55                   	push   %ebp
801088be:	89 e5                	mov    %esp,%ebp
801088c0:	53                   	push   %ebx
801088c1:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801088c4:	e8 fe aa ff ff       	call   801033c7 <kalloc>
801088c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801088cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088d0:	75 0a                	jne    801088dc <setupkvm+0x1f>
    return 0;
801088d2:	b8 00 00 00 00       	mov    $0x0,%eax
801088d7:	e9 98 00 00 00       	jmp    80108974 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801088dc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088e3:	00 
801088e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088eb:	00 
801088ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ef:	89 04 24             	mov    %eax,(%esp)
801088f2:	e8 bb d3 ff ff       	call   80105cb2 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801088f7:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801088fe:	e8 0d fa ff ff       	call   80108310 <p2v>
80108903:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108908:	76 0c                	jbe    80108916 <setupkvm+0x59>
    panic("PHYSTOP too high");
8010890a:	c7 04 24 22 97 10 80 	movl   $0x80109722,(%esp)
80108911:	e8 27 7c ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108916:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
8010891d:	eb 49                	jmp    80108968 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
8010891f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108922:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108925:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108928:	8b 50 04             	mov    0x4(%eax),%edx
8010892b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892e:	8b 58 08             	mov    0x8(%eax),%ebx
80108931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108934:	8b 40 04             	mov    0x4(%eax),%eax
80108937:	29 c3                	sub    %eax,%ebx
80108939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893c:	8b 00                	mov    (%eax),%eax
8010893e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108942:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108946:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010894a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010894e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108951:	89 04 24             	mov    %eax,(%esp)
80108954:	e8 d0 fe ff ff       	call   80108829 <mappages>
80108959:	85 c0                	test   %eax,%eax
8010895b:	79 07                	jns    80108964 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
8010895d:	b8 00 00 00 00       	mov    $0x0,%eax
80108962:	eb 10                	jmp    80108974 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108964:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108968:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
8010896f:	72 ae                	jb     8010891f <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108971:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108974:	83 c4 34             	add    $0x34,%esp
80108977:	5b                   	pop    %ebx
80108978:	5d                   	pop    %ebp
80108979:	c3                   	ret    

8010897a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010897a:	55                   	push   %ebp
8010897b:	89 e5                	mov    %esp,%ebp
8010897d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108980:	e8 38 ff ff ff       	call   801088bd <setupkvm>
80108985:	a3 58 6e 11 80       	mov    %eax,0x80116e58
  switchkvm();
8010898a:	e8 02 00 00 00       	call   80108991 <switchkvm>
}
8010898f:	c9                   	leave  
80108990:	c3                   	ret    

80108991 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108991:	55                   	push   %ebp
80108992:	89 e5                	mov    %esp,%ebp
80108994:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108997:	a1 58 6e 11 80       	mov    0x80116e58,%eax
8010899c:	89 04 24             	mov    %eax,(%esp)
8010899f:	e8 5f f9 ff ff       	call   80108303 <v2p>
801089a4:	89 04 24             	mov    %eax,(%esp)
801089a7:	e8 4c f9 ff ff       	call   801082f8 <lcr3>
}
801089ac:	c9                   	leave  
801089ad:	c3                   	ret    

801089ae <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801089ae:	55                   	push   %ebp
801089af:	89 e5                	mov    %esp,%ebp
801089b1:	53                   	push   %ebx
801089b2:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801089b5:	e8 f1 d1 ff ff       	call   80105bab <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801089ba:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801089c0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801089c7:	83 c2 08             	add    $0x8,%edx
801089ca:	89 d3                	mov    %edx,%ebx
801089cc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801089d3:	83 c2 08             	add    $0x8,%edx
801089d6:	c1 ea 10             	shr    $0x10,%edx
801089d9:	89 d1                	mov    %edx,%ecx
801089db:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801089e2:	83 c2 08             	add    $0x8,%edx
801089e5:	c1 ea 18             	shr    $0x18,%edx
801089e8:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801089ef:	67 00 
801089f1:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801089f8:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801089fe:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a05:	83 e1 f0             	and    $0xfffffff0,%ecx
80108a08:	83 c9 09             	or     $0x9,%ecx
80108a0b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a11:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a18:	83 c9 10             	or     $0x10,%ecx
80108a1b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a21:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a28:	83 e1 9f             	and    $0xffffff9f,%ecx
80108a2b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a31:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a38:	83 c9 80             	or     $0xffffff80,%ecx
80108a3b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a41:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108a48:	83 e1 f0             	and    $0xfffffff0,%ecx
80108a4b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108a51:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108a58:	83 e1 ef             	and    $0xffffffef,%ecx
80108a5b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108a61:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108a68:	83 e1 df             	and    $0xffffffdf,%ecx
80108a6b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108a71:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108a78:	83 c9 40             	or     $0x40,%ecx
80108a7b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108a81:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108a88:	83 e1 7f             	and    $0x7f,%ecx
80108a8b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108a91:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108a97:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108a9d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108aa4:	83 e2 ef             	and    $0xffffffef,%edx
80108aa7:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108aad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ab3:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108ab9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108abf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ac6:	8b 52 08             	mov    0x8(%edx),%edx
80108ac9:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108acf:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108ad2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108ad9:	e8 ef f7 ff ff       	call   801082cd <ltr>
  if(p->pgdir == 0)
80108ade:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae1:	8b 40 04             	mov    0x4(%eax),%eax
80108ae4:	85 c0                	test   %eax,%eax
80108ae6:	75 0c                	jne    80108af4 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108ae8:	c7 04 24 33 97 10 80 	movl   $0x80109733,(%esp)
80108aef:	e8 49 7a ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108af4:	8b 45 08             	mov    0x8(%ebp),%eax
80108af7:	8b 40 04             	mov    0x4(%eax),%eax
80108afa:	89 04 24             	mov    %eax,(%esp)
80108afd:	e8 01 f8 ff ff       	call   80108303 <v2p>
80108b02:	89 04 24             	mov    %eax,(%esp)
80108b05:	e8 ee f7 ff ff       	call   801082f8 <lcr3>
  popcli();
80108b0a:	e8 e4 d0 ff ff       	call   80105bf3 <popcli>
}
80108b0f:	83 c4 14             	add    $0x14,%esp
80108b12:	5b                   	pop    %ebx
80108b13:	5d                   	pop    %ebp
80108b14:	c3                   	ret    

80108b15 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108b15:	55                   	push   %ebp
80108b16:	89 e5                	mov    %esp,%ebp
80108b18:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108b1b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108b22:	76 0c                	jbe    80108b30 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108b24:	c7 04 24 47 97 10 80 	movl   $0x80109747,(%esp)
80108b2b:	e8 0d 7a ff ff       	call   8010053d <panic>
  mem = kalloc();
80108b30:	e8 92 a8 ff ff       	call   801033c7 <kalloc>
80108b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108b38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b3f:	00 
80108b40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b47:	00 
80108b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4b:	89 04 24             	mov    %eax,(%esp)
80108b4e:	e8 5f d1 ff ff       	call   80105cb2 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b56:	89 04 24             	mov    %eax,(%esp)
80108b59:	e8 a5 f7 ff ff       	call   80108303 <v2p>
80108b5e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108b65:	00 
80108b66:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108b6a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b71:	00 
80108b72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b79:	00 
80108b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b7d:	89 04 24             	mov    %eax,(%esp)
80108b80:	e8 a4 fc ff ff       	call   80108829 <mappages>
  memmove(mem, init, sz);
80108b85:	8b 45 10             	mov    0x10(%ebp),%eax
80108b88:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b96:	89 04 24             	mov    %eax,(%esp)
80108b99:	e8 e7 d1 ff ff       	call   80105d85 <memmove>
}
80108b9e:	c9                   	leave  
80108b9f:	c3                   	ret    

80108ba0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108ba0:	55                   	push   %ebp
80108ba1:	89 e5                	mov    %esp,%ebp
80108ba3:	53                   	push   %ebx
80108ba4:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108baa:	25 ff 0f 00 00       	and    $0xfff,%eax
80108baf:	85 c0                	test   %eax,%eax
80108bb1:	74 0c                	je     80108bbf <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108bb3:	c7 04 24 64 97 10 80 	movl   $0x80109764,(%esp)
80108bba:	e8 7e 79 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108bbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bc6:	e9 ad 00 00 00       	jmp    80108c78 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bce:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bd1:	01 d0                	add    %edx,%eax
80108bd3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bda:	00 
80108bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80108be2:	89 04 24             	mov    %eax,(%esp)
80108be5:	e8 a9 fb ff ff       	call   80108793 <walkpgdir>
80108bea:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108bed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bf1:	75 0c                	jne    80108bff <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108bf3:	c7 04 24 87 97 10 80 	movl   $0x80109787,(%esp)
80108bfa:	e8 3e 79 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108bff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c02:	8b 00                	mov    (%eax),%eax
80108c04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c09:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0f:	8b 55 18             	mov    0x18(%ebp),%edx
80108c12:	89 d1                	mov    %edx,%ecx
80108c14:	29 c1                	sub    %eax,%ecx
80108c16:	89 c8                	mov    %ecx,%eax
80108c18:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108c1d:	77 11                	ja     80108c30 <loaduvm+0x90>
      n = sz - i;
80108c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c22:	8b 55 18             	mov    0x18(%ebp),%edx
80108c25:	89 d1                	mov    %edx,%ecx
80108c27:	29 c1                	sub    %eax,%ecx
80108c29:	89 c8                	mov    %ecx,%eax
80108c2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c2e:	eb 07                	jmp    80108c37 <loaduvm+0x97>
    else
      n = PGSIZE;
80108c30:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3a:	8b 55 14             	mov    0x14(%ebp),%edx
80108c3d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108c40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c43:	89 04 24             	mov    %eax,(%esp)
80108c46:	e8 c5 f6 ff ff       	call   80108310 <p2v>
80108c4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108c52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108c56:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c5a:	8b 45 10             	mov    0x10(%ebp),%eax
80108c5d:	89 04 24             	mov    %eax,(%esp)
80108c60:	e8 8c 99 ff ff       	call   801025f1 <readi>
80108c65:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c68:	74 07                	je     80108c71 <loaduvm+0xd1>
      return -1;
80108c6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c6f:	eb 18                	jmp    80108c89 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108c71:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7b:	3b 45 18             	cmp    0x18(%ebp),%eax
80108c7e:	0f 82 47 ff ff ff    	jb     80108bcb <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c89:	83 c4 24             	add    $0x24,%esp
80108c8c:	5b                   	pop    %ebx
80108c8d:	5d                   	pop    %ebp
80108c8e:	c3                   	ret    

80108c8f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c8f:	55                   	push   %ebp
80108c90:	89 e5                	mov    %esp,%ebp
80108c92:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108c95:	8b 45 10             	mov    0x10(%ebp),%eax
80108c98:	85 c0                	test   %eax,%eax
80108c9a:	79 0a                	jns    80108ca6 <allocuvm+0x17>
    return 0;
80108c9c:	b8 00 00 00 00       	mov    $0x0,%eax
80108ca1:	e9 c1 00 00 00       	jmp    80108d67 <allocuvm+0xd8>
  if(newsz < oldsz)
80108ca6:	8b 45 10             	mov    0x10(%ebp),%eax
80108ca9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108cac:	73 08                	jae    80108cb6 <allocuvm+0x27>
    return oldsz;
80108cae:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cb1:	e9 b1 00 00 00       	jmp    80108d67 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cb9:	05 ff 0f 00 00       	add    $0xfff,%eax
80108cbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108cc6:	e9 8d 00 00 00       	jmp    80108d58 <allocuvm+0xc9>
    mem = kalloc();
80108ccb:	e8 f7 a6 ff ff       	call   801033c7 <kalloc>
80108cd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108cd3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108cd7:	75 2c                	jne    80108d05 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108cd9:	c7 04 24 a5 97 10 80 	movl   $0x801097a5,(%esp)
80108ce0:	e8 bc 76 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ce8:	89 44 24 08          	mov    %eax,0x8(%esp)
80108cec:	8b 45 10             	mov    0x10(%ebp),%eax
80108cef:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf6:	89 04 24             	mov    %eax,(%esp)
80108cf9:	e8 6b 00 00 00       	call   80108d69 <deallocuvm>
      return 0;
80108cfe:	b8 00 00 00 00       	mov    $0x0,%eax
80108d03:	eb 62                	jmp    80108d67 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108d05:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d0c:	00 
80108d0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108d14:	00 
80108d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d18:	89 04 24             	mov    %eax,(%esp)
80108d1b:	e8 92 cf ff ff       	call   80105cb2 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d23:	89 04 24             	mov    %eax,(%esp)
80108d26:	e8 d8 f5 ff ff       	call   80108303 <v2p>
80108d2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d2e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108d35:	00 
80108d36:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108d3a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d41:	00 
80108d42:	89 54 24 04          	mov    %edx,0x4(%esp)
80108d46:	8b 45 08             	mov    0x8(%ebp),%eax
80108d49:	89 04 24             	mov    %eax,(%esp)
80108d4c:	e8 d8 fa ff ff       	call   80108829 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108d51:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5b:	3b 45 10             	cmp    0x10(%ebp),%eax
80108d5e:	0f 82 67 ff ff ff    	jb     80108ccb <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108d64:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d67:	c9                   	leave  
80108d68:	c3                   	ret    

80108d69 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108d69:	55                   	push   %ebp
80108d6a:	89 e5                	mov    %esp,%ebp
80108d6c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108d6f:	8b 45 10             	mov    0x10(%ebp),%eax
80108d72:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d75:	72 08                	jb     80108d7f <deallocuvm+0x16>
    return oldsz;
80108d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d7a:	e9 a4 00 00 00       	jmp    80108e23 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108d7f:	8b 45 10             	mov    0x10(%ebp),%eax
80108d82:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108d8f:	e9 80 00 00 00       	jmp    80108e14 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d9e:	00 
80108d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108da3:	8b 45 08             	mov    0x8(%ebp),%eax
80108da6:	89 04 24             	mov    %eax,(%esp)
80108da9:	e8 e5 f9 ff ff       	call   80108793 <walkpgdir>
80108dae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108db1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108db5:	75 09                	jne    80108dc0 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108db7:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108dbe:	eb 4d                	jmp    80108e0d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc3:	8b 00                	mov    (%eax),%eax
80108dc5:	83 e0 01             	and    $0x1,%eax
80108dc8:	84 c0                	test   %al,%al
80108dca:	74 41                	je     80108e0d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dcf:	8b 00                	mov    (%eax),%eax
80108dd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108dd9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ddd:	75 0c                	jne    80108deb <deallocuvm+0x82>
        panic("kfree");
80108ddf:	c7 04 24 bd 97 10 80 	movl   $0x801097bd,(%esp)
80108de6:	e8 52 77 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108deb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dee:	89 04 24             	mov    %eax,(%esp)
80108df1:	e8 1a f5 ff ff       	call   80108310 <p2v>
80108df6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dfc:	89 04 24             	mov    %eax,(%esp)
80108dff:	e8 2a a5 ff ff       	call   8010332e <kfree>
      *pte = 0;
80108e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108e0d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e17:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e1a:	0f 82 74 ff ff ff    	jb     80108d94 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108e20:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e23:	c9                   	leave  
80108e24:	c3                   	ret    

80108e25 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108e25:	55                   	push   %ebp
80108e26:	89 e5                	mov    %esp,%ebp
80108e28:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108e2b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e2f:	75 0c                	jne    80108e3d <freevm+0x18>
    panic("freevm: no pgdir");
80108e31:	c7 04 24 c3 97 10 80 	movl   $0x801097c3,(%esp)
80108e38:	e8 00 77 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108e3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e44:	00 
80108e45:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108e4c:	80 
80108e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80108e50:	89 04 24             	mov    %eax,(%esp)
80108e53:	e8 11 ff ff ff       	call   80108d69 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108e58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e5f:	eb 3c                	jmp    80108e9d <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e64:	c1 e0 02             	shl    $0x2,%eax
80108e67:	03 45 08             	add    0x8(%ebp),%eax
80108e6a:	8b 00                	mov    (%eax),%eax
80108e6c:	83 e0 01             	and    $0x1,%eax
80108e6f:	84 c0                	test   %al,%al
80108e71:	74 26                	je     80108e99 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e76:	c1 e0 02             	shl    $0x2,%eax
80108e79:	03 45 08             	add    0x8(%ebp),%eax
80108e7c:	8b 00                	mov    (%eax),%eax
80108e7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e83:	89 04 24             	mov    %eax,(%esp)
80108e86:	e8 85 f4 ff ff       	call   80108310 <p2v>
80108e8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e91:	89 04 24             	mov    %eax,(%esp)
80108e94:	e8 95 a4 ff ff       	call   8010332e <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108e99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e9d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ea4:	76 bb                	jbe    80108e61 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea9:	89 04 24             	mov    %eax,(%esp)
80108eac:	e8 7d a4 ff ff       	call   8010332e <kfree>
}
80108eb1:	c9                   	leave  
80108eb2:	c3                   	ret    

80108eb3 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108eb3:	55                   	push   %ebp
80108eb4:	89 e5                	mov    %esp,%ebp
80108eb6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108eb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ec0:	00 
80108ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80108ecb:	89 04 24             	mov    %eax,(%esp)
80108ece:	e8 c0 f8 ff ff       	call   80108793 <walkpgdir>
80108ed3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108ed6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108eda:	75 0c                	jne    80108ee8 <clearpteu+0x35>
    panic("clearpteu");
80108edc:	c7 04 24 d4 97 10 80 	movl   $0x801097d4,(%esp)
80108ee3:	e8 55 76 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eeb:	8b 00                	mov    (%eax),%eax
80108eed:	89 c2                	mov    %eax,%edx
80108eef:	83 e2 fb             	and    $0xfffffffb,%edx
80108ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef5:	89 10                	mov    %edx,(%eax)
}
80108ef7:	c9                   	leave  
80108ef8:	c3                   	ret    

80108ef9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108ef9:	55                   	push   %ebp
80108efa:	89 e5                	mov    %esp,%ebp
80108efc:	53                   	push   %ebx
80108efd:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108f00:	e8 b8 f9 ff ff       	call   801088bd <setupkvm>
80108f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f0c:	75 0a                	jne    80108f18 <copyuvm+0x1f>
    return 0;
80108f0e:	b8 00 00 00 00       	mov    $0x0,%eax
80108f13:	e9 fd 00 00 00       	jmp    80109015 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108f18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f1f:	e9 cc 00 00 00       	jmp    80108ff0 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f2e:	00 
80108f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f33:	8b 45 08             	mov    0x8(%ebp),%eax
80108f36:	89 04 24             	mov    %eax,(%esp)
80108f39:	e8 55 f8 ff ff       	call   80108793 <walkpgdir>
80108f3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f45:	75 0c                	jne    80108f53 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108f47:	c7 04 24 de 97 10 80 	movl   $0x801097de,(%esp)
80108f4e:	e8 ea 75 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f56:	8b 00                	mov    (%eax),%eax
80108f58:	83 e0 01             	and    $0x1,%eax
80108f5b:	85 c0                	test   %eax,%eax
80108f5d:	75 0c                	jne    80108f6b <copyuvm+0x72>
      panic("copyuvm: page not present");
80108f5f:	c7 04 24 f8 97 10 80 	movl   $0x801097f8,(%esp)
80108f66:	e8 d2 75 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f6e:	8b 00                	mov    (%eax),%eax
80108f70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f75:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f7b:	8b 00                	mov    (%eax),%eax
80108f7d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108f85:	e8 3d a4 ff ff       	call   801033c7 <kalloc>
80108f8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108f8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108f91:	74 6e                	je     80109001 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108f93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f96:	89 04 24             	mov    %eax,(%esp)
80108f99:	e8 72 f3 ff ff       	call   80108310 <p2v>
80108f9e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108fa5:	00 
80108fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fad:	89 04 24             	mov    %eax,(%esp)
80108fb0:	e8 d0 cd ff ff       	call   80105d85 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108fb5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fbb:	89 04 24             	mov    %eax,(%esp)
80108fbe:	e8 40 f3 ff ff       	call   80108303 <v2p>
80108fc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fc6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108fca:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108fce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108fd5:	00 
80108fd6:	89 54 24 04          	mov    %edx,0x4(%esp)
80108fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fdd:	89 04 24             	mov    %eax,(%esp)
80108fe0:	e8 44 f8 ff ff       	call   80108829 <mappages>
80108fe5:	85 c0                	test   %eax,%eax
80108fe7:	78 1b                	js     80109004 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108fe9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ff6:	0f 82 28 ff ff ff    	jb     80108f24 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fff:	eb 14                	jmp    80109015 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109001:	90                   	nop
80109002:	eb 01                	jmp    80109005 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109004:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109005:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109008:	89 04 24             	mov    %eax,(%esp)
8010900b:	e8 15 fe ff ff       	call   80108e25 <freevm>
  return 0;
80109010:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109015:	83 c4 44             	add    $0x44,%esp
80109018:	5b                   	pop    %ebx
80109019:	5d                   	pop    %ebp
8010901a:	c3                   	ret    

8010901b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010901b:	55                   	push   %ebp
8010901c:	89 e5                	mov    %esp,%ebp
8010901e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109021:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109028:	00 
80109029:	8b 45 0c             	mov    0xc(%ebp),%eax
8010902c:	89 44 24 04          	mov    %eax,0x4(%esp)
80109030:	8b 45 08             	mov    0x8(%ebp),%eax
80109033:	89 04 24             	mov    %eax,(%esp)
80109036:	e8 58 f7 ff ff       	call   80108793 <walkpgdir>
8010903b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010903e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109041:	8b 00                	mov    (%eax),%eax
80109043:	83 e0 01             	and    $0x1,%eax
80109046:	85 c0                	test   %eax,%eax
80109048:	75 07                	jne    80109051 <uva2ka+0x36>
    return 0;
8010904a:	b8 00 00 00 00       	mov    $0x0,%eax
8010904f:	eb 25                	jmp    80109076 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80109051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109054:	8b 00                	mov    (%eax),%eax
80109056:	83 e0 04             	and    $0x4,%eax
80109059:	85 c0                	test   %eax,%eax
8010905b:	75 07                	jne    80109064 <uva2ka+0x49>
    return 0;
8010905d:	b8 00 00 00 00       	mov    $0x0,%eax
80109062:	eb 12                	jmp    80109076 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80109064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109067:	8b 00                	mov    (%eax),%eax
80109069:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010906e:	89 04 24             	mov    %eax,(%esp)
80109071:	e8 9a f2 ff ff       	call   80108310 <p2v>
}
80109076:	c9                   	leave  
80109077:	c3                   	ret    

80109078 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109078:	55                   	push   %ebp
80109079:	89 e5                	mov    %esp,%ebp
8010907b:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010907e:	8b 45 10             	mov    0x10(%ebp),%eax
80109081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109084:	e9 8b 00 00 00       	jmp    80109114 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80109089:	8b 45 0c             	mov    0xc(%ebp),%eax
8010908c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109091:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109094:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109097:	89 44 24 04          	mov    %eax,0x4(%esp)
8010909b:	8b 45 08             	mov    0x8(%ebp),%eax
8010909e:	89 04 24             	mov    %eax,(%esp)
801090a1:	e8 75 ff ff ff       	call   8010901b <uva2ka>
801090a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801090a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801090ad:	75 07                	jne    801090b6 <copyout+0x3e>
      return -1;
801090af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090b4:	eb 6d                	jmp    80109123 <copyout+0xab>
    n = PGSIZE - (va - va0);
801090b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801090b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801090bc:	89 d1                	mov    %edx,%ecx
801090be:	29 c1                	sub    %eax,%ecx
801090c0:	89 c8                	mov    %ecx,%eax
801090c2:	05 00 10 00 00       	add    $0x1000,%eax
801090c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801090ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090cd:	3b 45 14             	cmp    0x14(%ebp),%eax
801090d0:	76 06                	jbe    801090d8 <copyout+0x60>
      n = len;
801090d2:	8b 45 14             	mov    0x14(%ebp),%eax
801090d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801090d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090db:	8b 55 0c             	mov    0xc(%ebp),%edx
801090de:	89 d1                	mov    %edx,%ecx
801090e0:	29 c1                	sub    %eax,%ecx
801090e2:	89 c8                	mov    %ecx,%eax
801090e4:	03 45 e8             	add    -0x18(%ebp),%eax
801090e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090ea:	89 54 24 08          	mov    %edx,0x8(%esp)
801090ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801090f5:	89 04 24             	mov    %eax,(%esp)
801090f8:	e8 88 cc ff ff       	call   80105d85 <memmove>
    len -= n;
801090fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109100:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109106:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109109:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010910c:	05 00 10 00 00       	add    $0x1000,%eax
80109111:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109114:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109118:	0f 85 6b ff ff ff    	jne    80109089 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010911e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109123:	c9                   	leave  
80109124:	c3                   	ret    
