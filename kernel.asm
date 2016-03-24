
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
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

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
8010003a:	c7 44 24 04 74 91 10 	movl   $0x80109174,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 30 5a 00 00       	call   80105a7e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 15 11 80       	mov    0x80111594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
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
801000b6:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801000bd:	e8 dd 59 00 00       	call   80105a9f <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 15 11 80       	mov    0x80111594,%eax
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
801000fd:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100104:	e8 f8 59 00 00       	call   80105b01 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 8b 55 00 00       	call   801056af <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 15 11 80       	mov    0x80111590,%eax
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
80100175:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010017c:	e8 80 59 00 00       	call   80105b01 <release>
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
8010018f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 7b 91 10 80 	movl   $0x8010917b,(%esp)
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
801001ef:	c7 04 24 8c 91 10 80 	movl   $0x8010918c,(%esp)
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
80100229:	c7 04 24 93 91 10 80 	movl   $0x80109193,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 5e 58 00 00       	call   80105a9f <acquire>

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
8010025f:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 15 11 80       	mov    0x80111594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 15 11 80       	mov    %eax,0x80111594

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
8010029d:	e8 e9 54 00 00       	call   8010578b <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 53 58 00 00       	call   80105b01 <release>
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
801003a7:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801003bc:	e8 de 56 00 00       	call   80105a9f <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 9a 91 10 80 	movl   $0x8010919a,(%esp)
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
801004af:	c7 45 ec a3 91 10 80 	movl   $0x801091a3,-0x14(%ebp)
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
8010052f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100536:	e8 c6 55 00 00       	call   80105b01 <release>
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
80100548:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 aa 91 10 80 	movl   $0x801091aa,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 b9 91 10 80 	movl   $0x801091b9,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 b9 55 00 00       	call   80105b50 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 bb 91 10 80 	movl   $0x801091bb,(%esp)
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
801005c1:	c7 05 cc c5 10 80 01 	movl   $0x1,0x8010c5cc
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
80100682:	c7 05 18 c6 10 80 00 	movl   $0x0,0x8010c618
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
801006e2:	e8 da 56 00 00       	call   80105dc1 <memmove>
  startingPos++;
801006e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  else if(c == BACKSPACE){
     if(pos > 0) {
      --pos;
      int startingPos = pos;
      int i;
      for (i = 0 ; i < tmpPos ; i++){
801006eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801006ef:	a1 18 c6 10 80       	mov    0x8010c618,%eax
801006f4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801006f7:	7c bf                	jl     801006b8 <cgaputc+0xc2>
  memmove(crt+startingPos, crt+startingPos+1, 1); // take the rest of the line on the right 1 place to the left
  startingPos++;
      }
     crt[pos+tmpPos] = ' ' | 0x0700; // the last place which held the last char should now be blank
801006f9:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801006ff:	a1 18 c6 10 80       	mov    0x8010c618,%eax
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
8010072d:	a1 18 c6 10 80       	mov    0x8010c618,%eax
80100732:	83 c0 01             	add    $0x1,%eax
80100735:	a3 18 c6 10 80       	mov    %eax,0x8010c618
8010073a:	e9 80 02 00 00       	jmp    801009bf <cgaputc+0x3c9>
    }
  }
  else if (c == KEY_RT) {
8010073f:	8b 45 08             	mov    0x8(%ebp),%eax
80100742:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100747:	75 23                	jne    8010076c <cgaputc+0x176>
    if (tmpPos > 0) {
80100749:	a1 18 c6 10 80       	mov    0x8010c618,%eax
8010074e:	85 c0                	test   %eax,%eax
80100750:	0f 8e 69 02 00 00    	jle    801009bf <cgaputc+0x3c9>
      ++pos;
80100756:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      tmpPos--; // counter for how left are we from the last char in the line
8010075a:	a1 18 c6 10 80       	mov    0x8010c618,%eax
8010075f:	83 e8 01             	sub    $0x1,%eax
80100762:	a3 18 c6 10 80       	mov    %eax,0x8010c618
80100767:	e9 53 02 00 00       	jmp    801009bf <cgaputc+0x3c9>
    }
  }
  else if(c == KEY_UP) { // take the historyCommand of calculated current index and copy it to crt, command not executed gets deleted once pressing up
8010076c:	8b 45 08             	mov    0x8(%ebp),%eax
8010076f:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100774:	0f 85 cd 00 00 00    	jne    80100847 <cgaputc+0x251>
      int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
8010077a:	8b 15 c0 c5 10 80    	mov    0x8010c5c0,%edx
80100780:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
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
801007b0:	05 60 18 11 80       	add    $0x80111860,%eax
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
801007dc:	e8 e0 55 00 00       	call   80105dc1 <memmove>
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
80100808:	05 60 18 11 80       	add    $0x80111860,%eax
8010080d:	89 04 24             	mov    %eax,(%esp)
80100810:	e8 57 57 00 00       	call   80105f6c <strlen>
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
80100829:	05 60 18 11 80       	add    $0x80111860,%eax
8010082e:	89 04 24             	mov    %eax,(%esp)
80100831:	e8 36 57 00 00       	call   80105f6c <strlen>
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
80100855:	8b 15 c0 c5 10 80    	mov    0x8010c5c0,%edx
8010085b:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
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
8010088b:	05 60 18 11 80       	add    $0x80111860,%eax
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
801008b7:	e8 05 55 00 00       	call   80105dc1 <memmove>
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
801008e3:	05 60 18 11 80       	add    $0x80111860,%eax
801008e8:	89 04 24             	mov    %eax,(%esp)
801008eb:	e8 7c 56 00 00       	call   80105f6c <strlen>
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
80100904:	05 60 18 11 80       	add    $0x80111860,%eax
80100909:	89 04 24             	mov    %eax,(%esp)
8010090c:	e8 5b 56 00 00       	call   80105f6c <strlen>
80100911:	03 45 f4             	add    -0xc(%ebp),%eax
80100914:	01 c0                	add    %eax,%eax
80100916:	01 d8                	add    %ebx,%eax
80100918:	66 c7 00 20 07       	movw   $0x720,(%eax)
8010091d:	e9 9d 00 00 00       	jmp    801009bf <cgaputc+0x3c9>
  }
  else
    if ( !tmpPos ) { // if we are at the end of the line, just write c to crt (tmpPos = 0 => the most right, !tmpPos=1 means we can write regular)
80100922:	a1 18 c6 10 80       	mov    0x8010c618,%eax
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
8010094a:	a1 18 c6 10 80       	mov    0x8010c618,%eax
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
8010098b:	e8 31 54 00 00       	call   80105dc1 <memmove>
        endPos--;
80100990:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
      crt[pos++] = (c&0xff) | 0x0700;
    }
    else { // if we're typing in the middle of the command, we shift the remaining right sentene from tmpPos to the right and write c
      int endPos = pos + tmpPos -1; // go to the end of the line
      int i;
      for (i = 0; i < tmpPos ; i++) {
80100994:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80100998:	a1 18 c6 10 80       	mov    0x8010c618,%eax
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
801009e7:	e8 d5 53 00 00       	call   80105dc1 <memmove>
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
80100a16:	e8 d3 52 00 00       	call   80105cee <memset>
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
80100aa2:	a1 18 c6 10 80       	mov    0x8010c618,%eax
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
80100ac8:	a1 cc c5 10 80       	mov    0x8010c5cc,%eax
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
80100ae9:	e8 d7 6c 00 00       	call   801077c5 <uartputc>
80100aee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100af5:	e8 cb 6c 00 00       	call   801077c5 <uartputc>
80100afa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100b01:	e8 bf 6c 00 00       	call   801077c5 <uartputc>
80100b06:	eb 0b                	jmp    80100b13 <consputc+0x51>
    default:
      uartputc(c);
80100b08:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0b:	89 04 24             	mov    %eax,(%esp)
80100b0e:	e8 b2 6c 00 00       	call   801077c5 <uartputc>
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
80100b28:	a1 58 18 11 80       	mov    0x80111858,%eax
80100b2d:	83 c0 01             	add    $0x1,%eax
80100b30:	a3 58 18 11 80       	mov    %eax,0x80111858
        consputc(KEY_RT);
80100b35:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100b3c:	e8 81 ff ff ff       	call   80100ac2 <consputc>


void
DeleteCurrentUnfinishedCommand()
{
  while(input.w < input.e) { // if we're in the middle of the command - go to the right
80100b41:	8b 15 58 18 11 80    	mov    0x80111858,%edx
80100b47:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100b4c:	39 c2                	cmp    %eax,%edx
80100b4e:	72 d8                	jb     80100b28 <DeleteCurrentUnfinishedCommand+0x8>
        input.w++;
        consputc(KEY_RT);
  }
  while(input.e != input.r && input.buf[(input.e-1) % INPUT_BUF] != '\n'){ // same as BACKSPACE: do it for entire line
80100b50:	eb 35                	jmp    80100b87 <DeleteCurrentUnfinishedCommand+0x67>
    input.e--;
80100b52:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100b57:	83 e8 01             	sub    $0x1,%eax
80100b5a:	a3 5c 18 11 80       	mov    %eax,0x8011185c
    if(input.w != input.r)
80100b5f:	8b 15 58 18 11 80    	mov    0x80111858,%edx
80100b65:	a1 54 18 11 80       	mov    0x80111854,%eax
80100b6a:	39 c2                	cmp    %eax,%edx
80100b6c:	74 0d                	je     80100b7b <DeleteCurrentUnfinishedCommand+0x5b>
      input.w--;
80100b6e:	a1 58 18 11 80       	mov    0x80111858,%eax
80100b73:	83 e8 01             	sub    $0x1,%eax
80100b76:	a3 58 18 11 80       	mov    %eax,0x80111858
      consputc(BACKSPACE);
80100b7b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100b82:	e8 3b ff ff ff       	call   80100ac2 <consputc>
{
  while(input.w < input.e) { // if we're in the middle of the command - go to the right
        input.w++;
        consputc(KEY_RT);
  }
  while(input.e != input.r && input.buf[(input.e-1) % INPUT_BUF] != '\n'){ // same as BACKSPACE: do it for entire line
80100b87:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100b8d:	a1 54 18 11 80       	mov    0x80111854,%eax
80100b92:	39 c2                	cmp    %eax,%edx
80100b94:	74 16                	je     80100bac <DeleteCurrentUnfinishedCommand+0x8c>
80100b96:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100b9b:	83 e8 01             	sub    $0x1,%eax
80100b9e:	83 e0 7f             	and    $0x7f,%eax
80100ba1:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
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
80100bb5:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100bbc:	e8 de 4e 00 00       	call   80105a9f <acquire>
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
80100c2c:	e8 00 4c 00 00       	call   80105831 <procdump>
      break;
80100c31:	e9 ea 04 00 00       	jmp    80101120 <consoleintr+0x572>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100c36:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100c3b:	83 e8 01             	sub    $0x1,%eax
80100c3e:	a3 5c 18 11 80       	mov    %eax,0x8011185c
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
80100c52:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100c58:	a1 58 18 11 80       	mov    0x80111858,%eax
80100c5d:	39 c2                	cmp    %eax,%edx
80100c5f:	0f 84 a5 04 00 00    	je     8010110a <consoleintr+0x55c>
80100c65:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100c6a:	83 e8 01             	sub    $0x1,%eax
80100c6d:	83 e0 7f             	and    $0x7f,%eax
80100c70:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
80100c77:	3c 0a                	cmp    $0xa,%al
80100c79:	75 bb                	jne    80100c36 <consoleintr+0x88>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c7b:	e9 8a 04 00 00       	jmp    8010110a <consoleintr+0x55c>
    case C('H'): case '\x7f':  // Backspace
      if(input.w != input.r) {
80100c80:	8b 15 58 18 11 80    	mov    0x80111858,%edx
80100c86:	a1 54 18 11 80       	mov    0x80111854,%eax
80100c8b:	39 c2                	cmp    %eax,%edx
80100c8d:	0f 84 7a 04 00 00    	je     8010110d <consoleintr+0x55f>
  int forwardPos = input.w;
80100c93:	a1 58 18 11 80       	mov    0x80111858,%eax
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
80100cbc:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
80100cc3:	88 81 d4 17 11 80    	mov    %al,-0x7feee82c(%ecx)
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
80100cd4:	8b 0d 5c 18 11 80    	mov    0x8011185c,%ecx
80100cda:	8b 15 58 18 11 80    	mov    0x80111858,%edx
80100ce0:	89 cb                	mov    %ecx,%ebx
80100ce2:	29 d3                	sub    %edx,%ebx
80100ce4:	89 da                	mov    %ebx,%edx
80100ce6:	39 d0                	cmp    %edx,%eax
80100ce8:	72 ba                	jb     80100ca4 <consoleintr+0xf6>
    input.buf[forwardPos-1 % INPUT_BUF] = input.buf[forwardPos % INPUT_BUF];
    forwardPos++;
  }
  input.e--;
80100cea:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100cef:	83 e8 01             	sub    $0x1,%eax
80100cf2:	a3 5c 18 11 80       	mov    %eax,0x8011185c
  input.w--;
80100cf7:	a1 58 18 11 80       	mov    0x80111858,%eax
80100cfc:	83 e8 01             	sub    $0x1,%eax
80100cff:	a3 58 18 11 80       	mov    %eax,0x80111858
        consputc(BACKSPACE);
80100d04:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100d0b:	e8 b2 fd ff ff       	call   80100ac2 <consputc>
      }
      break;
80100d10:	e9 f8 03 00 00       	jmp    8010110d <consoleintr+0x55f>
    case KEY_LF:
      if(input.r < input.w) {
80100d15:	8b 15 54 18 11 80    	mov    0x80111854,%edx
80100d1b:	a1 58 18 11 80       	mov    0x80111858,%eax
80100d20:	39 c2                	cmp    %eax,%edx
80100d22:	0f 83 e8 03 00 00    	jae    80101110 <consoleintr+0x562>
        input.w--;
80100d28:	a1 58 18 11 80       	mov    0x80111858,%eax
80100d2d:	83 e8 01             	sub    $0x1,%eax
80100d30:	a3 58 18 11 80       	mov    %eax,0x80111858
        consputc(KEY_LF);
80100d35:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100d3c:	e8 81 fd ff ff       	call   80100ac2 <consputc>
      }
      break;
80100d41:	e9 ca 03 00 00       	jmp    80101110 <consoleintr+0x562>
    case KEY_RT:
      if(input.w < input.e) {
80100d46:	8b 15 58 18 11 80    	mov    0x80111858,%edx
80100d4c:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100d51:	39 c2                	cmp    %eax,%edx
80100d53:	0f 83 ba 03 00 00    	jae    80101113 <consoleintr+0x565>
        input.w++;
80100d59:	a1 58 18 11 80       	mov    0x80111858,%eax
80100d5e:	83 c0 01             	add    $0x1,%eax
80100d61:	a3 58 18 11 80       	mov    %eax,0x80111858
        consputc(KEY_RT);
80100d66:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100d6d:	e8 50 fd ff ff       	call   80100ac2 <consputc>
      }
      break;
80100d72:	e9 9c 03 00 00       	jmp    80101113 <consoleintr+0x565>
    case KEY_UP:
      if (commandExecuted == 0 && historyArrayIsFull == 0) { // no history yet, nothing been executed
80100d77:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
80100d7c:	85 c0                	test   %eax,%eax
80100d7e:	75 0d                	jne    80100d8d <consoleintr+0x1df>
80100d80:	a1 c4 c5 10 80       	mov    0x8010c5c4,%eax
80100d85:	85 c0                	test   %eax,%eax
80100d87:	0f 84 93 03 00 00    	je     80101120 <consoleintr+0x572>
        break;
      }
      else if (commandExecuted-currentHistoryPos == 0 && historyArrayIsFull==0) { // we are at the last command executed, can't go up
80100d8d:	8b 15 c0 c5 10 80    	mov    0x8010c5c0,%edx
80100d93:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100d98:	39 c2                	cmp    %eax,%edx
80100d9a:	75 0d                	jne    80100da9 <consoleintr+0x1fb>
80100d9c:	a1 c4 c5 10 80       	mov    0x8010c5c4,%eax
80100da1:	85 c0                	test   %eax,%eax
80100da3:	0f 84 77 03 00 00    	je     80101120 <consoleintr+0x572>
        break;
      }
      else if (currentHistoryPos != MAX_HISTORY) { // can perform history execution.
80100da9:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100dae:	83 f8 10             	cmp    $0x10,%eax
80100db1:	0f 84 5f 03 00 00    	je     80101116 <consoleintr+0x568>
  if(currentHistoryPos < MAX_HISTORY){
80100db7:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100dbc:	83 f8 0f             	cmp    $0xf,%eax
80100dbf:	7f 0d                	jg     80100dce <consoleintr+0x220>
    currentHistoryPos = currentHistoryPos + 1;
80100dc1:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100dc6:	83 c0 01             	add    $0x1,%eax
80100dc9:	a3 c8 c5 10 80       	mov    %eax,0x8010c5c8
  }
        DeleteCurrentUnfinishedCommand();
80100dce:	e8 4d fd ff ff       	call   80100b20 <DeleteCurrentUnfinishedCommand>
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
80100dd3:	8b 15 c0 c5 10 80    	mov    0x8010c5c0,%edx
80100dd9:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
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
80100e09:	05 60 18 11 80       	add    $0x80111860,%eax
80100e0e:	0f b6 00             	movzbl (%eax),%eax
80100e11:	0f be c0             	movsbl %al,%eax
80100e14:	89 45 d8             	mov    %eax,-0x28(%ebp)
          input.buf[input.w++ % INPUT_BUF] = c;
80100e17:	a1 58 18 11 80       	mov    0x80111858,%eax
80100e1c:	89 c1                	mov    %eax,%ecx
80100e1e:	83 e1 7f             	and    $0x7f,%ecx
80100e21:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100e24:	88 91 d4 17 11 80    	mov    %dl,-0x7feee82c(%ecx)
80100e2a:	83 c0 01             	add    $0x1,%eax
80100e2d:	a3 58 18 11 80       	mov    %eax,0x80111858
    input.e++;
80100e32:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100e37:	83 c0 01             	add    $0x1,%eax
80100e3a:	a3 5c 18 11 80       	mov    %eax,0x8011185c
    currentHistoryPos = currentHistoryPos + 1;
  }
        DeleteCurrentUnfinishedCommand();
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
80100e3f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e46:	c1 e0 07             	shl    $0x7,%eax
80100e49:	05 60 18 11 80       	add    $0x80111860,%eax
80100e4e:	89 04 24             	mov    %eax,(%esp)
80100e51:	e8 16 51 00 00       	call   80105f6c <strlen>
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
80100e6f:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
80100e74:	85 c0                	test   %eax,%eax
80100e76:	75 0d                	jne    80100e85 <consoleintr+0x2d7>
80100e78:	a1 c4 c5 10 80       	mov    0x8010c5c4,%eax
80100e7d:	85 c0                	test   %eax,%eax
80100e7f:	0f 84 9b 02 00 00    	je     80101120 <consoleintr+0x572>
        break;
      }
      else if (currentHistoryPos==0 ) {
80100e85:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100e8a:	85 c0                	test   %eax,%eax
80100e8c:	0f 84 87 02 00 00    	je     80101119 <consoleintr+0x56b>
        break;
      }
      else if (currentHistoryPos) {
80100e92:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100e97:	85 c0                	test   %eax,%eax
80100e99:	0f 84 7d 02 00 00    	je     8010111c <consoleintr+0x56e>
  currentHistoryPos = currentHistoryPos - 1;
80100e9f:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
80100ea4:	83 e8 01             	sub    $0x1,%eax
80100ea7:	a3 c8 c5 10 80       	mov    %eax,0x8010c5c8
        DeleteCurrentUnfinishedCommand();
80100eac:	e8 6f fc ff ff       	call   80100b20 <DeleteCurrentUnfinishedCommand>
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
80100eb1:	8b 15 c0 c5 10 80    	mov    0x8010c5c0,%edx
80100eb7:	a1 c8 c5 10 80       	mov    0x8010c5c8,%eax
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
80100ee7:	05 60 18 11 80       	add    $0x80111860,%eax
80100eec:	0f b6 00             	movzbl (%eax),%eax
80100eef:	0f be c0             	movsbl %al,%eax
80100ef2:	89 45 d8             	mov    %eax,-0x28(%ebp)
          input.buf[input.w++ % INPUT_BUF] = c;
80100ef5:	a1 58 18 11 80       	mov    0x80111858,%eax
80100efa:	89 c1                	mov    %eax,%ecx
80100efc:	83 e1 7f             	and    $0x7f,%ecx
80100eff:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f02:	88 91 d4 17 11 80    	mov    %dl,-0x7feee82c(%ecx)
80100f08:	83 c0 01             	add    $0x1,%eax
80100f0b:	a3 58 18 11 80       	mov    %eax,0x80111858
    input.e++;
80100f10:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100f15:	83 c0 01             	add    $0x1,%eax
80100f18:	a3 5c 18 11 80       	mov    %eax,0x8011185c
      else if (currentHistoryPos) {
  currentHistoryPos = currentHistoryPos - 1;
        DeleteCurrentUnfinishedCommand();
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
80100f1d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	c1 e0 07             	shl    $0x7,%eax
80100f27:	05 60 18 11 80       	add    $0x80111860,%eax
80100f2c:	89 04 24             	mov    %eax,(%esp)
80100f2f:	e8 38 50 00 00       	call   80105f6c <strlen>
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
80100f57:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100f5d:	a1 54 18 11 80       	mov    0x80111854,%eax
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
80100f8e:	a1 5c 18 11 80       	mov    0x8011185c,%eax
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
80100fb7:	0f b6 92 d4 17 11 80 	movzbl -0x7feee82c(%edx),%edx
80100fbe:	88 90 d4 17 11 80    	mov    %dl,-0x7feee82c(%eax)
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
80100fcf:	8b 0d 5c 18 11 80    	mov    0x8011185c,%ecx
80100fd5:	8b 15 58 18 11 80    	mov    0x80111858,%edx
80100fdb:	89 cb                	mov    %ecx,%ebx
80100fdd:	29 d3                	sub    %edx,%ebx
80100fdf:	89 da                	mov    %ebx,%edx
80100fe1:	39 d0                	cmp    %edx,%eax
80100fe3:	72 ba                	jb     80100f9f <consoleintr+0x3f1>
      input.buf[forwardPos % INPUT_BUF] = input.buf[forwardPos-1 % INPUT_BUF];
      forwardPos--;
    }
    input.buf[input.w++ % INPUT_BUF] = c;
80100fe5:	a1 58 18 11 80       	mov    0x80111858,%eax
80100fea:	89 c1                	mov    %eax,%ecx
80100fec:	83 e1 7f             	and    $0x7f,%ecx
80100fef:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100ff2:	88 91 d4 17 11 80    	mov    %dl,-0x7feee82c(%ecx)
80100ff8:	83 c0 01             	add    $0x1,%eax
80100ffb:	a3 58 18 11 80       	mov    %eax,0x80111858
    input.e++;
80101000:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80101005:	83 c0 01             	add    $0x1,%eax
80101008:	a3 5c 18 11 80       	mov    %eax,0x8011185c
8010100d:	eb 1b                	jmp    8010102a <consoleintr+0x47c>
  }
  else {
    input.buf[input.e++ % INPUT_BUF] = c;
8010100f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80101014:	89 c1                	mov    %eax,%ecx
80101016:	83 e1 7f             	and    $0x7f,%ecx
80101019:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010101c:	88 91 d4 17 11 80    	mov    %dl,-0x7feee82c(%ecx)
80101022:	83 c0 01             	add    $0x1,%eax
80101025:	a3 5c 18 11 80       	mov    %eax,0x8011185c
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
80101041:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80101046:	8b 15 54 18 11 80    	mov    0x80111854,%edx
8010104c:	83 ea 80             	sub    $0xffffff80,%edx
8010104f:	39 d0                	cmp    %edx,%eax
80101051:	0f 85 c8 00 00 00    	jne    8010111f <consoleintr+0x571>
    currentHistoryPos=0;
80101057:	c7 05 c8 c5 10 80 00 	movl   $0x0,0x8010c5c8
8010105e:	00 00 00 
          int tmpHistoryIndex;
    for (tmpHistoryIndex = 0 ; tmpHistoryIndex < input.e-input.r ; tmpHistoryIndex++){ // copy the command from the buffer to the historyArray at current position
80101061:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80101068:	eb 3b                	jmp    801010a5 <consoleintr+0x4f7>
      historyArray[commandExecuted][tmpHistoryIndex] = input.buf[input.r+tmpHistoryIndex % INPUT_BUF]; // copy chars from buffer to array
8010106a:	8b 0d c0 c5 10 80    	mov    0x8010c5c0,%ecx
80101070:	8b 1d 54 18 11 80    	mov    0x80111854,%ebx
80101076:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101079:	89 c2                	mov    %eax,%edx
8010107b:	c1 fa 1f             	sar    $0x1f,%edx
8010107e:	c1 ea 19             	shr    $0x19,%edx
80101081:	01 d0                	add    %edx,%eax
80101083:	83 e0 7f             	and    $0x7f,%eax
80101086:	29 d0                	sub    %edx,%eax
80101088:	01 d8                	add    %ebx,%eax
8010108a:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
80101091:	89 ca                	mov    %ecx,%edx
80101093:	c1 e2 07             	shl    $0x7,%edx
80101096:	03 55 dc             	add    -0x24(%ebp),%edx
80101099:	81 c2 60 18 11 80    	add    $0x80111860,%edx
8010109f:	88 02                	mov    %al,(%edx)
  }
        consputc(c);
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
    currentHistoryPos=0;
          int tmpHistoryIndex;
    for (tmpHistoryIndex = 0 ; tmpHistoryIndex < input.e-input.r ; tmpHistoryIndex++){ // copy the command from the buffer to the historyArray at current position
801010a1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801010a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010a8:	8b 0d 5c 18 11 80    	mov    0x8011185c,%ecx
801010ae:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801010b4:	89 cb                	mov    %ecx,%ebx
801010b6:	29 d3                	sub    %edx,%ebx
801010b8:	89 da                	mov    %ebx,%edx
801010ba:	39 d0                	cmp    %edx,%eax
801010bc:	72 ac                	jb     8010106a <consoleintr+0x4bc>
      historyArray[commandExecuted][tmpHistoryIndex] = input.buf[input.r+tmpHistoryIndex % INPUT_BUF]; // copy chars from buffer to array
    }

          if (commandExecuted == MAX_HISTORY-1)
801010be:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
801010c3:	83 f8 0f             	cmp    $0xf,%eax
801010c6:	75 0a                	jne    801010d2 <consoleintr+0x524>
            historyArrayIsFull = 1;
801010c8:	c7 05 c4 c5 10 80 01 	movl   $0x1,0x8010c5c4
801010cf:	00 00 00 
    commandExecuted = (commandExecuted+1) % MAX_HISTORY;
801010d2:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
801010d7:	8d 50 01             	lea    0x1(%eax),%edx
801010da:	89 d0                	mov    %edx,%eax
801010dc:	c1 f8 1f             	sar    $0x1f,%eax
801010df:	c1 e8 1c             	shr    $0x1c,%eax
801010e2:	01 c2                	add    %eax,%edx
801010e4:	83 e2 0f             	and    $0xf,%edx
801010e7:	89 d1                	mov    %edx,%ecx
801010e9:	29 c1                	sub    %eax,%ecx
801010eb:	89 c8                	mov    %ecx,%eax
801010ed:	a3 c0 c5 10 80       	mov    %eax,0x8010c5c0

          input.w = input.e;
801010f2:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801010f7:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
801010fc:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
80101103:	e8 83 46 00 00       	call   8010578b <wakeup>
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
80101132:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80101139:	e8 c3 49 00 00       	call   80105b01 <release>
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
8010115b:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80101162:	e8 38 49 00 00       	call   80105a9f <acquire>
  while(n > 0){
80101167:	e9 a8 00 00 00       	jmp    80101214 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010116c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101172:	8b 40 24             	mov    0x24(%eax),%eax
80101175:	85 c0                	test   %eax,%eax
80101177:	74 21                	je     8010119a <consoleread+0x56>
        release(&input.lock);
80101179:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80101180:	e8 7c 49 00 00       	call   80105b01 <release>
        ilock(ip);
80101185:	8b 45 08             	mov    0x8(%ebp),%eax
80101188:	89 04 24             	mov    %eax,(%esp)
8010118b:	e8 65 0f 00 00       	call   801020f5 <ilock>
        return -1;
80101190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101195:	e9 a9 00 00 00       	jmp    80101243 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010119a:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
801011a1:	80 
801011a2:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801011a9:	e8 01 45 00 00       	call   801056af <sleep>
801011ae:	eb 01                	jmp    801011b1 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801011b0:	90                   	nop
801011b1:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801011b7:	a1 58 18 11 80       	mov    0x80111858,%eax
801011bc:	39 c2                	cmp    %eax,%edx
801011be:	74 ac                	je     8010116c <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801011c0:	a1 54 18 11 80       	mov    0x80111854,%eax
801011c5:	89 c2                	mov    %eax,%edx
801011c7:	83 e2 7f             	and    $0x7f,%edx
801011ca:	0f b6 92 d4 17 11 80 	movzbl -0x7feee82c(%edx),%edx
801011d1:	0f be d2             	movsbl %dl,%edx
801011d4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011d7:	83 c0 01             	add    $0x1,%eax
801011da:	a3 54 18 11 80       	mov    %eax,0x80111854
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
801011ed:	a1 54 18 11 80       	mov    0x80111854,%eax
801011f2:	83 e8 01             	sub    $0x1,%eax
801011f5:	a3 54 18 11 80       	mov    %eax,0x80111854
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
80101220:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80101227:	e8 d5 48 00 00       	call   80105b01 <release>
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
80101256:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
8010125d:	e8 3d 48 00 00       	call   80105a9f <acquire>
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
80101290:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80101297:	e8 65 48 00 00       	call   80105b01 <release>
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
801012b2:	c7 44 24 04 bf 91 10 	movl   $0x801091bf,0x4(%esp)
801012b9:	80 
801012ba:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801012c1:	e8 b8 47 00 00       	call   80105a7e <initlock>
  initlock(&input.lock, "input");
801012c6:	c7 44 24 04 c7 91 10 	movl   $0x801091c7,0x4(%esp)
801012cd:	80 
801012ce:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801012d5:	e8 a4 47 00 00       	call   80105a7e <initlock>

  devsw[CONSOLE].write = consolewrite;
801012da:	c7 05 0c 2a 11 80 45 	movl   $0x80101245,0x80112a0c
801012e1:	12 10 80 
  devsw[CONSOLE].read = consoleread;
801012e4:	c7 05 08 2a 11 80 44 	movl   $0x80101144,0x80112a08
801012eb:	11 10 80 
  cons.locking = 1;
801012ee:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
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
8010139e:	e8 66 75 00 00       	call   80108909 <setupkvm>
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
80101437:	e8 9f 78 00 00       	call   80108cdb <allocuvm>
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
80101474:	e8 73 77 00 00       	call   80108bec <loaduvm>
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
801014e4:	e8 f2 77 00 00       	call   80108cdb <allocuvm>
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
80101508:	e8 f2 79 00 00       	call   80108eff <clearpteu>
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
80101537:	e8 30 4a 00 00       	call   80105f6c <strlen>
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
80101555:	e8 12 4a 00 00       	call   80105f6c <strlen>
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
8010157f:	e8 40 7b 00 00       	call   801090c4 <copyout>
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
8010161f:	e8 a0 7a 00 00       	call   801090c4 <copyout>
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
80101676:	e8 a3 48 00 00       	call   80105f1e <safestrcpy>

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
801016c8:	e8 2d 73 00 00       	call   801089fa <switchuvm>
  freevm(oldpgdir);
801016cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801016d0:	89 04 24             	mov    %eax,(%esp)
801016d3:	e8 99 77 00 00       	call   80108e71 <freevm>
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
8010170a:	e8 62 77 00 00       	call   80108e71 <freevm>
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
80101732:	c7 44 24 04 cd 91 10 	movl   $0x801091cd,0x4(%esp)
80101739:	80 
8010173a:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101741:	e8 38 43 00 00       	call   80105a7e <initlock>
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
8010174e:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101755:	e8 45 43 00 00       	call   80105a9f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010175a:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
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
80101777:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
8010177e:	e8 7e 43 00 00       	call   80105b01 <release>
      return f;
80101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101786:	eb 1e                	jmp    801017a6 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101788:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010178c:	81 7d f4 f4 29 11 80 	cmpl   $0x801129f4,-0xc(%ebp)
80101793:	72 ce                	jb     80101763 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101795:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
8010179c:	e8 60 43 00 00       	call   80105b01 <release>
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
801017ae:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
801017b5:	e8 e5 42 00 00       	call   80105a9f <acquire>
  if(f->ref < 1)
801017ba:	8b 45 08             	mov    0x8(%ebp),%eax
801017bd:	8b 40 04             	mov    0x4(%eax),%eax
801017c0:	85 c0                	test   %eax,%eax
801017c2:	7f 0c                	jg     801017d0 <filedup+0x28>
    panic("filedup");
801017c4:	c7 04 24 d4 91 10 80 	movl   $0x801091d4,(%esp)
801017cb:	e8 6d ed ff ff       	call   8010053d <panic>
  f->ref++;
801017d0:	8b 45 08             	mov    0x8(%ebp),%eax
801017d3:	8b 40 04             	mov    0x4(%eax),%eax
801017d6:	8d 50 01             	lea    0x1(%eax),%edx
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801017df:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
801017e6:	e8 16 43 00 00       	call   80105b01 <release>
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
801017f6:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
801017fd:	e8 9d 42 00 00       	call   80105a9f <acquire>
  if(f->ref < 1)
80101802:	8b 45 08             	mov    0x8(%ebp),%eax
80101805:	8b 40 04             	mov    0x4(%eax),%eax
80101808:	85 c0                	test   %eax,%eax
8010180a:	7f 0c                	jg     80101818 <fileclose+0x28>
    panic("fileclose");
8010180c:	c7 04 24 dc 91 10 80 	movl   $0x801091dc,(%esp)
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
80101831:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101838:	e8 c4 42 00 00       	call   80105b01 <release>
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
8010187b:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101882:	e8 7a 42 00 00       	call   80105b01 <release>
  
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
801019c3:	c7 04 24 e6 91 10 80 	movl   $0x801091e6,(%esp)
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
80101acf:	c7 04 24 ef 91 10 80 	movl   $0x801091ef,(%esp)
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
80101b04:	c7 04 24 ff 91 10 80 	movl   $0x801091ff,(%esp)
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
80101b4c:	e8 70 42 00 00       	call   80105dc1 <memmove>
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
80101b92:	e8 57 41 00 00       	call   80105cee <memset>
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
80101bdc:	a1 78 2a 11 80       	mov    0x80112a78,%eax
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
80101cbb:	a1 60 2a 11 80       	mov    0x80112a60,%eax
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
80101cdd:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101ce2:	39 c2                	cmp    %eax,%edx
80101ce4:	0f 82 df fe ff ff    	jb     80101bc9 <balloc+0x1a>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101cea:	c7 04 24 0c 92 10 80 	movl   $0x8010920c,(%esp)
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
80101cfd:	c7 44 24 04 60 2a 11 	movl   $0x80112a60,0x4(%esp)
80101d04:	80 
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	89 04 24             	mov    %eax,(%esp)
80101d0b:	e8 08 fe ff ff       	call   80101b18 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101d10:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d13:	89 c2                	mov    %eax,%edx
80101d15:	c1 ea 0c             	shr    $0xc,%edx
80101d18:	a1 78 2a 11 80       	mov    0x80112a78,%eax
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
80101d7e:	c7 04 24 22 92 10 80 	movl   $0x80109222,(%esp)
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
80101dd5:	c7 44 24 04 35 92 10 	movl   $0x80109235,0x4(%esp)
80101ddc:	80 
80101ddd:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80101de4:	e8 95 3c 00 00       	call   80105a7e <initlock>
  readsb(dev, &sb);
80101de9:	c7 44 24 04 60 2a 11 	movl   $0x80112a60,0x4(%esp)
80101df0:	80 
80101df1:	8b 45 08             	mov    0x8(%ebp),%eax
80101df4:	89 04 24             	mov    %eax,(%esp)
80101df7:	e8 1c fd ff ff       	call   80101b18 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101dfc:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101e01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101e04:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101e0a:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101e10:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101e16:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101e1c:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101e22:	a1 60 2a 11 80       	mov    0x80112a60,%eax
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
80101e4c:	c7 04 24 3c 92 10 80 	movl   $0x8010923c,(%esp)
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
80101e81:	a1 74 2a 11 80       	mov    0x80112a74,%eax
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
80101ecf:	e8 1a 3e 00 00       	call   80105cee <memset>
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
80101f1a:	a1 68 2a 11 80       	mov    0x80112a68,%eax
80101f1f:	39 c2                	cmp    %eax,%edx
80101f21:	0f 82 52 ff ff ff    	jb     80101e79 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101f27:	c7 04 24 8f 92 10 80 	movl   $0x8010928f,(%esp)
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
80101f44:	a1 74 2a 11 80       	mov    0x80112a74,%eax
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
80101fd4:	e8 e8 3d 00 00       	call   80105dc1 <memmove>
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
80101ff7:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80101ffe:	e8 9c 3a 00 00       	call   80105a9f <acquire>

  // Is the inode already cached?
  empty = 0;
80102003:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010200a:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
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
80102041:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80102048:	e8 b4 3a 00 00       	call   80105b01 <release>
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
8010206c:	81 7d f4 54 3a 11 80 	cmpl   $0x80113a54,-0xc(%ebp)
80102073:	72 9e                	jb     80102013 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80102075:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102079:	75 0c                	jne    80102087 <iget+0x96>
    panic("iget: no inodes");
8010207b:	c7 04 24 a1 92 10 80 	movl   $0x801092a1,(%esp)
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
801020b2:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801020b9:	e8 43 3a 00 00       	call   80105b01 <release>

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
801020c9:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801020d0:	e8 ca 39 00 00       	call   80105a9f <acquire>
  ip->ref++;
801020d5:	8b 45 08             	mov    0x8(%ebp),%eax
801020d8:	8b 40 08             	mov    0x8(%eax),%eax
801020db:	8d 50 01             	lea    0x1(%eax),%edx
801020de:	8b 45 08             	mov    0x8(%ebp),%eax
801020e1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801020e4:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801020eb:	e8 11 3a 00 00       	call   80105b01 <release>
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
8010210b:	c7 04 24 b1 92 10 80 	movl   $0x801092b1,(%esp)
80102112:	e8 26 e4 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102117:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010211e:	e8 7c 39 00 00       	call   80105a9f <acquire>
  while(ip->flags & I_BUSY)
80102123:	eb 13                	jmp    80102138 <ilock+0x43>
    sleep(ip, &icache.lock);
80102125:	c7 44 24 04 80 2a 11 	movl   $0x80112a80,0x4(%esp)
8010212c:	80 
8010212d:	8b 45 08             	mov    0x8(%ebp),%eax
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	e8 77 35 00 00       	call   801056af <sleep>

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
80102156:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010215d:	e8 9f 39 00 00       	call   80105b01 <release>

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
8010217e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
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
8010220e:	e8 ae 3b 00 00       	call   80105dc1 <memmove>
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
8010223b:	c7 04 24 b7 92 10 80 	movl   $0x801092b7,(%esp)
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
8010226c:	c7 04 24 c6 92 10 80 	movl   $0x801092c6,(%esp)
80102273:	e8 c5 e2 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102278:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010227f:	e8 1b 38 00 00       	call   80105a9f <acquire>
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
8010229b:	e8 eb 34 00 00       	call   8010578b <wakeup>
  release(&icache.lock);
801022a0:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801022a7:	e8 55 38 00 00       	call   80105b01 <release>
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
801022b4:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801022bb:	e8 df 37 00 00       	call   80105a9f <acquire>
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
801022f9:	c7 04 24 ce 92 10 80 	movl   $0x801092ce,(%esp)
80102300:	e8 38 e2 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	8b 40 0c             	mov    0xc(%eax),%eax
8010230b:	89 c2                	mov    %eax,%edx
8010230d:	83 ca 01             	or     $0x1,%edx
80102310:	8b 45 08             	mov    0x8(%ebp),%eax
80102313:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80102316:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010231d:	e8 df 37 00 00       	call   80105b01 <release>
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
80102341:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80102348:	e8 52 37 00 00       	call   80105a9f <acquire>
    ip->flags = 0;
8010234d:	8b 45 08             	mov    0x8(%ebp),%eax
80102350:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80102357:	8b 45 08             	mov    0x8(%ebp),%eax
8010235a:	89 04 24             	mov    %eax,(%esp)
8010235d:	e8 29 34 00 00       	call   8010578b <wakeup>
  }
  ip->ref--;
80102362:	8b 45 08             	mov    0x8(%ebp),%eax
80102365:	8b 40 08             	mov    0x8(%eax),%eax
80102368:	8d 50 ff             	lea    -0x1(%eax),%edx
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80102371:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80102378:	e8 84 37 00 00       	call   80105b01 <release>
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
8010248d:	c7 04 24 d8 92 10 80 	movl   $0x801092d8,(%esp)
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
80102626:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
8010262d:	85 c0                	test   %eax,%eax
8010262f:	75 0a                	jne    8010263b <readi+0x4a>
      return -1;
80102631:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102636:	e9 1b 01 00 00       	jmp    80102756 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
8010263b:	8b 45 08             	mov    0x8(%ebp),%eax
8010263e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102642:	98                   	cwtl   
80102643:	8b 14 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%edx
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
80102725:	e8 97 36 00 00       	call   80105dc1 <memmove>
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
80102791:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
80102798:	85 c0                	test   %eax,%eax
8010279a:	75 0a                	jne    801027a6 <writei+0x4a>
      return -1;
8010279c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027a1:	e9 46 01 00 00       	jmp    801028ec <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
801027a6:	8b 45 08             	mov    0x8(%ebp),%eax
801027a9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027ad:	98                   	cwtl   
801027ae:	8b 14 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%edx
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
8010288b:	e8 31 35 00 00       	call   80105dc1 <memmove>
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
8010290d:	e8 53 35 00 00       	call   80105e65 <strncmp>
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
80102927:	c7 04 24 eb 92 10 80 	movl   $0x801092eb,(%esp)
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
80102965:	c7 04 24 fd 92 10 80 	movl   $0x801092fd,(%esp)
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
80102a49:	c7 04 24 fd 92 10 80 	movl   $0x801092fd,(%esp)
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
80102a8f:	e8 29 34 00 00       	call   80105ebd <strncpy>
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
80102ac1:	c7 04 24 0a 93 10 80 	movl   $0x8010930a,(%esp)
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
80102b48:	e8 74 32 00 00       	call   80105dc1 <memmove>
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
80102b63:	e8 59 32 00 00       	call   80105dc1 <memmove>
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
80102dc0:	c7 44 24 04 12 93 10 	movl   $0x80109312,0x4(%esp)
80102dc7:	80 
80102dc8:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102dcf:	e8 aa 2c 00 00       	call   80105a7e <initlock>
  picenable(IRQ_IDE);
80102dd4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102ddb:	e8 e5 18 00 00       	call   801046c5 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102de0:	a1 80 41 11 80       	mov    0x80114180,%eax
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
80102e31:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
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
80102e6c:	c7 04 24 16 93 10 80 	movl   $0x80109316,(%esp)
80102e73:	e8 c5 d6 ff ff       	call   8010053d <panic>
  if(b->blockno >= FSSIZE)
80102e78:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7b:	8b 40 08             	mov    0x8(%eax),%eax
80102e7e:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e83:	76 0c                	jbe    80102e91 <idestart+0x31>
    panic("incorrect blockno");
80102e85:	c7 04 24 1f 93 10 80 	movl   $0x8010931f,(%esp)
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
80102ead:	c7 04 24 16 93 10 80 	movl   $0x80109316,(%esp)
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
80102fc2:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102fc9:	e8 d1 2a 00 00       	call   80105a9f <acquire>
  if((b = idequeue) == 0){
80102fce:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102fd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102fda:	75 11                	jne    80102fed <ideintr+0x31>
    release(&idelock);
80102fdc:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102fe3:	e8 19 2b 00 00       	call   80105b01 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102fe8:	e9 90 00 00 00       	jmp    8010307d <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ff0:	8b 40 14             	mov    0x14(%eax),%eax
80102ff3:	a3 54 c6 10 80       	mov    %eax,0x8010c654

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
80103056:	e8 30 27 00 00       	call   8010578b <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010305b:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80103060:	85 c0                	test   %eax,%eax
80103062:	74 0d                	je     80103071 <ideintr+0xb5>
    idestart(idequeue);
80103064:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80103069:	89 04 24             	mov    %eax,(%esp)
8010306c:	e8 ef fd ff ff       	call   80102e60 <idestart>

  release(&idelock);
80103071:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80103078:	e8 84 2a 00 00       	call   80105b01 <release>
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
80103091:	c7 04 24 31 93 10 80 	movl   $0x80109331,(%esp)
80103098:	e8 a0 d4 ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010309d:	8b 45 08             	mov    0x8(%ebp),%eax
801030a0:	8b 00                	mov    (%eax),%eax
801030a2:	83 e0 06             	and    $0x6,%eax
801030a5:	83 f8 02             	cmp    $0x2,%eax
801030a8:	75 0c                	jne    801030b6 <iderw+0x37>
    panic("iderw: nothing to do");
801030aa:	c7 04 24 45 93 10 80 	movl   $0x80109345,(%esp)
801030b1:	e8 87 d4 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801030b6:	8b 45 08             	mov    0x8(%ebp),%eax
801030b9:	8b 40 04             	mov    0x4(%eax),%eax
801030bc:	85 c0                	test   %eax,%eax
801030be:	74 15                	je     801030d5 <iderw+0x56>
801030c0:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801030c5:	85 c0                	test   %eax,%eax
801030c7:	75 0c                	jne    801030d5 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801030c9:	c7 04 24 5a 93 10 80 	movl   $0x8010935a,(%esp)
801030d0:	e8 68 d4 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
801030d5:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801030dc:	e8 be 29 00 00       	call   80105a9f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801030e1:	8b 45 08             	mov    0x8(%ebp),%eax
801030e4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801030eb:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
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
80103110:	a1 54 c6 10 80       	mov    0x8010c654,%eax
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
80103127:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
8010312e:	80 
8010312f:	8b 45 08             	mov    0x8(%ebp),%eax
80103132:	89 04 24             	mov    %eax,(%esp)
80103135:	e8 75 25 00 00       	call   801056af <sleep>
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
8010314a:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80103151:	e8 ab 29 00 00       	call   80105b01 <release>
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
8010315b:	a1 54 3a 11 80       	mov    0x80113a54,%eax
80103160:	8b 55 08             	mov    0x8(%ebp),%edx
80103163:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103165:	a1 54 3a 11 80       	mov    0x80113a54,%eax
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
80103172:	a1 54 3a 11 80       	mov    0x80113a54,%eax
80103177:	8b 55 08             	mov    0x8(%ebp),%edx
8010317a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010317c:	a1 54 3a 11 80       	mov    0x80113a54,%eax
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
8010318f:	a1 84 3b 11 80       	mov    0x80113b84,%eax
80103194:	85 c0                	test   %eax,%eax
80103196:	0f 84 9f 00 00 00    	je     8010323b <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010319c:	c7 05 54 3a 11 80 00 	movl   $0xfec00000,0x80113a54
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
801031cf:	0f b6 05 80 3b 11 80 	movzbl 0x80113b80,%eax
801031d6:	0f b6 c0             	movzbl %al,%eax
801031d9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801031dc:	74 0c                	je     801031ea <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801031de:	c7 04 24 78 93 10 80 	movl   $0x80109378,(%esp)
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
80103244:	a1 84 3b 11 80       	mov    0x80113b84,%eax
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
8010329f:	c7 44 24 04 aa 93 10 	movl   $0x801093aa,0x4(%esp)
801032a6:	80 
801032a7:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801032ae:	e8 cb 27 00 00       	call   80105a7e <initlock>
  kmem.use_lock = 0;
801032b3:	c7 05 94 3a 11 80 00 	movl   $0x0,0x80113a94
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
801032e9:	c7 05 94 3a 11 80 01 	movl   $0x1,0x80113a94
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
80103340:	81 7d 08 7c 6e 11 80 	cmpl   $0x80116e7c,0x8(%ebp)
80103347:	72 12                	jb     8010335b <kfree+0x2d>
80103349:	8b 45 08             	mov    0x8(%ebp),%eax
8010334c:	89 04 24             	mov    %eax,(%esp)
8010334f:	e8 38 ff ff ff       	call   8010328c <v2p>
80103354:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103359:	76 0c                	jbe    80103367 <kfree+0x39>
    panic("kfree");
8010335b:	c7 04 24 af 93 10 80 	movl   $0x801093af,(%esp)
80103362:	e8 d6 d1 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103367:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010336e:	00 
8010336f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103376:	00 
80103377:	8b 45 08             	mov    0x8(%ebp),%eax
8010337a:	89 04 24             	mov    %eax,(%esp)
8010337d:	e8 6c 29 00 00       	call   80105cee <memset>

  if(kmem.use_lock)
80103382:	a1 94 3a 11 80       	mov    0x80113a94,%eax
80103387:	85 c0                	test   %eax,%eax
80103389:	74 0c                	je     80103397 <kfree+0x69>
    acquire(&kmem.lock);
8010338b:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
80103392:	e8 08 27 00 00       	call   80105a9f <acquire>
  r = (struct run*)v;
80103397:	8b 45 08             	mov    0x8(%ebp),%eax
8010339a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010339d:	8b 15 98 3a 11 80    	mov    0x80113a98,%edx
801033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a6:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801033a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ab:	a3 98 3a 11 80       	mov    %eax,0x80113a98
  if(kmem.use_lock)
801033b0:	a1 94 3a 11 80       	mov    0x80113a94,%eax
801033b5:	85 c0                	test   %eax,%eax
801033b7:	74 0c                	je     801033c5 <kfree+0x97>
    release(&kmem.lock);
801033b9:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801033c0:	e8 3c 27 00 00       	call   80105b01 <release>
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
801033cd:	a1 94 3a 11 80       	mov    0x80113a94,%eax
801033d2:	85 c0                	test   %eax,%eax
801033d4:	74 0c                	je     801033e2 <kalloc+0x1b>
    acquire(&kmem.lock);
801033d6:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801033dd:	e8 bd 26 00 00       	call   80105a9f <acquire>
  r = kmem.freelist;
801033e2:	a1 98 3a 11 80       	mov    0x80113a98,%eax
801033e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801033ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801033ee:	74 0a                	je     801033fa <kalloc+0x33>
    kmem.freelist = r->next;
801033f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033f3:	8b 00                	mov    (%eax),%eax
801033f5:	a3 98 3a 11 80       	mov    %eax,0x80113a98
  if(kmem.use_lock)
801033fa:	a1 94 3a 11 80       	mov    0x80113a94,%eax
801033ff:	85 c0                	test   %eax,%eax
80103401:	74 0c                	je     8010340f <kalloc+0x48>
    release(&kmem.lock);
80103403:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
8010340a:	e8 f2 26 00 00       	call   80105b01 <release>
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
80103485:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
8010348a:	83 c8 40             	or     $0x40,%eax
8010348d:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
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
801034a8:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
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
801034d7:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
801034dc:	21 d0                	and    %edx,%eax
801034de:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
801034e3:	b8 00 00 00 00       	mov    $0x0,%eax
801034e8:	e9 a0 00 00 00       	jmp    8010358d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
801034ed:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
801034f2:	83 e0 40             	and    $0x40,%eax
801034f5:	85 c0                	test   %eax,%eax
801034f7:	74 14                	je     8010350d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801034f9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103500:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103505:	83 e0 bf             	and    $0xffffffbf,%eax
80103508:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
8010350d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103510:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103515:	0f b6 00             	movzbl (%eax),%eax
80103518:	0f b6 d0             	movzbl %al,%edx
8010351b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103520:	09 d0                	or     %edx,%eax
80103522:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80103527:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010352a:	05 20 a1 10 80       	add    $0x8010a120,%eax
8010352f:	0f b6 00             	movzbl (%eax),%eax
80103532:	0f b6 d0             	movzbl %al,%edx
80103535:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
8010353a:	31 d0                	xor    %edx,%eax
8010353c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80103541:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103546:	83 e0 03             	and    $0x3,%eax
80103549:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80103550:	03 45 fc             	add    -0x4(%ebp),%eax
80103553:	0f b6 00             	movzbl (%eax),%eax
80103556:	0f b6 c0             	movzbl %al,%eax
80103559:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010355c:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
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
80103604:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
80103609:	8b 55 08             	mov    0x8(%ebp),%edx
8010360c:	c1 e2 02             	shl    $0x2,%edx
8010360f:	01 c2                	add    %eax,%edx
80103611:	8b 45 0c             	mov    0xc(%ebp),%eax
80103614:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103616:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
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
80103628:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
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
801036ad:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
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
80103751:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
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
80103793:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80103798:	85 c0                	test   %eax,%eax
8010379a:	0f 94 c2             	sete   %dl
8010379d:	83 c0 01             	add    $0x1,%eax
801037a0:	a3 60 c6 10 80       	mov    %eax,0x8010c660
801037a5:	84 d2                	test   %dl,%dl
801037a7:	74 13                	je     801037bc <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801037a9:	8b 45 04             	mov    0x4(%ebp),%eax
801037ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b0:	c7 04 24 b8 93 10 80 	movl   $0x801093b8,(%esp)
801037b7:	e8 e5 cb ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801037bc:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
801037c1:	85 c0                	test   %eax,%eax
801037c3:	74 0f                	je     801037d4 <cpunum+0x55>
    return lapic[ID]>>24;
801037c5:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
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
801037e1:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
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
80103a14:	e8 4c 23 00 00       	call   80105d65 <memcmp>
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
80103b16:	c7 44 24 04 e4 93 10 	movl   $0x801093e4,0x4(%esp)
80103b1d:	80 
80103b1e:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103b25:	e8 54 1f 00 00       	call   80105a7e <initlock>
  readsb(dev, &sb);
80103b2a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b31:	8b 45 08             	mov    0x8(%ebp),%eax
80103b34:	89 04 24             	mov    %eax,(%esp)
80103b37:	e8 dc df ff ff       	call   80101b18 <readsb>
  log.start = sb.logstart;
80103b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b3f:	a3 d4 3a 11 80       	mov    %eax,0x80113ad4
  log.size = sb.nlog;
80103b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b47:	a3 d8 3a 11 80       	mov    %eax,0x80113ad8
  log.dev = dev;
80103b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b4f:	a3 e4 3a 11 80       	mov    %eax,0x80113ae4
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
80103b6d:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103b72:	03 45 f4             	add    -0xc(%ebp),%eax
80103b75:	83 c0 01             	add    $0x1,%eax
80103b78:	89 c2                	mov    %eax,%edx
80103b7a:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b83:	89 04 24             	mov    %eax,(%esp)
80103b86:	e8 1b c6 ff ff       	call   801001a6 <bread>
80103b8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b91:	83 c0 10             	add    $0x10,%eax
80103b94:	8b 04 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%eax
80103b9b:	89 c2                	mov    %eax,%edx
80103b9d:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
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
80103bcc:	e8 f0 21 00 00       	call   80105dc1 <memmove>
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
80103bf6:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
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
80103c0c:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103c11:	89 c2                	mov    %eax,%edx
80103c13:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
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
80103c35:	a3 e8 3a 11 80       	mov    %eax,0x80113ae8
  for (i = 0; i < log.lh.n; i++) {
80103c3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c41:	eb 1b                	jmp    80103c5e <read_head+0x58>
    log.lh.block[i] = lh->block[i];
80103c43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c49:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c50:	83 c2 10             	add    $0x10,%edx
80103c53:	89 04 95 ac 3a 11 80 	mov    %eax,-0x7feec554(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103c5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c5e:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
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
80103c7b:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103c80:	89 c2                	mov    %eax,%edx
80103c82:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
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
80103c9f:	8b 15 e8 3a 11 80    	mov    0x80113ae8,%edx
80103ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ca8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103caa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103cb1:	eb 1b                	jmp    80103cce <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	83 c0 10             	add    $0x10,%eax
80103cb9:	8b 0c 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%ecx
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
80103cce:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
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
80103d00:	c7 05 e8 3a 11 80 00 	movl   $0x0,0x80113ae8
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
80103d17:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d1e:	e8 7c 1d 00 00       	call   80105a9f <acquire>
  while(1){
    if(log.committing){
80103d23:	a1 e0 3a 11 80       	mov    0x80113ae0,%eax
80103d28:	85 c0                	test   %eax,%eax
80103d2a:	74 16                	je     80103d42 <begin_op+0x31>
      sleep(&log, &log.lock);
80103d2c:	c7 44 24 04 a0 3a 11 	movl   $0x80113aa0,0x4(%esp)
80103d33:	80 
80103d34:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d3b:	e8 6f 19 00 00       	call   801056af <sleep>
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
80103d42:	8b 0d e8 3a 11 80    	mov    0x80113ae8,%ecx
80103d48:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
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
80103d60:	c7 44 24 04 a0 3a 11 	movl   $0x80113aa0,0x4(%esp)
80103d67:	80 
80103d68:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d6f:	e8 3b 19 00 00       	call   801056af <sleep>
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
80103d76:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103d7b:	83 c0 01             	add    $0x1,%eax
80103d7e:	a3 dc 3a 11 80       	mov    %eax,0x80113adc
      release(&log.lock);
80103d83:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d8a:	e8 72 1d 00 00       	call   80105b01 <release>
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
80103d9f:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103da6:	e8 f4 1c 00 00       	call   80105a9f <acquire>
  log.outstanding -= 1;
80103dab:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103db0:	83 e8 01             	sub    $0x1,%eax
80103db3:	a3 dc 3a 11 80       	mov    %eax,0x80113adc
  if(log.committing)
80103db8:	a1 e0 3a 11 80       	mov    0x80113ae0,%eax
80103dbd:	85 c0                	test   %eax,%eax
80103dbf:	74 0c                	je     80103dcd <end_op+0x3b>
    panic("log.committing");
80103dc1:	c7 04 24 e8 93 10 80 	movl   $0x801093e8,(%esp)
80103dc8:	e8 70 c7 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
80103dcd:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	75 13                	jne    80103de9 <end_op+0x57>
    do_commit = 1;
80103dd6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103ddd:	c7 05 e0 3a 11 80 01 	movl   $0x1,0x80113ae0
80103de4:	00 00 00 
80103de7:	eb 0c                	jmp    80103df5 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103de9:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103df0:	e8 96 19 00 00       	call   8010578b <wakeup>
  }
  release(&log.lock);
80103df5:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103dfc:	e8 00 1d 00 00       	call   80105b01 <release>

  if(do_commit){
80103e01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e05:	74 33                	je     80103e3a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103e07:	e8 db 00 00 00       	call   80103ee7 <commit>
    acquire(&log.lock);
80103e0c:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e13:	e8 87 1c 00 00       	call   80105a9f <acquire>
    log.committing = 0;
80103e18:	c7 05 e0 3a 11 80 00 	movl   $0x0,0x80113ae0
80103e1f:	00 00 00 
    wakeup(&log);
80103e22:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e29:	e8 5d 19 00 00       	call   8010578b <wakeup>
    release(&log.lock);
80103e2e:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e35:	e8 c7 1c 00 00       	call   80105b01 <release>
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
80103e4e:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103e53:	03 45 f4             	add    -0xc(%ebp),%eax
80103e56:	83 c0 01             	add    $0x1,%eax
80103e59:	89 c2                	mov    %eax,%edx
80103e5b:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103e60:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e64:	89 04 24             	mov    %eax,(%esp)
80103e67:	e8 3a c3 ff ff       	call   801001a6 <bread>
80103e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e72:	83 c0 10             	add    $0x10,%eax
80103e75:	8b 04 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%eax
80103e7c:	89 c2                	mov    %eax,%edx
80103e7e:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
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
80103ead:	e8 0f 1f 00 00       	call   80105dc1 <memmove>
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
80103ed7:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
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
80103eed:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103ef2:	85 c0                	test   %eax,%eax
80103ef4:	7e 1e                	jle    80103f14 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103ef6:	e8 41 ff ff ff       	call   80103e3c <write_log>
    write_head();    // Write header to disk -- the real commit
80103efb:	e8 75 fd ff ff       	call   80103c75 <write_head>
    install_trans(); // Now install writes to home locations
80103f00:	e8 56 fc ff ff       	call   80103b5b <install_trans>
    log.lh.n = 0; 
80103f05:	c7 05 e8 3a 11 80 00 	movl   $0x0,0x80113ae8
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
80103f1c:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103f21:	83 f8 1d             	cmp    $0x1d,%eax
80103f24:	7f 12                	jg     80103f38 <log_write+0x22>
80103f26:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103f2b:	8b 15 d8 3a 11 80    	mov    0x80113ad8,%edx
80103f31:	83 ea 01             	sub    $0x1,%edx
80103f34:	39 d0                	cmp    %edx,%eax
80103f36:	7c 0c                	jl     80103f44 <log_write+0x2e>
    panic("too big a transaction");
80103f38:	c7 04 24 f7 93 10 80 	movl   $0x801093f7,(%esp)
80103f3f:	e8 f9 c5 ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103f44:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103f49:	85 c0                	test   %eax,%eax
80103f4b:	7f 0c                	jg     80103f59 <log_write+0x43>
    panic("log_write outside of trans");
80103f4d:	c7 04 24 0d 94 10 80 	movl   $0x8010940d,(%esp)
80103f54:	e8 e4 c5 ff ff       	call   8010053d <panic>

  acquire(&log.lock);
80103f59:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103f60:	e8 3a 1b 00 00       	call   80105a9f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103f65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f6c:	eb 1d                	jmp    80103f8b <log_write+0x75>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f71:	83 c0 10             	add    $0x10,%eax
80103f74:	8b 04 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%eax
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
80103f8b:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
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
80103fa4:	89 04 95 ac 3a 11 80 	mov    %eax,-0x7feec554(,%edx,4)
  if (i == log.lh.n)
80103fab:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103fb0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103fb3:	75 0d                	jne    80103fc2 <log_write+0xac>
    log.lh.n++;
80103fb5:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103fba:	83 c0 01             	add    $0x1,%eax
80103fbd:	a3 e8 3a 11 80       	mov    %eax,0x80113ae8
  b->flags |= B_DIRTY; // prevent eviction
80103fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc5:	8b 00                	mov    (%eax),%eax
80103fc7:	89 c2                	mov    %eax,%edx
80103fc9:	83 ca 04             	or     $0x4,%edx
80103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcf:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103fd1:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103fd8:	e8 24 1b 00 00       	call   80105b01 <release>
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
80104030:	c7 04 24 7c 6e 11 80 	movl   $0x80116e7c,(%esp)
80104037:	e8 5d f2 ff ff       	call   80103299 <kinit1>
  kvmalloc();      // kernel page table
8010403c:	e8 85 49 00 00       	call   801089c6 <kvmalloc>
  mpinit();        // collect info about this machine
80104041:	e8 4f 04 00 00       	call   80104495 <mpinit>
  lapicinit();
80104046:	e8 d7 f5 ff ff       	call   80103622 <lapicinit>
  seginit();       // set up segments
8010404b:	e8 19 43 00 00       	call   80108369 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80104050:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104056:	0f b6 00             	movzbl (%eax),%eax
80104059:	0f b6 c0             	movzbl %al,%eax
8010405c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104060:	c7 04 24 28 94 10 80 	movl   $0x80109428,(%esp)
80104067:	e8 35 c3 ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010406c:	e8 89 06 00 00       	call   801046fa <picinit>
  ioapicinit();    // another interrupt controller
80104071:	e8 13 f1 ff ff       	call   80103189 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104076:	e8 31 d2 ff ff       	call   801012ac <consoleinit>
  uartinit();      // serial port
8010407b:	e8 34 36 00 00       	call   801076b4 <uartinit>
  pinit();         // process table
80104080:	e8 8a 0b 00 00       	call   80104c0f <pinit>
  tvinit();        // trap vectors
80104085:	e8 a5 31 00 00       	call   8010722f <tvinit>
  binit();         // buffer cache
8010408a:	e8 a5 bf ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010408f:	e8 98 d6 ff ff       	call   8010172c <fileinit>
  ideinit();       // disk
80104094:	e8 21 ed ff ff       	call   80102dba <ideinit>
  if(!ismp)
80104099:	a1 84 3b 11 80       	mov    0x80113b84,%eax
8010409e:	85 c0                	test   %eax,%eax
801040a0:	75 05                	jne    801040a7 <main+0x88>
    timerinit();   // uniprocessor timer
801040a2:	e8 cb 30 00 00       	call   80107172 <timerinit>
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
801040d0:	e8 08 49 00 00       	call   801089dd <switchkvm>
  seginit();
801040d5:	e8 8f 42 00 00       	call   80108369 <seginit>
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
801040fa:	c7 04 24 3f 94 10 80 	movl   $0x8010943f,(%esp)
80104101:	e8 9b c2 ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80104106:	e8 98 32 00 00       	call   801073a3 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010410b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104111:	05 a8 00 00 00       	add    $0xa8,%eax
80104116:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010411d:	00 
8010411e:	89 04 24             	mov    %eax,(%esp)
80104121:	e8 d4 fe ff ff       	call   80103ffa <xchg>
  scheduler();     // start running processes
80104126:	e8 56 14 00 00       	call   80105581 <scheduler>

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
8010414a:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80104151:	80 
80104152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104155:	89 04 24             	mov    %eax,(%esp)
80104158:	e8 64 1c 00 00       	call   80105dc1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010415d:	c7 45 f4 a0 3b 11 80 	movl   $0x80113ba0,-0xc(%ebp)
80104164:	e9 86 00 00 00       	jmp    801041ef <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80104169:	e8 11 f6 ff ff       	call   8010377f <cpunum>
8010416e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104174:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
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
801041ef:	a1 80 41 11 80       	mov    0x80114180,%eax
801041f4:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041fa:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
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
80104268:	a1 64 c6 10 80       	mov    0x8010c664,%eax
8010426d:	89 c2                	mov    %eax,%edx
8010426f:	b8 a0 3b 11 80       	mov    $0x80113ba0,%eax
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
801042e8:	c7 44 24 04 50 94 10 	movl   $0x80109450,0x4(%esp)
801042ef:	80 
801042f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f3:	89 04 24             	mov    %eax,(%esp)
801042f6:	e8 6a 1a 00 00       	call   80105d65 <memcmp>
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
80104429:	c7 44 24 04 55 94 10 	movl   $0x80109455,0x4(%esp)
80104430:	80 
80104431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104434:	89 04 24             	mov    %eax,(%esp)
80104437:	e8 29 19 00 00       	call   80105d65 <memcmp>
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
8010449b:	c7 05 64 c6 10 80 a0 	movl   $0x80113ba0,0x8010c664
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
801044bd:	c7 05 84 3b 11 80 01 	movl   $0x1,0x80113b84
801044c4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801044c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ca:	8b 40 24             	mov    0x24(%eax),%eax
801044cd:	a3 9c 3a 11 80       	mov    %eax,0x80113a9c
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
80104502:	8b 04 85 98 94 10 80 	mov    -0x7fef6b68(,%eax,4),%eax
80104509:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010450b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104511:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104514:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104518:	0f b6 d0             	movzbl %al,%edx
8010451b:	a1 80 41 11 80       	mov    0x80114180,%eax
80104520:	39 c2                	cmp    %eax,%edx
80104522:	74 2d                	je     80104551 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104524:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104527:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010452b:	0f b6 d0             	movzbl %al,%edx
8010452e:	a1 80 41 11 80       	mov    0x80114180,%eax
80104533:	89 54 24 08          	mov    %edx,0x8(%esp)
80104537:	89 44 24 04          	mov    %eax,0x4(%esp)
8010453b:	c7 04 24 5a 94 10 80 	movl   $0x8010945a,(%esp)
80104542:	e8 5a be ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80104547:	c7 05 84 3b 11 80 00 	movl   $0x0,0x80113b84
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
80104562:	a1 80 41 11 80       	mov    0x80114180,%eax
80104567:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010456d:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
80104572:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80104577:	8b 15 80 41 11 80    	mov    0x80114180,%edx
8010457d:	a1 80 41 11 80       	mov    0x80114180,%eax
80104582:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80104588:	81 c2 a0 3b 11 80    	add    $0x80113ba0,%edx
8010458e:	88 02                	mov    %al,(%edx)
      ncpu++;
80104590:	a1 80 41 11 80       	mov    0x80114180,%eax
80104595:	83 c0 01             	add    $0x1,%eax
80104598:	a3 80 41 11 80       	mov    %eax,0x80114180
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
801045b0:	a2 80 3b 11 80       	mov    %al,0x80113b80
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
801045ce:	c7 04 24 78 94 10 80 	movl   $0x80109478,(%esp)
801045d5:	e8 c7 bd ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801045da:	c7 05 84 3b 11 80 00 	movl   $0x0,0x80113b84
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
801045f0:	a1 84 3b 11 80       	mov    0x80113b84,%eax
801045f5:	85 c0                	test   %eax,%eax
801045f7:	75 1d                	jne    80104616 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801045f9:	c7 05 80 41 11 80 01 	movl   $0x1,0x80114180
80104600:	00 00 00 
    lapic = 0;
80104603:	c7 05 9c 3a 11 80 00 	movl   $0x0,0x80113a9c
8010460a:	00 00 00 
    ioapicid = 0;
8010460d:	c6 05 80 3b 11 80 00 	movb   $0x0,0x80113b80
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
801048d3:	c7 44 24 04 ac 94 10 	movl   $0x801094ac,0x4(%esp)
801048da:	80 
801048db:	89 04 24             	mov    %eax,(%esp)
801048de:	e8 9b 11 00 00       	call   80105a7e <initlock>
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
8010498b:	e8 0f 11 00 00       	call   80105a9f <acquire>
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
801049ae:	e8 d8 0d 00 00       	call   8010578b <wakeup>
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
801049cd:	e8 b9 0d 00 00       	call   8010578b <wakeup>
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
801049f2:	e8 0a 11 00 00       	call   80105b01 <release>
    kfree((char*)p);
801049f7:	8b 45 08             	mov    0x8(%ebp),%eax
801049fa:	89 04 24             	mov    %eax,(%esp)
801049fd:	e8 2c e9 ff ff       	call   8010332e <kfree>
80104a02:	eb 0b                	jmp    80104a0f <pipeclose+0x90>
  } else
    release(&p->lock);
80104a04:	8b 45 08             	mov    0x8(%ebp),%eax
80104a07:	89 04 24             	mov    %eax,(%esp)
80104a0a:	e8 f2 10 00 00       	call   80105b01 <release>
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
80104a1e:	e8 7c 10 00 00       	call   80105a9f <acquire>
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
80104a4f:	e8 ad 10 00 00       	call   80105b01 <release>
        return -1;
80104a54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a59:	e9 9d 00 00 00       	jmp    80104afb <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a61:	05 34 02 00 00       	add    $0x234,%eax
80104a66:	89 04 24             	mov    %eax,(%esp)
80104a69:	e8 1d 0d 00 00       	call   8010578b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a71:	8b 55 08             	mov    0x8(%ebp),%edx
80104a74:	81 c2 38 02 00 00    	add    $0x238,%edx
80104a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a7e:	89 14 24             	mov    %edx,(%esp)
80104a81:	e8 29 0c 00 00       	call   801056af <sleep>
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
80104ae8:	e8 9e 0c 00 00       	call   8010578b <wakeup>
  release(&p->lock);
80104aed:	8b 45 08             	mov    0x8(%ebp),%eax
80104af0:	89 04 24             	mov    %eax,(%esp)
80104af3:	e8 09 10 00 00       	call   80105b01 <release>
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
80104b0e:	e8 8c 0f 00 00       	call   80105a9f <acquire>
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
80104b28:	e8 d4 0f 00 00       	call   80105b01 <release>
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
80104b4a:	e8 60 0b 00 00       	call   801056af <sleep>
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
80104bda:	e8 ac 0b 00 00       	call   8010578b <wakeup>
  release(&p->lock);
80104bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104be2:	89 04 24             	mov    %eax,(%esp)
80104be5:	e8 17 0f 00 00       	call   80105b01 <release>
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
80104c15:	c7 44 24 04 b1 94 10 	movl   $0x801094b1,0x4(%esp)
80104c1c:	80 
80104c1d:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104c24:	e8 55 0e 00 00       	call   80105a7e <initlock>
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
80104c31:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104c38:	e8 62 0e 00 00       	call   80105a9f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c3d:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
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
80104c57:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
80104c5e:	72 e6                	jb     80104c46 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104c60:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104c67:	e8 95 0e 00 00       	call   80105b01 <release>
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
80104ca1:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104ca8:	e8 54 0e 00 00       	call   80105b01 <release>

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
80104cf2:	ba e4 71 10 80       	mov    $0x801071e4,%edx
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
80104d22:	e8 c7 0f 00 00       	call   80105cee <memset>
  p->context->eip = (uint)forkret;
80104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d2d:	ba 70 56 10 80       	mov    $0x80105670,%edx
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
80104d4b:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
80104d50:	e8 b4 3b 00 00       	call   80108909 <setupkvm>
80104d55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d58:	89 42 04             	mov    %eax,0x4(%edx)
80104d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5e:	8b 40 04             	mov    0x4(%eax),%eax
80104d61:	85 c0                	test   %eax,%eax
80104d63:	75 0c                	jne    80104d71 <userinit+0x37>
    panic("userinit: out of memory?");
80104d65:	c7 04 24 b8 94 10 80 	movl   $0x801094b8,(%esp)
80104d6c:	e8 cc b7 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104d71:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	8b 40 04             	mov    0x4(%eax),%eax
80104d7c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d80:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
80104d87:	80 
80104d88:	89 04 24             	mov    %eax,(%esp)
80104d8b:	e8 d1 3d 00 00       	call   80108b61 <inituvm>
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
80104db2:	e8 37 0f 00 00       	call   80105cee <memset>
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
80104e2c:	c7 44 24 04 d1 94 10 	movl   $0x801094d1,0x4(%esp)
80104e33:	80 
80104e34:	89 04 24             	mov    %eax,(%esp)
80104e37:	e8 e2 10 00 00       	call   80105f1e <safestrcpy>
  p->cwd = namei("/");
80104e3c:	c7 04 24 da 94 10 80 	movl   $0x801094da,(%esp)
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
80104e90:	e8 46 3e 00 00       	call   80108cdb <allocuvm>
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
80104eca:	e8 e6 3e 00 00       	call   80108db5 <deallocuvm>
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
80104ef3:	e8 02 3b 00 00       	call   801089fa <switchuvm>
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
80104f1b:	e9 8e 01 00 00       	jmp    801050ae <fork+0x1af>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f26:	8b 10                	mov    (%eax),%edx
80104f28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f2e:	8b 40 04             	mov    0x4(%eax),%eax
80104f31:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f35:	89 04 24             	mov    %eax,(%esp)
80104f38:	e8 08 40 00 00       	call   80108f45 <copyuvm>
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
80104f74:	e9 35 01 00 00       	jmp    801050ae <fork+0x1af>
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
  np->retime=0;
80104f93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f96:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104f9d:	00 00 00 
  np->rutime=0;
80104fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa3:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104faa:	00 00 00 
  np->stime=0;
80104fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fb0:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104fb7:	00 00 00 
  np->priority=proc->priority;
80104fba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc0:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fc9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
  *np->tf = *proc->tf;
80104fcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd2:	8b 50 18             	mov    0x18(%eax),%edx
80104fd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fdb:	8b 40 18             	mov    0x18(%eax),%eax
80104fde:	89 c3                	mov    %eax,%ebx
80104fe0:	b8 13 00 00 00       	mov    $0x13,%eax
80104fe5:	89 d7                	mov    %edx,%edi
80104fe7:	89 de                	mov    %ebx,%esi
80104fe9:	89 c1                	mov    %eax,%ecx
80104feb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104fed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ff0:	8b 40 18             	mov    0x18(%eax),%eax
80104ff3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104ffa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105001:	eb 3d                	jmp    80105040 <fork+0x141>
    if(proc->ofile[i])
80105003:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105009:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010500c:	83 c2 08             	add    $0x8,%edx
8010500f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105013:	85 c0                	test   %eax,%eax
80105015:	74 25                	je     8010503c <fork+0x13d>
      np->ofile[i] = filedup(proc->ofile[i]);
80105017:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010501d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105020:	83 c2 08             	add    $0x8,%edx
80105023:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105027:	89 04 24             	mov    %eax,(%esp)
8010502a:	e8 79 c7 ff ff       	call   801017a8 <filedup>
8010502f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105032:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105035:	83 c1 08             	add    $0x8,%ecx
80105038:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010503c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105040:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105044:	7e bd                	jle    80105003 <fork+0x104>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105046:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010504c:	8b 40 68             	mov    0x68(%eax),%eax
8010504f:	89 04 24             	mov    %eax,(%esp)
80105052:	e8 6c d0 ff ff       	call   801020c3 <idup>
80105057:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010505a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010505d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105063:	8d 50 6c             	lea    0x6c(%eax),%edx
80105066:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105069:	83 c0 6c             	add    $0x6c,%eax
8010506c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105073:	00 
80105074:	89 54 24 04          	mov    %edx,0x4(%esp)
80105078:	89 04 24             	mov    %eax,(%esp)
8010507b:	e8 9e 0e 00 00       	call   80105f1e <safestrcpy>

  pid = np->pid;
80105080:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105083:	8b 40 10             	mov    0x10(%eax),%eax
80105086:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80105089:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105090:	e8 0a 0a 00 00       	call   80105a9f <acquire>
  np->state = RUNNABLE;
80105095:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105098:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
8010509f:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801050a6:	e8 56 0a 00 00       	call   80105b01 <release>

  return pid;
801050ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801050ae:	83 c4 2c             	add    $0x2c,%esp
801050b1:	5b                   	pop    %ebx
801050b2:	5e                   	pop    %esi
801050b3:	5f                   	pop    %edi
801050b4:	5d                   	pop    %ebp
801050b5:	c3                   	ret    

801050b6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801050b6:	55                   	push   %ebp
801050b7:	89 e5                	mov    %esp,%ebp
801050b9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801050bc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050c3:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801050c8:	39 c2                	cmp    %eax,%edx
801050ca:	75 0c                	jne    801050d8 <exit+0x22>
    panic("init exiting");
801050cc:	c7 04 24 dc 94 10 80 	movl   $0x801094dc,(%esp)
801050d3:	e8 65 b4 ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801050df:	eb 44                	jmp    80105125 <exit+0x6f>
    if(proc->ofile[fd]){
801050e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050ea:	83 c2 08             	add    $0x8,%edx
801050ed:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050f1:	85 c0                	test   %eax,%eax
801050f3:	74 2c                	je     80105121 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801050f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050fe:	83 c2 08             	add    $0x8,%edx
80105101:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105105:	89 04 24             	mov    %eax,(%esp)
80105108:	e8 e3 c6 ff ff       	call   801017f0 <fileclose>
      proc->ofile[fd] = 0;
8010510d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105113:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105116:	83 c2 08             	add    $0x8,%edx
80105119:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105120:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105121:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105125:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105129:	7e b6                	jle    801050e1 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010512b:	e8 e1 eb ff ff       	call   80103d11 <begin_op>
  iput(proc->cwd);
80105130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105136:	8b 40 68             	mov    0x68(%eax),%eax
80105139:	89 04 24             	mov    %eax,(%esp)
8010513c:	e8 6d d1 ff ff       	call   801022ae <iput>
  end_op();
80105141:	e8 4c ec ff ff       	call   80103d92 <end_op>
  proc->cwd = 0;
80105146:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010514c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105153:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010515a:	e8 40 09 00 00       	call   80105a9f <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010515f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105165:	8b 40 14             	mov    0x14(%eax),%eax
80105168:	89 04 24             	mov    %eax,(%esp)
8010516b:	e8 da 05 00 00       	call   8010574a <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105170:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
80105177:	eb 3b                	jmp    801051b4 <exit+0xfe>
    if(p->parent == proc){
80105179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517c:	8b 50 14             	mov    0x14(%eax),%edx
8010517f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105185:	39 c2                	cmp    %eax,%edx
80105187:	75 24                	jne    801051ad <exit+0xf7>
      p->parent = initproc;
80105189:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
8010518f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105192:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105198:	8b 40 0c             	mov    0xc(%eax),%eax
8010519b:	83 f8 05             	cmp    $0x5,%eax
8010519e:	75 0d                	jne    801051ad <exit+0xf7>
        wakeup1(initproc);
801051a0:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801051a5:	89 04 24             	mov    %eax,(%esp)
801051a8:	e8 9d 05 00 00       	call   8010574a <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051ad:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801051b4:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801051bb:	72 bc                	jb     80105179 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801051bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801051ca:	e8 bd 03 00 00       	call   8010558c <sched>
  panic("zombie exit");
801051cf:	c7 04 24 e9 94 10 80 	movl   $0x801094e9,(%esp)
801051d6:	e8 62 b3 ff ff       	call   8010053d <panic>

801051db <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801051db:	55                   	push   %ebp
801051dc:	89 e5                	mov    %esp,%ebp
801051de:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801051e1:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801051e8:	e8 b2 08 00 00       	call   80105a9f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801051ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051f4:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801051fb:	e9 9d 00 00 00       	jmp    8010529d <wait+0xc2>
      if(p->parent != proc)
80105200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105203:	8b 50 14             	mov    0x14(%eax),%edx
80105206:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010520c:	39 c2                	cmp    %eax,%edx
8010520e:	0f 85 81 00 00 00    	jne    80105295 <wait+0xba>
        continue;
      havekids = 1;
80105214:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010521b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521e:	8b 40 0c             	mov    0xc(%eax),%eax
80105221:	83 f8 05             	cmp    $0x5,%eax
80105224:	75 70                	jne    80105296 <wait+0xbb>
        // Found one.
        pid = p->pid;
80105226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105229:	8b 40 10             	mov    0x10(%eax),%eax
8010522c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010522f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105232:	8b 40 08             	mov    0x8(%eax),%eax
80105235:	89 04 24             	mov    %eax,(%esp)
80105238:	e8 f1 e0 ff ff       	call   8010332e <kfree>
        p->kstack = 0;
8010523d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105240:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524a:	8b 40 04             	mov    0x4(%eax),%eax
8010524d:	89 04 24             	mov    %eax,(%esp)
80105250:	e8 1c 3c 00 00       	call   80108e71 <freevm>
        p->state = UNUSED;
80105255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105258:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010525f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105262:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105276:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105284:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010528b:	e8 71 08 00 00       	call   80105b01 <release>
        return pid;
80105290:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105293:	eb 56                	jmp    801052eb <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105295:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105296:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010529d:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801052a4:	0f 82 56 ff ff ff    	jb     80105200 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801052aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052ae:	74 0d                	je     801052bd <wait+0xe2>
801052b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052b6:	8b 40 24             	mov    0x24(%eax),%eax
801052b9:	85 c0                	test   %eax,%eax
801052bb:	74 13                	je     801052d0 <wait+0xf5>
      release(&ptable.lock);
801052bd:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801052c4:	e8 38 08 00 00       	call   80105b01 <release>
      return -1;
801052c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ce:	eb 1b                	jmp    801052eb <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801052d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d6:	c7 44 24 04 a0 41 11 	movl   $0x801141a0,0x4(%esp)
801052dd:	80 
801052de:	89 04 24             	mov    %eax,(%esp)
801052e1:	e8 c9 03 00 00       	call   801056af <sleep>
  }
801052e6:	e9 02 ff ff ff       	jmp    801051ed <wait+0x12>
}
801052eb:	c9                   	leave  
801052ec:	c3                   	ret    

801052ed <scheduler_def>:
//  - eventually that process transfers control
//      via swtch back to the scheduler.


void
scheduler_def(void) {
801052ed:	55                   	push   %ebp
801052ee:	89 e5                	mov    %esp,%ebp
801052f0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801052f3:	e8 11 f9 ff ff       	call   80104c09 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801052f8:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801052ff:	e8 9b 07 00 00       	call   80105a9f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105304:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
8010530b:	eb 62                	jmp    8010536f <scheduler_def+0x82>
      if(p->state != RUNNABLE)
8010530d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105310:	8b 40 0c             	mov    0xc(%eax),%eax
80105313:	83 f8 03             	cmp    $0x3,%eax
80105316:	75 4f                	jne    80105367 <scheduler_def+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010531b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105324:	89 04 24             	mov    %eax,(%esp)
80105327:	e8 ce 36 00 00       	call   801089fa <switchuvm>
      p->state = RUNNING;
8010532c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105336:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010533f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105346:	83 c2 04             	add    $0x4,%edx
80105349:	89 44 24 04          	mov    %eax,0x4(%esp)
8010534d:	89 14 24             	mov    %edx,(%esp)
80105350:	e8 3f 0c 00 00       	call   80105f94 <swtch>
      switchkvm();
80105355:	e8 83 36 00 00       	call   801089dd <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010535a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105361:	00 00 00 00 
80105365:	eb 01                	jmp    80105368 <scheduler_def+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105367:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105368:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010536f:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
80105376:	72 95                	jb     8010530d <scheduler_def+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105378:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010537f:	e8 7d 07 00 00       	call   80105b01 <release>

  }
80105384:	e9 6a ff ff ff       	jmp    801052f3 <scheduler_def+0x6>

80105389 <scheduler_fcfs>:
}


void
scheduler_fcfs(void) {
80105389:	55                   	push   %ebp
8010538a:	89 e5                	mov    %esp,%ebp
8010538c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p,*chosenProc;
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010538f:	e8 75 f8 ff ff       	call   80104c09 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105394:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010539b:	e8 ff 06 00 00       	call   80105a9f <acquire>
    chosenProc=0;
801053a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    //Set chosenProc to the runnable proc with the minimum creation time.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053a7:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801053ae:	eb 2e                	jmp    801053de <scheduler_fcfs+0x55>
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime <= chosenProc->ctime)))
801053b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b3:	8b 40 0c             	mov    0xc(%eax),%eax
801053b6:	83 f8 03             	cmp    $0x3,%eax
801053b9:	75 1c                	jne    801053d7 <scheduler_fcfs+0x4e>
801053bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053bf:	74 10                	je     801053d1 <scheduler_fcfs+0x48>
801053c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c4:	8b 50 7c             	mov    0x7c(%eax),%edx
801053c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ca:	8b 40 7c             	mov    0x7c(%eax),%eax
801053cd:	39 c2                	cmp    %eax,%edx
801053cf:	77 06                	ja     801053d7 <scheduler_fcfs+0x4e>
        chosenProc=p;
801053d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    chosenProc=0;

    //Set chosenProc to the runnable proc with the minimum creation time.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053d7:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801053de:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801053e5:	72 c9                	jb     801053b0 <scheduler_fcfs+0x27>
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime <= chosenProc->ctime)))
        chosenProc=p;
    }

    if (!chosenProc) {
801053e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053eb:	75 0f                	jne    801053fc <scheduler_fcfs+0x73>
     release(&ptable.lock);
801053ed:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801053f4:	e8 08 07 00 00       	call   80105b01 <release>
     continue;
801053f9:	90                   	nop

    // Process is done running for now.
    // It should have changed its p->state before coming back.
    proc = 0;
    release(&ptable.lock);
  }
801053fa:	eb 93                	jmp    8010538f <scheduler_fcfs+0x6>
   }

    // Switch to chosen process.  It is the process's job
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    proc=chosenProc;
801053fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ff:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4

    //run process untill its no longer need cpu time
    while(proc->state==RUNNABLE) {
80105405:	eb 39                	jmp    80105440 <scheduler_fcfs+0xb7>
      switchuvm(chosenProc);
80105407:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540a:	89 04 24             	mov    %eax,(%esp)
8010540d:	e8 e8 35 00 00       	call   801089fa <switchuvm>
      chosenProc->state = RUNNING;
80105412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105415:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
8010541c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105422:	8b 40 1c             	mov    0x1c(%eax),%eax
80105425:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010542c:	83 c2 04             	add    $0x4,%edx
8010542f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105433:	89 14 24             	mov    %edx,(%esp)
80105436:	e8 59 0b 00 00       	call   80105f94 <swtch>
      switchkvm();
8010543b:	e8 9d 35 00 00       	call   801089dd <switchkvm>
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    proc=chosenProc;

    //run process untill its no longer need cpu time
    while(proc->state==RUNNABLE) {
80105440:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105446:	8b 40 0c             	mov    0xc(%eax),%eax
80105449:	83 f8 03             	cmp    $0x3,%eax
8010544c:	74 b9                	je     80105407 <scheduler_fcfs+0x7e>
      switchkvm();
   }

    // Process is done running for now.
    // It should have changed its p->state before coming back.
    proc = 0;
8010544e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105455:	00 00 00 00 
    release(&ptable.lock);
80105459:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105460:	e8 9c 06 00 00       	call   80105b01 <release>
  }
80105465:	e9 25 ff ff ff       	jmp    8010538f <scheduler_fcfs+0x6>

8010546a <scheduler_sml>:
}

void
scheduler_sml(void) {
8010546a:	55                   	push   %ebp
8010546b:	89 e5                	mov    %esp,%ebp
8010546d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p,*chosenProc=0;
80105470:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  uint priority;
  int beenInside=0;
80105477:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010547e:	e8 86 f7 ff ff       	call   80104c09 <sti>
    acquire(&ptable.lock);
80105483:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010548a:	e8 10 06 00 00       	call   80105a9f <acquire>
    //we start at MAX_PRIORITY, if we didnt find a process then we decrease the priority. if we found one, we resets it to max priority.
    if (beenInside && !chosenProc && priority>MIN_PRIORITY)
8010548f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80105493:	74 12                	je     801054a7 <scheduler_sml+0x3d>
80105495:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105499:	75 0c                	jne    801054a7 <scheduler_sml+0x3d>
8010549b:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
8010549f:	76 06                	jbe    801054a7 <scheduler_sml+0x3d>
        priority--;
801054a1:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801054a5:	eb 07                	jmp    801054ae <scheduler_sml+0x44>
    else
      priority=MAX_PRIORITY;
801054a7:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)

    chosenProc=0;
801054ae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    beenInside=1;
801054b5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    // Loop over process table looking for process to run.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054bc:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801054c3:	e9 90 00 00 00       	jmp    80105558 <scheduler_sml+0xee>
      if((p->state != RUNNABLE) || (p->priority!=priority))
801054c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cb:	8b 40 0c             	mov    0xc(%eax),%eax
801054ce:	83 f8 03             	cmp    $0x3,%eax
801054d1:	75 7d                	jne    80105550 <scheduler_sml+0xe6>
801054d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d6:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801054dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801054df:	75 6f                	jne    80105550 <scheduler_sml+0xe6>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      chosenProc=p;
801054e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      proc = p;
801054e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ea:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801054f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f3:	89 04 24             	mov    %eax,(%esp)
801054f6:	e8 ff 34 00 00       	call   801089fa <switchuvm>
      p->state = RUNNING;
801054fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054fe:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105505:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010550b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010550e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105515:	83 c2 04             	add    $0x4,%edx
80105518:	89 44 24 04          	mov    %eax,0x4(%esp)
8010551c:	89 14 24             	mov    %edx,(%esp)
8010551f:	e8 70 0a 00 00       	call   80105f94 <swtch>
      switchkvm();
80105524:	e8 b4 34 00 00       	call   801089dd <switchkvm>
      //  If a system call to change priority has been made, we need to relate this.
      if (p->priority>priority)
80105529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552c:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105532:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105535:	76 0c                	jbe    80105543 <scheduler_sml+0xd9>
        priority=p->priority;
80105537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105540:	89 45 ec             	mov    %eax,-0x14(%ebp)

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105543:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010554a:	00 00 00 00 
8010554e:	eb 01                	jmp    80105551 <scheduler_sml+0xe7>
    chosenProc=0;
    beenInside=1;
    // Loop over process table looking for process to run.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if((p->state != RUNNABLE) || (p->priority!=priority))
        continue;
80105550:	90                   	nop
      priority=MAX_PRIORITY;

    chosenProc=0;
    beenInside=1;
    // Loop over process table looking for process to run.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105551:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105558:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
8010555f:	0f 82 63 ff ff ff    	jb     801054c8 <scheduler_sml+0x5e>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105565:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010556c:	e8 90 05 00 00       	call   80105b01 <release>

  }
80105571:	e9 08 ff ff ff       	jmp    8010547e <scheduler_sml+0x14>

80105576 <scheduler_dml>:
}


void
scheduler_dml(void) {
80105576:	55                   	push   %ebp
80105577:	89 e5                	mov    %esp,%ebp
80105579:	83 ec 08             	sub    $0x8,%esp
  scheduler_sml();
8010557c:	e8 e9 fe ff ff       	call   8010546a <scheduler_sml>

80105581 <scheduler>:
}

void
scheduler(void)
{
80105581:	55                   	push   %ebp
80105582:	89 e5                	mov    %esp,%ebp
80105584:	83 ec 08             	sub    $0x8,%esp
#if SCHEDFLAG == DEFAULT
  scheduler_def();
#elif SCHEDFLAG == FCFS
  scheduler_fcfs();
#elif SCHEDFLAG == SML
  scheduler_sml();
80105587:	e8 de fe ff ff       	call   8010546a <scheduler_sml>

8010558c <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010558c:	55                   	push   %ebp
8010558d:	89 e5                	mov    %esp,%ebp
8010558f:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80105592:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105599:	e8 1f 06 00 00       	call   80105bbd <holding>
8010559e:	85 c0                	test   %eax,%eax
801055a0:	75 0c                	jne    801055ae <sched+0x22>
    panic("sched ptable.lock");
801055a2:	c7 04 24 f5 94 10 80 	movl   $0x801094f5,(%esp)
801055a9:	e8 8f af ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
801055ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055b4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055ba:	83 f8 01             	cmp    $0x1,%eax
801055bd:	74 0c                	je     801055cb <sched+0x3f>
    panic("sched locks");
801055bf:	c7 04 24 07 95 10 80 	movl   $0x80109507,(%esp)
801055c6:	e8 72 af ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
801055cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d1:	8b 40 0c             	mov    0xc(%eax),%eax
801055d4:	83 f8 04             	cmp    $0x4,%eax
801055d7:	75 0c                	jne    801055e5 <sched+0x59>
    panic("sched running");
801055d9:	c7 04 24 13 95 10 80 	movl   $0x80109513,(%esp)
801055e0:	e8 58 af ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
801055e5:	e8 0a f6 ff ff       	call   80104bf4 <readeflags>
801055ea:	25 00 02 00 00       	and    $0x200,%eax
801055ef:	85 c0                	test   %eax,%eax
801055f1:	74 0c                	je     801055ff <sched+0x73>
    panic("sched interruptible");
801055f3:	c7 04 24 21 95 10 80 	movl   $0x80109521,(%esp)
801055fa:	e8 3e af ff ff       	call   8010053d <panic>
  intena = cpu->intena;
801055ff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105605:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010560b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010560e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105614:	8b 40 04             	mov    0x4(%eax),%eax
80105617:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010561e:	83 c2 1c             	add    $0x1c,%edx
80105621:	89 44 24 04          	mov    %eax,0x4(%esp)
80105625:	89 14 24             	mov    %edx,(%esp)
80105628:	e8 67 09 00 00       	call   80105f94 <swtch>
  cpu->intena = intena;
8010562d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105633:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105636:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010563c:	c9                   	leave  
8010563d:	c3                   	ret    

8010563e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010563e:	55                   	push   %ebp
8010563f:	89 e5                	mov    %esp,%ebp
80105641:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105644:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010564b:	e8 4f 04 00 00       	call   80105a9f <acquire>
  proc->state = RUNNABLE;
80105650:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105656:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010565d:	e8 2a ff ff ff       	call   8010558c <sched>
  release(&ptable.lock);
80105662:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105669:	e8 93 04 00 00       	call   80105b01 <release>
}
8010566e:	c9                   	leave  
8010566f:	c3                   	ret    

80105670 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105670:	55                   	push   %ebp
80105671:	89 e5                	mov    %esp,%ebp
80105673:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105676:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010567d:	e8 7f 04 00 00       	call   80105b01 <release>

  if (first) {
80105682:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80105687:	85 c0                	test   %eax,%eax
80105689:	74 22                	je     801056ad <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010568b:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80105692:	00 00 00 
    iinit(ROOTDEV);
80105695:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010569c:	e8 2b c7 ff ff       	call   80101dcc <iinit>
    initlog(ROOTDEV);
801056a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056a8:	e8 63 e4 ff ff       	call   80103b10 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801056ad:	c9                   	leave  
801056ae:	c3                   	ret    

801056af <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801056af:	55                   	push   %ebp
801056b0:	89 e5                	mov    %esp,%ebp
801056b2:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801056b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056bb:	85 c0                	test   %eax,%eax
801056bd:	75 0c                	jne    801056cb <sleep+0x1c>
    panic("sleep");
801056bf:	c7 04 24 35 95 10 80 	movl   $0x80109535,(%esp)
801056c6:	e8 72 ae ff ff       	call   8010053d <panic>

  if(lk == 0)
801056cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801056cf:	75 0c                	jne    801056dd <sleep+0x2e>
    panic("sleep without lk");
801056d1:	c7 04 24 3b 95 10 80 	movl   $0x8010953b,(%esp)
801056d8:	e8 60 ae ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801056dd:	81 7d 0c a0 41 11 80 	cmpl   $0x801141a0,0xc(%ebp)
801056e4:	74 17                	je     801056fd <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801056e6:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801056ed:	e8 ad 03 00 00       	call   80105a9f <acquire>
    release(lk);
801056f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f5:	89 04 24             	mov    %eax,(%esp)
801056f8:	e8 04 04 00 00       	call   80105b01 <release>
  }

  // Go to sleep.
  proc->chan = chan;
801056fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105703:	8b 55 08             	mov    0x8(%ebp),%edx
80105706:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105709:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010570f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
#if SCHEDFLAG == DML
  proc->priority=MAX_PRIORITY;
#endif
  sched();
80105716:	e8 71 fe ff ff       	call   8010558c <sched>

  // Tidy up.
  proc->chan = 0;
8010571b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105721:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105728:	81 7d 0c a0 41 11 80 	cmpl   $0x801141a0,0xc(%ebp)
8010572f:	74 17                	je     80105748 <sleep+0x99>
    release(&ptable.lock);
80105731:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105738:	e8 c4 03 00 00       	call   80105b01 <release>
    acquire(lk);
8010573d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105740:	89 04 24             	mov    %eax,(%esp)
80105743:	e8 57 03 00 00       	call   80105a9f <acquire>
  }
}
80105748:	c9                   	leave  
80105749:	c3                   	ret    

8010574a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010574a:	55                   	push   %ebp
8010574b:	89 e5                	mov    %esp,%ebp
8010574d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105750:	c7 45 fc d4 41 11 80 	movl   $0x801141d4,-0x4(%ebp)
80105757:	eb 27                	jmp    80105780 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan){
80105759:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010575c:	8b 40 0c             	mov    0xc(%eax),%eax
8010575f:	83 f8 02             	cmp    $0x2,%eax
80105762:	75 15                	jne    80105779 <wakeup1+0x2f>
80105764:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105767:	8b 40 20             	mov    0x20(%eax),%eax
8010576a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010576d:	75 0a                	jne    80105779 <wakeup1+0x2f>
      #if SCHEDFLAG == DML
      p->priority=MAX_PRIORITY;
      #endif
      p->state = RUNNABLE;
8010576f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105772:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105779:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80105780:	81 7d fc d4 65 11 80 	cmpl   $0x801165d4,-0x4(%ebp)
80105787:	72 d0                	jb     80105759 <wakeup1+0xf>
      p->priority=MAX_PRIORITY;
      #endif
      p->state = RUNNABLE;
    }

}
80105789:	c9                   	leave  
8010578a:	c3                   	ret    

8010578b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010578b:	55                   	push   %ebp
8010578c:	89 e5                	mov    %esp,%ebp
8010578e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105791:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105798:	e8 02 03 00 00       	call   80105a9f <acquire>
  wakeup1(chan);
8010579d:	8b 45 08             	mov    0x8(%ebp),%eax
801057a0:	89 04 24             	mov    %eax,(%esp)
801057a3:	e8 a2 ff ff ff       	call   8010574a <wakeup1>
  release(&ptable.lock);
801057a8:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801057af:	e8 4d 03 00 00       	call   80105b01 <release>
}
801057b4:	c9                   	leave  
801057b5:	c3                   	ret    

801057b6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801057b6:	55                   	push   %ebp
801057b7:	89 e5                	mov    %esp,%ebp
801057b9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801057bc:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801057c3:	e8 d7 02 00 00       	call   80105a9f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057c8:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801057cf:	eb 44                	jmp    80105815 <kill+0x5f>
    if(p->pid == pid){
801057d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d4:	8b 40 10             	mov    0x10(%eax),%eax
801057d7:	3b 45 08             	cmp    0x8(%ebp),%eax
801057da:	75 32                	jne    8010580e <kill+0x58>
      p->killed = 1;
801057dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057df:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801057e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e9:	8b 40 0c             	mov    0xc(%eax),%eax
801057ec:	83 f8 02             	cmp    $0x2,%eax
801057ef:	75 0a                	jne    801057fb <kill+0x45>
        p->state = RUNNABLE;
801057f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801057fb:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105802:	e8 fa 02 00 00       	call   80105b01 <release>
      return 0;
80105807:	b8 00 00 00 00       	mov    $0x0,%eax
8010580c:	eb 21                	jmp    8010582f <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010580e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105815:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
8010581c:	72 b3                	jb     801057d1 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010581e:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105825:	e8 d7 02 00 00       	call   80105b01 <release>
  return -1;
8010582a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010582f:	c9                   	leave  
80105830:	c3                   	ret    

80105831 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105831:	55                   	push   %ebp
80105832:	89 e5                	mov    %esp,%ebp
80105834:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105837:	c7 45 f0 d4 41 11 80 	movl   $0x801141d4,-0x10(%ebp)
8010583e:	e9 db 00 00 00       	jmp    8010591e <procdump+0xed>
    if(p->state == UNUSED)
80105843:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105846:	8b 40 0c             	mov    0xc(%eax),%eax
80105849:	85 c0                	test   %eax,%eax
8010584b:	0f 84 c5 00 00 00    	je     80105916 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105854:	8b 40 0c             	mov    0xc(%eax),%eax
80105857:	83 f8 05             	cmp    $0x5,%eax
8010585a:	77 23                	ja     8010587f <procdump+0x4e>
8010585c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585f:	8b 40 0c             	mov    0xc(%eax),%eax
80105862:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105869:	85 c0                	test   %eax,%eax
8010586b:	74 12                	je     8010587f <procdump+0x4e>
      state = states[p->state];
8010586d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105870:	8b 40 0c             	mov    0xc(%eax),%eax
80105873:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010587a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010587d:	eb 07                	jmp    80105886 <procdump+0x55>
    else
      state = "???";
8010587f:	c7 45 ec 4c 95 10 80 	movl   $0x8010954c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105889:	8d 50 6c             	lea    0x6c(%eax),%edx
8010588c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588f:	8b 40 10             	mov    0x10(%eax),%eax
80105892:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105896:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105899:	89 54 24 08          	mov    %edx,0x8(%esp)
8010589d:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a1:	c7 04 24 50 95 10 80 	movl   $0x80109550,(%esp)
801058a8:	e8 f4 aa ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
801058ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b0:	8b 40 0c             	mov    0xc(%eax),%eax
801058b3:	83 f8 02             	cmp    $0x2,%eax
801058b6:	75 50                	jne    80105908 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801058b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bb:	8b 40 1c             	mov    0x1c(%eax),%eax
801058be:	8b 40 0c             	mov    0xc(%eax),%eax
801058c1:	83 c0 08             	add    $0x8,%eax
801058c4:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801058c7:	89 54 24 04          	mov    %edx,0x4(%esp)
801058cb:	89 04 24             	mov    %eax,(%esp)
801058ce:	e8 7d 02 00 00       	call   80105b50 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801058d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058da:	eb 1b                	jmp    801058f7 <procdump+0xc6>
        cprintf(" %p", pc[i]);
801058dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058df:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801058e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801058e7:	c7 04 24 59 95 10 80 	movl   $0x80109559,(%esp)
801058ee:	e8 ae aa ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801058f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058f7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801058fb:	7f 0b                	jg     80105908 <procdump+0xd7>
801058fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105900:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105904:	85 c0                	test   %eax,%eax
80105906:	75 d4                	jne    801058dc <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105908:	c7 04 24 5d 95 10 80 	movl   $0x8010955d,(%esp)
8010590f:	e8 8d aa ff ff       	call   801003a1 <cprintf>
80105914:	eb 01                	jmp    80105917 <procdump+0xe6>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105916:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105917:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
8010591e:	81 7d f0 d4 65 11 80 	cmpl   $0x801165d4,-0x10(%ebp)
80105925:	0f 82 18 ff ff ff    	jb     80105843 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010592b:	c9                   	leave  
8010592c:	c3                   	ret    

8010592d <updateTimes>:


void
updateTimes()
{
8010592d:	55                   	push   %ebp
8010592e:	89 e5                	mov    %esp,%ebp
80105930:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105933:	c7 45 fc d4 41 11 80 	movl   $0x801141d4,-0x4(%ebp)
8010593a:	eb 47                	jmp    80105983 <updateTimes+0x56>
    if(p->state == RUNNING)
8010593c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010593f:	8b 40 0c             	mov    0xc(%eax),%eax
80105942:	83 f8 04             	cmp    $0x4,%eax
80105945:	75 15                	jne    8010595c <updateTimes+0x2f>
      p->rutime++;
80105947:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010594a:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105950:	8d 50 01             	lea    0x1(%eax),%edx
80105953:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105956:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    if(p->state == SLEEPING)
8010595c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010595f:	8b 40 0c             	mov    0xc(%eax),%eax
80105962:	83 f8 02             	cmp    $0x2,%eax
80105965:	75 15                	jne    8010597c <updateTimes+0x4f>
      p->stime++;
80105967:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010596a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105970:	8d 50 01             	lea    0x1(%eax),%edx
80105973:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105976:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

void
updateTimes()
{
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010597c:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80105983:	81 7d fc d4 65 11 80 	cmpl   $0x801165d4,-0x4(%ebp)
8010598a:	72 b0                	jb     8010593c <updateTimes+0xf>
    if(p->state == RUNNING)
      p->rutime++;
    if(p->state == SLEEPING)
      p->stime++;
    }
}
8010598c:	c9                   	leave  
8010598d:	c3                   	ret    

8010598e <wait2>:

int
wait2(int *retime, int *rutime, int* stime) {
8010598e:	55                   	push   %ebp
8010598f:	89 e5                	mov    %esp,%ebp
80105991:	83 ec 18             	sub    $0x18,%esp
 int childPid=wait();
80105994:	e8 42 f8 ff ff       	call   801051db <wait>
80105999:	89 45 f0             	mov    %eax,-0x10(%ebp)
 struct proc* p;
 if (childPid<0)
8010599c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059a0:	79 05                	jns    801059a7 <wait2+0x19>
  return childPid;
801059a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a5:	eb 5a                	jmp    80105a01 <wait2+0x73>
 for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059a7:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801059ae:	eb 45                	jmp    801059f5 <wait2+0x67>
      if(p->pid != childPid)
801059b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b3:	8b 40 10             	mov    0x10(%eax),%eax
801059b6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801059b9:	75 32                	jne    801059ed <wait2+0x5f>
        continue;
    *retime=p->retime;
801059bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059be:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801059c4:	89 c2                	mov    %eax,%edx
801059c6:	8b 45 08             	mov    0x8(%ebp),%eax
801059c9:	89 10                	mov    %edx,(%eax)
    *rutime=p->rutime;
801059cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ce:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801059d4:	89 c2                	mov    %eax,%edx
801059d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801059d9:	89 10                	mov    %edx,(%eax)
    *stime=p->stime;
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801059e4:	89 c2                	mov    %eax,%edx
801059e6:	8b 45 10             	mov    0x10(%ebp),%eax
801059e9:	89 10                	mov    %edx,(%eax)
801059eb:	eb 01                	jmp    801059ee <wait2+0x60>
 struct proc* p;
 if (childPid<0)
  return childPid;
 for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->pid != childPid)
        continue;
801059ed:	90                   	nop
wait2(int *retime, int *rutime, int* stime) {
 int childPid=wait();
 struct proc* p;
 if (childPid<0)
  return childPid;
 for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059ee:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801059f5:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801059fc:	72 b2                	jb     801059b0 <wait2+0x22>
        continue;
    *retime=p->retime;
    *rutime=p->rutime;
    *stime=p->stime;
  }
 return childPid;
801059fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a01:	c9                   	leave  
80105a02:	c3                   	ret    

80105a03 <set_prio>:

int
set_prio(int priority){
80105a03:	55                   	push   %ebp
80105a04:	89 e5                	mov    %esp,%ebp
  #if SCHEDFLAG == DML
  return -1;
  #endif
  if ((priority>MAX_PRIORITY) | (priority<MIN_PRIORITY))
80105a06:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80105a0a:	0f 9f c2             	setg   %dl
80105a0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105a11:	0f 9e c0             	setle  %al
80105a14:	09 d0                	or     %edx,%eax
80105a16:	84 c0                	test   %al,%al
80105a18:	74 07                	je     80105a21 <set_prio+0x1e>
    return -1;
80105a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1f:	eb 14                	jmp    80105a35 <set_prio+0x32>
  proc->priority=priority;
80105a21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a27:	8b 55 08             	mov    0x8(%ebp),%edx
80105a2a:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
  return 0;
80105a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a35:	5d                   	pop    %ebp
80105a36:	c3                   	ret    
	...

80105a38 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105a38:	55                   	push   %ebp
80105a39:	89 e5                	mov    %esp,%ebp
80105a3b:	53                   	push   %ebx
80105a3c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105a3f:	9c                   	pushf  
80105a40:	5b                   	pop    %ebx
80105a41:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105a44:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105a47:	83 c4 10             	add    $0x10,%esp
80105a4a:	5b                   	pop    %ebx
80105a4b:	5d                   	pop    %ebp
80105a4c:	c3                   	ret    

80105a4d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105a4d:	55                   	push   %ebp
80105a4e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105a50:	fa                   	cli    
}
80105a51:	5d                   	pop    %ebp
80105a52:	c3                   	ret    

80105a53 <sti>:

static inline void
sti(void)
{
80105a53:	55                   	push   %ebp
80105a54:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105a56:	fb                   	sti    
}
80105a57:	5d                   	pop    %ebp
80105a58:	c3                   	ret    

80105a59 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	53                   	push   %ebx
80105a5d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105a60:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105a63:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105a66:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105a69:	89 c3                	mov    %eax,%ebx
80105a6b:	89 d8                	mov    %ebx,%eax
80105a6d:	f0 87 02             	lock xchg %eax,(%edx)
80105a70:	89 c3                	mov    %eax,%ebx
80105a72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105a75:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105a78:	83 c4 10             	add    $0x10,%esp
80105a7b:	5b                   	pop    %ebx
80105a7c:	5d                   	pop    %ebp
80105a7d:	c3                   	ret    

80105a7e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105a7e:	55                   	push   %ebp
80105a7f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105a81:	8b 45 08             	mov    0x8(%ebp),%eax
80105a84:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a87:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105a93:	8b 45 08             	mov    0x8(%ebp),%eax
80105a96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105a9d:	5d                   	pop    %ebp
80105a9e:	c3                   	ret    

80105a9f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105a9f:	55                   	push   %ebp
80105aa0:	89 e5                	mov    %esp,%ebp
80105aa2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105aa5:	e8 3d 01 00 00       	call   80105be7 <pushcli>
  if(holding(lk))
80105aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80105aad:	89 04 24             	mov    %eax,(%esp)
80105ab0:	e8 08 01 00 00       	call   80105bbd <holding>
80105ab5:	85 c0                	test   %eax,%eax
80105ab7:	74 0c                	je     80105ac5 <acquire+0x26>
    panic("acquire");
80105ab9:	c7 04 24 89 95 10 80 	movl   $0x80109589,(%esp)
80105ac0:	e8 78 aa ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105ac5:	90                   	nop
80105ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ac9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105ad0:	00 
80105ad1:	89 04 24             	mov    %eax,(%esp)
80105ad4:	e8 80 ff ff ff       	call   80105a59 <xchg>
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	75 e9                	jne    80105ac6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105add:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105ae7:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105aea:	8b 45 08             	mov    0x8(%ebp),%eax
80105aed:	83 c0 0c             	add    $0xc,%eax
80105af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af4:	8d 45 08             	lea    0x8(%ebp),%eax
80105af7:	89 04 24             	mov    %eax,(%esp)
80105afa:	e8 51 00 00 00       	call   80105b50 <getcallerpcs>
}
80105aff:	c9                   	leave  
80105b00:	c3                   	ret    

80105b01 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105b01:	55                   	push   %ebp
80105b02:	89 e5                	mov    %esp,%ebp
80105b04:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105b07:	8b 45 08             	mov    0x8(%ebp),%eax
80105b0a:	89 04 24             	mov    %eax,(%esp)
80105b0d:	e8 ab 00 00 00       	call   80105bbd <holding>
80105b12:	85 c0                	test   %eax,%eax
80105b14:	75 0c                	jne    80105b22 <release+0x21>
    panic("release");
80105b16:	c7 04 24 91 95 10 80 	movl   $0x80109591,(%esp)
80105b1d:	e8 1b aa ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105b22:	8b 45 08             	mov    0x8(%ebp),%eax
80105b25:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105b36:	8b 45 08             	mov    0x8(%ebp),%eax
80105b39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b40:	00 
80105b41:	89 04 24             	mov    %eax,(%esp)
80105b44:	e8 10 ff ff ff       	call   80105a59 <xchg>

  popcli();
80105b49:	e8 e1 00 00 00       	call   80105c2f <popcli>
}
80105b4e:	c9                   	leave  
80105b4f:	c3                   	ret    

80105b50 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105b50:	55                   	push   %ebp
80105b51:	89 e5                	mov    %esp,%ebp
80105b53:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105b56:	8b 45 08             	mov    0x8(%ebp),%eax
80105b59:	83 e8 08             	sub    $0x8,%eax
80105b5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105b5f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105b66:	eb 32                	jmp    80105b9a <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105b68:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105b6c:	74 47                	je     80105bb5 <getcallerpcs+0x65>
80105b6e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105b75:	76 3e                	jbe    80105bb5 <getcallerpcs+0x65>
80105b77:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105b7b:	74 38                	je     80105bb5 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105b7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b80:	c1 e0 02             	shl    $0x2,%eax
80105b83:	03 45 0c             	add    0xc(%ebp),%eax
80105b86:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b89:	8b 52 04             	mov    0x4(%edx),%edx
80105b8c:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105b8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b91:	8b 00                	mov    (%eax),%eax
80105b93:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105b96:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105b9a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105b9e:	7e c8                	jle    80105b68 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105ba0:	eb 13                	jmp    80105bb5 <getcallerpcs+0x65>
    pcs[i] = 0;
80105ba2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ba5:	c1 e0 02             	shl    $0x2,%eax
80105ba8:	03 45 0c             	add    0xc(%ebp),%eax
80105bab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105bb1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105bb5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105bb9:	7e e7                	jle    80105ba2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105bbb:	c9                   	leave  
80105bbc:	c3                   	ret    

80105bbd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105bbd:	55                   	push   %ebp
80105bbe:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc3:	8b 00                	mov    (%eax),%eax
80105bc5:	85 c0                	test   %eax,%eax
80105bc7:	74 17                	je     80105be0 <holding+0x23>
80105bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcc:	8b 50 08             	mov    0x8(%eax),%edx
80105bcf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105bd5:	39 c2                	cmp    %eax,%edx
80105bd7:	75 07                	jne    80105be0 <holding+0x23>
80105bd9:	b8 01 00 00 00       	mov    $0x1,%eax
80105bde:	eb 05                	jmp    80105be5 <holding+0x28>
80105be0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105be5:	5d                   	pop    %ebp
80105be6:	c3                   	ret    

80105be7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105be7:	55                   	push   %ebp
80105be8:	89 e5                	mov    %esp,%ebp
80105bea:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105bed:	e8 46 fe ff ff       	call   80105a38 <readeflags>
80105bf2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105bf5:	e8 53 fe ff ff       	call   80105a4d <cli>
  if(cpu->ncli++ == 0)
80105bfa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c00:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105c06:	85 d2                	test   %edx,%edx
80105c08:	0f 94 c1             	sete   %cl
80105c0b:	83 c2 01             	add    $0x1,%edx
80105c0e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105c14:	84 c9                	test   %cl,%cl
80105c16:	74 15                	je     80105c2d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105c18:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c1e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c21:	81 e2 00 02 00 00    	and    $0x200,%edx
80105c27:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105c2d:	c9                   	leave  
80105c2e:	c3                   	ret    

80105c2f <popcli>:

void
popcli(void)
{
80105c2f:	55                   	push   %ebp
80105c30:	89 e5                	mov    %esp,%ebp
80105c32:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105c35:	e8 fe fd ff ff       	call   80105a38 <readeflags>
80105c3a:	25 00 02 00 00       	and    $0x200,%eax
80105c3f:	85 c0                	test   %eax,%eax
80105c41:	74 0c                	je     80105c4f <popcli+0x20>
    panic("popcli - interruptible");
80105c43:	c7 04 24 99 95 10 80 	movl   $0x80109599,(%esp)
80105c4a:	e8 ee a8 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105c4f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c55:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105c5b:	83 ea 01             	sub    $0x1,%edx
80105c5e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105c64:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105c6a:	85 c0                	test   %eax,%eax
80105c6c:	79 0c                	jns    80105c7a <popcli+0x4b>
    panic("popcli");
80105c6e:	c7 04 24 b0 95 10 80 	movl   $0x801095b0,(%esp)
80105c75:	e8 c3 a8 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105c7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c80:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105c86:	85 c0                	test   %eax,%eax
80105c88:	75 15                	jne    80105c9f <popcli+0x70>
80105c8a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c90:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105c96:	85 c0                	test   %eax,%eax
80105c98:	74 05                	je     80105c9f <popcli+0x70>
    sti();
80105c9a:	e8 b4 fd ff ff       	call   80105a53 <sti>
}
80105c9f:	c9                   	leave  
80105ca0:	c3                   	ret    
80105ca1:	00 00                	add    %al,(%eax)
	...

80105ca4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105ca4:	55                   	push   %ebp
80105ca5:	89 e5                	mov    %esp,%ebp
80105ca7:	57                   	push   %edi
80105ca8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105cac:	8b 55 10             	mov    0x10(%ebp),%edx
80105caf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cb2:	89 cb                	mov    %ecx,%ebx
80105cb4:	89 df                	mov    %ebx,%edi
80105cb6:	89 d1                	mov    %edx,%ecx
80105cb8:	fc                   	cld    
80105cb9:	f3 aa                	rep stos %al,%es:(%edi)
80105cbb:	89 ca                	mov    %ecx,%edx
80105cbd:	89 fb                	mov    %edi,%ebx
80105cbf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105cc2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105cc5:	5b                   	pop    %ebx
80105cc6:	5f                   	pop    %edi
80105cc7:	5d                   	pop    %ebp
80105cc8:	c3                   	ret    

80105cc9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105cc9:	55                   	push   %ebp
80105cca:	89 e5                	mov    %esp,%ebp
80105ccc:	57                   	push   %edi
80105ccd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105cd1:	8b 55 10             	mov    0x10(%ebp),%edx
80105cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cd7:	89 cb                	mov    %ecx,%ebx
80105cd9:	89 df                	mov    %ebx,%edi
80105cdb:	89 d1                	mov    %edx,%ecx
80105cdd:	fc                   	cld    
80105cde:	f3 ab                	rep stos %eax,%es:(%edi)
80105ce0:	89 ca                	mov    %ecx,%edx
80105ce2:	89 fb                	mov    %edi,%ebx
80105ce4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105ce7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105cea:	5b                   	pop    %ebx
80105ceb:	5f                   	pop    %edi
80105cec:	5d                   	pop    %ebp
80105ced:	c3                   	ret    

80105cee <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105cee:	55                   	push   %ebp
80105cef:	89 e5                	mov    %esp,%ebp
80105cf1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf7:	83 e0 03             	and    $0x3,%eax
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	75 49                	jne    80105d47 <memset+0x59>
80105cfe:	8b 45 10             	mov    0x10(%ebp),%eax
80105d01:	83 e0 03             	and    $0x3,%eax
80105d04:	85 c0                	test   %eax,%eax
80105d06:	75 3f                	jne    80105d47 <memset+0x59>
    c &= 0xFF;
80105d08:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105d0f:	8b 45 10             	mov    0x10(%ebp),%eax
80105d12:	c1 e8 02             	shr    $0x2,%eax
80105d15:	89 c2                	mov    %eax,%edx
80105d17:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d1a:	89 c1                	mov    %eax,%ecx
80105d1c:	c1 e1 18             	shl    $0x18,%ecx
80105d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d22:	c1 e0 10             	shl    $0x10,%eax
80105d25:	09 c1                	or     %eax,%ecx
80105d27:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2a:	c1 e0 08             	shl    $0x8,%eax
80105d2d:	09 c8                	or     %ecx,%eax
80105d2f:	0b 45 0c             	or     0xc(%ebp),%eax
80105d32:	89 54 24 08          	mov    %edx,0x8(%esp)
80105d36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d3d:	89 04 24             	mov    %eax,(%esp)
80105d40:	e8 84 ff ff ff       	call   80105cc9 <stosl>
80105d45:	eb 19                	jmp    80105d60 <memset+0x72>
  } else
    stosb(dst, c, n);
80105d47:	8b 45 10             	mov    0x10(%ebp),%eax
80105d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d51:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d55:	8b 45 08             	mov    0x8(%ebp),%eax
80105d58:	89 04 24             	mov    %eax,(%esp)
80105d5b:	e8 44 ff ff ff       	call   80105ca4 <stosb>
  return dst;
80105d60:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105d63:	c9                   	leave  
80105d64:	c3                   	ret    

80105d65 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105d65:	55                   	push   %ebp
80105d66:	89 e5                	mov    %esp,%ebp
80105d68:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105d6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d74:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105d77:	eb 32                	jmp    80105dab <memcmp+0x46>
    if(*s1 != *s2)
80105d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d7c:	0f b6 10             	movzbl (%eax),%edx
80105d7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d82:	0f b6 00             	movzbl (%eax),%eax
80105d85:	38 c2                	cmp    %al,%dl
80105d87:	74 1a                	je     80105da3 <memcmp+0x3e>
      return *s1 - *s2;
80105d89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d8c:	0f b6 00             	movzbl (%eax),%eax
80105d8f:	0f b6 d0             	movzbl %al,%edx
80105d92:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d95:	0f b6 00             	movzbl (%eax),%eax
80105d98:	0f b6 c0             	movzbl %al,%eax
80105d9b:	89 d1                	mov    %edx,%ecx
80105d9d:	29 c1                	sub    %eax,%ecx
80105d9f:	89 c8                	mov    %ecx,%eax
80105da1:	eb 1c                	jmp    80105dbf <memcmp+0x5a>
    s1++, s2++;
80105da3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105da7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105dab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105daf:	0f 95 c0             	setne  %al
80105db2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105db6:	84 c0                	test   %al,%al
80105db8:	75 bf                	jne    80105d79 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105dba:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dbf:	c9                   	leave  
80105dc0:	c3                   	ret    

80105dc1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105dc1:	55                   	push   %ebp
80105dc2:	89 e5                	mov    %esp,%ebp
80105dc4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105dd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dd6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105dd9:	73 54                	jae    80105e2f <memmove+0x6e>
80105ddb:	8b 45 10             	mov    0x10(%ebp),%eax
80105dde:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105de1:	01 d0                	add    %edx,%eax
80105de3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105de6:	76 47                	jbe    80105e2f <memmove+0x6e>
    s += n;
80105de8:	8b 45 10             	mov    0x10(%ebp),%eax
80105deb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105dee:	8b 45 10             	mov    0x10(%ebp),%eax
80105df1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105df4:	eb 13                	jmp    80105e09 <memmove+0x48>
      *--d = *--s;
80105df6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105dfa:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105dfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e01:	0f b6 10             	movzbl (%eax),%edx
80105e04:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e07:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105e09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e0d:	0f 95 c0             	setne  %al
80105e10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105e14:	84 c0                	test   %al,%al
80105e16:	75 de                	jne    80105df6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105e18:	eb 25                	jmp    80105e3f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105e1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e1d:	0f b6 10             	movzbl (%eax),%edx
80105e20:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e23:	88 10                	mov    %dl,(%eax)
80105e25:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105e29:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e2d:	eb 01                	jmp    80105e30 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105e2f:	90                   	nop
80105e30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e34:	0f 95 c0             	setne  %al
80105e37:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105e3b:	84 c0                	test   %al,%al
80105e3d:	75 db                	jne    80105e1a <memmove+0x59>
      *d++ = *s++;

  return dst;
80105e3f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e42:	c9                   	leave  
80105e43:	c3                   	ret    

80105e44 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105e44:	55                   	push   %ebp
80105e45:	89 e5                	mov    %esp,%ebp
80105e47:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105e4a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e54:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e58:	8b 45 08             	mov    0x8(%ebp),%eax
80105e5b:	89 04 24             	mov    %eax,(%esp)
80105e5e:	e8 5e ff ff ff       	call   80105dc1 <memmove>
}
80105e63:	c9                   	leave  
80105e64:	c3                   	ret    

80105e65 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105e65:	55                   	push   %ebp
80105e66:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105e68:	eb 0c                	jmp    80105e76 <strncmp+0x11>
    n--, p++, q++;
80105e6a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105e6e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105e72:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e7a:	74 1a                	je     80105e96 <strncmp+0x31>
80105e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80105e7f:	0f b6 00             	movzbl (%eax),%eax
80105e82:	84 c0                	test   %al,%al
80105e84:	74 10                	je     80105e96 <strncmp+0x31>
80105e86:	8b 45 08             	mov    0x8(%ebp),%eax
80105e89:	0f b6 10             	movzbl (%eax),%edx
80105e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e8f:	0f b6 00             	movzbl (%eax),%eax
80105e92:	38 c2                	cmp    %al,%dl
80105e94:	74 d4                	je     80105e6a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105e96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e9a:	75 07                	jne    80105ea3 <strncmp+0x3e>
    return 0;
80105e9c:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea1:	eb 18                	jmp    80105ebb <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea6:	0f b6 00             	movzbl (%eax),%eax
80105ea9:	0f b6 d0             	movzbl %al,%edx
80105eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eaf:	0f b6 00             	movzbl (%eax),%eax
80105eb2:	0f b6 c0             	movzbl %al,%eax
80105eb5:	89 d1                	mov    %edx,%ecx
80105eb7:	29 c1                	sub    %eax,%ecx
80105eb9:	89 c8                	mov    %ecx,%eax
}
80105ebb:	5d                   	pop    %ebp
80105ebc:	c3                   	ret    

80105ebd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105ebd:	55                   	push   %ebp
80105ebe:	89 e5                	mov    %esp,%ebp
80105ec0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105ec9:	90                   	nop
80105eca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ece:	0f 9f c0             	setg   %al
80105ed1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105ed5:	84 c0                	test   %al,%al
80105ed7:	74 30                	je     80105f09 <strncpy+0x4c>
80105ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105edc:	0f b6 10             	movzbl (%eax),%edx
80105edf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee2:	88 10                	mov    %dl,(%eax)
80105ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee7:	0f b6 00             	movzbl (%eax),%eax
80105eea:	84 c0                	test   %al,%al
80105eec:	0f 95 c0             	setne  %al
80105eef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105ef3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105ef7:	84 c0                	test   %al,%al
80105ef9:	75 cf                	jne    80105eca <strncpy+0xd>
    ;
  while(n-- > 0)
80105efb:	eb 0c                	jmp    80105f09 <strncpy+0x4c>
    *s++ = 0;
80105efd:	8b 45 08             	mov    0x8(%ebp),%eax
80105f00:	c6 00 00             	movb   $0x0,(%eax)
80105f03:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f07:	eb 01                	jmp    80105f0a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105f09:	90                   	nop
80105f0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f0e:	0f 9f c0             	setg   %al
80105f11:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f15:	84 c0                	test   %al,%al
80105f17:	75 e4                	jne    80105efd <strncpy+0x40>
    *s++ = 0;
  return os;
80105f19:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f1c:	c9                   	leave  
80105f1d:	c3                   	ret    

80105f1e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105f1e:	55                   	push   %ebp
80105f1f:	89 e5                	mov    %esp,%ebp
80105f21:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f24:	8b 45 08             	mov    0x8(%ebp),%eax
80105f27:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f2e:	7f 05                	jg     80105f35 <safestrcpy+0x17>
    return os;
80105f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f33:	eb 35                	jmp    80105f6a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105f35:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f3d:	7e 22                	jle    80105f61 <safestrcpy+0x43>
80105f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f42:	0f b6 10             	movzbl (%eax),%edx
80105f45:	8b 45 08             	mov    0x8(%ebp),%eax
80105f48:	88 10                	mov    %dl,(%eax)
80105f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80105f4d:	0f b6 00             	movzbl (%eax),%eax
80105f50:	84 c0                	test   %al,%al
80105f52:	0f 95 c0             	setne  %al
80105f55:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f59:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105f5d:	84 c0                	test   %al,%al
80105f5f:	75 d4                	jne    80105f35 <safestrcpy+0x17>
    ;
  *s = 0;
80105f61:	8b 45 08             	mov    0x8(%ebp),%eax
80105f64:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105f67:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f6a:	c9                   	leave  
80105f6b:	c3                   	ret    

80105f6c <strlen>:

int
strlen(const char *s)
{
80105f6c:	55                   	push   %ebp
80105f6d:	89 e5                	mov    %esp,%ebp
80105f6f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105f72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105f79:	eb 04                	jmp    80105f7f <strlen+0x13>
80105f7b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f82:	03 45 08             	add    0x8(%ebp),%eax
80105f85:	0f b6 00             	movzbl (%eax),%eax
80105f88:	84 c0                	test   %al,%al
80105f8a:	75 ef                	jne    80105f7b <strlen+0xf>
    ;
  return n;
80105f8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f8f:	c9                   	leave  
80105f90:	c3                   	ret    
80105f91:	00 00                	add    %al,(%eax)
	...

80105f94 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105f94:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105f98:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105f9c:	55                   	push   %ebp
  pushl %ebx
80105f9d:	53                   	push   %ebx
  pushl %esi
80105f9e:	56                   	push   %esi
  pushl %edi
80105f9f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105fa0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105fa2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105fa4:	5f                   	pop    %edi
  popl %esi
80105fa5:	5e                   	pop    %esi
  popl %ebx
80105fa6:	5b                   	pop    %ebx
  popl %ebp
80105fa7:	5d                   	pop    %ebp
  ret
80105fa8:	c3                   	ret    
80105fa9:	00 00                	add    %al,(%eax)
	...

80105fac <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105fac:	55                   	push   %ebp
80105fad:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105faf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fb5:	8b 00                	mov    (%eax),%eax
80105fb7:	3b 45 08             	cmp    0x8(%ebp),%eax
80105fba:	76 12                	jbe    80105fce <fetchint+0x22>
80105fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80105fbf:	8d 50 04             	lea    0x4(%eax),%edx
80105fc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fc8:	8b 00                	mov    (%eax),%eax
80105fca:	39 c2                	cmp    %eax,%edx
80105fcc:	76 07                	jbe    80105fd5 <fetchint+0x29>
    return -1;
80105fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd3:	eb 0f                	jmp    80105fe4 <fetchint+0x38>
  *ip = *(int*)(addr);
80105fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd8:	8b 10                	mov    (%eax),%edx
80105fda:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fdd:	89 10                	mov    %edx,(%eax)
  return 0;
80105fdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fe4:	5d                   	pop    %ebp
80105fe5:	c3                   	ret    

80105fe6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105fe6:	55                   	push   %ebp
80105fe7:	89 e5                	mov    %esp,%ebp
80105fe9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105fec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ff2:	8b 00                	mov    (%eax),%eax
80105ff4:	3b 45 08             	cmp    0x8(%ebp),%eax
80105ff7:	77 07                	ja     80106000 <fetchstr+0x1a>
    return -1;
80105ff9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ffe:	eb 48                	jmp    80106048 <fetchstr+0x62>
  *pp = (char*)addr;
80106000:	8b 55 08             	mov    0x8(%ebp),%edx
80106003:	8b 45 0c             	mov    0xc(%ebp),%eax
80106006:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106008:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010600e:	8b 00                	mov    (%eax),%eax
80106010:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106013:	8b 45 0c             	mov    0xc(%ebp),%eax
80106016:	8b 00                	mov    (%eax),%eax
80106018:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010601b:	eb 1e                	jmp    8010603b <fetchstr+0x55>
    if(*s == 0)
8010601d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106020:	0f b6 00             	movzbl (%eax),%eax
80106023:	84 c0                	test   %al,%al
80106025:	75 10                	jne    80106037 <fetchstr+0x51>
      return s - *pp;
80106027:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010602a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010602d:	8b 00                	mov    (%eax),%eax
8010602f:	89 d1                	mov    %edx,%ecx
80106031:	29 c1                	sub    %eax,%ecx
80106033:	89 c8                	mov    %ecx,%eax
80106035:	eb 11                	jmp    80106048 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106037:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010603b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010603e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106041:	72 da                	jb     8010601d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106043:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106048:	c9                   	leave  
80106049:	c3                   	ret    

8010604a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010604a:	55                   	push   %ebp
8010604b:	89 e5                	mov    %esp,%ebp
8010604d:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106050:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106056:	8b 40 18             	mov    0x18(%eax),%eax
80106059:	8b 50 44             	mov    0x44(%eax),%edx
8010605c:	8b 45 08             	mov    0x8(%ebp),%eax
8010605f:	c1 e0 02             	shl    $0x2,%eax
80106062:	01 d0                	add    %edx,%eax
80106064:	8d 50 04             	lea    0x4(%eax),%edx
80106067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010606a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606e:	89 14 24             	mov    %edx,(%esp)
80106071:	e8 36 ff ff ff       	call   80105fac <fetchint>
}
80106076:	c9                   	leave  
80106077:	c3                   	ret    

80106078 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106078:	55                   	push   %ebp
80106079:	89 e5                	mov    %esp,%ebp
8010607b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(argint(n, &i) < 0)
8010607e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106081:	89 44 24 04          	mov    %eax,0x4(%esp)
80106085:	8b 45 08             	mov    0x8(%ebp),%eax
80106088:	89 04 24             	mov    %eax,(%esp)
8010608b:	e8 ba ff ff ff       	call   8010604a <argint>
80106090:	85 c0                	test   %eax,%eax
80106092:	79 07                	jns    8010609b <argptr+0x23>
    return -1;
80106094:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106099:	eb 3d                	jmp    801060d8 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010609b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010609e:	89 c2                	mov    %eax,%edx
801060a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060a6:	8b 00                	mov    (%eax),%eax
801060a8:	39 c2                	cmp    %eax,%edx
801060aa:	73 16                	jae    801060c2 <argptr+0x4a>
801060ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060af:	89 c2                	mov    %eax,%edx
801060b1:	8b 45 10             	mov    0x10(%ebp),%eax
801060b4:	01 c2                	add    %eax,%edx
801060b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060bc:	8b 00                	mov    (%eax),%eax
801060be:	39 c2                	cmp    %eax,%edx
801060c0:	76 07                	jbe    801060c9 <argptr+0x51>
    return -1;
801060c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c7:	eb 0f                	jmp    801060d8 <argptr+0x60>
  *pp = (char*)i;
801060c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060cc:	89 c2                	mov    %eax,%edx
801060ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801060d1:	89 10                	mov    %edx,(%eax)
  return 0;
801060d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d8:	c9                   	leave  
801060d9:	c3                   	ret    

801060da <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801060da:	55                   	push   %ebp
801060db:	89 e5                	mov    %esp,%ebp
801060dd:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801060e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
801060e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801060e7:	8b 45 08             	mov    0x8(%ebp),%eax
801060ea:	89 04 24             	mov    %eax,(%esp)
801060ed:	e8 58 ff ff ff       	call   8010604a <argint>
801060f2:	85 c0                	test   %eax,%eax
801060f4:	79 07                	jns    801060fd <argstr+0x23>
    return -1;
801060f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060fb:	eb 12                	jmp    8010610f <argstr+0x35>
  return fetchstr(addr, pp);
801060fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106100:	8b 55 0c             	mov    0xc(%ebp),%edx
80106103:	89 54 24 04          	mov    %edx,0x4(%esp)
80106107:	89 04 24             	mov    %eax,(%esp)
8010610a:	e8 d7 fe ff ff       	call   80105fe6 <fetchstr>
}
8010610f:	c9                   	leave  
80106110:	c3                   	ret    

80106111 <syscall>:
[SYS_yield] sys_yield,
};

void
syscall(void)
{
80106111:	55                   	push   %ebp
80106112:	89 e5                	mov    %esp,%ebp
80106114:	53                   	push   %ebx
80106115:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80106118:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010611e:	8b 40 18             	mov    0x18(%eax),%eax
80106121:	8b 40 1c             	mov    0x1c(%eax),%eax
80106124:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106127:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612b:	7e 30                	jle    8010615d <syscall+0x4c>
8010612d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106130:	83 f8 18             	cmp    $0x18,%eax
80106133:	77 28                	ja     8010615d <syscall+0x4c>
80106135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106138:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010613f:	85 c0                	test   %eax,%eax
80106141:	74 1a                	je     8010615d <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106143:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106149:	8b 58 18             	mov    0x18(%eax),%ebx
8010614c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614f:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106156:	ff d0                	call   *%eax
80106158:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010615b:	eb 3d                	jmp    8010619a <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010615d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106163:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106166:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010616c:	8b 40 10             	mov    0x10(%eax),%eax
8010616f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106172:	89 54 24 0c          	mov    %edx,0xc(%esp)
80106176:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010617a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010617e:	c7 04 24 b7 95 10 80 	movl   $0x801095b7,(%esp)
80106185:	e8 17 a2 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010618a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106190:	8b 40 18             	mov    0x18(%eax),%eax
80106193:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010619a:	83 c4 24             	add    $0x24,%esp
8010619d:	5b                   	pop    %ebx
8010619e:	5d                   	pop    %ebp
8010619f:	c3                   	ret    

801061a0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801061a0:	55                   	push   %ebp
801061a1:	89 e5                	mov    %esp,%ebp
801061a3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801061a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ad:	8b 45 08             	mov    0x8(%ebp),%eax
801061b0:	89 04 24             	mov    %eax,(%esp)
801061b3:	e8 92 fe ff ff       	call   8010604a <argint>
801061b8:	85 c0                	test   %eax,%eax
801061ba:	79 07                	jns    801061c3 <argfd+0x23>
    return -1;
801061bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c1:	eb 50                	jmp    80106213 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801061c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c6:	85 c0                	test   %eax,%eax
801061c8:	78 21                	js     801061eb <argfd+0x4b>
801061ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061cd:	83 f8 0f             	cmp    $0xf,%eax
801061d0:	7f 19                	jg     801061eb <argfd+0x4b>
801061d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061db:	83 c2 08             	add    $0x8,%edx
801061de:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801061e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e9:	75 07                	jne    801061f2 <argfd+0x52>
    return -1;
801061eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f0:	eb 21                	jmp    80106213 <argfd+0x73>
  if(pfd)
801061f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801061f6:	74 08                	je     80106200 <argfd+0x60>
    *pfd = fd;
801061f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801061fe:	89 10                	mov    %edx,(%eax)
  if(pf)
80106200:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106204:	74 08                	je     8010620e <argfd+0x6e>
    *pf = f;
80106206:	8b 45 10             	mov    0x10(%ebp),%eax
80106209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010620c:	89 10                	mov    %edx,(%eax)
  return 0;
8010620e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106213:	c9                   	leave  
80106214:	c3                   	ret    

80106215 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106215:	55                   	push   %ebp
80106216:	89 e5                	mov    %esp,%ebp
80106218:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010621b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106222:	eb 30                	jmp    80106254 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106224:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010622a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010622d:	83 c2 08             	add    $0x8,%edx
80106230:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106234:	85 c0                	test   %eax,%eax
80106236:	75 18                	jne    80106250 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106238:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010623e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106241:	8d 4a 08             	lea    0x8(%edx),%ecx
80106244:	8b 55 08             	mov    0x8(%ebp),%edx
80106247:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010624b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010624e:	eb 0f                	jmp    8010625f <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106250:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106254:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106258:	7e ca                	jle    80106224 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010625a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010625f:	c9                   	leave  
80106260:	c3                   	ret    

80106261 <sys_dup>:

int
sys_dup(void)
{
80106261:	55                   	push   %ebp
80106262:	89 e5                	mov    %esp,%ebp
80106264:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106267:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010626a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010626e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106275:	00 
80106276:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010627d:	e8 1e ff ff ff       	call   801061a0 <argfd>
80106282:	85 c0                	test   %eax,%eax
80106284:	79 07                	jns    8010628d <sys_dup+0x2c>
    return -1;
80106286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628b:	eb 29                	jmp    801062b6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010628d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106290:	89 04 24             	mov    %eax,(%esp)
80106293:	e8 7d ff ff ff       	call   80106215 <fdalloc>
80106298:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010629b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010629f:	79 07                	jns    801062a8 <sys_dup+0x47>
    return -1;
801062a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a6:	eb 0e                	jmp    801062b6 <sys_dup+0x55>
  filedup(f);
801062a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ab:	89 04 24             	mov    %eax,(%esp)
801062ae:	e8 f5 b4 ff ff       	call   801017a8 <filedup>
  return fd;
801062b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062b6:	c9                   	leave  
801062b7:	c3                   	ret    

801062b8 <sys_read>:

int
sys_read(void)
{
801062b8:	55                   	push   %ebp
801062b9:	89 e5                	mov    %esp,%ebp
801062bb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801062be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801062c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062cc:	00 
801062cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062d4:	e8 c7 fe ff ff       	call   801061a0 <argfd>
801062d9:	85 c0                	test   %eax,%eax
801062db:	78 35                	js     80106312 <sys_read+0x5a>
801062dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062eb:	e8 5a fd ff ff       	call   8010604a <argint>
801062f0:	85 c0                	test   %eax,%eax
801062f2:	78 1e                	js     80106312 <sys_read+0x5a>
801062f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801062fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106302:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106309:	e8 6a fd ff ff       	call   80106078 <argptr>
8010630e:	85 c0                	test   %eax,%eax
80106310:	79 07                	jns    80106319 <sys_read+0x61>
    return -1;
80106312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106317:	eb 19                	jmp    80106332 <sys_read+0x7a>
  return fileread(f, p, n);
80106319:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010631c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106326:	89 54 24 04          	mov    %edx,0x4(%esp)
8010632a:	89 04 24             	mov    %eax,(%esp)
8010632d:	e8 e3 b5 ff ff       	call   80101915 <fileread>
}
80106332:	c9                   	leave  
80106333:	c3                   	ret    

80106334 <sys_write>:

int
sys_write(void)
{
80106334:	55                   	push   %ebp
80106335:	89 e5                	mov    %esp,%ebp
80106337:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010633a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010633d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106341:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106348:	00 
80106349:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106350:	e8 4b fe ff ff       	call   801061a0 <argfd>
80106355:	85 c0                	test   %eax,%eax
80106357:	78 35                	js     8010638e <sys_write+0x5a>
80106359:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010635c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106360:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106367:	e8 de fc ff ff       	call   8010604a <argint>
8010636c:	85 c0                	test   %eax,%eax
8010636e:	78 1e                	js     8010638e <sys_write+0x5a>
80106370:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106373:	89 44 24 08          	mov    %eax,0x8(%esp)
80106377:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010637a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010637e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106385:	e8 ee fc ff ff       	call   80106078 <argptr>
8010638a:	85 c0                	test   %eax,%eax
8010638c:	79 07                	jns    80106395 <sys_write+0x61>
    return -1;
8010638e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106393:	eb 19                	jmp    801063ae <sys_write+0x7a>
  return filewrite(f, p, n);
80106395:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106398:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010639b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801063a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801063a6:	89 04 24             	mov    %eax,(%esp)
801063a9:	e8 23 b6 ff ff       	call   801019d1 <filewrite>
}
801063ae:	c9                   	leave  
801063af:	c3                   	ret    

801063b0 <sys_close>:

int
sys_close(void)
{
801063b0:	55                   	push   %ebp
801063b1:	89 e5                	mov    %esp,%ebp
801063b3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801063b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801063bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801063c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063cb:	e8 d0 fd ff ff       	call   801061a0 <argfd>
801063d0:	85 c0                	test   %eax,%eax
801063d2:	79 07                	jns    801063db <sys_close+0x2b>
    return -1;
801063d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d9:	eb 24                	jmp    801063ff <sys_close+0x4f>
  proc->ofile[fd] = 0;
801063db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063e4:	83 c2 08             	add    $0x8,%edx
801063e7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063ee:	00 
  fileclose(f);
801063ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f2:	89 04 24             	mov    %eax,(%esp)
801063f5:	e8 f6 b3 ff ff       	call   801017f0 <fileclose>
  return 0;
801063fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063ff:	c9                   	leave  
80106400:	c3                   	ret    

80106401 <sys_fstat>:

int
sys_fstat(void)
{
80106401:	55                   	push   %ebp
80106402:	89 e5                	mov    %esp,%ebp
80106404:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106407:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010640a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010640e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106415:	00 
80106416:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010641d:	e8 7e fd ff ff       	call   801061a0 <argfd>
80106422:	85 c0                	test   %eax,%eax
80106424:	78 1f                	js     80106445 <sys_fstat+0x44>
80106426:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010642d:	00 
8010642e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106431:	89 44 24 04          	mov    %eax,0x4(%esp)
80106435:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010643c:	e8 37 fc ff ff       	call   80106078 <argptr>
80106441:	85 c0                	test   %eax,%eax
80106443:	79 07                	jns    8010644c <sys_fstat+0x4b>
    return -1;
80106445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010644a:	eb 12                	jmp    8010645e <sys_fstat+0x5d>
  return filestat(f, st);
8010644c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010644f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106452:	89 54 24 04          	mov    %edx,0x4(%esp)
80106456:	89 04 24             	mov    %eax,(%esp)
80106459:	e8 68 b4 ff ff       	call   801018c6 <filestat>
}
8010645e:	c9                   	leave  
8010645f:	c3                   	ret    

80106460 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106460:	55                   	push   %ebp
80106461:	89 e5                	mov    %esp,%ebp
80106463:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106466:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106469:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106474:	e8 61 fc ff ff       	call   801060da <argstr>
80106479:	85 c0                	test   %eax,%eax
8010647b:	78 17                	js     80106494 <sys_link+0x34>
8010647d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106480:	89 44 24 04          	mov    %eax,0x4(%esp)
80106484:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010648b:	e8 4a fc ff ff       	call   801060da <argstr>
80106490:	85 c0                	test   %eax,%eax
80106492:	79 0a                	jns    8010649e <sys_link+0x3e>
    return -1;
80106494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106499:	e9 41 01 00 00       	jmp    801065df <sys_link+0x17f>

  begin_op();
8010649e:	e8 6e d8 ff ff       	call   80103d11 <begin_op>
  if((ip = namei(old)) == 0){
801064a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801064a6:	89 04 24             	mov    %eax,(%esp)
801064a9:	e8 ef c7 ff ff       	call   80102c9d <namei>
801064ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064b5:	75 0f                	jne    801064c6 <sys_link+0x66>
    end_op();
801064b7:	e8 d6 d8 ff ff       	call   80103d92 <end_op>
    return -1;
801064bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c1:	e9 19 01 00 00       	jmp    801065df <sys_link+0x17f>
  }

  ilock(ip);
801064c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c9:	89 04 24             	mov    %eax,(%esp)
801064cc:	e8 24 bc ff ff       	call   801020f5 <ilock>
  if(ip->type == T_DIR){
801064d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801064d8:	66 83 f8 01          	cmp    $0x1,%ax
801064dc:	75 1a                	jne    801064f8 <sys_link+0x98>
    iunlockput(ip);
801064de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e1:	89 04 24             	mov    %eax,(%esp)
801064e4:	e8 96 be ff ff       	call   8010237f <iunlockput>
    end_op();
801064e9:	e8 a4 d8 ff ff       	call   80103d92 <end_op>
    return -1;
801064ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f3:	e9 e7 00 00 00       	jmp    801065df <sys_link+0x17f>
  }

  ip->nlink++;
801064f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fb:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064ff:	8d 50 01             	lea    0x1(%eax),%edx
80106502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106505:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650c:	89 04 24             	mov    %eax,(%esp)
8010650f:	e8 1f ba ff ff       	call   80101f33 <iupdate>
  iunlock(ip);
80106514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106517:	89 04 24             	mov    %eax,(%esp)
8010651a:	e8 2a bd ff ff       	call   80102249 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010651f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106522:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106525:	89 54 24 04          	mov    %edx,0x4(%esp)
80106529:	89 04 24             	mov    %eax,(%esp)
8010652c:	e8 8e c7 ff ff       	call   80102cbf <nameiparent>
80106531:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106534:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106538:	74 68                	je     801065a2 <sys_link+0x142>
    goto bad;
  ilock(dp);
8010653a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653d:	89 04 24             	mov    %eax,(%esp)
80106540:	e8 b0 bb ff ff       	call   801020f5 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106548:	8b 10                	mov    (%eax),%edx
8010654a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654d:	8b 00                	mov    (%eax),%eax
8010654f:	39 c2                	cmp    %eax,%edx
80106551:	75 20                	jne    80106573 <sys_link+0x113>
80106553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106556:	8b 40 04             	mov    0x4(%eax),%eax
80106559:	89 44 24 08          	mov    %eax,0x8(%esp)
8010655d:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106560:	89 44 24 04          	mov    %eax,0x4(%esp)
80106564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106567:	89 04 24             	mov    %eax,(%esp)
8010656a:	e8 6d c4 ff ff       	call   801029dc <dirlink>
8010656f:	85 c0                	test   %eax,%eax
80106571:	79 0d                	jns    80106580 <sys_link+0x120>
    iunlockput(dp);
80106573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106576:	89 04 24             	mov    %eax,(%esp)
80106579:	e8 01 be ff ff       	call   8010237f <iunlockput>
    goto bad;
8010657e:	eb 23                	jmp    801065a3 <sys_link+0x143>
  }
  iunlockput(dp);
80106580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106583:	89 04 24             	mov    %eax,(%esp)
80106586:	e8 f4 bd ff ff       	call   8010237f <iunlockput>
  iput(ip);
8010658b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658e:	89 04 24             	mov    %eax,(%esp)
80106591:	e8 18 bd ff ff       	call   801022ae <iput>

  end_op();
80106596:	e8 f7 d7 ff ff       	call   80103d92 <end_op>

  return 0;
8010659b:	b8 00 00 00 00       	mov    $0x0,%eax
801065a0:	eb 3d                	jmp    801065df <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801065a2:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801065a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a6:	89 04 24             	mov    %eax,(%esp)
801065a9:	e8 47 bb ff ff       	call   801020f5 <ilock>
  ip->nlink--;
801065ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801065b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bb:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801065bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c2:	89 04 24             	mov    %eax,(%esp)
801065c5:	e8 69 b9 ff ff       	call   80101f33 <iupdate>
  iunlockput(ip);
801065ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cd:	89 04 24             	mov    %eax,(%esp)
801065d0:	e8 aa bd ff ff       	call   8010237f <iunlockput>
  end_op();
801065d5:	e8 b8 d7 ff ff       	call   80103d92 <end_op>
  return -1;
801065da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065df:	c9                   	leave  
801065e0:	c3                   	ret    

801065e1 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801065e1:	55                   	push   %ebp
801065e2:	89 e5                	mov    %esp,%ebp
801065e4:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801065e7:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801065ee:	eb 4b                	jmp    8010663b <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801065fa:	00 
801065fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801065ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106602:	89 44 24 04          	mov    %eax,0x4(%esp)
80106606:	8b 45 08             	mov    0x8(%ebp),%eax
80106609:	89 04 24             	mov    %eax,(%esp)
8010660c:	e8 e0 bf ff ff       	call   801025f1 <readi>
80106611:	83 f8 10             	cmp    $0x10,%eax
80106614:	74 0c                	je     80106622 <isdirempty+0x41>
      panic("isdirempty: readi");
80106616:	c7 04 24 d3 95 10 80 	movl   $0x801095d3,(%esp)
8010661d:	e8 1b 9f ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80106622:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106626:	66 85 c0             	test   %ax,%ax
80106629:	74 07                	je     80106632 <isdirempty+0x51>
      return 0;
8010662b:	b8 00 00 00 00       	mov    $0x0,%eax
80106630:	eb 1b                	jmp    8010664d <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106635:	83 c0 10             	add    $0x10,%eax
80106638:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010663b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010663e:	8b 45 08             	mov    0x8(%ebp),%eax
80106641:	8b 40 18             	mov    0x18(%eax),%eax
80106644:	39 c2                	cmp    %eax,%edx
80106646:	72 a8                	jb     801065f0 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106648:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010664d:	c9                   	leave  
8010664e:	c3                   	ret    

8010664f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010664f:	55                   	push   %ebp
80106650:	89 e5                	mov    %esp,%ebp
80106652:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106655:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106658:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106663:	e8 72 fa ff ff       	call   801060da <argstr>
80106668:	85 c0                	test   %eax,%eax
8010666a:	79 0a                	jns    80106676 <sys_unlink+0x27>
    return -1;
8010666c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106671:	e9 af 01 00 00       	jmp    80106825 <sys_unlink+0x1d6>

  begin_op();
80106676:	e8 96 d6 ff ff       	call   80103d11 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010667b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010667e:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106681:	89 54 24 04          	mov    %edx,0x4(%esp)
80106685:	89 04 24             	mov    %eax,(%esp)
80106688:	e8 32 c6 ff ff       	call   80102cbf <nameiparent>
8010668d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106690:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106694:	75 0f                	jne    801066a5 <sys_unlink+0x56>
    end_op();
80106696:	e8 f7 d6 ff ff       	call   80103d92 <end_op>
    return -1;
8010669b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a0:	e9 80 01 00 00       	jmp    80106825 <sys_unlink+0x1d6>
  }

  ilock(dp);
801066a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a8:	89 04 24             	mov    %eax,(%esp)
801066ab:	e8 45 ba ff ff       	call   801020f5 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801066b0:	c7 44 24 04 e5 95 10 	movl   $0x801095e5,0x4(%esp)
801066b7:	80 
801066b8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066bb:	89 04 24             	mov    %eax,(%esp)
801066be:	e8 2f c2 ff ff       	call   801028f2 <namecmp>
801066c3:	85 c0                	test   %eax,%eax
801066c5:	0f 84 45 01 00 00    	je     80106810 <sys_unlink+0x1c1>
801066cb:	c7 44 24 04 e7 95 10 	movl   $0x801095e7,0x4(%esp)
801066d2:	80 
801066d3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066d6:	89 04 24             	mov    %eax,(%esp)
801066d9:	e8 14 c2 ff ff       	call   801028f2 <namecmp>
801066de:	85 c0                	test   %eax,%eax
801066e0:	0f 84 2a 01 00 00    	je     80106810 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801066e6:	8d 45 c8             	lea    -0x38(%ebp),%eax
801066e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801066ed:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801066f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f7:	89 04 24             	mov    %eax,(%esp)
801066fa:	e8 15 c2 ff ff       	call   80102914 <dirlookup>
801066ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106702:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106706:	0f 84 03 01 00 00    	je     8010680f <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
8010670c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670f:	89 04 24             	mov    %eax,(%esp)
80106712:	e8 de b9 ff ff       	call   801020f5 <ilock>

  if(ip->nlink < 1)
80106717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010671a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010671e:	66 85 c0             	test   %ax,%ax
80106721:	7f 0c                	jg     8010672f <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80106723:	c7 04 24 ea 95 10 80 	movl   $0x801095ea,(%esp)
8010672a:	e8 0e 9e ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106732:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106736:	66 83 f8 01          	cmp    $0x1,%ax
8010673a:	75 1f                	jne    8010675b <sys_unlink+0x10c>
8010673c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673f:	89 04 24             	mov    %eax,(%esp)
80106742:	e8 9a fe ff ff       	call   801065e1 <isdirempty>
80106747:	85 c0                	test   %eax,%eax
80106749:	75 10                	jne    8010675b <sys_unlink+0x10c>
    iunlockput(ip);
8010674b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674e:	89 04 24             	mov    %eax,(%esp)
80106751:	e8 29 bc ff ff       	call   8010237f <iunlockput>
    goto bad;
80106756:	e9 b5 00 00 00       	jmp    80106810 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
8010675b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106762:	00 
80106763:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010676a:	00 
8010676b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010676e:	89 04 24             	mov    %eax,(%esp)
80106771:	e8 78 f5 ff ff       	call   80105cee <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106776:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106779:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106780:	00 
80106781:	89 44 24 08          	mov    %eax,0x8(%esp)
80106785:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106788:	89 44 24 04          	mov    %eax,0x4(%esp)
8010678c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678f:	89 04 24             	mov    %eax,(%esp)
80106792:	e8 c5 bf ff ff       	call   8010275c <writei>
80106797:	83 f8 10             	cmp    $0x10,%eax
8010679a:	74 0c                	je     801067a8 <sys_unlink+0x159>
    panic("unlink: writei");
8010679c:	c7 04 24 fc 95 10 80 	movl   $0x801095fc,(%esp)
801067a3:	e8 95 9d ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
801067a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067af:	66 83 f8 01          	cmp    $0x1,%ax
801067b3:	75 1c                	jne    801067d1 <sys_unlink+0x182>
    dp->nlink--;
801067b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067bc:	8d 50 ff             	lea    -0x1(%eax),%edx
801067bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801067c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c9:	89 04 24             	mov    %eax,(%esp)
801067cc:	e8 62 b7 ff ff       	call   80101f33 <iupdate>
  }
  iunlockput(dp);
801067d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d4:	89 04 24             	mov    %eax,(%esp)
801067d7:	e8 a3 bb ff ff       	call   8010237f <iunlockput>

  ip->nlink--;
801067dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067df:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067e3:	8d 50 ff             	lea    -0x1(%eax),%edx
801067e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801067ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f0:	89 04 24             	mov    %eax,(%esp)
801067f3:	e8 3b b7 ff ff       	call   80101f33 <iupdate>
  iunlockput(ip);
801067f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fb:	89 04 24             	mov    %eax,(%esp)
801067fe:	e8 7c bb ff ff       	call   8010237f <iunlockput>

  end_op();
80106803:	e8 8a d5 ff ff       	call   80103d92 <end_op>

  return 0;
80106808:	b8 00 00 00 00       	mov    $0x0,%eax
8010680d:	eb 16                	jmp    80106825 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010680f:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106813:	89 04 24             	mov    %eax,(%esp)
80106816:	e8 64 bb ff ff       	call   8010237f <iunlockput>
  end_op();
8010681b:	e8 72 d5 ff ff       	call   80103d92 <end_op>
  return -1;
80106820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106825:	c9                   	leave  
80106826:	c3                   	ret    

80106827 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106827:	55                   	push   %ebp
80106828:	89 e5                	mov    %esp,%ebp
8010682a:	83 ec 48             	sub    $0x48,%esp
8010682d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106830:	8b 55 10             	mov    0x10(%ebp),%edx
80106833:	8b 45 14             	mov    0x14(%ebp),%eax
80106836:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010683a:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010683e:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106842:	8d 45 de             	lea    -0x22(%ebp),%eax
80106845:	89 44 24 04          	mov    %eax,0x4(%esp)
80106849:	8b 45 08             	mov    0x8(%ebp),%eax
8010684c:	89 04 24             	mov    %eax,(%esp)
8010684f:	e8 6b c4 ff ff       	call   80102cbf <nameiparent>
80106854:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010685b:	75 0a                	jne    80106867 <create+0x40>
    return 0;
8010685d:	b8 00 00 00 00       	mov    $0x0,%eax
80106862:	e9 7e 01 00 00       	jmp    801069e5 <create+0x1be>
  ilock(dp);
80106867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686a:	89 04 24             	mov    %eax,(%esp)
8010686d:	e8 83 b8 ff ff       	call   801020f5 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106872:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106875:	89 44 24 08          	mov    %eax,0x8(%esp)
80106879:	8d 45 de             	lea    -0x22(%ebp),%eax
8010687c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106883:	89 04 24             	mov    %eax,(%esp)
80106886:	e8 89 c0 ff ff       	call   80102914 <dirlookup>
8010688b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010688e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106892:	74 47                	je     801068db <create+0xb4>
    iunlockput(dp);
80106894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106897:	89 04 24             	mov    %eax,(%esp)
8010689a:	e8 e0 ba ff ff       	call   8010237f <iunlockput>
    ilock(ip);
8010689f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068a2:	89 04 24             	mov    %eax,(%esp)
801068a5:	e8 4b b8 ff ff       	call   801020f5 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801068aa:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801068af:	75 15                	jne    801068c6 <create+0x9f>
801068b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068b8:	66 83 f8 02          	cmp    $0x2,%ax
801068bc:	75 08                	jne    801068c6 <create+0x9f>
      return ip;
801068be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c1:	e9 1f 01 00 00       	jmp    801069e5 <create+0x1be>
    iunlockput(ip);
801068c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c9:	89 04 24             	mov    %eax,(%esp)
801068cc:	e8 ae ba ff ff       	call   8010237f <iunlockput>
    return 0;
801068d1:	b8 00 00 00 00       	mov    $0x0,%eax
801068d6:	e9 0a 01 00 00       	jmp    801069e5 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801068db:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801068df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e2:	8b 00                	mov    (%eax),%eax
801068e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801068e8:	89 04 24             	mov    %eax,(%esp)
801068eb:	e8 70 b5 ff ff       	call   80101e60 <ialloc>
801068f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068f7:	75 0c                	jne    80106905 <create+0xde>
    panic("create: ialloc");
801068f9:	c7 04 24 0b 96 10 80 	movl   $0x8010960b,(%esp)
80106900:	e8 38 9c ff ff       	call   8010053d <panic>

  ilock(ip);
80106905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106908:	89 04 24             	mov    %eax,(%esp)
8010690b:	e8 e5 b7 ff ff       	call   801020f5 <ilock>
  ip->major = major;
80106910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106913:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106917:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010691b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010691e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106922:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106929:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010692f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106932:	89 04 24             	mov    %eax,(%esp)
80106935:	e8 f9 b5 ff ff       	call   80101f33 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010693a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010693f:	75 6a                	jne    801069ab <create+0x184>
    dp->nlink++;  // for ".."
80106941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106944:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106948:	8d 50 01             	lea    0x1(%eax),%edx
8010694b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694e:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106955:	89 04 24             	mov    %eax,(%esp)
80106958:	e8 d6 b5 ff ff       	call   80101f33 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010695d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106960:	8b 40 04             	mov    0x4(%eax),%eax
80106963:	89 44 24 08          	mov    %eax,0x8(%esp)
80106967:	c7 44 24 04 e5 95 10 	movl   $0x801095e5,0x4(%esp)
8010696e:	80 
8010696f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106972:	89 04 24             	mov    %eax,(%esp)
80106975:	e8 62 c0 ff ff       	call   801029dc <dirlink>
8010697a:	85 c0                	test   %eax,%eax
8010697c:	78 21                	js     8010699f <create+0x178>
8010697e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106981:	8b 40 04             	mov    0x4(%eax),%eax
80106984:	89 44 24 08          	mov    %eax,0x8(%esp)
80106988:	c7 44 24 04 e7 95 10 	movl   $0x801095e7,0x4(%esp)
8010698f:	80 
80106990:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106993:	89 04 24             	mov    %eax,(%esp)
80106996:	e8 41 c0 ff ff       	call   801029dc <dirlink>
8010699b:	85 c0                	test   %eax,%eax
8010699d:	79 0c                	jns    801069ab <create+0x184>
      panic("create dots");
8010699f:	c7 04 24 1a 96 10 80 	movl   $0x8010961a,(%esp)
801069a6:	e8 92 9b ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801069ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ae:	8b 40 04             	mov    0x4(%eax),%eax
801069b1:	89 44 24 08          	mov    %eax,0x8(%esp)
801069b5:	8d 45 de             	lea    -0x22(%ebp),%eax
801069b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801069bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069bf:	89 04 24             	mov    %eax,(%esp)
801069c2:	e8 15 c0 ff ff       	call   801029dc <dirlink>
801069c7:	85 c0                	test   %eax,%eax
801069c9:	79 0c                	jns    801069d7 <create+0x1b0>
    panic("create: dirlink");
801069cb:	c7 04 24 26 96 10 80 	movl   $0x80109626,(%esp)
801069d2:	e8 66 9b ff ff       	call   8010053d <panic>

  iunlockput(dp);
801069d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069da:	89 04 24             	mov    %eax,(%esp)
801069dd:	e8 9d b9 ff ff       	call   8010237f <iunlockput>

  return ip;
801069e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801069e5:	c9                   	leave  
801069e6:	c3                   	ret    

801069e7 <sys_open>:

int
sys_open(void)
{
801069e7:	55                   	push   %ebp
801069e8:	89 e5                	mov    %esp,%ebp
801069ea:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801069ed:	8d 45 e8             	lea    -0x18(%ebp),%eax
801069f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069fb:	e8 da f6 ff ff       	call   801060da <argstr>
80106a00:	85 c0                	test   %eax,%eax
80106a02:	78 17                	js     80106a1b <sys_open+0x34>
80106a04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a12:	e8 33 f6 ff ff       	call   8010604a <argint>
80106a17:	85 c0                	test   %eax,%eax
80106a19:	79 0a                	jns    80106a25 <sys_open+0x3e>
    return -1;
80106a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a20:	e9 5a 01 00 00       	jmp    80106b7f <sys_open+0x198>

  begin_op();
80106a25:	e8 e7 d2 ff ff       	call   80103d11 <begin_op>

  if(omode & O_CREATE){
80106a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a2d:	25 00 02 00 00       	and    $0x200,%eax
80106a32:	85 c0                	test   %eax,%eax
80106a34:	74 3b                	je     80106a71 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106a36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a39:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106a40:	00 
80106a41:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106a48:	00 
80106a49:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106a50:	00 
80106a51:	89 04 24             	mov    %eax,(%esp)
80106a54:	e8 ce fd ff ff       	call   80106827 <create>
80106a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106a5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a60:	75 6b                	jne    80106acd <sys_open+0xe6>
      end_op();
80106a62:	e8 2b d3 ff ff       	call   80103d92 <end_op>
      return -1;
80106a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6c:	e9 0e 01 00 00       	jmp    80106b7f <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80106a71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a74:	89 04 24             	mov    %eax,(%esp)
80106a77:	e8 21 c2 ff ff       	call   80102c9d <namei>
80106a7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a83:	75 0f                	jne    80106a94 <sys_open+0xad>
      end_op();
80106a85:	e8 08 d3 ff ff       	call   80103d92 <end_op>
      return -1;
80106a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8f:	e9 eb 00 00 00       	jmp    80106b7f <sys_open+0x198>
    }
    ilock(ip);
80106a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a97:	89 04 24             	mov    %eax,(%esp)
80106a9a:	e8 56 b6 ff ff       	call   801020f5 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106aa6:	66 83 f8 01          	cmp    $0x1,%ax
80106aaa:	75 21                	jne    80106acd <sys_open+0xe6>
80106aac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aaf:	85 c0                	test   %eax,%eax
80106ab1:	74 1a                	je     80106acd <sys_open+0xe6>
      iunlockput(ip);
80106ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab6:	89 04 24             	mov    %eax,(%esp)
80106ab9:	e8 c1 b8 ff ff       	call   8010237f <iunlockput>
      end_op();
80106abe:	e8 cf d2 ff ff       	call   80103d92 <end_op>
      return -1;
80106ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ac8:	e9 b2 00 00 00       	jmp    80106b7f <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106acd:	e8 76 ac ff ff       	call   80101748 <filealloc>
80106ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ad5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ad9:	74 14                	je     80106aef <sys_open+0x108>
80106adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ade:	89 04 24             	mov    %eax,(%esp)
80106ae1:	e8 2f f7 ff ff       	call   80106215 <fdalloc>
80106ae6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106ae9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106aed:	79 28                	jns    80106b17 <sys_open+0x130>
    if(f)
80106aef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106af3:	74 0b                	je     80106b00 <sys_open+0x119>
      fileclose(f);
80106af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af8:	89 04 24             	mov    %eax,(%esp)
80106afb:	e8 f0 ac ff ff       	call   801017f0 <fileclose>
    iunlockput(ip);
80106b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b03:	89 04 24             	mov    %eax,(%esp)
80106b06:	e8 74 b8 ff ff       	call   8010237f <iunlockput>
    end_op();
80106b0b:	e8 82 d2 ff ff       	call   80103d92 <end_op>
    return -1;
80106b10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b15:	eb 68                	jmp    80106b7f <sys_open+0x198>
  }
  iunlock(ip);
80106b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1a:	89 04 24             	mov    %eax,(%esp)
80106b1d:	e8 27 b7 ff ff       	call   80102249 <iunlock>
  end_op();
80106b22:	e8 6b d2 ff ff       	call   80103d92 <end_op>

  f->type = FD_INODE;
80106b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b2a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b36:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b3c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b46:	83 e0 01             	and    $0x1,%eax
80106b49:	85 c0                	test   %eax,%eax
80106b4b:	0f 94 c2             	sete   %dl
80106b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b51:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106b54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b57:	83 e0 01             	and    $0x1,%eax
80106b5a:	84 c0                	test   %al,%al
80106b5c:	75 0a                	jne    80106b68 <sys_open+0x181>
80106b5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b61:	83 e0 02             	and    $0x2,%eax
80106b64:	85 c0                	test   %eax,%eax
80106b66:	74 07                	je     80106b6f <sys_open+0x188>
80106b68:	b8 01 00 00 00       	mov    $0x1,%eax
80106b6d:	eb 05                	jmp    80106b74 <sys_open+0x18d>
80106b6f:	b8 00 00 00 00       	mov    $0x0,%eax
80106b74:	89 c2                	mov    %eax,%edx
80106b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b79:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106b7f:	c9                   	leave  
80106b80:	c3                   	ret    

80106b81 <sys_mkdir>:

int
sys_mkdir(void)
{
80106b81:	55                   	push   %ebp
80106b82:	89 e5                	mov    %esp,%ebp
80106b84:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106b87:	e8 85 d1 ff ff       	call   80103d11 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106b8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b9a:	e8 3b f5 ff ff       	call   801060da <argstr>
80106b9f:	85 c0                	test   %eax,%eax
80106ba1:	78 2c                	js     80106bcf <sys_mkdir+0x4e>
80106ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ba6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106bad:	00 
80106bae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106bb5:	00 
80106bb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106bbd:	00 
80106bbe:	89 04 24             	mov    %eax,(%esp)
80106bc1:	e8 61 fc ff ff       	call   80106827 <create>
80106bc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bcd:	75 0c                	jne    80106bdb <sys_mkdir+0x5a>
    end_op();
80106bcf:	e8 be d1 ff ff       	call   80103d92 <end_op>
    return -1;
80106bd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bd9:	eb 15                	jmp    80106bf0 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bde:	89 04 24             	mov    %eax,(%esp)
80106be1:	e8 99 b7 ff ff       	call   8010237f <iunlockput>
  end_op();
80106be6:	e8 a7 d1 ff ff       	call   80103d92 <end_op>
  return 0;
80106beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bf0:	c9                   	leave  
80106bf1:	c3                   	ret    

80106bf2 <sys_mknod>:

int
sys_mknod(void)
{
80106bf2:	55                   	push   %ebp
80106bf3:	89 e5                	mov    %esp,%ebp
80106bf5:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106bf8:	e8 14 d1 ff ff       	call   80103d11 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106bfd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106c00:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c0b:	e8 ca f4 ff ff       	call   801060da <argstr>
80106c10:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c13:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c17:	78 5e                	js     80106c77 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106c19:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c27:	e8 1e f4 ff ff       	call   8010604a <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106c2c:	85 c0                	test   %eax,%eax
80106c2e:	78 47                	js     80106c77 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106c30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106c33:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c37:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106c3e:	e8 07 f4 ff ff       	call   8010604a <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106c43:	85 c0                	test   %eax,%eax
80106c45:	78 30                	js     80106c77 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c4a:	0f bf c8             	movswl %ax,%ecx
80106c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c50:	0f bf d0             	movswl %ax,%edx
80106c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106c56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c5a:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c5e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c65:	00 
80106c66:	89 04 24             	mov    %eax,(%esp)
80106c69:	e8 b9 fb ff ff       	call   80106827 <create>
80106c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c75:	75 0c                	jne    80106c83 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106c77:	e8 16 d1 ff ff       	call   80103d92 <end_op>
    return -1;
80106c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c81:	eb 15                	jmp    80106c98 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c86:	89 04 24             	mov    %eax,(%esp)
80106c89:	e8 f1 b6 ff ff       	call   8010237f <iunlockput>
  end_op();
80106c8e:	e8 ff d0 ff ff       	call   80103d92 <end_op>
  return 0;
80106c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c98:	c9                   	leave  
80106c99:	c3                   	ret    

80106c9a <sys_chdir>:

int
sys_chdir(void)
{
80106c9a:	55                   	push   %ebp
80106c9b:	89 e5                	mov    %esp,%ebp
80106c9d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106ca0:	e8 6c d0 ff ff       	call   80103d11 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106ca5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cb3:	e8 22 f4 ff ff       	call   801060da <argstr>
80106cb8:	85 c0                	test   %eax,%eax
80106cba:	78 14                	js     80106cd0 <sys_chdir+0x36>
80106cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cbf:	89 04 24             	mov    %eax,(%esp)
80106cc2:	e8 d6 bf ff ff       	call   80102c9d <namei>
80106cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cce:	75 0c                	jne    80106cdc <sys_chdir+0x42>
    end_op();
80106cd0:	e8 bd d0 ff ff       	call   80103d92 <end_op>
    return -1;
80106cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cda:	eb 61                	jmp    80106d3d <sys_chdir+0xa3>
  }
  ilock(ip);
80106cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cdf:	89 04 24             	mov    %eax,(%esp)
80106ce2:	e8 0e b4 ff ff       	call   801020f5 <ilock>
  if(ip->type != T_DIR){
80106ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cea:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106cee:	66 83 f8 01          	cmp    $0x1,%ax
80106cf2:	74 17                	je     80106d0b <sys_chdir+0x71>
    iunlockput(ip);
80106cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cf7:	89 04 24             	mov    %eax,(%esp)
80106cfa:	e8 80 b6 ff ff       	call   8010237f <iunlockput>
    end_op();
80106cff:	e8 8e d0 ff ff       	call   80103d92 <end_op>
    return -1;
80106d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d09:	eb 32                	jmp    80106d3d <sys_chdir+0xa3>
  }
  iunlock(ip);
80106d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d0e:	89 04 24             	mov    %eax,(%esp)
80106d11:	e8 33 b5 ff ff       	call   80102249 <iunlock>
  iput(proc->cwd);
80106d16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d1c:	8b 40 68             	mov    0x68(%eax),%eax
80106d1f:	89 04 24             	mov    %eax,(%esp)
80106d22:	e8 87 b5 ff ff       	call   801022ae <iput>
  end_op();
80106d27:	e8 66 d0 ff ff       	call   80103d92 <end_op>
  proc->cwd = ip;
80106d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d35:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d3d:	c9                   	leave  
80106d3e:	c3                   	ret    

80106d3f <sys_exec>:

int
sys_exec(void)
{
80106d3f:	55                   	push   %ebp
80106d40:	89 e5                	mov    %esp,%ebp
80106d42:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106d48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d56:	e8 7f f3 ff ff       	call   801060da <argstr>
80106d5b:	85 c0                	test   %eax,%eax
80106d5d:	78 1a                	js     80106d79 <sys_exec+0x3a>
80106d5f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106d65:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d70:	e8 d5 f2 ff ff       	call   8010604a <argint>
80106d75:	85 c0                	test   %eax,%eax
80106d77:	79 0a                	jns    80106d83 <sys_exec+0x44>
    return -1;
80106d79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d7e:	e9 cc 00 00 00       	jmp    80106e4f <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80106d83:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106d8a:	00 
80106d8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d92:	00 
80106d93:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106d99:	89 04 24             	mov    %eax,(%esp)
80106d9c:	e8 4d ef ff ff       	call   80105cee <memset>
  for(i=0;; i++){
80106da1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dab:	83 f8 1f             	cmp    $0x1f,%eax
80106dae:	76 0a                	jbe    80106dba <sys_exec+0x7b>
      return -1;
80106db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db5:	e9 95 00 00 00       	jmp    80106e4f <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dbd:	c1 e0 02             	shl    $0x2,%eax
80106dc0:	89 c2                	mov    %eax,%edx
80106dc2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106dc8:	01 c2                	add    %eax,%edx
80106dca:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dd4:	89 14 24             	mov    %edx,(%esp)
80106dd7:	e8 d0 f1 ff ff       	call   80105fac <fetchint>
80106ddc:	85 c0                	test   %eax,%eax
80106dde:	79 07                	jns    80106de7 <sys_exec+0xa8>
      return -1;
80106de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106de5:	eb 68                	jmp    80106e4f <sys_exec+0x110>
    if(uarg == 0){
80106de7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ded:	85 c0                	test   %eax,%eax
80106def:	75 26                	jne    80106e17 <sys_exec+0xd8>
      argv[i] = 0;
80106df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df4:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106dfb:	00 00 00 00 
      break;
80106dff:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e03:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106e09:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e0d:	89 04 24             	mov    %eax,(%esp)
80106e10:	e8 07 a5 ff ff       	call   8010131c <exec>
80106e15:	eb 38                	jmp    80106e4f <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e21:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e27:	01 c2                	add    %eax,%edx
80106e29:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106e2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e33:	89 04 24             	mov    %eax,(%esp)
80106e36:	e8 ab f1 ff ff       	call   80105fe6 <fetchstr>
80106e3b:	85 c0                	test   %eax,%eax
80106e3d:	79 07                	jns    80106e46 <sys_exec+0x107>
      return -1;
80106e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e44:	eb 09                	jmp    80106e4f <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106e46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106e4a:	e9 59 ff ff ff       	jmp    80106da8 <sys_exec+0x69>
  return exec(path, argv);
}
80106e4f:	c9                   	leave  
80106e50:	c3                   	ret    

80106e51 <sys_pipe>:

int
sys_pipe(void)
{
80106e51:	55                   	push   %ebp
80106e52:	89 e5                	mov    %esp,%ebp
80106e54:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106e57:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106e5e:	00 
80106e5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e62:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e6d:	e8 06 f2 ff ff       	call   80106078 <argptr>
80106e72:	85 c0                	test   %eax,%eax
80106e74:	79 0a                	jns    80106e80 <sys_pipe+0x2f>
    return -1;
80106e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e7b:	e9 9b 00 00 00       	jmp    80106f1b <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106e80:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e83:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e87:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e8a:	89 04 24             	mov    %eax,(%esp)
80106e8d:	e8 aa d9 ff ff       	call   8010483c <pipealloc>
80106e92:	85 c0                	test   %eax,%eax
80106e94:	79 07                	jns    80106e9d <sys_pipe+0x4c>
    return -1;
80106e96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e9b:	eb 7e                	jmp    80106f1b <sys_pipe+0xca>
  fd0 = -1;
80106e9d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106ea4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ea7:	89 04 24             	mov    %eax,(%esp)
80106eaa:	e8 66 f3 ff ff       	call   80106215 <fdalloc>
80106eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106eb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106eb6:	78 14                	js     80106ecc <sys_pipe+0x7b>
80106eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ebb:	89 04 24             	mov    %eax,(%esp)
80106ebe:	e8 52 f3 ff ff       	call   80106215 <fdalloc>
80106ec3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ec6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106eca:	79 37                	jns    80106f03 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106ecc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ed0:	78 14                	js     80106ee6 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106edb:	83 c2 08             	add    $0x8,%edx
80106ede:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106ee5:	00 
    fileclose(rf);
80106ee6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ee9:	89 04 24             	mov    %eax,(%esp)
80106eec:	e8 ff a8 ff ff       	call   801017f0 <fileclose>
    fileclose(wf);
80106ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ef4:	89 04 24             	mov    %eax,(%esp)
80106ef7:	e8 f4 a8 ff ff       	call   801017f0 <fileclose>
    return -1;
80106efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f01:	eb 18                	jmp    80106f1b <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f09:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106f0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f0e:	8d 50 04             	lea    0x4(%eax),%edx
80106f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f14:	89 02                	mov    %eax,(%edx)
  return 0;
80106f16:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f1b:	c9                   	leave  
80106f1c:	c3                   	ret    
80106f1d:	00 00                	add    %al,(%eax)
	...

80106f20 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106f20:	55                   	push   %ebp
80106f21:	89 e5                	mov    %esp,%ebp
80106f23:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106f26:	e8 d4 df ff ff       	call   80104eff <fork>
}
80106f2b:	c9                   	leave  
80106f2c:	c3                   	ret    

80106f2d <sys_exit>:

int
sys_exit(void)
{
80106f2d:	55                   	push   %ebp
80106f2e:	89 e5                	mov    %esp,%ebp
80106f30:	83 ec 08             	sub    $0x8,%esp
  exit();
80106f33:	e8 7e e1 ff ff       	call   801050b6 <exit>
  return 0;  // not reached
80106f38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f3d:	c9                   	leave  
80106f3e:	c3                   	ret    

80106f3f <sys_wait>:

int
sys_wait(void)
{
80106f3f:	55                   	push   %ebp
80106f40:	89 e5                	mov    %esp,%ebp
80106f42:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106f45:	e8 91 e2 ff ff       	call   801051db <wait>
}
80106f4a:	c9                   	leave  
80106f4b:	c3                   	ret    

80106f4c <sys_kill>:

int
sys_kill(void)
{
80106f4c:	55                   	push   %ebp
80106f4d:	89 e5                	mov    %esp,%ebp
80106f4f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f55:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f60:	e8 e5 f0 ff ff       	call   8010604a <argint>
80106f65:	85 c0                	test   %eax,%eax
80106f67:	79 07                	jns    80106f70 <sys_kill+0x24>
    return -1;
80106f69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f6e:	eb 0b                	jmp    80106f7b <sys_kill+0x2f>
  return kill(pid);
80106f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f73:	89 04 24             	mov    %eax,(%esp)
80106f76:	e8 3b e8 ff ff       	call   801057b6 <kill>
}
80106f7b:	c9                   	leave  
80106f7c:	c3                   	ret    

80106f7d <sys_getpid>:

int
sys_getpid(void)
{
80106f7d:	55                   	push   %ebp
80106f7e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106f80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f86:	8b 40 10             	mov    0x10(%eax),%eax
}
80106f89:	5d                   	pop    %ebp
80106f8a:	c3                   	ret    

80106f8b <sys_sbrk>:

int
sys_sbrk(void)
{
80106f8b:	55                   	push   %ebp
80106f8c:	89 e5                	mov    %esp,%ebp
80106f8e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106f91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f94:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f9f:	e8 a6 f0 ff ff       	call   8010604a <argint>
80106fa4:	85 c0                	test   %eax,%eax
80106fa6:	79 07                	jns    80106faf <sys_sbrk+0x24>
    return -1;
80106fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fad:	eb 24                	jmp    80106fd3 <sys_sbrk+0x48>
  addr = proc->sz;
80106faf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fb5:	8b 00                	mov    (%eax),%eax
80106fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fbd:	89 04 24             	mov    %eax,(%esp)
80106fc0:	e8 95 de ff ff       	call   80104e5a <growproc>
80106fc5:	85 c0                	test   %eax,%eax
80106fc7:	79 07                	jns    80106fd0 <sys_sbrk+0x45>
    return -1;
80106fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fce:	eb 03                	jmp    80106fd3 <sys_sbrk+0x48>
  return addr;
80106fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106fd3:	c9                   	leave  
80106fd4:	c3                   	ret    

80106fd5 <sys_sleep>:

int
sys_sleep(void)
{
80106fd5:	55                   	push   %ebp
80106fd6:	89 e5                	mov    %esp,%ebp
80106fd8:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106fdb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fde:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fe2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fe9:	e8 5c f0 ff ff       	call   8010604a <argint>
80106fee:	85 c0                	test   %eax,%eax
80106ff0:	79 07                	jns    80106ff9 <sys_sleep+0x24>
    return -1;
80106ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff7:	eb 6c                	jmp    80107065 <sys_sleep+0x90>
  acquire(&tickslock);
80106ff9:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107000:	e8 9a ea ff ff       	call   80105a9f <acquire>
  ticks0 = ticks;
80107005:	a1 20 6e 11 80       	mov    0x80116e20,%eax
8010700a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010700d:	eb 34                	jmp    80107043 <sys_sleep+0x6e>
    if(proc->killed){
8010700f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107015:	8b 40 24             	mov    0x24(%eax),%eax
80107018:	85 c0                	test   %eax,%eax
8010701a:	74 13                	je     8010702f <sys_sleep+0x5a>
      release(&tickslock);
8010701c:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107023:	e8 d9 ea ff ff       	call   80105b01 <release>
      return -1;
80107028:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010702d:	eb 36                	jmp    80107065 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010702f:	c7 44 24 04 e0 65 11 	movl   $0x801165e0,0x4(%esp)
80107036:	80 
80107037:	c7 04 24 20 6e 11 80 	movl   $0x80116e20,(%esp)
8010703e:	e8 6c e6 ff ff       	call   801056af <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107043:	a1 20 6e 11 80       	mov    0x80116e20,%eax
80107048:	89 c2                	mov    %eax,%edx
8010704a:	2b 55 f4             	sub    -0xc(%ebp),%edx
8010704d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107050:	39 c2                	cmp    %eax,%edx
80107052:	72 bb                	jb     8010700f <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107054:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
8010705b:	e8 a1 ea ff ff       	call   80105b01 <release>
  return 0;
80107060:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107065:	c9                   	leave  
80107066:	c3                   	ret    

80107067 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107067:	55                   	push   %ebp
80107068:	89 e5                	mov    %esp,%ebp
8010706a:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010706d:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107074:	e8 26 ea ff ff       	call   80105a9f <acquire>
  xticks = ticks;
80107079:	a1 20 6e 11 80       	mov    0x80116e20,%eax
8010707e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107081:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107088:	e8 74 ea ff ff       	call   80105b01 <release>
  return xticks;
8010708d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107090:	c9                   	leave  
80107091:	c3                   	ret    

80107092 <sys_wait2>:

int
sys_wait2(void)
{
80107092:	55                   	push   %ebp
80107093:	89 e5                	mov    %esp,%ebp
80107095:	83 ec 28             	sub    $0x28,%esp
  int retime;
  int rutime;
  int stime;
  if(argint(0,&retime) < 0)
80107098:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010709b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010709f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070a6:	e8 9f ef ff ff       	call   8010604a <argint>
801070ab:	85 c0                	test   %eax,%eax
801070ad:	79 07                	jns    801070b6 <sys_wait2+0x24>
    return -1;
801070af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b4:	eb 59                	jmp    8010710f <sys_wait2+0x7d>
  if(argint(1,&rutime) < 0)
801070b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801070bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801070c4:	e8 81 ef ff ff       	call   8010604a <argint>
801070c9:	85 c0                	test   %eax,%eax
801070cb:	79 07                	jns    801070d4 <sys_wait2+0x42>
    return -1;
801070cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d2:	eb 3b                	jmp    8010710f <sys_wait2+0x7d>
  if(argint(2,&stime) < 0)
801070d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801070db:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801070e2:	e8 63 ef ff ff       	call   8010604a <argint>
801070e7:	85 c0                	test   %eax,%eax
801070e9:	79 07                	jns    801070f2 <sys_wait2+0x60>
    return -1;
801070eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f0:	eb 1d                	jmp    8010710f <sys_wait2+0x7d>
  return wait2((int*)retime, (int*)rutime, (int*)stime);
801070f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070f5:	89 c1                	mov    %eax,%ecx
801070f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070fa:	89 c2                	mov    %eax,%edx
801070fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107103:	89 54 24 04          	mov    %edx,0x4(%esp)
80107107:	89 04 24             	mov    %eax,(%esp)
8010710a:	e8 7f e8 ff ff       	call   8010598e <wait2>
}
8010710f:	c9                   	leave  
80107110:	c3                   	ret    

80107111 <sys_set_prio>:


int
sys_set_prio(void)
{
80107111:	55                   	push   %ebp
80107112:	89 e5                	mov    %esp,%ebp
80107114:	83 ec 28             	sub    $0x28,%esp
  int priority;
  if (argint(0,&priority) <0)
80107117:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010711a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010711e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107125:	e8 20 ef ff ff       	call   8010604a <argint>
8010712a:	85 c0                	test   %eax,%eax
8010712c:	79 07                	jns    80107135 <sys_set_prio+0x24>
    return -1;
8010712e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107133:	eb 0b                	jmp    80107140 <sys_set_prio+0x2f>
  return set_prio(priority);
80107135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107138:	89 04 24             	mov    %eax,(%esp)
8010713b:	e8 c3 e8 ff ff       	call   80105a03 <set_prio>
}
80107140:	c9                   	leave  
80107141:	c3                   	ret    

80107142 <sys_yield>:

int
sys_yield(void)
{
80107142:	55                   	push   %ebp
80107143:	89 e5                	mov    %esp,%ebp
80107145:	83 ec 08             	sub    $0x8,%esp
  yield();
80107148:	e8 f1 e4 ff ff       	call   8010563e <yield>
  return 0;
8010714d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107152:	c9                   	leave  
80107153:	c3                   	ret    

80107154 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107154:	55                   	push   %ebp
80107155:	89 e5                	mov    %esp,%ebp
80107157:	83 ec 08             	sub    $0x8,%esp
8010715a:	8b 55 08             	mov    0x8(%ebp),%edx
8010715d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107160:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107164:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107167:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010716b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010716f:	ee                   	out    %al,(%dx)
}
80107170:	c9                   	leave  
80107171:	c3                   	ret    

80107172 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107172:	55                   	push   %ebp
80107173:	89 e5                	mov    %esp,%ebp
80107175:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107178:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010717f:	00 
80107180:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80107187:	e8 c8 ff ff ff       	call   80107154 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010718c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80107193:	00 
80107194:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010719b:	e8 b4 ff ff ff       	call   80107154 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801071a0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801071a7:	00 
801071a8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801071af:	e8 a0 ff ff ff       	call   80107154 <outb>
  picenable(IRQ_TIMER);
801071b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071bb:	e8 05 d5 ff ff       	call   801046c5 <picenable>
}
801071c0:	c9                   	leave  
801071c1:	c3                   	ret    
	...

801071c4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801071c4:	1e                   	push   %ds
  pushl %es
801071c5:	06                   	push   %es
  pushl %fs
801071c6:	0f a0                	push   %fs
  pushl %gs
801071c8:	0f a8                	push   %gs
  pushal
801071ca:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801071cb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801071cf:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801071d1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801071d3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801071d7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801071d9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801071db:	54                   	push   %esp
  call trap
801071dc:	e8 de 01 00 00       	call   801073bf <trap>
  addl $4, %esp
801071e1:	83 c4 04             	add    $0x4,%esp

801071e4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801071e4:	61                   	popa   
  popl %gs
801071e5:	0f a9                	pop    %gs
  popl %fs
801071e7:	0f a1                	pop    %fs
  popl %es
801071e9:	07                   	pop    %es
  popl %ds
801071ea:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801071eb:	83 c4 08             	add    $0x8,%esp
  iret
801071ee:	cf                   	iret   
	...

801071f0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071f0:	55                   	push   %ebp
801071f1:	89 e5                	mov    %esp,%ebp
801071f3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801071f9:	83 e8 01             	sub    $0x1,%eax
801071fc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107200:	8b 45 08             	mov    0x8(%ebp),%eax
80107203:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107207:	8b 45 08             	mov    0x8(%ebp),%eax
8010720a:	c1 e8 10             	shr    $0x10,%eax
8010720d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107211:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107214:	0f 01 18             	lidtl  (%eax)
}
80107217:	c9                   	leave  
80107218:	c3                   	ret    

80107219 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107219:	55                   	push   %ebp
8010721a:	89 e5                	mov    %esp,%ebp
8010721c:	53                   	push   %ebx
8010721d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107220:	0f 20 d3             	mov    %cr2,%ebx
80107223:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80107226:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80107229:	83 c4 10             	add    $0x10,%esp
8010722c:	5b                   	pop    %ebx
8010722d:	5d                   	pop    %ebp
8010722e:	c3                   	ret    

8010722f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010722f:	55                   	push   %ebp
80107230:	89 e5                	mov    %esp,%ebp
80107232:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010723c:	e9 c3 00 00 00       	jmp    80107304 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107244:	8b 04 85 a4 c0 10 80 	mov    -0x7fef3f5c(,%eax,4),%eax
8010724b:	89 c2                	mov    %eax,%edx
8010724d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107250:	66 89 14 c5 20 66 11 	mov    %dx,-0x7fee99e0(,%eax,8)
80107257:	80 
80107258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725b:	66 c7 04 c5 22 66 11 	movw   $0x8,-0x7fee99de(,%eax,8)
80107262:	80 08 00 
80107265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107268:	0f b6 14 c5 24 66 11 	movzbl -0x7fee99dc(,%eax,8),%edx
8010726f:	80 
80107270:	83 e2 e0             	and    $0xffffffe0,%edx
80107273:	88 14 c5 24 66 11 80 	mov    %dl,-0x7fee99dc(,%eax,8)
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727d:	0f b6 14 c5 24 66 11 	movzbl -0x7fee99dc(,%eax,8),%edx
80107284:	80 
80107285:	83 e2 1f             	and    $0x1f,%edx
80107288:	88 14 c5 24 66 11 80 	mov    %dl,-0x7fee99dc(,%eax,8)
8010728f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107292:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
80107299:	80 
8010729a:	83 e2 f0             	and    $0xfffffff0,%edx
8010729d:	83 ca 0e             	or     $0xe,%edx
801072a0:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801072a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072aa:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801072b1:	80 
801072b2:	83 e2 ef             	and    $0xffffffef,%edx
801072b5:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801072bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bf:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801072c6:	80 
801072c7:	83 e2 9f             	and    $0xffffff9f,%edx
801072ca:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801072d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d4:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801072db:	80 
801072dc:	83 ca 80             	or     $0xffffff80,%edx
801072df:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801072e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e9:	8b 04 85 a4 c0 10 80 	mov    -0x7fef3f5c(,%eax,4),%eax
801072f0:	c1 e8 10             	shr    $0x10,%eax
801072f3:	89 c2                	mov    %eax,%edx
801072f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f8:	66 89 14 c5 26 66 11 	mov    %dx,-0x7fee99da(,%eax,8)
801072ff:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107300:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107304:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010730b:	0f 8e 30 ff ff ff    	jle    80107241 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107311:	a1 a4 c1 10 80       	mov    0x8010c1a4,%eax
80107316:	66 a3 20 68 11 80    	mov    %ax,0x80116820
8010731c:	66 c7 05 22 68 11 80 	movw   $0x8,0x80116822
80107323:	08 00 
80107325:	0f b6 05 24 68 11 80 	movzbl 0x80116824,%eax
8010732c:	83 e0 e0             	and    $0xffffffe0,%eax
8010732f:	a2 24 68 11 80       	mov    %al,0x80116824
80107334:	0f b6 05 24 68 11 80 	movzbl 0x80116824,%eax
8010733b:	83 e0 1f             	and    $0x1f,%eax
8010733e:	a2 24 68 11 80       	mov    %al,0x80116824
80107343:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
8010734a:	83 c8 0f             	or     $0xf,%eax
8010734d:	a2 25 68 11 80       	mov    %al,0x80116825
80107352:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107359:	83 e0 ef             	and    $0xffffffef,%eax
8010735c:	a2 25 68 11 80       	mov    %al,0x80116825
80107361:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107368:	83 c8 60             	or     $0x60,%eax
8010736b:	a2 25 68 11 80       	mov    %al,0x80116825
80107370:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107377:	83 c8 80             	or     $0xffffff80,%eax
8010737a:	a2 25 68 11 80       	mov    %al,0x80116825
8010737f:	a1 a4 c1 10 80       	mov    0x8010c1a4,%eax
80107384:	c1 e8 10             	shr    $0x10,%eax
80107387:	66 a3 26 68 11 80    	mov    %ax,0x80116826

  initlock(&tickslock, "time");
8010738d:	c7 44 24 04 38 96 10 	movl   $0x80109638,0x4(%esp)
80107394:	80 
80107395:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
8010739c:	e8 dd e6 ff ff       	call   80105a7e <initlock>
}
801073a1:	c9                   	leave  
801073a2:	c3                   	ret    

801073a3 <idtinit>:

void
idtinit(void)
{
801073a3:	55                   	push   %ebp
801073a4:	89 e5                	mov    %esp,%ebp
801073a6:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801073a9:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801073b0:	00 
801073b1:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
801073b8:	e8 33 fe ff ff       	call   801071f0 <lidt>
}
801073bd:	c9                   	leave  
801073be:	c3                   	ret    

801073bf <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801073bf:	55                   	push   %ebp
801073c0:	89 e5                	mov    %esp,%ebp
801073c2:	57                   	push   %edi
801073c3:	56                   	push   %esi
801073c4:	53                   	push   %ebx
801073c5:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801073c8:	8b 45 08             	mov    0x8(%ebp),%eax
801073cb:	8b 40 30             	mov    0x30(%eax),%eax
801073ce:	83 f8 40             	cmp    $0x40,%eax
801073d1:	75 3e                	jne    80107411 <trap+0x52>
    if(proc->killed)
801073d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073d9:	8b 40 24             	mov    0x24(%eax),%eax
801073dc:	85 c0                	test   %eax,%eax
801073de:	74 05                	je     801073e5 <trap+0x26>
      exit();
801073e0:	e8 d1 dc ff ff       	call   801050b6 <exit>
    proc->tf = tf;
801073e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073eb:	8b 55 08             	mov    0x8(%ebp),%edx
801073ee:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801073f1:	e8 1b ed ff ff       	call   80106111 <syscall>
    if(proc->killed)
801073f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073fc:	8b 40 24             	mov    0x24(%eax),%eax
801073ff:	85 c0                	test   %eax,%eax
80107401:	0f 84 5a 02 00 00    	je     80107661 <trap+0x2a2>
      exit();
80107407:	e8 aa dc ff ff       	call   801050b6 <exit>
    return;
8010740c:	e9 50 02 00 00       	jmp    80107661 <trap+0x2a2>
  }

  switch(tf->trapno){
80107411:	8b 45 08             	mov    0x8(%ebp),%eax
80107414:	8b 40 30             	mov    0x30(%eax),%eax
80107417:	83 e8 20             	sub    $0x20,%eax
8010741a:	83 f8 1f             	cmp    $0x1f,%eax
8010741d:	0f 87 c1 00 00 00    	ja     801074e4 <trap+0x125>
80107423:	8b 04 85 e0 96 10 80 	mov    -0x7fef6920(,%eax,4),%eax
8010742a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010742c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107432:	0f b6 00             	movzbl (%eax),%eax
80107435:	84 c0                	test   %al,%al
80107437:	75 36                	jne    8010746f <trap+0xb0>
      acquire(&tickslock);
80107439:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107440:	e8 5a e6 ff ff       	call   80105a9f <acquire>
      ticks++;
80107445:	a1 20 6e 11 80       	mov    0x80116e20,%eax
8010744a:	83 c0 01             	add    $0x1,%eax
8010744d:	a3 20 6e 11 80       	mov    %eax,0x80116e20
      updateTimes(); // after every tick - updates the times
80107452:	e8 d6 e4 ff ff       	call   8010592d <updateTimes>
      wakeup(&ticks);
80107457:	c7 04 24 20 6e 11 80 	movl   $0x80116e20,(%esp)
8010745e:	e8 28 e3 ff ff       	call   8010578b <wakeup>
      release(&tickslock);
80107463:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
8010746a:	e8 92 e6 ff ff       	call   80105b01 <release>
    }
    lapiceoi();
8010746f:	e8 67 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107474:	e9 41 01 00 00       	jmp    801075ba <trap+0x1fb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107479:	e8 3e bb ff ff       	call   80102fbc <ideintr>
    lapiceoi();
8010747e:	e8 58 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107483:	e9 32 01 00 00       	jmp    801075ba <trap+0x1fb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107488:	e8 02 c1 ff ff       	call   8010358f <kbdintr>
    lapiceoi();
8010748d:	e8 49 c3 ff ff       	call   801037db <lapiceoi>
    break;
80107492:	e9 23 01 00 00       	jmp    801075ba <trap+0x1fb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107497:	e8 cc 03 00 00       	call   80107868 <uartintr>
    lapiceoi();
8010749c:	e8 3a c3 ff ff       	call   801037db <lapiceoi>
    break;
801074a1:	e9 14 01 00 00       	jmp    801075ba <trap+0x1fb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
801074a6:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074a9:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801074ac:	8b 45 08             	mov    0x8(%ebp),%eax
801074af:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074b3:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801074b6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801074bc:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074bf:	0f b6 c0             	movzbl %al,%eax
801074c2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801074c6:	89 54 24 08          	mov    %edx,0x8(%esp)
801074ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801074ce:	c7 04 24 40 96 10 80 	movl   $0x80109640,(%esp)
801074d5:	e8 c7 8e ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801074da:	e8 fc c2 ff ff       	call   801037db <lapiceoi>
    break;
801074df:	e9 d6 00 00 00       	jmp    801075ba <trap+0x1fb>

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801074e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074ea:	85 c0                	test   %eax,%eax
801074ec:	74 11                	je     801074ff <trap+0x140>
801074ee:	8b 45 08             	mov    0x8(%ebp),%eax
801074f1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801074f5:	0f b7 c0             	movzwl %ax,%eax
801074f8:	83 e0 03             	and    $0x3,%eax
801074fb:	85 c0                	test   %eax,%eax
801074fd:	75 46                	jne    80107545 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074ff:	e8 15 fd ff ff       	call   80107219 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80107504:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107507:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010750a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107511:	0f b6 12             	movzbl (%edx),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107514:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107517:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010751a:	8b 52 30             	mov    0x30(%edx),%edx
8010751d:	89 44 24 10          	mov    %eax,0x10(%esp)
80107521:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107525:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107529:	89 54 24 04          	mov    %edx,0x4(%esp)
8010752d:	c7 04 24 64 96 10 80 	movl   $0x80109664,(%esp)
80107534:	e8 68 8e ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107539:	c7 04 24 96 96 10 80 	movl   $0x80109696,(%esp)
80107540:	e8 f8 8f ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107545:	e8 cf fc ff ff       	call   80107219 <rcr2>
8010754a:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010754c:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010754f:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107558:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010755b:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010755e:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107561:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107564:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107567:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010756a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107570:	83 c0 6c             	add    $0x6c,%eax
80107573:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107576:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010757c:	8b 40 10             	mov    0x10(%eax),%eax
8010757f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80107583:	89 7c 24 18          	mov    %edi,0x18(%esp)
80107587:	89 74 24 14          	mov    %esi,0x14(%esp)
8010758b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010758f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107593:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107596:	89 54 24 08          	mov    %edx,0x8(%esp)
8010759a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010759e:	c7 04 24 9c 96 10 80 	movl   $0x8010969c,(%esp)
801075a5:	e8 f7 8d ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
801075aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075b0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801075b7:	eb 01                	jmp    801075ba <trap+0x1fb>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801075b9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801075ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075c0:	85 c0                	test   %eax,%eax
801075c2:	74 24                	je     801075e8 <trap+0x229>
801075c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075ca:	8b 40 24             	mov    0x24(%eax),%eax
801075cd:	85 c0                	test   %eax,%eax
801075cf:	74 17                	je     801075e8 <trap+0x229>
801075d1:	8b 45 08             	mov    0x8(%ebp),%eax
801075d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801075d8:	0f b7 c0             	movzwl %ax,%eax
801075db:	83 e0 03             	and    $0x3,%eax
801075de:	83 f8 03             	cmp    $0x3,%eax
801075e1:	75 05                	jne    801075e8 <trap+0x229>
    exit();
801075e3:	e8 ce da ff ff       	call   801050b6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && ticks%QUANTA==0){
801075e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075ee:	85 c0                	test   %eax,%eax
801075f0:	74 3f                	je     80107631 <trap+0x272>
801075f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f8:	8b 40 0c             	mov    0xc(%eax),%eax
801075fb:	83 f8 04             	cmp    $0x4,%eax
801075fe:	75 31                	jne    80107631 <trap+0x272>
80107600:	8b 45 08             	mov    0x8(%ebp),%eax
80107603:	8b 40 30             	mov    0x30(%eax),%eax
80107606:	83 f8 20             	cmp    $0x20,%eax
80107609:	75 26                	jne    80107631 <trap+0x272>
8010760b:	8b 0d 20 6e 11 80    	mov    0x80116e20,%ecx
80107611:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107616:	89 c8                	mov    %ecx,%eax
80107618:	f7 e2                	mul    %edx
8010761a:	c1 ea 02             	shr    $0x2,%edx
8010761d:	89 d0                	mov    %edx,%eax
8010761f:	c1 e0 02             	shl    $0x2,%eax
80107622:	01 d0                	add    %edx,%eax
80107624:	89 ca                	mov    %ecx,%edx
80107626:	29 c2                	sub    %eax,%edx
80107628:	85 d2                	test   %edx,%edx
8010762a:	75 05                	jne    80107631 <trap+0x272>
  #if SCHEDFLAG == DML
  proc->priority=(proc->priority==MIN_PRIORITY)? MIN_PRIORITY : proc->priority-1;
  #endif
  yield();
8010762c:	e8 0d e0 ff ff       	call   8010563e <yield>
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107631:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107637:	85 c0                	test   %eax,%eax
80107639:	74 27                	je     80107662 <trap+0x2a3>
8010763b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107641:	8b 40 24             	mov    0x24(%eax),%eax
80107644:	85 c0                	test   %eax,%eax
80107646:	74 1a                	je     80107662 <trap+0x2a3>
80107648:	8b 45 08             	mov    0x8(%ebp),%eax
8010764b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010764f:	0f b7 c0             	movzwl %ax,%eax
80107652:	83 e0 03             	and    $0x3,%eax
80107655:	83 f8 03             	cmp    $0x3,%eax
80107658:	75 08                	jne    80107662 <trap+0x2a3>
    exit();
8010765a:	e8 57 da ff ff       	call   801050b6 <exit>
8010765f:	eb 01                	jmp    80107662 <trap+0x2a3>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107661:	90                   	nop
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107662:	83 c4 3c             	add    $0x3c,%esp
80107665:	5b                   	pop    %ebx
80107666:	5e                   	pop    %esi
80107667:	5f                   	pop    %edi
80107668:	5d                   	pop    %ebp
80107669:	c3                   	ret    
	...

8010766c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010766c:	55                   	push   %ebp
8010766d:	89 e5                	mov    %esp,%ebp
8010766f:	53                   	push   %ebx
80107670:	83 ec 14             	sub    $0x14,%esp
80107673:	8b 45 08             	mov    0x8(%ebp),%eax
80107676:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010767a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010767e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80107682:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80107686:	ec                   	in     (%dx),%al
80107687:	89 c3                	mov    %eax,%ebx
80107689:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010768c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80107690:	83 c4 14             	add    $0x14,%esp
80107693:	5b                   	pop    %ebx
80107694:	5d                   	pop    %ebp
80107695:	c3                   	ret    

80107696 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107696:	55                   	push   %ebp
80107697:	89 e5                	mov    %esp,%ebp
80107699:	83 ec 08             	sub    $0x8,%esp
8010769c:	8b 55 08             	mov    0x8(%ebp),%edx
8010769f:	8b 45 0c             	mov    0xc(%ebp),%eax
801076a2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801076a6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801076a9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801076ad:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801076b1:	ee                   	out    %al,(%dx)
}
801076b2:	c9                   	leave  
801076b3:	c3                   	ret    

801076b4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801076b4:	55                   	push   %ebp
801076b5:	89 e5                	mov    %esp,%ebp
801076b7:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801076ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801076c1:	00 
801076c2:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801076c9:	e8 c8 ff ff ff       	call   80107696 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801076ce:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801076d5:	00 
801076d6:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801076dd:	e8 b4 ff ff ff       	call   80107696 <outb>
  outb(COM1+0, 115200/9600);
801076e2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801076e9:	00 
801076ea:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801076f1:	e8 a0 ff ff ff       	call   80107696 <outb>
  outb(COM1+1, 0);
801076f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801076fd:	00 
801076fe:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107705:	e8 8c ff ff ff       	call   80107696 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010770a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107711:	00 
80107712:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107719:	e8 78 ff ff ff       	call   80107696 <outb>
  outb(COM1+4, 0);
8010771e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107725:	00 
80107726:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010772d:	e8 64 ff ff ff       	call   80107696 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107732:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107739:	00 
8010773a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107741:	e8 50 ff ff ff       	call   80107696 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107746:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010774d:	e8 1a ff ff ff       	call   8010766c <inb>
80107752:	3c ff                	cmp    $0xff,%al
80107754:	74 6c                	je     801077c2 <uartinit+0x10e>
    return;
  uart = 1;
80107756:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
8010775d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107760:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107767:	e8 00 ff ff ff       	call   8010766c <inb>
  inb(COM1+0);
8010776c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107773:	e8 f4 fe ff ff       	call   8010766c <inb>
  picenable(IRQ_COM1);
80107778:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010777f:	e8 41 cf ff ff       	call   801046c5 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107784:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010778b:	00 
8010778c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107793:	e8 a6 ba ff ff       	call   8010323e <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107798:	c7 45 f4 60 97 10 80 	movl   $0x80109760,-0xc(%ebp)
8010779f:	eb 15                	jmp    801077b6 <uartinit+0x102>
    uartputc(*p);
801077a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a4:	0f b6 00             	movzbl (%eax),%eax
801077a7:	0f be c0             	movsbl %al,%eax
801077aa:	89 04 24             	mov    %eax,(%esp)
801077ad:	e8 13 00 00 00       	call   801077c5 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b9:	0f b6 00             	movzbl (%eax),%eax
801077bc:	84 c0                	test   %al,%al
801077be:	75 e1                	jne    801077a1 <uartinit+0xed>
801077c0:	eb 01                	jmp    801077c3 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801077c2:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801077c3:	c9                   	leave  
801077c4:	c3                   	ret    

801077c5 <uartputc>:

void
uartputc(int c)
{
801077c5:	55                   	push   %ebp
801077c6:	89 e5                	mov    %esp,%ebp
801077c8:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801077cb:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801077d0:	85 c0                	test   %eax,%eax
801077d2:	74 4d                	je     80107821 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801077db:	eb 10                	jmp    801077ed <uartputc+0x28>
    microdelay(10);
801077dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801077e4:	e8 17 c0 ff ff       	call   80103800 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077ed:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801077f1:	7f 16                	jg     80107809 <uartputc+0x44>
801077f3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801077fa:	e8 6d fe ff ff       	call   8010766c <inb>
801077ff:	0f b6 c0             	movzbl %al,%eax
80107802:	83 e0 20             	and    $0x20,%eax
80107805:	85 c0                	test   %eax,%eax
80107807:	74 d4                	je     801077dd <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107809:	8b 45 08             	mov    0x8(%ebp),%eax
8010780c:	0f b6 c0             	movzbl %al,%eax
8010780f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107813:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010781a:	e8 77 fe ff ff       	call   80107696 <outb>
8010781f:	eb 01                	jmp    80107822 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107821:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107822:	c9                   	leave  
80107823:	c3                   	ret    

80107824 <uartgetc>:

static int
uartgetc(void)
{
80107824:	55                   	push   %ebp
80107825:	89 e5                	mov    %esp,%ebp
80107827:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010782a:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010782f:	85 c0                	test   %eax,%eax
80107831:	75 07                	jne    8010783a <uartgetc+0x16>
    return -1;
80107833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107838:	eb 2c                	jmp    80107866 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010783a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107841:	e8 26 fe ff ff       	call   8010766c <inb>
80107846:	0f b6 c0             	movzbl %al,%eax
80107849:	83 e0 01             	and    $0x1,%eax
8010784c:	85 c0                	test   %eax,%eax
8010784e:	75 07                	jne    80107857 <uartgetc+0x33>
    return -1;
80107850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107855:	eb 0f                	jmp    80107866 <uartgetc+0x42>
  return inb(COM1+0);
80107857:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010785e:	e8 09 fe ff ff       	call   8010766c <inb>
80107863:	0f b6 c0             	movzbl %al,%eax
}
80107866:	c9                   	leave  
80107867:	c3                   	ret    

80107868 <uartintr>:

void
uartintr(void)
{
80107868:	55                   	push   %ebp
80107869:	89 e5                	mov    %esp,%ebp
8010786b:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010786e:	c7 04 24 24 78 10 80 	movl   $0x80107824,(%esp)
80107875:	e8 34 93 ff ff       	call   80100bae <consoleintr>
}
8010787a:	c9                   	leave  
8010787b:	c3                   	ret    

8010787c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010787c:	6a 00                	push   $0x0
  pushl $0
8010787e:	6a 00                	push   $0x0
  jmp alltraps
80107880:	e9 3f f9 ff ff       	jmp    801071c4 <alltraps>

80107885 <vector1>:
.globl vector1
vector1:
  pushl $0
80107885:	6a 00                	push   $0x0
  pushl $1
80107887:	6a 01                	push   $0x1
  jmp alltraps
80107889:	e9 36 f9 ff ff       	jmp    801071c4 <alltraps>

8010788e <vector2>:
.globl vector2
vector2:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $2
80107890:	6a 02                	push   $0x2
  jmp alltraps
80107892:	e9 2d f9 ff ff       	jmp    801071c4 <alltraps>

80107897 <vector3>:
.globl vector3
vector3:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $3
80107899:	6a 03                	push   $0x3
  jmp alltraps
8010789b:	e9 24 f9 ff ff       	jmp    801071c4 <alltraps>

801078a0 <vector4>:
.globl vector4
vector4:
  pushl $0
801078a0:	6a 00                	push   $0x0
  pushl $4
801078a2:	6a 04                	push   $0x4
  jmp alltraps
801078a4:	e9 1b f9 ff ff       	jmp    801071c4 <alltraps>

801078a9 <vector5>:
.globl vector5
vector5:
  pushl $0
801078a9:	6a 00                	push   $0x0
  pushl $5
801078ab:	6a 05                	push   $0x5
  jmp alltraps
801078ad:	e9 12 f9 ff ff       	jmp    801071c4 <alltraps>

801078b2 <vector6>:
.globl vector6
vector6:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $6
801078b4:	6a 06                	push   $0x6
  jmp alltraps
801078b6:	e9 09 f9 ff ff       	jmp    801071c4 <alltraps>

801078bb <vector7>:
.globl vector7
vector7:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $7
801078bd:	6a 07                	push   $0x7
  jmp alltraps
801078bf:	e9 00 f9 ff ff       	jmp    801071c4 <alltraps>

801078c4 <vector8>:
.globl vector8
vector8:
  pushl $8
801078c4:	6a 08                	push   $0x8
  jmp alltraps
801078c6:	e9 f9 f8 ff ff       	jmp    801071c4 <alltraps>

801078cb <vector9>:
.globl vector9
vector9:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $9
801078cd:	6a 09                	push   $0x9
  jmp alltraps
801078cf:	e9 f0 f8 ff ff       	jmp    801071c4 <alltraps>

801078d4 <vector10>:
.globl vector10
vector10:
  pushl $10
801078d4:	6a 0a                	push   $0xa
  jmp alltraps
801078d6:	e9 e9 f8 ff ff       	jmp    801071c4 <alltraps>

801078db <vector11>:
.globl vector11
vector11:
  pushl $11
801078db:	6a 0b                	push   $0xb
  jmp alltraps
801078dd:	e9 e2 f8 ff ff       	jmp    801071c4 <alltraps>

801078e2 <vector12>:
.globl vector12
vector12:
  pushl $12
801078e2:	6a 0c                	push   $0xc
  jmp alltraps
801078e4:	e9 db f8 ff ff       	jmp    801071c4 <alltraps>

801078e9 <vector13>:
.globl vector13
vector13:
  pushl $13
801078e9:	6a 0d                	push   $0xd
  jmp alltraps
801078eb:	e9 d4 f8 ff ff       	jmp    801071c4 <alltraps>

801078f0 <vector14>:
.globl vector14
vector14:
  pushl $14
801078f0:	6a 0e                	push   $0xe
  jmp alltraps
801078f2:	e9 cd f8 ff ff       	jmp    801071c4 <alltraps>

801078f7 <vector15>:
.globl vector15
vector15:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $15
801078f9:	6a 0f                	push   $0xf
  jmp alltraps
801078fb:	e9 c4 f8 ff ff       	jmp    801071c4 <alltraps>

80107900 <vector16>:
.globl vector16
vector16:
  pushl $0
80107900:	6a 00                	push   $0x0
  pushl $16
80107902:	6a 10                	push   $0x10
  jmp alltraps
80107904:	e9 bb f8 ff ff       	jmp    801071c4 <alltraps>

80107909 <vector17>:
.globl vector17
vector17:
  pushl $17
80107909:	6a 11                	push   $0x11
  jmp alltraps
8010790b:	e9 b4 f8 ff ff       	jmp    801071c4 <alltraps>

80107910 <vector18>:
.globl vector18
vector18:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $18
80107912:	6a 12                	push   $0x12
  jmp alltraps
80107914:	e9 ab f8 ff ff       	jmp    801071c4 <alltraps>

80107919 <vector19>:
.globl vector19
vector19:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $19
8010791b:	6a 13                	push   $0x13
  jmp alltraps
8010791d:	e9 a2 f8 ff ff       	jmp    801071c4 <alltraps>

80107922 <vector20>:
.globl vector20
vector20:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $20
80107924:	6a 14                	push   $0x14
  jmp alltraps
80107926:	e9 99 f8 ff ff       	jmp    801071c4 <alltraps>

8010792b <vector21>:
.globl vector21
vector21:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $21
8010792d:	6a 15                	push   $0x15
  jmp alltraps
8010792f:	e9 90 f8 ff ff       	jmp    801071c4 <alltraps>

80107934 <vector22>:
.globl vector22
vector22:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $22
80107936:	6a 16                	push   $0x16
  jmp alltraps
80107938:	e9 87 f8 ff ff       	jmp    801071c4 <alltraps>

8010793d <vector23>:
.globl vector23
vector23:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $23
8010793f:	6a 17                	push   $0x17
  jmp alltraps
80107941:	e9 7e f8 ff ff       	jmp    801071c4 <alltraps>

80107946 <vector24>:
.globl vector24
vector24:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $24
80107948:	6a 18                	push   $0x18
  jmp alltraps
8010794a:	e9 75 f8 ff ff       	jmp    801071c4 <alltraps>

8010794f <vector25>:
.globl vector25
vector25:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $25
80107951:	6a 19                	push   $0x19
  jmp alltraps
80107953:	e9 6c f8 ff ff       	jmp    801071c4 <alltraps>

80107958 <vector26>:
.globl vector26
vector26:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $26
8010795a:	6a 1a                	push   $0x1a
  jmp alltraps
8010795c:	e9 63 f8 ff ff       	jmp    801071c4 <alltraps>

80107961 <vector27>:
.globl vector27
vector27:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $27
80107963:	6a 1b                	push   $0x1b
  jmp alltraps
80107965:	e9 5a f8 ff ff       	jmp    801071c4 <alltraps>

8010796a <vector28>:
.globl vector28
vector28:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $28
8010796c:	6a 1c                	push   $0x1c
  jmp alltraps
8010796e:	e9 51 f8 ff ff       	jmp    801071c4 <alltraps>

80107973 <vector29>:
.globl vector29
vector29:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $29
80107975:	6a 1d                	push   $0x1d
  jmp alltraps
80107977:	e9 48 f8 ff ff       	jmp    801071c4 <alltraps>

8010797c <vector30>:
.globl vector30
vector30:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $30
8010797e:	6a 1e                	push   $0x1e
  jmp alltraps
80107980:	e9 3f f8 ff ff       	jmp    801071c4 <alltraps>

80107985 <vector31>:
.globl vector31
vector31:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $31
80107987:	6a 1f                	push   $0x1f
  jmp alltraps
80107989:	e9 36 f8 ff ff       	jmp    801071c4 <alltraps>

8010798e <vector32>:
.globl vector32
vector32:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $32
80107990:	6a 20                	push   $0x20
  jmp alltraps
80107992:	e9 2d f8 ff ff       	jmp    801071c4 <alltraps>

80107997 <vector33>:
.globl vector33
vector33:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $33
80107999:	6a 21                	push   $0x21
  jmp alltraps
8010799b:	e9 24 f8 ff ff       	jmp    801071c4 <alltraps>

801079a0 <vector34>:
.globl vector34
vector34:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $34
801079a2:	6a 22                	push   $0x22
  jmp alltraps
801079a4:	e9 1b f8 ff ff       	jmp    801071c4 <alltraps>

801079a9 <vector35>:
.globl vector35
vector35:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $35
801079ab:	6a 23                	push   $0x23
  jmp alltraps
801079ad:	e9 12 f8 ff ff       	jmp    801071c4 <alltraps>

801079b2 <vector36>:
.globl vector36
vector36:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $36
801079b4:	6a 24                	push   $0x24
  jmp alltraps
801079b6:	e9 09 f8 ff ff       	jmp    801071c4 <alltraps>

801079bb <vector37>:
.globl vector37
vector37:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $37
801079bd:	6a 25                	push   $0x25
  jmp alltraps
801079bf:	e9 00 f8 ff ff       	jmp    801071c4 <alltraps>

801079c4 <vector38>:
.globl vector38
vector38:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $38
801079c6:	6a 26                	push   $0x26
  jmp alltraps
801079c8:	e9 f7 f7 ff ff       	jmp    801071c4 <alltraps>

801079cd <vector39>:
.globl vector39
vector39:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $39
801079cf:	6a 27                	push   $0x27
  jmp alltraps
801079d1:	e9 ee f7 ff ff       	jmp    801071c4 <alltraps>

801079d6 <vector40>:
.globl vector40
vector40:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $40
801079d8:	6a 28                	push   $0x28
  jmp alltraps
801079da:	e9 e5 f7 ff ff       	jmp    801071c4 <alltraps>

801079df <vector41>:
.globl vector41
vector41:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $41
801079e1:	6a 29                	push   $0x29
  jmp alltraps
801079e3:	e9 dc f7 ff ff       	jmp    801071c4 <alltraps>

801079e8 <vector42>:
.globl vector42
vector42:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $42
801079ea:	6a 2a                	push   $0x2a
  jmp alltraps
801079ec:	e9 d3 f7 ff ff       	jmp    801071c4 <alltraps>

801079f1 <vector43>:
.globl vector43
vector43:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $43
801079f3:	6a 2b                	push   $0x2b
  jmp alltraps
801079f5:	e9 ca f7 ff ff       	jmp    801071c4 <alltraps>

801079fa <vector44>:
.globl vector44
vector44:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $44
801079fc:	6a 2c                	push   $0x2c
  jmp alltraps
801079fe:	e9 c1 f7 ff ff       	jmp    801071c4 <alltraps>

80107a03 <vector45>:
.globl vector45
vector45:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $45
80107a05:	6a 2d                	push   $0x2d
  jmp alltraps
80107a07:	e9 b8 f7 ff ff       	jmp    801071c4 <alltraps>

80107a0c <vector46>:
.globl vector46
vector46:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $46
80107a0e:	6a 2e                	push   $0x2e
  jmp alltraps
80107a10:	e9 af f7 ff ff       	jmp    801071c4 <alltraps>

80107a15 <vector47>:
.globl vector47
vector47:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $47
80107a17:	6a 2f                	push   $0x2f
  jmp alltraps
80107a19:	e9 a6 f7 ff ff       	jmp    801071c4 <alltraps>

80107a1e <vector48>:
.globl vector48
vector48:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $48
80107a20:	6a 30                	push   $0x30
  jmp alltraps
80107a22:	e9 9d f7 ff ff       	jmp    801071c4 <alltraps>

80107a27 <vector49>:
.globl vector49
vector49:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $49
80107a29:	6a 31                	push   $0x31
  jmp alltraps
80107a2b:	e9 94 f7 ff ff       	jmp    801071c4 <alltraps>

80107a30 <vector50>:
.globl vector50
vector50:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $50
80107a32:	6a 32                	push   $0x32
  jmp alltraps
80107a34:	e9 8b f7 ff ff       	jmp    801071c4 <alltraps>

80107a39 <vector51>:
.globl vector51
vector51:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $51
80107a3b:	6a 33                	push   $0x33
  jmp alltraps
80107a3d:	e9 82 f7 ff ff       	jmp    801071c4 <alltraps>

80107a42 <vector52>:
.globl vector52
vector52:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $52
80107a44:	6a 34                	push   $0x34
  jmp alltraps
80107a46:	e9 79 f7 ff ff       	jmp    801071c4 <alltraps>

80107a4b <vector53>:
.globl vector53
vector53:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $53
80107a4d:	6a 35                	push   $0x35
  jmp alltraps
80107a4f:	e9 70 f7 ff ff       	jmp    801071c4 <alltraps>

80107a54 <vector54>:
.globl vector54
vector54:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $54
80107a56:	6a 36                	push   $0x36
  jmp alltraps
80107a58:	e9 67 f7 ff ff       	jmp    801071c4 <alltraps>

80107a5d <vector55>:
.globl vector55
vector55:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $55
80107a5f:	6a 37                	push   $0x37
  jmp alltraps
80107a61:	e9 5e f7 ff ff       	jmp    801071c4 <alltraps>

80107a66 <vector56>:
.globl vector56
vector56:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $56
80107a68:	6a 38                	push   $0x38
  jmp alltraps
80107a6a:	e9 55 f7 ff ff       	jmp    801071c4 <alltraps>

80107a6f <vector57>:
.globl vector57
vector57:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $57
80107a71:	6a 39                	push   $0x39
  jmp alltraps
80107a73:	e9 4c f7 ff ff       	jmp    801071c4 <alltraps>

80107a78 <vector58>:
.globl vector58
vector58:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $58
80107a7a:	6a 3a                	push   $0x3a
  jmp alltraps
80107a7c:	e9 43 f7 ff ff       	jmp    801071c4 <alltraps>

80107a81 <vector59>:
.globl vector59
vector59:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $59
80107a83:	6a 3b                	push   $0x3b
  jmp alltraps
80107a85:	e9 3a f7 ff ff       	jmp    801071c4 <alltraps>

80107a8a <vector60>:
.globl vector60
vector60:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $60
80107a8c:	6a 3c                	push   $0x3c
  jmp alltraps
80107a8e:	e9 31 f7 ff ff       	jmp    801071c4 <alltraps>

80107a93 <vector61>:
.globl vector61
vector61:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $61
80107a95:	6a 3d                	push   $0x3d
  jmp alltraps
80107a97:	e9 28 f7 ff ff       	jmp    801071c4 <alltraps>

80107a9c <vector62>:
.globl vector62
vector62:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $62
80107a9e:	6a 3e                	push   $0x3e
  jmp alltraps
80107aa0:	e9 1f f7 ff ff       	jmp    801071c4 <alltraps>

80107aa5 <vector63>:
.globl vector63
vector63:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $63
80107aa7:	6a 3f                	push   $0x3f
  jmp alltraps
80107aa9:	e9 16 f7 ff ff       	jmp    801071c4 <alltraps>

80107aae <vector64>:
.globl vector64
vector64:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $64
80107ab0:	6a 40                	push   $0x40
  jmp alltraps
80107ab2:	e9 0d f7 ff ff       	jmp    801071c4 <alltraps>

80107ab7 <vector65>:
.globl vector65
vector65:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $65
80107ab9:	6a 41                	push   $0x41
  jmp alltraps
80107abb:	e9 04 f7 ff ff       	jmp    801071c4 <alltraps>

80107ac0 <vector66>:
.globl vector66
vector66:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $66
80107ac2:	6a 42                	push   $0x42
  jmp alltraps
80107ac4:	e9 fb f6 ff ff       	jmp    801071c4 <alltraps>

80107ac9 <vector67>:
.globl vector67
vector67:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $67
80107acb:	6a 43                	push   $0x43
  jmp alltraps
80107acd:	e9 f2 f6 ff ff       	jmp    801071c4 <alltraps>

80107ad2 <vector68>:
.globl vector68
vector68:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $68
80107ad4:	6a 44                	push   $0x44
  jmp alltraps
80107ad6:	e9 e9 f6 ff ff       	jmp    801071c4 <alltraps>

80107adb <vector69>:
.globl vector69
vector69:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $69
80107add:	6a 45                	push   $0x45
  jmp alltraps
80107adf:	e9 e0 f6 ff ff       	jmp    801071c4 <alltraps>

80107ae4 <vector70>:
.globl vector70
vector70:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $70
80107ae6:	6a 46                	push   $0x46
  jmp alltraps
80107ae8:	e9 d7 f6 ff ff       	jmp    801071c4 <alltraps>

80107aed <vector71>:
.globl vector71
vector71:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $71
80107aef:	6a 47                	push   $0x47
  jmp alltraps
80107af1:	e9 ce f6 ff ff       	jmp    801071c4 <alltraps>

80107af6 <vector72>:
.globl vector72
vector72:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $72
80107af8:	6a 48                	push   $0x48
  jmp alltraps
80107afa:	e9 c5 f6 ff ff       	jmp    801071c4 <alltraps>

80107aff <vector73>:
.globl vector73
vector73:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $73
80107b01:	6a 49                	push   $0x49
  jmp alltraps
80107b03:	e9 bc f6 ff ff       	jmp    801071c4 <alltraps>

80107b08 <vector74>:
.globl vector74
vector74:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $74
80107b0a:	6a 4a                	push   $0x4a
  jmp alltraps
80107b0c:	e9 b3 f6 ff ff       	jmp    801071c4 <alltraps>

80107b11 <vector75>:
.globl vector75
vector75:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $75
80107b13:	6a 4b                	push   $0x4b
  jmp alltraps
80107b15:	e9 aa f6 ff ff       	jmp    801071c4 <alltraps>

80107b1a <vector76>:
.globl vector76
vector76:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $76
80107b1c:	6a 4c                	push   $0x4c
  jmp alltraps
80107b1e:	e9 a1 f6 ff ff       	jmp    801071c4 <alltraps>

80107b23 <vector77>:
.globl vector77
vector77:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $77
80107b25:	6a 4d                	push   $0x4d
  jmp alltraps
80107b27:	e9 98 f6 ff ff       	jmp    801071c4 <alltraps>

80107b2c <vector78>:
.globl vector78
vector78:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $78
80107b2e:	6a 4e                	push   $0x4e
  jmp alltraps
80107b30:	e9 8f f6 ff ff       	jmp    801071c4 <alltraps>

80107b35 <vector79>:
.globl vector79
vector79:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $79
80107b37:	6a 4f                	push   $0x4f
  jmp alltraps
80107b39:	e9 86 f6 ff ff       	jmp    801071c4 <alltraps>

80107b3e <vector80>:
.globl vector80
vector80:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $80
80107b40:	6a 50                	push   $0x50
  jmp alltraps
80107b42:	e9 7d f6 ff ff       	jmp    801071c4 <alltraps>

80107b47 <vector81>:
.globl vector81
vector81:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $81
80107b49:	6a 51                	push   $0x51
  jmp alltraps
80107b4b:	e9 74 f6 ff ff       	jmp    801071c4 <alltraps>

80107b50 <vector82>:
.globl vector82
vector82:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $82
80107b52:	6a 52                	push   $0x52
  jmp alltraps
80107b54:	e9 6b f6 ff ff       	jmp    801071c4 <alltraps>

80107b59 <vector83>:
.globl vector83
vector83:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $83
80107b5b:	6a 53                	push   $0x53
  jmp alltraps
80107b5d:	e9 62 f6 ff ff       	jmp    801071c4 <alltraps>

80107b62 <vector84>:
.globl vector84
vector84:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $84
80107b64:	6a 54                	push   $0x54
  jmp alltraps
80107b66:	e9 59 f6 ff ff       	jmp    801071c4 <alltraps>

80107b6b <vector85>:
.globl vector85
vector85:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $85
80107b6d:	6a 55                	push   $0x55
  jmp alltraps
80107b6f:	e9 50 f6 ff ff       	jmp    801071c4 <alltraps>

80107b74 <vector86>:
.globl vector86
vector86:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $86
80107b76:	6a 56                	push   $0x56
  jmp alltraps
80107b78:	e9 47 f6 ff ff       	jmp    801071c4 <alltraps>

80107b7d <vector87>:
.globl vector87
vector87:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $87
80107b7f:	6a 57                	push   $0x57
  jmp alltraps
80107b81:	e9 3e f6 ff ff       	jmp    801071c4 <alltraps>

80107b86 <vector88>:
.globl vector88
vector88:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $88
80107b88:	6a 58                	push   $0x58
  jmp alltraps
80107b8a:	e9 35 f6 ff ff       	jmp    801071c4 <alltraps>

80107b8f <vector89>:
.globl vector89
vector89:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $89
80107b91:	6a 59                	push   $0x59
  jmp alltraps
80107b93:	e9 2c f6 ff ff       	jmp    801071c4 <alltraps>

80107b98 <vector90>:
.globl vector90
vector90:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $90
80107b9a:	6a 5a                	push   $0x5a
  jmp alltraps
80107b9c:	e9 23 f6 ff ff       	jmp    801071c4 <alltraps>

80107ba1 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $91
80107ba3:	6a 5b                	push   $0x5b
  jmp alltraps
80107ba5:	e9 1a f6 ff ff       	jmp    801071c4 <alltraps>

80107baa <vector92>:
.globl vector92
vector92:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $92
80107bac:	6a 5c                	push   $0x5c
  jmp alltraps
80107bae:	e9 11 f6 ff ff       	jmp    801071c4 <alltraps>

80107bb3 <vector93>:
.globl vector93
vector93:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $93
80107bb5:	6a 5d                	push   $0x5d
  jmp alltraps
80107bb7:	e9 08 f6 ff ff       	jmp    801071c4 <alltraps>

80107bbc <vector94>:
.globl vector94
vector94:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $94
80107bbe:	6a 5e                	push   $0x5e
  jmp alltraps
80107bc0:	e9 ff f5 ff ff       	jmp    801071c4 <alltraps>

80107bc5 <vector95>:
.globl vector95
vector95:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $95
80107bc7:	6a 5f                	push   $0x5f
  jmp alltraps
80107bc9:	e9 f6 f5 ff ff       	jmp    801071c4 <alltraps>

80107bce <vector96>:
.globl vector96
vector96:
  pushl $0
80107bce:	6a 00                	push   $0x0
  pushl $96
80107bd0:	6a 60                	push   $0x60
  jmp alltraps
80107bd2:	e9 ed f5 ff ff       	jmp    801071c4 <alltraps>

80107bd7 <vector97>:
.globl vector97
vector97:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $97
80107bd9:	6a 61                	push   $0x61
  jmp alltraps
80107bdb:	e9 e4 f5 ff ff       	jmp    801071c4 <alltraps>

80107be0 <vector98>:
.globl vector98
vector98:
  pushl $0
80107be0:	6a 00                	push   $0x0
  pushl $98
80107be2:	6a 62                	push   $0x62
  jmp alltraps
80107be4:	e9 db f5 ff ff       	jmp    801071c4 <alltraps>

80107be9 <vector99>:
.globl vector99
vector99:
  pushl $0
80107be9:	6a 00                	push   $0x0
  pushl $99
80107beb:	6a 63                	push   $0x63
  jmp alltraps
80107bed:	e9 d2 f5 ff ff       	jmp    801071c4 <alltraps>

80107bf2 <vector100>:
.globl vector100
vector100:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $100
80107bf4:	6a 64                	push   $0x64
  jmp alltraps
80107bf6:	e9 c9 f5 ff ff       	jmp    801071c4 <alltraps>

80107bfb <vector101>:
.globl vector101
vector101:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $101
80107bfd:	6a 65                	push   $0x65
  jmp alltraps
80107bff:	e9 c0 f5 ff ff       	jmp    801071c4 <alltraps>

80107c04 <vector102>:
.globl vector102
vector102:
  pushl $0
80107c04:	6a 00                	push   $0x0
  pushl $102
80107c06:	6a 66                	push   $0x66
  jmp alltraps
80107c08:	e9 b7 f5 ff ff       	jmp    801071c4 <alltraps>

80107c0d <vector103>:
.globl vector103
vector103:
  pushl $0
80107c0d:	6a 00                	push   $0x0
  pushl $103
80107c0f:	6a 67                	push   $0x67
  jmp alltraps
80107c11:	e9 ae f5 ff ff       	jmp    801071c4 <alltraps>

80107c16 <vector104>:
.globl vector104
vector104:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $104
80107c18:	6a 68                	push   $0x68
  jmp alltraps
80107c1a:	e9 a5 f5 ff ff       	jmp    801071c4 <alltraps>

80107c1f <vector105>:
.globl vector105
vector105:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $105
80107c21:	6a 69                	push   $0x69
  jmp alltraps
80107c23:	e9 9c f5 ff ff       	jmp    801071c4 <alltraps>

80107c28 <vector106>:
.globl vector106
vector106:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $106
80107c2a:	6a 6a                	push   $0x6a
  jmp alltraps
80107c2c:	e9 93 f5 ff ff       	jmp    801071c4 <alltraps>

80107c31 <vector107>:
.globl vector107
vector107:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $107
80107c33:	6a 6b                	push   $0x6b
  jmp alltraps
80107c35:	e9 8a f5 ff ff       	jmp    801071c4 <alltraps>

80107c3a <vector108>:
.globl vector108
vector108:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $108
80107c3c:	6a 6c                	push   $0x6c
  jmp alltraps
80107c3e:	e9 81 f5 ff ff       	jmp    801071c4 <alltraps>

80107c43 <vector109>:
.globl vector109
vector109:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $109
80107c45:	6a 6d                	push   $0x6d
  jmp alltraps
80107c47:	e9 78 f5 ff ff       	jmp    801071c4 <alltraps>

80107c4c <vector110>:
.globl vector110
vector110:
  pushl $0
80107c4c:	6a 00                	push   $0x0
  pushl $110
80107c4e:	6a 6e                	push   $0x6e
  jmp alltraps
80107c50:	e9 6f f5 ff ff       	jmp    801071c4 <alltraps>

80107c55 <vector111>:
.globl vector111
vector111:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $111
80107c57:	6a 6f                	push   $0x6f
  jmp alltraps
80107c59:	e9 66 f5 ff ff       	jmp    801071c4 <alltraps>

80107c5e <vector112>:
.globl vector112
vector112:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $112
80107c60:	6a 70                	push   $0x70
  jmp alltraps
80107c62:	e9 5d f5 ff ff       	jmp    801071c4 <alltraps>

80107c67 <vector113>:
.globl vector113
vector113:
  pushl $0
80107c67:	6a 00                	push   $0x0
  pushl $113
80107c69:	6a 71                	push   $0x71
  jmp alltraps
80107c6b:	e9 54 f5 ff ff       	jmp    801071c4 <alltraps>

80107c70 <vector114>:
.globl vector114
vector114:
  pushl $0
80107c70:	6a 00                	push   $0x0
  pushl $114
80107c72:	6a 72                	push   $0x72
  jmp alltraps
80107c74:	e9 4b f5 ff ff       	jmp    801071c4 <alltraps>

80107c79 <vector115>:
.globl vector115
vector115:
  pushl $0
80107c79:	6a 00                	push   $0x0
  pushl $115
80107c7b:	6a 73                	push   $0x73
  jmp alltraps
80107c7d:	e9 42 f5 ff ff       	jmp    801071c4 <alltraps>

80107c82 <vector116>:
.globl vector116
vector116:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $116
80107c84:	6a 74                	push   $0x74
  jmp alltraps
80107c86:	e9 39 f5 ff ff       	jmp    801071c4 <alltraps>

80107c8b <vector117>:
.globl vector117
vector117:
  pushl $0
80107c8b:	6a 00                	push   $0x0
  pushl $117
80107c8d:	6a 75                	push   $0x75
  jmp alltraps
80107c8f:	e9 30 f5 ff ff       	jmp    801071c4 <alltraps>

80107c94 <vector118>:
.globl vector118
vector118:
  pushl $0
80107c94:	6a 00                	push   $0x0
  pushl $118
80107c96:	6a 76                	push   $0x76
  jmp alltraps
80107c98:	e9 27 f5 ff ff       	jmp    801071c4 <alltraps>

80107c9d <vector119>:
.globl vector119
vector119:
  pushl $0
80107c9d:	6a 00                	push   $0x0
  pushl $119
80107c9f:	6a 77                	push   $0x77
  jmp alltraps
80107ca1:	e9 1e f5 ff ff       	jmp    801071c4 <alltraps>

80107ca6 <vector120>:
.globl vector120
vector120:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $120
80107ca8:	6a 78                	push   $0x78
  jmp alltraps
80107caa:	e9 15 f5 ff ff       	jmp    801071c4 <alltraps>

80107caf <vector121>:
.globl vector121
vector121:
  pushl $0
80107caf:	6a 00                	push   $0x0
  pushl $121
80107cb1:	6a 79                	push   $0x79
  jmp alltraps
80107cb3:	e9 0c f5 ff ff       	jmp    801071c4 <alltraps>

80107cb8 <vector122>:
.globl vector122
vector122:
  pushl $0
80107cb8:	6a 00                	push   $0x0
  pushl $122
80107cba:	6a 7a                	push   $0x7a
  jmp alltraps
80107cbc:	e9 03 f5 ff ff       	jmp    801071c4 <alltraps>

80107cc1 <vector123>:
.globl vector123
vector123:
  pushl $0
80107cc1:	6a 00                	push   $0x0
  pushl $123
80107cc3:	6a 7b                	push   $0x7b
  jmp alltraps
80107cc5:	e9 fa f4 ff ff       	jmp    801071c4 <alltraps>

80107cca <vector124>:
.globl vector124
vector124:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $124
80107ccc:	6a 7c                	push   $0x7c
  jmp alltraps
80107cce:	e9 f1 f4 ff ff       	jmp    801071c4 <alltraps>

80107cd3 <vector125>:
.globl vector125
vector125:
  pushl $0
80107cd3:	6a 00                	push   $0x0
  pushl $125
80107cd5:	6a 7d                	push   $0x7d
  jmp alltraps
80107cd7:	e9 e8 f4 ff ff       	jmp    801071c4 <alltraps>

80107cdc <vector126>:
.globl vector126
vector126:
  pushl $0
80107cdc:	6a 00                	push   $0x0
  pushl $126
80107cde:	6a 7e                	push   $0x7e
  jmp alltraps
80107ce0:	e9 df f4 ff ff       	jmp    801071c4 <alltraps>

80107ce5 <vector127>:
.globl vector127
vector127:
  pushl $0
80107ce5:	6a 00                	push   $0x0
  pushl $127
80107ce7:	6a 7f                	push   $0x7f
  jmp alltraps
80107ce9:	e9 d6 f4 ff ff       	jmp    801071c4 <alltraps>

80107cee <vector128>:
.globl vector128
vector128:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $128
80107cf0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107cf5:	e9 ca f4 ff ff       	jmp    801071c4 <alltraps>

80107cfa <vector129>:
.globl vector129
vector129:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $129
80107cfc:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107d01:	e9 be f4 ff ff       	jmp    801071c4 <alltraps>

80107d06 <vector130>:
.globl vector130
vector130:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $130
80107d08:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107d0d:	e9 b2 f4 ff ff       	jmp    801071c4 <alltraps>

80107d12 <vector131>:
.globl vector131
vector131:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $131
80107d14:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107d19:	e9 a6 f4 ff ff       	jmp    801071c4 <alltraps>

80107d1e <vector132>:
.globl vector132
vector132:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $132
80107d20:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107d25:	e9 9a f4 ff ff       	jmp    801071c4 <alltraps>

80107d2a <vector133>:
.globl vector133
vector133:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $133
80107d2c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107d31:	e9 8e f4 ff ff       	jmp    801071c4 <alltraps>

80107d36 <vector134>:
.globl vector134
vector134:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $134
80107d38:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107d3d:	e9 82 f4 ff ff       	jmp    801071c4 <alltraps>

80107d42 <vector135>:
.globl vector135
vector135:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $135
80107d44:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107d49:	e9 76 f4 ff ff       	jmp    801071c4 <alltraps>

80107d4e <vector136>:
.globl vector136
vector136:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $136
80107d50:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107d55:	e9 6a f4 ff ff       	jmp    801071c4 <alltraps>

80107d5a <vector137>:
.globl vector137
vector137:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $137
80107d5c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107d61:	e9 5e f4 ff ff       	jmp    801071c4 <alltraps>

80107d66 <vector138>:
.globl vector138
vector138:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $138
80107d68:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107d6d:	e9 52 f4 ff ff       	jmp    801071c4 <alltraps>

80107d72 <vector139>:
.globl vector139
vector139:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $139
80107d74:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107d79:	e9 46 f4 ff ff       	jmp    801071c4 <alltraps>

80107d7e <vector140>:
.globl vector140
vector140:
  pushl $0
80107d7e:	6a 00                	push   $0x0
  pushl $140
80107d80:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107d85:	e9 3a f4 ff ff       	jmp    801071c4 <alltraps>

80107d8a <vector141>:
.globl vector141
vector141:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $141
80107d8c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107d91:	e9 2e f4 ff ff       	jmp    801071c4 <alltraps>

80107d96 <vector142>:
.globl vector142
vector142:
  pushl $0
80107d96:	6a 00                	push   $0x0
  pushl $142
80107d98:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107d9d:	e9 22 f4 ff ff       	jmp    801071c4 <alltraps>

80107da2 <vector143>:
.globl vector143
vector143:
  pushl $0
80107da2:	6a 00                	push   $0x0
  pushl $143
80107da4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107da9:	e9 16 f4 ff ff       	jmp    801071c4 <alltraps>

80107dae <vector144>:
.globl vector144
vector144:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $144
80107db0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107db5:	e9 0a f4 ff ff       	jmp    801071c4 <alltraps>

80107dba <vector145>:
.globl vector145
vector145:
  pushl $0
80107dba:	6a 00                	push   $0x0
  pushl $145
80107dbc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107dc1:	e9 fe f3 ff ff       	jmp    801071c4 <alltraps>

80107dc6 <vector146>:
.globl vector146
vector146:
  pushl $0
80107dc6:	6a 00                	push   $0x0
  pushl $146
80107dc8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107dcd:	e9 f2 f3 ff ff       	jmp    801071c4 <alltraps>

80107dd2 <vector147>:
.globl vector147
vector147:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $147
80107dd4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107dd9:	e9 e6 f3 ff ff       	jmp    801071c4 <alltraps>

80107dde <vector148>:
.globl vector148
vector148:
  pushl $0
80107dde:	6a 00                	push   $0x0
  pushl $148
80107de0:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107de5:	e9 da f3 ff ff       	jmp    801071c4 <alltraps>

80107dea <vector149>:
.globl vector149
vector149:
  pushl $0
80107dea:	6a 00                	push   $0x0
  pushl $149
80107dec:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107df1:	e9 ce f3 ff ff       	jmp    801071c4 <alltraps>

80107df6 <vector150>:
.globl vector150
vector150:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $150
80107df8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107dfd:	e9 c2 f3 ff ff       	jmp    801071c4 <alltraps>

80107e02 <vector151>:
.globl vector151
vector151:
  pushl $0
80107e02:	6a 00                	push   $0x0
  pushl $151
80107e04:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107e09:	e9 b6 f3 ff ff       	jmp    801071c4 <alltraps>

80107e0e <vector152>:
.globl vector152
vector152:
  pushl $0
80107e0e:	6a 00                	push   $0x0
  pushl $152
80107e10:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107e15:	e9 aa f3 ff ff       	jmp    801071c4 <alltraps>

80107e1a <vector153>:
.globl vector153
vector153:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $153
80107e1c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107e21:	e9 9e f3 ff ff       	jmp    801071c4 <alltraps>

80107e26 <vector154>:
.globl vector154
vector154:
  pushl $0
80107e26:	6a 00                	push   $0x0
  pushl $154
80107e28:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107e2d:	e9 92 f3 ff ff       	jmp    801071c4 <alltraps>

80107e32 <vector155>:
.globl vector155
vector155:
  pushl $0
80107e32:	6a 00                	push   $0x0
  pushl $155
80107e34:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107e39:	e9 86 f3 ff ff       	jmp    801071c4 <alltraps>

80107e3e <vector156>:
.globl vector156
vector156:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $156
80107e40:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107e45:	e9 7a f3 ff ff       	jmp    801071c4 <alltraps>

80107e4a <vector157>:
.globl vector157
vector157:
  pushl $0
80107e4a:	6a 00                	push   $0x0
  pushl $157
80107e4c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107e51:	e9 6e f3 ff ff       	jmp    801071c4 <alltraps>

80107e56 <vector158>:
.globl vector158
vector158:
  pushl $0
80107e56:	6a 00                	push   $0x0
  pushl $158
80107e58:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107e5d:	e9 62 f3 ff ff       	jmp    801071c4 <alltraps>

80107e62 <vector159>:
.globl vector159
vector159:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $159
80107e64:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107e69:	e9 56 f3 ff ff       	jmp    801071c4 <alltraps>

80107e6e <vector160>:
.globl vector160
vector160:
  pushl $0
80107e6e:	6a 00                	push   $0x0
  pushl $160
80107e70:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107e75:	e9 4a f3 ff ff       	jmp    801071c4 <alltraps>

80107e7a <vector161>:
.globl vector161
vector161:
  pushl $0
80107e7a:	6a 00                	push   $0x0
  pushl $161
80107e7c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107e81:	e9 3e f3 ff ff       	jmp    801071c4 <alltraps>

80107e86 <vector162>:
.globl vector162
vector162:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $162
80107e88:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107e8d:	e9 32 f3 ff ff       	jmp    801071c4 <alltraps>

80107e92 <vector163>:
.globl vector163
vector163:
  pushl $0
80107e92:	6a 00                	push   $0x0
  pushl $163
80107e94:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107e99:	e9 26 f3 ff ff       	jmp    801071c4 <alltraps>

80107e9e <vector164>:
.globl vector164
vector164:
  pushl $0
80107e9e:	6a 00                	push   $0x0
  pushl $164
80107ea0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107ea5:	e9 1a f3 ff ff       	jmp    801071c4 <alltraps>

80107eaa <vector165>:
.globl vector165
vector165:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $165
80107eac:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107eb1:	e9 0e f3 ff ff       	jmp    801071c4 <alltraps>

80107eb6 <vector166>:
.globl vector166
vector166:
  pushl $0
80107eb6:	6a 00                	push   $0x0
  pushl $166
80107eb8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ebd:	e9 02 f3 ff ff       	jmp    801071c4 <alltraps>

80107ec2 <vector167>:
.globl vector167
vector167:
  pushl $0
80107ec2:	6a 00                	push   $0x0
  pushl $167
80107ec4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107ec9:	e9 f6 f2 ff ff       	jmp    801071c4 <alltraps>

80107ece <vector168>:
.globl vector168
vector168:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $168
80107ed0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107ed5:	e9 ea f2 ff ff       	jmp    801071c4 <alltraps>

80107eda <vector169>:
.globl vector169
vector169:
  pushl $0
80107eda:	6a 00                	push   $0x0
  pushl $169
80107edc:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107ee1:	e9 de f2 ff ff       	jmp    801071c4 <alltraps>

80107ee6 <vector170>:
.globl vector170
vector170:
  pushl $0
80107ee6:	6a 00                	push   $0x0
  pushl $170
80107ee8:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107eed:	e9 d2 f2 ff ff       	jmp    801071c4 <alltraps>

80107ef2 <vector171>:
.globl vector171
vector171:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $171
80107ef4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107ef9:	e9 c6 f2 ff ff       	jmp    801071c4 <alltraps>

80107efe <vector172>:
.globl vector172
vector172:
  pushl $0
80107efe:	6a 00                	push   $0x0
  pushl $172
80107f00:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107f05:	e9 ba f2 ff ff       	jmp    801071c4 <alltraps>

80107f0a <vector173>:
.globl vector173
vector173:
  pushl $0
80107f0a:	6a 00                	push   $0x0
  pushl $173
80107f0c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107f11:	e9 ae f2 ff ff       	jmp    801071c4 <alltraps>

80107f16 <vector174>:
.globl vector174
vector174:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $174
80107f18:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107f1d:	e9 a2 f2 ff ff       	jmp    801071c4 <alltraps>

80107f22 <vector175>:
.globl vector175
vector175:
  pushl $0
80107f22:	6a 00                	push   $0x0
  pushl $175
80107f24:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107f29:	e9 96 f2 ff ff       	jmp    801071c4 <alltraps>

80107f2e <vector176>:
.globl vector176
vector176:
  pushl $0
80107f2e:	6a 00                	push   $0x0
  pushl $176
80107f30:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107f35:	e9 8a f2 ff ff       	jmp    801071c4 <alltraps>

80107f3a <vector177>:
.globl vector177
vector177:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $177
80107f3c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107f41:	e9 7e f2 ff ff       	jmp    801071c4 <alltraps>

80107f46 <vector178>:
.globl vector178
vector178:
  pushl $0
80107f46:	6a 00                	push   $0x0
  pushl $178
80107f48:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107f4d:	e9 72 f2 ff ff       	jmp    801071c4 <alltraps>

80107f52 <vector179>:
.globl vector179
vector179:
  pushl $0
80107f52:	6a 00                	push   $0x0
  pushl $179
80107f54:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107f59:	e9 66 f2 ff ff       	jmp    801071c4 <alltraps>

80107f5e <vector180>:
.globl vector180
vector180:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $180
80107f60:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107f65:	e9 5a f2 ff ff       	jmp    801071c4 <alltraps>

80107f6a <vector181>:
.globl vector181
vector181:
  pushl $0
80107f6a:	6a 00                	push   $0x0
  pushl $181
80107f6c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107f71:	e9 4e f2 ff ff       	jmp    801071c4 <alltraps>

80107f76 <vector182>:
.globl vector182
vector182:
  pushl $0
80107f76:	6a 00                	push   $0x0
  pushl $182
80107f78:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107f7d:	e9 42 f2 ff ff       	jmp    801071c4 <alltraps>

80107f82 <vector183>:
.globl vector183
vector183:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $183
80107f84:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107f89:	e9 36 f2 ff ff       	jmp    801071c4 <alltraps>

80107f8e <vector184>:
.globl vector184
vector184:
  pushl $0
80107f8e:	6a 00                	push   $0x0
  pushl $184
80107f90:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107f95:	e9 2a f2 ff ff       	jmp    801071c4 <alltraps>

80107f9a <vector185>:
.globl vector185
vector185:
  pushl $0
80107f9a:	6a 00                	push   $0x0
  pushl $185
80107f9c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107fa1:	e9 1e f2 ff ff       	jmp    801071c4 <alltraps>

80107fa6 <vector186>:
.globl vector186
vector186:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $186
80107fa8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107fad:	e9 12 f2 ff ff       	jmp    801071c4 <alltraps>

80107fb2 <vector187>:
.globl vector187
vector187:
  pushl $0
80107fb2:	6a 00                	push   $0x0
  pushl $187
80107fb4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107fb9:	e9 06 f2 ff ff       	jmp    801071c4 <alltraps>

80107fbe <vector188>:
.globl vector188
vector188:
  pushl $0
80107fbe:	6a 00                	push   $0x0
  pushl $188
80107fc0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107fc5:	e9 fa f1 ff ff       	jmp    801071c4 <alltraps>

80107fca <vector189>:
.globl vector189
vector189:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $189
80107fcc:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107fd1:	e9 ee f1 ff ff       	jmp    801071c4 <alltraps>

80107fd6 <vector190>:
.globl vector190
vector190:
  pushl $0
80107fd6:	6a 00                	push   $0x0
  pushl $190
80107fd8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107fdd:	e9 e2 f1 ff ff       	jmp    801071c4 <alltraps>

80107fe2 <vector191>:
.globl vector191
vector191:
  pushl $0
80107fe2:	6a 00                	push   $0x0
  pushl $191
80107fe4:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107fe9:	e9 d6 f1 ff ff       	jmp    801071c4 <alltraps>

80107fee <vector192>:
.globl vector192
vector192:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $192
80107ff0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107ff5:	e9 ca f1 ff ff       	jmp    801071c4 <alltraps>

80107ffa <vector193>:
.globl vector193
vector193:
  pushl $0
80107ffa:	6a 00                	push   $0x0
  pushl $193
80107ffc:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108001:	e9 be f1 ff ff       	jmp    801071c4 <alltraps>

80108006 <vector194>:
.globl vector194
vector194:
  pushl $0
80108006:	6a 00                	push   $0x0
  pushl $194
80108008:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010800d:	e9 b2 f1 ff ff       	jmp    801071c4 <alltraps>

80108012 <vector195>:
.globl vector195
vector195:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $195
80108014:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108019:	e9 a6 f1 ff ff       	jmp    801071c4 <alltraps>

8010801e <vector196>:
.globl vector196
vector196:
  pushl $0
8010801e:	6a 00                	push   $0x0
  pushl $196
80108020:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108025:	e9 9a f1 ff ff       	jmp    801071c4 <alltraps>

8010802a <vector197>:
.globl vector197
vector197:
  pushl $0
8010802a:	6a 00                	push   $0x0
  pushl $197
8010802c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108031:	e9 8e f1 ff ff       	jmp    801071c4 <alltraps>

80108036 <vector198>:
.globl vector198
vector198:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $198
80108038:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010803d:	e9 82 f1 ff ff       	jmp    801071c4 <alltraps>

80108042 <vector199>:
.globl vector199
vector199:
  pushl $0
80108042:	6a 00                	push   $0x0
  pushl $199
80108044:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108049:	e9 76 f1 ff ff       	jmp    801071c4 <alltraps>

8010804e <vector200>:
.globl vector200
vector200:
  pushl $0
8010804e:	6a 00                	push   $0x0
  pushl $200
80108050:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108055:	e9 6a f1 ff ff       	jmp    801071c4 <alltraps>

8010805a <vector201>:
.globl vector201
vector201:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $201
8010805c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108061:	e9 5e f1 ff ff       	jmp    801071c4 <alltraps>

80108066 <vector202>:
.globl vector202
vector202:
  pushl $0
80108066:	6a 00                	push   $0x0
  pushl $202
80108068:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010806d:	e9 52 f1 ff ff       	jmp    801071c4 <alltraps>

80108072 <vector203>:
.globl vector203
vector203:
  pushl $0
80108072:	6a 00                	push   $0x0
  pushl $203
80108074:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108079:	e9 46 f1 ff ff       	jmp    801071c4 <alltraps>

8010807e <vector204>:
.globl vector204
vector204:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $204
80108080:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108085:	e9 3a f1 ff ff       	jmp    801071c4 <alltraps>

8010808a <vector205>:
.globl vector205
vector205:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $205
8010808c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108091:	e9 2e f1 ff ff       	jmp    801071c4 <alltraps>

80108096 <vector206>:
.globl vector206
vector206:
  pushl $0
80108096:	6a 00                	push   $0x0
  pushl $206
80108098:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010809d:	e9 22 f1 ff ff       	jmp    801071c4 <alltraps>

801080a2 <vector207>:
.globl vector207
vector207:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $207
801080a4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801080a9:	e9 16 f1 ff ff       	jmp    801071c4 <alltraps>

801080ae <vector208>:
.globl vector208
vector208:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $208
801080b0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801080b5:	e9 0a f1 ff ff       	jmp    801071c4 <alltraps>

801080ba <vector209>:
.globl vector209
vector209:
  pushl $0
801080ba:	6a 00                	push   $0x0
  pushl $209
801080bc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801080c1:	e9 fe f0 ff ff       	jmp    801071c4 <alltraps>

801080c6 <vector210>:
.globl vector210
vector210:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $210
801080c8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801080cd:	e9 f2 f0 ff ff       	jmp    801071c4 <alltraps>

801080d2 <vector211>:
.globl vector211
vector211:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $211
801080d4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801080d9:	e9 e6 f0 ff ff       	jmp    801071c4 <alltraps>

801080de <vector212>:
.globl vector212
vector212:
  pushl $0
801080de:	6a 00                	push   $0x0
  pushl $212
801080e0:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801080e5:	e9 da f0 ff ff       	jmp    801071c4 <alltraps>

801080ea <vector213>:
.globl vector213
vector213:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $213
801080ec:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801080f1:	e9 ce f0 ff ff       	jmp    801071c4 <alltraps>

801080f6 <vector214>:
.globl vector214
vector214:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $214
801080f8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801080fd:	e9 c2 f0 ff ff       	jmp    801071c4 <alltraps>

80108102 <vector215>:
.globl vector215
vector215:
  pushl $0
80108102:	6a 00                	push   $0x0
  pushl $215
80108104:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108109:	e9 b6 f0 ff ff       	jmp    801071c4 <alltraps>

8010810e <vector216>:
.globl vector216
vector216:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $216
80108110:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108115:	e9 aa f0 ff ff       	jmp    801071c4 <alltraps>

8010811a <vector217>:
.globl vector217
vector217:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $217
8010811c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108121:	e9 9e f0 ff ff       	jmp    801071c4 <alltraps>

80108126 <vector218>:
.globl vector218
vector218:
  pushl $0
80108126:	6a 00                	push   $0x0
  pushl $218
80108128:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010812d:	e9 92 f0 ff ff       	jmp    801071c4 <alltraps>

80108132 <vector219>:
.globl vector219
vector219:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $219
80108134:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108139:	e9 86 f0 ff ff       	jmp    801071c4 <alltraps>

8010813e <vector220>:
.globl vector220
vector220:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $220
80108140:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108145:	e9 7a f0 ff ff       	jmp    801071c4 <alltraps>

8010814a <vector221>:
.globl vector221
vector221:
  pushl $0
8010814a:	6a 00                	push   $0x0
  pushl $221
8010814c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108151:	e9 6e f0 ff ff       	jmp    801071c4 <alltraps>

80108156 <vector222>:
.globl vector222
vector222:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $222
80108158:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010815d:	e9 62 f0 ff ff       	jmp    801071c4 <alltraps>

80108162 <vector223>:
.globl vector223
vector223:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $223
80108164:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108169:	e9 56 f0 ff ff       	jmp    801071c4 <alltraps>

8010816e <vector224>:
.globl vector224
vector224:
  pushl $0
8010816e:	6a 00                	push   $0x0
  pushl $224
80108170:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108175:	e9 4a f0 ff ff       	jmp    801071c4 <alltraps>

8010817a <vector225>:
.globl vector225
vector225:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $225
8010817c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108181:	e9 3e f0 ff ff       	jmp    801071c4 <alltraps>

80108186 <vector226>:
.globl vector226
vector226:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $226
80108188:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010818d:	e9 32 f0 ff ff       	jmp    801071c4 <alltraps>

80108192 <vector227>:
.globl vector227
vector227:
  pushl $0
80108192:	6a 00                	push   $0x0
  pushl $227
80108194:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108199:	e9 26 f0 ff ff       	jmp    801071c4 <alltraps>

8010819e <vector228>:
.globl vector228
vector228:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $228
801081a0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801081a5:	e9 1a f0 ff ff       	jmp    801071c4 <alltraps>

801081aa <vector229>:
.globl vector229
vector229:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $229
801081ac:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801081b1:	e9 0e f0 ff ff       	jmp    801071c4 <alltraps>

801081b6 <vector230>:
.globl vector230
vector230:
  pushl $0
801081b6:	6a 00                	push   $0x0
  pushl $230
801081b8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801081bd:	e9 02 f0 ff ff       	jmp    801071c4 <alltraps>

801081c2 <vector231>:
.globl vector231
vector231:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $231
801081c4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801081c9:	e9 f6 ef ff ff       	jmp    801071c4 <alltraps>

801081ce <vector232>:
.globl vector232
vector232:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $232
801081d0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801081d5:	e9 ea ef ff ff       	jmp    801071c4 <alltraps>

801081da <vector233>:
.globl vector233
vector233:
  pushl $0
801081da:	6a 00                	push   $0x0
  pushl $233
801081dc:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801081e1:	e9 de ef ff ff       	jmp    801071c4 <alltraps>

801081e6 <vector234>:
.globl vector234
vector234:
  pushl $0
801081e6:	6a 00                	push   $0x0
  pushl $234
801081e8:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801081ed:	e9 d2 ef ff ff       	jmp    801071c4 <alltraps>

801081f2 <vector235>:
.globl vector235
vector235:
  pushl $0
801081f2:	6a 00                	push   $0x0
  pushl $235
801081f4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801081f9:	e9 c6 ef ff ff       	jmp    801071c4 <alltraps>

801081fe <vector236>:
.globl vector236
vector236:
  pushl $0
801081fe:	6a 00                	push   $0x0
  pushl $236
80108200:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108205:	e9 ba ef ff ff       	jmp    801071c4 <alltraps>

8010820a <vector237>:
.globl vector237
vector237:
  pushl $0
8010820a:	6a 00                	push   $0x0
  pushl $237
8010820c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108211:	e9 ae ef ff ff       	jmp    801071c4 <alltraps>

80108216 <vector238>:
.globl vector238
vector238:
  pushl $0
80108216:	6a 00                	push   $0x0
  pushl $238
80108218:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010821d:	e9 a2 ef ff ff       	jmp    801071c4 <alltraps>

80108222 <vector239>:
.globl vector239
vector239:
  pushl $0
80108222:	6a 00                	push   $0x0
  pushl $239
80108224:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108229:	e9 96 ef ff ff       	jmp    801071c4 <alltraps>

8010822e <vector240>:
.globl vector240
vector240:
  pushl $0
8010822e:	6a 00                	push   $0x0
  pushl $240
80108230:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108235:	e9 8a ef ff ff       	jmp    801071c4 <alltraps>

8010823a <vector241>:
.globl vector241
vector241:
  pushl $0
8010823a:	6a 00                	push   $0x0
  pushl $241
8010823c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108241:	e9 7e ef ff ff       	jmp    801071c4 <alltraps>

80108246 <vector242>:
.globl vector242
vector242:
  pushl $0
80108246:	6a 00                	push   $0x0
  pushl $242
80108248:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010824d:	e9 72 ef ff ff       	jmp    801071c4 <alltraps>

80108252 <vector243>:
.globl vector243
vector243:
  pushl $0
80108252:	6a 00                	push   $0x0
  pushl $243
80108254:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108259:	e9 66 ef ff ff       	jmp    801071c4 <alltraps>

8010825e <vector244>:
.globl vector244
vector244:
  pushl $0
8010825e:	6a 00                	push   $0x0
  pushl $244
80108260:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108265:	e9 5a ef ff ff       	jmp    801071c4 <alltraps>

8010826a <vector245>:
.globl vector245
vector245:
  pushl $0
8010826a:	6a 00                	push   $0x0
  pushl $245
8010826c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108271:	e9 4e ef ff ff       	jmp    801071c4 <alltraps>

80108276 <vector246>:
.globl vector246
vector246:
  pushl $0
80108276:	6a 00                	push   $0x0
  pushl $246
80108278:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010827d:	e9 42 ef ff ff       	jmp    801071c4 <alltraps>

80108282 <vector247>:
.globl vector247
vector247:
  pushl $0
80108282:	6a 00                	push   $0x0
  pushl $247
80108284:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108289:	e9 36 ef ff ff       	jmp    801071c4 <alltraps>

8010828e <vector248>:
.globl vector248
vector248:
  pushl $0
8010828e:	6a 00                	push   $0x0
  pushl $248
80108290:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108295:	e9 2a ef ff ff       	jmp    801071c4 <alltraps>

8010829a <vector249>:
.globl vector249
vector249:
  pushl $0
8010829a:	6a 00                	push   $0x0
  pushl $249
8010829c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801082a1:	e9 1e ef ff ff       	jmp    801071c4 <alltraps>

801082a6 <vector250>:
.globl vector250
vector250:
  pushl $0
801082a6:	6a 00                	push   $0x0
  pushl $250
801082a8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801082ad:	e9 12 ef ff ff       	jmp    801071c4 <alltraps>

801082b2 <vector251>:
.globl vector251
vector251:
  pushl $0
801082b2:	6a 00                	push   $0x0
  pushl $251
801082b4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801082b9:	e9 06 ef ff ff       	jmp    801071c4 <alltraps>

801082be <vector252>:
.globl vector252
vector252:
  pushl $0
801082be:	6a 00                	push   $0x0
  pushl $252
801082c0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801082c5:	e9 fa ee ff ff       	jmp    801071c4 <alltraps>

801082ca <vector253>:
.globl vector253
vector253:
  pushl $0
801082ca:	6a 00                	push   $0x0
  pushl $253
801082cc:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801082d1:	e9 ee ee ff ff       	jmp    801071c4 <alltraps>

801082d6 <vector254>:
.globl vector254
vector254:
  pushl $0
801082d6:	6a 00                	push   $0x0
  pushl $254
801082d8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801082dd:	e9 e2 ee ff ff       	jmp    801071c4 <alltraps>

801082e2 <vector255>:
.globl vector255
vector255:
  pushl $0
801082e2:	6a 00                	push   $0x0
  pushl $255
801082e4:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801082e9:	e9 d6 ee ff ff       	jmp    801071c4 <alltraps>
	...

801082f0 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801082f0:	55                   	push   %ebp
801082f1:	89 e5                	mov    %esp,%ebp
801082f3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801082f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f9:	83 e8 01             	sub    $0x1,%eax
801082fc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108300:	8b 45 08             	mov    0x8(%ebp),%eax
80108303:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108307:	8b 45 08             	mov    0x8(%ebp),%eax
8010830a:	c1 e8 10             	shr    $0x10,%eax
8010830d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108311:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108314:	0f 01 10             	lgdtl  (%eax)
}
80108317:	c9                   	leave  
80108318:	c3                   	ret    

80108319 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108319:	55                   	push   %ebp
8010831a:	89 e5                	mov    %esp,%ebp
8010831c:	83 ec 04             	sub    $0x4,%esp
8010831f:	8b 45 08             	mov    0x8(%ebp),%eax
80108322:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108326:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010832a:	0f 00 d8             	ltr    %ax
}
8010832d:	c9                   	leave  
8010832e:	c3                   	ret    

8010832f <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010832f:	55                   	push   %ebp
80108330:	89 e5                	mov    %esp,%ebp
80108332:	83 ec 04             	sub    $0x4,%esp
80108335:	8b 45 08             	mov    0x8(%ebp),%eax
80108338:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010833c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108340:	8e e8                	mov    %eax,%gs
}
80108342:	c9                   	leave  
80108343:	c3                   	ret    

80108344 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108344:	55                   	push   %ebp
80108345:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108347:	8b 45 08             	mov    0x8(%ebp),%eax
8010834a:	0f 22 d8             	mov    %eax,%cr3
}
8010834d:	5d                   	pop    %ebp
8010834e:	c3                   	ret    

8010834f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010834f:	55                   	push   %ebp
80108350:	89 e5                	mov    %esp,%ebp
80108352:	8b 45 08             	mov    0x8(%ebp),%eax
80108355:	05 00 00 00 80       	add    $0x80000000,%eax
8010835a:	5d                   	pop    %ebp
8010835b:	c3                   	ret    

8010835c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010835c:	55                   	push   %ebp
8010835d:	89 e5                	mov    %esp,%ebp
8010835f:	8b 45 08             	mov    0x8(%ebp),%eax
80108362:	05 00 00 00 80       	add    $0x80000000,%eax
80108367:	5d                   	pop    %ebp
80108368:	c3                   	ret    

80108369 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108369:	55                   	push   %ebp
8010836a:	89 e5                	mov    %esp,%ebp
8010836c:	53                   	push   %ebx
8010836d:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108370:	e8 0a b4 ff ff       	call   8010377f <cpunum>
80108375:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010837b:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
80108380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108386:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010838c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108398:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010839c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083a3:	83 e2 f0             	and    $0xfffffff0,%edx
801083a6:	83 ca 0a             	or     $0xa,%edx
801083a9:	88 50 7d             	mov    %dl,0x7d(%eax)
801083ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083af:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083b3:	83 ca 10             	or     $0x10,%edx
801083b6:	88 50 7d             	mov    %dl,0x7d(%eax)
801083b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083c0:	83 e2 9f             	and    $0xffffff9f,%edx
801083c3:	88 50 7d             	mov    %dl,0x7d(%eax)
801083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083cd:	83 ca 80             	or     $0xffffff80,%edx
801083d0:	88 50 7d             	mov    %dl,0x7d(%eax)
801083d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083da:	83 ca 0f             	or     $0xf,%edx
801083dd:	88 50 7e             	mov    %dl,0x7e(%eax)
801083e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083e7:	83 e2 ef             	and    $0xffffffef,%edx
801083ea:	88 50 7e             	mov    %dl,0x7e(%eax)
801083ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083f4:	83 e2 df             	and    $0xffffffdf,%edx
801083f7:	88 50 7e             	mov    %dl,0x7e(%eax)
801083fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108401:	83 ca 40             	or     $0x40,%edx
80108404:	88 50 7e             	mov    %dl,0x7e(%eax)
80108407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010840e:	83 ca 80             	or     $0xffffff80,%edx
80108411:	88 50 7e             	mov    %dl,0x7e(%eax)
80108414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108417:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108425:	ff ff 
80108427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108431:	00 00 
80108433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108436:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010843d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108440:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108447:	83 e2 f0             	and    $0xfffffff0,%edx
8010844a:	83 ca 02             	or     $0x2,%edx
8010844d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108456:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010845d:	83 ca 10             	or     $0x10,%edx
80108460:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108469:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108470:	83 e2 9f             	and    $0xffffff9f,%edx
80108473:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108483:	83 ca 80             	or     $0xffffff80,%edx
80108486:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010848c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108496:	83 ca 0f             	or     $0xf,%edx
80108499:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010849f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084a9:	83 e2 ef             	and    $0xffffffef,%edx
801084ac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084bc:	83 e2 df             	and    $0xffffffdf,%edx
801084bf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084cf:	83 ca 40             	or     $0x40,%edx
801084d2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084db:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084e2:	83 ca 80             	or     $0xffffff80,%edx
801084e5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ee:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801084f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f8:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801084ff:	ff ff 
80108501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108504:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010850b:	00 00 
8010850d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108510:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108521:	83 e2 f0             	and    $0xfffffff0,%edx
80108524:	83 ca 0a             	or     $0xa,%edx
80108527:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010852d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108530:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108537:	83 ca 10             	or     $0x10,%edx
8010853a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108543:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010854a:	83 ca 60             	or     $0x60,%edx
8010854d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108556:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010855d:	83 ca 80             	or     $0xffffff80,%edx
80108560:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108569:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108570:	83 ca 0f             	or     $0xf,%edx
80108573:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108583:	83 e2 ef             	and    $0xffffffef,%edx
80108586:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010858c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108596:	83 e2 df             	and    $0xffffffdf,%edx
80108599:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085a9:	83 ca 40             	or     $0x40,%edx
801085ac:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085bc:	83 ca 80             	or     $0xffffff80,%edx
801085bf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c8:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801085cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d2:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801085d9:	ff ff 
801085db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085de:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801085e5:	00 00 
801085e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ea:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801085f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801085fb:	83 e2 f0             	and    $0xfffffff0,%edx
801085fe:	83 ca 02             	or     $0x2,%edx
80108601:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108611:	83 ca 10             	or     $0x10,%edx
80108614:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010861a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108624:	83 ca 60             	or     $0x60,%edx
80108627:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010862d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108630:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108637:	83 ca 80             	or     $0xffffff80,%edx
8010863a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108643:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010864a:	83 ca 0f             	or     $0xf,%edx
8010864d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010865d:	83 e2 ef             	and    $0xffffffef,%edx
80108660:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108670:	83 e2 df             	and    $0xffffffdf,%edx
80108673:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108683:	83 ca 40             	or     $0x40,%edx
80108686:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010868c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108696:	83 ca 80             	or     $0xffffff80,%edx
80108699:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010869f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a2:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801086a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ac:	05 b4 00 00 00       	add    $0xb4,%eax
801086b1:	89 c3                	mov    %eax,%ebx
801086b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b6:	05 b4 00 00 00       	add    $0xb4,%eax
801086bb:	c1 e8 10             	shr    $0x10,%eax
801086be:	89 c1                	mov    %eax,%ecx
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	05 b4 00 00 00       	add    $0xb4,%eax
801086c8:	c1 e8 18             	shr    $0x18,%eax
801086cb:	89 c2                	mov    %eax,%edx
801086cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d0:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801086d7:	00 00 
801086d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dc:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801086e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e6:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801086ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ef:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801086f6:	83 e1 f0             	and    $0xfffffff0,%ecx
801086f9:	83 c9 02             	or     $0x2,%ecx
801086fc:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010870c:	83 c9 10             	or     $0x10,%ecx
8010870f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010871f:	83 e1 9f             	and    $0xffffff9f,%ecx
80108722:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108732:	83 c9 80             	or     $0xffffff80,%ecx
80108735:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108745:	83 e1 f0             	and    $0xfffffff0,%ecx
80108748:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108758:	83 e1 ef             	and    $0xffffffef,%ecx
8010875b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108764:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010876b:	83 e1 df             	and    $0xffffffdf,%ecx
8010876e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108777:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010877e:	83 c9 40             	or     $0x40,%ecx
80108781:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108791:	83 c9 80             	or     $0xffffff80,%ecx
80108794:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010879a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879d:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801087a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a6:	83 c0 70             	add    $0x70,%eax
801087a9:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801087b0:	00 
801087b1:	89 04 24             	mov    %eax,(%esp)
801087b4:	e8 37 fb ff ff       	call   801082f0 <lgdt>
  loadgs(SEG_KCPU << 3);
801087b9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801087c0:	e8 6a fb ff ff       	call   8010832f <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
801087c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c8:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801087ce:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801087d5:	00 00 00 00 
}
801087d9:	83 c4 24             	add    $0x24,%esp
801087dc:	5b                   	pop    %ebx
801087dd:	5d                   	pop    %ebp
801087de:	c3                   	ret    

801087df <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801087df:	55                   	push   %ebp
801087e0:	89 e5                	mov    %esp,%ebp
801087e2:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801087e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801087e8:	c1 e8 16             	shr    $0x16,%eax
801087eb:	c1 e0 02             	shl    $0x2,%eax
801087ee:	03 45 08             	add    0x8(%ebp),%eax
801087f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801087f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f7:	8b 00                	mov    (%eax),%eax
801087f9:	83 e0 01             	and    $0x1,%eax
801087fc:	84 c0                	test   %al,%al
801087fe:	74 17                	je     80108817 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108803:	8b 00                	mov    (%eax),%eax
80108805:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010880a:	89 04 24             	mov    %eax,(%esp)
8010880d:	e8 4a fb ff ff       	call   8010835c <p2v>
80108812:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108815:	eb 4b                	jmp    80108862 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108817:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010881b:	74 0e                	je     8010882b <walkpgdir+0x4c>
8010881d:	e8 a5 ab ff ff       	call   801033c7 <kalloc>
80108822:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108829:	75 07                	jne    80108832 <walkpgdir+0x53>
      return 0;
8010882b:	b8 00 00 00 00       	mov    $0x0,%eax
80108830:	eb 41                	jmp    80108873 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108832:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108839:	00 
8010883a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108841:	00 
80108842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108845:	89 04 24             	mov    %eax,(%esp)
80108848:	e8 a1 d4 ff ff       	call   80105cee <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010884d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108850:	89 04 24             	mov    %eax,(%esp)
80108853:	e8 f7 fa ff ff       	call   8010834f <v2p>
80108858:	89 c2                	mov    %eax,%edx
8010885a:	83 ca 07             	or     $0x7,%edx
8010885d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108860:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108862:	8b 45 0c             	mov    0xc(%ebp),%eax
80108865:	c1 e8 0c             	shr    $0xc,%eax
80108868:	25 ff 03 00 00       	and    $0x3ff,%eax
8010886d:	c1 e0 02             	shl    $0x2,%eax
80108870:	03 45 f4             	add    -0xc(%ebp),%eax
}
80108873:	c9                   	leave  
80108874:	c3                   	ret    

80108875 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108875:	55                   	push   %ebp
80108876:	89 e5                	mov    %esp,%ebp
80108878:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010887b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108883:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108886:	8b 45 0c             	mov    0xc(%ebp),%eax
80108889:	03 45 10             	add    0x10(%ebp),%eax
8010888c:	83 e8 01             	sub    $0x1,%eax
8010888f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108894:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108897:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010889e:	00 
8010889f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801088a6:	8b 45 08             	mov    0x8(%ebp),%eax
801088a9:	89 04 24             	mov    %eax,(%esp)
801088ac:	e8 2e ff ff ff       	call   801087df <walkpgdir>
801088b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801088b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088b8:	75 07                	jne    801088c1 <mappages+0x4c>
      return -1;
801088ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088bf:	eb 46                	jmp    80108907 <mappages+0x92>
    if(*pte & PTE_P)
801088c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c4:	8b 00                	mov    (%eax),%eax
801088c6:	83 e0 01             	and    $0x1,%eax
801088c9:	84 c0                	test   %al,%al
801088cb:	74 0c                	je     801088d9 <mappages+0x64>
      panic("remap");
801088cd:	c7 04 24 68 97 10 80 	movl   $0x80109768,(%esp)
801088d4:	e8 64 7c ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
801088d9:	8b 45 18             	mov    0x18(%ebp),%eax
801088dc:	0b 45 14             	or     0x14(%ebp),%eax
801088df:	89 c2                	mov    %eax,%edx
801088e1:	83 ca 01             	or     $0x1,%edx
801088e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e7:	89 10                	mov    %edx,(%eax)
    if(a == last)
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801088ef:	74 10                	je     80108901 <mappages+0x8c>
      break;
    a += PGSIZE;
801088f1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801088f8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801088ff:	eb 96                	jmp    80108897 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108901:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108902:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108907:	c9                   	leave  
80108908:	c3                   	ret    

80108909 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108909:	55                   	push   %ebp
8010890a:	89 e5                	mov    %esp,%ebp
8010890c:	53                   	push   %ebx
8010890d:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108910:	e8 b2 aa ff ff       	call   801033c7 <kalloc>
80108915:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108918:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010891c:	75 0a                	jne    80108928 <setupkvm+0x1f>
    return 0;
8010891e:	b8 00 00 00 00       	mov    $0x0,%eax
80108923:	e9 98 00 00 00       	jmp    801089c0 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108928:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010892f:	00 
80108930:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108937:	00 
80108938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010893b:	89 04 24             	mov    %eax,(%esp)
8010893e:	e8 ab d3 ff ff       	call   80105cee <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108943:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
8010894a:	e8 0d fa ff ff       	call   8010835c <p2v>
8010894f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108954:	76 0c                	jbe    80108962 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108956:	c7 04 24 6e 97 10 80 	movl   $0x8010976e,(%esp)
8010895d:	e8 db 7b ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108962:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108969:	eb 49                	jmp    801089b4 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
8010896b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010896e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108971:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108974:	8b 50 04             	mov    0x4(%eax),%edx
80108977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897a:	8b 58 08             	mov    0x8(%eax),%ebx
8010897d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108980:	8b 40 04             	mov    0x4(%eax),%eax
80108983:	29 c3                	sub    %eax,%ebx
80108985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108988:	8b 00                	mov    (%eax),%eax
8010898a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010898e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108992:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108996:	89 44 24 04          	mov    %eax,0x4(%esp)
8010899a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010899d:	89 04 24             	mov    %eax,(%esp)
801089a0:	e8 d0 fe ff ff       	call   80108875 <mappages>
801089a5:	85 c0                	test   %eax,%eax
801089a7:	79 07                	jns    801089b0 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801089a9:	b8 00 00 00 00       	mov    $0x0,%eax
801089ae:	eb 10                	jmp    801089c0 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801089b0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801089b4:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801089bb:	72 ae                	jb     8010896b <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801089bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801089c0:	83 c4 34             	add    $0x34,%esp
801089c3:	5b                   	pop    %ebx
801089c4:	5d                   	pop    %ebp
801089c5:	c3                   	ret    

801089c6 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801089c6:	55                   	push   %ebp
801089c7:	89 e5                	mov    %esp,%ebp
801089c9:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801089cc:	e8 38 ff ff ff       	call   80108909 <setupkvm>
801089d1:	a3 78 6e 11 80       	mov    %eax,0x80116e78
  switchkvm();
801089d6:	e8 02 00 00 00       	call   801089dd <switchkvm>
}
801089db:	c9                   	leave  
801089dc:	c3                   	ret    

801089dd <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801089dd:	55                   	push   %ebp
801089de:	89 e5                	mov    %esp,%ebp
801089e0:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801089e3:	a1 78 6e 11 80       	mov    0x80116e78,%eax
801089e8:	89 04 24             	mov    %eax,(%esp)
801089eb:	e8 5f f9 ff ff       	call   8010834f <v2p>
801089f0:	89 04 24             	mov    %eax,(%esp)
801089f3:	e8 4c f9 ff ff       	call   80108344 <lcr3>
}
801089f8:	c9                   	leave  
801089f9:	c3                   	ret    

801089fa <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801089fa:	55                   	push   %ebp
801089fb:	89 e5                	mov    %esp,%ebp
801089fd:	53                   	push   %ebx
801089fe:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108a01:	e8 e1 d1 ff ff       	call   80105be7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108a06:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108a0c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a13:	83 c2 08             	add    $0x8,%edx
80108a16:	89 d3                	mov    %edx,%ebx
80108a18:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a1f:	83 c2 08             	add    $0x8,%edx
80108a22:	c1 ea 10             	shr    $0x10,%edx
80108a25:	89 d1                	mov    %edx,%ecx
80108a27:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a2e:	83 c2 08             	add    $0x8,%edx
80108a31:	c1 ea 18             	shr    $0x18,%edx
80108a34:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108a3b:	67 00 
80108a3d:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108a44:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108a4a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a51:	83 e1 f0             	and    $0xfffffff0,%ecx
80108a54:	83 c9 09             	or     $0x9,%ecx
80108a57:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a5d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a64:	83 c9 10             	or     $0x10,%ecx
80108a67:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a6d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a74:	83 e1 9f             	and    $0xffffff9f,%ecx
80108a77:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a7d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108a84:	83 c9 80             	or     $0xffffff80,%ecx
80108a87:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108a8d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108a94:	83 e1 f0             	and    $0xfffffff0,%ecx
80108a97:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108a9d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108aa4:	83 e1 ef             	and    $0xffffffef,%ecx
80108aa7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108aad:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108ab4:	83 e1 df             	and    $0xffffffdf,%ecx
80108ab7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108abd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108ac4:	83 c9 40             	or     $0x40,%ecx
80108ac7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108acd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108ad4:	83 e1 7f             	and    $0x7f,%ecx
80108ad7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108add:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108ae3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ae9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108af0:	83 e2 ef             	and    $0xffffffef,%edx
80108af3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108af9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108aff:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108b05:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b0b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108b12:	8b 52 08             	mov    0x8(%edx),%edx
80108b15:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108b1b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108b1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108b25:	e8 ef f7 ff ff       	call   80108319 <ltr>
  if(p->pgdir == 0)
80108b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2d:	8b 40 04             	mov    0x4(%eax),%eax
80108b30:	85 c0                	test   %eax,%eax
80108b32:	75 0c                	jne    80108b40 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108b34:	c7 04 24 7f 97 10 80 	movl   $0x8010977f,(%esp)
80108b3b:	e8 fd 79 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108b40:	8b 45 08             	mov    0x8(%ebp),%eax
80108b43:	8b 40 04             	mov    0x4(%eax),%eax
80108b46:	89 04 24             	mov    %eax,(%esp)
80108b49:	e8 01 f8 ff ff       	call   8010834f <v2p>
80108b4e:	89 04 24             	mov    %eax,(%esp)
80108b51:	e8 ee f7 ff ff       	call   80108344 <lcr3>
  popcli();
80108b56:	e8 d4 d0 ff ff       	call   80105c2f <popcli>
}
80108b5b:	83 c4 14             	add    $0x14,%esp
80108b5e:	5b                   	pop    %ebx
80108b5f:	5d                   	pop    %ebp
80108b60:	c3                   	ret    

80108b61 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108b61:	55                   	push   %ebp
80108b62:	89 e5                	mov    %esp,%ebp
80108b64:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108b67:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108b6e:	76 0c                	jbe    80108b7c <inituvm+0x1b>
    panic("inituvm: more than a page");
80108b70:	c7 04 24 93 97 10 80 	movl   $0x80109793,(%esp)
80108b77:	e8 c1 79 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108b7c:	e8 46 a8 ff ff       	call   801033c7 <kalloc>
80108b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108b84:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b8b:	00 
80108b8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b93:	00 
80108b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b97:	89 04 24             	mov    %eax,(%esp)
80108b9a:	e8 4f d1 ff ff       	call   80105cee <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba2:	89 04 24             	mov    %eax,(%esp)
80108ba5:	e8 a5 f7 ff ff       	call   8010834f <v2p>
80108baa:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108bb1:	00 
80108bb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108bb6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108bbd:	00 
80108bbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108bc5:	00 
80108bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80108bc9:	89 04 24             	mov    %eax,(%esp)
80108bcc:	e8 a4 fc ff ff       	call   80108875 <mappages>
  memmove(mem, init, sz);
80108bd1:	8b 45 10             	mov    0x10(%ebp),%eax
80108bd4:	89 44 24 08          	mov    %eax,0x8(%esp)
80108bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be2:	89 04 24             	mov    %eax,(%esp)
80108be5:	e8 d7 d1 ff ff       	call   80105dc1 <memmove>
}
80108bea:	c9                   	leave  
80108beb:	c3                   	ret    

80108bec <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108bec:	55                   	push   %ebp
80108bed:	89 e5                	mov    %esp,%ebp
80108bef:	53                   	push   %ebx
80108bf0:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bf6:	25 ff 0f 00 00       	and    $0xfff,%eax
80108bfb:	85 c0                	test   %eax,%eax
80108bfd:	74 0c                	je     80108c0b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108bff:	c7 04 24 b0 97 10 80 	movl   $0x801097b0,(%esp)
80108c06:	e8 32 79 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108c0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c12:	e9 ad 00 00 00       	jmp    80108cc4 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c1d:	01 d0                	add    %edx,%eax
80108c1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c26:	00 
80108c27:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c2e:	89 04 24             	mov    %eax,(%esp)
80108c31:	e8 a9 fb ff ff       	call   801087df <walkpgdir>
80108c36:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c3d:	75 0c                	jne    80108c4b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108c3f:	c7 04 24 d3 97 10 80 	movl   $0x801097d3,(%esp)
80108c46:	e8 f2 78 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108c4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c4e:	8b 00                	mov    (%eax),%eax
80108c50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c55:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c5b:	8b 55 18             	mov    0x18(%ebp),%edx
80108c5e:	89 d1                	mov    %edx,%ecx
80108c60:	29 c1                	sub    %eax,%ecx
80108c62:	89 c8                	mov    %ecx,%eax
80108c64:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108c69:	77 11                	ja     80108c7c <loaduvm+0x90>
      n = sz - i;
80108c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6e:	8b 55 18             	mov    0x18(%ebp),%edx
80108c71:	89 d1                	mov    %edx,%ecx
80108c73:	29 c1                	sub    %eax,%ecx
80108c75:	89 c8                	mov    %ecx,%eax
80108c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c7a:	eb 07                	jmp    80108c83 <loaduvm+0x97>
    else
      n = PGSIZE;
80108c7c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c86:	8b 55 14             	mov    0x14(%ebp),%edx
80108c89:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108c8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c8f:	89 04 24             	mov    %eax,(%esp)
80108c92:	e8 c5 f6 ff ff       	call   8010835c <p2v>
80108c97:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c9a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108c9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ca6:	8b 45 10             	mov    0x10(%ebp),%eax
80108ca9:	89 04 24             	mov    %eax,(%esp)
80108cac:	e8 40 99 ff ff       	call   801025f1 <readi>
80108cb1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108cb4:	74 07                	je     80108cbd <loaduvm+0xd1>
      return -1;
80108cb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cbb:	eb 18                	jmp    80108cd5 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108cbd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc7:	3b 45 18             	cmp    0x18(%ebp),%eax
80108cca:	0f 82 47 ff ff ff    	jb     80108c17 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cd5:	83 c4 24             	add    $0x24,%esp
80108cd8:	5b                   	pop    %ebx
80108cd9:	5d                   	pop    %ebp
80108cda:	c3                   	ret    

80108cdb <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108cdb:	55                   	push   %ebp
80108cdc:	89 e5                	mov    %esp,%ebp
80108cde:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108ce1:	8b 45 10             	mov    0x10(%ebp),%eax
80108ce4:	85 c0                	test   %eax,%eax
80108ce6:	79 0a                	jns    80108cf2 <allocuvm+0x17>
    return 0;
80108ce8:	b8 00 00 00 00       	mov    $0x0,%eax
80108ced:	e9 c1 00 00 00       	jmp    80108db3 <allocuvm+0xd8>
  if(newsz < oldsz)
80108cf2:	8b 45 10             	mov    0x10(%ebp),%eax
80108cf5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108cf8:	73 08                	jae    80108d02 <allocuvm+0x27>
    return oldsz;
80108cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cfd:	e9 b1 00 00 00       	jmp    80108db3 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108d02:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d05:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108d12:	e9 8d 00 00 00       	jmp    80108da4 <allocuvm+0xc9>
    mem = kalloc();
80108d17:	e8 ab a6 ff ff       	call   801033c7 <kalloc>
80108d1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108d1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d23:	75 2c                	jne    80108d51 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108d25:	c7 04 24 f1 97 10 80 	movl   $0x801097f1,(%esp)
80108d2c:	e8 70 76 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108d31:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d34:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d38:	8b 45 10             	mov    0x10(%ebp),%eax
80108d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80108d42:	89 04 24             	mov    %eax,(%esp)
80108d45:	e8 6b 00 00 00       	call   80108db5 <deallocuvm>
      return 0;
80108d4a:	b8 00 00 00 00       	mov    $0x0,%eax
80108d4f:	eb 62                	jmp    80108db3 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108d51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d58:	00 
80108d59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108d60:	00 
80108d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d64:	89 04 24             	mov    %eax,(%esp)
80108d67:	e8 82 cf ff ff       	call   80105cee <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d6f:	89 04 24             	mov    %eax,(%esp)
80108d72:	e8 d8 f5 ff ff       	call   8010834f <v2p>
80108d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d7a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108d81:	00 
80108d82:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108d86:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d8d:	00 
80108d8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108d92:	8b 45 08             	mov    0x8(%ebp),%eax
80108d95:	89 04 24             	mov    %eax,(%esp)
80108d98:	e8 d8 fa ff ff       	call   80108875 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108d9d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da7:	3b 45 10             	cmp    0x10(%ebp),%eax
80108daa:	0f 82 67 ff ff ff    	jb     80108d17 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108db0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108db3:	c9                   	leave  
80108db4:	c3                   	ret    

80108db5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108db5:	55                   	push   %ebp
80108db6:	89 e5                	mov    %esp,%ebp
80108db8:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108dbb:	8b 45 10             	mov    0x10(%ebp),%eax
80108dbe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108dc1:	72 08                	jb     80108dcb <deallocuvm+0x16>
    return oldsz;
80108dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dc6:	e9 a4 00 00 00       	jmp    80108e6f <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108dcb:	8b 45 10             	mov    0x10(%ebp),%eax
80108dce:	05 ff 0f 00 00       	add    $0xfff,%eax
80108dd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108ddb:	e9 80 00 00 00       	jmp    80108e60 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108dea:	00 
80108deb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108def:	8b 45 08             	mov    0x8(%ebp),%eax
80108df2:	89 04 24             	mov    %eax,(%esp)
80108df5:	e8 e5 f9 ff ff       	call   801087df <walkpgdir>
80108dfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108dfd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e01:	75 09                	jne    80108e0c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108e03:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108e0a:	eb 4d                	jmp    80108e59 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e0f:	8b 00                	mov    (%eax),%eax
80108e11:	83 e0 01             	and    $0x1,%eax
80108e14:	84 c0                	test   %al,%al
80108e16:	74 41                	je     80108e59 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1b:	8b 00                	mov    (%eax),%eax
80108e1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e22:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108e25:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e29:	75 0c                	jne    80108e37 <deallocuvm+0x82>
        panic("kfree");
80108e2b:	c7 04 24 09 98 10 80 	movl   $0x80109809,(%esp)
80108e32:	e8 06 77 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e3a:	89 04 24             	mov    %eax,(%esp)
80108e3d:	e8 1a f5 ff ff       	call   8010835c <p2v>
80108e42:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108e45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e48:	89 04 24             	mov    %eax,(%esp)
80108e4b:	e8 de a4 ff ff       	call   8010332e <kfree>
      *pte = 0;
80108e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108e59:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e63:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e66:	0f 82 74 ff ff ff    	jb     80108de0 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108e6c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e6f:	c9                   	leave  
80108e70:	c3                   	ret    

80108e71 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108e71:	55                   	push   %ebp
80108e72:	89 e5                	mov    %esp,%ebp
80108e74:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108e77:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e7b:	75 0c                	jne    80108e89 <freevm+0x18>
    panic("freevm: no pgdir");
80108e7d:	c7 04 24 0f 98 10 80 	movl   $0x8010980f,(%esp)
80108e84:	e8 b4 76 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108e89:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e90:	00 
80108e91:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108e98:	80 
80108e99:	8b 45 08             	mov    0x8(%ebp),%eax
80108e9c:	89 04 24             	mov    %eax,(%esp)
80108e9f:	e8 11 ff ff ff       	call   80108db5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108ea4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108eab:	eb 3c                	jmp    80108ee9 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb0:	c1 e0 02             	shl    $0x2,%eax
80108eb3:	03 45 08             	add    0x8(%ebp),%eax
80108eb6:	8b 00                	mov    (%eax),%eax
80108eb8:	83 e0 01             	and    $0x1,%eax
80108ebb:	84 c0                	test   %al,%al
80108ebd:	74 26                	je     80108ee5 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec2:	c1 e0 02             	shl    $0x2,%eax
80108ec5:	03 45 08             	add    0x8(%ebp),%eax
80108ec8:	8b 00                	mov    (%eax),%eax
80108eca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ecf:	89 04 24             	mov    %eax,(%esp)
80108ed2:	e8 85 f4 ff ff       	call   8010835c <p2v>
80108ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108edd:	89 04 24             	mov    %eax,(%esp)
80108ee0:	e8 49 a4 ff ff       	call   8010332e <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108ee5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ee9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ef0:	76 bb                	jbe    80108ead <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef5:	89 04 24             	mov    %eax,(%esp)
80108ef8:	e8 31 a4 ff ff       	call   8010332e <kfree>
}
80108efd:	c9                   	leave  
80108efe:	c3                   	ret    

80108eff <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108eff:	55                   	push   %ebp
80108f00:	89 e5                	mov    %esp,%ebp
80108f02:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108f05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f0c:	00 
80108f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f10:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f14:	8b 45 08             	mov    0x8(%ebp),%eax
80108f17:	89 04 24             	mov    %eax,(%esp)
80108f1a:	e8 c0 f8 ff ff       	call   801087df <walkpgdir>
80108f1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108f22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f26:	75 0c                	jne    80108f34 <clearpteu+0x35>
    panic("clearpteu");
80108f28:	c7 04 24 20 98 10 80 	movl   $0x80109820,(%esp)
80108f2f:	e8 09 76 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f37:	8b 00                	mov    (%eax),%eax
80108f39:	89 c2                	mov    %eax,%edx
80108f3b:	83 e2 fb             	and    $0xfffffffb,%edx
80108f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f41:	89 10                	mov    %edx,(%eax)
}
80108f43:	c9                   	leave  
80108f44:	c3                   	ret    

80108f45 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108f45:	55                   	push   %ebp
80108f46:	89 e5                	mov    %esp,%ebp
80108f48:	53                   	push   %ebx
80108f49:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108f4c:	e8 b8 f9 ff ff       	call   80108909 <setupkvm>
80108f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f58:	75 0a                	jne    80108f64 <copyuvm+0x1f>
    return 0;
80108f5a:	b8 00 00 00 00       	mov    $0x0,%eax
80108f5f:	e9 fd 00 00 00       	jmp    80109061 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108f64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f6b:	e9 cc 00 00 00       	jmp    8010903c <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f7a:	00 
80108f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f82:	89 04 24             	mov    %eax,(%esp)
80108f85:	e8 55 f8 ff ff       	call   801087df <walkpgdir>
80108f8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f8d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f91:	75 0c                	jne    80108f9f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108f93:	c7 04 24 2a 98 10 80 	movl   $0x8010982a,(%esp)
80108f9a:	e8 9e 75 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108f9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa2:	8b 00                	mov    (%eax),%eax
80108fa4:	83 e0 01             	and    $0x1,%eax
80108fa7:	85 c0                	test   %eax,%eax
80108fa9:	75 0c                	jne    80108fb7 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108fab:	c7 04 24 44 98 10 80 	movl   $0x80109844,(%esp)
80108fb2:	e8 86 75 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108fb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fba:	8b 00                	mov    (%eax),%eax
80108fbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108fc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fc7:	8b 00                	mov    (%eax),%eax
80108fc9:	25 ff 0f 00 00       	and    $0xfff,%eax
80108fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108fd1:	e8 f1 a3 ff ff       	call   801033c7 <kalloc>
80108fd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108fd9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108fdd:	74 6e                	je     8010904d <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108fdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fe2:	89 04 24             	mov    %eax,(%esp)
80108fe5:	e8 72 f3 ff ff       	call   8010835c <p2v>
80108fea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ff1:	00 
80108ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ff6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ff9:	89 04 24             	mov    %eax,(%esp)
80108ffc:	e8 c0 cd ff ff       	call   80105dc1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109001:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109004:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109007:	89 04 24             	mov    %eax,(%esp)
8010900a:	e8 40 f3 ff ff       	call   8010834f <v2p>
8010900f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109012:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80109016:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010901a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109021:	00 
80109022:	89 54 24 04          	mov    %edx,0x4(%esp)
80109026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109029:	89 04 24             	mov    %eax,(%esp)
8010902c:	e8 44 f8 ff ff       	call   80108875 <mappages>
80109031:	85 c0                	test   %eax,%eax
80109033:	78 1b                	js     80109050 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109035:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010903c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010903f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109042:	0f 82 28 ff ff ff    	jb     80108f70 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109048:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010904b:	eb 14                	jmp    80109061 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010904d:	90                   	nop
8010904e:	eb 01                	jmp    80109051 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109050:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109054:	89 04 24             	mov    %eax,(%esp)
80109057:	e8 15 fe ff ff       	call   80108e71 <freevm>
  return 0;
8010905c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109061:	83 c4 44             	add    $0x44,%esp
80109064:	5b                   	pop    %ebx
80109065:	5d                   	pop    %ebp
80109066:	c3                   	ret    

80109067 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109067:	55                   	push   %ebp
80109068:	89 e5                	mov    %esp,%ebp
8010906a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010906d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109074:	00 
80109075:	8b 45 0c             	mov    0xc(%ebp),%eax
80109078:	89 44 24 04          	mov    %eax,0x4(%esp)
8010907c:	8b 45 08             	mov    0x8(%ebp),%eax
8010907f:	89 04 24             	mov    %eax,(%esp)
80109082:	e8 58 f7 ff ff       	call   801087df <walkpgdir>
80109087:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010908a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010908d:	8b 00                	mov    (%eax),%eax
8010908f:	83 e0 01             	and    $0x1,%eax
80109092:	85 c0                	test   %eax,%eax
80109094:	75 07                	jne    8010909d <uva2ka+0x36>
    return 0;
80109096:	b8 00 00 00 00       	mov    $0x0,%eax
8010909b:	eb 25                	jmp    801090c2 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010909d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a0:	8b 00                	mov    (%eax),%eax
801090a2:	83 e0 04             	and    $0x4,%eax
801090a5:	85 c0                	test   %eax,%eax
801090a7:	75 07                	jne    801090b0 <uva2ka+0x49>
    return 0;
801090a9:	b8 00 00 00 00       	mov    $0x0,%eax
801090ae:	eb 12                	jmp    801090c2 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801090b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b3:	8b 00                	mov    (%eax),%eax
801090b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090ba:	89 04 24             	mov    %eax,(%esp)
801090bd:	e8 9a f2 ff ff       	call   8010835c <p2v>
}
801090c2:	c9                   	leave  
801090c3:	c3                   	ret    

801090c4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801090c4:	55                   	push   %ebp
801090c5:	89 e5                	mov    %esp,%ebp
801090c7:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801090ca:	8b 45 10             	mov    0x10(%ebp),%eax
801090cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801090d0:	e9 8b 00 00 00       	jmp    80109160 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
801090d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801090d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801090e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801090e7:	8b 45 08             	mov    0x8(%ebp),%eax
801090ea:	89 04 24             	mov    %eax,(%esp)
801090ed:	e8 75 ff ff ff       	call   80109067 <uva2ka>
801090f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801090f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801090f9:	75 07                	jne    80109102 <copyout+0x3e>
      return -1;
801090fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109100:	eb 6d                	jmp    8010916f <copyout+0xab>
    n = PGSIZE - (va - va0);
80109102:	8b 45 0c             	mov    0xc(%ebp),%eax
80109105:	8b 55 ec             	mov    -0x14(%ebp),%edx
80109108:	89 d1                	mov    %edx,%ecx
8010910a:	29 c1                	sub    %eax,%ecx
8010910c:	89 c8                	mov    %ecx,%eax
8010910e:	05 00 10 00 00       	add    $0x1000,%eax
80109113:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109119:	3b 45 14             	cmp    0x14(%ebp),%eax
8010911c:	76 06                	jbe    80109124 <copyout+0x60>
      n = len;
8010911e:	8b 45 14             	mov    0x14(%ebp),%eax
80109121:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109124:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109127:	8b 55 0c             	mov    0xc(%ebp),%edx
8010912a:	89 d1                	mov    %edx,%ecx
8010912c:	29 c1                	sub    %eax,%ecx
8010912e:	89 c8                	mov    %ecx,%eax
80109130:	03 45 e8             	add    -0x18(%ebp),%eax
80109133:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109136:	89 54 24 08          	mov    %edx,0x8(%esp)
8010913a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010913d:	89 54 24 04          	mov    %edx,0x4(%esp)
80109141:	89 04 24             	mov    %eax,(%esp)
80109144:	e8 78 cc ff ff       	call   80105dc1 <memmove>
    len -= n;
80109149:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010914c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010914f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109152:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109155:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109158:	05 00 10 00 00       	add    $0x1000,%eax
8010915d:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109160:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109164:	0f 85 6b ff ff ff    	jne    801090d5 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010916a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010916f:	c9                   	leave  
80109170:	c3                   	ret    
