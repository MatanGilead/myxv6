
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
8010002d:	b8 2f 40 10 80       	mov    $0x8010402f,%eax
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
8010003a:	c7 44 24 04 b4 92 10 	movl   $0x801092b4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 3c 5b 00 00       	call   80105b8a <initlock>

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
801000bd:	e8 e9 5a 00 00       	call   80105bab <acquire>

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
80100104:	e8 04 5b 00 00       	call   80105c0d <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 9b 55 00 00       	call   801056bf <sleep>
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
8010017c:	e8 8c 5a 00 00       	call   80105c0d <release>
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
80100198:	c7 04 24 bb 92 10 80 	movl   $0x801092bb,(%esp)
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
801001d3:	e8 b7 2e 00 00       	call   8010308f <iderw>
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
801001ef:	c7 04 24 cc 92 10 80 	movl   $0x801092cc,(%esp)
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
80100210:	e8 7a 2e 00 00       	call   8010308f <iderw>
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
80100229:	c7 04 24 d3 92 10 80 	movl   $0x801092d3,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 6a 59 00 00       	call   80105bab <acquire>

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
8010029d:	e8 06 55 00 00       	call   801057a8 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 5f 59 00 00       	call   80105c0d <release>
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
801003bc:	e8 ea 57 00 00       	call   80105bab <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 da 92 10 80 	movl   $0x801092da,(%esp)
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
801004af:	c7 45 ec e3 92 10 80 	movl   $0x801092e3,-0x14(%ebp)
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
80100536:	e8 d2 56 00 00       	call   80105c0d <release>
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
80100562:	c7 04 24 ea 92 10 80 	movl   $0x801092ea,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 f9 92 10 80 	movl   $0x801092f9,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 c5 56 00 00       	call   80105c5c <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 fb 92 10 80 	movl   $0x801092fb,(%esp)
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
801006e2:	e8 e6 57 00 00       	call   80105ecd <memmove>
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
801007dc:	e8 ec 56 00 00       	call   80105ecd <memmove>
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
80100810:	e8 63 58 00 00       	call   80106078 <strlen>
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
80100831:	e8 42 58 00 00       	call   80106078 <strlen>
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
801008b7:	e8 11 56 00 00       	call   80105ecd <memmove>
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
801008eb:	e8 88 57 00 00       	call   80106078 <strlen>
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
8010090c:	e8 67 57 00 00       	call   80106078 <strlen>
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
8010098b:	e8 3d 55 00 00       	call   80105ecd <memmove>
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
801009e7:	e8 e1 54 00 00       	call   80105ecd <memmove>
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
80100a16:	e8 df 53 00 00       	call   80105dfa <memset>
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
80100ae9:	e8 17 6e 00 00       	call   80107905 <uartputc>
80100aee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100af5:	e8 0b 6e 00 00       	call   80107905 <uartputc>
80100afa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100b01:	e8 ff 6d 00 00       	call   80107905 <uartputc>
80100b06:	eb 0b                	jmp    80100b13 <consputc+0x51>
    default:
      uartputc(c);
80100b08:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0b:	89 04 24             	mov    %eax,(%esp)
80100b0e:	e8 f2 6d 00 00       	call   80107905 <uartputc>
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
80100bbc:	e8 ea 4f 00 00       	call   80105bab <acquire>
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
80100c2c:	e8 1d 4c 00 00       	call   8010584e <procdump>
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
80100e51:	e8 22 52 00 00       	call   80106078 <strlen>
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
80100f2f:	e8 44 51 00 00       	call   80106078 <strlen>
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
80101103:	e8 a0 46 00 00       	call   801057a8 <wakeup>
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
80101139:	e8 cf 4a 00 00       	call   80105c0d <release>
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
80101150:	e8 04 11 00 00       	call   80102259 <iunlock>
  target = n;
80101155:	8b 45 10             	mov    0x10(%ebp),%eax
80101158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010115b:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80101162:	e8 44 4a 00 00       	call   80105bab <acquire>
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
80101180:	e8 88 4a 00 00       	call   80105c0d <release>
        ilock(ip);
80101185:	8b 45 08             	mov    0x8(%ebp),%eax
80101188:	89 04 24             	mov    %eax,(%esp)
8010118b:	e8 75 0f 00 00       	call   80102105 <ilock>
        return -1;
80101190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101195:	e9 a9 00 00 00       	jmp    80101243 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010119a:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
801011a1:	80 
801011a2:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801011a9:	e8 11 45 00 00       	call   801056bf <sleep>
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
80101227:	e8 e1 49 00 00       	call   80105c0d <release>
  ilock(ip);
8010122c:	8b 45 08             	mov    0x8(%ebp),%eax
8010122f:	89 04 24             	mov    %eax,(%esp)
80101232:	e8 ce 0e 00 00       	call   80102105 <ilock>

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
80101251:	e8 03 10 00 00       	call   80102259 <iunlock>
  acquire(&cons.lock);
80101256:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
8010125d:	e8 49 49 00 00       	call   80105bab <acquire>
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
80101297:	e8 71 49 00 00       	call   80105c0d <release>
  ilock(ip);
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 5e 0e 00 00       	call   80102105 <ilock>

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
801012b2:	c7 44 24 04 ff 92 10 	movl   $0x801092ff,0x4(%esp)
801012b9:	80 
801012ba:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801012c1:	e8 c4 48 00 00       	call   80105b8a <initlock>
  initlock(&input.lock, "input");
801012c6:	c7 44 24 04 07 93 10 	movl   $0x80109307,0x4(%esp)
801012cd:	80 
801012ce:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801012d5:	e8 b0 48 00 00       	call   80105b8a <initlock>

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
801012ff:	e8 d1 33 00 00       	call   801046d5 <picenable>
  ioapicenable(IRQ_KBD, 0);
80101304:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010130b:	00 
8010130c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80101313:	e8 36 1f 00 00       	call   8010324e <ioapicenable>
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
80101325:	e8 f7 29 00 00       	call   80103d21 <begin_op>
  if((ip = namei(path)) == 0){
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 78 19 00 00       	call   80102cad <namei>
80101335:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101338:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010133c:	75 0f                	jne    8010134d <exec+0x31>
    end_op();
8010133e:	e8 5f 2a 00 00       	call   80103da2 <end_op>
    return -1;
80101343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101348:	e9 ed 03 00 00       	jmp    8010173a <exec+0x41e>
  }
  ilock(ip);
8010134d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101350:	89 04 24             	mov    %eax,(%esp)
80101353:	e8 ad 0d 00 00       	call   80102105 <ilock>
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
8010137f:	e8 7d 12 00 00       	call   80102601 <readi>
80101384:	83 f8 33             	cmp    $0x33,%eax
80101387:	0f 86 62 03 00 00    	jbe    801016ef <exec+0x3d3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
8010138d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80101393:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80101398:	0f 85 54 03 00 00    	jne    801016f2 <exec+0x3d6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
8010139e:	e8 a6 76 00 00       	call   80108a49 <setupkvm>
801013a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801013a6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801013aa:	0f 84 45 03 00 00    	je     801016f5 <exec+0x3d9>
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
801013eb:	e8 11 12 00 00       	call   80102601 <readi>
801013f0:	83 f8 20             	cmp    $0x20,%eax
801013f3:	0f 85 ff 02 00 00    	jne    801016f8 <exec+0x3dc>
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
80101412:	0f 82 e3 02 00 00    	jb     801016fb <exec+0x3df>
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
80101437:	e8 df 79 00 00       	call   80108e1b <allocuvm>
8010143c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010143f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101443:	0f 84 b5 02 00 00    	je     801016fe <exec+0x3e2>
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
80101474:	e8 b3 78 00 00       	call   80108d2c <loaduvm>
80101479:	85 c0                	test   %eax,%eax
8010147b:	0f 88 80 02 00 00    	js     80101701 <exec+0x3e5>
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
801014aa:	e8 e0 0e 00 00       	call   8010238f <iunlockput>
  end_op();
801014af:	e8 ee 28 00 00       	call   80103da2 <end_op>
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
801014e4:	e8 32 79 00 00       	call   80108e1b <allocuvm>
801014e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801014ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801014f0:	0f 84 0e 02 00 00    	je     80101704 <exec+0x3e8>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
801014f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014f9:	2d 00 20 00 00       	sub    $0x2000,%eax
801014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80101502:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101505:	89 04 24             	mov    %eax,(%esp)
80101508:	e8 32 7b 00 00       	call   8010903f <clearpteu>
  sp = sz;
8010150d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101510:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101513:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010151a:	e9 81 00 00 00       	jmp    801015a0 <exec+0x284>
    if(argc >= MAXARG)
8010151f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101523:	0f 87 de 01 00 00    	ja     80101707 <exec+0x3eb>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010152c:	c1 e0 02             	shl    $0x2,%eax
8010152f:	03 45 0c             	add    0xc(%ebp),%eax
80101532:	8b 00                	mov    (%eax),%eax
80101534:	89 04 24             	mov    %eax,(%esp)
80101537:	e8 3c 4b 00 00       	call   80106078 <strlen>
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
80101555:	e8 1e 4b 00 00       	call   80106078 <strlen>
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
8010157f:	e8 80 7c 00 00       	call   80109204 <copyout>
80101584:	85 c0                	test   %eax,%eax
80101586:	0f 88 7e 01 00 00    	js     8010170a <exec+0x3ee>
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
8010161f:	e8 e0 7b 00 00       	call   80109204 <copyout>
80101624:	85 c0                	test   %eax,%eax
80101626:	0f 88 e1 00 00 00    	js     8010170d <exec+0x3f1>
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
80101676:	e8 af 49 00 00       	call   8010602a <safestrcpy>

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
801016bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801016c5:	c7 80 8c 00 00 00 02 	movl   $0x2,0x8c(%eax)
801016cc:	00 00 00 
  #endif
  switchuvm(proc);
801016cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801016d5:	89 04 24             	mov    %eax,(%esp)
801016d8:	e8 5d 74 00 00       	call   80108b3a <switchuvm>
  freevm(oldpgdir);
801016dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801016e0:	89 04 24             	mov    %eax,(%esp)
801016e3:	e8 c9 78 00 00       	call   80108fb1 <freevm>
  return 0;
801016e8:	b8 00 00 00 00       	mov    $0x0,%eax
801016ed:	eb 4b                	jmp    8010173a <exec+0x41e>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
801016ef:	90                   	nop
801016f0:	eb 1c                	jmp    8010170e <exec+0x3f2>
  if(elf.magic != ELF_MAGIC)
    goto bad;
801016f2:	90                   	nop
801016f3:	eb 19                	jmp    8010170e <exec+0x3f2>

  if((pgdir = setupkvm()) == 0)
    goto bad;
801016f5:	90                   	nop
801016f6:	eb 16                	jmp    8010170e <exec+0x3f2>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
801016f8:	90                   	nop
801016f9:	eb 13                	jmp    8010170e <exec+0x3f2>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
801016fb:	90                   	nop
801016fc:	eb 10                	jmp    8010170e <exec+0x3f2>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801016fe:	90                   	nop
801016ff:	eb 0d                	jmp    8010170e <exec+0x3f2>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101701:	90                   	nop
80101702:	eb 0a                	jmp    8010170e <exec+0x3f2>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101704:	90                   	nop
80101705:	eb 07                	jmp    8010170e <exec+0x3f2>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101707:	90                   	nop
80101708:	eb 04                	jmp    8010170e <exec+0x3f2>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
8010170a:	90                   	nop
8010170b:	eb 01                	jmp    8010170e <exec+0x3f2>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010170d:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010170e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101712:	74 0b                	je     8010171f <exec+0x403>
    freevm(pgdir);
80101714:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101717:	89 04 24             	mov    %eax,(%esp)
8010171a:	e8 92 78 00 00       	call   80108fb1 <freevm>
  if(ip){
8010171f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101723:	74 10                	je     80101735 <exec+0x419>
    iunlockput(ip);
80101725:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101728:	89 04 24             	mov    %eax,(%esp)
8010172b:	e8 5f 0c 00 00       	call   8010238f <iunlockput>
    end_op();
80101730:	e8 6d 26 00 00       	call   80103da2 <end_op>
  }
  return -1;
80101735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010173a:	c9                   	leave  
8010173b:	c3                   	ret    

8010173c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010173c:	55                   	push   %ebp
8010173d:	89 e5                	mov    %esp,%ebp
8010173f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80101742:	c7 44 24 04 0d 93 10 	movl   $0x8010930d,0x4(%esp)
80101749:	80 
8010174a:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101751:	e8 34 44 00 00       	call   80105b8a <initlock>
}
80101756:	c9                   	leave  
80101757:	c3                   	ret    

80101758 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101758:	55                   	push   %ebp
80101759:	89 e5                	mov    %esp,%ebp
8010175b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010175e:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101765:	e8 41 44 00 00       	call   80105bab <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010176a:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
80101771:	eb 29                	jmp    8010179c <filealloc+0x44>
    if(f->ref == 0){
80101773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101776:	8b 40 04             	mov    0x4(%eax),%eax
80101779:	85 c0                	test   %eax,%eax
8010177b:	75 1b                	jne    80101798 <filealloc+0x40>
      f->ref = 1;
8010177d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101780:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101787:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
8010178e:	e8 7a 44 00 00       	call   80105c0d <release>
      return f;
80101793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101796:	eb 1e                	jmp    801017b6 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101798:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010179c:	81 7d f4 f4 29 11 80 	cmpl   $0x801129f4,-0xc(%ebp)
801017a3:	72 ce                	jb     80101773 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801017a5:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
801017ac:	e8 5c 44 00 00       	call   80105c0d <release>
  return 0;
801017b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801017b6:	c9                   	leave  
801017b7:	c3                   	ret    

801017b8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801017b8:	55                   	push   %ebp
801017b9:	89 e5                	mov    %esp,%ebp
801017bb:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801017be:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
801017c5:	e8 e1 43 00 00       	call   80105bab <acquire>
  if(f->ref < 1)
801017ca:	8b 45 08             	mov    0x8(%ebp),%eax
801017cd:	8b 40 04             	mov    0x4(%eax),%eax
801017d0:	85 c0                	test   %eax,%eax
801017d2:	7f 0c                	jg     801017e0 <filedup+0x28>
    panic("filedup");
801017d4:	c7 04 24 14 93 10 80 	movl   $0x80109314,(%esp)
801017db:	e8 5d ed ff ff       	call   8010053d <panic>
  f->ref++;
801017e0:	8b 45 08             	mov    0x8(%ebp),%eax
801017e3:	8b 40 04             	mov    0x4(%eax),%eax
801017e6:	8d 50 01             	lea    0x1(%eax),%edx
801017e9:	8b 45 08             	mov    0x8(%ebp),%eax
801017ec:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801017ef:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
801017f6:	e8 12 44 00 00       	call   80105c0d <release>
  return f;
801017fb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801017fe:	c9                   	leave  
801017ff:	c3                   	ret    

80101800 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101800:	55                   	push   %ebp
80101801:	89 e5                	mov    %esp,%ebp
80101803:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101806:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
8010180d:	e8 99 43 00 00       	call   80105bab <acquire>
  if(f->ref < 1)
80101812:	8b 45 08             	mov    0x8(%ebp),%eax
80101815:	8b 40 04             	mov    0x4(%eax),%eax
80101818:	85 c0                	test   %eax,%eax
8010181a:	7f 0c                	jg     80101828 <fileclose+0x28>
    panic("fileclose");
8010181c:	c7 04 24 1c 93 10 80 	movl   $0x8010931c,(%esp)
80101823:	e8 15 ed ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101828:	8b 45 08             	mov    0x8(%ebp),%eax
8010182b:	8b 40 04             	mov    0x4(%eax),%eax
8010182e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101831:	8b 45 08             	mov    0x8(%ebp),%eax
80101834:	89 50 04             	mov    %edx,0x4(%eax)
80101837:	8b 45 08             	mov    0x8(%ebp),%eax
8010183a:	8b 40 04             	mov    0x4(%eax),%eax
8010183d:	85 c0                	test   %eax,%eax
8010183f:	7e 11                	jle    80101852 <fileclose+0x52>
    release(&ftable.lock);
80101841:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101848:	e8 c0 43 00 00       	call   80105c0d <release>
    return;
8010184d:	e9 82 00 00 00       	jmp    801018d4 <fileclose+0xd4>
  }
  ff = *f;
80101852:	8b 45 08             	mov    0x8(%ebp),%eax
80101855:	8b 10                	mov    (%eax),%edx
80101857:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010185a:	8b 50 04             	mov    0x4(%eax),%edx
8010185d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101860:	8b 50 08             	mov    0x8(%eax),%edx
80101863:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101866:	8b 50 0c             	mov    0xc(%eax),%edx
80101869:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010186c:	8b 50 10             	mov    0x10(%eax),%edx
8010186f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101872:	8b 40 14             	mov    0x14(%eax),%eax
80101875:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101878:	8b 45 08             	mov    0x8(%ebp),%eax
8010187b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010188b:	c7 04 24 60 20 11 80 	movl   $0x80112060,(%esp)
80101892:	e8 76 43 00 00       	call   80105c0d <release>
  
  if(ff.type == FD_PIPE)
80101897:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010189a:	83 f8 01             	cmp    $0x1,%eax
8010189d:	75 18                	jne    801018b7 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010189f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801018a3:	0f be d0             	movsbl %al,%edx
801018a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ad:	89 04 24             	mov    %eax,(%esp)
801018b0:	e8 da 30 00 00       	call   8010498f <pipeclose>
801018b5:	eb 1d                	jmp    801018d4 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801018b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801018ba:	83 f8 02             	cmp    $0x2,%eax
801018bd:	75 15                	jne    801018d4 <fileclose+0xd4>
    begin_op();
801018bf:	e8 5d 24 00 00       	call   80103d21 <begin_op>
    iput(ff.ip);
801018c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c7:	89 04 24             	mov    %eax,(%esp)
801018ca:	e8 ef 09 00 00       	call   801022be <iput>
    end_op();
801018cf:	e8 ce 24 00 00       	call   80103da2 <end_op>
  }
}
801018d4:	c9                   	leave  
801018d5:	c3                   	ret    

801018d6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801018dc:	8b 45 08             	mov    0x8(%ebp),%eax
801018df:	8b 00                	mov    (%eax),%eax
801018e1:	83 f8 02             	cmp    $0x2,%eax
801018e4:	75 38                	jne    8010191e <filestat+0x48>
    ilock(f->ip);
801018e6:	8b 45 08             	mov    0x8(%ebp),%eax
801018e9:	8b 40 10             	mov    0x10(%eax),%eax
801018ec:	89 04 24             	mov    %eax,(%esp)
801018ef:	e8 11 08 00 00       	call   80102105 <ilock>
    stati(f->ip, st);
801018f4:	8b 45 08             	mov    0x8(%ebp),%eax
801018f7:	8b 40 10             	mov    0x10(%eax),%eax
801018fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801018fd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101901:	89 04 24             	mov    %eax,(%esp)
80101904:	e8 b3 0c 00 00       	call   801025bc <stati>
    iunlock(f->ip);
80101909:	8b 45 08             	mov    0x8(%ebp),%eax
8010190c:	8b 40 10             	mov    0x10(%eax),%eax
8010190f:	89 04 24             	mov    %eax,(%esp)
80101912:	e8 42 09 00 00       	call   80102259 <iunlock>
    return 0;
80101917:	b8 00 00 00 00       	mov    $0x0,%eax
8010191c:	eb 05                	jmp    80101923 <filestat+0x4d>
  }
  return -1;
8010191e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101923:	c9                   	leave  
80101924:	c3                   	ret    

80101925 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101925:	55                   	push   %ebp
80101926:	89 e5                	mov    %esp,%ebp
80101928:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101932:	84 c0                	test   %al,%al
80101934:	75 0a                	jne    80101940 <fileread+0x1b>
    return -1;
80101936:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010193b:	e9 9f 00 00 00       	jmp    801019df <fileread+0xba>
  if(f->type == FD_PIPE)
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	8b 00                	mov    (%eax),%eax
80101945:	83 f8 01             	cmp    $0x1,%eax
80101948:	75 1e                	jne    80101968 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010194a:	8b 45 08             	mov    0x8(%ebp),%eax
8010194d:	8b 40 0c             	mov    0xc(%eax),%eax
80101950:	8b 55 10             	mov    0x10(%ebp),%edx
80101953:	89 54 24 08          	mov    %edx,0x8(%esp)
80101957:	8b 55 0c             	mov    0xc(%ebp),%edx
8010195a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010195e:	89 04 24             	mov    %eax,(%esp)
80101961:	e8 ab 31 00 00       	call   80104b11 <piperead>
80101966:	eb 77                	jmp    801019df <fileread+0xba>
  if(f->type == FD_INODE){
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	8b 00                	mov    (%eax),%eax
8010196d:	83 f8 02             	cmp    $0x2,%eax
80101970:	75 61                	jne    801019d3 <fileread+0xae>
    ilock(f->ip);
80101972:	8b 45 08             	mov    0x8(%ebp),%eax
80101975:	8b 40 10             	mov    0x10(%eax),%eax
80101978:	89 04 24             	mov    %eax,(%esp)
8010197b:	e8 85 07 00 00       	call   80102105 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101980:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101983:	8b 45 08             	mov    0x8(%ebp),%eax
80101986:	8b 50 14             	mov    0x14(%eax),%edx
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	8b 40 10             	mov    0x10(%eax),%eax
8010198f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101993:	89 54 24 08          	mov    %edx,0x8(%esp)
80101997:	8b 55 0c             	mov    0xc(%ebp),%edx
8010199a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010199e:	89 04 24             	mov    %eax,(%esp)
801019a1:	e8 5b 0c 00 00       	call   80102601 <readi>
801019a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801019a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801019ad:	7e 11                	jle    801019c0 <fileread+0x9b>
      f->off += r;
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	8b 50 14             	mov    0x14(%eax),%edx
801019b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b8:	01 c2                	add    %eax,%edx
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	8b 40 10             	mov    0x10(%eax),%eax
801019c6:	89 04 24             	mov    %eax,(%esp)
801019c9:	e8 8b 08 00 00       	call   80102259 <iunlock>
    return r;
801019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d1:	eb 0c                	jmp    801019df <fileread+0xba>
  }
  panic("fileread");
801019d3:	c7 04 24 26 93 10 80 	movl   $0x80109326,(%esp)
801019da:	e8 5e eb ff ff       	call   8010053d <panic>
}
801019df:	c9                   	leave  
801019e0:	c3                   	ret    

801019e1 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801019e1:	55                   	push   %ebp
801019e2:	89 e5                	mov    %esp,%ebp
801019e4:	53                   	push   %ebx
801019e5:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801019ef:	84 c0                	test   %al,%al
801019f1:	75 0a                	jne    801019fd <filewrite+0x1c>
    return -1;
801019f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019f8:	e9 23 01 00 00       	jmp    80101b20 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 00                	mov    (%eax),%eax
80101a02:	83 f8 01             	cmp    $0x1,%eax
80101a05:	75 21                	jne    80101a28 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	8b 40 0c             	mov    0xc(%eax),%eax
80101a0d:	8b 55 10             	mov    0x10(%ebp),%edx
80101a10:	89 54 24 08          	mov    %edx,0x8(%esp)
80101a14:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a17:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a1b:	89 04 24             	mov    %eax,(%esp)
80101a1e:	e8 fe 2f 00 00       	call   80104a21 <pipewrite>
80101a23:	e9 f8 00 00 00       	jmp    80101b20 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	8b 00                	mov    (%eax),%eax
80101a2d:	83 f8 02             	cmp    $0x2,%eax
80101a30:	0f 85 de 00 00 00    	jne    80101b14 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101a36:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101a3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101a44:	e9 a8 00 00 00       	jmp    80101af1 <filewrite+0x110>
      int n1 = n - i;
80101a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4c:	8b 55 10             	mov    0x10(%ebp),%edx
80101a4f:	89 d1                	mov    %edx,%ecx
80101a51:	29 c1                	sub    %eax,%ecx
80101a53:	89 c8                	mov    %ecx,%eax
80101a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101a5e:	7e 06                	jle    80101a66 <filewrite+0x85>
        n1 = max;
80101a60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a63:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101a66:	e8 b6 22 00 00       	call   80103d21 <begin_op>
      ilock(f->ip);
80101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6e:	8b 40 10             	mov    0x10(%eax),%eax
80101a71:	89 04 24             	mov    %eax,(%esp)
80101a74:	e8 8c 06 00 00       	call   80102105 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101a79:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7f:	8b 48 14             	mov    0x14(%eax),%ecx
80101a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a85:	89 c2                	mov    %eax,%edx
80101a87:	03 55 0c             	add    0xc(%ebp),%edx
80101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8d:	8b 40 10             	mov    0x10(%eax),%eax
80101a90:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101a94:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101a98:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a9c:	89 04 24             	mov    %eax,(%esp)
80101a9f:	e8 c8 0c 00 00       	call   8010276c <writei>
80101aa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101aa7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101aab:	7e 11                	jle    80101abe <filewrite+0xdd>
        f->off += r;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	8b 50 14             	mov    0x14(%eax),%edx
80101ab3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ab6:	01 c2                	add    %eax,%edx
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101abe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac1:	8b 40 10             	mov    0x10(%eax),%eax
80101ac4:	89 04 24             	mov    %eax,(%esp)
80101ac7:	e8 8d 07 00 00       	call   80102259 <iunlock>
      end_op();
80101acc:	e8 d1 22 00 00       	call   80103da2 <end_op>

      if(r < 0)
80101ad1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101ad5:	78 28                	js     80101aff <filewrite+0x11e>
        break;
      if(r != n1)
80101ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ada:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101add:	74 0c                	je     80101aeb <filewrite+0x10a>
        panic("short filewrite");
80101adf:	c7 04 24 2f 93 10 80 	movl   $0x8010932f,(%esp)
80101ae6:	e8 52 ea ff ff       	call   8010053d <panic>
      i += r;
80101aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101aee:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101af7:	0f 8c 4c ff ff ff    	jl     80101a49 <filewrite+0x68>
80101afd:	eb 01                	jmp    80101b00 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101aff:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b03:	3b 45 10             	cmp    0x10(%ebp),%eax
80101b06:	75 05                	jne    80101b0d <filewrite+0x12c>
80101b08:	8b 45 10             	mov    0x10(%ebp),%eax
80101b0b:	eb 05                	jmp    80101b12 <filewrite+0x131>
80101b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b12:	eb 0c                	jmp    80101b20 <filewrite+0x13f>
  }
  panic("filewrite");
80101b14:	c7 04 24 3f 93 10 80 	movl   $0x8010933f,(%esp)
80101b1b:	e8 1d ea ff ff       	call   8010053d <panic>
}
80101b20:	83 c4 24             	add    $0x24,%esp
80101b23:	5b                   	pop    %ebx
80101b24:	5d                   	pop    %ebp
80101b25:	c3                   	ret    
	...

80101b28 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101b28:	55                   	push   %ebp
80101b29:	89 e5                	mov    %esp,%ebp
80101b2b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b31:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101b38:	00 
80101b39:	89 04 24             	mov    %eax,(%esp)
80101b3c:	e8 65 e6 ff ff       	call   801001a6 <bread>
80101b41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b47:	83 c0 18             	add    $0x18,%eax
80101b4a:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101b51:	00 
80101b52:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b59:	89 04 24             	mov    %eax,(%esp)
80101b5c:	e8 6c 43 00 00       	call   80105ecd <memmove>
  brelse(bp);
80101b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b64:	89 04 24             	mov    %eax,(%esp)
80101b67:	e8 ab e6 ff ff       	call   80100217 <brelse>
}
80101b6c:	c9                   	leave  
80101b6d:	c3                   	ret    

80101b6e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101b6e:	55                   	push   %ebp
80101b6f:	89 e5                	mov    %esp,%ebp
80101b71:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101b74:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b7e:	89 04 24             	mov    %eax,(%esp)
80101b81:	e8 20 e6 ff ff       	call   801001a6 <bread>
80101b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8c:	83 c0 18             	add    $0x18,%eax
80101b8f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101b96:	00 
80101b97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101b9e:	00 
80101b9f:	89 04 24             	mov    %eax,(%esp)
80101ba2:	e8 53 42 00 00       	call   80105dfa <memset>
  log_write(bp);
80101ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101baa:	89 04 24             	mov    %eax,(%esp)
80101bad:	e8 74 23 00 00       	call   80103f26 <log_write>
  brelse(bp);
80101bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb5:	89 04 24             	mov    %eax,(%esp)
80101bb8:	e8 5a e6 ff ff       	call   80100217 <brelse>
}
80101bbd:	c9                   	leave  
80101bbe:	c3                   	ret    

80101bbf <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101bbf:	55                   	push   %ebp
80101bc0:	89 e5                	mov    %esp,%ebp
80101bc2:	53                   	push   %ebx
80101bc3:	83 ec 24             	sub    $0x24,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101bc6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101bcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101bd4:	e9 11 01 00 00       	jmp    80101cea <balloc+0x12b>
    bp = bread(dev, BBLOCK(b, sb));
80101bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101be2:	85 c0                	test   %eax,%eax
80101be4:	0f 48 c2             	cmovs  %edx,%eax
80101be7:	c1 f8 0c             	sar    $0xc,%eax
80101bea:	89 c2                	mov    %eax,%edx
80101bec:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101bf1:	01 d0                	add    %edx,%eax
80101bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	89 04 24             	mov    %eax,(%esp)
80101bfd:	e8 a4 e5 ff ff       	call   801001a6 <bread>
80101c02:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101c05:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c0c:	e9 a7 00 00 00       	jmp    80101cb8 <balloc+0xf9>
      m = 1 << (bi % 8);
80101c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c14:	89 c2                	mov    %eax,%edx
80101c16:	c1 fa 1f             	sar    $0x1f,%edx
80101c19:	c1 ea 1d             	shr    $0x1d,%edx
80101c1c:	01 d0                	add    %edx,%eax
80101c1e:	83 e0 07             	and    $0x7,%eax
80101c21:	29 d0                	sub    %edx,%eax
80101c23:	ba 01 00 00 00       	mov    $0x1,%edx
80101c28:	89 d3                	mov    %edx,%ebx
80101c2a:	89 c1                	mov    %eax,%ecx
80101c2c:	d3 e3                	shl    %cl,%ebx
80101c2e:	89 d8                	mov    %ebx,%eax
80101c30:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c36:	8d 50 07             	lea    0x7(%eax),%edx
80101c39:	85 c0                	test   %eax,%eax
80101c3b:	0f 48 c2             	cmovs  %edx,%eax
80101c3e:	c1 f8 03             	sar    $0x3,%eax
80101c41:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c44:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101c49:	0f b6 c0             	movzbl %al,%eax
80101c4c:	23 45 e8             	and    -0x18(%ebp),%eax
80101c4f:	85 c0                	test   %eax,%eax
80101c51:	75 61                	jne    80101cb4 <balloc+0xf5>
        bp->data[bi/8] |= m;  // Mark block in use.
80101c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c56:	8d 50 07             	lea    0x7(%eax),%edx
80101c59:	85 c0                	test   %eax,%eax
80101c5b:	0f 48 c2             	cmovs  %edx,%eax
80101c5e:	c1 f8 03             	sar    $0x3,%eax
80101c61:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c64:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101c69:	89 d1                	mov    %edx,%ecx
80101c6b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101c6e:	09 ca                	or     %ecx,%edx
80101c70:	89 d1                	mov    %edx,%ecx
80101c72:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c75:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101c79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c7c:	89 04 24             	mov    %eax,(%esp)
80101c7f:	e8 a2 22 00 00       	call   80103f26 <log_write>
        brelse(bp);
80101c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c87:	89 04 24             	mov    %eax,(%esp)
80101c8a:	e8 88 e5 ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c95:	01 c2                	add    %eax,%edx
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c9e:	89 04 24             	mov    %eax,(%esp)
80101ca1:	e8 c8 fe ff ff       	call   80101b6e <bzero>
        return b + bi;
80101ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cac:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101cae:	83 c4 24             	add    $0x24,%esp
80101cb1:	5b                   	pop    %ebx
80101cb2:	5d                   	pop    %ebp
80101cb3:	c3                   	ret    
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101cb4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cb8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101cbf:	7f 17                	jg     80101cd8 <balloc+0x119>
80101cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc7:	01 d0                	add    %edx,%eax
80101cc9:	89 c2                	mov    %eax,%edx
80101ccb:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101cd0:	39 c2                	cmp    %eax,%edx
80101cd2:	0f 82 39 ff ff ff    	jb     80101c11 <balloc+0x52>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101cd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cdb:	89 04 24             	mov    %eax,(%esp)
80101cde:	e8 34 e5 ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101ce3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ced:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101cf2:	39 c2                	cmp    %eax,%edx
80101cf4:	0f 82 df fe ff ff    	jb     80101bd9 <balloc+0x1a>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101cfa:	c7 04 24 4c 93 10 80 	movl   $0x8010934c,(%esp)
80101d01:	e8 37 e8 ff ff       	call   8010053d <panic>

80101d06 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101d06:	55                   	push   %ebp
80101d07:	89 e5                	mov    %esp,%ebp
80101d09:	53                   	push   %ebx
80101d0a:	83 ec 24             	sub    $0x24,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101d0d:	c7 44 24 04 60 2a 11 	movl   $0x80112a60,0x4(%esp)
80101d14:	80 
80101d15:	8b 45 08             	mov    0x8(%ebp),%eax
80101d18:	89 04 24             	mov    %eax,(%esp)
80101d1b:	e8 08 fe ff ff       	call   80101b28 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101d20:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d23:	89 c2                	mov    %eax,%edx
80101d25:	c1 ea 0c             	shr    $0xc,%edx
80101d28:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101d2d:	01 c2                	add    %eax,%edx
80101d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d32:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d36:	89 04 24             	mov    %eax,(%esp)
80101d39:	e8 68 e4 ff ff       	call   801001a6 <bread>
80101d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d44:	25 ff 0f 00 00       	and    $0xfff,%eax
80101d49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4f:	89 c2                	mov    %eax,%edx
80101d51:	c1 fa 1f             	sar    $0x1f,%edx
80101d54:	c1 ea 1d             	shr    $0x1d,%edx
80101d57:	01 d0                	add    %edx,%eax
80101d59:	83 e0 07             	and    $0x7,%eax
80101d5c:	29 d0                	sub    %edx,%eax
80101d5e:	ba 01 00 00 00       	mov    $0x1,%edx
80101d63:	89 d3                	mov    %edx,%ebx
80101d65:	89 c1                	mov    %eax,%ecx
80101d67:	d3 e3                	shl    %cl,%ebx
80101d69:	89 d8                	mov    %ebx,%eax
80101d6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d71:	8d 50 07             	lea    0x7(%eax),%edx
80101d74:	85 c0                	test   %eax,%eax
80101d76:	0f 48 c2             	cmovs  %edx,%eax
80101d79:	c1 f8 03             	sar    $0x3,%eax
80101d7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7f:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101d84:	0f b6 c0             	movzbl %al,%eax
80101d87:	23 45 ec             	and    -0x14(%ebp),%eax
80101d8a:	85 c0                	test   %eax,%eax
80101d8c:	75 0c                	jne    80101d9a <bfree+0x94>
    panic("freeing free block");
80101d8e:	c7 04 24 62 93 10 80 	movl   $0x80109362,(%esp)
80101d95:	e8 a3 e7 ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9d:	8d 50 07             	lea    0x7(%eax),%edx
80101da0:	85 c0                	test   %eax,%eax
80101da2:	0f 48 c2             	cmovs  %edx,%eax
80101da5:	c1 f8 03             	sar    $0x3,%eax
80101da8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dab:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101db0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101db3:	f7 d1                	not    %ecx
80101db5:	21 ca                	and    %ecx,%edx
80101db7:	89 d1                	mov    %edx,%ecx
80101db9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dbc:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc3:	89 04 24             	mov    %eax,(%esp)
80101dc6:	e8 5b 21 00 00       	call   80103f26 <log_write>
  brelse(bp);
80101dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dce:	89 04 24             	mov    %eax,(%esp)
80101dd1:	e8 41 e4 ff ff       	call   80100217 <brelse>
}
80101dd6:	83 c4 24             	add    $0x24,%esp
80101dd9:	5b                   	pop    %ebx
80101dda:	5d                   	pop    %ebp
80101ddb:	c3                   	ret    

80101ddc <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101ddc:	55                   	push   %ebp
80101ddd:	89 e5                	mov    %esp,%ebp
80101ddf:	57                   	push   %edi
80101de0:	56                   	push   %esi
80101de1:	53                   	push   %ebx
80101de2:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
80101de5:	c7 44 24 04 75 93 10 	movl   $0x80109375,0x4(%esp)
80101dec:	80 
80101ded:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80101df4:	e8 91 3d 00 00       	call   80105b8a <initlock>
  readsb(dev, &sb);
80101df9:	c7 44 24 04 60 2a 11 	movl   $0x80112a60,0x4(%esp)
80101e00:	80 
80101e01:	8b 45 08             	mov    0x8(%ebp),%eax
80101e04:	89 04 24             	mov    %eax,(%esp)
80101e07:	e8 1c fd ff ff       	call   80101b28 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101e0c:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101e11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101e14:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101e1a:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101e20:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101e26:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101e2c:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101e32:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101e37:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101e3d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101e41:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101e45:	89 74 24 14          	mov    %esi,0x14(%esp)
80101e49:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101e4d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101e51:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e55:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101e58:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e5c:	c7 04 24 7c 93 10 80 	movl   $0x8010937c,(%esp)
80101e63:	e8 39 e5 ff ff       	call   801003a1 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101e68:	83 c4 3c             	add    $0x3c,%esp
80101e6b:	5b                   	pop    %ebx
80101e6c:	5e                   	pop    %esi
80101e6d:	5f                   	pop    %edi
80101e6e:	5d                   	pop    %ebp
80101e6f:	c3                   	ret    

80101e70 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101e70:	55                   	push   %ebp
80101e71:	89 e5                	mov    %esp,%ebp
80101e73:	83 ec 38             	sub    $0x38,%esp
80101e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e79:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101e7d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101e84:	e9 9e 00 00 00       	jmp    80101f27 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e8c:	89 c2                	mov    %eax,%edx
80101e8e:	c1 ea 03             	shr    $0x3,%edx
80101e91:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101e96:	01 d0                	add    %edx,%eax
80101e98:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9f:	89 04 24             	mov    %eax,(%esp)
80101ea2:	e8 ff e2 ff ff       	call   801001a6 <bread>
80101ea7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ead:	8d 50 18             	lea    0x18(%eax),%edx
80101eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb3:	83 e0 07             	and    $0x7,%eax
80101eb6:	c1 e0 06             	shl    $0x6,%eax
80101eb9:	01 d0                	add    %edx,%eax
80101ebb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec1:	0f b7 00             	movzwl (%eax),%eax
80101ec4:	66 85 c0             	test   %ax,%ax
80101ec7:	75 4f                	jne    80101f18 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101ec9:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101ed0:	00 
80101ed1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101ed8:	00 
80101ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101edc:	89 04 24             	mov    %eax,(%esp)
80101edf:	e8 16 3f 00 00       	call   80105dfa <memset>
      dip->type = type;
80101ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101eeb:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef1:	89 04 24             	mov    %eax,(%esp)
80101ef4:	e8 2d 20 00 00       	call   80103f26 <log_write>
      brelse(bp);
80101ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efc:	89 04 24             	mov    %eax,(%esp)
80101eff:	e8 13 e3 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f07:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	89 04 24             	mov    %eax,(%esp)
80101f11:	e8 eb 00 00 00       	call   80102001 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101f16:	c9                   	leave  
80101f17:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f1b:	89 04 24             	mov    %eax,(%esp)
80101f1e:	e8 f4 e2 ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101f23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f2a:	a1 68 2a 11 80       	mov    0x80112a68,%eax
80101f2f:	39 c2                	cmp    %eax,%edx
80101f31:	0f 82 52 ff ff ff    	jb     80101e89 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101f37:	c7 04 24 cf 93 10 80 	movl   $0x801093cf,(%esp)
80101f3e:	e8 fa e5 ff ff       	call   8010053d <panic>

80101f43 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101f43:	55                   	push   %ebp
80101f44:	89 e5                	mov    %esp,%ebp
80101f46:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	8b 40 04             	mov    0x4(%eax),%eax
80101f4f:	89 c2                	mov    %eax,%edx
80101f51:	c1 ea 03             	shr    $0x3,%edx
80101f54:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101f59:	01 c2                	add    %eax,%edx
80101f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5e:	8b 00                	mov    (%eax),%eax
80101f60:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f64:	89 04 24             	mov    %eax,(%esp)
80101f67:	e8 3a e2 ff ff       	call   801001a6 <bread>
80101f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f72:	8d 50 18             	lea    0x18(%eax),%edx
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 40 04             	mov    0x4(%eax),%eax
80101f7b:	83 e0 07             	and    $0x7,%eax
80101f7e:	c1 e0 06             	shl    $0x6,%eax
80101f81:	01 d0                	add    %edx,%eax
80101f83:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101f86:	8b 45 08             	mov    0x8(%ebp),%eax
80101f89:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f90:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101f93:	8b 45 08             	mov    0x8(%ebp),%eax
80101f96:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fab:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101faf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb9:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	8b 50 18             	mov    0x18(%eax),%edx
80101fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	8d 50 1c             	lea    0x1c(%eax),%edx
80101fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd2:	83 c0 0c             	add    $0xc,%eax
80101fd5:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101fdc:	00 
80101fdd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fe1:	89 04 24             	mov    %eax,(%esp)
80101fe4:	e8 e4 3e 00 00       	call   80105ecd <memmove>
  log_write(bp);
80101fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fec:	89 04 24             	mov    %eax,(%esp)
80101fef:	e8 32 1f 00 00       	call   80103f26 <log_write>
  brelse(bp);
80101ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ff7:	89 04 24             	mov    %eax,(%esp)
80101ffa:	e8 18 e2 ff ff       	call   80100217 <brelse>
}
80101fff:	c9                   	leave  
80102000:	c3                   	ret    

80102001 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80102001:	55                   	push   %ebp
80102002:	89 e5                	mov    %esp,%ebp
80102004:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80102007:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010200e:	e8 98 3b 00 00       	call   80105bab <acquire>

  // Is the inode already cached?
  empty = 0;
80102013:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010201a:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80102021:	eb 59                	jmp    8010207c <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80102023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102026:	8b 40 08             	mov    0x8(%eax),%eax
80102029:	85 c0                	test   %eax,%eax
8010202b:	7e 35                	jle    80102062 <iget+0x61>
8010202d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102030:	8b 00                	mov    (%eax),%eax
80102032:	3b 45 08             	cmp    0x8(%ebp),%eax
80102035:	75 2b                	jne    80102062 <iget+0x61>
80102037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010203a:	8b 40 04             	mov    0x4(%eax),%eax
8010203d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102040:	75 20                	jne    80102062 <iget+0x61>
      ip->ref++;
80102042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102045:	8b 40 08             	mov    0x8(%eax),%eax
80102048:	8d 50 01             	lea    0x1(%eax),%edx
8010204b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010204e:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80102051:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80102058:	e8 b0 3b 00 00       	call   80105c0d <release>
      return ip;
8010205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102060:	eb 6f                	jmp    801020d1 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80102062:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102066:	75 10                	jne    80102078 <iget+0x77>
80102068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010206b:	8b 40 08             	mov    0x8(%eax),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 06                	jne    80102078 <iget+0x77>
      empty = ip;
80102072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102075:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80102078:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010207c:	81 7d f4 54 3a 11 80 	cmpl   $0x80113a54,-0xc(%ebp)
80102083:	72 9e                	jb     80102023 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80102085:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102089:	75 0c                	jne    80102097 <iget+0x96>
    panic("iget: no inodes");
8010208b:	c7 04 24 e1 93 10 80 	movl   $0x801093e1,(%esp)
80102092:	e8 a6 e4 ff ff       	call   8010053d <panic>

  ip = empty;
80102097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010209a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010209d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a0:	8b 55 08             	mov    0x8(%ebp),%edx
801020a3:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801020a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801020ab:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801020c2:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801020c9:	e8 3f 3b 00 00       	call   80105c0d <release>

  return ip;
801020ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801020d1:	c9                   	leave  
801020d2:	c3                   	ret    

801020d3 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801020d3:	55                   	push   %ebp
801020d4:	89 e5                	mov    %esp,%ebp
801020d6:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801020d9:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801020e0:	e8 c6 3a 00 00       	call   80105bab <acquire>
  ip->ref++;
801020e5:	8b 45 08             	mov    0x8(%ebp),%eax
801020e8:	8b 40 08             	mov    0x8(%eax),%eax
801020eb:	8d 50 01             	lea    0x1(%eax),%edx
801020ee:	8b 45 08             	mov    0x8(%ebp),%eax
801020f1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801020f4:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801020fb:	e8 0d 3b 00 00       	call   80105c0d <release>
  return ip;
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102103:	c9                   	leave  
80102104:	c3                   	ret    

80102105 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80102105:	55                   	push   %ebp
80102106:	89 e5                	mov    %esp,%ebp
80102108:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010210b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010210f:	74 0a                	je     8010211b <ilock+0x16>
80102111:	8b 45 08             	mov    0x8(%ebp),%eax
80102114:	8b 40 08             	mov    0x8(%eax),%eax
80102117:	85 c0                	test   %eax,%eax
80102119:	7f 0c                	jg     80102127 <ilock+0x22>
    panic("ilock");
8010211b:	c7 04 24 f1 93 10 80 	movl   $0x801093f1,(%esp)
80102122:	e8 16 e4 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102127:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010212e:	e8 78 3a 00 00       	call   80105bab <acquire>
  while(ip->flags & I_BUSY)
80102133:	eb 13                	jmp    80102148 <ilock+0x43>
    sleep(ip, &icache.lock);
80102135:	c7 44 24 04 80 2a 11 	movl   $0x80112a80,0x4(%esp)
8010213c:	80 
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	89 04 24             	mov    %eax,(%esp)
80102143:	e8 77 35 00 00       	call   801056bf <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80102148:	8b 45 08             	mov    0x8(%ebp),%eax
8010214b:	8b 40 0c             	mov    0xc(%eax),%eax
8010214e:	83 e0 01             	and    $0x1,%eax
80102151:	84 c0                	test   %al,%al
80102153:	75 e0                	jne    80102135 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80102155:	8b 45 08             	mov    0x8(%ebp),%eax
80102158:	8b 40 0c             	mov    0xc(%eax),%eax
8010215b:	89 c2                	mov    %eax,%edx
8010215d:	83 ca 01             	or     $0x1,%edx
80102160:	8b 45 08             	mov    0x8(%ebp),%eax
80102163:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80102166:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010216d:	e8 9b 3a 00 00       	call   80105c0d <release>

  if(!(ip->flags & I_VALID)){
80102172:	8b 45 08             	mov    0x8(%ebp),%eax
80102175:	8b 40 0c             	mov    0xc(%eax),%eax
80102178:	83 e0 02             	and    $0x2,%eax
8010217b:	85 c0                	test   %eax,%eax
8010217d:	0f 85 d4 00 00 00    	jne    80102257 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80102183:	8b 45 08             	mov    0x8(%ebp),%eax
80102186:	8b 40 04             	mov    0x4(%eax),%eax
80102189:	89 c2                	mov    %eax,%edx
8010218b:	c1 ea 03             	shr    $0x3,%edx
8010218e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80102193:	01 c2                	add    %eax,%edx
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 00                	mov    (%eax),%eax
8010219a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010219e:	89 04 24             	mov    %eax,(%esp)
801021a1:	e8 00 e0 ff ff       	call   801001a6 <bread>
801021a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ac:	8d 50 18             	lea    0x18(%eax),%edx
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	8b 40 04             	mov    0x4(%eax),%eax
801021b5:	83 e0 07             	and    $0x7,%eax
801021b8:	c1 e0 06             	shl    $0x6,%eax
801021bb:	01 d0                	add    %edx,%eax
801021bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801021c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021c3:	0f b7 10             	movzwl (%eax),%edx
801021c6:	8b 45 08             	mov    0x8(%ebp),%eax
801021c9:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801021cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021d0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801021d4:	8b 45 08             	mov    0x8(%ebp),%eax
801021d7:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801021db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021de:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801021e2:	8b 45 08             	mov    0x8(%ebp),%eax
801021e5:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801021e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ec:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801021f0:	8b 45 08             	mov    0x8(%ebp),%eax
801021f3:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801021f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021fa:	8b 50 08             	mov    0x8(%eax),%edx
801021fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102200:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80102203:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102206:	8d 50 0c             	lea    0xc(%eax),%edx
80102209:	8b 45 08             	mov    0x8(%ebp),%eax
8010220c:	83 c0 1c             	add    $0x1c,%eax
8010220f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80102216:	00 
80102217:	89 54 24 04          	mov    %edx,0x4(%esp)
8010221b:	89 04 24             	mov    %eax,(%esp)
8010221e:	e8 aa 3c 00 00       	call   80105ecd <memmove>
    brelse(bp);
80102223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102226:	89 04 24             	mov    %eax,(%esp)
80102229:	e8 e9 df ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010222e:	8b 45 08             	mov    0x8(%ebp),%eax
80102231:	8b 40 0c             	mov    0xc(%eax),%eax
80102234:	89 c2                	mov    %eax,%edx
80102236:	83 ca 02             	or     $0x2,%edx
80102239:	8b 45 08             	mov    0x8(%ebp),%eax
8010223c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010223f:	8b 45 08             	mov    0x8(%ebp),%eax
80102242:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102246:	66 85 c0             	test   %ax,%ax
80102249:	75 0c                	jne    80102257 <ilock+0x152>
      panic("ilock: no type");
8010224b:	c7 04 24 f7 93 10 80 	movl   $0x801093f7,(%esp)
80102252:	e8 e6 e2 ff ff       	call   8010053d <panic>
  }
}
80102257:	c9                   	leave  
80102258:	c3                   	ret    

80102259 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80102259:	55                   	push   %ebp
8010225a:	89 e5                	mov    %esp,%ebp
8010225c:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
8010225f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102263:	74 17                	je     8010227c <iunlock+0x23>
80102265:	8b 45 08             	mov    0x8(%ebp),%eax
80102268:	8b 40 0c             	mov    0xc(%eax),%eax
8010226b:	83 e0 01             	and    $0x1,%eax
8010226e:	85 c0                	test   %eax,%eax
80102270:	74 0a                	je     8010227c <iunlock+0x23>
80102272:	8b 45 08             	mov    0x8(%ebp),%eax
80102275:	8b 40 08             	mov    0x8(%eax),%eax
80102278:	85 c0                	test   %eax,%eax
8010227a:	7f 0c                	jg     80102288 <iunlock+0x2f>
    panic("iunlock");
8010227c:	c7 04 24 06 94 10 80 	movl   $0x80109406,(%esp)
80102283:	e8 b5 e2 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102288:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010228f:	e8 17 39 00 00       	call   80105bab <acquire>
  ip->flags &= ~I_BUSY;
80102294:	8b 45 08             	mov    0x8(%ebp),%eax
80102297:	8b 40 0c             	mov    0xc(%eax),%eax
8010229a:	89 c2                	mov    %eax,%edx
8010229c:	83 e2 fe             	and    $0xfffffffe,%edx
8010229f:	8b 45 08             	mov    0x8(%ebp),%eax
801022a2:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	89 04 24             	mov    %eax,(%esp)
801022ab:	e8 f8 34 00 00       	call   801057a8 <wakeup>
  release(&icache.lock);
801022b0:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801022b7:	e8 51 39 00 00       	call   80105c0d <release>
}
801022bc:	c9                   	leave  
801022bd:	c3                   	ret    

801022be <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
801022be:	55                   	push   %ebp
801022bf:	89 e5                	mov    %esp,%ebp
801022c1:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801022c4:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
801022cb:	e8 db 38 00 00       	call   80105bab <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
801022d0:	8b 45 08             	mov    0x8(%ebp),%eax
801022d3:	8b 40 08             	mov    0x8(%eax),%eax
801022d6:	83 f8 01             	cmp    $0x1,%eax
801022d9:	0f 85 93 00 00 00    	jne    80102372 <iput+0xb4>
801022df:	8b 45 08             	mov    0x8(%ebp),%eax
801022e2:	8b 40 0c             	mov    0xc(%eax),%eax
801022e5:	83 e0 02             	and    $0x2,%eax
801022e8:	85 c0                	test   %eax,%eax
801022ea:	0f 84 82 00 00 00    	je     80102372 <iput+0xb4>
801022f0:	8b 45 08             	mov    0x8(%ebp),%eax
801022f3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801022f7:	66 85 c0             	test   %ax,%ax
801022fa:	75 76                	jne    80102372 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
801022fc:	8b 45 08             	mov    0x8(%ebp),%eax
801022ff:	8b 40 0c             	mov    0xc(%eax),%eax
80102302:	83 e0 01             	and    $0x1,%eax
80102305:	84 c0                	test   %al,%al
80102307:	74 0c                	je     80102315 <iput+0x57>
      panic("iput busy");
80102309:	c7 04 24 0e 94 10 80 	movl   $0x8010940e,(%esp)
80102310:	e8 28 e2 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80102315:	8b 45 08             	mov    0x8(%ebp),%eax
80102318:	8b 40 0c             	mov    0xc(%eax),%eax
8010231b:	89 c2                	mov    %eax,%edx
8010231d:	83 ca 01             	or     $0x1,%edx
80102320:	8b 45 08             	mov    0x8(%ebp),%eax
80102323:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80102326:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
8010232d:	e8 db 38 00 00       	call   80105c0d <release>
    itrunc(ip);
80102332:	8b 45 08             	mov    0x8(%ebp),%eax
80102335:	89 04 24             	mov    %eax,(%esp)
80102338:	e8 72 01 00 00       	call   801024af <itrunc>
    ip->type = 0;
8010233d:	8b 45 08             	mov    0x8(%ebp),%eax
80102340:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80102346:	8b 45 08             	mov    0x8(%ebp),%eax
80102349:	89 04 24             	mov    %eax,(%esp)
8010234c:	e8 f2 fb ff ff       	call   80101f43 <iupdate>
    acquire(&icache.lock);
80102351:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80102358:	e8 4e 38 00 00       	call   80105bab <acquire>
    ip->flags = 0;
8010235d:	8b 45 08             	mov    0x8(%ebp),%eax
80102360:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	89 04 24             	mov    %eax,(%esp)
8010236d:	e8 36 34 00 00       	call   801057a8 <wakeup>
  }
  ip->ref--;
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	8b 40 08             	mov    0x8(%eax),%eax
80102378:	8d 50 ff             	lea    -0x1(%eax),%edx
8010237b:	8b 45 08             	mov    0x8(%ebp),%eax
8010237e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80102381:	c7 04 24 80 2a 11 80 	movl   $0x80112a80,(%esp)
80102388:	e8 80 38 00 00       	call   80105c0d <release>
}
8010238d:	c9                   	leave  
8010238e:	c3                   	ret    

8010238f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
8010238f:	55                   	push   %ebp
80102390:	89 e5                	mov    %esp,%ebp
80102392:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80102395:	8b 45 08             	mov    0x8(%ebp),%eax
80102398:	89 04 24             	mov    %eax,(%esp)
8010239b:	e8 b9 fe ff ff       	call   80102259 <iunlock>
  iput(ip);
801023a0:	8b 45 08             	mov    0x8(%ebp),%eax
801023a3:	89 04 24             	mov    %eax,(%esp)
801023a6:	e8 13 ff ff ff       	call   801022be <iput>
}
801023ab:	c9                   	leave  
801023ac:	c3                   	ret    

801023ad <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801023ad:	55                   	push   %ebp
801023ae:	89 e5                	mov    %esp,%ebp
801023b0:	53                   	push   %ebx
801023b1:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801023b4:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
801023b8:	77 3e                	ja     801023f8 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
801023ba:	8b 45 08             	mov    0x8(%ebp),%eax
801023bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801023c0:	83 c2 04             	add    $0x4,%edx
801023c3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801023c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801023ce:	75 20                	jne    801023f0 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
801023d0:	8b 45 08             	mov    0x8(%ebp),%eax
801023d3:	8b 00                	mov    (%eax),%eax
801023d5:	89 04 24             	mov    %eax,(%esp)
801023d8:	e8 e2 f7 ff ff       	call   80101bbf <balloc>
801023dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023e0:	8b 45 08             	mov    0x8(%ebp),%eax
801023e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801023e6:	8d 4a 04             	lea    0x4(%edx),%ecx
801023e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023ec:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
801023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f3:	e9 b1 00 00 00       	jmp    801024a9 <bmap+0xfc>
  }
  bn -= NDIRECT;
801023f8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
801023fc:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80102400:	0f 87 97 00 00 00    	ja     8010249d <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80102406:	8b 45 08             	mov    0x8(%ebp),%eax
80102409:	8b 40 4c             	mov    0x4c(%eax),%eax
8010240c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010240f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102413:	75 19                	jne    8010242e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80102415:	8b 45 08             	mov    0x8(%ebp),%eax
80102418:	8b 00                	mov    (%eax),%eax
8010241a:	89 04 24             	mov    %eax,(%esp)
8010241d:	e8 9d f7 ff ff       	call   80101bbf <balloc>
80102422:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102425:	8b 45 08             	mov    0x8(%ebp),%eax
80102428:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010242b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	8b 00                	mov    (%eax),%eax
80102433:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102436:	89 54 24 04          	mov    %edx,0x4(%esp)
8010243a:	89 04 24             	mov    %eax,(%esp)
8010243d:	e8 64 dd ff ff       	call   801001a6 <bread>
80102442:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80102445:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102448:	83 c0 18             	add    $0x18,%eax
8010244b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
8010244e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102451:	c1 e0 02             	shl    $0x2,%eax
80102454:	03 45 ec             	add    -0x14(%ebp),%eax
80102457:	8b 00                	mov    (%eax),%eax
80102459:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010245c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102460:	75 2b                	jne    8010248d <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80102462:	8b 45 0c             	mov    0xc(%ebp),%eax
80102465:	c1 e0 02             	shl    $0x2,%eax
80102468:	89 c3                	mov    %eax,%ebx
8010246a:	03 5d ec             	add    -0x14(%ebp),%ebx
8010246d:	8b 45 08             	mov    0x8(%ebp),%eax
80102470:	8b 00                	mov    (%eax),%eax
80102472:	89 04 24             	mov    %eax,(%esp)
80102475:	e8 45 f7 ff ff       	call   80101bbf <balloc>
8010247a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010247d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102480:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80102482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102485:	89 04 24             	mov    %eax,(%esp)
80102488:	e8 99 1a 00 00       	call   80103f26 <log_write>
    }
    brelse(bp);
8010248d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102490:	89 04 24             	mov    %eax,(%esp)
80102493:	e8 7f dd ff ff       	call   80100217 <brelse>
    return addr;
80102498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249b:	eb 0c                	jmp    801024a9 <bmap+0xfc>
  }

  panic("bmap: out of range");
8010249d:	c7 04 24 18 94 10 80 	movl   $0x80109418,(%esp)
801024a4:	e8 94 e0 ff ff       	call   8010053d <panic>
}
801024a9:	83 c4 24             	add    $0x24,%esp
801024ac:	5b                   	pop    %ebx
801024ad:	5d                   	pop    %ebp
801024ae:	c3                   	ret    

801024af <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
801024af:	55                   	push   %ebp
801024b0:	89 e5                	mov    %esp,%ebp
801024b2:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801024b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024bc:	eb 44                	jmp    80102502 <itrunc+0x53>
    if(ip->addrs[i]){
801024be:	8b 45 08             	mov    0x8(%ebp),%eax
801024c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024c4:	83 c2 04             	add    $0x4,%edx
801024c7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801024cb:	85 c0                	test   %eax,%eax
801024cd:	74 2f                	je     801024fe <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
801024d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024d5:	83 c2 04             	add    $0x4,%edx
801024d8:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
801024dc:	8b 45 08             	mov    0x8(%ebp),%eax
801024df:	8b 00                	mov    (%eax),%eax
801024e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801024e5:	89 04 24             	mov    %eax,(%esp)
801024e8:	e8 19 f8 ff ff       	call   80101d06 <bfree>
      ip->addrs[i] = 0;
801024ed:	8b 45 08             	mov    0x8(%ebp),%eax
801024f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024f3:	83 c2 04             	add    $0x4,%edx
801024f6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801024fd:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801024fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102502:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102506:	7e b6                	jle    801024be <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80102508:	8b 45 08             	mov    0x8(%ebp),%eax
8010250b:	8b 40 4c             	mov    0x4c(%eax),%eax
8010250e:	85 c0                	test   %eax,%eax
80102510:	0f 84 8f 00 00 00    	je     801025a5 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102516:	8b 45 08             	mov    0x8(%ebp),%eax
80102519:	8b 50 4c             	mov    0x4c(%eax),%edx
8010251c:	8b 45 08             	mov    0x8(%ebp),%eax
8010251f:	8b 00                	mov    (%eax),%eax
80102521:	89 54 24 04          	mov    %edx,0x4(%esp)
80102525:	89 04 24             	mov    %eax,(%esp)
80102528:	e8 79 dc ff ff       	call   801001a6 <bread>
8010252d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80102530:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102533:	83 c0 18             	add    $0x18,%eax
80102536:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80102539:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102540:	eb 2f                	jmp    80102571 <itrunc+0xc2>
      if(a[j])
80102542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102545:	c1 e0 02             	shl    $0x2,%eax
80102548:	03 45 e8             	add    -0x18(%ebp),%eax
8010254b:	8b 00                	mov    (%eax),%eax
8010254d:	85 c0                	test   %eax,%eax
8010254f:	74 1c                	je     8010256d <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102554:	c1 e0 02             	shl    $0x2,%eax
80102557:	03 45 e8             	add    -0x18(%ebp),%eax
8010255a:	8b 10                	mov    (%eax),%edx
8010255c:	8b 45 08             	mov    0x8(%ebp),%eax
8010255f:	8b 00                	mov    (%eax),%eax
80102561:	89 54 24 04          	mov    %edx,0x4(%esp)
80102565:	89 04 24             	mov    %eax,(%esp)
80102568:	e8 99 f7 ff ff       	call   80101d06 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010256d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102574:	83 f8 7f             	cmp    $0x7f,%eax
80102577:	76 c9                	jbe    80102542 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80102579:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010257c:	89 04 24             	mov    %eax,(%esp)
8010257f:	e8 93 dc ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102584:	8b 45 08             	mov    0x8(%ebp),%eax
80102587:	8b 50 4c             	mov    0x4c(%eax),%edx
8010258a:	8b 45 08             	mov    0x8(%ebp),%eax
8010258d:	8b 00                	mov    (%eax),%eax
8010258f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102593:	89 04 24             	mov    %eax,(%esp)
80102596:	e8 6b f7 ff ff       	call   80101d06 <bfree>
    ip->addrs[NDIRECT] = 0;
8010259b:	8b 45 08             	mov    0x8(%ebp),%eax
8010259e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
801025a5:	8b 45 08             	mov    0x8(%ebp),%eax
801025a8:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
801025af:	8b 45 08             	mov    0x8(%ebp),%eax
801025b2:	89 04 24             	mov    %eax,(%esp)
801025b5:	e8 89 f9 ff ff       	call   80101f43 <iupdate>
}
801025ba:	c9                   	leave  
801025bb:	c3                   	ret    

801025bc <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
801025bc:	55                   	push   %ebp
801025bd:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	8b 00                	mov    (%eax),%eax
801025c4:	89 c2                	mov    %eax,%edx
801025c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
801025cc:	8b 45 08             	mov    0x8(%ebp),%eax
801025cf:	8b 50 04             	mov    0x4(%eax),%edx
801025d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801025d5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801025d8:	8b 45 08             	mov    0x8(%ebp),%eax
801025db:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801025df:	8b 45 0c             	mov    0xc(%ebp),%eax
801025e2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801025e5:	8b 45 08             	mov    0x8(%ebp),%eax
801025e8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801025ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ef:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801025f3:	8b 45 08             	mov    0x8(%ebp),%eax
801025f6:	8b 50 18             	mov    0x18(%eax),%edx
801025f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801025fc:	89 50 10             	mov    %edx,0x10(%eax)
}
801025ff:	5d                   	pop    %ebp
80102600:	c3                   	ret    

80102601 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102601:	55                   	push   %ebp
80102602:	89 e5                	mov    %esp,%ebp
80102604:	53                   	push   %ebx
80102605:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102608:	8b 45 08             	mov    0x8(%ebp),%eax
8010260b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010260f:	66 83 f8 03          	cmp    $0x3,%ax
80102613:	75 60                	jne    80102675 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102615:	8b 45 08             	mov    0x8(%ebp),%eax
80102618:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010261c:	66 85 c0             	test   %ax,%ax
8010261f:	78 20                	js     80102641 <readi+0x40>
80102621:	8b 45 08             	mov    0x8(%ebp),%eax
80102624:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102628:	66 83 f8 09          	cmp    $0x9,%ax
8010262c:	7f 13                	jg     80102641 <readi+0x40>
8010262e:	8b 45 08             	mov    0x8(%ebp),%eax
80102631:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102635:	98                   	cwtl   
80102636:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
8010263d:	85 c0                	test   %eax,%eax
8010263f:	75 0a                	jne    8010264b <readi+0x4a>
      return -1;
80102641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102646:	e9 1b 01 00 00       	jmp    80102766 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
8010264b:	8b 45 08             	mov    0x8(%ebp),%eax
8010264e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102652:	98                   	cwtl   
80102653:	8b 14 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%edx
8010265a:	8b 45 14             	mov    0x14(%ebp),%eax
8010265d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102661:	8b 45 0c             	mov    0xc(%ebp),%eax
80102664:	89 44 24 04          	mov    %eax,0x4(%esp)
80102668:	8b 45 08             	mov    0x8(%ebp),%eax
8010266b:	89 04 24             	mov    %eax,(%esp)
8010266e:	ff d2                	call   *%edx
80102670:	e9 f1 00 00 00       	jmp    80102766 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80102675:	8b 45 08             	mov    0x8(%ebp),%eax
80102678:	8b 40 18             	mov    0x18(%eax),%eax
8010267b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010267e:	72 0d                	jb     8010268d <readi+0x8c>
80102680:	8b 45 14             	mov    0x14(%ebp),%eax
80102683:	8b 55 10             	mov    0x10(%ebp),%edx
80102686:	01 d0                	add    %edx,%eax
80102688:	3b 45 10             	cmp    0x10(%ebp),%eax
8010268b:	73 0a                	jae    80102697 <readi+0x96>
    return -1;
8010268d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102692:	e9 cf 00 00 00       	jmp    80102766 <readi+0x165>
  if(off + n > ip->size)
80102697:	8b 45 14             	mov    0x14(%ebp),%eax
8010269a:	8b 55 10             	mov    0x10(%ebp),%edx
8010269d:	01 c2                	add    %eax,%edx
8010269f:	8b 45 08             	mov    0x8(%ebp),%eax
801026a2:	8b 40 18             	mov    0x18(%eax),%eax
801026a5:	39 c2                	cmp    %eax,%edx
801026a7:	76 0c                	jbe    801026b5 <readi+0xb4>
    n = ip->size - off;
801026a9:	8b 45 08             	mov    0x8(%ebp),%eax
801026ac:	8b 40 18             	mov    0x18(%eax),%eax
801026af:	2b 45 10             	sub    0x10(%ebp),%eax
801026b2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801026b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026bc:	e9 96 00 00 00       	jmp    80102757 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801026c1:	8b 45 10             	mov    0x10(%ebp),%eax
801026c4:	c1 e8 09             	shr    $0x9,%eax
801026c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026cb:	8b 45 08             	mov    0x8(%ebp),%eax
801026ce:	89 04 24             	mov    %eax,(%esp)
801026d1:	e8 d7 fc ff ff       	call   801023ad <bmap>
801026d6:	8b 55 08             	mov    0x8(%ebp),%edx
801026d9:	8b 12                	mov    (%edx),%edx
801026db:	89 44 24 04          	mov    %eax,0x4(%esp)
801026df:	89 14 24             	mov    %edx,(%esp)
801026e2:	e8 bf da ff ff       	call   801001a6 <bread>
801026e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801026ea:	8b 45 10             	mov    0x10(%ebp),%eax
801026ed:	89 c2                	mov    %eax,%edx
801026ef:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801026f5:	b8 00 02 00 00       	mov    $0x200,%eax
801026fa:	89 c1                	mov    %eax,%ecx
801026fc:	29 d1                	sub    %edx,%ecx
801026fe:	89 ca                	mov    %ecx,%edx
80102700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102703:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102706:	89 cb                	mov    %ecx,%ebx
80102708:	29 c3                	sub    %eax,%ebx
8010270a:	89 d8                	mov    %ebx,%eax
8010270c:	39 c2                	cmp    %eax,%edx
8010270e:	0f 46 c2             	cmovbe %edx,%eax
80102711:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102717:	8d 50 18             	lea    0x18(%eax),%edx
8010271a:	8b 45 10             	mov    0x10(%ebp),%eax
8010271d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102722:	01 c2                	add    %eax,%edx
80102724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102727:	89 44 24 08          	mov    %eax,0x8(%esp)
8010272b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010272f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102732:	89 04 24             	mov    %eax,(%esp)
80102735:	e8 93 37 00 00       	call   80105ecd <memmove>
    brelse(bp);
8010273a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010273d:	89 04 24             	mov    %eax,(%esp)
80102740:	e8 d2 da ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102745:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102748:	01 45 f4             	add    %eax,-0xc(%ebp)
8010274b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010274e:	01 45 10             	add    %eax,0x10(%ebp)
80102751:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102754:	01 45 0c             	add    %eax,0xc(%ebp)
80102757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010275d:	0f 82 5e ff ff ff    	jb     801026c1 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102763:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102766:	83 c4 24             	add    $0x24,%esp
80102769:	5b                   	pop    %ebx
8010276a:	5d                   	pop    %ebp
8010276b:	c3                   	ret    

8010276c <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010276c:	55                   	push   %ebp
8010276d:	89 e5                	mov    %esp,%ebp
8010276f:	53                   	push   %ebx
80102770:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010277a:	66 83 f8 03          	cmp    $0x3,%ax
8010277e:	75 60                	jne    801027e0 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102780:	8b 45 08             	mov    0x8(%ebp),%eax
80102783:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102787:	66 85 c0             	test   %ax,%ax
8010278a:	78 20                	js     801027ac <writei+0x40>
8010278c:	8b 45 08             	mov    0x8(%ebp),%eax
8010278f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102793:	66 83 f8 09          	cmp    $0x9,%ax
80102797:	7f 13                	jg     801027ac <writei+0x40>
80102799:	8b 45 08             	mov    0x8(%ebp),%eax
8010279c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027a0:	98                   	cwtl   
801027a1:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801027a8:	85 c0                	test   %eax,%eax
801027aa:	75 0a                	jne    801027b6 <writei+0x4a>
      return -1;
801027ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027b1:	e9 46 01 00 00       	jmp    801028fc <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
801027b6:	8b 45 08             	mov    0x8(%ebp),%eax
801027b9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027bd:	98                   	cwtl   
801027be:	8b 14 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%edx
801027c5:	8b 45 14             	mov    0x14(%ebp),%eax
801027c8:	89 44 24 08          	mov    %eax,0x8(%esp)
801027cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801027cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801027d3:	8b 45 08             	mov    0x8(%ebp),%eax
801027d6:	89 04 24             	mov    %eax,(%esp)
801027d9:	ff d2                	call   *%edx
801027db:	e9 1c 01 00 00       	jmp    801028fc <writei+0x190>
  }

  if(off > ip->size || off + n < off)
801027e0:	8b 45 08             	mov    0x8(%ebp),%eax
801027e3:	8b 40 18             	mov    0x18(%eax),%eax
801027e6:	3b 45 10             	cmp    0x10(%ebp),%eax
801027e9:	72 0d                	jb     801027f8 <writei+0x8c>
801027eb:	8b 45 14             	mov    0x14(%ebp),%eax
801027ee:	8b 55 10             	mov    0x10(%ebp),%edx
801027f1:	01 d0                	add    %edx,%eax
801027f3:	3b 45 10             	cmp    0x10(%ebp),%eax
801027f6:	73 0a                	jae    80102802 <writei+0x96>
    return -1;
801027f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027fd:	e9 fa 00 00 00       	jmp    801028fc <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80102802:	8b 45 14             	mov    0x14(%ebp),%eax
80102805:	8b 55 10             	mov    0x10(%ebp),%edx
80102808:	01 d0                	add    %edx,%eax
8010280a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010280f:	76 0a                	jbe    8010281b <writei+0xaf>
    return -1;
80102811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102816:	e9 e1 00 00 00       	jmp    801028fc <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010281b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102822:	e9 a1 00 00 00       	jmp    801028c8 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102827:	8b 45 10             	mov    0x10(%ebp),%eax
8010282a:	c1 e8 09             	shr    $0x9,%eax
8010282d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102831:	8b 45 08             	mov    0x8(%ebp),%eax
80102834:	89 04 24             	mov    %eax,(%esp)
80102837:	e8 71 fb ff ff       	call   801023ad <bmap>
8010283c:	8b 55 08             	mov    0x8(%ebp),%edx
8010283f:	8b 12                	mov    (%edx),%edx
80102841:	89 44 24 04          	mov    %eax,0x4(%esp)
80102845:	89 14 24             	mov    %edx,(%esp)
80102848:	e8 59 d9 ff ff       	call   801001a6 <bread>
8010284d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102850:	8b 45 10             	mov    0x10(%ebp),%eax
80102853:	89 c2                	mov    %eax,%edx
80102855:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010285b:	b8 00 02 00 00       	mov    $0x200,%eax
80102860:	89 c1                	mov    %eax,%ecx
80102862:	29 d1                	sub    %edx,%ecx
80102864:	89 ca                	mov    %ecx,%edx
80102866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102869:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010286c:	89 cb                	mov    %ecx,%ebx
8010286e:	29 c3                	sub    %eax,%ebx
80102870:	89 d8                	mov    %ebx,%eax
80102872:	39 c2                	cmp    %eax,%edx
80102874:	0f 46 c2             	cmovbe %edx,%eax
80102877:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010287a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010287d:	8d 50 18             	lea    0x18(%eax),%edx
80102880:	8b 45 10             	mov    0x10(%ebp),%eax
80102883:	25 ff 01 00 00       	and    $0x1ff,%eax
80102888:	01 c2                	add    %eax,%edx
8010288a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010288d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102891:	8b 45 0c             	mov    0xc(%ebp),%eax
80102894:	89 44 24 04          	mov    %eax,0x4(%esp)
80102898:	89 14 24             	mov    %edx,(%esp)
8010289b:	e8 2d 36 00 00       	call   80105ecd <memmove>
    log_write(bp);
801028a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028a3:	89 04 24             	mov    %eax,(%esp)
801028a6:	e8 7b 16 00 00       	call   80103f26 <log_write>
    brelse(bp);
801028ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ae:	89 04 24             	mov    %eax,(%esp)
801028b1:	e8 61 d9 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801028b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028b9:	01 45 f4             	add    %eax,-0xc(%ebp)
801028bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028bf:	01 45 10             	add    %eax,0x10(%ebp)
801028c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028c5:	01 45 0c             	add    %eax,0xc(%ebp)
801028c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cb:	3b 45 14             	cmp    0x14(%ebp),%eax
801028ce:	0f 82 53 ff ff ff    	jb     80102827 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801028d4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801028d8:	74 1f                	je     801028f9 <writei+0x18d>
801028da:	8b 45 08             	mov    0x8(%ebp),%eax
801028dd:	8b 40 18             	mov    0x18(%eax),%eax
801028e0:	3b 45 10             	cmp    0x10(%ebp),%eax
801028e3:	73 14                	jae    801028f9 <writei+0x18d>
    ip->size = off;
801028e5:	8b 45 08             	mov    0x8(%ebp),%eax
801028e8:	8b 55 10             	mov    0x10(%ebp),%edx
801028eb:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801028ee:	8b 45 08             	mov    0x8(%ebp),%eax
801028f1:	89 04 24             	mov    %eax,(%esp)
801028f4:	e8 4a f6 ff ff       	call   80101f43 <iupdate>
  }
  return n;
801028f9:	8b 45 14             	mov    0x14(%ebp),%eax
}
801028fc:	83 c4 24             	add    $0x24,%esp
801028ff:	5b                   	pop    %ebx
80102900:	5d                   	pop    %ebp
80102901:	c3                   	ret    

80102902 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102902:	55                   	push   %ebp
80102903:	89 e5                	mov    %esp,%ebp
80102905:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102908:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010290f:	00 
80102910:	8b 45 0c             	mov    0xc(%ebp),%eax
80102913:	89 44 24 04          	mov    %eax,0x4(%esp)
80102917:	8b 45 08             	mov    0x8(%ebp),%eax
8010291a:	89 04 24             	mov    %eax,(%esp)
8010291d:	e8 4f 36 00 00       	call   80105f71 <strncmp>
}
80102922:	c9                   	leave  
80102923:	c3                   	ret    

80102924 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102924:	55                   	push   %ebp
80102925:	89 e5                	mov    %esp,%ebp
80102927:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010292a:	8b 45 08             	mov    0x8(%ebp),%eax
8010292d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102931:	66 83 f8 01          	cmp    $0x1,%ax
80102935:	74 0c                	je     80102943 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102937:	c7 04 24 2b 94 10 80 	movl   $0x8010942b,(%esp)
8010293e:	e8 fa db ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102943:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010294a:	e9 87 00 00 00       	jmp    801029d6 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010294f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102956:	00 
80102957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010295a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010295e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102961:	89 44 24 04          	mov    %eax,0x4(%esp)
80102965:	8b 45 08             	mov    0x8(%ebp),%eax
80102968:	89 04 24             	mov    %eax,(%esp)
8010296b:	e8 91 fc ff ff       	call   80102601 <readi>
80102970:	83 f8 10             	cmp    $0x10,%eax
80102973:	74 0c                	je     80102981 <dirlookup+0x5d>
      panic("dirlink read");
80102975:	c7 04 24 3d 94 10 80 	movl   $0x8010943d,(%esp)
8010297c:	e8 bc db ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102981:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102985:	66 85 c0             	test   %ax,%ax
80102988:	74 47                	je     801029d1 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010298a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010298d:	83 c0 02             	add    $0x2,%eax
80102990:	89 44 24 04          	mov    %eax,0x4(%esp)
80102994:	8b 45 0c             	mov    0xc(%ebp),%eax
80102997:	89 04 24             	mov    %eax,(%esp)
8010299a:	e8 63 ff ff ff       	call   80102902 <namecmp>
8010299f:	85 c0                	test   %eax,%eax
801029a1:	75 2f                	jne    801029d2 <dirlookup+0xae>
      // entry matches path element
      if(poff)
801029a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801029a7:	74 08                	je     801029b1 <dirlookup+0x8d>
        *poff = off;
801029a9:	8b 45 10             	mov    0x10(%ebp),%eax
801029ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029af:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801029b1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801029b5:	0f b7 c0             	movzwl %ax,%eax
801029b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801029bb:	8b 45 08             	mov    0x8(%ebp),%eax
801029be:	8b 00                	mov    (%eax),%eax
801029c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801029c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801029c7:	89 04 24             	mov    %eax,(%esp)
801029ca:	e8 32 f6 ff ff       	call   80102001 <iget>
801029cf:	eb 19                	jmp    801029ea <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
801029d1:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801029d2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801029d6:	8b 45 08             	mov    0x8(%ebp),%eax
801029d9:	8b 40 18             	mov    0x18(%eax),%eax
801029dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801029df:	0f 87 6a ff ff ff    	ja     8010294f <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801029e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029ea:	c9                   	leave  
801029eb:	c3                   	ret    

801029ec <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801029ec:	55                   	push   %ebp
801029ed:	89 e5                	mov    %esp,%ebp
801029ef:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801029f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801029f9:	00 
801029fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801029fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a01:	8b 45 08             	mov    0x8(%ebp),%eax
80102a04:	89 04 24             	mov    %eax,(%esp)
80102a07:	e8 18 ff ff ff       	call   80102924 <dirlookup>
80102a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102a0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102a13:	74 15                	je     80102a2a <dirlink+0x3e>
    iput(ip);
80102a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a18:	89 04 24             	mov    %eax,(%esp)
80102a1b:	e8 9e f8 ff ff       	call   801022be <iput>
    return -1;
80102a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a25:	e9 b8 00 00 00       	jmp    80102ae2 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102a2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a31:	eb 44                	jmp    80102a77 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a36:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102a3d:	00 
80102a3e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102a42:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a45:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a49:	8b 45 08             	mov    0x8(%ebp),%eax
80102a4c:	89 04 24             	mov    %eax,(%esp)
80102a4f:	e8 ad fb ff ff       	call   80102601 <readi>
80102a54:	83 f8 10             	cmp    $0x10,%eax
80102a57:	74 0c                	je     80102a65 <dirlink+0x79>
      panic("dirlink read");
80102a59:	c7 04 24 3d 94 10 80 	movl   $0x8010943d,(%esp)
80102a60:	e8 d8 da ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102a65:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102a69:	66 85 c0             	test   %ax,%ax
80102a6c:	74 18                	je     80102a86 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a71:	83 c0 10             	add    $0x10,%eax
80102a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7d:	8b 40 18             	mov    0x18(%eax),%eax
80102a80:	39 c2                	cmp    %eax,%edx
80102a82:	72 af                	jb     80102a33 <dirlink+0x47>
80102a84:	eb 01                	jmp    80102a87 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102a86:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102a87:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102a8e:	00 
80102a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a92:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a96:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a99:	83 c0 02             	add    $0x2,%eax
80102a9c:	89 04 24             	mov    %eax,(%esp)
80102a9f:	e8 25 35 00 00       	call   80105fc9 <strncpy>
  de.inum = inum;
80102aa4:	8b 45 10             	mov    0x10(%ebp),%eax
80102aa7:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aae:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102ab5:	00 
80102ab6:	89 44 24 08          	mov    %eax,0x8(%esp)
80102aba:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102abd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac4:	89 04 24             	mov    %eax,(%esp)
80102ac7:	e8 a0 fc ff ff       	call   8010276c <writei>
80102acc:	83 f8 10             	cmp    $0x10,%eax
80102acf:	74 0c                	je     80102add <dirlink+0xf1>
    panic("dirlink");
80102ad1:	c7 04 24 4a 94 10 80 	movl   $0x8010944a,(%esp)
80102ad8:	e8 60 da ff ff       	call   8010053d <panic>
  
  return 0;
80102add:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ae2:	c9                   	leave  
80102ae3:	c3                   	ret    

80102ae4 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102ae4:	55                   	push   %ebp
80102ae5:	89 e5                	mov    %esp,%ebp
80102ae7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102aea:	eb 04                	jmp    80102af0 <skipelem+0xc>
    path++;
80102aec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102af0:	8b 45 08             	mov    0x8(%ebp),%eax
80102af3:	0f b6 00             	movzbl (%eax),%eax
80102af6:	3c 2f                	cmp    $0x2f,%al
80102af8:	74 f2                	je     80102aec <skipelem+0x8>
    path++;
  if(*path == 0)
80102afa:	8b 45 08             	mov    0x8(%ebp),%eax
80102afd:	0f b6 00             	movzbl (%eax),%eax
80102b00:	84 c0                	test   %al,%al
80102b02:	75 0a                	jne    80102b0e <skipelem+0x2a>
    return 0;
80102b04:	b8 00 00 00 00       	mov    $0x0,%eax
80102b09:	e9 86 00 00 00       	jmp    80102b94 <skipelem+0xb0>
  s = path;
80102b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102b14:	eb 04                	jmp    80102b1a <skipelem+0x36>
    path++;
80102b16:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	0f b6 00             	movzbl (%eax),%eax
80102b20:	3c 2f                	cmp    $0x2f,%al
80102b22:	74 0a                	je     80102b2e <skipelem+0x4a>
80102b24:	8b 45 08             	mov    0x8(%ebp),%eax
80102b27:	0f b6 00             	movzbl (%eax),%eax
80102b2a:	84 c0                	test   %al,%al
80102b2c:	75 e8                	jne    80102b16 <skipelem+0x32>
    path++;
  len = path - s;
80102b2e:	8b 55 08             	mov    0x8(%ebp),%edx
80102b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b34:	89 d1                	mov    %edx,%ecx
80102b36:	29 c1                	sub    %eax,%ecx
80102b38:	89 c8                	mov    %ecx,%eax
80102b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102b3d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102b41:	7e 1c                	jle    80102b5f <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102b43:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102b4a:	00 
80102b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b52:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b55:	89 04 24             	mov    %eax,(%esp)
80102b58:	e8 70 33 00 00       	call   80105ecd <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102b5d:	eb 28                	jmp    80102b87 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b62:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b69:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b70:	89 04 24             	mov    %eax,(%esp)
80102b73:	e8 55 33 00 00       	call   80105ecd <memmove>
    name[len] = 0;
80102b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b7b:	03 45 0c             	add    0xc(%ebp),%eax
80102b7e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102b81:	eb 04                	jmp    80102b87 <skipelem+0xa3>
    path++;
80102b83:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102b87:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8a:	0f b6 00             	movzbl (%eax),%eax
80102b8d:	3c 2f                	cmp    $0x2f,%al
80102b8f:	74 f2                	je     80102b83 <skipelem+0x9f>
    path++;
  return path;
80102b91:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102b94:	c9                   	leave  
80102b95:	c3                   	ret    

80102b96 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102b96:	55                   	push   %ebp
80102b97:	89 e5                	mov    %esp,%ebp
80102b99:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9f:	0f b6 00             	movzbl (%eax),%eax
80102ba2:	3c 2f                	cmp    $0x2f,%al
80102ba4:	75 1c                	jne    80102bc2 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102ba6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102bad:	00 
80102bae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102bb5:	e8 47 f4 ff ff       	call   80102001 <iget>
80102bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102bbd:	e9 af 00 00 00       	jmp    80102c71 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102bc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102bc8:	8b 40 68             	mov    0x68(%eax),%eax
80102bcb:	89 04 24             	mov    %eax,(%esp)
80102bce:	e8 00 f5 ff ff       	call   801020d3 <idup>
80102bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102bd6:	e9 96 00 00 00       	jmp    80102c71 <namex+0xdb>
    ilock(ip);
80102bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bde:	89 04 24             	mov    %eax,(%esp)
80102be1:	e8 1f f5 ff ff       	call   80102105 <ilock>
    if(ip->type != T_DIR){
80102be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102bed:	66 83 f8 01          	cmp    $0x1,%ax
80102bf1:	74 15                	je     80102c08 <namex+0x72>
      iunlockput(ip);
80102bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bf6:	89 04 24             	mov    %eax,(%esp)
80102bf9:	e8 91 f7 ff ff       	call   8010238f <iunlockput>
      return 0;
80102bfe:	b8 00 00 00 00       	mov    $0x0,%eax
80102c03:	e9 a3 00 00 00       	jmp    80102cab <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102c08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c0c:	74 1d                	je     80102c2b <namex+0x95>
80102c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c11:	0f b6 00             	movzbl (%eax),%eax
80102c14:	84 c0                	test   %al,%al
80102c16:	75 13                	jne    80102c2b <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1b:	89 04 24             	mov    %eax,(%esp)
80102c1e:	e8 36 f6 ff ff       	call   80102259 <iunlock>
      return ip;
80102c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c26:	e9 80 00 00 00       	jmp    80102cab <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102c2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102c32:	00 
80102c33:	8b 45 10             	mov    0x10(%ebp),%eax
80102c36:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3d:	89 04 24             	mov    %eax,(%esp)
80102c40:	e8 df fc ff ff       	call   80102924 <dirlookup>
80102c45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102c48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102c4c:	75 12                	jne    80102c60 <namex+0xca>
      iunlockput(ip);
80102c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c51:	89 04 24             	mov    %eax,(%esp)
80102c54:	e8 36 f7 ff ff       	call   8010238f <iunlockput>
      return 0;
80102c59:	b8 00 00 00 00       	mov    $0x0,%eax
80102c5e:	eb 4b                	jmp    80102cab <namex+0x115>
    }
    iunlockput(ip);
80102c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c63:	89 04 24             	mov    %eax,(%esp)
80102c66:	e8 24 f7 ff ff       	call   8010238f <iunlockput>
    ip = next;
80102c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102c71:	8b 45 10             	mov    0x10(%ebp),%eax
80102c74:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c78:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7b:	89 04 24             	mov    %eax,(%esp)
80102c7e:	e8 61 fe ff ff       	call   80102ae4 <skipelem>
80102c83:	89 45 08             	mov    %eax,0x8(%ebp)
80102c86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102c8a:	0f 85 4b ff ff ff    	jne    80102bdb <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102c90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c94:	74 12                	je     80102ca8 <namex+0x112>
    iput(ip);
80102c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c99:	89 04 24             	mov    %eax,(%esp)
80102c9c:	e8 1d f6 ff ff       	call   801022be <iput>
    return 0;
80102ca1:	b8 00 00 00 00       	mov    $0x0,%eax
80102ca6:	eb 03                	jmp    80102cab <namex+0x115>
  }
  return ip;
80102ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cab:	c9                   	leave  
80102cac:	c3                   	ret    

80102cad <namei>:

struct inode*
namei(char *path)
{
80102cad:	55                   	push   %ebp
80102cae:	89 e5                	mov    %esp,%ebp
80102cb0:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102cb3:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102cb6:	89 44 24 08          	mov    %eax,0x8(%esp)
80102cba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cc1:	00 
80102cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc5:	89 04 24             	mov    %eax,(%esp)
80102cc8:	e8 c9 fe ff ff       	call   80102b96 <namex>
}
80102ccd:	c9                   	leave  
80102cce:	c3                   	ret    

80102ccf <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102ccf:	55                   	push   %ebp
80102cd0:	89 e5                	mov    %esp,%ebp
80102cd2:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cd8:	89 44 24 08          	mov    %eax,0x8(%esp)
80102cdc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ce3:	00 
80102ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce7:	89 04 24             	mov    %eax,(%esp)
80102cea:	e8 a7 fe ff ff       	call   80102b96 <namex>
}
80102cef:	c9                   	leave  
80102cf0:	c3                   	ret    
80102cf1:	00 00                	add    %al,(%eax)
	...

80102cf4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cf4:	55                   	push   %ebp
80102cf5:	89 e5                	mov    %esp,%ebp
80102cf7:	53                   	push   %ebx
80102cf8:	83 ec 14             	sub    $0x14,%esp
80102cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cfe:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d02:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102d06:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102d0a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102d0e:	ec                   	in     (%dx),%al
80102d0f:	89 c3                	mov    %eax,%ebx
80102d11:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d14:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d18:	83 c4 14             	add    $0x14,%esp
80102d1b:	5b                   	pop    %ebx
80102d1c:	5d                   	pop    %ebp
80102d1d:	c3                   	ret    

80102d1e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d1e:	55                   	push   %ebp
80102d1f:	89 e5                	mov    %esp,%ebp
80102d21:	57                   	push   %edi
80102d22:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d23:	8b 55 08             	mov    0x8(%ebp),%edx
80102d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d29:	8b 45 10             	mov    0x10(%ebp),%eax
80102d2c:	89 cb                	mov    %ecx,%ebx
80102d2e:	89 df                	mov    %ebx,%edi
80102d30:	89 c1                	mov    %eax,%ecx
80102d32:	fc                   	cld    
80102d33:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d35:	89 c8                	mov    %ecx,%eax
80102d37:	89 fb                	mov    %edi,%ebx
80102d39:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d3c:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d3f:	5b                   	pop    %ebx
80102d40:	5f                   	pop    %edi
80102d41:	5d                   	pop    %ebp
80102d42:	c3                   	ret    

80102d43 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d43:	55                   	push   %ebp
80102d44:	89 e5                	mov    %esp,%ebp
80102d46:	83 ec 08             	sub    $0x8,%esp
80102d49:	8b 55 08             	mov    0x8(%ebp),%edx
80102d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d4f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d53:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d56:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d5a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d5e:	ee                   	out    %al,(%dx)
}
80102d5f:	c9                   	leave  
80102d60:	c3                   	ret    

80102d61 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102d61:	55                   	push   %ebp
80102d62:	89 e5                	mov    %esp,%ebp
80102d64:	56                   	push   %esi
80102d65:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102d66:	8b 55 08             	mov    0x8(%ebp),%edx
80102d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d6c:	8b 45 10             	mov    0x10(%ebp),%eax
80102d6f:	89 cb                	mov    %ecx,%ebx
80102d71:	89 de                	mov    %ebx,%esi
80102d73:	89 c1                	mov    %eax,%ecx
80102d75:	fc                   	cld    
80102d76:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102d78:	89 c8                	mov    %ecx,%eax
80102d7a:	89 f3                	mov    %esi,%ebx
80102d7c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d7f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102d82:	5b                   	pop    %ebx
80102d83:	5e                   	pop    %esi
80102d84:	5d                   	pop    %ebp
80102d85:	c3                   	ret    

80102d86 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102d86:	55                   	push   %ebp
80102d87:	89 e5                	mov    %esp,%ebp
80102d89:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102d8c:	90                   	nop
80102d8d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102d94:	e8 5b ff ff ff       	call   80102cf4 <inb>
80102d99:	0f b6 c0             	movzbl %al,%eax
80102d9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da2:	25 c0 00 00 00       	and    $0xc0,%eax
80102da7:	83 f8 40             	cmp    $0x40,%eax
80102daa:	75 e1                	jne    80102d8d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102dac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102db0:	74 11                	je     80102dc3 <idewait+0x3d>
80102db2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db5:	83 e0 21             	and    $0x21,%eax
80102db8:	85 c0                	test   %eax,%eax
80102dba:	74 07                	je     80102dc3 <idewait+0x3d>
    return -1;
80102dbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dc1:	eb 05                	jmp    80102dc8 <idewait+0x42>
  return 0;
80102dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102dc8:	c9                   	leave  
80102dc9:	c3                   	ret    

80102dca <ideinit>:

void
ideinit(void)
{
80102dca:	55                   	push   %ebp
80102dcb:	89 e5                	mov    %esp,%ebp
80102dcd:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102dd0:	c7 44 24 04 52 94 10 	movl   $0x80109452,0x4(%esp)
80102dd7:	80 
80102dd8:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102ddf:	e8 a6 2d 00 00       	call   80105b8a <initlock>
  picenable(IRQ_IDE);
80102de4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102deb:	e8 e5 18 00 00       	call   801046d5 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102df0:	a1 80 41 11 80       	mov    0x80114180,%eax
80102df5:	83 e8 01             	sub    $0x1,%eax
80102df8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dfc:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102e03:	e8 46 04 00 00       	call   8010324e <ioapicenable>
  idewait(0);
80102e08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102e0f:	e8 72 ff ff ff       	call   80102d86 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e14:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102e1b:	00 
80102e1c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102e23:	e8 1b ff ff ff       	call   80102d43 <outb>
  for(i=0; i<1000; i++){
80102e28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e2f:	eb 20                	jmp    80102e51 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102e31:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102e38:	e8 b7 fe ff ff       	call   80102cf4 <inb>
80102e3d:	84 c0                	test   %al,%al
80102e3f:	74 0c                	je     80102e4d <ideinit+0x83>
      havedisk1 = 1;
80102e41:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102e48:	00 00 00 
      break;
80102e4b:	eb 0d                	jmp    80102e5a <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102e4d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e51:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102e58:	7e d7                	jle    80102e31 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102e5a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102e61:	00 
80102e62:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102e69:	e8 d5 fe ff ff       	call   80102d43 <outb>
}
80102e6e:	c9                   	leave  
80102e6f:	c3                   	ret    

80102e70 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102e76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e7a:	75 0c                	jne    80102e88 <idestart+0x18>
    panic("idestart");
80102e7c:	c7 04 24 56 94 10 80 	movl   $0x80109456,(%esp)
80102e83:	e8 b5 d6 ff ff       	call   8010053d <panic>
  if(b->blockno >= FSSIZE)
80102e88:	8b 45 08             	mov    0x8(%ebp),%eax
80102e8b:	8b 40 08             	mov    0x8(%eax),%eax
80102e8e:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e93:	76 0c                	jbe    80102ea1 <idestart+0x31>
    panic("incorrect blockno");
80102e95:	c7 04 24 5f 94 10 80 	movl   $0x8010945f,(%esp)
80102e9c:	e8 9c d6 ff ff       	call   8010053d <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102ea1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80102eab:	8b 50 08             	mov    0x8(%eax),%edx
80102eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb1:	0f af c2             	imul   %edx,%eax
80102eb4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102eb7:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102ebb:	7e 0c                	jle    80102ec9 <idestart+0x59>
80102ebd:	c7 04 24 56 94 10 80 	movl   $0x80109456,(%esp)
80102ec4:	e8 74 d6 ff ff       	call   8010053d <panic>
  
  idewait(0);
80102ec9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102ed0:	e8 b1 fe ff ff       	call   80102d86 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102ed5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102edc:	00 
80102edd:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102ee4:	e8 5a fe ff ff       	call   80102d43 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eec:	0f b6 c0             	movzbl %al,%eax
80102eef:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ef3:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102efa:	e8 44 fe ff ff       	call   80102d43 <outb>
  outb(0x1f3, sector & 0xff);
80102eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f02:	0f b6 c0             	movzbl %al,%eax
80102f05:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f09:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102f10:	e8 2e fe ff ff       	call   80102d43 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f18:	c1 f8 08             	sar    $0x8,%eax
80102f1b:	0f b6 c0             	movzbl %al,%eax
80102f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f22:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102f29:	e8 15 fe ff ff       	call   80102d43 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f31:	c1 f8 10             	sar    $0x10,%eax
80102f34:	0f b6 c0             	movzbl %al,%eax
80102f37:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f3b:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102f42:	e8 fc fd ff ff       	call   80102d43 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102f47:	8b 45 08             	mov    0x8(%ebp),%eax
80102f4a:	8b 40 04             	mov    0x4(%eax),%eax
80102f4d:	83 e0 01             	and    $0x1,%eax
80102f50:	89 c2                	mov    %eax,%edx
80102f52:	c1 e2 04             	shl    $0x4,%edx
80102f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f58:	c1 f8 18             	sar    $0x18,%eax
80102f5b:	83 e0 0f             	and    $0xf,%eax
80102f5e:	09 d0                	or     %edx,%eax
80102f60:	83 c8 e0             	or     $0xffffffe0,%eax
80102f63:	0f b6 c0             	movzbl %al,%eax
80102f66:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f6a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102f71:	e8 cd fd ff ff       	call   80102d43 <outb>
  if(b->flags & B_DIRTY){
80102f76:	8b 45 08             	mov    0x8(%ebp),%eax
80102f79:	8b 00                	mov    (%eax),%eax
80102f7b:	83 e0 04             	and    $0x4,%eax
80102f7e:	85 c0                	test   %eax,%eax
80102f80:	74 34                	je     80102fb6 <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
80102f82:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102f89:	00 
80102f8a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102f91:	e8 ad fd ff ff       	call   80102d43 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102f96:	8b 45 08             	mov    0x8(%ebp),%eax
80102f99:	83 c0 18             	add    $0x18,%eax
80102f9c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102fa3:	00 
80102fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fa8:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102faf:	e8 ad fd ff ff       	call   80102d61 <outsl>
80102fb4:	eb 14                	jmp    80102fca <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102fb6:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102fbd:	00 
80102fbe:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102fc5:	e8 79 fd ff ff       	call   80102d43 <outb>
  }
}
80102fca:	c9                   	leave  
80102fcb:	c3                   	ret    

80102fcc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102fcc:	55                   	push   %ebp
80102fcd:	89 e5                	mov    %esp,%ebp
80102fcf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102fd2:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102fd9:	e8 cd 2b 00 00       	call   80105bab <acquire>
  if((b = idequeue) == 0){
80102fde:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102fe6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102fea:	75 11                	jne    80102ffd <ideintr+0x31>
    release(&idelock);
80102fec:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102ff3:	e8 15 2c 00 00       	call   80105c0d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102ff8:	e9 90 00 00 00       	jmp    8010308d <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103000:	8b 40 14             	mov    0x14(%eax),%eax
80103003:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010300b:	8b 00                	mov    (%eax),%eax
8010300d:	83 e0 04             	and    $0x4,%eax
80103010:	85 c0                	test   %eax,%eax
80103012:	75 2e                	jne    80103042 <ideintr+0x76>
80103014:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010301b:	e8 66 fd ff ff       	call   80102d86 <idewait>
80103020:	85 c0                	test   %eax,%eax
80103022:	78 1e                	js     80103042 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80103024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103027:	83 c0 18             	add    $0x18,%eax
8010302a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80103031:	00 
80103032:	89 44 24 04          	mov    %eax,0x4(%esp)
80103036:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010303d:	e8 dc fc ff ff       	call   80102d1e <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80103042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103045:	8b 00                	mov    (%eax),%eax
80103047:	89 c2                	mov    %eax,%edx
80103049:	83 ca 02             	or     $0x2,%edx
8010304c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010304f:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80103051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103054:	8b 00                	mov    (%eax),%eax
80103056:	89 c2                	mov    %eax,%edx
80103058:	83 e2 fb             	and    $0xfffffffb,%edx
8010305b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010305e:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80103060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103063:	89 04 24             	mov    %eax,(%esp)
80103066:	e8 3d 27 00 00       	call   801057a8 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010306b:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80103070:	85 c0                	test   %eax,%eax
80103072:	74 0d                	je     80103081 <ideintr+0xb5>
    idestart(idequeue);
80103074:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80103079:	89 04 24             	mov    %eax,(%esp)
8010307c:	e8 ef fd ff ff       	call   80102e70 <idestart>

  release(&idelock);
80103081:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80103088:	e8 80 2b 00 00       	call   80105c0d <release>
}
8010308d:	c9                   	leave  
8010308e:	c3                   	ret    

8010308f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010308f:	55                   	push   %ebp
80103090:	89 e5                	mov    %esp,%ebp
80103092:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103095:	8b 45 08             	mov    0x8(%ebp),%eax
80103098:	8b 00                	mov    (%eax),%eax
8010309a:	83 e0 01             	and    $0x1,%eax
8010309d:	85 c0                	test   %eax,%eax
8010309f:	75 0c                	jne    801030ad <iderw+0x1e>
    panic("iderw: buf not busy");
801030a1:	c7 04 24 71 94 10 80 	movl   $0x80109471,(%esp)
801030a8:	e8 90 d4 ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801030ad:	8b 45 08             	mov    0x8(%ebp),%eax
801030b0:	8b 00                	mov    (%eax),%eax
801030b2:	83 e0 06             	and    $0x6,%eax
801030b5:	83 f8 02             	cmp    $0x2,%eax
801030b8:	75 0c                	jne    801030c6 <iderw+0x37>
    panic("iderw: nothing to do");
801030ba:	c7 04 24 85 94 10 80 	movl   $0x80109485,(%esp)
801030c1:	e8 77 d4 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801030c6:	8b 45 08             	mov    0x8(%ebp),%eax
801030c9:	8b 40 04             	mov    0x4(%eax),%eax
801030cc:	85 c0                	test   %eax,%eax
801030ce:	74 15                	je     801030e5 <iderw+0x56>
801030d0:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801030d5:	85 c0                	test   %eax,%eax
801030d7:	75 0c                	jne    801030e5 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801030d9:	c7 04 24 9a 94 10 80 	movl   $0x8010949a,(%esp)
801030e0:	e8 58 d4 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
801030e5:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801030ec:	e8 ba 2a 00 00       	call   80105bab <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801030f1:	8b 45 08             	mov    0x8(%ebp),%eax
801030f4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801030fb:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80103102:	eb 0b                	jmp    8010310f <iderw+0x80>
80103104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103107:	8b 00                	mov    (%eax),%eax
80103109:	83 c0 14             	add    $0x14,%eax
8010310c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010310f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103112:	8b 00                	mov    (%eax),%eax
80103114:	85 c0                	test   %eax,%eax
80103116:	75 ec                	jne    80103104 <iderw+0x75>
    ;
  *pp = b;
80103118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010311b:	8b 55 08             	mov    0x8(%ebp),%edx
8010311e:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80103120:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80103125:	3b 45 08             	cmp    0x8(%ebp),%eax
80103128:	75 22                	jne    8010314c <iderw+0xbd>
    idestart(b);
8010312a:	8b 45 08             	mov    0x8(%ebp),%eax
8010312d:	89 04 24             	mov    %eax,(%esp)
80103130:	e8 3b fd ff ff       	call   80102e70 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103135:	eb 15                	jmp    8010314c <iderw+0xbd>
    sleep(b, &idelock);
80103137:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
8010313e:	80 
8010313f:	8b 45 08             	mov    0x8(%ebp),%eax
80103142:	89 04 24             	mov    %eax,(%esp)
80103145:	e8 75 25 00 00       	call   801056bf <sleep>
8010314a:	eb 01                	jmp    8010314d <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010314c:	90                   	nop
8010314d:	8b 45 08             	mov    0x8(%ebp),%eax
80103150:	8b 00                	mov    (%eax),%eax
80103152:	83 e0 06             	and    $0x6,%eax
80103155:	83 f8 02             	cmp    $0x2,%eax
80103158:	75 dd                	jne    80103137 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
8010315a:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80103161:	e8 a7 2a 00 00       	call   80105c0d <release>
}
80103166:	c9                   	leave  
80103167:	c3                   	ret    

80103168 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103168:	55                   	push   %ebp
80103169:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010316b:	a1 54 3a 11 80       	mov    0x80113a54,%eax
80103170:	8b 55 08             	mov    0x8(%ebp),%edx
80103173:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103175:	a1 54 3a 11 80       	mov    0x80113a54,%eax
8010317a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010317d:	5d                   	pop    %ebp
8010317e:	c3                   	ret    

8010317f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010317f:	55                   	push   %ebp
80103180:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103182:	a1 54 3a 11 80       	mov    0x80113a54,%eax
80103187:	8b 55 08             	mov    0x8(%ebp),%edx
8010318a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010318c:	a1 54 3a 11 80       	mov    0x80113a54,%eax
80103191:	8b 55 0c             	mov    0xc(%ebp),%edx
80103194:	89 50 10             	mov    %edx,0x10(%eax)
}
80103197:	5d                   	pop    %ebp
80103198:	c3                   	ret    

80103199 <ioapicinit>:

void
ioapicinit(void)
{
80103199:	55                   	push   %ebp
8010319a:	89 e5                	mov    %esp,%ebp
8010319c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010319f:	a1 84 3b 11 80       	mov    0x80113b84,%eax
801031a4:	85 c0                	test   %eax,%eax
801031a6:	0f 84 9f 00 00 00    	je     8010324b <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801031ac:	c7 05 54 3a 11 80 00 	movl   $0xfec00000,0x80113a54
801031b3:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801031b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031bd:	e8 a6 ff ff ff       	call   80103168 <ioapicread>
801031c2:	c1 e8 10             	shr    $0x10,%eax
801031c5:	25 ff 00 00 00       	and    $0xff,%eax
801031ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801031cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801031d4:	e8 8f ff ff ff       	call   80103168 <ioapicread>
801031d9:	c1 e8 18             	shr    $0x18,%eax
801031dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801031df:	0f b6 05 80 3b 11 80 	movzbl 0x80113b80,%eax
801031e6:	0f b6 c0             	movzbl %al,%eax
801031e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801031ec:	74 0c                	je     801031fa <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801031ee:	c7 04 24 b8 94 10 80 	movl   $0x801094b8,(%esp)
801031f5:	e8 a7 d1 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103201:	eb 3e                	jmp    80103241 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103206:	83 c0 20             	add    $0x20,%eax
80103209:	0d 00 00 01 00       	or     $0x10000,%eax
8010320e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103211:	83 c2 08             	add    $0x8,%edx
80103214:	01 d2                	add    %edx,%edx
80103216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010321a:	89 14 24             	mov    %edx,(%esp)
8010321d:	e8 5d ff ff ff       	call   8010317f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80103222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103225:	83 c0 08             	add    $0x8,%eax
80103228:	01 c0                	add    %eax,%eax
8010322a:	83 c0 01             	add    $0x1,%eax
8010322d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103234:	00 
80103235:	89 04 24             	mov    %eax,(%esp)
80103238:	e8 42 ff ff ff       	call   8010317f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010323d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103244:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103247:	7e ba                	jle    80103203 <ioapicinit+0x6a>
80103249:	eb 01                	jmp    8010324c <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
8010324b:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010324c:	c9                   	leave  
8010324d:	c3                   	ret    

8010324e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010324e:	55                   	push   %ebp
8010324f:	89 e5                	mov    %esp,%ebp
80103251:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80103254:	a1 84 3b 11 80       	mov    0x80113b84,%eax
80103259:	85 c0                	test   %eax,%eax
8010325b:	74 39                	je     80103296 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010325d:	8b 45 08             	mov    0x8(%ebp),%eax
80103260:	83 c0 20             	add    $0x20,%eax
80103263:	8b 55 08             	mov    0x8(%ebp),%edx
80103266:	83 c2 08             	add    $0x8,%edx
80103269:	01 d2                	add    %edx,%edx
8010326b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010326f:	89 14 24             	mov    %edx,(%esp)
80103272:	e8 08 ff ff ff       	call   8010317f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103277:	8b 45 0c             	mov    0xc(%ebp),%eax
8010327a:	c1 e0 18             	shl    $0x18,%eax
8010327d:	8b 55 08             	mov    0x8(%ebp),%edx
80103280:	83 c2 08             	add    $0x8,%edx
80103283:	01 d2                	add    %edx,%edx
80103285:	83 c2 01             	add    $0x1,%edx
80103288:	89 44 24 04          	mov    %eax,0x4(%esp)
8010328c:	89 14 24             	mov    %edx,(%esp)
8010328f:	e8 eb fe ff ff       	call   8010317f <ioapicwrite>
80103294:	eb 01                	jmp    80103297 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103296:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103297:	c9                   	leave  
80103298:	c3                   	ret    
80103299:	00 00                	add    %al,(%eax)
	...

8010329c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010329c:	55                   	push   %ebp
8010329d:	89 e5                	mov    %esp,%ebp
8010329f:	8b 45 08             	mov    0x8(%ebp),%eax
801032a2:	05 00 00 00 80       	add    $0x80000000,%eax
801032a7:	5d                   	pop    %ebp
801032a8:	c3                   	ret    

801032a9 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801032a9:	55                   	push   %ebp
801032aa:	89 e5                	mov    %esp,%ebp
801032ac:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801032af:	c7 44 24 04 ea 94 10 	movl   $0x801094ea,0x4(%esp)
801032b6:	80 
801032b7:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801032be:	e8 c7 28 00 00       	call   80105b8a <initlock>
  kmem.use_lock = 0;
801032c3:	c7 05 94 3a 11 80 00 	movl   $0x0,0x80113a94
801032ca:	00 00 00 
  freerange(vstart, vend);
801032cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801032d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d4:	8b 45 08             	mov    0x8(%ebp),%eax
801032d7:	89 04 24             	mov    %eax,(%esp)
801032da:	e8 26 00 00 00       	call   80103305 <freerange>
}
801032df:	c9                   	leave  
801032e0:	c3                   	ret    

801032e1 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801032e1:	55                   	push   %ebp
801032e2:	89 e5                	mov    %esp,%ebp
801032e4:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801032e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801032ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801032ee:	8b 45 08             	mov    0x8(%ebp),%eax
801032f1:	89 04 24             	mov    %eax,(%esp)
801032f4:	e8 0c 00 00 00       	call   80103305 <freerange>
  kmem.use_lock = 1;
801032f9:	c7 05 94 3a 11 80 01 	movl   $0x1,0x80113a94
80103300:	00 00 00 
}
80103303:	c9                   	leave  
80103304:	c3                   	ret    

80103305 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103305:	55                   	push   %ebp
80103306:	89 e5                	mov    %esp,%ebp
80103308:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010330b:	8b 45 08             	mov    0x8(%ebp),%eax
8010330e:	05 ff 0f 00 00       	add    $0xfff,%eax
80103313:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103318:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010331b:	eb 12                	jmp    8010332f <freerange+0x2a>
    kfree(p);
8010331d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103320:	89 04 24             	mov    %eax,(%esp)
80103323:	e8 16 00 00 00       	call   8010333e <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103328:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010332f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103332:	05 00 10 00 00       	add    $0x1000,%eax
80103337:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010333a:	76 e1                	jbe    8010331d <freerange+0x18>
    kfree(p);
}
8010333c:	c9                   	leave  
8010333d:	c3                   	ret    

8010333e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010333e:	55                   	push   %ebp
8010333f:	89 e5                	mov    %esp,%ebp
80103341:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80103344:	8b 45 08             	mov    0x8(%ebp),%eax
80103347:	25 ff 0f 00 00       	and    $0xfff,%eax
8010334c:	85 c0                	test   %eax,%eax
8010334e:	75 1b                	jne    8010336b <kfree+0x2d>
80103350:	81 7d 08 7c 6e 11 80 	cmpl   $0x80116e7c,0x8(%ebp)
80103357:	72 12                	jb     8010336b <kfree+0x2d>
80103359:	8b 45 08             	mov    0x8(%ebp),%eax
8010335c:	89 04 24             	mov    %eax,(%esp)
8010335f:	e8 38 ff ff ff       	call   8010329c <v2p>
80103364:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103369:	76 0c                	jbe    80103377 <kfree+0x39>
    panic("kfree");
8010336b:	c7 04 24 ef 94 10 80 	movl   $0x801094ef,(%esp)
80103372:	e8 c6 d1 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103377:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010337e:	00 
8010337f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103386:	00 
80103387:	8b 45 08             	mov    0x8(%ebp),%eax
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 68 2a 00 00       	call   80105dfa <memset>

  if(kmem.use_lock)
80103392:	a1 94 3a 11 80       	mov    0x80113a94,%eax
80103397:	85 c0                	test   %eax,%eax
80103399:	74 0c                	je     801033a7 <kfree+0x69>
    acquire(&kmem.lock);
8010339b:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801033a2:	e8 04 28 00 00       	call   80105bab <acquire>
  r = (struct run*)v;
801033a7:	8b 45 08             	mov    0x8(%ebp),%eax
801033aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801033ad:	8b 15 98 3a 11 80    	mov    0x80113a98,%edx
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801033b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033bb:	a3 98 3a 11 80       	mov    %eax,0x80113a98
  if(kmem.use_lock)
801033c0:	a1 94 3a 11 80       	mov    0x80113a94,%eax
801033c5:	85 c0                	test   %eax,%eax
801033c7:	74 0c                	je     801033d5 <kfree+0x97>
    release(&kmem.lock);
801033c9:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801033d0:	e8 38 28 00 00       	call   80105c0d <release>
}
801033d5:	c9                   	leave  
801033d6:	c3                   	ret    

801033d7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801033d7:	55                   	push   %ebp
801033d8:	89 e5                	mov    %esp,%ebp
801033da:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
801033dd:	a1 94 3a 11 80       	mov    0x80113a94,%eax
801033e2:	85 c0                	test   %eax,%eax
801033e4:	74 0c                	je     801033f2 <kalloc+0x1b>
    acquire(&kmem.lock);
801033e6:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
801033ed:	e8 b9 27 00 00       	call   80105bab <acquire>
  r = kmem.freelist;
801033f2:	a1 98 3a 11 80       	mov    0x80113a98,%eax
801033f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801033fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801033fe:	74 0a                	je     8010340a <kalloc+0x33>
    kmem.freelist = r->next;
80103400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103403:	8b 00                	mov    (%eax),%eax
80103405:	a3 98 3a 11 80       	mov    %eax,0x80113a98
  if(kmem.use_lock)
8010340a:	a1 94 3a 11 80       	mov    0x80113a94,%eax
8010340f:	85 c0                	test   %eax,%eax
80103411:	74 0c                	je     8010341f <kalloc+0x48>
    release(&kmem.lock);
80103413:	c7 04 24 60 3a 11 80 	movl   $0x80113a60,(%esp)
8010341a:	e8 ee 27 00 00       	call   80105c0d <release>
  return (char*)r;
8010341f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103422:	c9                   	leave  
80103423:	c3                   	ret    

80103424 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103424:	55                   	push   %ebp
80103425:	89 e5                	mov    %esp,%ebp
80103427:	53                   	push   %ebx
80103428:	83 ec 14             	sub    $0x14,%esp
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103432:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103436:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010343a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010343e:	ec                   	in     (%dx),%al
8010343f:	89 c3                	mov    %eax,%ebx
80103441:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103444:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103448:	83 c4 14             	add    $0x14,%esp
8010344b:	5b                   	pop    %ebx
8010344c:	5d                   	pop    %ebp
8010344d:	c3                   	ret    

8010344e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010344e:	55                   	push   %ebp
8010344f:	89 e5                	mov    %esp,%ebp
80103451:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103454:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010345b:	e8 c4 ff ff ff       	call   80103424 <inb>
80103460:	0f b6 c0             	movzbl %al,%eax
80103463:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103469:	83 e0 01             	and    $0x1,%eax
8010346c:	85 c0                	test   %eax,%eax
8010346e:	75 0a                	jne    8010347a <kbdgetc+0x2c>
    return -1;
80103470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103475:	e9 23 01 00 00       	jmp    8010359d <kbdgetc+0x14f>
  data = inb(KBDATAP);
8010347a:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80103481:	e8 9e ff ff ff       	call   80103424 <inb>
80103486:	0f b6 c0             	movzbl %al,%eax
80103489:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010348c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103493:	75 17                	jne    801034ac <kbdgetc+0x5e>
    shift |= E0ESC;
80103495:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
8010349a:	83 c8 40             	or     $0x40,%eax
8010349d:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
801034a2:	b8 00 00 00 00       	mov    $0x0,%eax
801034a7:	e9 f1 00 00 00       	jmp    8010359d <kbdgetc+0x14f>
  } else if(data & 0x80){
801034ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034af:	25 80 00 00 00       	and    $0x80,%eax
801034b4:	85 c0                	test   %eax,%eax
801034b6:	74 45                	je     801034fd <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801034b8:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
801034bd:	83 e0 40             	and    $0x40,%eax
801034c0:	85 c0                	test   %eax,%eax
801034c2:	75 08                	jne    801034cc <kbdgetc+0x7e>
801034c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034c7:	83 e0 7f             	and    $0x7f,%eax
801034ca:	eb 03                	jmp    801034cf <kbdgetc+0x81>
801034cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801034d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034d5:	05 20 a0 10 80       	add    $0x8010a020,%eax
801034da:	0f b6 00             	movzbl (%eax),%eax
801034dd:	83 c8 40             	or     $0x40,%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	f7 d0                	not    %eax
801034e5:	89 c2                	mov    %eax,%edx
801034e7:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
801034ec:	21 d0                	and    %edx,%eax
801034ee:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
801034f3:	b8 00 00 00 00       	mov    $0x0,%eax
801034f8:	e9 a0 00 00 00       	jmp    8010359d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
801034fd:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103502:	83 e0 40             	and    $0x40,%eax
80103505:	85 c0                	test   %eax,%eax
80103507:	74 14                	je     8010351d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103509:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103510:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103515:	83 e0 bf             	and    $0xffffffbf,%eax
80103518:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
8010351d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103520:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103525:	0f b6 00             	movzbl (%eax),%eax
80103528:	0f b6 d0             	movzbl %al,%edx
8010352b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103530:	09 d0                	or     %edx,%eax
80103532:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80103537:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010353a:	05 20 a1 10 80       	add    $0x8010a120,%eax
8010353f:	0f b6 00             	movzbl (%eax),%eax
80103542:	0f b6 d0             	movzbl %al,%edx
80103545:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
8010354a:	31 d0                	xor    %edx,%eax
8010354c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80103551:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103556:	83 e0 03             	and    $0x3,%eax
80103559:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80103560:	03 45 fc             	add    -0x4(%ebp),%eax
80103563:	0f b6 00             	movzbl (%eax),%eax
80103566:	0f b6 c0             	movzbl %al,%eax
80103569:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010356c:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80103571:	83 e0 08             	and    $0x8,%eax
80103574:	85 c0                	test   %eax,%eax
80103576:	74 22                	je     8010359a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80103578:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010357c:	76 0c                	jbe    8010358a <kbdgetc+0x13c>
8010357e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103582:	77 06                	ja     8010358a <kbdgetc+0x13c>
      c += 'A' - 'a';
80103584:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103588:	eb 10                	jmp    8010359a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
8010358a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010358e:	76 0a                	jbe    8010359a <kbdgetc+0x14c>
80103590:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103594:	77 04                	ja     8010359a <kbdgetc+0x14c>
      c += 'a' - 'A';
80103596:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010359a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010359d:	c9                   	leave  
8010359e:	c3                   	ret    

8010359f <kbdintr>:

void
kbdintr(void)
{
8010359f:	55                   	push   %ebp
801035a0:	89 e5                	mov    %esp,%ebp
801035a2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801035a5:	c7 04 24 4e 34 10 80 	movl   $0x8010344e,(%esp)
801035ac:	e8 fd d5 ff ff       	call   80100bae <consoleintr>
}
801035b1:	c9                   	leave  
801035b2:	c3                   	ret    
	...

801035b4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801035b4:	55                   	push   %ebp
801035b5:	89 e5                	mov    %esp,%ebp
801035b7:	53                   	push   %ebx
801035b8:	83 ec 14             	sub    $0x14,%esp
801035bb:	8b 45 08             	mov    0x8(%ebp),%eax
801035be:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035c2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801035c6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801035ca:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801035ce:	ec                   	in     (%dx),%al
801035cf:	89 c3                	mov    %eax,%ebx
801035d1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801035d4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801035d8:	83 c4 14             	add    $0x14,%esp
801035db:	5b                   	pop    %ebx
801035dc:	5d                   	pop    %ebp
801035dd:	c3                   	ret    

801035de <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801035de:	55                   	push   %ebp
801035df:	89 e5                	mov    %esp,%ebp
801035e1:	83 ec 08             	sub    $0x8,%esp
801035e4:	8b 55 08             	mov    0x8(%ebp),%edx
801035e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801035ea:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801035ee:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035f1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801035f5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801035f9:	ee                   	out    %al,(%dx)
}
801035fa:	c9                   	leave  
801035fb:	c3                   	ret    

801035fc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801035fc:	55                   	push   %ebp
801035fd:	89 e5                	mov    %esp,%ebp
801035ff:	53                   	push   %ebx
80103600:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103603:	9c                   	pushf  
80103604:	5b                   	pop    %ebx
80103605:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103608:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010360b:	83 c4 10             	add    $0x10,%esp
8010360e:	5b                   	pop    %ebx
8010360f:	5d                   	pop    %ebp
80103610:	c3                   	ret    

80103611 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103611:	55                   	push   %ebp
80103612:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103614:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
80103619:	8b 55 08             	mov    0x8(%ebp),%edx
8010361c:	c1 e2 02             	shl    $0x2,%edx
8010361f:	01 c2                	add    %eax,%edx
80103621:	8b 45 0c             	mov    0xc(%ebp),%eax
80103624:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103626:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
8010362b:	83 c0 20             	add    $0x20,%eax
8010362e:	8b 00                	mov    (%eax),%eax
}
80103630:	5d                   	pop    %ebp
80103631:	c3                   	ret    

80103632 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80103632:	55                   	push   %ebp
80103633:	89 e5                	mov    %esp,%ebp
80103635:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103638:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
8010363d:	85 c0                	test   %eax,%eax
8010363f:	0f 84 47 01 00 00    	je     8010378c <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103645:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010364c:	00 
8010364d:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103654:	e8 b8 ff ff ff       	call   80103611 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103659:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103660:	00 
80103661:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103668:	e8 a4 ff ff ff       	call   80103611 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010366d:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103674:	00 
80103675:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010367c:	e8 90 ff ff ff       	call   80103611 <lapicw>
  lapicw(TICR, 10000000); 
80103681:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103688:	00 
80103689:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80103690:	e8 7c ff ff ff       	call   80103611 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103695:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010369c:	00 
8010369d:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801036a4:	e8 68 ff ff ff       	call   80103611 <lapicw>
  lapicw(LINT1, MASKED);
801036a9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801036b0:	00 
801036b1:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801036b8:	e8 54 ff ff ff       	call   80103611 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801036bd:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
801036c2:	83 c0 30             	add    $0x30,%eax
801036c5:	8b 00                	mov    (%eax),%eax
801036c7:	c1 e8 10             	shr    $0x10,%eax
801036ca:	25 ff 00 00 00       	and    $0xff,%eax
801036cf:	83 f8 03             	cmp    $0x3,%eax
801036d2:	76 14                	jbe    801036e8 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801036d4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801036db:	00 
801036dc:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801036e3:	e8 29 ff ff ff       	call   80103611 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801036e8:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801036ef:	00 
801036f0:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801036f7:	e8 15 ff ff ff       	call   80103611 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801036fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103703:	00 
80103704:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010370b:	e8 01 ff ff ff       	call   80103611 <lapicw>
  lapicw(ESR, 0);
80103710:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103717:	00 
80103718:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010371f:	e8 ed fe ff ff       	call   80103611 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103724:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010372b:	00 
8010372c:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103733:	e8 d9 fe ff ff       	call   80103611 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103738:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010373f:	00 
80103740:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103747:	e8 c5 fe ff ff       	call   80103611 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010374c:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103753:	00 
80103754:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010375b:	e8 b1 fe ff ff       	call   80103611 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103760:	90                   	nop
80103761:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
80103766:	05 00 03 00 00       	add    $0x300,%eax
8010376b:	8b 00                	mov    (%eax),%eax
8010376d:	25 00 10 00 00       	and    $0x1000,%eax
80103772:	85 c0                	test   %eax,%eax
80103774:	75 eb                	jne    80103761 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103776:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010377d:	00 
8010377e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103785:	e8 87 fe ff ff       	call   80103611 <lapicw>
8010378a:	eb 01                	jmp    8010378d <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010378c:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010378d:	c9                   	leave  
8010378e:	c3                   	ret    

8010378f <cpunum>:

int
cpunum(void)
{
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103795:	e8 62 fe ff ff       	call   801035fc <readeflags>
8010379a:	25 00 02 00 00       	and    $0x200,%eax
8010379f:	85 c0                	test   %eax,%eax
801037a1:	74 29                	je     801037cc <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801037a3:	a1 60 c6 10 80       	mov    0x8010c660,%eax
801037a8:	85 c0                	test   %eax,%eax
801037aa:	0f 94 c2             	sete   %dl
801037ad:	83 c0 01             	add    $0x1,%eax
801037b0:	a3 60 c6 10 80       	mov    %eax,0x8010c660
801037b5:	84 d2                	test   %dl,%dl
801037b7:	74 13                	je     801037cc <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801037b9:	8b 45 04             	mov    0x4(%ebp),%eax
801037bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801037c0:	c7 04 24 f8 94 10 80 	movl   $0x801094f8,(%esp)
801037c7:	e8 d5 cb ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801037cc:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
801037d1:	85 c0                	test   %eax,%eax
801037d3:	74 0f                	je     801037e4 <cpunum+0x55>
    return lapic[ID]>>24;
801037d5:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
801037da:	83 c0 20             	add    $0x20,%eax
801037dd:	8b 00                	mov    (%eax),%eax
801037df:	c1 e8 18             	shr    $0x18,%eax
801037e2:	eb 05                	jmp    801037e9 <cpunum+0x5a>
  return 0;
801037e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801037e9:	c9                   	leave  
801037ea:	c3                   	ret    

801037eb <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801037eb:	55                   	push   %ebp
801037ec:	89 e5                	mov    %esp,%ebp
801037ee:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801037f1:	a1 9c 3a 11 80       	mov    0x80113a9c,%eax
801037f6:	85 c0                	test   %eax,%eax
801037f8:	74 14                	je     8010380e <lapiceoi+0x23>
    lapicw(EOI, 0);
801037fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103801:	00 
80103802:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103809:	e8 03 fe ff ff       	call   80103611 <lapicw>
}
8010380e:	c9                   	leave  
8010380f:	c3                   	ret    

80103810 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103810:	55                   	push   %ebp
80103811:	89 e5                	mov    %esp,%ebp
}
80103813:	5d                   	pop    %ebp
80103814:	c3                   	ret    

80103815 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103815:	55                   	push   %ebp
80103816:	89 e5                	mov    %esp,%ebp
80103818:	83 ec 1c             	sub    $0x1c,%esp
8010381b:	8b 45 08             	mov    0x8(%ebp),%eax
8010381e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103821:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103828:	00 
80103829:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103830:	e8 a9 fd ff ff       	call   801035de <outb>
  outb(CMOS_PORT+1, 0x0A);
80103835:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010383c:	00 
8010383d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103844:	e8 95 fd ff ff       	call   801035de <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103849:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103850:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103853:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103858:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010385b:	8d 50 02             	lea    0x2(%eax),%edx
8010385e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103861:	c1 e8 04             	shr    $0x4,%eax
80103864:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103867:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010386b:	c1 e0 18             	shl    $0x18,%eax
8010386e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103872:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103879:	e8 93 fd ff ff       	call   80103611 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010387e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103885:	00 
80103886:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010388d:	e8 7f fd ff ff       	call   80103611 <lapicw>
  microdelay(200);
80103892:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103899:	e8 72 ff ff ff       	call   80103810 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010389e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801038a5:	00 
801038a6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801038ad:	e8 5f fd ff ff       	call   80103611 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038b2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801038b9:	e8 52 ff ff ff       	call   80103810 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038c5:	eb 40                	jmp    80103907 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801038c7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038cb:	c1 e0 18             	shl    $0x18,%eax
801038ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801038d2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801038d9:	e8 33 fd ff ff       	call   80103611 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801038de:	8b 45 0c             	mov    0xc(%ebp),%eax
801038e1:	c1 e8 0c             	shr    $0xc,%eax
801038e4:	80 cc 06             	or     $0x6,%ah
801038e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801038eb:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801038f2:	e8 1a fd ff ff       	call   80103611 <lapicw>
    microdelay(200);
801038f7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801038fe:	e8 0d ff ff ff       	call   80103810 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103903:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103907:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010390b:	7e ba                	jle    801038c7 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010390d:	c9                   	leave  
8010390e:	c3                   	ret    

8010390f <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010390f:	55                   	push   %ebp
80103910:	89 e5                	mov    %esp,%ebp
80103912:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103915:	8b 45 08             	mov    0x8(%ebp),%eax
80103918:	0f b6 c0             	movzbl %al,%eax
8010391b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010391f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103926:	e8 b3 fc ff ff       	call   801035de <outb>
  microdelay(200);
8010392b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103932:	e8 d9 fe ff ff       	call   80103810 <microdelay>

  return inb(CMOS_RETURN);
80103937:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010393e:	e8 71 fc ff ff       	call   801035b4 <inb>
80103943:	0f b6 c0             	movzbl %al,%eax
}
80103946:	c9                   	leave  
80103947:	c3                   	ret    

80103948 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103948:	55                   	push   %ebp
80103949:	89 e5                	mov    %esp,%ebp
8010394b:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010394e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103955:	e8 b5 ff ff ff       	call   8010390f <cmos_read>
8010395a:	8b 55 08             	mov    0x8(%ebp),%edx
8010395d:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010395f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103966:	e8 a4 ff ff ff       	call   8010390f <cmos_read>
8010396b:	8b 55 08             	mov    0x8(%ebp),%edx
8010396e:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103971:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103978:	e8 92 ff ff ff       	call   8010390f <cmos_read>
8010397d:	8b 55 08             	mov    0x8(%ebp),%edx
80103980:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103983:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010398a:	e8 80 ff ff ff       	call   8010390f <cmos_read>
8010398f:	8b 55 08             	mov    0x8(%ebp),%edx
80103992:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103995:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010399c:	e8 6e ff ff ff       	call   8010390f <cmos_read>
801039a1:	8b 55 08             	mov    0x8(%ebp),%edx
801039a4:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801039a7:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801039ae:	e8 5c ff ff ff       	call   8010390f <cmos_read>
801039b3:	8b 55 08             	mov    0x8(%ebp),%edx
801039b6:	89 42 14             	mov    %eax,0x14(%edx)
}
801039b9:	c9                   	leave  
801039ba:	c3                   	ret    

801039bb <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039bb:	55                   	push   %ebp
801039bc:	89 e5                	mov    %esp,%ebp
801039be:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039c1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801039c8:	e8 42 ff ff ff       	call   8010390f <cmos_read>
801039cd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d3:	83 e0 04             	and    $0x4,%eax
801039d6:	85 c0                	test   %eax,%eax
801039d8:	0f 94 c0             	sete   %al
801039db:	0f b6 c0             	movzbl %al,%eax
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
801039e1:	eb 01                	jmp    801039e4 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801039e3:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039e4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039e7:	89 04 24             	mov    %eax,(%esp)
801039ea:	e8 59 ff ff ff       	call   80103948 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801039ef:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801039f6:	e8 14 ff ff ff       	call   8010390f <cmos_read>
801039fb:	25 80 00 00 00       	and    $0x80,%eax
80103a00:	85 c0                	test   %eax,%eax
80103a02:	75 2b                	jne    80103a2f <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
80103a04:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a07:	89 04 24             	mov    %eax,(%esp)
80103a0a:	e8 39 ff ff ff       	call   80103948 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a0f:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103a16:	00 
80103a17:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a1e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a21:	89 04 24             	mov    %eax,(%esp)
80103a24:	e8 48 24 00 00       	call   80105e71 <memcmp>
80103a29:	85 c0                	test   %eax,%eax
80103a2b:	75 b6                	jne    801039e3 <cmostime+0x28>
      break;
80103a2d:	eb 03                	jmp    80103a32 <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a2f:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a30:	eb b1                	jmp    801039e3 <cmostime+0x28>

  // convert
  if (bcd) {
80103a32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a36:	0f 84 a8 00 00 00    	je     80103ae4 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a3f:	89 c2                	mov    %eax,%edx
80103a41:	c1 ea 04             	shr    $0x4,%edx
80103a44:	89 d0                	mov    %edx,%eax
80103a46:	c1 e0 02             	shl    $0x2,%eax
80103a49:	01 d0                	add    %edx,%eax
80103a4b:	01 c0                	add    %eax,%eax
80103a4d:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103a50:	83 e2 0f             	and    $0xf,%edx
80103a53:	01 d0                	add    %edx,%eax
80103a55:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a5b:	89 c2                	mov    %eax,%edx
80103a5d:	c1 ea 04             	shr    $0x4,%edx
80103a60:	89 d0                	mov    %edx,%eax
80103a62:	c1 e0 02             	shl    $0x2,%eax
80103a65:	01 d0                	add    %edx,%eax
80103a67:	01 c0                	add    %eax,%eax
80103a69:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103a6c:	83 e2 0f             	and    $0xf,%edx
80103a6f:	01 d0                	add    %edx,%eax
80103a71:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a77:	89 c2                	mov    %eax,%edx
80103a79:	c1 ea 04             	shr    $0x4,%edx
80103a7c:	89 d0                	mov    %edx,%eax
80103a7e:	c1 e0 02             	shl    $0x2,%eax
80103a81:	01 d0                	add    %edx,%eax
80103a83:	01 c0                	add    %eax,%eax
80103a85:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103a88:	83 e2 0f             	and    $0xf,%edx
80103a8b:	01 d0                	add    %edx,%eax
80103a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a93:	89 c2                	mov    %eax,%edx
80103a95:	c1 ea 04             	shr    $0x4,%edx
80103a98:	89 d0                	mov    %edx,%eax
80103a9a:	c1 e0 02             	shl    $0x2,%eax
80103a9d:	01 d0                	add    %edx,%eax
80103a9f:	01 c0                	add    %eax,%eax
80103aa1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103aa4:	83 e2 0f             	and    $0xf,%edx
80103aa7:	01 d0                	add    %edx,%eax
80103aa9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103aaf:	89 c2                	mov    %eax,%edx
80103ab1:	c1 ea 04             	shr    $0x4,%edx
80103ab4:	89 d0                	mov    %edx,%eax
80103ab6:	c1 e0 02             	shl    $0x2,%eax
80103ab9:	01 d0                	add    %edx,%eax
80103abb:	01 c0                	add    %eax,%eax
80103abd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103ac0:	83 e2 0f             	and    $0xf,%edx
80103ac3:	01 d0                	add    %edx,%eax
80103ac5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103acb:	89 c2                	mov    %eax,%edx
80103acd:	c1 ea 04             	shr    $0x4,%edx
80103ad0:	89 d0                	mov    %edx,%eax
80103ad2:	c1 e0 02             	shl    $0x2,%eax
80103ad5:	01 d0                	add    %edx,%eax
80103ad7:	01 c0                	add    %eax,%eax
80103ad9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103adc:	83 e2 0f             	and    $0xf,%edx
80103adf:	01 d0                	add    %edx,%eax
80103ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103aea:	89 10                	mov    %edx,(%eax)
80103aec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103aef:	89 50 04             	mov    %edx,0x4(%eax)
80103af2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103af5:	89 50 08             	mov    %edx,0x8(%eax)
80103af8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103afb:	89 50 0c             	mov    %edx,0xc(%eax)
80103afe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b01:	89 50 10             	mov    %edx,0x10(%eax)
80103b04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b07:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0d:	8b 40 14             	mov    0x14(%eax),%eax
80103b10:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b16:	8b 45 08             	mov    0x8(%ebp),%eax
80103b19:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b1c:	c9                   	leave  
80103b1d:	c3                   	ret    
	...

80103b20 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103b20:	55                   	push   %ebp
80103b21:	89 e5                	mov    %esp,%ebp
80103b23:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103b26:	c7 44 24 04 24 95 10 	movl   $0x80109524,0x4(%esp)
80103b2d:	80 
80103b2e:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103b35:	e8 50 20 00 00       	call   80105b8a <initlock>
  readsb(dev, &sb);
80103b3a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b41:	8b 45 08             	mov    0x8(%ebp),%eax
80103b44:	89 04 24             	mov    %eax,(%esp)
80103b47:	e8 dc df ff ff       	call   80101b28 <readsb>
  log.start = sb.logstart;
80103b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b4f:	a3 d4 3a 11 80       	mov    %eax,0x80113ad4
  log.size = sb.nlog;
80103b54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b57:	a3 d8 3a 11 80       	mov    %eax,0x80113ad8
  log.dev = dev;
80103b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b5f:	a3 e4 3a 11 80       	mov    %eax,0x80113ae4
  recover_from_log();
80103b64:	e8 97 01 00 00       	call   80103d00 <recover_from_log>
}
80103b69:	c9                   	leave  
80103b6a:	c3                   	ret    

80103b6b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103b6b:	55                   	push   %ebp
80103b6c:	89 e5                	mov    %esp,%ebp
80103b6e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b78:	e9 89 00 00 00       	jmp    80103c06 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103b7d:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103b82:	03 45 f4             	add    -0xc(%ebp),%eax
80103b85:	83 c0 01             	add    $0x1,%eax
80103b88:	89 c2                	mov    %eax,%edx
80103b8a:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103b8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b93:	89 04 24             	mov    %eax,(%esp)
80103b96:	e8 0b c6 ff ff       	call   801001a6 <bread>
80103b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba1:	83 c0 10             	add    $0x10,%eax
80103ba4:	8b 04 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%eax
80103bab:	89 c2                	mov    %eax,%edx
80103bad:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103bb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80103bb6:	89 04 24             	mov    %eax,(%esp)
80103bb9:	e8 e8 c5 ff ff       	call   801001a6 <bread>
80103bbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc4:	8d 50 18             	lea    0x18(%eax),%edx
80103bc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bca:	83 c0 18             	add    $0x18,%eax
80103bcd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103bd4:	00 
80103bd5:	89 54 24 04          	mov    %edx,0x4(%esp)
80103bd9:	89 04 24             	mov    %eax,(%esp)
80103bdc:	e8 ec 22 00 00       	call   80105ecd <memmove>
    bwrite(dbuf);  // write dst to disk
80103be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103be4:	89 04 24             	mov    %eax,(%esp)
80103be7:	e8 f1 c5 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bef:	89 04 24             	mov    %eax,(%esp)
80103bf2:	e8 20 c6 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bfa:	89 04 24             	mov    %eax,(%esp)
80103bfd:	e8 15 c6 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103c02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c06:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103c0b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c0e:	0f 8f 69 ff ff ff    	jg     80103b7d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103c14:	c9                   	leave  
80103c15:	c3                   	ret    

80103c16 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103c16:	55                   	push   %ebp
80103c17:	89 e5                	mov    %esp,%ebp
80103c19:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103c1c:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103c21:	89 c2                	mov    %eax,%edx
80103c23:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103c28:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c2c:	89 04 24             	mov    %eax,(%esp)
80103c2f:	e8 72 c5 ff ff       	call   801001a6 <bread>
80103c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3a:	83 c0 18             	add    $0x18,%eax
80103c3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103c40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c43:	8b 00                	mov    (%eax),%eax
80103c45:	a3 e8 3a 11 80       	mov    %eax,0x80113ae8
  for (i = 0; i < log.lh.n; i++) {
80103c4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c51:	eb 1b                	jmp    80103c6e <read_head+0x58>
    log.lh.block[i] = lh->block[i];
80103c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c59:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103c5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c60:	83 c2 10             	add    $0x10,%edx
80103c63:	89 04 95 ac 3a 11 80 	mov    %eax,-0x7feec554(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103c6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c6e:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103c73:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c76:	7f db                	jg     80103c53 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7b:	89 04 24             	mov    %eax,(%esp)
80103c7e:	e8 94 c5 ff ff       	call   80100217 <brelse>
}
80103c83:	c9                   	leave  
80103c84:	c3                   	ret    

80103c85 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103c85:	55                   	push   %ebp
80103c86:	89 e5                	mov    %esp,%ebp
80103c88:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103c8b:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103c90:	89 c2                	mov    %eax,%edx
80103c92:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103c97:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c9b:	89 04 24             	mov    %eax,(%esp)
80103c9e:	e8 03 c5 ff ff       	call   801001a6 <bread>
80103ca3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca9:	83 c0 18             	add    $0x18,%eax
80103cac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103caf:	8b 15 e8 3a 11 80    	mov    0x80113ae8,%edx
80103cb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cb8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103cba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103cc1:	eb 1b                	jmp    80103cde <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc6:	83 c0 10             	add    $0x10,%eax
80103cc9:	8b 0c 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%ecx
80103cd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103cda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cde:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103ce3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ce6:	7f db                	jg     80103cc3 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ceb:	89 04 24             	mov    %eax,(%esp)
80103cee:	e8 ea c4 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf6:	89 04 24             	mov    %eax,(%esp)
80103cf9:	e8 19 c5 ff ff       	call   80100217 <brelse>
}
80103cfe:	c9                   	leave  
80103cff:	c3                   	ret    

80103d00 <recover_from_log>:

static void
recover_from_log(void)
{
80103d00:	55                   	push   %ebp
80103d01:	89 e5                	mov    %esp,%ebp
80103d03:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103d06:	e8 0b ff ff ff       	call   80103c16 <read_head>
  install_trans(); // if committed, copy from log to disk
80103d0b:	e8 5b fe ff ff       	call   80103b6b <install_trans>
  log.lh.n = 0;
80103d10:	c7 05 e8 3a 11 80 00 	movl   $0x0,0x80113ae8
80103d17:	00 00 00 
  write_head(); // clear the log
80103d1a:	e8 66 ff ff ff       	call   80103c85 <write_head>
}
80103d1f:	c9                   	leave  
80103d20:	c3                   	ret    

80103d21 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103d21:	55                   	push   %ebp
80103d22:	89 e5                	mov    %esp,%ebp
80103d24:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103d27:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d2e:	e8 78 1e 00 00       	call   80105bab <acquire>
  while(1){
    if(log.committing){
80103d33:	a1 e0 3a 11 80       	mov    0x80113ae0,%eax
80103d38:	85 c0                	test   %eax,%eax
80103d3a:	74 16                	je     80103d52 <begin_op+0x31>
      sleep(&log, &log.lock);
80103d3c:	c7 44 24 04 a0 3a 11 	movl   $0x80113aa0,0x4(%esp)
80103d43:	80 
80103d44:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d4b:	e8 6f 19 00 00       	call   801056bf <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103d50:	eb e1                	jmp    80103d33 <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103d52:	8b 0d e8 3a 11 80    	mov    0x80113ae8,%ecx
80103d58:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103d5d:	8d 50 01             	lea    0x1(%eax),%edx
80103d60:	89 d0                	mov    %edx,%eax
80103d62:	c1 e0 02             	shl    $0x2,%eax
80103d65:	01 d0                	add    %edx,%eax
80103d67:	01 c0                	add    %eax,%eax
80103d69:	01 c8                	add    %ecx,%eax
80103d6b:	83 f8 1e             	cmp    $0x1e,%eax
80103d6e:	7e 16                	jle    80103d86 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103d70:	c7 44 24 04 a0 3a 11 	movl   $0x80113aa0,0x4(%esp)
80103d77:	80 
80103d78:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d7f:	e8 3b 19 00 00       	call   801056bf <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103d84:	eb ad                	jmp    80103d33 <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80103d86:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103d8b:	83 c0 01             	add    $0x1,%eax
80103d8e:	a3 dc 3a 11 80       	mov    %eax,0x80113adc
      release(&log.lock);
80103d93:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103d9a:	e8 6e 1e 00 00       	call   80105c0d <release>
      break;
80103d9f:	90                   	nop
    }
  }
}
80103da0:	c9                   	leave  
80103da1:	c3                   	ret    

80103da2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103da2:	55                   	push   %ebp
80103da3:	89 e5                	mov    %esp,%ebp
80103da5:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103da8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103daf:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103db6:	e8 f0 1d 00 00       	call   80105bab <acquire>
  log.outstanding -= 1;
80103dbb:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103dc0:	83 e8 01             	sub    $0x1,%eax
80103dc3:	a3 dc 3a 11 80       	mov    %eax,0x80113adc
  if(log.committing)
80103dc8:	a1 e0 3a 11 80       	mov    0x80113ae0,%eax
80103dcd:	85 c0                	test   %eax,%eax
80103dcf:	74 0c                	je     80103ddd <end_op+0x3b>
    panic("log.committing");
80103dd1:	c7 04 24 28 95 10 80 	movl   $0x80109528,(%esp)
80103dd8:	e8 60 c7 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
80103ddd:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103de2:	85 c0                	test   %eax,%eax
80103de4:	75 13                	jne    80103df9 <end_op+0x57>
    do_commit = 1;
80103de6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103ded:	c7 05 e0 3a 11 80 01 	movl   $0x1,0x80113ae0
80103df4:	00 00 00 
80103df7:	eb 0c                	jmp    80103e05 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103df9:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e00:	e8 a3 19 00 00       	call   801057a8 <wakeup>
  }
  release(&log.lock);
80103e05:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e0c:	e8 fc 1d 00 00       	call   80105c0d <release>

  if(do_commit){
80103e11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e15:	74 33                	je     80103e4a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103e17:	e8 db 00 00 00       	call   80103ef7 <commit>
    acquire(&log.lock);
80103e1c:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e23:	e8 83 1d 00 00       	call   80105bab <acquire>
    log.committing = 0;
80103e28:	c7 05 e0 3a 11 80 00 	movl   $0x0,0x80113ae0
80103e2f:	00 00 00 
    wakeup(&log);
80103e32:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e39:	e8 6a 19 00 00       	call   801057a8 <wakeup>
    release(&log.lock);
80103e3e:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103e45:	e8 c3 1d 00 00       	call   80105c0d <release>
  }
}
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e59:	e9 89 00 00 00       	jmp    80103ee7 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103e5e:	a1 d4 3a 11 80       	mov    0x80113ad4,%eax
80103e63:	03 45 f4             	add    -0xc(%ebp),%eax
80103e66:	83 c0 01             	add    $0x1,%eax
80103e69:	89 c2                	mov    %eax,%edx
80103e6b:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103e70:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e74:	89 04 24             	mov    %eax,(%esp)
80103e77:	e8 2a c3 ff ff       	call   801001a6 <bread>
80103e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e82:	83 c0 10             	add    $0x10,%eax
80103e85:	8b 04 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%eax
80103e8c:	89 c2                	mov    %eax,%edx
80103e8e:	a1 e4 3a 11 80       	mov    0x80113ae4,%eax
80103e93:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e97:	89 04 24             	mov    %eax,(%esp)
80103e9a:	e8 07 c3 ff ff       	call   801001a6 <bread>
80103e9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103ea2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ea5:	8d 50 18             	lea    0x18(%eax),%edx
80103ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eab:	83 c0 18             	add    $0x18,%eax
80103eae:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103eb5:	00 
80103eb6:	89 54 24 04          	mov    %edx,0x4(%esp)
80103eba:	89 04 24             	mov    %eax,(%esp)
80103ebd:	e8 0b 20 00 00       	call   80105ecd <memmove>
    bwrite(to);  // write the log
80103ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec5:	89 04 24             	mov    %eax,(%esp)
80103ec8:	e8 10 c3 ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed0:	89 04 24             	mov    %eax,(%esp)
80103ed3:	e8 3f c3 ff ff       	call   80100217 <brelse>
    brelse(to);
80103ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103edb:	89 04 24             	mov    %eax,(%esp)
80103ede:	e8 34 c3 ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103ee3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ee7:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103eec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103eef:	0f 8f 69 ff ff ff    	jg     80103e5e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103ef5:	c9                   	leave  
80103ef6:	c3                   	ret    

80103ef7 <commit>:

static void
commit()
{
80103ef7:	55                   	push   %ebp
80103ef8:	89 e5                	mov    %esp,%ebp
80103efa:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103efd:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103f02:	85 c0                	test   %eax,%eax
80103f04:	7e 1e                	jle    80103f24 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103f06:	e8 41 ff ff ff       	call   80103e4c <write_log>
    write_head();    // Write header to disk -- the real commit
80103f0b:	e8 75 fd ff ff       	call   80103c85 <write_head>
    install_trans(); // Now install writes to home locations
80103f10:	e8 56 fc ff ff       	call   80103b6b <install_trans>
    log.lh.n = 0; 
80103f15:	c7 05 e8 3a 11 80 00 	movl   $0x0,0x80113ae8
80103f1c:	00 00 00 
    write_head();    // Erase the transaction from the log
80103f1f:	e8 61 fd ff ff       	call   80103c85 <write_head>
  }
}
80103f24:	c9                   	leave  
80103f25:	c3                   	ret    

80103f26 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103f26:	55                   	push   %ebp
80103f27:	89 e5                	mov    %esp,%ebp
80103f29:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103f2c:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103f31:	83 f8 1d             	cmp    $0x1d,%eax
80103f34:	7f 12                	jg     80103f48 <log_write+0x22>
80103f36:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103f3b:	8b 15 d8 3a 11 80    	mov    0x80113ad8,%edx
80103f41:	83 ea 01             	sub    $0x1,%edx
80103f44:	39 d0                	cmp    %edx,%eax
80103f46:	7c 0c                	jl     80103f54 <log_write+0x2e>
    panic("too big a transaction");
80103f48:	c7 04 24 37 95 10 80 	movl   $0x80109537,(%esp)
80103f4f:	e8 e9 c5 ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103f54:	a1 dc 3a 11 80       	mov    0x80113adc,%eax
80103f59:	85 c0                	test   %eax,%eax
80103f5b:	7f 0c                	jg     80103f69 <log_write+0x43>
    panic("log_write outside of trans");
80103f5d:	c7 04 24 4d 95 10 80 	movl   $0x8010954d,(%esp)
80103f64:	e8 d4 c5 ff ff       	call   8010053d <panic>

  acquire(&log.lock);
80103f69:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103f70:	e8 36 1c 00 00       	call   80105bab <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103f75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f7c:	eb 1d                	jmp    80103f9b <log_write+0x75>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f81:	83 c0 10             	add    $0x10,%eax
80103f84:	8b 04 85 ac 3a 11 80 	mov    -0x7feec554(,%eax,4),%eax
80103f8b:	89 c2                	mov    %eax,%edx
80103f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f90:	8b 40 08             	mov    0x8(%eax),%eax
80103f93:	39 c2                	cmp    %eax,%edx
80103f95:	74 10                	je     80103fa7 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103f97:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f9b:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103fa0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103fa3:	7f d9                	jg     80103f7e <log_write+0x58>
80103fa5:	eb 01                	jmp    80103fa8 <log_write+0x82>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103fa7:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fab:	8b 40 08             	mov    0x8(%eax),%eax
80103fae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fb1:	83 c2 10             	add    $0x10,%edx
80103fb4:	89 04 95 ac 3a 11 80 	mov    %eax,-0x7feec554(,%edx,4)
  if (i == log.lh.n)
80103fbb:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103fc0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103fc3:	75 0d                	jne    80103fd2 <log_write+0xac>
    log.lh.n++;
80103fc5:	a1 e8 3a 11 80       	mov    0x80113ae8,%eax
80103fca:	83 c0 01             	add    $0x1,%eax
80103fcd:	a3 e8 3a 11 80       	mov    %eax,0x80113ae8
  b->flags |= B_DIRTY; // prevent eviction
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	8b 00                	mov    (%eax),%eax
80103fd7:	89 c2                	mov    %eax,%edx
80103fd9:	83 ca 04             	or     $0x4,%edx
80103fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdf:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103fe1:	c7 04 24 a0 3a 11 80 	movl   $0x80113aa0,(%esp)
80103fe8:	e8 20 1c 00 00       	call   80105c0d <release>
}
80103fed:	c9                   	leave  
80103fee:	c3                   	ret    
	...

80103ff0 <v2p>:
80103ff0:	55                   	push   %ebp
80103ff1:	89 e5                	mov    %esp,%ebp
80103ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff6:	05 00 00 00 80       	add    $0x80000000,%eax
80103ffb:	5d                   	pop    %ebp
80103ffc:	c3                   	ret    

80103ffd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103ffd:	55                   	push   %ebp
80103ffe:	89 e5                	mov    %esp,%ebp
80104000:	8b 45 08             	mov    0x8(%ebp),%eax
80104003:	05 00 00 00 80       	add    $0x80000000,%eax
80104008:	5d                   	pop    %ebp
80104009:	c3                   	ret    

8010400a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010400a:	55                   	push   %ebp
8010400b:	89 e5                	mov    %esp,%ebp
8010400d:	53                   	push   %ebx
8010400e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104011:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104014:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104017:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010401a:	89 c3                	mov    %eax,%ebx
8010401c:	89 d8                	mov    %ebx,%eax
8010401e:	f0 87 02             	lock xchg %eax,(%edx)
80104021:	89 c3                	mov    %eax,%ebx
80104023:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104026:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104029:	83 c4 10             	add    $0x10,%esp
8010402c:	5b                   	pop    %ebx
8010402d:	5d                   	pop    %ebp
8010402e:	c3                   	ret    

8010402f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010402f:	55                   	push   %ebp
80104030:	89 e5                	mov    %esp,%ebp
80104032:	83 e4 f0             	and    $0xfffffff0,%esp
80104035:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80104038:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010403f:	80 
80104040:	c7 04 24 7c 6e 11 80 	movl   $0x80116e7c,(%esp)
80104047:	e8 5d f2 ff ff       	call   801032a9 <kinit1>
  kvmalloc();      // kernel page table
8010404c:	e8 b5 4a 00 00       	call   80108b06 <kvmalloc>
  mpinit();        // collect info about this machine
80104051:	e8 4f 04 00 00       	call   801044a5 <mpinit>
  lapicinit();
80104056:	e8 d7 f5 ff ff       	call   80103632 <lapicinit>
  seginit();       // set up segments
8010405b:	e8 49 44 00 00       	call   801084a9 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80104060:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104066:	0f b6 00             	movzbl (%eax),%eax
80104069:	0f b6 c0             	movzbl %al,%eax
8010406c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104070:	c7 04 24 68 95 10 80 	movl   $0x80109568,(%esp)
80104077:	e8 25 c3 ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010407c:	e8 89 06 00 00       	call   8010470a <picinit>
  ioapicinit();    // another interrupt controller
80104081:	e8 13 f1 ff ff       	call   80103199 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104086:	e8 21 d2 ff ff       	call   801012ac <consoleinit>
  uartinit();      // serial port
8010408b:	e8 64 37 00 00       	call   801077f4 <uartinit>
  pinit();         // process table
80104090:	e8 8a 0b 00 00       	call   80104c1f <pinit>
  tvinit();        // trap vectors
80104095:	e8 a1 32 00 00       	call   8010733b <tvinit>
  binit();         // buffer cache
8010409a:	e8 95 bf ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010409f:	e8 98 d6 ff ff       	call   8010173c <fileinit>
  ideinit();       // disk
801040a4:	e8 21 ed ff ff       	call   80102dca <ideinit>
  if(!ismp)
801040a9:	a1 84 3b 11 80       	mov    0x80113b84,%eax
801040ae:	85 c0                	test   %eax,%eax
801040b0:	75 05                	jne    801040b7 <main+0x88>
    timerinit();   // uniprocessor timer
801040b2:	e8 c7 31 00 00       	call   8010727e <timerinit>
  startothers();   // start other processors
801040b7:	e8 7f 00 00 00       	call   8010413b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801040bc:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801040c3:	8e 
801040c4:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801040cb:	e8 11 f2 ff ff       	call   801032e1 <kinit2>
  userinit();      // first user process
801040d0:	e8 75 0c 00 00       	call   80104d4a <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801040d5:	e8 1a 00 00 00       	call   801040f4 <mpmain>

801040da <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801040da:	55                   	push   %ebp
801040db:	89 e5                	mov    %esp,%ebp
801040dd:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801040e0:	e8 38 4a 00 00       	call   80108b1d <switchkvm>
  seginit();
801040e5:	e8 bf 43 00 00       	call   801084a9 <seginit>
  lapicinit();
801040ea:	e8 43 f5 ff ff       	call   80103632 <lapicinit>
  mpmain();
801040ef:	e8 00 00 00 00       	call   801040f4 <mpmain>

801040f4 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801040f4:	55                   	push   %ebp
801040f5:	89 e5                	mov    %esp,%ebp
801040f7:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801040fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104100:	0f b6 00             	movzbl (%eax),%eax
80104103:	0f b6 c0             	movzbl %al,%eax
80104106:	89 44 24 04          	mov    %eax,0x4(%esp)
8010410a:	c7 04 24 7f 95 10 80 	movl   $0x8010957f,(%esp)
80104111:	e8 8b c2 ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80104116:	e8 94 33 00 00       	call   801074af <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010411b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104121:	05 a8 00 00 00       	add    $0xa8,%eax
80104126:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010412d:	00 
8010412e:	89 04 24             	mov    %eax,(%esp)
80104131:	e8 d4 fe ff ff       	call   8010400a <xchg>
  scheduler();     // start running processes
80104136:	e8 56 14 00 00       	call   80105591 <scheduler>

8010413b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010413b:	55                   	push   %ebp
8010413c:	89 e5                	mov    %esp,%ebp
8010413e:	53                   	push   %ebx
8010413f:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80104142:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80104149:	e8 af fe ff ff       	call   80103ffd <p2v>
8010414e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80104151:	b8 8a 00 00 00       	mov    $0x8a,%eax
80104156:	89 44 24 08          	mov    %eax,0x8(%esp)
8010415a:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80104161:	80 
80104162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104165:	89 04 24             	mov    %eax,(%esp)
80104168:	e8 60 1d 00 00       	call   80105ecd <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010416d:	c7 45 f4 a0 3b 11 80 	movl   $0x80113ba0,-0xc(%ebp)
80104174:	e9 86 00 00 00       	jmp    801041ff <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80104179:	e8 11 f6 ff ff       	call   8010378f <cpunum>
8010417e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104184:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
80104189:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010418c:	74 69                	je     801041f7 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010418e:	e8 44 f2 ff ff       	call   801033d7 <kalloc>
80104193:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104199:	83 e8 04             	sub    $0x4,%eax
8010419c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010419f:	81 c2 00 10 00 00    	add    $0x1000,%edx
801041a5:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801041a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041aa:	83 e8 08             	sub    $0x8,%eax
801041ad:	c7 00 da 40 10 80    	movl   $0x801040da,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801041b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041b6:	8d 58 f4             	lea    -0xc(%eax),%ebx
801041b9:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
801041c0:	e8 2b fe ff ff       	call   80103ff0 <v2p>
801041c5:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801041c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041ca:	89 04 24             	mov    %eax,(%esp)
801041cd:	e8 1e fe ff ff       	call   80103ff0 <v2p>
801041d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d5:	0f b6 12             	movzbl (%edx),%edx
801041d8:	0f b6 d2             	movzbl %dl,%edx
801041db:	89 44 24 04          	mov    %eax,0x4(%esp)
801041df:	89 14 24             	mov    %edx,(%esp)
801041e2:	e8 2e f6 ff ff       	call   80103815 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801041e7:	90                   	nop
801041e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041eb:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801041f1:	85 c0                	test   %eax,%eax
801041f3:	74 f3                	je     801041e8 <startothers+0xad>
801041f5:	eb 01                	jmp    801041f8 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801041f7:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801041f8:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801041ff:	a1 80 41 11 80       	mov    0x80114180,%eax
80104204:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010420a:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
8010420f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104212:	0f 87 61 ff ff ff    	ja     80104179 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80104218:	83 c4 24             	add    $0x24,%esp
8010421b:	5b                   	pop    %ebx
8010421c:	5d                   	pop    %ebp
8010421d:	c3                   	ret    
	...

80104220 <p2v>:
80104220:	55                   	push   %ebp
80104221:	89 e5                	mov    %esp,%ebp
80104223:	8b 45 08             	mov    0x8(%ebp),%eax
80104226:	05 00 00 00 80       	add    $0x80000000,%eax
8010422b:	5d                   	pop    %ebp
8010422c:	c3                   	ret    

8010422d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010422d:	55                   	push   %ebp
8010422e:	89 e5                	mov    %esp,%ebp
80104230:	53                   	push   %ebx
80104231:	83 ec 14             	sub    $0x14,%esp
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010423b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010423f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80104243:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80104247:	ec                   	in     (%dx),%al
80104248:	89 c3                	mov    %eax,%ebx
8010424a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010424d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80104251:	83 c4 14             	add    $0x14,%esp
80104254:	5b                   	pop    %ebx
80104255:	5d                   	pop    %ebp
80104256:	c3                   	ret    

80104257 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104257:	55                   	push   %ebp
80104258:	89 e5                	mov    %esp,%ebp
8010425a:	83 ec 08             	sub    $0x8,%esp
8010425d:	8b 55 08             	mov    0x8(%ebp),%edx
80104260:	8b 45 0c             	mov    0xc(%ebp),%eax
80104263:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104267:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010426a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010426e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104272:	ee                   	out    %al,(%dx)
}
80104273:	c9                   	leave  
80104274:	c3                   	ret    

80104275 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80104275:	55                   	push   %ebp
80104276:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104278:	a1 64 c6 10 80       	mov    0x8010c664,%eax
8010427d:	89 c2                	mov    %eax,%edx
8010427f:	b8 a0 3b 11 80       	mov    $0x80113ba0,%eax
80104284:	89 d1                	mov    %edx,%ecx
80104286:	29 c1                	sub    %eax,%ecx
80104288:	89 c8                	mov    %ecx,%eax
8010428a:	c1 f8 02             	sar    $0x2,%eax
8010428d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104293:	5d                   	pop    %ebp
80104294:	c3                   	ret    

80104295 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104295:	55                   	push   %ebp
80104296:	89 e5                	mov    %esp,%ebp
80104298:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010429b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801042a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801042a9:	eb 13                	jmp    801042be <sum+0x29>
    sum += addr[i];
801042ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801042ae:	03 45 08             	add    0x8(%ebp),%eax
801042b1:	0f b6 00             	movzbl (%eax),%eax
801042b4:	0f b6 c0             	movzbl %al,%eax
801042b7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801042ba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801042be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801042c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801042c4:	7c e5                	jl     801042ab <sum+0x16>
    sum += addr[i];
  return sum;
801042c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801042c9:	c9                   	leave  
801042ca:	c3                   	ret    

801042cb <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801042cb:	55                   	push   %ebp
801042cc:	89 e5                	mov    %esp,%ebp
801042ce:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801042d1:	8b 45 08             	mov    0x8(%ebp),%eax
801042d4:	89 04 24             	mov    %eax,(%esp)
801042d7:	e8 44 ff ff ff       	call   80104220 <p2v>
801042dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801042df:	8b 45 0c             	mov    0xc(%ebp),%eax
801042e2:	03 45 f0             	add    -0x10(%ebp),%eax
801042e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801042e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042ee:	eb 3f                	jmp    8010432f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801042f0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801042f7:	00 
801042f8:	c7 44 24 04 90 95 10 	movl   $0x80109590,0x4(%esp)
801042ff:	80 
80104300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104303:	89 04 24             	mov    %eax,(%esp)
80104306:	e8 66 1b 00 00       	call   80105e71 <memcmp>
8010430b:	85 c0                	test   %eax,%eax
8010430d:	75 1c                	jne    8010432b <mpsearch1+0x60>
8010430f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80104316:	00 
80104317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431a:	89 04 24             	mov    %eax,(%esp)
8010431d:	e8 73 ff ff ff       	call   80104295 <sum>
80104322:	84 c0                	test   %al,%al
80104324:	75 05                	jne    8010432b <mpsearch1+0x60>
      return (struct mp*)p;
80104326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104329:	eb 11                	jmp    8010433c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010432b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104335:	72 b9                	jb     801042f0 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80104337:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010433c:	c9                   	leave  
8010433d:	c3                   	ret    

8010433e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010433e:	55                   	push   %ebp
8010433f:	89 e5                	mov    %esp,%ebp
80104341:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80104344:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	83 c0 0f             	add    $0xf,%eax
80104351:	0f b6 00             	movzbl (%eax),%eax
80104354:	0f b6 c0             	movzbl %al,%eax
80104357:	89 c2                	mov    %eax,%edx
80104359:	c1 e2 08             	shl    $0x8,%edx
8010435c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435f:	83 c0 0e             	add    $0xe,%eax
80104362:	0f b6 00             	movzbl (%eax),%eax
80104365:	0f b6 c0             	movzbl %al,%eax
80104368:	09 d0                	or     %edx,%eax
8010436a:	c1 e0 04             	shl    $0x4,%eax
8010436d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104370:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104374:	74 21                	je     80104397 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80104376:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010437d:	00 
8010437e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104381:	89 04 24             	mov    %eax,(%esp)
80104384:	e8 42 ff ff ff       	call   801042cb <mpsearch1>
80104389:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010438c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104390:	74 50                	je     801043e2 <mpsearch+0xa4>
      return mp;
80104392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104395:	eb 5f                	jmp    801043f6 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439a:	83 c0 14             	add    $0x14,%eax
8010439d:	0f b6 00             	movzbl (%eax),%eax
801043a0:	0f b6 c0             	movzbl %al,%eax
801043a3:	89 c2                	mov    %eax,%edx
801043a5:	c1 e2 08             	shl    $0x8,%edx
801043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ab:	83 c0 13             	add    $0x13,%eax
801043ae:	0f b6 00             	movzbl (%eax),%eax
801043b1:	0f b6 c0             	movzbl %al,%eax
801043b4:	09 d0                	or     %edx,%eax
801043b6:	c1 e0 0a             	shl    $0xa,%eax
801043b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801043bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043bf:	2d 00 04 00 00       	sub    $0x400,%eax
801043c4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801043cb:	00 
801043cc:	89 04 24             	mov    %eax,(%esp)
801043cf:	e8 f7 fe ff ff       	call   801042cb <mpsearch1>
801043d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801043d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801043db:	74 05                	je     801043e2 <mpsearch+0xa4>
      return mp;
801043dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e0:	eb 14                	jmp    801043f6 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801043e2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801043e9:	00 
801043ea:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801043f1:	e8 d5 fe ff ff       	call   801042cb <mpsearch1>
}
801043f6:	c9                   	leave  
801043f7:	c3                   	ret    

801043f8 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801043f8:	55                   	push   %ebp
801043f9:	89 e5                	mov    %esp,%ebp
801043fb:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801043fe:	e8 3b ff ff ff       	call   8010433e <mpsearch>
80104403:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104406:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010440a:	74 0a                	je     80104416 <mpconfig+0x1e>
8010440c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440f:	8b 40 04             	mov    0x4(%eax),%eax
80104412:	85 c0                	test   %eax,%eax
80104414:	75 0a                	jne    80104420 <mpconfig+0x28>
    return 0;
80104416:	b8 00 00 00 00       	mov    $0x0,%eax
8010441b:	e9 83 00 00 00       	jmp    801044a3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104423:	8b 40 04             	mov    0x4(%eax),%eax
80104426:	89 04 24             	mov    %eax,(%esp)
80104429:	e8 f2 fd ff ff       	call   80104220 <p2v>
8010442e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80104431:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104438:	00 
80104439:	c7 44 24 04 95 95 10 	movl   $0x80109595,0x4(%esp)
80104440:	80 
80104441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104444:	89 04 24             	mov    %eax,(%esp)
80104447:	e8 25 1a 00 00       	call   80105e71 <memcmp>
8010444c:	85 c0                	test   %eax,%eax
8010444e:	74 07                	je     80104457 <mpconfig+0x5f>
    return 0;
80104450:	b8 00 00 00 00       	mov    $0x0,%eax
80104455:	eb 4c                	jmp    801044a3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80104457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010445a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010445e:	3c 01                	cmp    $0x1,%al
80104460:	74 12                	je     80104474 <mpconfig+0x7c>
80104462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104465:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104469:	3c 04                	cmp    $0x4,%al
8010446b:	74 07                	je     80104474 <mpconfig+0x7c>
    return 0;
8010446d:	b8 00 00 00 00       	mov    $0x0,%eax
80104472:	eb 2f                	jmp    801044a3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80104474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104477:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010447b:	0f b7 c0             	movzwl %ax,%eax
8010447e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104485:	89 04 24             	mov    %eax,(%esp)
80104488:	e8 08 fe ff ff       	call   80104295 <sum>
8010448d:	84 c0                	test   %al,%al
8010448f:	74 07                	je     80104498 <mpconfig+0xa0>
    return 0;
80104491:	b8 00 00 00 00       	mov    $0x0,%eax
80104496:	eb 0b                	jmp    801044a3 <mpconfig+0xab>
  *pmp = mp;
80104498:	8b 45 08             	mov    0x8(%ebp),%eax
8010449b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449e:	89 10                	mov    %edx,(%eax)
  return conf;
801044a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044a3:	c9                   	leave  
801044a4:	c3                   	ret    

801044a5 <mpinit>:

void
mpinit(void)
{
801044a5:	55                   	push   %ebp
801044a6:	89 e5                	mov    %esp,%ebp
801044a8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801044ab:	c7 05 64 c6 10 80 a0 	movl   $0x80113ba0,0x8010c664
801044b2:	3b 11 80 
  if((conf = mpconfig(&mp)) == 0)
801044b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044b8:	89 04 24             	mov    %eax,(%esp)
801044bb:	e8 38 ff ff ff       	call   801043f8 <mpconfig>
801044c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801044c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044c7:	0f 84 9c 01 00 00    	je     80104669 <mpinit+0x1c4>
    return;
  ismp = 1;
801044cd:	c7 05 84 3b 11 80 01 	movl   $0x1,0x80113b84
801044d4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801044d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044da:	8b 40 24             	mov    0x24(%eax),%eax
801044dd:	a3 9c 3a 11 80       	mov    %eax,0x80113a9c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801044e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e5:	83 c0 2c             	add    $0x2c,%eax
801044e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ee:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801044f2:	0f b7 c0             	movzwl %ax,%eax
801044f5:	03 45 f0             	add    -0x10(%ebp),%eax
801044f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044fb:	e9 f4 00 00 00       	jmp    801045f4 <mpinit+0x14f>
    switch(*p){
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	0f b6 00             	movzbl (%eax),%eax
80104506:	0f b6 c0             	movzbl %al,%eax
80104509:	83 f8 04             	cmp    $0x4,%eax
8010450c:	0f 87 bf 00 00 00    	ja     801045d1 <mpinit+0x12c>
80104512:	8b 04 85 d8 95 10 80 	mov    -0x7fef6a28(,%eax,4),%eax
80104519:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104521:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104524:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104528:	0f b6 d0             	movzbl %al,%edx
8010452b:	a1 80 41 11 80       	mov    0x80114180,%eax
80104530:	39 c2                	cmp    %eax,%edx
80104532:	74 2d                	je     80104561 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104534:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104537:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010453b:	0f b6 d0             	movzbl %al,%edx
8010453e:	a1 80 41 11 80       	mov    0x80114180,%eax
80104543:	89 54 24 08          	mov    %edx,0x8(%esp)
80104547:	89 44 24 04          	mov    %eax,0x4(%esp)
8010454b:	c7 04 24 9a 95 10 80 	movl   $0x8010959a,(%esp)
80104552:	e8 4a be ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80104557:	c7 05 84 3b 11 80 00 	movl   $0x0,0x80113b84
8010455e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104561:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104564:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104568:	0f b6 c0             	movzbl %al,%eax
8010456b:	83 e0 02             	and    $0x2,%eax
8010456e:	85 c0                	test   %eax,%eax
80104570:	74 15                	je     80104587 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80104572:	a1 80 41 11 80       	mov    0x80114180,%eax
80104577:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010457d:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
80104582:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80104587:	8b 15 80 41 11 80    	mov    0x80114180,%edx
8010458d:	a1 80 41 11 80       	mov    0x80114180,%eax
80104592:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80104598:	81 c2 a0 3b 11 80    	add    $0x80113ba0,%edx
8010459e:	88 02                	mov    %al,(%edx)
      ncpu++;
801045a0:	a1 80 41 11 80       	mov    0x80114180,%eax
801045a5:	83 c0 01             	add    $0x1,%eax
801045a8:	a3 80 41 11 80       	mov    %eax,0x80114180
      p += sizeof(struct mpproc);
801045ad:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801045b1:	eb 41                	jmp    801045f4 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801045b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801045bc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801045c0:	a2 80 3b 11 80       	mov    %al,0x80113b80
      p += sizeof(struct mpioapic);
801045c5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801045c9:	eb 29                	jmp    801045f4 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801045cb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801045cf:	eb 23                	jmp    801045f4 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d4:	0f b6 00             	movzbl (%eax),%eax
801045d7:	0f b6 c0             	movzbl %al,%eax
801045da:	89 44 24 04          	mov    %eax,0x4(%esp)
801045de:	c7 04 24 b8 95 10 80 	movl   $0x801095b8,(%esp)
801045e5:	e8 b7 bd ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801045ea:	c7 05 84 3b 11 80 00 	movl   $0x0,0x80113b84
801045f1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801045f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801045fa:	0f 82 00 ff ff ff    	jb     80104500 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104600:	a1 84 3b 11 80       	mov    0x80113b84,%eax
80104605:	85 c0                	test   %eax,%eax
80104607:	75 1d                	jne    80104626 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104609:	c7 05 80 41 11 80 01 	movl   $0x1,0x80114180
80104610:	00 00 00 
    lapic = 0;
80104613:	c7 05 9c 3a 11 80 00 	movl   $0x0,0x80113a9c
8010461a:	00 00 00 
    ioapicid = 0;
8010461d:	c6 05 80 3b 11 80 00 	movb   $0x0,0x80113b80
    return;
80104624:	eb 44                	jmp    8010466a <mpinit+0x1c5>
  }

  if(mp->imcrp){
80104626:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104629:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010462d:	84 c0                	test   %al,%al
8010462f:	74 39                	je     8010466a <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104631:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104638:	00 
80104639:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104640:	e8 12 fc ff ff       	call   80104257 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104645:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010464c:	e8 dc fb ff ff       	call   8010422d <inb>
80104651:	83 c8 01             	or     $0x1,%eax
80104654:	0f b6 c0             	movzbl %al,%eax
80104657:	89 44 24 04          	mov    %eax,0x4(%esp)
8010465b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104662:	e8 f0 fb ff ff       	call   80104257 <outb>
80104667:	eb 01                	jmp    8010466a <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104669:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010466a:	c9                   	leave  
8010466b:	c3                   	ret    

8010466c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010466c:	55                   	push   %ebp
8010466d:	89 e5                	mov    %esp,%ebp
8010466f:	83 ec 08             	sub    $0x8,%esp
80104672:	8b 55 08             	mov    0x8(%ebp),%edx
80104675:	8b 45 0c             	mov    0xc(%ebp),%eax
80104678:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010467c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010467f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104683:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104687:	ee                   	out    %al,(%dx)
}
80104688:	c9                   	leave  
80104689:	c3                   	ret    

8010468a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
8010468a:	55                   	push   %ebp
8010468b:	89 e5                	mov    %esp,%ebp
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	8b 45 08             	mov    0x8(%ebp),%eax
80104693:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104697:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010469b:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
801046a1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801046a5:	0f b6 c0             	movzbl %al,%eax
801046a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801046ac:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801046b3:	e8 b4 ff ff ff       	call   8010466c <outb>
  outb(IO_PIC2+1, mask >> 8);
801046b8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801046bc:	66 c1 e8 08          	shr    $0x8,%ax
801046c0:	0f b6 c0             	movzbl %al,%eax
801046c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801046c7:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801046ce:	e8 99 ff ff ff       	call   8010466c <outb>
}
801046d3:	c9                   	leave  
801046d4:	c3                   	ret    

801046d5 <picenable>:

void
picenable(int irq)
{
801046d5:	55                   	push   %ebp
801046d6:	89 e5                	mov    %esp,%ebp
801046d8:	53                   	push   %ebx
801046d9:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
801046dc:	8b 45 08             	mov    0x8(%ebp),%eax
801046df:	ba 01 00 00 00       	mov    $0x1,%edx
801046e4:	89 d3                	mov    %edx,%ebx
801046e6:	89 c1                	mov    %eax,%ecx
801046e8:	d3 e3                	shl    %cl,%ebx
801046ea:	89 d8                	mov    %ebx,%eax
801046ec:	89 c2                	mov    %eax,%edx
801046ee:	f7 d2                	not    %edx
801046f0:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801046f7:	21 d0                	and    %edx,%eax
801046f9:	0f b7 c0             	movzwl %ax,%eax
801046fc:	89 04 24             	mov    %eax,(%esp)
801046ff:	e8 86 ff ff ff       	call   8010468a <picsetmask>
}
80104704:	83 c4 04             	add    $0x4,%esp
80104707:	5b                   	pop    %ebx
80104708:	5d                   	pop    %ebp
80104709:	c3                   	ret    

8010470a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010470a:	55                   	push   %ebp
8010470b:	89 e5                	mov    %esp,%ebp
8010470d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104710:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104717:	00 
80104718:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010471f:	e8 48 ff ff ff       	call   8010466c <outb>
  outb(IO_PIC2+1, 0xFF);
80104724:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
8010472b:	00 
8010472c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104733:	e8 34 ff ff ff       	call   8010466c <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104738:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010473f:	00 
80104740:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104747:	e8 20 ff ff ff       	call   8010466c <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010474c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80104753:	00 
80104754:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010475b:	e8 0c ff ff ff       	call   8010466c <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104760:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104767:	00 
80104768:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010476f:	e8 f8 fe ff ff       	call   8010466c <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104774:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010477b:	00 
8010477c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104783:	e8 e4 fe ff ff       	call   8010466c <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104788:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010478f:	00 
80104790:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104797:	e8 d0 fe ff ff       	call   8010466c <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010479c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
801047a3:	00 
801047a4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801047ab:	e8 bc fe ff ff       	call   8010466c <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801047b0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801047b7:	00 
801047b8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801047bf:	e8 a8 fe ff ff       	call   8010466c <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801047c4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801047cb:	00 
801047cc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801047d3:	e8 94 fe ff ff       	call   8010466c <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801047d8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801047df:	00 
801047e0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801047e7:	e8 80 fe ff ff       	call   8010466c <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
801047ec:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801047f3:	00 
801047f4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801047fb:	e8 6c fe ff ff       	call   8010466c <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104800:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104807:	00 
80104808:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010480f:	e8 58 fe ff ff       	call   8010466c <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104814:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010481b:	00 
8010481c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104823:	e8 44 fe ff ff       	call   8010466c <outb>

  if(irqmask != 0xFFFF)
80104828:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010482f:	66 83 f8 ff          	cmp    $0xffff,%ax
80104833:	74 12                	je     80104847 <picinit+0x13d>
    picsetmask(irqmask);
80104835:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010483c:	0f b7 c0             	movzwl %ax,%eax
8010483f:	89 04 24             	mov    %eax,(%esp)
80104842:	e8 43 fe ff ff       	call   8010468a <picsetmask>
}
80104847:	c9                   	leave  
80104848:	c3                   	ret    
80104849:	00 00                	add    %al,(%eax)
	...

8010484c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010484c:	55                   	push   %ebp
8010484d:	89 e5                	mov    %esp,%ebp
8010484f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104859:	8b 45 0c             	mov    0xc(%ebp),%eax
8010485c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104862:	8b 45 0c             	mov    0xc(%ebp),%eax
80104865:	8b 10                	mov    (%eax),%edx
80104867:	8b 45 08             	mov    0x8(%ebp),%eax
8010486a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010486c:	e8 e7 ce ff ff       	call   80101758 <filealloc>
80104871:	8b 55 08             	mov    0x8(%ebp),%edx
80104874:	89 02                	mov    %eax,(%edx)
80104876:	8b 45 08             	mov    0x8(%ebp),%eax
80104879:	8b 00                	mov    (%eax),%eax
8010487b:	85 c0                	test   %eax,%eax
8010487d:	0f 84 c8 00 00 00    	je     8010494b <pipealloc+0xff>
80104883:	e8 d0 ce ff ff       	call   80101758 <filealloc>
80104888:	8b 55 0c             	mov    0xc(%ebp),%edx
8010488b:	89 02                	mov    %eax,(%edx)
8010488d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104890:	8b 00                	mov    (%eax),%eax
80104892:	85 c0                	test   %eax,%eax
80104894:	0f 84 b1 00 00 00    	je     8010494b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010489a:	e8 38 eb ff ff       	call   801033d7 <kalloc>
8010489f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048a6:	0f 84 9e 00 00 00    	je     8010494a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
801048ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048af:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801048b6:	00 00 00 
  p->writeopen = 1;
801048b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bc:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801048c3:	00 00 00 
  p->nwrite = 0;
801048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801048d0:	00 00 00 
  p->nread = 0;
801048d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801048dd:	00 00 00 
  initlock(&p->lock, "pipe");
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	c7 44 24 04 ec 95 10 	movl   $0x801095ec,0x4(%esp)
801048ea:	80 
801048eb:	89 04 24             	mov    %eax,(%esp)
801048ee:	e8 97 12 00 00       	call   80105b8a <initlock>
  (*f0)->type = FD_PIPE;
801048f3:	8b 45 08             	mov    0x8(%ebp),%eax
801048f6:	8b 00                	mov    (%eax),%eax
801048f8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801048fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104901:	8b 00                	mov    (%eax),%eax
80104903:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104907:	8b 45 08             	mov    0x8(%ebp),%eax
8010490a:	8b 00                	mov    (%eax),%eax
8010490c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104910:	8b 45 08             	mov    0x8(%ebp),%eax
80104913:	8b 00                	mov    (%eax),%eax
80104915:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104918:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010491b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010491e:	8b 00                	mov    (%eax),%eax
80104920:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104926:	8b 45 0c             	mov    0xc(%ebp),%eax
80104929:	8b 00                	mov    (%eax),%eax
8010492b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010492f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104932:	8b 00                	mov    (%eax),%eax
80104934:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104938:	8b 45 0c             	mov    0xc(%ebp),%eax
8010493b:	8b 00                	mov    (%eax),%eax
8010493d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104940:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104943:	b8 00 00 00 00       	mov    $0x0,%eax
80104948:	eb 43                	jmp    8010498d <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010494a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010494b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010494f:	74 0b                	je     8010495c <pipealloc+0x110>
    kfree((char*)p);
80104951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104954:	89 04 24             	mov    %eax,(%esp)
80104957:	e8 e2 e9 ff ff       	call   8010333e <kfree>
  if(*f0)
8010495c:	8b 45 08             	mov    0x8(%ebp),%eax
8010495f:	8b 00                	mov    (%eax),%eax
80104961:	85 c0                	test   %eax,%eax
80104963:	74 0d                	je     80104972 <pipealloc+0x126>
    fileclose(*f0);
80104965:	8b 45 08             	mov    0x8(%ebp),%eax
80104968:	8b 00                	mov    (%eax),%eax
8010496a:	89 04 24             	mov    %eax,(%esp)
8010496d:	e8 8e ce ff ff       	call   80101800 <fileclose>
  if(*f1)
80104972:	8b 45 0c             	mov    0xc(%ebp),%eax
80104975:	8b 00                	mov    (%eax),%eax
80104977:	85 c0                	test   %eax,%eax
80104979:	74 0d                	je     80104988 <pipealloc+0x13c>
    fileclose(*f1);
8010497b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010497e:	8b 00                	mov    (%eax),%eax
80104980:	89 04 24             	mov    %eax,(%esp)
80104983:	e8 78 ce ff ff       	call   80101800 <fileclose>
  return -1;
80104988:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010498d:	c9                   	leave  
8010498e:	c3                   	ret    

8010498f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010498f:	55                   	push   %ebp
80104990:	89 e5                	mov    %esp,%ebp
80104992:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104995:	8b 45 08             	mov    0x8(%ebp),%eax
80104998:	89 04 24             	mov    %eax,(%esp)
8010499b:	e8 0b 12 00 00       	call   80105bab <acquire>
  if(writable){
801049a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049a4:	74 1f                	je     801049c5 <pipeclose+0x36>
    p->writeopen = 0;
801049a6:	8b 45 08             	mov    0x8(%ebp),%eax
801049a9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801049b0:	00 00 00 
    wakeup(&p->nread);
801049b3:	8b 45 08             	mov    0x8(%ebp),%eax
801049b6:	05 34 02 00 00       	add    $0x234,%eax
801049bb:	89 04 24             	mov    %eax,(%esp)
801049be:	e8 e5 0d 00 00       	call   801057a8 <wakeup>
801049c3:	eb 1d                	jmp    801049e2 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801049c5:	8b 45 08             	mov    0x8(%ebp),%eax
801049c8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801049cf:	00 00 00 
    wakeup(&p->nwrite);
801049d2:	8b 45 08             	mov    0x8(%ebp),%eax
801049d5:	05 38 02 00 00       	add    $0x238,%eax
801049da:	89 04 24             	mov    %eax,(%esp)
801049dd:	e8 c6 0d 00 00       	call   801057a8 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801049e2:	8b 45 08             	mov    0x8(%ebp),%eax
801049e5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801049eb:	85 c0                	test   %eax,%eax
801049ed:	75 25                	jne    80104a14 <pipeclose+0x85>
801049ef:	8b 45 08             	mov    0x8(%ebp),%eax
801049f2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801049f8:	85 c0                	test   %eax,%eax
801049fa:	75 18                	jne    80104a14 <pipeclose+0x85>
    release(&p->lock);
801049fc:	8b 45 08             	mov    0x8(%ebp),%eax
801049ff:	89 04 24             	mov    %eax,(%esp)
80104a02:	e8 06 12 00 00       	call   80105c0d <release>
    kfree((char*)p);
80104a07:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0a:	89 04 24             	mov    %eax,(%esp)
80104a0d:	e8 2c e9 ff ff       	call   8010333e <kfree>
80104a12:	eb 0b                	jmp    80104a1f <pipeclose+0x90>
  } else
    release(&p->lock);
80104a14:	8b 45 08             	mov    0x8(%ebp),%eax
80104a17:	89 04 24             	mov    %eax,(%esp)
80104a1a:	e8 ee 11 00 00       	call   80105c0d <release>
}
80104a1f:	c9                   	leave  
80104a20:	c3                   	ret    

80104a21 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104a21:	55                   	push   %ebp
80104a22:	89 e5                	mov    %esp,%ebp
80104a24:	53                   	push   %ebx
80104a25:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104a28:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2b:	89 04 24             	mov    %eax,(%esp)
80104a2e:	e8 78 11 00 00       	call   80105bab <acquire>
  for(i = 0; i < n; i++){
80104a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a3a:	e9 a6 00 00 00       	jmp    80104ae5 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a42:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104a48:	85 c0                	test   %eax,%eax
80104a4a:	74 0d                	je     80104a59 <pipewrite+0x38>
80104a4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a52:	8b 40 24             	mov    0x24(%eax),%eax
80104a55:	85 c0                	test   %eax,%eax
80104a57:	74 15                	je     80104a6e <pipewrite+0x4d>
        release(&p->lock);
80104a59:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5c:	89 04 24             	mov    %eax,(%esp)
80104a5f:	e8 a9 11 00 00       	call   80105c0d <release>
        return -1;
80104a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a69:	e9 9d 00 00 00       	jmp    80104b0b <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a71:	05 34 02 00 00       	add    $0x234,%eax
80104a76:	89 04 24             	mov    %eax,(%esp)
80104a79:	e8 2a 0d 00 00       	call   801057a8 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a81:	8b 55 08             	mov    0x8(%ebp),%edx
80104a84:	81 c2 38 02 00 00    	add    $0x238,%edx
80104a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a8e:	89 14 24             	mov    %edx,(%esp)
80104a91:	e8 29 0c 00 00       	call   801056bf <sleep>
80104a96:	eb 01                	jmp    80104a99 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104a98:	90                   	nop
80104a99:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104aab:	05 00 02 00 00       	add    $0x200,%eax
80104ab0:	39 c2                	cmp    %eax,%edx
80104ab2:	74 8b                	je     80104a3f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104abd:	89 c3                	mov    %eax,%ebx
80104abf:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ac8:	03 55 0c             	add    0xc(%ebp),%edx
80104acb:	0f b6 0a             	movzbl (%edx),%ecx
80104ace:	8b 55 08             	mov    0x8(%ebp),%edx
80104ad1:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104ad5:	8d 50 01             	lea    0x1(%eax),%edx
80104ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80104adb:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104ae1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae8:	3b 45 10             	cmp    0x10(%ebp),%eax
80104aeb:	7c ab                	jl     80104a98 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104aed:	8b 45 08             	mov    0x8(%ebp),%eax
80104af0:	05 34 02 00 00       	add    $0x234,%eax
80104af5:	89 04 24             	mov    %eax,(%esp)
80104af8:	e8 ab 0c 00 00       	call   801057a8 <wakeup>
  release(&p->lock);
80104afd:	8b 45 08             	mov    0x8(%ebp),%eax
80104b00:	89 04 24             	mov    %eax,(%esp)
80104b03:	e8 05 11 00 00       	call   80105c0d <release>
  return n;
80104b08:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104b0b:	83 c4 24             	add    $0x24,%esp
80104b0e:	5b                   	pop    %ebx
80104b0f:	5d                   	pop    %ebp
80104b10:	c3                   	ret    

80104b11 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104b11:	55                   	push   %ebp
80104b12:	89 e5                	mov    %esp,%ebp
80104b14:	53                   	push   %ebx
80104b15:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104b18:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1b:	89 04 24             	mov    %eax,(%esp)
80104b1e:	e8 88 10 00 00       	call   80105bab <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104b23:	eb 3a                	jmp    80104b5f <piperead+0x4e>
    if(proc->killed){
80104b25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2b:	8b 40 24             	mov    0x24(%eax),%eax
80104b2e:	85 c0                	test   %eax,%eax
80104b30:	74 15                	je     80104b47 <piperead+0x36>
      release(&p->lock);
80104b32:	8b 45 08             	mov    0x8(%ebp),%eax
80104b35:	89 04 24             	mov    %eax,(%esp)
80104b38:	e8 d0 10 00 00       	call   80105c0d <release>
      return -1;
80104b3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b42:	e9 b6 00 00 00       	jmp    80104bfd <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104b47:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4a:	8b 55 08             	mov    0x8(%ebp),%edx
80104b4d:	81 c2 34 02 00 00    	add    $0x234,%edx
80104b53:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b57:	89 14 24             	mov    %edx,(%esp)
80104b5a:	e8 60 0b 00 00       	call   801056bf <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b62:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104b68:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104b71:	39 c2                	cmp    %eax,%edx
80104b73:	75 0d                	jne    80104b82 <piperead+0x71>
80104b75:	8b 45 08             	mov    0x8(%ebp),%eax
80104b78:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104b7e:	85 c0                	test   %eax,%eax
80104b80:	75 a3                	jne    80104b25 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104b82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b89:	eb 49                	jmp    80104bd4 <piperead+0xc3>
    if(p->nread == p->nwrite)
80104b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104b94:	8b 45 08             	mov    0x8(%ebp),%eax
80104b97:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104b9d:	39 c2                	cmp    %eax,%edx
80104b9f:	74 3d                	je     80104bde <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba4:	89 c2                	mov    %eax,%edx
80104ba6:	03 55 0c             	add    0xc(%ebp),%edx
80104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bac:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104bb2:	89 c3                	mov    %eax,%ebx
80104bb4:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104bba:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bbd:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104bc2:	88 0a                	mov    %cl,(%edx)
80104bc4:	8d 50 01             	lea    0x1(%eax),%edx
80104bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bca:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104bd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd7:	3b 45 10             	cmp    0x10(%ebp),%eax
80104bda:	7c af                	jl     80104b8b <piperead+0x7a>
80104bdc:	eb 01                	jmp    80104bdf <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104bde:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104be2:	05 38 02 00 00       	add    $0x238,%eax
80104be7:	89 04 24             	mov    %eax,(%esp)
80104bea:	e8 b9 0b 00 00       	call   801057a8 <wakeup>
  release(&p->lock);
80104bef:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf2:	89 04 24             	mov    %eax,(%esp)
80104bf5:	e8 13 10 00 00       	call   80105c0d <release>
  return i;
80104bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bfd:	83 c4 24             	add    $0x24,%esp
80104c00:	5b                   	pop    %ebx
80104c01:	5d                   	pop    %ebp
80104c02:	c3                   	ret    
	...

80104c04 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104c04:	55                   	push   %ebp
80104c05:	89 e5                	mov    %esp,%ebp
80104c07:	53                   	push   %ebx
80104c08:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c0b:	9c                   	pushf  
80104c0c:	5b                   	pop    %ebx
80104c0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104c10:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104c13:	83 c4 10             	add    $0x10,%esp
80104c16:	5b                   	pop    %ebx
80104c17:	5d                   	pop    %ebp
80104c18:	c3                   	ret    

80104c19 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104c19:	55                   	push   %ebp
80104c1a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104c1c:	fb                   	sti    
}
80104c1d:	5d                   	pop    %ebp
80104c1e:	c3                   	ret    

80104c1f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104c1f:	55                   	push   %ebp
80104c20:	89 e5                	mov    %esp,%ebp
80104c22:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104c25:	c7 44 24 04 f1 95 10 	movl   $0x801095f1,0x4(%esp)
80104c2c:	80 
80104c2d:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104c34:	e8 51 0f 00 00       	call   80105b8a <initlock>
}
80104c39:	c9                   	leave  
80104c3a:	c3                   	ret    

80104c3b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104c3b:	55                   	push   %ebp
80104c3c:	89 e5                	mov    %esp,%ebp
80104c3e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104c41:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104c48:	e8 5e 0f 00 00       	call   80105bab <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c4d:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
80104c54:	eb 11                	jmp    80104c67 <allocproc+0x2c>
    if(p->state == UNUSED)
80104c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c59:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5c:	85 c0                	test   %eax,%eax
80104c5e:	74 26                	je     80104c86 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c60:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104c67:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
80104c6e:	72 e6                	jb     80104c56 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104c70:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104c77:	e8 91 0f 00 00       	call   80105c0d <release>
  return 0;
80104c7c:	b8 00 00 00 00       	mov    $0x0,%eax
80104c81:	e9 c2 00 00 00       	jmp    80104d48 <allocproc+0x10d>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104c86:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104c91:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c99:	89 42 10             	mov    %eax,0x10(%edx)
80104c9c:	83 c0 01             	add    $0x1,%eax
80104c9f:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  p->priority=DEF_PRIORITY;
80104ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca7:	c7 80 8c 00 00 00 02 	movl   $0x2,0x8c(%eax)
80104cae:	00 00 00 
  release(&ptable.lock);
80104cb1:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80104cb8:	e8 50 0f 00 00       	call   80105c0d <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104cbd:	e8 15 e7 ff ff       	call   801033d7 <kalloc>
80104cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc5:	89 42 08             	mov    %eax,0x8(%edx)
80104cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccb:	8b 40 08             	mov    0x8(%eax),%eax
80104cce:	85 c0                	test   %eax,%eax
80104cd0:	75 11                	jne    80104ce3 <allocproc+0xa8>
    p->state = UNUSED;
80104cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104cdc:	b8 00 00 00 00       	mov    $0x0,%eax
80104ce1:	eb 65                	jmp    80104d48 <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
80104ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce6:	8b 40 08             	mov    0x8(%eax),%eax
80104ce9:	05 00 10 00 00       	add    $0x1000,%eax
80104cee:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104cf1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cfb:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104cfe:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104d02:	ba f0 72 10 80       	mov    $0x801072f0,%edx
80104d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d0a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104d0c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d16:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d1f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104d26:	00 
80104d27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104d2e:	00 
80104d2f:	89 04 24             	mov    %eax,(%esp)
80104d32:	e8 c3 10 00 00       	call   80105dfa <memset>
  p->context->eip = (uint)forkret;
80104d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d3d:	ba 80 56 10 80       	mov    $0x80105680,%edx
80104d42:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d48:	c9                   	leave  
80104d49:	c3                   	ret    

80104d4a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104d4a:	55                   	push   %ebp
80104d4b:	89 e5                	mov    %esp,%ebp
80104d4d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104d50:	e8 e6 fe ff ff       	call   80104c3b <allocproc>
80104d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5b:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
80104d60:	e8 e4 3c 00 00       	call   80108a49 <setupkvm>
80104d65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d68:	89 42 04             	mov    %eax,0x4(%edx)
80104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6e:	8b 40 04             	mov    0x4(%eax),%eax
80104d71:	85 c0                	test   %eax,%eax
80104d73:	75 0c                	jne    80104d81 <userinit+0x37>
    panic("userinit: out of memory?");
80104d75:	c7 04 24 f8 95 10 80 	movl   $0x801095f8,(%esp)
80104d7c:	e8 bc b7 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104d81:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d89:	8b 40 04             	mov    0x4(%eax),%eax
80104d8c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d90:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
80104d97:	80 
80104d98:	89 04 24             	mov    %eax,(%esp)
80104d9b:	e8 01 3f 00 00       	call   80108ca1 <inituvm>
  p->sz = PGSIZE;
80104da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dac:	8b 40 18             	mov    0x18(%eax),%eax
80104daf:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104db6:	00 
80104db7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104dbe:	00 
80104dbf:	89 04 24             	mov    %eax,(%esp)
80104dc2:	e8 33 10 00 00       	call   80105dfa <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	8b 40 18             	mov    0x18(%eax),%eax
80104dcd:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd6:	8b 40 18             	mov    0x18(%eax),%eax
80104dd9:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de2:	8b 40 18             	mov    0x18(%eax),%eax
80104de5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104de8:	8b 52 18             	mov    0x18(%edx),%edx
80104deb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104def:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df6:	8b 40 18             	mov    0x18(%eax),%eax
80104df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dfc:	8b 52 18             	mov    0x18(%edx),%edx
80104dff:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e03:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0a:	8b 40 18             	mov    0x18(%eax),%eax
80104e0d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e17:	8b 40 18             	mov    0x18(%eax),%eax
80104e1a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e24:	8b 40 18             	mov    0x18(%eax),%eax
80104e27:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e31:	83 c0 6c             	add    $0x6c,%eax
80104e34:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104e3b:	00 
80104e3c:	c7 44 24 04 11 96 10 	movl   $0x80109611,0x4(%esp)
80104e43:	80 
80104e44:	89 04 24             	mov    %eax,(%esp)
80104e47:	e8 de 11 00 00       	call   8010602a <safestrcpy>
  p->cwd = namei("/");
80104e4c:	c7 04 24 1a 96 10 80 	movl   $0x8010961a,(%esp)
80104e53:	e8 55 de ff ff       	call   80102cad <namei>
80104e58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e5b:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e61:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104e68:	c9                   	leave  
80104e69:	c3                   	ret    

80104e6a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104e6a:	55                   	push   %ebp
80104e6b:	89 e5                	mov    %esp,%ebp
80104e6d:	83 ec 28             	sub    $0x28,%esp
  uint sz;

  sz = proc->sz;
80104e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e76:	8b 00                	mov    (%eax),%eax
80104e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104e7b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104e7f:	7e 34                	jle    80104eb5 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104e81:	8b 45 08             	mov    0x8(%ebp),%eax
80104e84:	89 c2                	mov    %eax,%edx
80104e86:	03 55 f4             	add    -0xc(%ebp),%edx
80104e89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e8f:	8b 40 04             	mov    0x4(%eax),%eax
80104e92:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e99:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e9d:	89 04 24             	mov    %eax,(%esp)
80104ea0:	e8 76 3f 00 00       	call   80108e1b <allocuvm>
80104ea5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ea8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104eac:	75 41                	jne    80104eef <growproc+0x85>
      return -1;
80104eae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb3:	eb 58                	jmp    80104f0d <growproc+0xa3>
  } else if(n < 0){
80104eb5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104eb9:	79 34                	jns    80104eef <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebe:	89 c2                	mov    %eax,%edx
80104ec0:	03 55 f4             	add    -0xc(%ebp),%edx
80104ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ec9:	8b 40 04             	mov    0x4(%eax),%eax
80104ecc:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ed0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ed3:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ed7:	89 04 24             	mov    %eax,(%esp)
80104eda:	e8 16 40 00 00       	call   80108ef5 <deallocuvm>
80104edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ee2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ee6:	75 07                	jne    80104eef <growproc+0x85>
      return -1;
80104ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eed:	eb 1e                	jmp    80104f0d <growproc+0xa3>
  }
  proc->sz = sz;
80104eef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ef8:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104efa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f00:	89 04 24             	mov    %eax,(%esp)
80104f03:	e8 32 3c 00 00       	call   80108b3a <switchuvm>
  return 0;
80104f08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f0d:	c9                   	leave  
80104f0e:	c3                   	ret    

80104f0f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104f0f:	55                   	push   %ebp
80104f10:	89 e5                	mov    %esp,%ebp
80104f12:	57                   	push   %edi
80104f13:	56                   	push   %esi
80104f14:	53                   	push   %ebx
80104f15:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f18:	e8 1e fd ff ff       	call   80104c3b <allocproc>
80104f1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104f20:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104f24:	75 0a                	jne    80104f30 <fork+0x21>
    return -1;
80104f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f2b:	e9 8e 01 00 00       	jmp    801050be <fork+0x1af>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f36:	8b 10                	mov    (%eax),%edx
80104f38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f3e:	8b 40 04             	mov    0x4(%eax),%eax
80104f41:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f45:	89 04 24             	mov    %eax,(%esp)
80104f48:	e8 38 41 00 00       	call   80109085 <copyuvm>
80104f4d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104f50:	89 42 04             	mov    %eax,0x4(%edx)
80104f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f56:	8b 40 04             	mov    0x4(%eax),%eax
80104f59:	85 c0                	test   %eax,%eax
80104f5b:	75 2c                	jne    80104f89 <fork+0x7a>
    kfree(np->kstack);
80104f5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f60:	8b 40 08             	mov    0x8(%eax),%eax
80104f63:	89 04 24             	mov    %eax,(%esp)
80104f66:	e8 d3 e3 ff ff       	call   8010333e <kfree>
    np->kstack = 0;
80104f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f6e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104f75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f78:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f84:	e9 35 01 00 00       	jmp    801050be <fork+0x1af>
  }
  np->sz = proc->sz;
80104f89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f8f:	8b 10                	mov    (%eax),%edx
80104f91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f94:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104f96:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa0:	89 50 14             	mov    %edx,0x14(%eax)
  np->retime=0;
80104fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa6:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104fad:	00 00 00 
  np->rutime=0;
80104fb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fb3:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104fba:	00 00 00 
  np->stime=0;
80104fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fc0:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104fc7:	00 00 00 
  np->priority=proc->priority;
80104fca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd0:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104fd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
  *np->tf = *proc->tf;
80104fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fe2:	8b 50 18             	mov    0x18(%eax),%edx
80104fe5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104feb:	8b 40 18             	mov    0x18(%eax),%eax
80104fee:	89 c3                	mov    %eax,%ebx
80104ff0:	b8 13 00 00 00       	mov    $0x13,%eax
80104ff5:	89 d7                	mov    %edx,%edi
80104ff7:	89 de                	mov    %ebx,%esi
80104ff9:	89 c1                	mov    %eax,%ecx
80104ffb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105000:	8b 40 18             	mov    0x18(%eax),%eax
80105003:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010500a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105011:	eb 3d                	jmp    80105050 <fork+0x141>
    if(proc->ofile[i])
80105013:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105019:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010501c:	83 c2 08             	add    $0x8,%edx
8010501f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105023:	85 c0                	test   %eax,%eax
80105025:	74 25                	je     8010504c <fork+0x13d>
      np->ofile[i] = filedup(proc->ofile[i]);
80105027:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010502d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105030:	83 c2 08             	add    $0x8,%edx
80105033:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105037:	89 04 24             	mov    %eax,(%esp)
8010503a:	e8 79 c7 ff ff       	call   801017b8 <filedup>
8010503f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105042:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105045:	83 c1 08             	add    $0x8,%ecx
80105048:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010504c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105050:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105054:	7e bd                	jle    80105013 <fork+0x104>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105056:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505c:	8b 40 68             	mov    0x68(%eax),%eax
8010505f:	89 04 24             	mov    %eax,(%esp)
80105062:	e8 6c d0 ff ff       	call   801020d3 <idup>
80105067:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010506a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010506d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105073:	8d 50 6c             	lea    0x6c(%eax),%edx
80105076:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105079:	83 c0 6c             	add    $0x6c,%eax
8010507c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105083:	00 
80105084:	89 54 24 04          	mov    %edx,0x4(%esp)
80105088:	89 04 24             	mov    %eax,(%esp)
8010508b:	e8 9a 0f 00 00       	call   8010602a <safestrcpy>

  pid = np->pid;
80105090:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105093:	8b 40 10             	mov    0x10(%eax),%eax
80105096:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80105099:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801050a0:	e8 06 0b 00 00       	call   80105bab <acquire>
  np->state = RUNNABLE;
801050a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801050af:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801050b6:	e8 52 0b 00 00       	call   80105c0d <release>

  return pid;
801050bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801050be:	83 c4 2c             	add    $0x2c,%esp
801050c1:	5b                   	pop    %ebx
801050c2:	5e                   	pop    %esi
801050c3:	5f                   	pop    %edi
801050c4:	5d                   	pop    %ebp
801050c5:	c3                   	ret    

801050c6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801050c6:	55                   	push   %ebp
801050c7:	89 e5                	mov    %esp,%ebp
801050c9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801050cc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050d3:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801050d8:	39 c2                	cmp    %eax,%edx
801050da:	75 0c                	jne    801050e8 <exit+0x22>
    panic("init exiting");
801050dc:	c7 04 24 1c 96 10 80 	movl   $0x8010961c,(%esp)
801050e3:	e8 55 b4 ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801050ef:	eb 44                	jmp    80105135 <exit+0x6f>
    if(proc->ofile[fd]){
801050f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050fa:	83 c2 08             	add    $0x8,%edx
801050fd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105101:	85 c0                	test   %eax,%eax
80105103:	74 2c                	je     80105131 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80105105:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010510b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010510e:	83 c2 08             	add    $0x8,%edx
80105111:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105115:	89 04 24             	mov    %eax,(%esp)
80105118:	e8 e3 c6 ff ff       	call   80101800 <fileclose>
      proc->ofile[fd] = 0;
8010511d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105123:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105126:	83 c2 08             	add    $0x8,%edx
80105129:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105130:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105131:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105135:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105139:	7e b6                	jle    801050f1 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010513b:	e8 e1 eb ff ff       	call   80103d21 <begin_op>
  iput(proc->cwd);
80105140:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105146:	8b 40 68             	mov    0x68(%eax),%eax
80105149:	89 04 24             	mov    %eax,(%esp)
8010514c:	e8 6d d1 ff ff       	call   801022be <iput>
  end_op();
80105151:	e8 4c ec ff ff       	call   80103da2 <end_op>
  proc->cwd = 0;
80105156:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105163:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010516a:	e8 3c 0a 00 00       	call   80105bab <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010516f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105175:	8b 40 14             	mov    0x14(%eax),%eax
80105178:	89 04 24             	mov    %eax,(%esp)
8010517b:	e8 da 05 00 00       	call   8010575a <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105180:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
80105187:	eb 3b                	jmp    801051c4 <exit+0xfe>
    if(p->parent == proc){
80105189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518c:	8b 50 14             	mov    0x14(%eax),%edx
8010518f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105195:	39 c2                	cmp    %eax,%edx
80105197:	75 24                	jne    801051bd <exit+0xf7>
      p->parent = initproc;
80105199:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
8010519f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801051a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a8:	8b 40 0c             	mov    0xc(%eax),%eax
801051ab:	83 f8 05             	cmp    $0x5,%eax
801051ae:	75 0d                	jne    801051bd <exit+0xf7>
        wakeup1(initproc);
801051b0:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801051b5:	89 04 24             	mov    %eax,(%esp)
801051b8:	e8 9d 05 00 00       	call   8010575a <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051bd:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801051c4:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801051cb:	72 bc                	jb     80105189 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801051cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801051da:	e8 bd 03 00 00       	call   8010559c <sched>
  panic("zombie exit");
801051df:	c7 04 24 29 96 10 80 	movl   $0x80109629,(%esp)
801051e6:	e8 52 b3 ff ff       	call   8010053d <panic>

801051eb <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801051eb:	55                   	push   %ebp
801051ec:	89 e5                	mov    %esp,%ebp
801051ee:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801051f1:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801051f8:	e8 ae 09 00 00       	call   80105bab <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801051fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105204:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
8010520b:	e9 9d 00 00 00       	jmp    801052ad <wait+0xc2>
      if(p->parent != proc)
80105210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105213:	8b 50 14             	mov    0x14(%eax),%edx
80105216:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010521c:	39 c2                	cmp    %eax,%edx
8010521e:	0f 85 81 00 00 00    	jne    801052a5 <wait+0xba>
        continue;
      havekids = 1;
80105224:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010522b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010522e:	8b 40 0c             	mov    0xc(%eax),%eax
80105231:	83 f8 05             	cmp    $0x5,%eax
80105234:	75 70                	jne    801052a6 <wait+0xbb>
        // Found one.
        pid = p->pid;
80105236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105239:	8b 40 10             	mov    0x10(%eax),%eax
8010523c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010523f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105242:	8b 40 08             	mov    0x8(%eax),%eax
80105245:	89 04 24             	mov    %eax,(%esp)
80105248:	e8 f1 e0 ff ff       	call   8010333e <kfree>
        p->kstack = 0;
8010524d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105250:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525a:	8b 40 04             	mov    0x4(%eax),%eax
8010525d:	89 04 24             	mov    %eax,(%esp)
80105260:	e8 4c 3d 00 00       	call   80108fb1 <freevm>
        p->state = UNUSED;
80105265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105268:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010526f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105272:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105286:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010528a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105294:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010529b:	e8 6d 09 00 00       	call   80105c0d <release>
        return pid;
801052a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052a3:	eb 56                	jmp    801052fb <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801052a5:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052a6:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801052ad:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801052b4:	0f 82 56 ff ff ff    	jb     80105210 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801052ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052be:	74 0d                	je     801052cd <wait+0xe2>
801052c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c6:	8b 40 24             	mov    0x24(%eax),%eax
801052c9:	85 c0                	test   %eax,%eax
801052cb:	74 13                	je     801052e0 <wait+0xf5>
      release(&ptable.lock);
801052cd:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801052d4:	e8 34 09 00 00       	call   80105c0d <release>
      return -1;
801052d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052de:	eb 1b                	jmp    801052fb <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801052e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052e6:	c7 44 24 04 a0 41 11 	movl   $0x801141a0,0x4(%esp)
801052ed:	80 
801052ee:	89 04 24             	mov    %eax,(%esp)
801052f1:	e8 c9 03 00 00       	call   801056bf <sleep>
  }
801052f6:	e9 02 ff ff ff       	jmp    801051fd <wait+0x12>
}
801052fb:	c9                   	leave  
801052fc:	c3                   	ret    

801052fd <scheduler_def>:
//  - eventually that process transfers control
//      via swtch back to the scheduler.


void
scheduler_def(void) {
801052fd:	55                   	push   %ebp
801052fe:	89 e5                	mov    %esp,%ebp
80105300:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105303:	e8 11 f9 ff ff       	call   80104c19 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105308:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010530f:	e8 97 08 00 00       	call   80105bab <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105314:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
8010531b:	eb 62                	jmp    8010537f <scheduler_def+0x82>
      if(p->state != RUNNABLE)
8010531d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105320:	8b 40 0c             	mov    0xc(%eax),%eax
80105323:	83 f8 03             	cmp    $0x3,%eax
80105326:	75 4f                	jne    80105377 <scheduler_def+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105334:	89 04 24             	mov    %eax,(%esp)
80105337:	e8 fe 37 00 00       	call   80108b3a <switchuvm>
      p->state = RUNNING;
8010533c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105346:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010534c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010534f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105356:	83 c2 04             	add    $0x4,%edx
80105359:	89 44 24 04          	mov    %eax,0x4(%esp)
8010535d:	89 14 24             	mov    %edx,(%esp)
80105360:	e8 3b 0d 00 00       	call   801060a0 <swtch>
      switchkvm();
80105365:	e8 b3 37 00 00       	call   80108b1d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010536a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105371:	00 00 00 00 
80105375:	eb 01                	jmp    80105378 <scheduler_def+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105377:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105378:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010537f:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
80105386:	72 95                	jb     8010531d <scheduler_def+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105388:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010538f:	e8 79 08 00 00       	call   80105c0d <release>

  }
80105394:	e9 6a ff ff ff       	jmp    80105303 <scheduler_def+0x6>

80105399 <scheduler_fcfs>:
}


void
scheduler_fcfs(void) {
80105399:	55                   	push   %ebp
8010539a:	89 e5                	mov    %esp,%ebp
8010539c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p,*chosenProc;
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010539f:	e8 75 f8 ff ff       	call   80104c19 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801053a4:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801053ab:	e8 fb 07 00 00       	call   80105bab <acquire>
    chosenProc=0;
801053b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    //Set chosenProc to the runnable proc with the minimum creation time.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053b7:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801053be:	eb 2e                	jmp    801053ee <scheduler_fcfs+0x55>
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime < chosenProc->ctime)))
801053c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c3:	8b 40 0c             	mov    0xc(%eax),%eax
801053c6:	83 f8 03             	cmp    $0x3,%eax
801053c9:	75 1c                	jne    801053e7 <scheduler_fcfs+0x4e>
801053cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053cf:	74 10                	je     801053e1 <scheduler_fcfs+0x48>
801053d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d4:	8b 50 7c             	mov    0x7c(%eax),%edx
801053d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053da:	8b 40 7c             	mov    0x7c(%eax),%eax
801053dd:	39 c2                	cmp    %eax,%edx
801053df:	73 06                	jae    801053e7 <scheduler_fcfs+0x4e>
        chosenProc=p;
801053e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    chosenProc=0;

    //Set chosenProc to the runnable proc with the minimum creation time.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053e7:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801053ee:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
801053f5:	72 c9                	jb     801053c0 <scheduler_fcfs+0x27>
      if(p->state == RUNNABLE && (!chosenProc || (p->ctime < chosenProc->ctime)))
        chosenProc=p;
    }

    if (!chosenProc) {
801053f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053fb:	75 0f                	jne    8010540c <scheduler_fcfs+0x73>
     release(&ptable.lock);
801053fd:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105404:	e8 04 08 00 00       	call   80105c0d <release>
     continue;
80105409:	90                   	nop

    // Process is done running for now.
    // It should have changed its p->state before coming back.
    proc = 0;
    release(&ptable.lock);
  }
8010540a:	eb 93                	jmp    8010539f <scheduler_fcfs+0x6>
   }

    // Switch to chosen process.  It is the process's job
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    proc=chosenProc;
8010540c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540f:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4

    //run process untill its no longer need cpu time
    while(proc->state==RUNNABLE) {
80105415:	eb 39                	jmp    80105450 <scheduler_fcfs+0xb7>
      switchuvm(chosenProc);
80105417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541a:	89 04 24             	mov    %eax,(%esp)
8010541d:	e8 18 37 00 00       	call   80108b3a <switchuvm>
      chosenProc->state = RUNNING;
80105422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105425:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
8010542c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105432:	8b 40 1c             	mov    0x1c(%eax),%eax
80105435:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010543c:	83 c2 04             	add    $0x4,%edx
8010543f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105443:	89 14 24             	mov    %edx,(%esp)
80105446:	e8 55 0c 00 00       	call   801060a0 <swtch>
      switchkvm();
8010544b:	e8 cd 36 00 00       	call   80108b1d <switchkvm>
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    proc=chosenProc;

    //run process untill its no longer need cpu time
    while(proc->state==RUNNABLE) {
80105450:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105456:	8b 40 0c             	mov    0xc(%eax),%eax
80105459:	83 f8 03             	cmp    $0x3,%eax
8010545c:	74 b9                	je     80105417 <scheduler_fcfs+0x7e>
      switchkvm();
   }

    // Process is done running for now.
    // It should have changed its p->state before coming back.
    proc = 0;
8010545e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105465:	00 00 00 00 
    release(&ptable.lock);
80105469:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105470:	e8 98 07 00 00       	call   80105c0d <release>
  }
80105475:	e9 25 ff ff ff       	jmp    8010539f <scheduler_fcfs+0x6>

8010547a <scheduler_sml>:
}

void
scheduler_sml(void) {
8010547a:	55                   	push   %ebp
8010547b:	89 e5                	mov    %esp,%ebp
8010547d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p,*chosenProc=0;
80105480:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  uint priority;
  int beenInside=0;
80105487:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010548e:	e8 86 f7 ff ff       	call   80104c19 <sti>
    acquire(&ptable.lock);
80105493:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010549a:	e8 0c 07 00 00       	call   80105bab <acquire>
    //we start at MAX_PRIORITY, if we didnt find a process then we decrease the priority. if we found one, we resets it to max priority.
    if (beenInside && !chosenProc && priority>MIN_PRIORITY)
8010549f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801054a3:	74 12                	je     801054b7 <scheduler_sml+0x3d>
801054a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054a9:	75 0c                	jne    801054b7 <scheduler_sml+0x3d>
801054ab:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
801054af:	76 06                	jbe    801054b7 <scheduler_sml+0x3d>
        priority--;
801054b1:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801054b5:	eb 07                	jmp    801054be <scheduler_sml+0x44>
    else
      priority=MAX_PRIORITY;
801054b7:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)

    chosenProc=0;
801054be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    beenInside=1;
801054c5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    // Loop over process table looking for process to run.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054cc:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801054d3:	e9 90 00 00 00       	jmp    80105568 <scheduler_sml+0xee>
      if((p->state != RUNNABLE) || (p->priority!=priority))
801054d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054db:	8b 40 0c             	mov    0xc(%eax),%eax
801054de:	83 f8 03             	cmp    $0x3,%eax
801054e1:	75 7d                	jne    80105560 <scheduler_sml+0xe6>
801054e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e6:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801054ec:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801054ef:	75 6f                	jne    80105560 <scheduler_sml+0xe6>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      chosenProc=p;
801054f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      proc = p;
801054f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054fa:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105503:	89 04 24             	mov    %eax,(%esp)
80105506:	e8 2f 36 00 00       	call   80108b3a <switchuvm>
      p->state = RUNNING;
8010550b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105515:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010551b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010551e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105525:	83 c2 04             	add    $0x4,%edx
80105528:	89 44 24 04          	mov    %eax,0x4(%esp)
8010552c:	89 14 24             	mov    %edx,(%esp)
8010552f:	e8 6c 0b 00 00       	call   801060a0 <swtch>
      switchkvm();
80105534:	e8 e4 35 00 00       	call   80108b1d <switchkvm>
      //  If a system call to change priority has been made, we need to relate this.
      if (p->priority>priority)
80105539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553c:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105542:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105545:	76 0c                	jbe    80105553 <scheduler_sml+0xd9>
        priority=p->priority;
80105547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105550:	89 45 ec             	mov    %eax,-0x14(%ebp)

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105553:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010555a:	00 00 00 00 
8010555e:	eb 01                	jmp    80105561 <scheduler_sml+0xe7>
    chosenProc=0;
    beenInside=1;
    // Loop over process table looking for process to run.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if((p->state != RUNNABLE) || (p->priority!=priority))
        continue;
80105560:	90                   	nop
      priority=MAX_PRIORITY;

    chosenProc=0;
    beenInside=1;
    // Loop over process table looking for process to run.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105561:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105568:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
8010556f:	0f 82 63 ff ff ff    	jb     801054d8 <scheduler_sml+0x5e>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105575:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010557c:	e8 8c 06 00 00       	call   80105c0d <release>

  }
80105581:	e9 08 ff ff ff       	jmp    8010548e <scheduler_sml+0x14>

80105586 <scheduler_dml>:
}


void
scheduler_dml(void) {
80105586:	55                   	push   %ebp
80105587:	89 e5                	mov    %esp,%ebp
80105589:	83 ec 08             	sub    $0x8,%esp
  scheduler_sml();
8010558c:	e8 e9 fe ff ff       	call   8010547a <scheduler_sml>

80105591 <scheduler>:
}

void
scheduler(void)
{
80105591:	55                   	push   %ebp
80105592:	89 e5                	mov    %esp,%ebp
80105594:	83 ec 08             	sub    $0x8,%esp
#elif SCHEDFLAG == FCFS
  scheduler_fcfs();
#elif SCHEDFLAG == SML
  scheduler_sml();
#elif SCHEDFLAG == DML
  scheduler_dml();
80105597:	e8 ea ff ff ff       	call   80105586 <scheduler_dml>

8010559c <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010559c:	55                   	push   %ebp
8010559d:	89 e5                	mov    %esp,%ebp
8010559f:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
801055a2:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801055a9:	e8 1b 07 00 00       	call   80105cc9 <holding>
801055ae:	85 c0                	test   %eax,%eax
801055b0:	75 0c                	jne    801055be <sched+0x22>
    panic("sched ptable.lock");
801055b2:	c7 04 24 35 96 10 80 	movl   $0x80109635,(%esp)
801055b9:	e8 7f af ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
801055be:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055c4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055ca:	83 f8 01             	cmp    $0x1,%eax
801055cd:	74 0c                	je     801055db <sched+0x3f>
    panic("sched locks");
801055cf:	c7 04 24 47 96 10 80 	movl   $0x80109647,(%esp)
801055d6:	e8 62 af ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
801055db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e1:	8b 40 0c             	mov    0xc(%eax),%eax
801055e4:	83 f8 04             	cmp    $0x4,%eax
801055e7:	75 0c                	jne    801055f5 <sched+0x59>
    panic("sched running");
801055e9:	c7 04 24 53 96 10 80 	movl   $0x80109653,(%esp)
801055f0:	e8 48 af ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
801055f5:	e8 0a f6 ff ff       	call   80104c04 <readeflags>
801055fa:	25 00 02 00 00       	and    $0x200,%eax
801055ff:	85 c0                	test   %eax,%eax
80105601:	74 0c                	je     8010560f <sched+0x73>
    panic("sched interruptible");
80105603:	c7 04 24 61 96 10 80 	movl   $0x80109661,(%esp)
8010560a:	e8 2e af ff ff       	call   8010053d <panic>
  intena = cpu->intena;
8010560f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105615:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010561b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010561e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105624:	8b 40 04             	mov    0x4(%eax),%eax
80105627:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010562e:	83 c2 1c             	add    $0x1c,%edx
80105631:	89 44 24 04          	mov    %eax,0x4(%esp)
80105635:	89 14 24             	mov    %edx,(%esp)
80105638:	e8 63 0a 00 00       	call   801060a0 <swtch>
  cpu->intena = intena;
8010563d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105643:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105646:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010564c:	c9                   	leave  
8010564d:	c3                   	ret    

8010564e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010564e:	55                   	push   %ebp
8010564f:	89 e5                	mov    %esp,%ebp
80105651:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105654:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010565b:	e8 4b 05 00 00       	call   80105bab <acquire>
  proc->state = RUNNABLE;
80105660:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105666:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010566d:	e8 2a ff ff ff       	call   8010559c <sched>
  release(&ptable.lock);
80105672:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105679:	e8 8f 05 00 00       	call   80105c0d <release>
}
8010567e:	c9                   	leave  
8010567f:	c3                   	ret    

80105680 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
80105683:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105686:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010568d:	e8 7b 05 00 00       	call   80105c0d <release>

  if (first) {
80105692:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80105697:	85 c0                	test   %eax,%eax
80105699:	74 22                	je     801056bd <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010569b:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801056a2:	00 00 00 
    iinit(ROOTDEV);
801056a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056ac:	e8 2b c7 ff ff       	call   80101ddc <iinit>
    initlog(ROOTDEV);
801056b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056b8:	e8 63 e4 ff ff       	call   80103b20 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801056bd:	c9                   	leave  
801056be:	c3                   	ret    

801056bf <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801056bf:	55                   	push   %ebp
801056c0:	89 e5                	mov    %esp,%ebp
801056c2:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801056c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056cb:	85 c0                	test   %eax,%eax
801056cd:	75 0c                	jne    801056db <sleep+0x1c>
    panic("sleep");
801056cf:	c7 04 24 75 96 10 80 	movl   $0x80109675,(%esp)
801056d6:	e8 62 ae ff ff       	call   8010053d <panic>

  if(lk == 0)
801056db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801056df:	75 0c                	jne    801056ed <sleep+0x2e>
    panic("sleep without lk");
801056e1:	c7 04 24 7b 96 10 80 	movl   $0x8010967b,(%esp)
801056e8:	e8 50 ae ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801056ed:	81 7d 0c a0 41 11 80 	cmpl   $0x801141a0,0xc(%ebp)
801056f4:	74 17                	je     8010570d <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801056f6:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801056fd:	e8 a9 04 00 00       	call   80105bab <acquire>
    release(lk);
80105702:	8b 45 0c             	mov    0xc(%ebp),%eax
80105705:	89 04 24             	mov    %eax,(%esp)
80105708:	e8 00 05 00 00       	call   80105c0d <release>
  }

  // Go to sleep.
  proc->chan = chan;
8010570d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105713:	8b 55 08             	mov    0x8(%ebp),%edx
80105716:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105719:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010571f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105726:	e8 71 fe ff ff       	call   8010559c <sched>

  // Tidy up.
  proc->chan = 0;
8010572b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105731:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105738:	81 7d 0c a0 41 11 80 	cmpl   $0x801141a0,0xc(%ebp)
8010573f:	74 17                	je     80105758 <sleep+0x99>
    release(&ptable.lock);
80105741:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105748:	e8 c0 04 00 00       	call   80105c0d <release>
    acquire(lk);
8010574d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105750:	89 04 24             	mov    %eax,(%esp)
80105753:	e8 53 04 00 00       	call   80105bab <acquire>
  }
}
80105758:	c9                   	leave  
80105759:	c3                   	ret    

8010575a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010575a:	55                   	push   %ebp
8010575b:	89 e5                	mov    %esp,%ebp
8010575d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105760:	c7 45 fc d4 41 11 80 	movl   $0x801141d4,-0x4(%ebp)
80105767:	eb 34                	jmp    8010579d <wakeup1+0x43>
    if(p->state == SLEEPING && p->chan == chan){
80105769:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010576c:	8b 40 0c             	mov    0xc(%eax),%eax
8010576f:	83 f8 02             	cmp    $0x2,%eax
80105772:	75 22                	jne    80105796 <wakeup1+0x3c>
80105774:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105777:	8b 40 20             	mov    0x20(%eax),%eax
8010577a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010577d:	75 17                	jne    80105796 <wakeup1+0x3c>
      #if SCHEDFLAG == DML
      p->priority=MAX_PRIORITY;
8010577f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105782:	c7 80 8c 00 00 00 03 	movl   $0x3,0x8c(%eax)
80105789:	00 00 00 
      #endif
      p->state = RUNNABLE;
8010578c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010578f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105796:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
8010579d:	81 7d fc d4 65 11 80 	cmpl   $0x801165d4,-0x4(%ebp)
801057a4:	72 c3                	jb     80105769 <wakeup1+0xf>
      p->priority=MAX_PRIORITY;
      #endif
      p->state = RUNNABLE;
    }

}
801057a6:	c9                   	leave  
801057a7:	c3                   	ret    

801057a8 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801057a8:	55                   	push   %ebp
801057a9:	89 e5                	mov    %esp,%ebp
801057ab:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801057ae:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801057b5:	e8 f1 03 00 00       	call   80105bab <acquire>
  wakeup1(chan);
801057ba:	8b 45 08             	mov    0x8(%ebp),%eax
801057bd:	89 04 24             	mov    %eax,(%esp)
801057c0:	e8 95 ff ff ff       	call   8010575a <wakeup1>
  release(&ptable.lock);
801057c5:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801057cc:	e8 3c 04 00 00       	call   80105c0d <release>
}
801057d1:	c9                   	leave  
801057d2:	c3                   	ret    

801057d3 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801057d3:	55                   	push   %ebp
801057d4:	89 e5                	mov    %esp,%ebp
801057d6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801057d9:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801057e0:	e8 c6 03 00 00       	call   80105bab <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057e5:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801057ec:	eb 44                	jmp    80105832 <kill+0x5f>
    if(p->pid == pid){
801057ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f1:	8b 40 10             	mov    0x10(%eax),%eax
801057f4:	3b 45 08             	cmp    0x8(%ebp),%eax
801057f7:	75 32                	jne    8010582b <kill+0x58>
      p->killed = 1;
801057f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105806:	8b 40 0c             	mov    0xc(%eax),%eax
80105809:	83 f8 02             	cmp    $0x2,%eax
8010580c:	75 0a                	jne    80105818 <kill+0x45>
        p->state = RUNNABLE;
8010580e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105811:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105818:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
8010581f:	e8 e9 03 00 00       	call   80105c0d <release>
      return 0;
80105824:	b8 00 00 00 00       	mov    $0x0,%eax
80105829:	eb 21                	jmp    8010584c <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010582b:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105832:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
80105839:	72 b3                	jb     801057ee <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010583b:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105842:	e8 c6 03 00 00       	call   80105c0d <release>
  return -1;
80105847:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010584c:	c9                   	leave  
8010584d:	c3                   	ret    

8010584e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010584e:	55                   	push   %ebp
8010584f:	89 e5                	mov    %esp,%ebp
80105851:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105854:	c7 45 f0 d4 41 11 80 	movl   $0x801141d4,-0x10(%ebp)
8010585b:	e9 db 00 00 00       	jmp    8010593b <procdump+0xed>
    if(p->state == UNUSED)
80105860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105863:	8b 40 0c             	mov    0xc(%eax),%eax
80105866:	85 c0                	test   %eax,%eax
80105868:	0f 84 c5 00 00 00    	je     80105933 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010586e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105871:	8b 40 0c             	mov    0xc(%eax),%eax
80105874:	83 f8 05             	cmp    $0x5,%eax
80105877:	77 23                	ja     8010589c <procdump+0x4e>
80105879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587c:	8b 40 0c             	mov    0xc(%eax),%eax
8010587f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105886:	85 c0                	test   %eax,%eax
80105888:	74 12                	je     8010589c <procdump+0x4e>
      state = states[p->state];
8010588a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588d:	8b 40 0c             	mov    0xc(%eax),%eax
80105890:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105897:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010589a:	eb 07                	jmp    801058a3 <procdump+0x55>
    else
      state = "???";
8010589c:	c7 45 ec 8c 96 10 80 	movl   $0x8010968c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a6:	8d 50 6c             	lea    0x6c(%eax),%edx
801058a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ac:	8b 40 10             	mov    0x10(%eax),%eax
801058af:	89 54 24 0c          	mov    %edx,0xc(%esp)
801058b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058b6:	89 54 24 08          	mov    %edx,0x8(%esp)
801058ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801058be:	c7 04 24 90 96 10 80 	movl   $0x80109690,(%esp)
801058c5:	e8 d7 aa ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
801058ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058cd:	8b 40 0c             	mov    0xc(%eax),%eax
801058d0:	83 f8 02             	cmp    $0x2,%eax
801058d3:	75 50                	jne    80105925 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801058d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d8:	8b 40 1c             	mov    0x1c(%eax),%eax
801058db:	8b 40 0c             	mov    0xc(%eax),%eax
801058de:	83 c0 08             	add    $0x8,%eax
801058e1:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801058e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801058e8:	89 04 24             	mov    %eax,(%esp)
801058eb:	e8 6c 03 00 00       	call   80105c5c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801058f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058f7:	eb 1b                	jmp    80105914 <procdump+0xc6>
        cprintf(" %p", pc[i]);
801058f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105900:	89 44 24 04          	mov    %eax,0x4(%esp)
80105904:	c7 04 24 99 96 10 80 	movl   $0x80109699,(%esp)
8010590b:	e8 91 aa ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105910:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105914:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105918:	7f 0b                	jg     80105925 <procdump+0xd7>
8010591a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105921:	85 c0                	test   %eax,%eax
80105923:	75 d4                	jne    801058f9 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105925:	c7 04 24 9d 96 10 80 	movl   $0x8010969d,(%esp)
8010592c:	e8 70 aa ff ff       	call   801003a1 <cprintf>
80105931:	eb 01                	jmp    80105934 <procdump+0xe6>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105933:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105934:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
8010593b:	81 7d f0 d4 65 11 80 	cmpl   $0x801165d4,-0x10(%ebp)
80105942:	0f 82 18 ff ff ff    	jb     80105860 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105948:	c9                   	leave  
80105949:	c3                   	ret    

8010594a <updateTimes>:


void
updateTimes()
{
8010594a:	55                   	push   %ebp
8010594b:	89 e5                	mov    %esp,%ebp
8010594d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105950:	c7 45 fc d4 41 11 80 	movl   $0x801141d4,-0x4(%ebp)
80105957:	eb 67                	jmp    801059c0 <updateTimes+0x76>
    if(p->state == RUNNABLE)
80105959:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010595c:	8b 40 0c             	mov    0xc(%eax),%eax
8010595f:	83 f8 03             	cmp    $0x3,%eax
80105962:	75 15                	jne    80105979 <updateTimes+0x2f>
      p->retime++;
80105964:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105967:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010596d:	8d 50 01             	lea    0x1(%eax),%edx
80105970:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105973:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    if(p->state == RUNNING)
80105979:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010597c:	8b 40 0c             	mov    0xc(%eax),%eax
8010597f:	83 f8 04             	cmp    $0x4,%eax
80105982:	75 15                	jne    80105999 <updateTimes+0x4f>
      p->rutime++;
80105984:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105987:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010598d:	8d 50 01             	lea    0x1(%eax),%edx
80105990:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105993:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    if(p->state == SLEEPING)
80105999:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010599c:	8b 40 0c             	mov    0xc(%eax),%eax
8010599f:	83 f8 02             	cmp    $0x2,%eax
801059a2:	75 15                	jne    801059b9 <updateTimes+0x6f>
      p->stime++;
801059a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059a7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801059ad:	8d 50 01             	lea    0x1(%eax),%edx
801059b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059b3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

void
updateTimes()
{
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059b9:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
801059c0:	81 7d fc d4 65 11 80 	cmpl   $0x801165d4,-0x4(%ebp)
801059c7:	72 90                	jb     80105959 <updateTimes+0xf>
    if(p->state == RUNNING)
      p->rutime++;
    if(p->state == SLEEPING)
      p->stime++;
    }
}
801059c9:	c9                   	leave  
801059ca:	c3                   	ret    

801059cb <wait2>:

int
wait2(int *retime, int *rutime, int* stime) {
801059cb:	55                   	push   %ebp
801059cc:	89 e5                	mov    %esp,%ebp
801059ce:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801059d1:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
801059d8:	e8 ce 01 00 00       	call   80105bab <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801059dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059e4:	c7 45 f4 d4 41 11 80 	movl   $0x801141d4,-0xc(%ebp)
801059eb:	e9 f8 00 00 00       	jmp    80105ae8 <wait2+0x11d>
      if(p->parent != proc)
801059f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f3:	8b 50 14             	mov    0x14(%eax),%edx
801059f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059fc:	39 c2                	cmp    %eax,%edx
801059fe:	0f 85 dc 00 00 00    	jne    80105ae0 <wait2+0x115>
        continue;
      havekids = 1;
80105a04:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0e:	8b 40 0c             	mov    0xc(%eax),%eax
80105a11:	83 f8 05             	cmp    $0x5,%eax
80105a14:	0f 85 c7 00 00 00    	jne    80105ae1 <wait2+0x116>
        // Found one.
        *retime=p->retime;
80105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1d:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105a23:	89 c2                	mov    %eax,%edx
80105a25:	8b 45 08             	mov    0x8(%ebp),%eax
80105a28:	89 10                	mov    %edx,(%eax)
        *rutime=p->rutime;
80105a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2d:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105a33:	89 c2                	mov    %eax,%edx
80105a35:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a38:	89 10                	mov    %edx,(%eax)
        *stime=p->stime;
80105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105a43:	89 c2                	mov    %eax,%edx
80105a45:	8b 45 10             	mov    0x10(%ebp),%eax
80105a48:	89 10                	mov    %edx,(%eax)
        p->retime=0;
80105a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4d:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80105a54:	00 00 00 
        p->rutime=0;
80105a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5a:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80105a61:	00 00 00 
        p->stime=0;
80105a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a67:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80105a6e:	00 00 00 
        pid = p->pid;
80105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a74:	8b 40 10             	mov    0x10(%eax),%eax
80105a77:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7d:	8b 40 08             	mov    0x8(%eax),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 b6 d8 ff ff       	call   8010333e <kfree>
        p->kstack = 0;
80105a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a95:	8b 40 04             	mov    0x4(%eax),%eax
80105a98:	89 04 24             	mov    %eax,(%esp)
80105a9b:	e8 11 35 00 00       	call   80108fb1 <freevm>
        p->state = UNUSED;
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aad:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105acf:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105ad6:	e8 32 01 00 00       	call   80105c0d <release>
        return pid;
80105adb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ade:	eb 56                	jmp    80105b36 <wait2+0x16b>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105ae0:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105ae1:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105ae8:	81 7d f4 d4 65 11 80 	cmpl   $0x801165d4,-0xc(%ebp)
80105aef:	0f 82 fb fe ff ff    	jb     801059f0 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105af5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105af9:	74 0d                	je     80105b08 <wait2+0x13d>
80105afb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b01:	8b 40 24             	mov    0x24(%eax),%eax
80105b04:	85 c0                	test   %eax,%eax
80105b06:	74 13                	je     80105b1b <wait2+0x150>
      release(&ptable.lock);
80105b08:	c7 04 24 a0 41 11 80 	movl   $0x801141a0,(%esp)
80105b0f:	e8 f9 00 00 00       	call   80105c0d <release>
      return -1;
80105b14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b19:	eb 1b                	jmp    80105b36 <wait2+0x16b>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105b1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b21:	c7 44 24 04 a0 41 11 	movl   $0x801141a0,0x4(%esp)
80105b28:	80 
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 8e fb ff ff       	call   801056bf <sleep>
  }
80105b31:	e9 a7 fe ff ff       	jmp    801059dd <wait2+0x12>
}
80105b36:	c9                   	leave  
80105b37:	c3                   	ret    

80105b38 <set_prio>:


int
set_prio(int priority){
80105b38:	55                   	push   %ebp
80105b39:	89 e5                	mov    %esp,%ebp
  #if SCHEDFLAG == DML
  return -1;
80105b3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  #endif
  if ((priority>MAX_PRIORITY) | (priority<MIN_PRIORITY))
    return -1;
  proc->priority=priority;
  return 0;
}
80105b40:	5d                   	pop    %ebp
80105b41:	c3                   	ret    
	...

80105b44 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b44:	55                   	push   %ebp
80105b45:	89 e5                	mov    %esp,%ebp
80105b47:	53                   	push   %ebx
80105b48:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b4b:	9c                   	pushf  
80105b4c:	5b                   	pop    %ebx
80105b4d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	5b                   	pop    %ebx
80105b57:	5d                   	pop    %ebp
80105b58:	c3                   	ret    

80105b59 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b59:	55                   	push   %ebp
80105b5a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b5c:	fa                   	cli    
}
80105b5d:	5d                   	pop    %ebp
80105b5e:	c3                   	ret    

80105b5f <sti>:

static inline void
sti(void)
{
80105b5f:	55                   	push   %ebp
80105b60:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b62:	fb                   	sti    
}
80105b63:	5d                   	pop    %ebp
80105b64:	c3                   	ret    

80105b65 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b65:	55                   	push   %ebp
80105b66:	89 e5                	mov    %esp,%ebp
80105b68:	53                   	push   %ebx
80105b69:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105b6c:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b75:	89 c3                	mov    %eax,%ebx
80105b77:	89 d8                	mov    %ebx,%eax
80105b79:	f0 87 02             	lock xchg %eax,(%edx)
80105b7c:	89 c3                	mov    %eax,%ebx
80105b7e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b81:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105b84:	83 c4 10             	add    $0x10,%esp
80105b87:	5b                   	pop    %ebx
80105b88:	5d                   	pop    %ebp
80105b89:	c3                   	ret    

80105b8a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b8a:	55                   	push   %ebp
80105b8b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105b90:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b93:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b96:	8b 45 08             	mov    0x8(%ebp),%eax
80105b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105ba9:	5d                   	pop    %ebp
80105baa:	c3                   	ret    

80105bab <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105bab:	55                   	push   %ebp
80105bac:	89 e5                	mov    %esp,%ebp
80105bae:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105bb1:	e8 3d 01 00 00       	call   80105cf3 <pushcli>
  if(holding(lk))
80105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb9:	89 04 24             	mov    %eax,(%esp)
80105bbc:	e8 08 01 00 00       	call   80105cc9 <holding>
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	74 0c                	je     80105bd1 <acquire+0x26>
    panic("acquire");
80105bc5:	c7 04 24 c9 96 10 80 	movl   $0x801096c9,(%esp)
80105bcc:	e8 6c a9 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bd1:	90                   	nop
80105bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105bdc:	00 
80105bdd:	89 04 24             	mov    %eax,(%esp)
80105be0:	e8 80 ff ff ff       	call   80105b65 <xchg>
80105be5:	85 c0                	test   %eax,%eax
80105be7:	75 e9                	jne    80105bd2 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105be9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bf3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf9:	83 c0 0c             	add    $0xc,%eax
80105bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c00:	8d 45 08             	lea    0x8(%ebp),%eax
80105c03:	89 04 24             	mov    %eax,(%esp)
80105c06:	e8 51 00 00 00       	call   80105c5c <getcallerpcs>
}
80105c0b:	c9                   	leave  
80105c0c:	c3                   	ret    

80105c0d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105c0d:	55                   	push   %ebp
80105c0e:	89 e5                	mov    %esp,%ebp
80105c10:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105c13:	8b 45 08             	mov    0x8(%ebp),%eax
80105c16:	89 04 24             	mov    %eax,(%esp)
80105c19:	e8 ab 00 00 00       	call   80105cc9 <holding>
80105c1e:	85 c0                	test   %eax,%eax
80105c20:	75 0c                	jne    80105c2e <release+0x21>
    panic("release");
80105c22:	c7 04 24 d1 96 10 80 	movl   $0x801096d1,(%esp)
80105c29:	e8 0f a9 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c31:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c38:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c42:	8b 45 08             	mov    0x8(%ebp),%eax
80105c45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c4c:	00 
80105c4d:	89 04 24             	mov    %eax,(%esp)
80105c50:	e8 10 ff ff ff       	call   80105b65 <xchg>

  popcli();
80105c55:	e8 e1 00 00 00       	call   80105d3b <popcli>
}
80105c5a:	c9                   	leave  
80105c5b:	c3                   	ret    

80105c5c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c5c:	55                   	push   %ebp
80105c5d:	89 e5                	mov    %esp,%ebp
80105c5f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c62:	8b 45 08             	mov    0x8(%ebp),%eax
80105c65:	83 e8 08             	sub    $0x8,%eax
80105c68:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c6b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c72:	eb 32                	jmp    80105ca6 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c74:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c78:	74 47                	je     80105cc1 <getcallerpcs+0x65>
80105c7a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c81:	76 3e                	jbe    80105cc1 <getcallerpcs+0x65>
80105c83:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c87:	74 38                	je     80105cc1 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c89:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c8c:	c1 e0 02             	shl    $0x2,%eax
80105c8f:	03 45 0c             	add    0xc(%ebp),%eax
80105c92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c95:	8b 52 04             	mov    0x4(%edx),%edx
80105c98:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c9d:	8b 00                	mov    (%eax),%eax
80105c9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105ca2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105ca6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105caa:	7e c8                	jle    80105c74 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cac:	eb 13                	jmp    80105cc1 <getcallerpcs+0x65>
    pcs[i] = 0;
80105cae:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cb1:	c1 e0 02             	shl    $0x2,%eax
80105cb4:	03 45 0c             	add    0xc(%ebp),%eax
80105cb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cbd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cc1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cc5:	7e e7                	jle    80105cae <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105cc7:	c9                   	leave  
80105cc8:	c3                   	ret    

80105cc9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cc9:	55                   	push   %ebp
80105cca:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80105ccf:	8b 00                	mov    (%eax),%eax
80105cd1:	85 c0                	test   %eax,%eax
80105cd3:	74 17                	je     80105cec <holding+0x23>
80105cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd8:	8b 50 08             	mov    0x8(%eax),%edx
80105cdb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ce1:	39 c2                	cmp    %eax,%edx
80105ce3:	75 07                	jne    80105cec <holding+0x23>
80105ce5:	b8 01 00 00 00       	mov    $0x1,%eax
80105cea:	eb 05                	jmp    80105cf1 <holding+0x28>
80105cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf1:	5d                   	pop    %ebp
80105cf2:	c3                   	ret    

80105cf3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105cf3:	55                   	push   %ebp
80105cf4:	89 e5                	mov    %esp,%ebp
80105cf6:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105cf9:	e8 46 fe ff ff       	call   80105b44 <readeflags>
80105cfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d01:	e8 53 fe ff ff       	call   80105b59 <cli>
  if(cpu->ncli++ == 0)
80105d06:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d0c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d12:	85 d2                	test   %edx,%edx
80105d14:	0f 94 c1             	sete   %cl
80105d17:	83 c2 01             	add    $0x1,%edx
80105d1a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d20:	84 c9                	test   %cl,%cl
80105d22:	74 15                	je     80105d39 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105d24:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d2a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d2d:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d33:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d39:	c9                   	leave  
80105d3a:	c3                   	ret    

80105d3b <popcli>:

void
popcli(void)
{
80105d3b:	55                   	push   %ebp
80105d3c:	89 e5                	mov    %esp,%ebp
80105d3e:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105d41:	e8 fe fd ff ff       	call   80105b44 <readeflags>
80105d46:	25 00 02 00 00       	and    $0x200,%eax
80105d4b:	85 c0                	test   %eax,%eax
80105d4d:	74 0c                	je     80105d5b <popcli+0x20>
    panic("popcli - interruptible");
80105d4f:	c7 04 24 d9 96 10 80 	movl   $0x801096d9,(%esp)
80105d56:	e8 e2 a7 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105d5b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d61:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d67:	83 ea 01             	sub    $0x1,%edx
80105d6a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d70:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d76:	85 c0                	test   %eax,%eax
80105d78:	79 0c                	jns    80105d86 <popcli+0x4b>
    panic("popcli");
80105d7a:	c7 04 24 f0 96 10 80 	movl   $0x801096f0,(%esp)
80105d81:	e8 b7 a7 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d86:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d8c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d92:	85 c0                	test   %eax,%eax
80105d94:	75 15                	jne    80105dab <popcli+0x70>
80105d96:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d9c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105da2:	85 c0                	test   %eax,%eax
80105da4:	74 05                	je     80105dab <popcli+0x70>
    sti();
80105da6:	e8 b4 fd ff ff       	call   80105b5f <sti>
}
80105dab:	c9                   	leave  
80105dac:	c3                   	ret    
80105dad:	00 00                	add    %al,(%eax)
	...

80105db0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105db0:	55                   	push   %ebp
80105db1:	89 e5                	mov    %esp,%ebp
80105db3:	57                   	push   %edi
80105db4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105db8:	8b 55 10             	mov    0x10(%ebp),%edx
80105dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dbe:	89 cb                	mov    %ecx,%ebx
80105dc0:	89 df                	mov    %ebx,%edi
80105dc2:	89 d1                	mov    %edx,%ecx
80105dc4:	fc                   	cld    
80105dc5:	f3 aa                	rep stos %al,%es:(%edi)
80105dc7:	89 ca                	mov    %ecx,%edx
80105dc9:	89 fb                	mov    %edi,%ebx
80105dcb:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dce:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dd1:	5b                   	pop    %ebx
80105dd2:	5f                   	pop    %edi
80105dd3:	5d                   	pop    %ebp
80105dd4:	c3                   	ret    

80105dd5 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dd5:	55                   	push   %ebp
80105dd6:	89 e5                	mov    %esp,%ebp
80105dd8:	57                   	push   %edi
80105dd9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ddd:	8b 55 10             	mov    0x10(%ebp),%edx
80105de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105de3:	89 cb                	mov    %ecx,%ebx
80105de5:	89 df                	mov    %ebx,%edi
80105de7:	89 d1                	mov    %edx,%ecx
80105de9:	fc                   	cld    
80105dea:	f3 ab                	rep stos %eax,%es:(%edi)
80105dec:	89 ca                	mov    %ecx,%edx
80105dee:	89 fb                	mov    %edi,%ebx
80105df0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105df3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105df6:	5b                   	pop    %ebx
80105df7:	5f                   	pop    %edi
80105df8:	5d                   	pop    %ebp
80105df9:	c3                   	ret    

80105dfa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105dfa:	55                   	push   %ebp
80105dfb:	89 e5                	mov    %esp,%ebp
80105dfd:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105e00:	8b 45 08             	mov    0x8(%ebp),%eax
80105e03:	83 e0 03             	and    $0x3,%eax
80105e06:	85 c0                	test   %eax,%eax
80105e08:	75 49                	jne    80105e53 <memset+0x59>
80105e0a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e0d:	83 e0 03             	and    $0x3,%eax
80105e10:	85 c0                	test   %eax,%eax
80105e12:	75 3f                	jne    80105e53 <memset+0x59>
    c &= 0xFF;
80105e14:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e1b:	8b 45 10             	mov    0x10(%ebp),%eax
80105e1e:	c1 e8 02             	shr    $0x2,%eax
80105e21:	89 c2                	mov    %eax,%edx
80105e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e26:	89 c1                	mov    %eax,%ecx
80105e28:	c1 e1 18             	shl    $0x18,%ecx
80105e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e2e:	c1 e0 10             	shl    $0x10,%eax
80105e31:	09 c1                	or     %eax,%ecx
80105e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e36:	c1 e0 08             	shl    $0x8,%eax
80105e39:	09 c8                	or     %ecx,%eax
80105e3b:	0b 45 0c             	or     0xc(%ebp),%eax
80105e3e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105e42:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e46:	8b 45 08             	mov    0x8(%ebp),%eax
80105e49:	89 04 24             	mov    %eax,(%esp)
80105e4c:	e8 84 ff ff ff       	call   80105dd5 <stosl>
80105e51:	eb 19                	jmp    80105e6c <memset+0x72>
  } else
    stosb(dst, c, n);
80105e53:	8b 45 10             	mov    0x10(%ebp),%eax
80105e56:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e61:	8b 45 08             	mov    0x8(%ebp),%eax
80105e64:	89 04 24             	mov    %eax,(%esp)
80105e67:	e8 44 ff ff ff       	call   80105db0 <stosb>
  return dst;
80105e6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e6f:	c9                   	leave  
80105e70:	c3                   	ret    

80105e71 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e71:	55                   	push   %ebp
80105e72:	89 e5                	mov    %esp,%ebp
80105e74:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e77:	8b 45 08             	mov    0x8(%ebp),%eax
80105e7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e80:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e83:	eb 32                	jmp    80105eb7 <memcmp+0x46>
    if(*s1 != *s2)
80105e85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e88:	0f b6 10             	movzbl (%eax),%edx
80105e8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e8e:	0f b6 00             	movzbl (%eax),%eax
80105e91:	38 c2                	cmp    %al,%dl
80105e93:	74 1a                	je     80105eaf <memcmp+0x3e>
      return *s1 - *s2;
80105e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e98:	0f b6 00             	movzbl (%eax),%eax
80105e9b:	0f b6 d0             	movzbl %al,%edx
80105e9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ea1:	0f b6 00             	movzbl (%eax),%eax
80105ea4:	0f b6 c0             	movzbl %al,%eax
80105ea7:	89 d1                	mov    %edx,%ecx
80105ea9:	29 c1                	sub    %eax,%ecx
80105eab:	89 c8                	mov    %ecx,%eax
80105ead:	eb 1c                	jmp    80105ecb <memcmp+0x5a>
    s1++, s2++;
80105eaf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105eb3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105eb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ebb:	0f 95 c0             	setne  %al
80105ebe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105ec2:	84 c0                	test   %al,%al
80105ec4:	75 bf                	jne    80105e85 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ecb:	c9                   	leave  
80105ecc:	c3                   	ret    

80105ecd <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ecd:	55                   	push   %ebp
80105ece:	89 e5                	mov    %esp,%ebp
80105ed0:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ed6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80105edc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ee2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ee5:	73 54                	jae    80105f3b <memmove+0x6e>
80105ee7:	8b 45 10             	mov    0x10(%ebp),%eax
80105eea:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105eed:	01 d0                	add    %edx,%eax
80105eef:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ef2:	76 47                	jbe    80105f3b <memmove+0x6e>
    s += n;
80105ef4:	8b 45 10             	mov    0x10(%ebp),%eax
80105ef7:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105efa:	8b 45 10             	mov    0x10(%ebp),%eax
80105efd:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105f00:	eb 13                	jmp    80105f15 <memmove+0x48>
      *--d = *--s;
80105f02:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105f06:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f0d:	0f b6 10             	movzbl (%eax),%edx
80105f10:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f13:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f19:	0f 95 c0             	setne  %al
80105f1c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f20:	84 c0                	test   %al,%al
80105f22:	75 de                	jne    80105f02 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f24:	eb 25                	jmp    80105f4b <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f29:	0f b6 10             	movzbl (%eax),%edx
80105f2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f2f:	88 10                	mov    %dl,(%eax)
80105f31:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105f35:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f39:	eb 01                	jmp    80105f3c <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f3b:	90                   	nop
80105f3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f40:	0f 95 c0             	setne  %al
80105f43:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f47:	84 c0                	test   %al,%al
80105f49:	75 db                	jne    80105f26 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105f4b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f4e:	c9                   	leave  
80105f4f:	c3                   	ret    

80105f50 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f50:	55                   	push   %ebp
80105f51:	89 e5                	mov    %esp,%ebp
80105f53:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105f56:	8b 45 10             	mov    0x10(%ebp),%eax
80105f59:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f64:	8b 45 08             	mov    0x8(%ebp),%eax
80105f67:	89 04 24             	mov    %eax,(%esp)
80105f6a:	e8 5e ff ff ff       	call   80105ecd <memmove>
}
80105f6f:	c9                   	leave  
80105f70:	c3                   	ret    

80105f71 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f71:	55                   	push   %ebp
80105f72:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f74:	eb 0c                	jmp    80105f82 <strncmp+0x11>
    n--, p++, q++;
80105f76:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f7a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f7e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f86:	74 1a                	je     80105fa2 <strncmp+0x31>
80105f88:	8b 45 08             	mov    0x8(%ebp),%eax
80105f8b:	0f b6 00             	movzbl (%eax),%eax
80105f8e:	84 c0                	test   %al,%al
80105f90:	74 10                	je     80105fa2 <strncmp+0x31>
80105f92:	8b 45 08             	mov    0x8(%ebp),%eax
80105f95:	0f b6 10             	movzbl (%eax),%edx
80105f98:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f9b:	0f b6 00             	movzbl (%eax),%eax
80105f9e:	38 c2                	cmp    %al,%dl
80105fa0:	74 d4                	je     80105f76 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105fa2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fa6:	75 07                	jne    80105faf <strncmp+0x3e>
    return 0;
80105fa8:	b8 00 00 00 00       	mov    $0x0,%eax
80105fad:	eb 18                	jmp    80105fc7 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105faf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb2:	0f b6 00             	movzbl (%eax),%eax
80105fb5:	0f b6 d0             	movzbl %al,%edx
80105fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fbb:	0f b6 00             	movzbl (%eax),%eax
80105fbe:	0f b6 c0             	movzbl %al,%eax
80105fc1:	89 d1                	mov    %edx,%ecx
80105fc3:	29 c1                	sub    %eax,%ecx
80105fc5:	89 c8                	mov    %ecx,%eax
}
80105fc7:	5d                   	pop    %ebp
80105fc8:	c3                   	ret    

80105fc9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105fc9:	55                   	push   %ebp
80105fca:	89 e5                	mov    %esp,%ebp
80105fcc:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105fd5:	90                   	nop
80105fd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fda:	0f 9f c0             	setg   %al
80105fdd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105fe1:	84 c0                	test   %al,%al
80105fe3:	74 30                	je     80106015 <strncpy+0x4c>
80105fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fe8:	0f b6 10             	movzbl (%eax),%edx
80105feb:	8b 45 08             	mov    0x8(%ebp),%eax
80105fee:	88 10                	mov    %dl,(%eax)
80105ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff3:	0f b6 00             	movzbl (%eax),%eax
80105ff6:	84 c0                	test   %al,%al
80105ff8:	0f 95 c0             	setne  %al
80105ffb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105fff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80106003:	84 c0                	test   %al,%al
80106005:	75 cf                	jne    80105fd6 <strncpy+0xd>
    ;
  while(n-- > 0)
80106007:	eb 0c                	jmp    80106015 <strncpy+0x4c>
    *s++ = 0;
80106009:	8b 45 08             	mov    0x8(%ebp),%eax
8010600c:	c6 00 00             	movb   $0x0,(%eax)
8010600f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106013:	eb 01                	jmp    80106016 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106015:	90                   	nop
80106016:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010601a:	0f 9f c0             	setg   %al
8010601d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106021:	84 c0                	test   %al,%al
80106023:	75 e4                	jne    80106009 <strncpy+0x40>
    *s++ = 0;
  return os;
80106025:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106028:	c9                   	leave  
80106029:	c3                   	ret    

8010602a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010602a:	55                   	push   %ebp
8010602b:	89 e5                	mov    %esp,%ebp
8010602d:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106030:	8b 45 08             	mov    0x8(%ebp),%eax
80106033:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106036:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010603a:	7f 05                	jg     80106041 <safestrcpy+0x17>
    return os;
8010603c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010603f:	eb 35                	jmp    80106076 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80106041:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106045:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106049:	7e 22                	jle    8010606d <safestrcpy+0x43>
8010604b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010604e:	0f b6 10             	movzbl (%eax),%edx
80106051:	8b 45 08             	mov    0x8(%ebp),%eax
80106054:	88 10                	mov    %dl,(%eax)
80106056:	8b 45 08             	mov    0x8(%ebp),%eax
80106059:	0f b6 00             	movzbl (%eax),%eax
8010605c:	84 c0                	test   %al,%al
8010605e:	0f 95 c0             	setne  %al
80106061:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106065:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80106069:	84 c0                	test   %al,%al
8010606b:	75 d4                	jne    80106041 <safestrcpy+0x17>
    ;
  *s = 0;
8010606d:	8b 45 08             	mov    0x8(%ebp),%eax
80106070:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106073:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106076:	c9                   	leave  
80106077:	c3                   	ret    

80106078 <strlen>:

int
strlen(const char *s)
{
80106078:	55                   	push   %ebp
80106079:	89 e5                	mov    %esp,%ebp
8010607b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010607e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106085:	eb 04                	jmp    8010608b <strlen+0x13>
80106087:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010608b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010608e:	03 45 08             	add    0x8(%ebp),%eax
80106091:	0f b6 00             	movzbl (%eax),%eax
80106094:	84 c0                	test   %al,%al
80106096:	75 ef                	jne    80106087 <strlen+0xf>
    ;
  return n;
80106098:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010609b:	c9                   	leave  
8010609c:	c3                   	ret    
8010609d:	00 00                	add    %al,(%eax)
	...

801060a0 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801060a0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801060a4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801060a8:	55                   	push   %ebp
  pushl %ebx
801060a9:	53                   	push   %ebx
  pushl %esi
801060aa:	56                   	push   %esi
  pushl %edi
801060ab:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801060ac:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801060ae:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801060b0:	5f                   	pop    %edi
  popl %esi
801060b1:	5e                   	pop    %esi
  popl %ebx
801060b2:	5b                   	pop    %ebx
  popl %ebp
801060b3:	5d                   	pop    %ebp
  ret
801060b4:	c3                   	ret    
801060b5:	00 00                	add    %al,(%eax)
	...

801060b8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801060b8:	55                   	push   %ebp
801060b9:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801060bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c1:	8b 00                	mov    (%eax),%eax
801060c3:	3b 45 08             	cmp    0x8(%ebp),%eax
801060c6:	76 12                	jbe    801060da <fetchint+0x22>
801060c8:	8b 45 08             	mov    0x8(%ebp),%eax
801060cb:	8d 50 04             	lea    0x4(%eax),%edx
801060ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d4:	8b 00                	mov    (%eax),%eax
801060d6:	39 c2                	cmp    %eax,%edx
801060d8:	76 07                	jbe    801060e1 <fetchint+0x29>
    return -1;
801060da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060df:	eb 0f                	jmp    801060f0 <fetchint+0x38>
  *ip = *(int*)(addr);
801060e1:	8b 45 08             	mov    0x8(%ebp),%eax
801060e4:	8b 10                	mov    (%eax),%edx
801060e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801060e9:	89 10                	mov    %edx,(%eax)
  return 0;
801060eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060f0:	5d                   	pop    %ebp
801060f1:	c3                   	ret    

801060f2 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060f2:	55                   	push   %ebp
801060f3:	89 e5                	mov    %esp,%ebp
801060f5:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060fe:	8b 00                	mov    (%eax),%eax
80106100:	3b 45 08             	cmp    0x8(%ebp),%eax
80106103:	77 07                	ja     8010610c <fetchstr+0x1a>
    return -1;
80106105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610a:	eb 48                	jmp    80106154 <fetchstr+0x62>
  *pp = (char*)addr;
8010610c:	8b 55 08             	mov    0x8(%ebp),%edx
8010610f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106112:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106114:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010611a:	8b 00                	mov    (%eax),%eax
8010611c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010611f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106122:	8b 00                	mov    (%eax),%eax
80106124:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106127:	eb 1e                	jmp    80106147 <fetchstr+0x55>
    if(*s == 0)
80106129:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010612c:	0f b6 00             	movzbl (%eax),%eax
8010612f:	84 c0                	test   %al,%al
80106131:	75 10                	jne    80106143 <fetchstr+0x51>
      return s - *pp;
80106133:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106136:	8b 45 0c             	mov    0xc(%ebp),%eax
80106139:	8b 00                	mov    (%eax),%eax
8010613b:	89 d1                	mov    %edx,%ecx
8010613d:	29 c1                	sub    %eax,%ecx
8010613f:	89 c8                	mov    %ecx,%eax
80106141:	eb 11                	jmp    80106154 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106143:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106147:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010614a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010614d:	72 da                	jb     80106129 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010614f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106154:	c9                   	leave  
80106155:	c3                   	ret    

80106156 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106156:	55                   	push   %ebp
80106157:	89 e5                	mov    %esp,%ebp
80106159:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010615c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106162:	8b 40 18             	mov    0x18(%eax),%eax
80106165:	8b 50 44             	mov    0x44(%eax),%edx
80106168:	8b 45 08             	mov    0x8(%ebp),%eax
8010616b:	c1 e0 02             	shl    $0x2,%eax
8010616e:	01 d0                	add    %edx,%eax
80106170:	8d 50 04             	lea    0x4(%eax),%edx
80106173:	8b 45 0c             	mov    0xc(%ebp),%eax
80106176:	89 44 24 04          	mov    %eax,0x4(%esp)
8010617a:	89 14 24             	mov    %edx,(%esp)
8010617d:	e8 36 ff ff ff       	call   801060b8 <fetchint>
}
80106182:	c9                   	leave  
80106183:	c3                   	ret    

80106184 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106184:	55                   	push   %ebp
80106185:	89 e5                	mov    %esp,%ebp
80106187:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(argint(n, &i) < 0)
8010618a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010618d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106191:	8b 45 08             	mov    0x8(%ebp),%eax
80106194:	89 04 24             	mov    %eax,(%esp)
80106197:	e8 ba ff ff ff       	call   80106156 <argint>
8010619c:	85 c0                	test   %eax,%eax
8010619e:	79 07                	jns    801061a7 <argptr+0x23>
    return -1;
801061a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a5:	eb 3d                	jmp    801061e4 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801061a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061aa:	89 c2                	mov    %eax,%edx
801061ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061b2:	8b 00                	mov    (%eax),%eax
801061b4:	39 c2                	cmp    %eax,%edx
801061b6:	73 16                	jae    801061ce <argptr+0x4a>
801061b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061bb:	89 c2                	mov    %eax,%edx
801061bd:	8b 45 10             	mov    0x10(%ebp),%eax
801061c0:	01 c2                	add    %eax,%edx
801061c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061c8:	8b 00                	mov    (%eax),%eax
801061ca:	39 c2                	cmp    %eax,%edx
801061cc:	76 07                	jbe    801061d5 <argptr+0x51>
    return -1;
801061ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d3:	eb 0f                	jmp    801061e4 <argptr+0x60>
  *pp = (char*)i;
801061d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061d8:	89 c2                	mov    %eax,%edx
801061da:	8b 45 0c             	mov    0xc(%ebp),%eax
801061dd:	89 10                	mov    %edx,(%eax)
  return 0;
801061df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061e4:	c9                   	leave  
801061e5:	c3                   	ret    

801061e6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801061e6:	55                   	push   %ebp
801061e7:	89 e5                	mov    %esp,%ebp
801061e9:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801061ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801061f3:	8b 45 08             	mov    0x8(%ebp),%eax
801061f6:	89 04 24             	mov    %eax,(%esp)
801061f9:	e8 58 ff ff ff       	call   80106156 <argint>
801061fe:	85 c0                	test   %eax,%eax
80106200:	79 07                	jns    80106209 <argstr+0x23>
    return -1;
80106202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106207:	eb 12                	jmp    8010621b <argstr+0x35>
  return fetchstr(addr, pp);
80106209:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010620c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010620f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106213:	89 04 24             	mov    %eax,(%esp)
80106216:	e8 d7 fe ff ff       	call   801060f2 <fetchstr>
}
8010621b:	c9                   	leave  
8010621c:	c3                   	ret    

8010621d <syscall>:
[SYS_yield] sys_yield,
};

void
syscall(void)
{
8010621d:	55                   	push   %ebp
8010621e:	89 e5                	mov    %esp,%ebp
80106220:	53                   	push   %ebx
80106221:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80106224:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010622a:	8b 40 18             	mov    0x18(%eax),%eax
8010622d:	8b 40 1c             	mov    0x1c(%eax),%eax
80106230:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106237:	7e 30                	jle    80106269 <syscall+0x4c>
80106239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623c:	83 f8 18             	cmp    $0x18,%eax
8010623f:	77 28                	ja     80106269 <syscall+0x4c>
80106241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106244:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010624b:	85 c0                	test   %eax,%eax
8010624d:	74 1a                	je     80106269 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010624f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106255:	8b 58 18             	mov    0x18(%eax),%ebx
80106258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625b:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106262:	ff d0                	call   *%eax
80106264:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106267:	eb 3d                	jmp    801062a6 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106269:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010626f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106272:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106278:	8b 40 10             	mov    0x10(%eax),%eax
8010627b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010627e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80106282:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106286:	89 44 24 04          	mov    %eax,0x4(%esp)
8010628a:	c7 04 24 f7 96 10 80 	movl   $0x801096f7,(%esp)
80106291:	e8 0b a1 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106296:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010629c:	8b 40 18             	mov    0x18(%eax),%eax
8010629f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801062a6:	83 c4 24             	add    $0x24,%esp
801062a9:	5b                   	pop    %ebx
801062aa:	5d                   	pop    %ebp
801062ab:	c3                   	ret    

801062ac <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801062ac:	55                   	push   %ebp
801062ad:	89 e5                	mov    %esp,%ebp
801062af:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801062b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b9:	8b 45 08             	mov    0x8(%ebp),%eax
801062bc:	89 04 24             	mov    %eax,(%esp)
801062bf:	e8 92 fe ff ff       	call   80106156 <argint>
801062c4:	85 c0                	test   %eax,%eax
801062c6:	79 07                	jns    801062cf <argfd+0x23>
    return -1;
801062c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062cd:	eb 50                	jmp    8010631f <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801062cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d2:	85 c0                	test   %eax,%eax
801062d4:	78 21                	js     801062f7 <argfd+0x4b>
801062d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d9:	83 f8 0f             	cmp    $0xf,%eax
801062dc:	7f 19                	jg     801062f7 <argfd+0x4b>
801062de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062e7:	83 c2 08             	add    $0x8,%edx
801062ea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f5:	75 07                	jne    801062fe <argfd+0x52>
    return -1;
801062f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fc:	eb 21                	jmp    8010631f <argfd+0x73>
  if(pfd)
801062fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106302:	74 08                	je     8010630c <argfd+0x60>
    *pfd = fd;
80106304:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106307:	8b 45 0c             	mov    0xc(%ebp),%eax
8010630a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010630c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106310:	74 08                	je     8010631a <argfd+0x6e>
    *pf = f;
80106312:	8b 45 10             	mov    0x10(%ebp),%eax
80106315:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106318:	89 10                	mov    %edx,(%eax)
  return 0;
8010631a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010631f:	c9                   	leave  
80106320:	c3                   	ret    

80106321 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106321:	55                   	push   %ebp
80106322:	89 e5                	mov    %esp,%ebp
80106324:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106327:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010632e:	eb 30                	jmp    80106360 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106330:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106336:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106339:	83 c2 08             	add    $0x8,%edx
8010633c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106340:	85 c0                	test   %eax,%eax
80106342:	75 18                	jne    8010635c <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106344:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010634a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010634d:	8d 4a 08             	lea    0x8(%edx),%ecx
80106350:	8b 55 08             	mov    0x8(%ebp),%edx
80106353:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010635a:	eb 0f                	jmp    8010636b <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010635c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106360:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106364:	7e ca                	jle    80106330 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106366:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010636b:	c9                   	leave  
8010636c:	c3                   	ret    

8010636d <sys_dup>:

int
sys_dup(void)
{
8010636d:	55                   	push   %ebp
8010636e:	89 e5                	mov    %esp,%ebp
80106370:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106373:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106376:	89 44 24 08          	mov    %eax,0x8(%esp)
8010637a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106381:	00 
80106382:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106389:	e8 1e ff ff ff       	call   801062ac <argfd>
8010638e:	85 c0                	test   %eax,%eax
80106390:	79 07                	jns    80106399 <sys_dup+0x2c>
    return -1;
80106392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106397:	eb 29                	jmp    801063c2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639c:	89 04 24             	mov    %eax,(%esp)
8010639f:	e8 7d ff ff ff       	call   80106321 <fdalloc>
801063a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ab:	79 07                	jns    801063b4 <sys_dup+0x47>
    return -1;
801063ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b2:	eb 0e                	jmp    801063c2 <sys_dup+0x55>
  filedup(f);
801063b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b7:	89 04 24             	mov    %eax,(%esp)
801063ba:	e8 f9 b3 ff ff       	call   801017b8 <filedup>
  return fd;
801063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063c2:	c9                   	leave  
801063c3:	c3                   	ret    

801063c4 <sys_read>:

int
sys_read(void)
{
801063c4:	55                   	push   %ebp
801063c5:	89 e5                	mov    %esp,%ebp
801063c7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063cd:	89 44 24 08          	mov    %eax,0x8(%esp)
801063d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063d8:	00 
801063d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e0:	e8 c7 fe ff ff       	call   801062ac <argfd>
801063e5:	85 c0                	test   %eax,%eax
801063e7:	78 35                	js     8010641e <sys_read+0x5a>
801063e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801063f7:	e8 5a fd ff ff       	call   80106156 <argint>
801063fc:	85 c0                	test   %eax,%eax
801063fe:	78 1e                	js     8010641e <sys_read+0x5a>
80106400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106403:	89 44 24 08          	mov    %eax,0x8(%esp)
80106407:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010640a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010640e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106415:	e8 6a fd ff ff       	call   80106184 <argptr>
8010641a:	85 c0                	test   %eax,%eax
8010641c:	79 07                	jns    80106425 <sys_read+0x61>
    return -1;
8010641e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106423:	eb 19                	jmp    8010643e <sys_read+0x7a>
  return fileread(f, p, n);
80106425:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106428:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010642b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106432:	89 54 24 04          	mov    %edx,0x4(%esp)
80106436:	89 04 24             	mov    %eax,(%esp)
80106439:	e8 e7 b4 ff ff       	call   80101925 <fileread>
}
8010643e:	c9                   	leave  
8010643f:	c3                   	ret    

80106440 <sys_write>:

int
sys_write(void)
{
80106440:	55                   	push   %ebp
80106441:	89 e5                	mov    %esp,%ebp
80106443:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106446:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106449:	89 44 24 08          	mov    %eax,0x8(%esp)
8010644d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106454:	00 
80106455:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010645c:	e8 4b fe ff ff       	call   801062ac <argfd>
80106461:	85 c0                	test   %eax,%eax
80106463:	78 35                	js     8010649a <sys_write+0x5a>
80106465:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106468:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106473:	e8 de fc ff ff       	call   80106156 <argint>
80106478:	85 c0                	test   %eax,%eax
8010647a:	78 1e                	js     8010649a <sys_write+0x5a>
8010647c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106483:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106486:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106491:	e8 ee fc ff ff       	call   80106184 <argptr>
80106496:	85 c0                	test   %eax,%eax
80106498:	79 07                	jns    801064a1 <sys_write+0x61>
    return -1;
8010649a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649f:	eb 19                	jmp    801064ba <sys_write+0x7a>
  return filewrite(f, p, n);
801064a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801064a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801064a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801064ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801064b2:	89 04 24             	mov    %eax,(%esp)
801064b5:	e8 27 b5 ff ff       	call   801019e1 <filewrite>
}
801064ba:	c9                   	leave  
801064bb:	c3                   	ret    

801064bc <sys_close>:

int
sys_close(void)
{
801064bc:	55                   	push   %ebp
801064bd:	89 e5                	mov    %esp,%ebp
801064bf:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801064c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064c5:	89 44 24 08          	mov    %eax,0x8(%esp)
801064c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801064d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064d7:	e8 d0 fd ff ff       	call   801062ac <argfd>
801064dc:	85 c0                	test   %eax,%eax
801064de:	79 07                	jns    801064e7 <sys_close+0x2b>
    return -1;
801064e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e5:	eb 24                	jmp    8010650b <sys_close+0x4f>
  proc->ofile[fd] = 0;
801064e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064f0:	83 c2 08             	add    $0x8,%edx
801064f3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064fa:	00 
  fileclose(f);
801064fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064fe:	89 04 24             	mov    %eax,(%esp)
80106501:	e8 fa b2 ff ff       	call   80101800 <fileclose>
  return 0;
80106506:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010650b:	c9                   	leave  
8010650c:	c3                   	ret    

8010650d <sys_fstat>:

int
sys_fstat(void)
{
8010650d:	55                   	push   %ebp
8010650e:	89 e5                	mov    %esp,%ebp
80106510:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106513:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106516:	89 44 24 08          	mov    %eax,0x8(%esp)
8010651a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106521:	00 
80106522:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106529:	e8 7e fd ff ff       	call   801062ac <argfd>
8010652e:	85 c0                	test   %eax,%eax
80106530:	78 1f                	js     80106551 <sys_fstat+0x44>
80106532:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80106539:	00 
8010653a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010653d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106541:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106548:	e8 37 fc ff ff       	call   80106184 <argptr>
8010654d:	85 c0                	test   %eax,%eax
8010654f:	79 07                	jns    80106558 <sys_fstat+0x4b>
    return -1;
80106551:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106556:	eb 12                	jmp    8010656a <sys_fstat+0x5d>
  return filestat(f, st);
80106558:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010655b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106562:	89 04 24             	mov    %eax,(%esp)
80106565:	e8 6c b3 ff ff       	call   801018d6 <filestat>
}
8010656a:	c9                   	leave  
8010656b:	c3                   	ret    

8010656c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010656c:	55                   	push   %ebp
8010656d:	89 e5                	mov    %esp,%ebp
8010656f:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106572:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106575:	89 44 24 04          	mov    %eax,0x4(%esp)
80106579:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106580:	e8 61 fc ff ff       	call   801061e6 <argstr>
80106585:	85 c0                	test   %eax,%eax
80106587:	78 17                	js     801065a0 <sys_link+0x34>
80106589:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010658c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106590:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106597:	e8 4a fc ff ff       	call   801061e6 <argstr>
8010659c:	85 c0                	test   %eax,%eax
8010659e:	79 0a                	jns    801065aa <sys_link+0x3e>
    return -1;
801065a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a5:	e9 41 01 00 00       	jmp    801066eb <sys_link+0x17f>

  begin_op();
801065aa:	e8 72 d7 ff ff       	call   80103d21 <begin_op>
  if((ip = namei(old)) == 0){
801065af:	8b 45 d8             	mov    -0x28(%ebp),%eax
801065b2:	89 04 24             	mov    %eax,(%esp)
801065b5:	e8 f3 c6 ff ff       	call   80102cad <namei>
801065ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065c1:	75 0f                	jne    801065d2 <sys_link+0x66>
    end_op();
801065c3:	e8 da d7 ff ff       	call   80103da2 <end_op>
    return -1;
801065c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065cd:	e9 19 01 00 00       	jmp    801066eb <sys_link+0x17f>
  }

  ilock(ip);
801065d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d5:	89 04 24             	mov    %eax,(%esp)
801065d8:	e8 28 bb ff ff       	call   80102105 <ilock>
  if(ip->type == T_DIR){
801065dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065e4:	66 83 f8 01          	cmp    $0x1,%ax
801065e8:	75 1a                	jne    80106604 <sys_link+0x98>
    iunlockput(ip);
801065ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ed:	89 04 24             	mov    %eax,(%esp)
801065f0:	e8 9a bd ff ff       	call   8010238f <iunlockput>
    end_op();
801065f5:	e8 a8 d7 ff ff       	call   80103da2 <end_op>
    return -1;
801065fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ff:	e9 e7 00 00 00       	jmp    801066eb <sys_link+0x17f>
  }

  ip->nlink++;
80106604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106607:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010660b:	8d 50 01             	lea    0x1(%eax),%edx
8010660e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106611:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106618:	89 04 24             	mov    %eax,(%esp)
8010661b:	e8 23 b9 ff ff       	call   80101f43 <iupdate>
  iunlock(ip);
80106620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106623:	89 04 24             	mov    %eax,(%esp)
80106626:	e8 2e bc ff ff       	call   80102259 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010662b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010662e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106631:	89 54 24 04          	mov    %edx,0x4(%esp)
80106635:	89 04 24             	mov    %eax,(%esp)
80106638:	e8 92 c6 ff ff       	call   80102ccf <nameiparent>
8010663d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106640:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106644:	74 68                	je     801066ae <sys_link+0x142>
    goto bad;
  ilock(dp);
80106646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106649:	89 04 24             	mov    %eax,(%esp)
8010664c:	e8 b4 ba ff ff       	call   80102105 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106654:	8b 10                	mov    (%eax),%edx
80106656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106659:	8b 00                	mov    (%eax),%eax
8010665b:	39 c2                	cmp    %eax,%edx
8010665d:	75 20                	jne    8010667f <sys_link+0x113>
8010665f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106662:	8b 40 04             	mov    0x4(%eax),%eax
80106665:	89 44 24 08          	mov    %eax,0x8(%esp)
80106669:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010666c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106673:	89 04 24             	mov    %eax,(%esp)
80106676:	e8 71 c3 ff ff       	call   801029ec <dirlink>
8010667b:	85 c0                	test   %eax,%eax
8010667d:	79 0d                	jns    8010668c <sys_link+0x120>
    iunlockput(dp);
8010667f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106682:	89 04 24             	mov    %eax,(%esp)
80106685:	e8 05 bd ff ff       	call   8010238f <iunlockput>
    goto bad;
8010668a:	eb 23                	jmp    801066af <sys_link+0x143>
  }
  iunlockput(dp);
8010668c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010668f:	89 04 24             	mov    %eax,(%esp)
80106692:	e8 f8 bc ff ff       	call   8010238f <iunlockput>
  iput(ip);
80106697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669a:	89 04 24             	mov    %eax,(%esp)
8010669d:	e8 1c bc ff ff       	call   801022be <iput>

  end_op();
801066a2:	e8 fb d6 ff ff       	call   80103da2 <end_op>

  return 0;
801066a7:	b8 00 00 00 00       	mov    $0x0,%eax
801066ac:	eb 3d                	jmp    801066eb <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801066ae:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801066af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b2:	89 04 24             	mov    %eax,(%esp)
801066b5:	e8 4b ba ff ff       	call   80102105 <ilock>
  ip->nlink--;
801066ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bd:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066c1:	8d 50 ff             	lea    -0x1(%eax),%edx
801066c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c7:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801066cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ce:	89 04 24             	mov    %eax,(%esp)
801066d1:	e8 6d b8 ff ff       	call   80101f43 <iupdate>
  iunlockput(ip);
801066d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d9:	89 04 24             	mov    %eax,(%esp)
801066dc:	e8 ae bc ff ff       	call   8010238f <iunlockput>
  end_op();
801066e1:	e8 bc d6 ff ff       	call   80103da2 <end_op>
  return -1;
801066e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066eb:	c9                   	leave  
801066ec:	c3                   	ret    

801066ed <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801066ed:	55                   	push   %ebp
801066ee:	89 e5                	mov    %esp,%ebp
801066f0:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801066f3:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066fa:	eb 4b                	jmp    80106747 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ff:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106706:	00 
80106707:	89 44 24 08          	mov    %eax,0x8(%esp)
8010670b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010670e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106712:	8b 45 08             	mov    0x8(%ebp),%eax
80106715:	89 04 24             	mov    %eax,(%esp)
80106718:	e8 e4 be ff ff       	call   80102601 <readi>
8010671d:	83 f8 10             	cmp    $0x10,%eax
80106720:	74 0c                	je     8010672e <isdirempty+0x41>
      panic("isdirempty: readi");
80106722:	c7 04 24 13 97 10 80 	movl   $0x80109713,(%esp)
80106729:	e8 0f 9e ff ff       	call   8010053d <panic>
    if(de.inum != 0)
8010672e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106732:	66 85 c0             	test   %ax,%ax
80106735:	74 07                	je     8010673e <isdirempty+0x51>
      return 0;
80106737:	b8 00 00 00 00       	mov    $0x0,%eax
8010673c:	eb 1b                	jmp    80106759 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010673e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106741:	83 c0 10             	add    $0x10,%eax
80106744:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106747:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010674a:	8b 45 08             	mov    0x8(%ebp),%eax
8010674d:	8b 40 18             	mov    0x18(%eax),%eax
80106750:	39 c2                	cmp    %eax,%edx
80106752:	72 a8                	jb     801066fc <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106754:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106759:	c9                   	leave  
8010675a:	c3                   	ret    

8010675b <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010675b:	55                   	push   %ebp
8010675c:	89 e5                	mov    %esp,%ebp
8010675e:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106761:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106764:	89 44 24 04          	mov    %eax,0x4(%esp)
80106768:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010676f:	e8 72 fa ff ff       	call   801061e6 <argstr>
80106774:	85 c0                	test   %eax,%eax
80106776:	79 0a                	jns    80106782 <sys_unlink+0x27>
    return -1;
80106778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677d:	e9 af 01 00 00       	jmp    80106931 <sys_unlink+0x1d6>

  begin_op();
80106782:	e8 9a d5 ff ff       	call   80103d21 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106787:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010678a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010678d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106791:	89 04 24             	mov    %eax,(%esp)
80106794:	e8 36 c5 ff ff       	call   80102ccf <nameiparent>
80106799:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010679c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a0:	75 0f                	jne    801067b1 <sys_unlink+0x56>
    end_op();
801067a2:	e8 fb d5 ff ff       	call   80103da2 <end_op>
    return -1;
801067a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ac:	e9 80 01 00 00       	jmp    80106931 <sys_unlink+0x1d6>
  }

  ilock(dp);
801067b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b4:	89 04 24             	mov    %eax,(%esp)
801067b7:	e8 49 b9 ff ff       	call   80102105 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067bc:	c7 44 24 04 25 97 10 	movl   $0x80109725,0x4(%esp)
801067c3:	80 
801067c4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067c7:	89 04 24             	mov    %eax,(%esp)
801067ca:	e8 33 c1 ff ff       	call   80102902 <namecmp>
801067cf:	85 c0                	test   %eax,%eax
801067d1:	0f 84 45 01 00 00    	je     8010691c <sys_unlink+0x1c1>
801067d7:	c7 44 24 04 27 97 10 	movl   $0x80109727,0x4(%esp)
801067de:	80 
801067df:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067e2:	89 04 24             	mov    %eax,(%esp)
801067e5:	e8 18 c1 ff ff       	call   80102902 <namecmp>
801067ea:	85 c0                	test   %eax,%eax
801067ec:	0f 84 2a 01 00 00    	je     8010691c <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801067f2:	8d 45 c8             	lea    -0x38(%ebp),%eax
801067f5:	89 44 24 08          	mov    %eax,0x8(%esp)
801067f9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106803:	89 04 24             	mov    %eax,(%esp)
80106806:	e8 19 c1 ff ff       	call   80102924 <dirlookup>
8010680b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010680e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106812:	0f 84 03 01 00 00    	je     8010691b <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80106818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010681b:	89 04 24             	mov    %eax,(%esp)
8010681e:	e8 e2 b8 ff ff       	call   80102105 <ilock>

  if(ip->nlink < 1)
80106823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106826:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010682a:	66 85 c0             	test   %ax,%ax
8010682d:	7f 0c                	jg     8010683b <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
8010682f:	c7 04 24 2a 97 10 80 	movl   $0x8010972a,(%esp)
80106836:	e8 02 9d ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010683b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010683e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106842:	66 83 f8 01          	cmp    $0x1,%ax
80106846:	75 1f                	jne    80106867 <sys_unlink+0x10c>
80106848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010684b:	89 04 24             	mov    %eax,(%esp)
8010684e:	e8 9a fe ff ff       	call   801066ed <isdirempty>
80106853:	85 c0                	test   %eax,%eax
80106855:	75 10                	jne    80106867 <sys_unlink+0x10c>
    iunlockput(ip);
80106857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685a:	89 04 24             	mov    %eax,(%esp)
8010685d:	e8 2d bb ff ff       	call   8010238f <iunlockput>
    goto bad;
80106862:	e9 b5 00 00 00       	jmp    8010691c <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80106867:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010686e:	00 
8010686f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106876:	00 
80106877:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010687a:	89 04 24             	mov    %eax,(%esp)
8010687d:	e8 78 f5 ff ff       	call   80105dfa <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106882:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106885:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010688c:	00 
8010688d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106891:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106894:	89 44 24 04          	mov    %eax,0x4(%esp)
80106898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689b:	89 04 24             	mov    %eax,(%esp)
8010689e:	e8 c9 be ff ff       	call   8010276c <writei>
801068a3:	83 f8 10             	cmp    $0x10,%eax
801068a6:	74 0c                	je     801068b4 <sys_unlink+0x159>
    panic("unlink: writei");
801068a8:	c7 04 24 3c 97 10 80 	movl   $0x8010973c,(%esp)
801068af:	e8 89 9c ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
801068b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068bb:	66 83 f8 01          	cmp    $0x1,%ax
801068bf:	75 1c                	jne    801068dd <sys_unlink+0x182>
    dp->nlink--;
801068c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068c8:	8d 50 ff             	lea    -0x1(%eax),%edx
801068cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ce:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801068d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d5:	89 04 24             	mov    %eax,(%esp)
801068d8:	e8 66 b6 ff ff       	call   80101f43 <iupdate>
  }
  iunlockput(dp);
801068dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e0:	89 04 24             	mov    %eax,(%esp)
801068e3:	e8 a7 ba ff ff       	call   8010238f <iunlockput>

  ip->nlink--;
801068e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068eb:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068ef:	8d 50 ff             	lea    -0x1(%eax),%edx
801068f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f5:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801068f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068fc:	89 04 24             	mov    %eax,(%esp)
801068ff:	e8 3f b6 ff ff       	call   80101f43 <iupdate>
  iunlockput(ip);
80106904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106907:	89 04 24             	mov    %eax,(%esp)
8010690a:	e8 80 ba ff ff       	call   8010238f <iunlockput>

  end_op();
8010690f:	e8 8e d4 ff ff       	call   80103da2 <end_op>

  return 0;
80106914:	b8 00 00 00 00       	mov    $0x0,%eax
80106919:	eb 16                	jmp    80106931 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010691b:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010691c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691f:	89 04 24             	mov    %eax,(%esp)
80106922:	e8 68 ba ff ff       	call   8010238f <iunlockput>
  end_op();
80106927:	e8 76 d4 ff ff       	call   80103da2 <end_op>
  return -1;
8010692c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106931:	c9                   	leave  
80106932:	c3                   	ret    

80106933 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106933:	55                   	push   %ebp
80106934:	89 e5                	mov    %esp,%ebp
80106936:	83 ec 48             	sub    $0x48,%esp
80106939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010693c:	8b 55 10             	mov    0x10(%ebp),%edx
8010693f:	8b 45 14             	mov    0x14(%ebp),%eax
80106942:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106946:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010694a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010694e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106951:	89 44 24 04          	mov    %eax,0x4(%esp)
80106955:	8b 45 08             	mov    0x8(%ebp),%eax
80106958:	89 04 24             	mov    %eax,(%esp)
8010695b:	e8 6f c3 ff ff       	call   80102ccf <nameiparent>
80106960:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106963:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106967:	75 0a                	jne    80106973 <create+0x40>
    return 0;
80106969:	b8 00 00 00 00       	mov    $0x0,%eax
8010696e:	e9 7e 01 00 00       	jmp    80106af1 <create+0x1be>
  ilock(dp);
80106973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106976:	89 04 24             	mov    %eax,(%esp)
80106979:	e8 87 b7 ff ff       	call   80102105 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010697e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106981:	89 44 24 08          	mov    %eax,0x8(%esp)
80106985:	8d 45 de             	lea    -0x22(%ebp),%eax
80106988:	89 44 24 04          	mov    %eax,0x4(%esp)
8010698c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698f:	89 04 24             	mov    %eax,(%esp)
80106992:	e8 8d bf ff ff       	call   80102924 <dirlookup>
80106997:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010699a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010699e:	74 47                	je     801069e7 <create+0xb4>
    iunlockput(dp);
801069a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a3:	89 04 24             	mov    %eax,(%esp)
801069a6:	e8 e4 b9 ff ff       	call   8010238f <iunlockput>
    ilock(ip);
801069ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ae:	89 04 24             	mov    %eax,(%esp)
801069b1:	e8 4f b7 ff ff       	call   80102105 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801069b6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801069bb:	75 15                	jne    801069d2 <create+0x9f>
801069bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069c4:	66 83 f8 02          	cmp    $0x2,%ax
801069c8:	75 08                	jne    801069d2 <create+0x9f>
      return ip;
801069ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069cd:	e9 1f 01 00 00       	jmp    80106af1 <create+0x1be>
    iunlockput(ip);
801069d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d5:	89 04 24             	mov    %eax,(%esp)
801069d8:	e8 b2 b9 ff ff       	call   8010238f <iunlockput>
    return 0;
801069dd:	b8 00 00 00 00       	mov    $0x0,%eax
801069e2:	e9 0a 01 00 00       	jmp    80106af1 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801069e7:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801069eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ee:	8b 00                	mov    (%eax),%eax
801069f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801069f4:	89 04 24             	mov    %eax,(%esp)
801069f7:	e8 74 b4 ff ff       	call   80101e70 <ialloc>
801069fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a03:	75 0c                	jne    80106a11 <create+0xde>
    panic("create: ialloc");
80106a05:	c7 04 24 4b 97 10 80 	movl   $0x8010974b,(%esp)
80106a0c:	e8 2c 9b ff ff       	call   8010053d <panic>

  ilock(ip);
80106a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a14:	89 04 24             	mov    %eax,(%esp)
80106a17:	e8 e9 b6 ff ff       	call   80102105 <ilock>
  ip->major = major;
80106a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a1f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a23:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a2a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a2e:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a35:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a3e:	89 04 24             	mov    %eax,(%esp)
80106a41:	e8 fd b4 ff ff       	call   80101f43 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106a46:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106a4b:	75 6a                	jne    80106ab7 <create+0x184>
    dp->nlink++;  // for ".."
80106a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a50:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a54:	8d 50 01             	lea    0x1(%eax),%edx
80106a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a61:	89 04 24             	mov    %eax,(%esp)
80106a64:	e8 da b4 ff ff       	call   80101f43 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a6c:	8b 40 04             	mov    0x4(%eax),%eax
80106a6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106a73:	c7 44 24 04 25 97 10 	movl   $0x80109725,0x4(%esp)
80106a7a:	80 
80106a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a7e:	89 04 24             	mov    %eax,(%esp)
80106a81:	e8 66 bf ff ff       	call   801029ec <dirlink>
80106a86:	85 c0                	test   %eax,%eax
80106a88:	78 21                	js     80106aab <create+0x178>
80106a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8d:	8b 40 04             	mov    0x4(%eax),%eax
80106a90:	89 44 24 08          	mov    %eax,0x8(%esp)
80106a94:	c7 44 24 04 27 97 10 	movl   $0x80109727,0x4(%esp)
80106a9b:	80 
80106a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a9f:	89 04 24             	mov    %eax,(%esp)
80106aa2:	e8 45 bf ff ff       	call   801029ec <dirlink>
80106aa7:	85 c0                	test   %eax,%eax
80106aa9:	79 0c                	jns    80106ab7 <create+0x184>
      panic("create dots");
80106aab:	c7 04 24 5a 97 10 80 	movl   $0x8010975a,(%esp)
80106ab2:	e8 86 9a ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aba:	8b 40 04             	mov    0x4(%eax),%eax
80106abd:	89 44 24 08          	mov    %eax,0x8(%esp)
80106ac1:	8d 45 de             	lea    -0x22(%ebp),%eax
80106ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106acb:	89 04 24             	mov    %eax,(%esp)
80106ace:	e8 19 bf ff ff       	call   801029ec <dirlink>
80106ad3:	85 c0                	test   %eax,%eax
80106ad5:	79 0c                	jns    80106ae3 <create+0x1b0>
    panic("create: dirlink");
80106ad7:	c7 04 24 66 97 10 80 	movl   $0x80109766,(%esp)
80106ade:	e8 5a 9a ff ff       	call   8010053d <panic>

  iunlockput(dp);
80106ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae6:	89 04 24             	mov    %eax,(%esp)
80106ae9:	e8 a1 b8 ff ff       	call   8010238f <iunlockput>

  return ip;
80106aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106af1:	c9                   	leave  
80106af2:	c3                   	ret    

80106af3 <sys_open>:

int
sys_open(void)
{
80106af3:	55                   	push   %ebp
80106af4:	89 e5                	mov    %esp,%ebp
80106af6:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106af9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106afc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b07:	e8 da f6 ff ff       	call   801061e6 <argstr>
80106b0c:	85 c0                	test   %eax,%eax
80106b0e:	78 17                	js     80106b27 <sys_open+0x34>
80106b10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b13:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b1e:	e8 33 f6 ff ff       	call   80106156 <argint>
80106b23:	85 c0                	test   %eax,%eax
80106b25:	79 0a                	jns    80106b31 <sys_open+0x3e>
    return -1;
80106b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2c:	e9 5a 01 00 00       	jmp    80106c8b <sys_open+0x198>

  begin_op();
80106b31:	e8 eb d1 ff ff       	call   80103d21 <begin_op>

  if(omode & O_CREATE){
80106b36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b39:	25 00 02 00 00       	and    $0x200,%eax
80106b3e:	85 c0                	test   %eax,%eax
80106b40:	74 3b                	je     80106b7d <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106b42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106b4c:	00 
80106b4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106b54:	00 
80106b55:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106b5c:	00 
80106b5d:	89 04 24             	mov    %eax,(%esp)
80106b60:	e8 ce fd ff ff       	call   80106933 <create>
80106b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106b68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b6c:	75 6b                	jne    80106bd9 <sys_open+0xe6>
      end_op();
80106b6e:	e8 2f d2 ff ff       	call   80103da2 <end_op>
      return -1;
80106b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b78:	e9 0e 01 00 00       	jmp    80106c8b <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b80:	89 04 24             	mov    %eax,(%esp)
80106b83:	e8 25 c1 ff ff       	call   80102cad <namei>
80106b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b8f:	75 0f                	jne    80106ba0 <sys_open+0xad>
      end_op();
80106b91:	e8 0c d2 ff ff       	call   80103da2 <end_op>
      return -1;
80106b96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b9b:	e9 eb 00 00 00       	jmp    80106c8b <sys_open+0x198>
    }
    ilock(ip);
80106ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba3:	89 04 24             	mov    %eax,(%esp)
80106ba6:	e8 5a b5 ff ff       	call   80102105 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106bb2:	66 83 f8 01          	cmp    $0x1,%ax
80106bb6:	75 21                	jne    80106bd9 <sys_open+0xe6>
80106bb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bbb:	85 c0                	test   %eax,%eax
80106bbd:	74 1a                	je     80106bd9 <sys_open+0xe6>
      iunlockput(ip);
80106bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc2:	89 04 24             	mov    %eax,(%esp)
80106bc5:	e8 c5 b7 ff ff       	call   8010238f <iunlockput>
      end_op();
80106bca:	e8 d3 d1 ff ff       	call   80103da2 <end_op>
      return -1;
80106bcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bd4:	e9 b2 00 00 00       	jmp    80106c8b <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106bd9:	e8 7a ab ff ff       	call   80101758 <filealloc>
80106bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106be1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106be5:	74 14                	je     80106bfb <sys_open+0x108>
80106be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bea:	89 04 24             	mov    %eax,(%esp)
80106bed:	e8 2f f7 ff ff       	call   80106321 <fdalloc>
80106bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106bf5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106bf9:	79 28                	jns    80106c23 <sys_open+0x130>
    if(f)
80106bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bff:	74 0b                	je     80106c0c <sys_open+0x119>
      fileclose(f);
80106c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c04:	89 04 24             	mov    %eax,(%esp)
80106c07:	e8 f4 ab ff ff       	call   80101800 <fileclose>
    iunlockput(ip);
80106c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0f:	89 04 24             	mov    %eax,(%esp)
80106c12:	e8 78 b7 ff ff       	call   8010238f <iunlockput>
    end_op();
80106c17:	e8 86 d1 ff ff       	call   80103da2 <end_op>
    return -1;
80106c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c21:	eb 68                	jmp    80106c8b <sys_open+0x198>
  }
  iunlock(ip);
80106c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c26:	89 04 24             	mov    %eax,(%esp)
80106c29:	e8 2b b6 ff ff       	call   80102259 <iunlock>
  end_op();
80106c2e:	e8 6f d1 ff ff       	call   80103da2 <end_op>

  f->type = FD_INODE;
80106c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c36:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c42:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c48:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c52:	83 e0 01             	and    $0x1,%eax
80106c55:	85 c0                	test   %eax,%eax
80106c57:	0f 94 c2             	sete   %dl
80106c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c5d:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c63:	83 e0 01             	and    $0x1,%eax
80106c66:	84 c0                	test   %al,%al
80106c68:	75 0a                	jne    80106c74 <sys_open+0x181>
80106c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c6d:	83 e0 02             	and    $0x2,%eax
80106c70:	85 c0                	test   %eax,%eax
80106c72:	74 07                	je     80106c7b <sys_open+0x188>
80106c74:	b8 01 00 00 00       	mov    $0x1,%eax
80106c79:	eb 05                	jmp    80106c80 <sys_open+0x18d>
80106c7b:	b8 00 00 00 00       	mov    $0x0,%eax
80106c80:	89 c2                	mov    %eax,%edx
80106c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c85:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106c88:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106c8b:	c9                   	leave  
80106c8c:	c3                   	ret    

80106c8d <sys_mkdir>:

int
sys_mkdir(void)
{
80106c8d:	55                   	push   %ebp
80106c8e:	89 e5                	mov    %esp,%ebp
80106c90:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106c93:	e8 89 d0 ff ff       	call   80103d21 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106c98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ca6:	e8 3b f5 ff ff       	call   801061e6 <argstr>
80106cab:	85 c0                	test   %eax,%eax
80106cad:	78 2c                	js     80106cdb <sys_mkdir+0x4e>
80106caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cb2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106cb9:	00 
80106cba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106cc1:	00 
80106cc2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106cc9:	00 
80106cca:	89 04 24             	mov    %eax,(%esp)
80106ccd:	e8 61 fc ff ff       	call   80106933 <create>
80106cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cd5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cd9:	75 0c                	jne    80106ce7 <sys_mkdir+0x5a>
    end_op();
80106cdb:	e8 c2 d0 ff ff       	call   80103da2 <end_op>
    return -1;
80106ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce5:	eb 15                	jmp    80106cfc <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cea:	89 04 24             	mov    %eax,(%esp)
80106ced:	e8 9d b6 ff ff       	call   8010238f <iunlockput>
  end_op();
80106cf2:	e8 ab d0 ff ff       	call   80103da2 <end_op>
  return 0;
80106cf7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cfc:	c9                   	leave  
80106cfd:	c3                   	ret    

80106cfe <sys_mknod>:

int
sys_mknod(void)
{
80106cfe:	55                   	push   %ebp
80106cff:	89 e5                	mov    %esp,%ebp
80106d01:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106d04:	e8 18 d0 ff ff       	call   80103d21 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106d09:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d17:	e8 ca f4 ff ff       	call   801061e6 <argstr>
80106d1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d23:	78 5e                	js     80106d83 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106d25:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d28:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d33:	e8 1e f4 ff ff       	call   80106156 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106d38:	85 c0                	test   %eax,%eax
80106d3a:	78 47                	js     80106d83 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d3c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d43:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106d4a:	e8 07 f4 ff ff       	call   80106156 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106d4f:	85 c0                	test   %eax,%eax
80106d51:	78 30                	js     80106d83 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d56:	0f bf c8             	movswl %ax,%ecx
80106d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d5c:	0f bf d0             	movswl %ax,%edx
80106d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d66:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d6a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106d71:	00 
80106d72:	89 04 24             	mov    %eax,(%esp)
80106d75:	e8 b9 fb ff ff       	call   80106933 <create>
80106d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d81:	75 0c                	jne    80106d8f <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d83:	e8 1a d0 ff ff       	call   80103da2 <end_op>
    return -1;
80106d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d8d:	eb 15                	jmp    80106da4 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d92:	89 04 24             	mov    %eax,(%esp)
80106d95:	e8 f5 b5 ff ff       	call   8010238f <iunlockput>
  end_op();
80106d9a:	e8 03 d0 ff ff       	call   80103da2 <end_op>
  return 0;
80106d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106da4:	c9                   	leave  
80106da5:	c3                   	ret    

80106da6 <sys_chdir>:

int
sys_chdir(void)
{
80106da6:	55                   	push   %ebp
80106da7:	89 e5                	mov    %esp,%ebp
80106da9:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106dac:	e8 70 cf ff ff       	call   80103d21 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106db1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106db4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106db8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dbf:	e8 22 f4 ff ff       	call   801061e6 <argstr>
80106dc4:	85 c0                	test   %eax,%eax
80106dc6:	78 14                	js     80106ddc <sys_chdir+0x36>
80106dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dcb:	89 04 24             	mov    %eax,(%esp)
80106dce:	e8 da be ff ff       	call   80102cad <namei>
80106dd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106dd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106dda:	75 0c                	jne    80106de8 <sys_chdir+0x42>
    end_op();
80106ddc:	e8 c1 cf ff ff       	call   80103da2 <end_op>
    return -1;
80106de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106de6:	eb 61                	jmp    80106e49 <sys_chdir+0xa3>
  }
  ilock(ip);
80106de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106deb:	89 04 24             	mov    %eax,(%esp)
80106dee:	e8 12 b3 ff ff       	call   80102105 <ilock>
  if(ip->type != T_DIR){
80106df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106dfa:	66 83 f8 01          	cmp    $0x1,%ax
80106dfe:	74 17                	je     80106e17 <sys_chdir+0x71>
    iunlockput(ip);
80106e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e03:	89 04 24             	mov    %eax,(%esp)
80106e06:	e8 84 b5 ff ff       	call   8010238f <iunlockput>
    end_op();
80106e0b:	e8 92 cf ff ff       	call   80103da2 <end_op>
    return -1;
80106e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e15:	eb 32                	jmp    80106e49 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e1a:	89 04 24             	mov    %eax,(%esp)
80106e1d:	e8 37 b4 ff ff       	call   80102259 <iunlock>
  iput(proc->cwd);
80106e22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e28:	8b 40 68             	mov    0x68(%eax),%eax
80106e2b:	89 04 24             	mov    %eax,(%esp)
80106e2e:	e8 8b b4 ff ff       	call   801022be <iput>
  end_op();
80106e33:	e8 6a cf ff ff       	call   80103da2 <end_op>
  proc->cwd = ip;
80106e38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e41:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e49:	c9                   	leave  
80106e4a:	c3                   	ret    

80106e4b <sys_exec>:

int
sys_exec(void)
{
80106e4b:	55                   	push   %ebp
80106e4c:	89 e5                	mov    %esp,%ebp
80106e4e:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106e54:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e57:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e62:	e8 7f f3 ff ff       	call   801061e6 <argstr>
80106e67:	85 c0                	test   %eax,%eax
80106e69:	78 1a                	js     80106e85 <sys_exec+0x3a>
80106e6b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e71:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e7c:	e8 d5 f2 ff ff       	call   80106156 <argint>
80106e81:	85 c0                	test   %eax,%eax
80106e83:	79 0a                	jns    80106e8f <sys_exec+0x44>
    return -1;
80106e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8a:	e9 cc 00 00 00       	jmp    80106f5b <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80106e8f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106e96:	00 
80106e97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e9e:	00 
80106e9f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ea5:	89 04 24             	mov    %eax,(%esp)
80106ea8:	e8 4d ef ff ff       	call   80105dfa <memset>
  for(i=0;; i++){
80106ead:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb7:	83 f8 1f             	cmp    $0x1f,%eax
80106eba:	76 0a                	jbe    80106ec6 <sys_exec+0x7b>
      return -1;
80106ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ec1:	e9 95 00 00 00       	jmp    80106f5b <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec9:	c1 e0 02             	shl    $0x2,%eax
80106ecc:	89 c2                	mov    %eax,%edx
80106ece:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ed4:	01 c2                	add    %eax,%edx
80106ed6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106edc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ee0:	89 14 24             	mov    %edx,(%esp)
80106ee3:	e8 d0 f1 ff ff       	call   801060b8 <fetchint>
80106ee8:	85 c0                	test   %eax,%eax
80106eea:	79 07                	jns    80106ef3 <sys_exec+0xa8>
      return -1;
80106eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef1:	eb 68                	jmp    80106f5b <sys_exec+0x110>
    if(uarg == 0){
80106ef3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ef9:	85 c0                	test   %eax,%eax
80106efb:	75 26                	jne    80106f23 <sys_exec+0xd8>
      argv[i] = 0;
80106efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f00:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106f07:	00 00 00 00 
      break;
80106f0b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f0f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f15:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f19:	89 04 24             	mov    %eax,(%esp)
80106f1c:	e8 fb a3 ff ff       	call   8010131c <exec>
80106f21:	eb 38                	jmp    80106f5b <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106f2d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f33:	01 c2                	add    %eax,%edx
80106f35:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f3b:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f3f:	89 04 24             	mov    %eax,(%esp)
80106f42:	e8 ab f1 ff ff       	call   801060f2 <fetchstr>
80106f47:	85 c0                	test   %eax,%eax
80106f49:	79 07                	jns    80106f52 <sys_exec+0x107>
      return -1;
80106f4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f50:	eb 09                	jmp    80106f5b <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f52:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f56:	e9 59 ff ff ff       	jmp    80106eb4 <sys_exec+0x69>
  return exec(path, argv);
}
80106f5b:	c9                   	leave  
80106f5c:	c3                   	ret    

80106f5d <sys_pipe>:

int
sys_pipe(void)
{
80106f5d:	55                   	push   %ebp
80106f5e:	89 e5                	mov    %esp,%ebp
80106f60:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106f63:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106f6a:	00 
80106f6b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f79:	e8 06 f2 ff ff       	call   80106184 <argptr>
80106f7e:	85 c0                	test   %eax,%eax
80106f80:	79 0a                	jns    80106f8c <sys_pipe+0x2f>
    return -1;
80106f82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f87:	e9 9b 00 00 00       	jmp    80107027 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106f8c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f93:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f96:	89 04 24             	mov    %eax,(%esp)
80106f99:	e8 ae d8 ff ff       	call   8010484c <pipealloc>
80106f9e:	85 c0                	test   %eax,%eax
80106fa0:	79 07                	jns    80106fa9 <sys_pipe+0x4c>
    return -1;
80106fa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa7:	eb 7e                	jmp    80107027 <sys_pipe+0xca>
  fd0 = -1;
80106fa9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106fb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fb3:	89 04 24             	mov    %eax,(%esp)
80106fb6:	e8 66 f3 ff ff       	call   80106321 <fdalloc>
80106fbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fc2:	78 14                	js     80106fd8 <sys_pipe+0x7b>
80106fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fc7:	89 04 24             	mov    %eax,(%esp)
80106fca:	e8 52 f3 ff ff       	call   80106321 <fdalloc>
80106fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106fd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106fd6:	79 37                	jns    8010700f <sys_pipe+0xb2>
    if(fd0 >= 0)
80106fd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fdc:	78 14                	js     80106ff2 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106fde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fe4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fe7:	83 c2 08             	add    $0x8,%edx
80106fea:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106ff1:	00 
    fileclose(rf);
80106ff2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ff5:	89 04 24             	mov    %eax,(%esp)
80106ff8:	e8 03 a8 ff ff       	call   80101800 <fileclose>
    fileclose(wf);
80106ffd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107000:	89 04 24             	mov    %eax,(%esp)
80107003:	e8 f8 a7 ff ff       	call   80101800 <fileclose>
    return -1;
80107008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010700d:	eb 18                	jmp    80107027 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010700f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107012:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107015:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107017:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010701a:	8d 50 04             	lea    0x4(%eax),%edx
8010701d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107020:	89 02                	mov    %eax,(%edx)
  return 0;
80107022:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107027:	c9                   	leave  
80107028:	c3                   	ret    
80107029:	00 00                	add    %al,(%eax)
	...

8010702c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010702c:	55                   	push   %ebp
8010702d:	89 e5                	mov    %esp,%ebp
8010702f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107032:	e8 d8 de ff ff       	call   80104f0f <fork>
}
80107037:	c9                   	leave  
80107038:	c3                   	ret    

80107039 <sys_exit>:

int
sys_exit(void)
{
80107039:	55                   	push   %ebp
8010703a:	89 e5                	mov    %esp,%ebp
8010703c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010703f:	e8 82 e0 ff ff       	call   801050c6 <exit>
  return 0;  // not reached
80107044:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107049:	c9                   	leave  
8010704a:	c3                   	ret    

8010704b <sys_wait>:

int
sys_wait(void)
{
8010704b:	55                   	push   %ebp
8010704c:	89 e5                	mov    %esp,%ebp
8010704e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107051:	e8 95 e1 ff ff       	call   801051eb <wait>
}
80107056:	c9                   	leave  
80107057:	c3                   	ret    

80107058 <sys_kill>:

int
sys_kill(void)
{
80107058:	55                   	push   %ebp
80107059:	89 e5                	mov    %esp,%ebp
8010705b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010705e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107061:	89 44 24 04          	mov    %eax,0x4(%esp)
80107065:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010706c:	e8 e5 f0 ff ff       	call   80106156 <argint>
80107071:	85 c0                	test   %eax,%eax
80107073:	79 07                	jns    8010707c <sys_kill+0x24>
    return -1;
80107075:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010707a:	eb 0b                	jmp    80107087 <sys_kill+0x2f>
  return kill(pid);
8010707c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707f:	89 04 24             	mov    %eax,(%esp)
80107082:	e8 4c e7 ff ff       	call   801057d3 <kill>
}
80107087:	c9                   	leave  
80107088:	c3                   	ret    

80107089 <sys_getpid>:

int
sys_getpid(void)
{
80107089:	55                   	push   %ebp
8010708a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010708c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107092:	8b 40 10             	mov    0x10(%eax),%eax
}
80107095:	5d                   	pop    %ebp
80107096:	c3                   	ret    

80107097 <sys_sbrk>:

int
sys_sbrk(void)
{
80107097:	55                   	push   %ebp
80107098:	89 e5                	mov    %esp,%ebp
8010709a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010709d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801070a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070ab:	e8 a6 f0 ff ff       	call   80106156 <argint>
801070b0:	85 c0                	test   %eax,%eax
801070b2:	79 07                	jns    801070bb <sys_sbrk+0x24>
    return -1;
801070b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b9:	eb 24                	jmp    801070df <sys_sbrk+0x48>
  addr = proc->sz;
801070bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070c1:	8b 00                	mov    (%eax),%eax
801070c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801070c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070c9:	89 04 24             	mov    %eax,(%esp)
801070cc:	e8 99 dd ff ff       	call   80104e6a <growproc>
801070d1:	85 c0                	test   %eax,%eax
801070d3:	79 07                	jns    801070dc <sys_sbrk+0x45>
    return -1;
801070d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070da:	eb 03                	jmp    801070df <sys_sbrk+0x48>
  return addr;
801070dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070df:	c9                   	leave  
801070e0:	c3                   	ret    

801070e1 <sys_sleep>:

int
sys_sleep(void)
{
801070e1:	55                   	push   %ebp
801070e2:	89 e5                	mov    %esp,%ebp
801070e4:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801070e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801070ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070f5:	e8 5c f0 ff ff       	call   80106156 <argint>
801070fa:	85 c0                	test   %eax,%eax
801070fc:	79 07                	jns    80107105 <sys_sleep+0x24>
    return -1;
801070fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107103:	eb 6c                	jmp    80107171 <sys_sleep+0x90>
  acquire(&tickslock);
80107105:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
8010710c:	e8 9a ea ff ff       	call   80105bab <acquire>
  ticks0 = ticks;
80107111:	a1 20 6e 11 80       	mov    0x80116e20,%eax
80107116:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107119:	eb 34                	jmp    8010714f <sys_sleep+0x6e>
    if(proc->killed){
8010711b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107121:	8b 40 24             	mov    0x24(%eax),%eax
80107124:	85 c0                	test   %eax,%eax
80107126:	74 13                	je     8010713b <sys_sleep+0x5a>
      release(&tickslock);
80107128:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
8010712f:	e8 d9 ea ff ff       	call   80105c0d <release>
      return -1;
80107134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107139:	eb 36                	jmp    80107171 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010713b:	c7 44 24 04 e0 65 11 	movl   $0x801165e0,0x4(%esp)
80107142:	80 
80107143:	c7 04 24 20 6e 11 80 	movl   $0x80116e20,(%esp)
8010714a:	e8 70 e5 ff ff       	call   801056bf <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010714f:	a1 20 6e 11 80       	mov    0x80116e20,%eax
80107154:	89 c2                	mov    %eax,%edx
80107156:	2b 55 f4             	sub    -0xc(%ebp),%edx
80107159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010715c:	39 c2                	cmp    %eax,%edx
8010715e:	72 bb                	jb     8010711b <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107160:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107167:	e8 a1 ea ff ff       	call   80105c0d <release>
  return 0;
8010716c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107171:	c9                   	leave  
80107172:	c3                   	ret    

80107173 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107173:	55                   	push   %ebp
80107174:	89 e5                	mov    %esp,%ebp
80107176:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80107179:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107180:	e8 26 ea ff ff       	call   80105bab <acquire>
  xticks = ticks;
80107185:	a1 20 6e 11 80       	mov    0x80116e20,%eax
8010718a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010718d:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107194:	e8 74 ea ff ff       	call   80105c0d <release>
  return xticks;
80107199:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010719c:	c9                   	leave  
8010719d:	c3                   	ret    

8010719e <sys_wait2>:

int
sys_wait2(void)
{
8010719e:	55                   	push   %ebp
8010719f:	89 e5                	mov    %esp,%ebp
801071a1:	83 ec 28             	sub    $0x28,%esp
  int retime;
  int rutime;
  int stime;
  if(argint(0,&retime) < 0)
801071a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801071ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071b2:	e8 9f ef ff ff       	call   80106156 <argint>
801071b7:	85 c0                	test   %eax,%eax
801071b9:	79 07                	jns    801071c2 <sys_wait2+0x24>
    return -1;
801071bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c0:	eb 59                	jmp    8010721b <sys_wait2+0x7d>
  if(argint(1,&rutime) < 0)
801071c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801071c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801071d0:	e8 81 ef ff ff       	call   80106156 <argint>
801071d5:	85 c0                	test   %eax,%eax
801071d7:	79 07                	jns    801071e0 <sys_wait2+0x42>
    return -1;
801071d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071de:	eb 3b                	jmp    8010721b <sys_wait2+0x7d>
  if(argint(2,&stime) < 0)
801071e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801071e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801071e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801071ee:	e8 63 ef ff ff       	call   80106156 <argint>
801071f3:	85 c0                	test   %eax,%eax
801071f5:	79 07                	jns    801071fe <sys_wait2+0x60>
    return -1;
801071f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071fc:	eb 1d                	jmp    8010721b <sys_wait2+0x7d>
  return wait2((int*)retime, (int*)rutime, (int*)stime);
801071fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107201:	89 c1                	mov    %eax,%ecx
80107203:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107206:	89 c2                	mov    %eax,%edx
80107208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010720f:	89 54 24 04          	mov    %edx,0x4(%esp)
80107213:	89 04 24             	mov    %eax,(%esp)
80107216:	e8 b0 e7 ff ff       	call   801059cb <wait2>
}
8010721b:	c9                   	leave  
8010721c:	c3                   	ret    

8010721d <sys_set_prio>:


int
sys_set_prio(void)
{
8010721d:	55                   	push   %ebp
8010721e:	89 e5                	mov    %esp,%ebp
80107220:	83 ec 28             	sub    $0x28,%esp
  int priority;
  if (argint(0,&priority) <0)
80107223:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010722a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107231:	e8 20 ef ff ff       	call   80106156 <argint>
80107236:	85 c0                	test   %eax,%eax
80107238:	79 07                	jns    80107241 <sys_set_prio+0x24>
    return -1;
8010723a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010723f:	eb 0b                	jmp    8010724c <sys_set_prio+0x2f>
  return set_prio(priority);
80107241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107244:	89 04 24             	mov    %eax,(%esp)
80107247:	e8 ec e8 ff ff       	call   80105b38 <set_prio>
}
8010724c:	c9                   	leave  
8010724d:	c3                   	ret    

8010724e <sys_yield>:

int
sys_yield(void)
{
8010724e:	55                   	push   %ebp
8010724f:	89 e5                	mov    %esp,%ebp
80107251:	83 ec 08             	sub    $0x8,%esp
  yield();
80107254:	e8 f5 e3 ff ff       	call   8010564e <yield>
  return 0;
80107259:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010725e:	c9                   	leave  
8010725f:	c3                   	ret    

80107260 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107260:	55                   	push   %ebp
80107261:	89 e5                	mov    %esp,%ebp
80107263:	83 ec 08             	sub    $0x8,%esp
80107266:	8b 55 08             	mov    0x8(%ebp),%edx
80107269:	8b 45 0c             	mov    0xc(%ebp),%eax
8010726c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107270:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107273:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107277:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010727b:	ee                   	out    %al,(%dx)
}
8010727c:	c9                   	leave  
8010727d:	c3                   	ret    

8010727e <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010727e:	55                   	push   %ebp
8010727f:	89 e5                	mov    %esp,%ebp
80107281:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107284:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010728b:	00 
8010728c:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80107293:	e8 c8 ff ff ff       	call   80107260 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107298:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010729f:	00 
801072a0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801072a7:	e8 b4 ff ff ff       	call   80107260 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801072ac:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801072b3:	00 
801072b4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801072bb:	e8 a0 ff ff ff       	call   80107260 <outb>
  picenable(IRQ_TIMER);
801072c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801072c7:	e8 09 d4 ff ff       	call   801046d5 <picenable>
}
801072cc:	c9                   	leave  
801072cd:	c3                   	ret    
	...

801072d0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801072d0:	1e                   	push   %ds
  pushl %es
801072d1:	06                   	push   %es
  pushl %fs
801072d2:	0f a0                	push   %fs
  pushl %gs
801072d4:	0f a8                	push   %gs
  pushal
801072d6:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801072d7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801072db:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801072dd:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801072df:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801072e3:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801072e5:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801072e7:	54                   	push   %esp
  call trap
801072e8:	e8 de 01 00 00       	call   801074cb <trap>
  addl $4, %esp
801072ed:	83 c4 04             	add    $0x4,%esp

801072f0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801072f0:	61                   	popa   
  popl %gs
801072f1:	0f a9                	pop    %gs
  popl %fs
801072f3:	0f a1                	pop    %fs
  popl %es
801072f5:	07                   	pop    %es
  popl %ds
801072f6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801072f7:	83 c4 08             	add    $0x8,%esp
  iret
801072fa:	cf                   	iret   
	...

801072fc <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801072fc:	55                   	push   %ebp
801072fd:	89 e5                	mov    %esp,%ebp
801072ff:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107302:	8b 45 0c             	mov    0xc(%ebp),%eax
80107305:	83 e8 01             	sub    $0x1,%eax
80107308:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010730c:	8b 45 08             	mov    0x8(%ebp),%eax
8010730f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107313:	8b 45 08             	mov    0x8(%ebp),%eax
80107316:	c1 e8 10             	shr    $0x10,%eax
80107319:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010731d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107320:	0f 01 18             	lidtl  (%eax)
}
80107323:	c9                   	leave  
80107324:	c3                   	ret    

80107325 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107325:	55                   	push   %ebp
80107326:	89 e5                	mov    %esp,%ebp
80107328:	53                   	push   %ebx
80107329:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010732c:	0f 20 d3             	mov    %cr2,%ebx
8010732f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80107332:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80107335:	83 c4 10             	add    $0x10,%esp
80107338:	5b                   	pop    %ebx
80107339:	5d                   	pop    %ebp
8010733a:	c3                   	ret    

8010733b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010733b:	55                   	push   %ebp
8010733c:	89 e5                	mov    %esp,%ebp
8010733e:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107341:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107348:	e9 c3 00 00 00       	jmp    80107410 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010734d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107350:	8b 04 85 a4 c0 10 80 	mov    -0x7fef3f5c(,%eax,4),%eax
80107357:	89 c2                	mov    %eax,%edx
80107359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735c:	66 89 14 c5 20 66 11 	mov    %dx,-0x7fee99e0(,%eax,8)
80107363:	80 
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	66 c7 04 c5 22 66 11 	movw   $0x8,-0x7fee99de(,%eax,8)
8010736e:	80 08 00 
80107371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107374:	0f b6 14 c5 24 66 11 	movzbl -0x7fee99dc(,%eax,8),%edx
8010737b:	80 
8010737c:	83 e2 e0             	and    $0xffffffe0,%edx
8010737f:	88 14 c5 24 66 11 80 	mov    %dl,-0x7fee99dc(,%eax,8)
80107386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107389:	0f b6 14 c5 24 66 11 	movzbl -0x7fee99dc(,%eax,8),%edx
80107390:	80 
80107391:	83 e2 1f             	and    $0x1f,%edx
80107394:	88 14 c5 24 66 11 80 	mov    %dl,-0x7fee99dc(,%eax,8)
8010739b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739e:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801073a5:	80 
801073a6:	83 e2 f0             	and    $0xfffffff0,%edx
801073a9:	83 ca 0e             	or     $0xe,%edx
801073ac:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801073b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b6:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801073bd:	80 
801073be:	83 e2 ef             	and    $0xffffffef,%edx
801073c1:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801073c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cb:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801073d2:	80 
801073d3:	83 e2 9f             	and    $0xffffff9f,%edx
801073d6:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801073dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e0:	0f b6 14 c5 25 66 11 	movzbl -0x7fee99db(,%eax,8),%edx
801073e7:	80 
801073e8:	83 ca 80             	or     $0xffffff80,%edx
801073eb:	88 14 c5 25 66 11 80 	mov    %dl,-0x7fee99db(,%eax,8)
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	8b 04 85 a4 c0 10 80 	mov    -0x7fef3f5c(,%eax,4),%eax
801073fc:	c1 e8 10             	shr    $0x10,%eax
801073ff:	89 c2                	mov    %eax,%edx
80107401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107404:	66 89 14 c5 26 66 11 	mov    %dx,-0x7fee99da(,%eax,8)
8010740b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010740c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107410:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107417:	0f 8e 30 ff ff ff    	jle    8010734d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010741d:	a1 a4 c1 10 80       	mov    0x8010c1a4,%eax
80107422:	66 a3 20 68 11 80    	mov    %ax,0x80116820
80107428:	66 c7 05 22 68 11 80 	movw   $0x8,0x80116822
8010742f:	08 00 
80107431:	0f b6 05 24 68 11 80 	movzbl 0x80116824,%eax
80107438:	83 e0 e0             	and    $0xffffffe0,%eax
8010743b:	a2 24 68 11 80       	mov    %al,0x80116824
80107440:	0f b6 05 24 68 11 80 	movzbl 0x80116824,%eax
80107447:	83 e0 1f             	and    $0x1f,%eax
8010744a:	a2 24 68 11 80       	mov    %al,0x80116824
8010744f:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107456:	83 c8 0f             	or     $0xf,%eax
80107459:	a2 25 68 11 80       	mov    %al,0x80116825
8010745e:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107465:	83 e0 ef             	and    $0xffffffef,%eax
80107468:	a2 25 68 11 80       	mov    %al,0x80116825
8010746d:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107474:	83 c8 60             	or     $0x60,%eax
80107477:	a2 25 68 11 80       	mov    %al,0x80116825
8010747c:	0f b6 05 25 68 11 80 	movzbl 0x80116825,%eax
80107483:	83 c8 80             	or     $0xffffff80,%eax
80107486:	a2 25 68 11 80       	mov    %al,0x80116825
8010748b:	a1 a4 c1 10 80       	mov    0x8010c1a4,%eax
80107490:	c1 e8 10             	shr    $0x10,%eax
80107493:	66 a3 26 68 11 80    	mov    %ax,0x80116826

  initlock(&tickslock, "time");
80107499:	c7 44 24 04 78 97 10 	movl   $0x80109778,0x4(%esp)
801074a0:	80 
801074a1:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
801074a8:	e8 dd e6 ff ff       	call   80105b8a <initlock>
}
801074ad:	c9                   	leave  
801074ae:	c3                   	ret    

801074af <idtinit>:

void
idtinit(void)
{
801074af:	55                   	push   %ebp
801074b0:	89 e5                	mov    %esp,%ebp
801074b2:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801074b5:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801074bc:	00 
801074bd:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
801074c4:	e8 33 fe ff ff       	call   801072fc <lidt>
}
801074c9:	c9                   	leave  
801074ca:	c3                   	ret    

801074cb <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801074cb:	55                   	push   %ebp
801074cc:	89 e5                	mov    %esp,%ebp
801074ce:	57                   	push   %edi
801074cf:	56                   	push   %esi
801074d0:	53                   	push   %ebx
801074d1:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801074d4:	8b 45 08             	mov    0x8(%ebp),%eax
801074d7:	8b 40 30             	mov    0x30(%eax),%eax
801074da:	83 f8 40             	cmp    $0x40,%eax
801074dd:	75 3e                	jne    8010751d <trap+0x52>
    if(proc->killed)
801074df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074e5:	8b 40 24             	mov    0x24(%eax),%eax
801074e8:	85 c0                	test   %eax,%eax
801074ea:	74 05                	je     801074f1 <trap+0x26>
      exit();
801074ec:	e8 d5 db ff ff       	call   801050c6 <exit>
    proc->tf = tf;
801074f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074f7:	8b 55 08             	mov    0x8(%ebp),%edx
801074fa:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801074fd:	e8 1b ed ff ff       	call   8010621d <syscall>
    if(proc->killed)
80107502:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107508:	8b 40 24             	mov    0x24(%eax),%eax
8010750b:	85 c0                	test   %eax,%eax
8010750d:	0f 84 8e 02 00 00    	je     801077a1 <trap+0x2d6>
      exit();
80107513:	e8 ae db ff ff       	call   801050c6 <exit>
    return;
80107518:	e9 84 02 00 00       	jmp    801077a1 <trap+0x2d6>
  }

  switch(tf->trapno){
8010751d:	8b 45 08             	mov    0x8(%ebp),%eax
80107520:	8b 40 30             	mov    0x30(%eax),%eax
80107523:	83 e8 20             	sub    $0x20,%eax
80107526:	83 f8 1f             	cmp    $0x1f,%eax
80107529:	0f 87 c1 00 00 00    	ja     801075f0 <trap+0x125>
8010752f:	8b 04 85 20 98 10 80 	mov    -0x7fef67e0(,%eax,4),%eax
80107536:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107538:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010753e:	0f b6 00             	movzbl (%eax),%eax
80107541:	84 c0                	test   %al,%al
80107543:	75 36                	jne    8010757b <trap+0xb0>
      acquire(&tickslock);
80107545:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
8010754c:	e8 5a e6 ff ff       	call   80105bab <acquire>
      ticks++;
80107551:	a1 20 6e 11 80       	mov    0x80116e20,%eax
80107556:	83 c0 01             	add    $0x1,%eax
80107559:	a3 20 6e 11 80       	mov    %eax,0x80116e20
      updateTimes(); // after every tick - updates the times
8010755e:	e8 e7 e3 ff ff       	call   8010594a <updateTimes>
      wakeup(&ticks);
80107563:	c7 04 24 20 6e 11 80 	movl   $0x80116e20,(%esp)
8010756a:	e8 39 e2 ff ff       	call   801057a8 <wakeup>
      release(&tickslock);
8010756f:	c7 04 24 e0 65 11 80 	movl   $0x801165e0,(%esp)
80107576:	e8 92 e6 ff ff       	call   80105c0d <release>
    }
    lapiceoi();
8010757b:	e8 6b c2 ff ff       	call   801037eb <lapiceoi>
    break;
80107580:	e9 41 01 00 00       	jmp    801076c6 <trap+0x1fb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107585:	e8 42 ba ff ff       	call   80102fcc <ideintr>
    lapiceoi();
8010758a:	e8 5c c2 ff ff       	call   801037eb <lapiceoi>
    break;
8010758f:	e9 32 01 00 00       	jmp    801076c6 <trap+0x1fb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107594:	e8 06 c0 ff ff       	call   8010359f <kbdintr>
    lapiceoi();
80107599:	e8 4d c2 ff ff       	call   801037eb <lapiceoi>
    break;
8010759e:	e9 23 01 00 00       	jmp    801076c6 <trap+0x1fb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075a3:	e8 00 04 00 00       	call   801079a8 <uartintr>
    lapiceoi();
801075a8:	e8 3e c2 ff ff       	call   801037eb <lapiceoi>
    break;
801075ad:	e9 14 01 00 00       	jmp    801076c6 <trap+0x1fb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
801075b2:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075b5:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801075b8:	8b 45 08             	mov    0x8(%ebp),%eax
801075bb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075bf:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801075c2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075c8:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075cb:	0f b6 c0             	movzbl %al,%eax
801075ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801075d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801075d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801075da:	c7 04 24 80 97 10 80 	movl   $0x80109780,(%esp)
801075e1:	e8 bb 8d ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801075e6:	e8 00 c2 ff ff       	call   801037eb <lapiceoi>
    break;
801075eb:	e9 d6 00 00 00       	jmp    801076c6 <trap+0x1fb>

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801075f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f6:	85 c0                	test   %eax,%eax
801075f8:	74 11                	je     8010760b <trap+0x140>
801075fa:	8b 45 08             	mov    0x8(%ebp),%eax
801075fd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107601:	0f b7 c0             	movzwl %ax,%eax
80107604:	83 e0 03             	and    $0x3,%eax
80107607:	85 c0                	test   %eax,%eax
80107609:	75 46                	jne    80107651 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010760b:	e8 15 fd ff ff       	call   80107325 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80107610:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107613:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107616:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010761d:	0f b6 12             	movzbl (%edx),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107620:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107623:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107626:	8b 52 30             	mov    0x30(%edx),%edx
80107629:	89 44 24 10          	mov    %eax,0x10(%esp)
8010762d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107631:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107635:	89 54 24 04          	mov    %edx,0x4(%esp)
80107639:	c7 04 24 a4 97 10 80 	movl   $0x801097a4,(%esp)
80107640:	e8 5c 8d ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107645:	c7 04 24 d6 97 10 80 	movl   $0x801097d6,(%esp)
8010764c:	e8 ec 8e ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107651:	e8 cf fc ff ff       	call   80107325 <rcr2>
80107656:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107658:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010765b:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010765e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107664:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107667:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010766a:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010766d:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107670:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107673:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107676:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010767c:	83 c0 6c             	add    $0x6c,%eax
8010767f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107682:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107688:	8b 40 10             	mov    0x10(%eax),%eax
8010768b:	89 54 24 1c          	mov    %edx,0x1c(%esp)
8010768f:	89 7c 24 18          	mov    %edi,0x18(%esp)
80107693:	89 74 24 14          	mov    %esi,0x14(%esp)
80107697:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010769b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010769f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076a2:	89 54 24 08          	mov    %edx,0x8(%esp)
801076a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801076aa:	c7 04 24 dc 97 10 80 	movl   $0x801097dc,(%esp)
801076b1:	e8 eb 8c ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
801076b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076bc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801076c3:	eb 01                	jmp    801076c6 <trap+0x1fb>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801076c5:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801076c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076cc:	85 c0                	test   %eax,%eax
801076ce:	74 24                	je     801076f4 <trap+0x229>
801076d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076d6:	8b 40 24             	mov    0x24(%eax),%eax
801076d9:	85 c0                	test   %eax,%eax
801076db:	74 17                	je     801076f4 <trap+0x229>
801076dd:	8b 45 08             	mov    0x8(%ebp),%eax
801076e0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801076e4:	0f b7 c0             	movzwl %ax,%eax
801076e7:	83 e0 03             	and    $0x3,%eax
801076ea:	83 f8 03             	cmp    $0x3,%eax
801076ed:	75 05                	jne    801076f4 <trap+0x229>
    exit();
801076ef:	e8 d2 d9 ff ff       	call   801050c6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && ticks%QUANTA==0){
801076f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076fa:	85 c0                	test   %eax,%eax
801076fc:	74 73                	je     80107771 <trap+0x2a6>
801076fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107704:	8b 40 0c             	mov    0xc(%eax),%eax
80107707:	83 f8 04             	cmp    $0x4,%eax
8010770a:	75 65                	jne    80107771 <trap+0x2a6>
8010770c:	8b 45 08             	mov    0x8(%ebp),%eax
8010770f:	8b 40 30             	mov    0x30(%eax),%eax
80107712:	83 f8 20             	cmp    $0x20,%eax
80107715:	75 5a                	jne    80107771 <trap+0x2a6>
80107717:	8b 0d 20 6e 11 80    	mov    0x80116e20,%ecx
8010771d:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107722:	89 c8                	mov    %ecx,%eax
80107724:	f7 e2                	mul    %edx
80107726:	c1 ea 02             	shr    $0x2,%edx
80107729:	89 d0                	mov    %edx,%eax
8010772b:	c1 e0 02             	shl    $0x2,%eax
8010772e:	01 d0                	add    %edx,%eax
80107730:	89 ca                	mov    %ecx,%edx
80107732:	29 c2                	sub    %eax,%edx
80107734:	85 d2                	test   %edx,%edx
80107736:	75 39                	jne    80107771 <trap+0x2a6>
  #if SCHEDFLAG == DML
  proc->priority=(proc->priority==MIN_PRIORITY)? MIN_PRIORITY : proc->priority-1;
80107738:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010773f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107745:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010774b:	83 f8 01             	cmp    $0x1,%eax
8010774e:	74 11                	je     80107761 <trap+0x296>
80107750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107756:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010775c:	83 e8 01             	sub    $0x1,%eax
8010775f:	eb 05                	jmp    80107766 <trap+0x29b>
80107761:	b8 01 00 00 00       	mov    $0x1,%eax
80107766:	89 82 8c 00 00 00    	mov    %eax,0x8c(%edx)
  #endif
  yield();
8010776c:	e8 dd de ff ff       	call   8010564e <yield>
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107771:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107777:	85 c0                	test   %eax,%eax
80107779:	74 27                	je     801077a2 <trap+0x2d7>
8010777b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107781:	8b 40 24             	mov    0x24(%eax),%eax
80107784:	85 c0                	test   %eax,%eax
80107786:	74 1a                	je     801077a2 <trap+0x2d7>
80107788:	8b 45 08             	mov    0x8(%ebp),%eax
8010778b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010778f:	0f b7 c0             	movzwl %ax,%eax
80107792:	83 e0 03             	and    $0x3,%eax
80107795:	83 f8 03             	cmp    $0x3,%eax
80107798:	75 08                	jne    801077a2 <trap+0x2d7>
    exit();
8010779a:	e8 27 d9 ff ff       	call   801050c6 <exit>
8010779f:	eb 01                	jmp    801077a2 <trap+0x2d7>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801077a1:	90                   	nop
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801077a2:	83 c4 3c             	add    $0x3c,%esp
801077a5:	5b                   	pop    %ebx
801077a6:	5e                   	pop    %esi
801077a7:	5f                   	pop    %edi
801077a8:	5d                   	pop    %ebp
801077a9:	c3                   	ret    
	...

801077ac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801077ac:	55                   	push   %ebp
801077ad:	89 e5                	mov    %esp,%ebp
801077af:	53                   	push   %ebx
801077b0:	83 ec 14             	sub    $0x14,%esp
801077b3:	8b 45 08             	mov    0x8(%ebp),%eax
801077b6:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801077ba:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801077be:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801077c2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801077c6:	ec                   	in     (%dx),%al
801077c7:	89 c3                	mov    %eax,%ebx
801077c9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801077cc:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801077d0:	83 c4 14             	add    $0x14,%esp
801077d3:	5b                   	pop    %ebx
801077d4:	5d                   	pop    %ebp
801077d5:	c3                   	ret    

801077d6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801077d6:	55                   	push   %ebp
801077d7:	89 e5                	mov    %esp,%ebp
801077d9:	83 ec 08             	sub    $0x8,%esp
801077dc:	8b 55 08             	mov    0x8(%ebp),%edx
801077df:	8b 45 0c             	mov    0xc(%ebp),%eax
801077e2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801077e6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801077e9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801077ed:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801077f1:	ee                   	out    %al,(%dx)
}
801077f2:	c9                   	leave  
801077f3:	c3                   	ret    

801077f4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801077f4:	55                   	push   %ebp
801077f5:	89 e5                	mov    %esp,%ebp
801077f7:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801077fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107801:	00 
80107802:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107809:	e8 c8 ff ff ff       	call   801077d6 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010780e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107815:	00 
80107816:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010781d:	e8 b4 ff ff ff       	call   801077d6 <outb>
  outb(COM1+0, 115200/9600);
80107822:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107829:	00 
8010782a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107831:	e8 a0 ff ff ff       	call   801077d6 <outb>
  outb(COM1+1, 0);
80107836:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010783d:	00 
8010783e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107845:	e8 8c ff ff ff       	call   801077d6 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010784a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107851:	00 
80107852:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107859:	e8 78 ff ff ff       	call   801077d6 <outb>
  outb(COM1+4, 0);
8010785e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107865:	00 
80107866:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010786d:	e8 64 ff ff ff       	call   801077d6 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107872:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107879:	00 
8010787a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107881:	e8 50 ff ff ff       	call   801077d6 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107886:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010788d:	e8 1a ff ff ff       	call   801077ac <inb>
80107892:	3c ff                	cmp    $0xff,%al
80107894:	74 6c                	je     80107902 <uartinit+0x10e>
    return;
  uart = 1;
80107896:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
8010789d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801078a0:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801078a7:	e8 00 ff ff ff       	call   801077ac <inb>
  inb(COM1+0);
801078ac:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801078b3:	e8 f4 fe ff ff       	call   801077ac <inb>
  picenable(IRQ_COM1);
801078b8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801078bf:	e8 11 ce ff ff       	call   801046d5 <picenable>
  ioapicenable(IRQ_COM1, 0);
801078c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078cb:	00 
801078cc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801078d3:	e8 76 b9 ff ff       	call   8010324e <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078d8:	c7 45 f4 a0 98 10 80 	movl   $0x801098a0,-0xc(%ebp)
801078df:	eb 15                	jmp    801078f6 <uartinit+0x102>
    uartputc(*p);
801078e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e4:	0f b6 00             	movzbl (%eax),%eax
801078e7:	0f be c0             	movsbl %al,%eax
801078ea:	89 04 24             	mov    %eax,(%esp)
801078ed:	e8 13 00 00 00       	call   80107905 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801078f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f9:	0f b6 00             	movzbl (%eax),%eax
801078fc:	84 c0                	test   %al,%al
801078fe:	75 e1                	jne    801078e1 <uartinit+0xed>
80107900:	eb 01                	jmp    80107903 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107902:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107903:	c9                   	leave  
80107904:	c3                   	ret    

80107905 <uartputc>:

void
uartputc(int c)
{
80107905:	55                   	push   %ebp
80107906:	89 e5                	mov    %esp,%ebp
80107908:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010790b:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107910:	85 c0                	test   %eax,%eax
80107912:	74 4d                	je     80107961 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010791b:	eb 10                	jmp    8010792d <uartputc+0x28>
    microdelay(10);
8010791d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107924:	e8 e7 be ff ff       	call   80103810 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107929:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010792d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107931:	7f 16                	jg     80107949 <uartputc+0x44>
80107933:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010793a:	e8 6d fe ff ff       	call   801077ac <inb>
8010793f:	0f b6 c0             	movzbl %al,%eax
80107942:	83 e0 20             	and    $0x20,%eax
80107945:	85 c0                	test   %eax,%eax
80107947:	74 d4                	je     8010791d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107949:	8b 45 08             	mov    0x8(%ebp),%eax
8010794c:	0f b6 c0             	movzbl %al,%eax
8010794f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107953:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010795a:	e8 77 fe ff ff       	call   801077d6 <outb>
8010795f:	eb 01                	jmp    80107962 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107961:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107962:	c9                   	leave  
80107963:	c3                   	ret    

80107964 <uartgetc>:

static int
uartgetc(void)
{
80107964:	55                   	push   %ebp
80107965:	89 e5                	mov    %esp,%ebp
80107967:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010796a:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010796f:	85 c0                	test   %eax,%eax
80107971:	75 07                	jne    8010797a <uartgetc+0x16>
    return -1;
80107973:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107978:	eb 2c                	jmp    801079a6 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010797a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107981:	e8 26 fe ff ff       	call   801077ac <inb>
80107986:	0f b6 c0             	movzbl %al,%eax
80107989:	83 e0 01             	and    $0x1,%eax
8010798c:	85 c0                	test   %eax,%eax
8010798e:	75 07                	jne    80107997 <uartgetc+0x33>
    return -1;
80107990:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107995:	eb 0f                	jmp    801079a6 <uartgetc+0x42>
  return inb(COM1+0);
80107997:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010799e:	e8 09 fe ff ff       	call   801077ac <inb>
801079a3:	0f b6 c0             	movzbl %al,%eax
}
801079a6:	c9                   	leave  
801079a7:	c3                   	ret    

801079a8 <uartintr>:

void
uartintr(void)
{
801079a8:	55                   	push   %ebp
801079a9:	89 e5                	mov    %esp,%ebp
801079ab:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801079ae:	c7 04 24 64 79 10 80 	movl   $0x80107964,(%esp)
801079b5:	e8 f4 91 ff ff       	call   80100bae <consoleintr>
}
801079ba:	c9                   	leave  
801079bb:	c3                   	ret    

801079bc <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $0
801079be:	6a 00                	push   $0x0
  jmp alltraps
801079c0:	e9 0b f9 ff ff       	jmp    801072d0 <alltraps>

801079c5 <vector1>:
.globl vector1
vector1:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $1
801079c7:	6a 01                	push   $0x1
  jmp alltraps
801079c9:	e9 02 f9 ff ff       	jmp    801072d0 <alltraps>

801079ce <vector2>:
.globl vector2
vector2:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $2
801079d0:	6a 02                	push   $0x2
  jmp alltraps
801079d2:	e9 f9 f8 ff ff       	jmp    801072d0 <alltraps>

801079d7 <vector3>:
.globl vector3
vector3:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $3
801079d9:	6a 03                	push   $0x3
  jmp alltraps
801079db:	e9 f0 f8 ff ff       	jmp    801072d0 <alltraps>

801079e0 <vector4>:
.globl vector4
vector4:
  pushl $0
801079e0:	6a 00                	push   $0x0
  pushl $4
801079e2:	6a 04                	push   $0x4
  jmp alltraps
801079e4:	e9 e7 f8 ff ff       	jmp    801072d0 <alltraps>

801079e9 <vector5>:
.globl vector5
vector5:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $5
801079eb:	6a 05                	push   $0x5
  jmp alltraps
801079ed:	e9 de f8 ff ff       	jmp    801072d0 <alltraps>

801079f2 <vector6>:
.globl vector6
vector6:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $6
801079f4:	6a 06                	push   $0x6
  jmp alltraps
801079f6:	e9 d5 f8 ff ff       	jmp    801072d0 <alltraps>

801079fb <vector7>:
.globl vector7
vector7:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $7
801079fd:	6a 07                	push   $0x7
  jmp alltraps
801079ff:	e9 cc f8 ff ff       	jmp    801072d0 <alltraps>

80107a04 <vector8>:
.globl vector8
vector8:
  pushl $8
80107a04:	6a 08                	push   $0x8
  jmp alltraps
80107a06:	e9 c5 f8 ff ff       	jmp    801072d0 <alltraps>

80107a0b <vector9>:
.globl vector9
vector9:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $9
80107a0d:	6a 09                	push   $0x9
  jmp alltraps
80107a0f:	e9 bc f8 ff ff       	jmp    801072d0 <alltraps>

80107a14 <vector10>:
.globl vector10
vector10:
  pushl $10
80107a14:	6a 0a                	push   $0xa
  jmp alltraps
80107a16:	e9 b5 f8 ff ff       	jmp    801072d0 <alltraps>

80107a1b <vector11>:
.globl vector11
vector11:
  pushl $11
80107a1b:	6a 0b                	push   $0xb
  jmp alltraps
80107a1d:	e9 ae f8 ff ff       	jmp    801072d0 <alltraps>

80107a22 <vector12>:
.globl vector12
vector12:
  pushl $12
80107a22:	6a 0c                	push   $0xc
  jmp alltraps
80107a24:	e9 a7 f8 ff ff       	jmp    801072d0 <alltraps>

80107a29 <vector13>:
.globl vector13
vector13:
  pushl $13
80107a29:	6a 0d                	push   $0xd
  jmp alltraps
80107a2b:	e9 a0 f8 ff ff       	jmp    801072d0 <alltraps>

80107a30 <vector14>:
.globl vector14
vector14:
  pushl $14
80107a30:	6a 0e                	push   $0xe
  jmp alltraps
80107a32:	e9 99 f8 ff ff       	jmp    801072d0 <alltraps>

80107a37 <vector15>:
.globl vector15
vector15:
  pushl $0
80107a37:	6a 00                	push   $0x0
  pushl $15
80107a39:	6a 0f                	push   $0xf
  jmp alltraps
80107a3b:	e9 90 f8 ff ff       	jmp    801072d0 <alltraps>

80107a40 <vector16>:
.globl vector16
vector16:
  pushl $0
80107a40:	6a 00                	push   $0x0
  pushl $16
80107a42:	6a 10                	push   $0x10
  jmp alltraps
80107a44:	e9 87 f8 ff ff       	jmp    801072d0 <alltraps>

80107a49 <vector17>:
.globl vector17
vector17:
  pushl $17
80107a49:	6a 11                	push   $0x11
  jmp alltraps
80107a4b:	e9 80 f8 ff ff       	jmp    801072d0 <alltraps>

80107a50 <vector18>:
.globl vector18
vector18:
  pushl $0
80107a50:	6a 00                	push   $0x0
  pushl $18
80107a52:	6a 12                	push   $0x12
  jmp alltraps
80107a54:	e9 77 f8 ff ff       	jmp    801072d0 <alltraps>

80107a59 <vector19>:
.globl vector19
vector19:
  pushl $0
80107a59:	6a 00                	push   $0x0
  pushl $19
80107a5b:	6a 13                	push   $0x13
  jmp alltraps
80107a5d:	e9 6e f8 ff ff       	jmp    801072d0 <alltraps>

80107a62 <vector20>:
.globl vector20
vector20:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $20
80107a64:	6a 14                	push   $0x14
  jmp alltraps
80107a66:	e9 65 f8 ff ff       	jmp    801072d0 <alltraps>

80107a6b <vector21>:
.globl vector21
vector21:
  pushl $0
80107a6b:	6a 00                	push   $0x0
  pushl $21
80107a6d:	6a 15                	push   $0x15
  jmp alltraps
80107a6f:	e9 5c f8 ff ff       	jmp    801072d0 <alltraps>

80107a74 <vector22>:
.globl vector22
vector22:
  pushl $0
80107a74:	6a 00                	push   $0x0
  pushl $22
80107a76:	6a 16                	push   $0x16
  jmp alltraps
80107a78:	e9 53 f8 ff ff       	jmp    801072d0 <alltraps>

80107a7d <vector23>:
.globl vector23
vector23:
  pushl $0
80107a7d:	6a 00                	push   $0x0
  pushl $23
80107a7f:	6a 17                	push   $0x17
  jmp alltraps
80107a81:	e9 4a f8 ff ff       	jmp    801072d0 <alltraps>

80107a86 <vector24>:
.globl vector24
vector24:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $24
80107a88:	6a 18                	push   $0x18
  jmp alltraps
80107a8a:	e9 41 f8 ff ff       	jmp    801072d0 <alltraps>

80107a8f <vector25>:
.globl vector25
vector25:
  pushl $0
80107a8f:	6a 00                	push   $0x0
  pushl $25
80107a91:	6a 19                	push   $0x19
  jmp alltraps
80107a93:	e9 38 f8 ff ff       	jmp    801072d0 <alltraps>

80107a98 <vector26>:
.globl vector26
vector26:
  pushl $0
80107a98:	6a 00                	push   $0x0
  pushl $26
80107a9a:	6a 1a                	push   $0x1a
  jmp alltraps
80107a9c:	e9 2f f8 ff ff       	jmp    801072d0 <alltraps>

80107aa1 <vector27>:
.globl vector27
vector27:
  pushl $0
80107aa1:	6a 00                	push   $0x0
  pushl $27
80107aa3:	6a 1b                	push   $0x1b
  jmp alltraps
80107aa5:	e9 26 f8 ff ff       	jmp    801072d0 <alltraps>

80107aaa <vector28>:
.globl vector28
vector28:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $28
80107aac:	6a 1c                	push   $0x1c
  jmp alltraps
80107aae:	e9 1d f8 ff ff       	jmp    801072d0 <alltraps>

80107ab3 <vector29>:
.globl vector29
vector29:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $29
80107ab5:	6a 1d                	push   $0x1d
  jmp alltraps
80107ab7:	e9 14 f8 ff ff       	jmp    801072d0 <alltraps>

80107abc <vector30>:
.globl vector30
vector30:
  pushl $0
80107abc:	6a 00                	push   $0x0
  pushl $30
80107abe:	6a 1e                	push   $0x1e
  jmp alltraps
80107ac0:	e9 0b f8 ff ff       	jmp    801072d0 <alltraps>

80107ac5 <vector31>:
.globl vector31
vector31:
  pushl $0
80107ac5:	6a 00                	push   $0x0
  pushl $31
80107ac7:	6a 1f                	push   $0x1f
  jmp alltraps
80107ac9:	e9 02 f8 ff ff       	jmp    801072d0 <alltraps>

80107ace <vector32>:
.globl vector32
vector32:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $32
80107ad0:	6a 20                	push   $0x20
  jmp alltraps
80107ad2:	e9 f9 f7 ff ff       	jmp    801072d0 <alltraps>

80107ad7 <vector33>:
.globl vector33
vector33:
  pushl $0
80107ad7:	6a 00                	push   $0x0
  pushl $33
80107ad9:	6a 21                	push   $0x21
  jmp alltraps
80107adb:	e9 f0 f7 ff ff       	jmp    801072d0 <alltraps>

80107ae0 <vector34>:
.globl vector34
vector34:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $34
80107ae2:	6a 22                	push   $0x22
  jmp alltraps
80107ae4:	e9 e7 f7 ff ff       	jmp    801072d0 <alltraps>

80107ae9 <vector35>:
.globl vector35
vector35:
  pushl $0
80107ae9:	6a 00                	push   $0x0
  pushl $35
80107aeb:	6a 23                	push   $0x23
  jmp alltraps
80107aed:	e9 de f7 ff ff       	jmp    801072d0 <alltraps>

80107af2 <vector36>:
.globl vector36
vector36:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $36
80107af4:	6a 24                	push   $0x24
  jmp alltraps
80107af6:	e9 d5 f7 ff ff       	jmp    801072d0 <alltraps>

80107afb <vector37>:
.globl vector37
vector37:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $37
80107afd:	6a 25                	push   $0x25
  jmp alltraps
80107aff:	e9 cc f7 ff ff       	jmp    801072d0 <alltraps>

80107b04 <vector38>:
.globl vector38
vector38:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $38
80107b06:	6a 26                	push   $0x26
  jmp alltraps
80107b08:	e9 c3 f7 ff ff       	jmp    801072d0 <alltraps>

80107b0d <vector39>:
.globl vector39
vector39:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $39
80107b0f:	6a 27                	push   $0x27
  jmp alltraps
80107b11:	e9 ba f7 ff ff       	jmp    801072d0 <alltraps>

80107b16 <vector40>:
.globl vector40
vector40:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $40
80107b18:	6a 28                	push   $0x28
  jmp alltraps
80107b1a:	e9 b1 f7 ff ff       	jmp    801072d0 <alltraps>

80107b1f <vector41>:
.globl vector41
vector41:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $41
80107b21:	6a 29                	push   $0x29
  jmp alltraps
80107b23:	e9 a8 f7 ff ff       	jmp    801072d0 <alltraps>

80107b28 <vector42>:
.globl vector42
vector42:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $42
80107b2a:	6a 2a                	push   $0x2a
  jmp alltraps
80107b2c:	e9 9f f7 ff ff       	jmp    801072d0 <alltraps>

80107b31 <vector43>:
.globl vector43
vector43:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $43
80107b33:	6a 2b                	push   $0x2b
  jmp alltraps
80107b35:	e9 96 f7 ff ff       	jmp    801072d0 <alltraps>

80107b3a <vector44>:
.globl vector44
vector44:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $44
80107b3c:	6a 2c                	push   $0x2c
  jmp alltraps
80107b3e:	e9 8d f7 ff ff       	jmp    801072d0 <alltraps>

80107b43 <vector45>:
.globl vector45
vector45:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $45
80107b45:	6a 2d                	push   $0x2d
  jmp alltraps
80107b47:	e9 84 f7 ff ff       	jmp    801072d0 <alltraps>

80107b4c <vector46>:
.globl vector46
vector46:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $46
80107b4e:	6a 2e                	push   $0x2e
  jmp alltraps
80107b50:	e9 7b f7 ff ff       	jmp    801072d0 <alltraps>

80107b55 <vector47>:
.globl vector47
vector47:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $47
80107b57:	6a 2f                	push   $0x2f
  jmp alltraps
80107b59:	e9 72 f7 ff ff       	jmp    801072d0 <alltraps>

80107b5e <vector48>:
.globl vector48
vector48:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $48
80107b60:	6a 30                	push   $0x30
  jmp alltraps
80107b62:	e9 69 f7 ff ff       	jmp    801072d0 <alltraps>

80107b67 <vector49>:
.globl vector49
vector49:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $49
80107b69:	6a 31                	push   $0x31
  jmp alltraps
80107b6b:	e9 60 f7 ff ff       	jmp    801072d0 <alltraps>

80107b70 <vector50>:
.globl vector50
vector50:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $50
80107b72:	6a 32                	push   $0x32
  jmp alltraps
80107b74:	e9 57 f7 ff ff       	jmp    801072d0 <alltraps>

80107b79 <vector51>:
.globl vector51
vector51:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $51
80107b7b:	6a 33                	push   $0x33
  jmp alltraps
80107b7d:	e9 4e f7 ff ff       	jmp    801072d0 <alltraps>

80107b82 <vector52>:
.globl vector52
vector52:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $52
80107b84:	6a 34                	push   $0x34
  jmp alltraps
80107b86:	e9 45 f7 ff ff       	jmp    801072d0 <alltraps>

80107b8b <vector53>:
.globl vector53
vector53:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $53
80107b8d:	6a 35                	push   $0x35
  jmp alltraps
80107b8f:	e9 3c f7 ff ff       	jmp    801072d0 <alltraps>

80107b94 <vector54>:
.globl vector54
vector54:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $54
80107b96:	6a 36                	push   $0x36
  jmp alltraps
80107b98:	e9 33 f7 ff ff       	jmp    801072d0 <alltraps>

80107b9d <vector55>:
.globl vector55
vector55:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $55
80107b9f:	6a 37                	push   $0x37
  jmp alltraps
80107ba1:	e9 2a f7 ff ff       	jmp    801072d0 <alltraps>

80107ba6 <vector56>:
.globl vector56
vector56:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $56
80107ba8:	6a 38                	push   $0x38
  jmp alltraps
80107baa:	e9 21 f7 ff ff       	jmp    801072d0 <alltraps>

80107baf <vector57>:
.globl vector57
vector57:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $57
80107bb1:	6a 39                	push   $0x39
  jmp alltraps
80107bb3:	e9 18 f7 ff ff       	jmp    801072d0 <alltraps>

80107bb8 <vector58>:
.globl vector58
vector58:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $58
80107bba:	6a 3a                	push   $0x3a
  jmp alltraps
80107bbc:	e9 0f f7 ff ff       	jmp    801072d0 <alltraps>

80107bc1 <vector59>:
.globl vector59
vector59:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $59
80107bc3:	6a 3b                	push   $0x3b
  jmp alltraps
80107bc5:	e9 06 f7 ff ff       	jmp    801072d0 <alltraps>

80107bca <vector60>:
.globl vector60
vector60:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $60
80107bcc:	6a 3c                	push   $0x3c
  jmp alltraps
80107bce:	e9 fd f6 ff ff       	jmp    801072d0 <alltraps>

80107bd3 <vector61>:
.globl vector61
vector61:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $61
80107bd5:	6a 3d                	push   $0x3d
  jmp alltraps
80107bd7:	e9 f4 f6 ff ff       	jmp    801072d0 <alltraps>

80107bdc <vector62>:
.globl vector62
vector62:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $62
80107bde:	6a 3e                	push   $0x3e
  jmp alltraps
80107be0:	e9 eb f6 ff ff       	jmp    801072d0 <alltraps>

80107be5 <vector63>:
.globl vector63
vector63:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $63
80107be7:	6a 3f                	push   $0x3f
  jmp alltraps
80107be9:	e9 e2 f6 ff ff       	jmp    801072d0 <alltraps>

80107bee <vector64>:
.globl vector64
vector64:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $64
80107bf0:	6a 40                	push   $0x40
  jmp alltraps
80107bf2:	e9 d9 f6 ff ff       	jmp    801072d0 <alltraps>

80107bf7 <vector65>:
.globl vector65
vector65:
  pushl $0
80107bf7:	6a 00                	push   $0x0
  pushl $65
80107bf9:	6a 41                	push   $0x41
  jmp alltraps
80107bfb:	e9 d0 f6 ff ff       	jmp    801072d0 <alltraps>

80107c00 <vector66>:
.globl vector66
vector66:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $66
80107c02:	6a 42                	push   $0x42
  jmp alltraps
80107c04:	e9 c7 f6 ff ff       	jmp    801072d0 <alltraps>

80107c09 <vector67>:
.globl vector67
vector67:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $67
80107c0b:	6a 43                	push   $0x43
  jmp alltraps
80107c0d:	e9 be f6 ff ff       	jmp    801072d0 <alltraps>

80107c12 <vector68>:
.globl vector68
vector68:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $68
80107c14:	6a 44                	push   $0x44
  jmp alltraps
80107c16:	e9 b5 f6 ff ff       	jmp    801072d0 <alltraps>

80107c1b <vector69>:
.globl vector69
vector69:
  pushl $0
80107c1b:	6a 00                	push   $0x0
  pushl $69
80107c1d:	6a 45                	push   $0x45
  jmp alltraps
80107c1f:	e9 ac f6 ff ff       	jmp    801072d0 <alltraps>

80107c24 <vector70>:
.globl vector70
vector70:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $70
80107c26:	6a 46                	push   $0x46
  jmp alltraps
80107c28:	e9 a3 f6 ff ff       	jmp    801072d0 <alltraps>

80107c2d <vector71>:
.globl vector71
vector71:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $71
80107c2f:	6a 47                	push   $0x47
  jmp alltraps
80107c31:	e9 9a f6 ff ff       	jmp    801072d0 <alltraps>

80107c36 <vector72>:
.globl vector72
vector72:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $72
80107c38:	6a 48                	push   $0x48
  jmp alltraps
80107c3a:	e9 91 f6 ff ff       	jmp    801072d0 <alltraps>

80107c3f <vector73>:
.globl vector73
vector73:
  pushl $0
80107c3f:	6a 00                	push   $0x0
  pushl $73
80107c41:	6a 49                	push   $0x49
  jmp alltraps
80107c43:	e9 88 f6 ff ff       	jmp    801072d0 <alltraps>

80107c48 <vector74>:
.globl vector74
vector74:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $74
80107c4a:	6a 4a                	push   $0x4a
  jmp alltraps
80107c4c:	e9 7f f6 ff ff       	jmp    801072d0 <alltraps>

80107c51 <vector75>:
.globl vector75
vector75:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $75
80107c53:	6a 4b                	push   $0x4b
  jmp alltraps
80107c55:	e9 76 f6 ff ff       	jmp    801072d0 <alltraps>

80107c5a <vector76>:
.globl vector76
vector76:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $76
80107c5c:	6a 4c                	push   $0x4c
  jmp alltraps
80107c5e:	e9 6d f6 ff ff       	jmp    801072d0 <alltraps>

80107c63 <vector77>:
.globl vector77
vector77:
  pushl $0
80107c63:	6a 00                	push   $0x0
  pushl $77
80107c65:	6a 4d                	push   $0x4d
  jmp alltraps
80107c67:	e9 64 f6 ff ff       	jmp    801072d0 <alltraps>

80107c6c <vector78>:
.globl vector78
vector78:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $78
80107c6e:	6a 4e                	push   $0x4e
  jmp alltraps
80107c70:	e9 5b f6 ff ff       	jmp    801072d0 <alltraps>

80107c75 <vector79>:
.globl vector79
vector79:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $79
80107c77:	6a 4f                	push   $0x4f
  jmp alltraps
80107c79:	e9 52 f6 ff ff       	jmp    801072d0 <alltraps>

80107c7e <vector80>:
.globl vector80
vector80:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $80
80107c80:	6a 50                	push   $0x50
  jmp alltraps
80107c82:	e9 49 f6 ff ff       	jmp    801072d0 <alltraps>

80107c87 <vector81>:
.globl vector81
vector81:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $81
80107c89:	6a 51                	push   $0x51
  jmp alltraps
80107c8b:	e9 40 f6 ff ff       	jmp    801072d0 <alltraps>

80107c90 <vector82>:
.globl vector82
vector82:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $82
80107c92:	6a 52                	push   $0x52
  jmp alltraps
80107c94:	e9 37 f6 ff ff       	jmp    801072d0 <alltraps>

80107c99 <vector83>:
.globl vector83
vector83:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $83
80107c9b:	6a 53                	push   $0x53
  jmp alltraps
80107c9d:	e9 2e f6 ff ff       	jmp    801072d0 <alltraps>

80107ca2 <vector84>:
.globl vector84
vector84:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $84
80107ca4:	6a 54                	push   $0x54
  jmp alltraps
80107ca6:	e9 25 f6 ff ff       	jmp    801072d0 <alltraps>

80107cab <vector85>:
.globl vector85
vector85:
  pushl $0
80107cab:	6a 00                	push   $0x0
  pushl $85
80107cad:	6a 55                	push   $0x55
  jmp alltraps
80107caf:	e9 1c f6 ff ff       	jmp    801072d0 <alltraps>

80107cb4 <vector86>:
.globl vector86
vector86:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $86
80107cb6:	6a 56                	push   $0x56
  jmp alltraps
80107cb8:	e9 13 f6 ff ff       	jmp    801072d0 <alltraps>

80107cbd <vector87>:
.globl vector87
vector87:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $87
80107cbf:	6a 57                	push   $0x57
  jmp alltraps
80107cc1:	e9 0a f6 ff ff       	jmp    801072d0 <alltraps>

80107cc6 <vector88>:
.globl vector88
vector88:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $88
80107cc8:	6a 58                	push   $0x58
  jmp alltraps
80107cca:	e9 01 f6 ff ff       	jmp    801072d0 <alltraps>

80107ccf <vector89>:
.globl vector89
vector89:
  pushl $0
80107ccf:	6a 00                	push   $0x0
  pushl $89
80107cd1:	6a 59                	push   $0x59
  jmp alltraps
80107cd3:	e9 f8 f5 ff ff       	jmp    801072d0 <alltraps>

80107cd8 <vector90>:
.globl vector90
vector90:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $90
80107cda:	6a 5a                	push   $0x5a
  jmp alltraps
80107cdc:	e9 ef f5 ff ff       	jmp    801072d0 <alltraps>

80107ce1 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $91
80107ce3:	6a 5b                	push   $0x5b
  jmp alltraps
80107ce5:	e9 e6 f5 ff ff       	jmp    801072d0 <alltraps>

80107cea <vector92>:
.globl vector92
vector92:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $92
80107cec:	6a 5c                	push   $0x5c
  jmp alltraps
80107cee:	e9 dd f5 ff ff       	jmp    801072d0 <alltraps>

80107cf3 <vector93>:
.globl vector93
vector93:
  pushl $0
80107cf3:	6a 00                	push   $0x0
  pushl $93
80107cf5:	6a 5d                	push   $0x5d
  jmp alltraps
80107cf7:	e9 d4 f5 ff ff       	jmp    801072d0 <alltraps>

80107cfc <vector94>:
.globl vector94
vector94:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $94
80107cfe:	6a 5e                	push   $0x5e
  jmp alltraps
80107d00:	e9 cb f5 ff ff       	jmp    801072d0 <alltraps>

80107d05 <vector95>:
.globl vector95
vector95:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $95
80107d07:	6a 5f                	push   $0x5f
  jmp alltraps
80107d09:	e9 c2 f5 ff ff       	jmp    801072d0 <alltraps>

80107d0e <vector96>:
.globl vector96
vector96:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $96
80107d10:	6a 60                	push   $0x60
  jmp alltraps
80107d12:	e9 b9 f5 ff ff       	jmp    801072d0 <alltraps>

80107d17 <vector97>:
.globl vector97
vector97:
  pushl $0
80107d17:	6a 00                	push   $0x0
  pushl $97
80107d19:	6a 61                	push   $0x61
  jmp alltraps
80107d1b:	e9 b0 f5 ff ff       	jmp    801072d0 <alltraps>

80107d20 <vector98>:
.globl vector98
vector98:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $98
80107d22:	6a 62                	push   $0x62
  jmp alltraps
80107d24:	e9 a7 f5 ff ff       	jmp    801072d0 <alltraps>

80107d29 <vector99>:
.globl vector99
vector99:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $99
80107d2b:	6a 63                	push   $0x63
  jmp alltraps
80107d2d:	e9 9e f5 ff ff       	jmp    801072d0 <alltraps>

80107d32 <vector100>:
.globl vector100
vector100:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $100
80107d34:	6a 64                	push   $0x64
  jmp alltraps
80107d36:	e9 95 f5 ff ff       	jmp    801072d0 <alltraps>

80107d3b <vector101>:
.globl vector101
vector101:
  pushl $0
80107d3b:	6a 00                	push   $0x0
  pushl $101
80107d3d:	6a 65                	push   $0x65
  jmp alltraps
80107d3f:	e9 8c f5 ff ff       	jmp    801072d0 <alltraps>

80107d44 <vector102>:
.globl vector102
vector102:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $102
80107d46:	6a 66                	push   $0x66
  jmp alltraps
80107d48:	e9 83 f5 ff ff       	jmp    801072d0 <alltraps>

80107d4d <vector103>:
.globl vector103
vector103:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $103
80107d4f:	6a 67                	push   $0x67
  jmp alltraps
80107d51:	e9 7a f5 ff ff       	jmp    801072d0 <alltraps>

80107d56 <vector104>:
.globl vector104
vector104:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $104
80107d58:	6a 68                	push   $0x68
  jmp alltraps
80107d5a:	e9 71 f5 ff ff       	jmp    801072d0 <alltraps>

80107d5f <vector105>:
.globl vector105
vector105:
  pushl $0
80107d5f:	6a 00                	push   $0x0
  pushl $105
80107d61:	6a 69                	push   $0x69
  jmp alltraps
80107d63:	e9 68 f5 ff ff       	jmp    801072d0 <alltraps>

80107d68 <vector106>:
.globl vector106
vector106:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $106
80107d6a:	6a 6a                	push   $0x6a
  jmp alltraps
80107d6c:	e9 5f f5 ff ff       	jmp    801072d0 <alltraps>

80107d71 <vector107>:
.globl vector107
vector107:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $107
80107d73:	6a 6b                	push   $0x6b
  jmp alltraps
80107d75:	e9 56 f5 ff ff       	jmp    801072d0 <alltraps>

80107d7a <vector108>:
.globl vector108
vector108:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $108
80107d7c:	6a 6c                	push   $0x6c
  jmp alltraps
80107d7e:	e9 4d f5 ff ff       	jmp    801072d0 <alltraps>

80107d83 <vector109>:
.globl vector109
vector109:
  pushl $0
80107d83:	6a 00                	push   $0x0
  pushl $109
80107d85:	6a 6d                	push   $0x6d
  jmp alltraps
80107d87:	e9 44 f5 ff ff       	jmp    801072d0 <alltraps>

80107d8c <vector110>:
.globl vector110
vector110:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $110
80107d8e:	6a 6e                	push   $0x6e
  jmp alltraps
80107d90:	e9 3b f5 ff ff       	jmp    801072d0 <alltraps>

80107d95 <vector111>:
.globl vector111
vector111:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $111
80107d97:	6a 6f                	push   $0x6f
  jmp alltraps
80107d99:	e9 32 f5 ff ff       	jmp    801072d0 <alltraps>

80107d9e <vector112>:
.globl vector112
vector112:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $112
80107da0:	6a 70                	push   $0x70
  jmp alltraps
80107da2:	e9 29 f5 ff ff       	jmp    801072d0 <alltraps>

80107da7 <vector113>:
.globl vector113
vector113:
  pushl $0
80107da7:	6a 00                	push   $0x0
  pushl $113
80107da9:	6a 71                	push   $0x71
  jmp alltraps
80107dab:	e9 20 f5 ff ff       	jmp    801072d0 <alltraps>

80107db0 <vector114>:
.globl vector114
vector114:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $114
80107db2:	6a 72                	push   $0x72
  jmp alltraps
80107db4:	e9 17 f5 ff ff       	jmp    801072d0 <alltraps>

80107db9 <vector115>:
.globl vector115
vector115:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $115
80107dbb:	6a 73                	push   $0x73
  jmp alltraps
80107dbd:	e9 0e f5 ff ff       	jmp    801072d0 <alltraps>

80107dc2 <vector116>:
.globl vector116
vector116:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $116
80107dc4:	6a 74                	push   $0x74
  jmp alltraps
80107dc6:	e9 05 f5 ff ff       	jmp    801072d0 <alltraps>

80107dcb <vector117>:
.globl vector117
vector117:
  pushl $0
80107dcb:	6a 00                	push   $0x0
  pushl $117
80107dcd:	6a 75                	push   $0x75
  jmp alltraps
80107dcf:	e9 fc f4 ff ff       	jmp    801072d0 <alltraps>

80107dd4 <vector118>:
.globl vector118
vector118:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $118
80107dd6:	6a 76                	push   $0x76
  jmp alltraps
80107dd8:	e9 f3 f4 ff ff       	jmp    801072d0 <alltraps>

80107ddd <vector119>:
.globl vector119
vector119:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $119
80107ddf:	6a 77                	push   $0x77
  jmp alltraps
80107de1:	e9 ea f4 ff ff       	jmp    801072d0 <alltraps>

80107de6 <vector120>:
.globl vector120
vector120:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $120
80107de8:	6a 78                	push   $0x78
  jmp alltraps
80107dea:	e9 e1 f4 ff ff       	jmp    801072d0 <alltraps>

80107def <vector121>:
.globl vector121
vector121:
  pushl $0
80107def:	6a 00                	push   $0x0
  pushl $121
80107df1:	6a 79                	push   $0x79
  jmp alltraps
80107df3:	e9 d8 f4 ff ff       	jmp    801072d0 <alltraps>

80107df8 <vector122>:
.globl vector122
vector122:
  pushl $0
80107df8:	6a 00                	push   $0x0
  pushl $122
80107dfa:	6a 7a                	push   $0x7a
  jmp alltraps
80107dfc:	e9 cf f4 ff ff       	jmp    801072d0 <alltraps>

80107e01 <vector123>:
.globl vector123
vector123:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $123
80107e03:	6a 7b                	push   $0x7b
  jmp alltraps
80107e05:	e9 c6 f4 ff ff       	jmp    801072d0 <alltraps>

80107e0a <vector124>:
.globl vector124
vector124:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $124
80107e0c:	6a 7c                	push   $0x7c
  jmp alltraps
80107e0e:	e9 bd f4 ff ff       	jmp    801072d0 <alltraps>

80107e13 <vector125>:
.globl vector125
vector125:
  pushl $0
80107e13:	6a 00                	push   $0x0
  pushl $125
80107e15:	6a 7d                	push   $0x7d
  jmp alltraps
80107e17:	e9 b4 f4 ff ff       	jmp    801072d0 <alltraps>

80107e1c <vector126>:
.globl vector126
vector126:
  pushl $0
80107e1c:	6a 00                	push   $0x0
  pushl $126
80107e1e:	6a 7e                	push   $0x7e
  jmp alltraps
80107e20:	e9 ab f4 ff ff       	jmp    801072d0 <alltraps>

80107e25 <vector127>:
.globl vector127
vector127:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $127
80107e27:	6a 7f                	push   $0x7f
  jmp alltraps
80107e29:	e9 a2 f4 ff ff       	jmp    801072d0 <alltraps>

80107e2e <vector128>:
.globl vector128
vector128:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $128
80107e30:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107e35:	e9 96 f4 ff ff       	jmp    801072d0 <alltraps>

80107e3a <vector129>:
.globl vector129
vector129:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $129
80107e3c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107e41:	e9 8a f4 ff ff       	jmp    801072d0 <alltraps>

80107e46 <vector130>:
.globl vector130
vector130:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $130
80107e48:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107e4d:	e9 7e f4 ff ff       	jmp    801072d0 <alltraps>

80107e52 <vector131>:
.globl vector131
vector131:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $131
80107e54:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e59:	e9 72 f4 ff ff       	jmp    801072d0 <alltraps>

80107e5e <vector132>:
.globl vector132
vector132:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $132
80107e60:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e65:	e9 66 f4 ff ff       	jmp    801072d0 <alltraps>

80107e6a <vector133>:
.globl vector133
vector133:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $133
80107e6c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107e71:	e9 5a f4 ff ff       	jmp    801072d0 <alltraps>

80107e76 <vector134>:
.globl vector134
vector134:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $134
80107e78:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107e7d:	e9 4e f4 ff ff       	jmp    801072d0 <alltraps>

80107e82 <vector135>:
.globl vector135
vector135:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $135
80107e84:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107e89:	e9 42 f4 ff ff       	jmp    801072d0 <alltraps>

80107e8e <vector136>:
.globl vector136
vector136:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $136
80107e90:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107e95:	e9 36 f4 ff ff       	jmp    801072d0 <alltraps>

80107e9a <vector137>:
.globl vector137
vector137:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $137
80107e9c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107ea1:	e9 2a f4 ff ff       	jmp    801072d0 <alltraps>

80107ea6 <vector138>:
.globl vector138
vector138:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $138
80107ea8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107ead:	e9 1e f4 ff ff       	jmp    801072d0 <alltraps>

80107eb2 <vector139>:
.globl vector139
vector139:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $139
80107eb4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107eb9:	e9 12 f4 ff ff       	jmp    801072d0 <alltraps>

80107ebe <vector140>:
.globl vector140
vector140:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $140
80107ec0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107ec5:	e9 06 f4 ff ff       	jmp    801072d0 <alltraps>

80107eca <vector141>:
.globl vector141
vector141:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $141
80107ecc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107ed1:	e9 fa f3 ff ff       	jmp    801072d0 <alltraps>

80107ed6 <vector142>:
.globl vector142
vector142:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $142
80107ed8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107edd:	e9 ee f3 ff ff       	jmp    801072d0 <alltraps>

80107ee2 <vector143>:
.globl vector143
vector143:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $143
80107ee4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107ee9:	e9 e2 f3 ff ff       	jmp    801072d0 <alltraps>

80107eee <vector144>:
.globl vector144
vector144:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $144
80107ef0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107ef5:	e9 d6 f3 ff ff       	jmp    801072d0 <alltraps>

80107efa <vector145>:
.globl vector145
vector145:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $145
80107efc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107f01:	e9 ca f3 ff ff       	jmp    801072d0 <alltraps>

80107f06 <vector146>:
.globl vector146
vector146:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $146
80107f08:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107f0d:	e9 be f3 ff ff       	jmp    801072d0 <alltraps>

80107f12 <vector147>:
.globl vector147
vector147:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $147
80107f14:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107f19:	e9 b2 f3 ff ff       	jmp    801072d0 <alltraps>

80107f1e <vector148>:
.globl vector148
vector148:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $148
80107f20:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107f25:	e9 a6 f3 ff ff       	jmp    801072d0 <alltraps>

80107f2a <vector149>:
.globl vector149
vector149:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $149
80107f2c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107f31:	e9 9a f3 ff ff       	jmp    801072d0 <alltraps>

80107f36 <vector150>:
.globl vector150
vector150:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $150
80107f38:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107f3d:	e9 8e f3 ff ff       	jmp    801072d0 <alltraps>

80107f42 <vector151>:
.globl vector151
vector151:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $151
80107f44:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107f49:	e9 82 f3 ff ff       	jmp    801072d0 <alltraps>

80107f4e <vector152>:
.globl vector152
vector152:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $152
80107f50:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107f55:	e9 76 f3 ff ff       	jmp    801072d0 <alltraps>

80107f5a <vector153>:
.globl vector153
vector153:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $153
80107f5c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f61:	e9 6a f3 ff ff       	jmp    801072d0 <alltraps>

80107f66 <vector154>:
.globl vector154
vector154:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $154
80107f68:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107f6d:	e9 5e f3 ff ff       	jmp    801072d0 <alltraps>

80107f72 <vector155>:
.globl vector155
vector155:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $155
80107f74:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107f79:	e9 52 f3 ff ff       	jmp    801072d0 <alltraps>

80107f7e <vector156>:
.globl vector156
vector156:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $156
80107f80:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107f85:	e9 46 f3 ff ff       	jmp    801072d0 <alltraps>

80107f8a <vector157>:
.globl vector157
vector157:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $157
80107f8c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107f91:	e9 3a f3 ff ff       	jmp    801072d0 <alltraps>

80107f96 <vector158>:
.globl vector158
vector158:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $158
80107f98:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107f9d:	e9 2e f3 ff ff       	jmp    801072d0 <alltraps>

80107fa2 <vector159>:
.globl vector159
vector159:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $159
80107fa4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107fa9:	e9 22 f3 ff ff       	jmp    801072d0 <alltraps>

80107fae <vector160>:
.globl vector160
vector160:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $160
80107fb0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107fb5:	e9 16 f3 ff ff       	jmp    801072d0 <alltraps>

80107fba <vector161>:
.globl vector161
vector161:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $161
80107fbc:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107fc1:	e9 0a f3 ff ff       	jmp    801072d0 <alltraps>

80107fc6 <vector162>:
.globl vector162
vector162:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $162
80107fc8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107fcd:	e9 fe f2 ff ff       	jmp    801072d0 <alltraps>

80107fd2 <vector163>:
.globl vector163
vector163:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $163
80107fd4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107fd9:	e9 f2 f2 ff ff       	jmp    801072d0 <alltraps>

80107fde <vector164>:
.globl vector164
vector164:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $164
80107fe0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107fe5:	e9 e6 f2 ff ff       	jmp    801072d0 <alltraps>

80107fea <vector165>:
.globl vector165
vector165:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $165
80107fec:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107ff1:	e9 da f2 ff ff       	jmp    801072d0 <alltraps>

80107ff6 <vector166>:
.globl vector166
vector166:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $166
80107ff8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ffd:	e9 ce f2 ff ff       	jmp    801072d0 <alltraps>

80108002 <vector167>:
.globl vector167
vector167:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $167
80108004:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108009:	e9 c2 f2 ff ff       	jmp    801072d0 <alltraps>

8010800e <vector168>:
.globl vector168
vector168:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $168
80108010:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108015:	e9 b6 f2 ff ff       	jmp    801072d0 <alltraps>

8010801a <vector169>:
.globl vector169
vector169:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $169
8010801c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108021:	e9 aa f2 ff ff       	jmp    801072d0 <alltraps>

80108026 <vector170>:
.globl vector170
vector170:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $170
80108028:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010802d:	e9 9e f2 ff ff       	jmp    801072d0 <alltraps>

80108032 <vector171>:
.globl vector171
vector171:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $171
80108034:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108039:	e9 92 f2 ff ff       	jmp    801072d0 <alltraps>

8010803e <vector172>:
.globl vector172
vector172:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $172
80108040:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108045:	e9 86 f2 ff ff       	jmp    801072d0 <alltraps>

8010804a <vector173>:
.globl vector173
vector173:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $173
8010804c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108051:	e9 7a f2 ff ff       	jmp    801072d0 <alltraps>

80108056 <vector174>:
.globl vector174
vector174:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $174
80108058:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010805d:	e9 6e f2 ff ff       	jmp    801072d0 <alltraps>

80108062 <vector175>:
.globl vector175
vector175:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $175
80108064:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108069:	e9 62 f2 ff ff       	jmp    801072d0 <alltraps>

8010806e <vector176>:
.globl vector176
vector176:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $176
80108070:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108075:	e9 56 f2 ff ff       	jmp    801072d0 <alltraps>

8010807a <vector177>:
.globl vector177
vector177:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $177
8010807c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108081:	e9 4a f2 ff ff       	jmp    801072d0 <alltraps>

80108086 <vector178>:
.globl vector178
vector178:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $178
80108088:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010808d:	e9 3e f2 ff ff       	jmp    801072d0 <alltraps>

80108092 <vector179>:
.globl vector179
vector179:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $179
80108094:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108099:	e9 32 f2 ff ff       	jmp    801072d0 <alltraps>

8010809e <vector180>:
.globl vector180
vector180:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $180
801080a0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801080a5:	e9 26 f2 ff ff       	jmp    801072d0 <alltraps>

801080aa <vector181>:
.globl vector181
vector181:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $181
801080ac:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801080b1:	e9 1a f2 ff ff       	jmp    801072d0 <alltraps>

801080b6 <vector182>:
.globl vector182
vector182:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $182
801080b8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801080bd:	e9 0e f2 ff ff       	jmp    801072d0 <alltraps>

801080c2 <vector183>:
.globl vector183
vector183:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $183
801080c4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801080c9:	e9 02 f2 ff ff       	jmp    801072d0 <alltraps>

801080ce <vector184>:
.globl vector184
vector184:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $184
801080d0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801080d5:	e9 f6 f1 ff ff       	jmp    801072d0 <alltraps>

801080da <vector185>:
.globl vector185
vector185:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $185
801080dc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801080e1:	e9 ea f1 ff ff       	jmp    801072d0 <alltraps>

801080e6 <vector186>:
.globl vector186
vector186:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $186
801080e8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801080ed:	e9 de f1 ff ff       	jmp    801072d0 <alltraps>

801080f2 <vector187>:
.globl vector187
vector187:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $187
801080f4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801080f9:	e9 d2 f1 ff ff       	jmp    801072d0 <alltraps>

801080fe <vector188>:
.globl vector188
vector188:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $188
80108100:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108105:	e9 c6 f1 ff ff       	jmp    801072d0 <alltraps>

8010810a <vector189>:
.globl vector189
vector189:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $189
8010810c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108111:	e9 ba f1 ff ff       	jmp    801072d0 <alltraps>

80108116 <vector190>:
.globl vector190
vector190:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $190
80108118:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010811d:	e9 ae f1 ff ff       	jmp    801072d0 <alltraps>

80108122 <vector191>:
.globl vector191
vector191:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $191
80108124:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108129:	e9 a2 f1 ff ff       	jmp    801072d0 <alltraps>

8010812e <vector192>:
.globl vector192
vector192:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $192
80108130:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108135:	e9 96 f1 ff ff       	jmp    801072d0 <alltraps>

8010813a <vector193>:
.globl vector193
vector193:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $193
8010813c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108141:	e9 8a f1 ff ff       	jmp    801072d0 <alltraps>

80108146 <vector194>:
.globl vector194
vector194:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $194
80108148:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010814d:	e9 7e f1 ff ff       	jmp    801072d0 <alltraps>

80108152 <vector195>:
.globl vector195
vector195:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $195
80108154:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108159:	e9 72 f1 ff ff       	jmp    801072d0 <alltraps>

8010815e <vector196>:
.globl vector196
vector196:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $196
80108160:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108165:	e9 66 f1 ff ff       	jmp    801072d0 <alltraps>

8010816a <vector197>:
.globl vector197
vector197:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $197
8010816c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108171:	e9 5a f1 ff ff       	jmp    801072d0 <alltraps>

80108176 <vector198>:
.globl vector198
vector198:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $198
80108178:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010817d:	e9 4e f1 ff ff       	jmp    801072d0 <alltraps>

80108182 <vector199>:
.globl vector199
vector199:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $199
80108184:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108189:	e9 42 f1 ff ff       	jmp    801072d0 <alltraps>

8010818e <vector200>:
.globl vector200
vector200:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $200
80108190:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108195:	e9 36 f1 ff ff       	jmp    801072d0 <alltraps>

8010819a <vector201>:
.globl vector201
vector201:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $201
8010819c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801081a1:	e9 2a f1 ff ff       	jmp    801072d0 <alltraps>

801081a6 <vector202>:
.globl vector202
vector202:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $202
801081a8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801081ad:	e9 1e f1 ff ff       	jmp    801072d0 <alltraps>

801081b2 <vector203>:
.globl vector203
vector203:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $203
801081b4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801081b9:	e9 12 f1 ff ff       	jmp    801072d0 <alltraps>

801081be <vector204>:
.globl vector204
vector204:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $204
801081c0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801081c5:	e9 06 f1 ff ff       	jmp    801072d0 <alltraps>

801081ca <vector205>:
.globl vector205
vector205:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $205
801081cc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801081d1:	e9 fa f0 ff ff       	jmp    801072d0 <alltraps>

801081d6 <vector206>:
.globl vector206
vector206:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $206
801081d8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801081dd:	e9 ee f0 ff ff       	jmp    801072d0 <alltraps>

801081e2 <vector207>:
.globl vector207
vector207:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $207
801081e4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801081e9:	e9 e2 f0 ff ff       	jmp    801072d0 <alltraps>

801081ee <vector208>:
.globl vector208
vector208:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $208
801081f0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801081f5:	e9 d6 f0 ff ff       	jmp    801072d0 <alltraps>

801081fa <vector209>:
.globl vector209
vector209:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $209
801081fc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108201:	e9 ca f0 ff ff       	jmp    801072d0 <alltraps>

80108206 <vector210>:
.globl vector210
vector210:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $210
80108208:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010820d:	e9 be f0 ff ff       	jmp    801072d0 <alltraps>

80108212 <vector211>:
.globl vector211
vector211:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $211
80108214:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108219:	e9 b2 f0 ff ff       	jmp    801072d0 <alltraps>

8010821e <vector212>:
.globl vector212
vector212:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $212
80108220:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108225:	e9 a6 f0 ff ff       	jmp    801072d0 <alltraps>

8010822a <vector213>:
.globl vector213
vector213:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $213
8010822c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108231:	e9 9a f0 ff ff       	jmp    801072d0 <alltraps>

80108236 <vector214>:
.globl vector214
vector214:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $214
80108238:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010823d:	e9 8e f0 ff ff       	jmp    801072d0 <alltraps>

80108242 <vector215>:
.globl vector215
vector215:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $215
80108244:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108249:	e9 82 f0 ff ff       	jmp    801072d0 <alltraps>

8010824e <vector216>:
.globl vector216
vector216:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $216
80108250:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108255:	e9 76 f0 ff ff       	jmp    801072d0 <alltraps>

8010825a <vector217>:
.globl vector217
vector217:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $217
8010825c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108261:	e9 6a f0 ff ff       	jmp    801072d0 <alltraps>

80108266 <vector218>:
.globl vector218
vector218:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $218
80108268:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010826d:	e9 5e f0 ff ff       	jmp    801072d0 <alltraps>

80108272 <vector219>:
.globl vector219
vector219:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $219
80108274:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108279:	e9 52 f0 ff ff       	jmp    801072d0 <alltraps>

8010827e <vector220>:
.globl vector220
vector220:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $220
80108280:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108285:	e9 46 f0 ff ff       	jmp    801072d0 <alltraps>

8010828a <vector221>:
.globl vector221
vector221:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $221
8010828c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108291:	e9 3a f0 ff ff       	jmp    801072d0 <alltraps>

80108296 <vector222>:
.globl vector222
vector222:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $222
80108298:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010829d:	e9 2e f0 ff ff       	jmp    801072d0 <alltraps>

801082a2 <vector223>:
.globl vector223
vector223:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $223
801082a4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801082a9:	e9 22 f0 ff ff       	jmp    801072d0 <alltraps>

801082ae <vector224>:
.globl vector224
vector224:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $224
801082b0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801082b5:	e9 16 f0 ff ff       	jmp    801072d0 <alltraps>

801082ba <vector225>:
.globl vector225
vector225:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $225
801082bc:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801082c1:	e9 0a f0 ff ff       	jmp    801072d0 <alltraps>

801082c6 <vector226>:
.globl vector226
vector226:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $226
801082c8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801082cd:	e9 fe ef ff ff       	jmp    801072d0 <alltraps>

801082d2 <vector227>:
.globl vector227
vector227:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $227
801082d4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801082d9:	e9 f2 ef ff ff       	jmp    801072d0 <alltraps>

801082de <vector228>:
.globl vector228
vector228:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $228
801082e0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801082e5:	e9 e6 ef ff ff       	jmp    801072d0 <alltraps>

801082ea <vector229>:
.globl vector229
vector229:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $229
801082ec:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801082f1:	e9 da ef ff ff       	jmp    801072d0 <alltraps>

801082f6 <vector230>:
.globl vector230
vector230:
  pushl $0
801082f6:	6a 00                	push   $0x0
  pushl $230
801082f8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801082fd:	e9 ce ef ff ff       	jmp    801072d0 <alltraps>

80108302 <vector231>:
.globl vector231
vector231:
  pushl $0
80108302:	6a 00                	push   $0x0
  pushl $231
80108304:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108309:	e9 c2 ef ff ff       	jmp    801072d0 <alltraps>

8010830e <vector232>:
.globl vector232
vector232:
  pushl $0
8010830e:	6a 00                	push   $0x0
  pushl $232
80108310:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108315:	e9 b6 ef ff ff       	jmp    801072d0 <alltraps>

8010831a <vector233>:
.globl vector233
vector233:
  pushl $0
8010831a:	6a 00                	push   $0x0
  pushl $233
8010831c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108321:	e9 aa ef ff ff       	jmp    801072d0 <alltraps>

80108326 <vector234>:
.globl vector234
vector234:
  pushl $0
80108326:	6a 00                	push   $0x0
  pushl $234
80108328:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010832d:	e9 9e ef ff ff       	jmp    801072d0 <alltraps>

80108332 <vector235>:
.globl vector235
vector235:
  pushl $0
80108332:	6a 00                	push   $0x0
  pushl $235
80108334:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108339:	e9 92 ef ff ff       	jmp    801072d0 <alltraps>

8010833e <vector236>:
.globl vector236
vector236:
  pushl $0
8010833e:	6a 00                	push   $0x0
  pushl $236
80108340:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108345:	e9 86 ef ff ff       	jmp    801072d0 <alltraps>

8010834a <vector237>:
.globl vector237
vector237:
  pushl $0
8010834a:	6a 00                	push   $0x0
  pushl $237
8010834c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108351:	e9 7a ef ff ff       	jmp    801072d0 <alltraps>

80108356 <vector238>:
.globl vector238
vector238:
  pushl $0
80108356:	6a 00                	push   $0x0
  pushl $238
80108358:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010835d:	e9 6e ef ff ff       	jmp    801072d0 <alltraps>

80108362 <vector239>:
.globl vector239
vector239:
  pushl $0
80108362:	6a 00                	push   $0x0
  pushl $239
80108364:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108369:	e9 62 ef ff ff       	jmp    801072d0 <alltraps>

8010836e <vector240>:
.globl vector240
vector240:
  pushl $0
8010836e:	6a 00                	push   $0x0
  pushl $240
80108370:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108375:	e9 56 ef ff ff       	jmp    801072d0 <alltraps>

8010837a <vector241>:
.globl vector241
vector241:
  pushl $0
8010837a:	6a 00                	push   $0x0
  pushl $241
8010837c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108381:	e9 4a ef ff ff       	jmp    801072d0 <alltraps>

80108386 <vector242>:
.globl vector242
vector242:
  pushl $0
80108386:	6a 00                	push   $0x0
  pushl $242
80108388:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010838d:	e9 3e ef ff ff       	jmp    801072d0 <alltraps>

80108392 <vector243>:
.globl vector243
vector243:
  pushl $0
80108392:	6a 00                	push   $0x0
  pushl $243
80108394:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108399:	e9 32 ef ff ff       	jmp    801072d0 <alltraps>

8010839e <vector244>:
.globl vector244
vector244:
  pushl $0
8010839e:	6a 00                	push   $0x0
  pushl $244
801083a0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801083a5:	e9 26 ef ff ff       	jmp    801072d0 <alltraps>

801083aa <vector245>:
.globl vector245
vector245:
  pushl $0
801083aa:	6a 00                	push   $0x0
  pushl $245
801083ac:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801083b1:	e9 1a ef ff ff       	jmp    801072d0 <alltraps>

801083b6 <vector246>:
.globl vector246
vector246:
  pushl $0
801083b6:	6a 00                	push   $0x0
  pushl $246
801083b8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801083bd:	e9 0e ef ff ff       	jmp    801072d0 <alltraps>

801083c2 <vector247>:
.globl vector247
vector247:
  pushl $0
801083c2:	6a 00                	push   $0x0
  pushl $247
801083c4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801083c9:	e9 02 ef ff ff       	jmp    801072d0 <alltraps>

801083ce <vector248>:
.globl vector248
vector248:
  pushl $0
801083ce:	6a 00                	push   $0x0
  pushl $248
801083d0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801083d5:	e9 f6 ee ff ff       	jmp    801072d0 <alltraps>

801083da <vector249>:
.globl vector249
vector249:
  pushl $0
801083da:	6a 00                	push   $0x0
  pushl $249
801083dc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801083e1:	e9 ea ee ff ff       	jmp    801072d0 <alltraps>

801083e6 <vector250>:
.globl vector250
vector250:
  pushl $0
801083e6:	6a 00                	push   $0x0
  pushl $250
801083e8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801083ed:	e9 de ee ff ff       	jmp    801072d0 <alltraps>

801083f2 <vector251>:
.globl vector251
vector251:
  pushl $0
801083f2:	6a 00                	push   $0x0
  pushl $251
801083f4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801083f9:	e9 d2 ee ff ff       	jmp    801072d0 <alltraps>

801083fe <vector252>:
.globl vector252
vector252:
  pushl $0
801083fe:	6a 00                	push   $0x0
  pushl $252
80108400:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108405:	e9 c6 ee ff ff       	jmp    801072d0 <alltraps>

8010840a <vector253>:
.globl vector253
vector253:
  pushl $0
8010840a:	6a 00                	push   $0x0
  pushl $253
8010840c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108411:	e9 ba ee ff ff       	jmp    801072d0 <alltraps>

80108416 <vector254>:
.globl vector254
vector254:
  pushl $0
80108416:	6a 00                	push   $0x0
  pushl $254
80108418:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010841d:	e9 ae ee ff ff       	jmp    801072d0 <alltraps>

80108422 <vector255>:
.globl vector255
vector255:
  pushl $0
80108422:	6a 00                	push   $0x0
  pushl $255
80108424:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108429:	e9 a2 ee ff ff       	jmp    801072d0 <alltraps>
	...

80108430 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108430:	55                   	push   %ebp
80108431:	89 e5                	mov    %esp,%ebp
80108433:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108436:	8b 45 0c             	mov    0xc(%ebp),%eax
80108439:	83 e8 01             	sub    $0x1,%eax
8010843c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108440:	8b 45 08             	mov    0x8(%ebp),%eax
80108443:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108447:	8b 45 08             	mov    0x8(%ebp),%eax
8010844a:	c1 e8 10             	shr    $0x10,%eax
8010844d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108451:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108454:	0f 01 10             	lgdtl  (%eax)
}
80108457:	c9                   	leave  
80108458:	c3                   	ret    

80108459 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108459:	55                   	push   %ebp
8010845a:	89 e5                	mov    %esp,%ebp
8010845c:	83 ec 04             	sub    $0x4,%esp
8010845f:	8b 45 08             	mov    0x8(%ebp),%eax
80108462:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108466:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010846a:	0f 00 d8             	ltr    %ax
}
8010846d:	c9                   	leave  
8010846e:	c3                   	ret    

8010846f <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010846f:	55                   	push   %ebp
80108470:	89 e5                	mov    %esp,%ebp
80108472:	83 ec 04             	sub    $0x4,%esp
80108475:	8b 45 08             	mov    0x8(%ebp),%eax
80108478:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010847c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108480:	8e e8                	mov    %eax,%gs
}
80108482:	c9                   	leave  
80108483:	c3                   	ret    

80108484 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108484:	55                   	push   %ebp
80108485:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108487:	8b 45 08             	mov    0x8(%ebp),%eax
8010848a:	0f 22 d8             	mov    %eax,%cr3
}
8010848d:	5d                   	pop    %ebp
8010848e:	c3                   	ret    

8010848f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010848f:	55                   	push   %ebp
80108490:	89 e5                	mov    %esp,%ebp
80108492:	8b 45 08             	mov    0x8(%ebp),%eax
80108495:	05 00 00 00 80       	add    $0x80000000,%eax
8010849a:	5d                   	pop    %ebp
8010849b:	c3                   	ret    

8010849c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010849c:	55                   	push   %ebp
8010849d:	89 e5                	mov    %esp,%ebp
8010849f:	8b 45 08             	mov    0x8(%ebp),%eax
801084a2:	05 00 00 00 80       	add    $0x80000000,%eax
801084a7:	5d                   	pop    %ebp
801084a8:	c3                   	ret    

801084a9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801084a9:	55                   	push   %ebp
801084aa:	89 e5                	mov    %esp,%ebp
801084ac:	53                   	push   %ebx
801084ad:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801084b0:	e8 da b2 ff ff       	call   8010378f <cpunum>
801084b5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801084bb:	05 a0 3b 11 80       	add    $0x80113ba0,%eax
801084c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801084c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801084cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cf:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801084d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801084dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084df:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084e3:	83 e2 f0             	and    $0xfffffff0,%edx
801084e6:	83 ca 0a             	or     $0xa,%edx
801084e9:	88 50 7d             	mov    %dl,0x7d(%eax)
801084ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ef:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084f3:	83 ca 10             	or     $0x10,%edx
801084f6:	88 50 7d             	mov    %dl,0x7d(%eax)
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108500:	83 e2 9f             	and    $0xffffff9f,%edx
80108503:	88 50 7d             	mov    %dl,0x7d(%eax)
80108506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108509:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010850d:	83 ca 80             	or     $0xffffff80,%edx
80108510:	88 50 7d             	mov    %dl,0x7d(%eax)
80108513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108516:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010851a:	83 ca 0f             	or     $0xf,%edx
8010851d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108523:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108527:	83 e2 ef             	and    $0xffffffef,%edx
8010852a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010852d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108530:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108534:	83 e2 df             	and    $0xffffffdf,%edx
80108537:	88 50 7e             	mov    %dl,0x7e(%eax)
8010853a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108541:	83 ca 40             	or     $0x40,%edx
80108544:	88 50 7e             	mov    %dl,0x7e(%eax)
80108547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010854e:	83 ca 80             	or     $0xffffff80,%edx
80108551:	88 50 7e             	mov    %dl,0x7e(%eax)
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010855b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108565:	ff ff 
80108567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108571:	00 00 
80108573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108576:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010857d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108580:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108587:	83 e2 f0             	and    $0xfffffff0,%edx
8010858a:	83 ca 02             	or     $0x2,%edx
8010858d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108596:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010859d:	83 ca 10             	or     $0x10,%edx
801085a0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085b0:	83 e2 9f             	and    $0xffffff9f,%edx
801085b3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085c3:	83 ca 80             	or     $0xffffff80,%edx
801085c6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085d6:	83 ca 0f             	or     $0xf,%edx
801085d9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085e9:	83 e2 ef             	and    $0xffffffef,%edx
801085ec:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085fc:	83 e2 df             	and    $0xffffffdf,%edx
801085ff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010860f:	83 ca 40             	or     $0x40,%edx
80108612:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108622:	83 ca 80             	or     $0xffffff80,%edx
80108625:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108638:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010863f:	ff ff 
80108641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108644:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010864b:	00 00 
8010864d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108650:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108661:	83 e2 f0             	and    $0xfffffff0,%edx
80108664:	83 ca 0a             	or     $0xa,%edx
80108667:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010866d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108670:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108677:	83 ca 10             	or     $0x10,%edx
8010867a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108683:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010868a:	83 ca 60             	or     $0x60,%edx
8010868d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108696:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010869d:	83 ca 80             	or     $0xffffff80,%edx
801086a0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086b0:	83 ca 0f             	or     $0xf,%edx
801086b3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086c3:	83 e2 ef             	and    $0xffffffef,%edx
801086c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086d6:	83 e2 df             	and    $0xffffffdf,%edx
801086d9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086e9:	83 ca 40             	or     $0x40,%edx
801086ec:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086fc:	83 ca 80             	or     $0xffffff80,%edx
801086ff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108708:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010870f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108712:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108719:	ff ff 
8010871b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108725:	00 00 
80108727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108734:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010873b:	83 e2 f0             	and    $0xfffffff0,%edx
8010873e:	83 ca 02             	or     $0x2,%edx
80108741:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108751:	83 ca 10             	or     $0x10,%edx
80108754:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010875a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108764:	83 ca 60             	or     $0x60,%edx
80108767:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010876d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108770:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108777:	83 ca 80             	or     $0xffffff80,%edx
8010877a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010878a:	83 ca 0f             	or     $0xf,%edx
8010878d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108796:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010879d:	83 e2 ef             	and    $0xffffffef,%edx
801087a0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087b0:	83 e2 df             	and    $0xffffffdf,%edx
801087b3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087c3:	83 ca 40             	or     $0x40,%edx
801087c6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087d6:	83 ca 80             	or     $0xffffff80,%edx
801087d9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e2:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801087e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ec:	05 b4 00 00 00       	add    $0xb4,%eax
801087f1:	89 c3                	mov    %eax,%ebx
801087f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f6:	05 b4 00 00 00       	add    $0xb4,%eax
801087fb:	c1 e8 10             	shr    $0x10,%eax
801087fe:	89 c1                	mov    %eax,%ecx
80108800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108803:	05 b4 00 00 00       	add    $0xb4,%eax
80108808:	c1 e8 18             	shr    $0x18,%eax
8010880b:	89 c2                	mov    %eax,%edx
8010880d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108810:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108817:	00 00 
80108819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108826:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
8010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108836:	83 e1 f0             	and    $0xfffffff0,%ecx
80108839:	83 c9 02             	or     $0x2,%ecx
8010883c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108845:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010884c:	83 c9 10             	or     $0x10,%ecx
8010884f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108858:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010885f:	83 e1 9f             	and    $0xffffff9f,%ecx
80108862:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108872:	83 c9 80             	or     $0xffffff80,%ecx
80108875:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010887b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108885:	83 e1 f0             	and    $0xfffffff0,%ecx
80108888:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010888e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108891:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108898:	83 e1 ef             	and    $0xffffffef,%ecx
8010889b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801088ab:	83 e1 df             	and    $0xffffffdf,%ecx
801088ae:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801088be:	83 c9 40             	or     $0x40,%ecx
801088c1:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801088d1:	83 c9 80             	or     $0xffffff80,%ecx
801088d4:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801088da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dd:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801088e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e6:	83 c0 70             	add    $0x70,%eax
801088e9:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801088f0:	00 
801088f1:	89 04 24             	mov    %eax,(%esp)
801088f4:	e8 37 fb ff ff       	call   80108430 <lgdt>
  loadgs(SEG_KCPU << 3);
801088f9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108900:	e8 6a fb ff ff       	call   8010846f <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80108905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108908:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010890e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108915:	00 00 00 00 
}
80108919:	83 c4 24             	add    $0x24,%esp
8010891c:	5b                   	pop    %ebx
8010891d:	5d                   	pop    %ebp
8010891e:	c3                   	ret    

8010891f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010891f:	55                   	push   %ebp
80108920:	89 e5                	mov    %esp,%ebp
80108922:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108925:	8b 45 0c             	mov    0xc(%ebp),%eax
80108928:	c1 e8 16             	shr    $0x16,%eax
8010892b:	c1 e0 02             	shl    $0x2,%eax
8010892e:	03 45 08             	add    0x8(%ebp),%eax
80108931:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108937:	8b 00                	mov    (%eax),%eax
80108939:	83 e0 01             	and    $0x1,%eax
8010893c:	84 c0                	test   %al,%al
8010893e:	74 17                	je     80108957 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108943:	8b 00                	mov    (%eax),%eax
80108945:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010894a:	89 04 24             	mov    %eax,(%esp)
8010894d:	e8 4a fb ff ff       	call   8010849c <p2v>
80108952:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108955:	eb 4b                	jmp    801089a2 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108957:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010895b:	74 0e                	je     8010896b <walkpgdir+0x4c>
8010895d:	e8 75 aa ff ff       	call   801033d7 <kalloc>
80108962:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108965:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108969:	75 07                	jne    80108972 <walkpgdir+0x53>
      return 0;
8010896b:	b8 00 00 00 00       	mov    $0x0,%eax
80108970:	eb 41                	jmp    801089b3 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108972:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108979:	00 
8010897a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108981:	00 
80108982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108985:	89 04 24             	mov    %eax,(%esp)
80108988:	e8 6d d4 ff ff       	call   80105dfa <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010898d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108990:	89 04 24             	mov    %eax,(%esp)
80108993:	e8 f7 fa ff ff       	call   8010848f <v2p>
80108998:	89 c2                	mov    %eax,%edx
8010899a:	83 ca 07             	or     $0x7,%edx
8010899d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801089a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801089a5:	c1 e8 0c             	shr    $0xc,%eax
801089a8:	25 ff 03 00 00       	and    $0x3ff,%eax
801089ad:	c1 e0 02             	shl    $0x2,%eax
801089b0:	03 45 f4             	add    -0xc(%ebp),%eax
}
801089b3:	c9                   	leave  
801089b4:	c3                   	ret    

801089b5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801089b5:	55                   	push   %ebp
801089b6:	89 e5                	mov    %esp,%ebp
801089b8:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801089bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801089be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801089c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801089c9:	03 45 10             	add    0x10(%ebp),%eax
801089cc:	83 e8 01             	sub    $0x1,%eax
801089cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801089d7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801089de:	00 
801089df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801089e6:	8b 45 08             	mov    0x8(%ebp),%eax
801089e9:	89 04 24             	mov    %eax,(%esp)
801089ec:	e8 2e ff ff ff       	call   8010891f <walkpgdir>
801089f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801089f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089f8:	75 07                	jne    80108a01 <mappages+0x4c>
      return -1;
801089fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089ff:	eb 46                	jmp    80108a47 <mappages+0x92>
    if(*pte & PTE_P)
80108a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a04:	8b 00                	mov    (%eax),%eax
80108a06:	83 e0 01             	and    $0x1,%eax
80108a09:	84 c0                	test   %al,%al
80108a0b:	74 0c                	je     80108a19 <mappages+0x64>
      panic("remap");
80108a0d:	c7 04 24 a8 98 10 80 	movl   $0x801098a8,(%esp)
80108a14:	e8 24 7b ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108a19:	8b 45 18             	mov    0x18(%ebp),%eax
80108a1c:	0b 45 14             	or     0x14(%ebp),%eax
80108a1f:	89 c2                	mov    %eax,%edx
80108a21:	83 ca 01             	or     $0x1,%edx
80108a24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a27:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a2f:	74 10                	je     80108a41 <mappages+0x8c>
      break;
    a += PGSIZE;
80108a31:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108a38:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108a3f:	eb 96                	jmp    801089d7 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108a41:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a47:	c9                   	leave  
80108a48:	c3                   	ret    

80108a49 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108a49:	55                   	push   %ebp
80108a4a:	89 e5                	mov    %esp,%ebp
80108a4c:	53                   	push   %ebx
80108a4d:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108a50:	e8 82 a9 ff ff       	call   801033d7 <kalloc>
80108a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a5c:	75 0a                	jne    80108a68 <setupkvm+0x1f>
    return 0;
80108a5e:	b8 00 00 00 00       	mov    $0x0,%eax
80108a63:	e9 98 00 00 00       	jmp    80108b00 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108a68:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a6f:	00 
80108a70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108a77:	00 
80108a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a7b:	89 04 24             	mov    %eax,(%esp)
80108a7e:	e8 77 d3 ff ff       	call   80105dfa <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108a83:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108a8a:	e8 0d fa ff ff       	call   8010849c <p2v>
80108a8f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108a94:	76 0c                	jbe    80108aa2 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108a96:	c7 04 24 ae 98 10 80 	movl   $0x801098ae,(%esp)
80108a9d:	e8 9b 7a ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108aa2:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108aa9:	eb 49                	jmp    80108af4 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108aae:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108ab4:	8b 50 04             	mov    0x4(%eax),%edx
80108ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aba:	8b 58 08             	mov    0x8(%eax),%ebx
80108abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac0:	8b 40 04             	mov    0x4(%eax),%eax
80108ac3:	29 c3                	sub    %eax,%ebx
80108ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac8:	8b 00                	mov    (%eax),%eax
80108aca:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108ace:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108ad2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108add:	89 04 24             	mov    %eax,(%esp)
80108ae0:	e8 d0 fe ff ff       	call   801089b5 <mappages>
80108ae5:	85 c0                	test   %eax,%eax
80108ae7:	79 07                	jns    80108af0 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108ae9:	b8 00 00 00 00       	mov    $0x0,%eax
80108aee:	eb 10                	jmp    80108b00 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108af0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108af4:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108afb:	72 ae                	jb     80108aab <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108b00:	83 c4 34             	add    $0x34,%esp
80108b03:	5b                   	pop    %ebx
80108b04:	5d                   	pop    %ebp
80108b05:	c3                   	ret    

80108b06 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108b06:	55                   	push   %ebp
80108b07:	89 e5                	mov    %esp,%ebp
80108b09:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108b0c:	e8 38 ff ff ff       	call   80108a49 <setupkvm>
80108b11:	a3 78 6e 11 80       	mov    %eax,0x80116e78
  switchkvm();
80108b16:	e8 02 00 00 00       	call   80108b1d <switchkvm>
}
80108b1b:	c9                   	leave  
80108b1c:	c3                   	ret    

80108b1d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108b1d:	55                   	push   %ebp
80108b1e:	89 e5                	mov    %esp,%ebp
80108b20:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108b23:	a1 78 6e 11 80       	mov    0x80116e78,%eax
80108b28:	89 04 24             	mov    %eax,(%esp)
80108b2b:	e8 5f f9 ff ff       	call   8010848f <v2p>
80108b30:	89 04 24             	mov    %eax,(%esp)
80108b33:	e8 4c f9 ff ff       	call   80108484 <lcr3>
}
80108b38:	c9                   	leave  
80108b39:	c3                   	ret    

80108b3a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108b3a:	55                   	push   %ebp
80108b3b:	89 e5                	mov    %esp,%ebp
80108b3d:	53                   	push   %ebx
80108b3e:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108b41:	e8 ad d1 ff ff       	call   80105cf3 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108b46:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b4c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b53:	83 c2 08             	add    $0x8,%edx
80108b56:	89 d3                	mov    %edx,%ebx
80108b58:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b5f:	83 c2 08             	add    $0x8,%edx
80108b62:	c1 ea 10             	shr    $0x10,%edx
80108b65:	89 d1                	mov    %edx,%ecx
80108b67:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b6e:	83 c2 08             	add    $0x8,%edx
80108b71:	c1 ea 18             	shr    $0x18,%edx
80108b74:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108b7b:	67 00 
80108b7d:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108b84:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108b8a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108b91:	83 e1 f0             	and    $0xfffffff0,%ecx
80108b94:	83 c9 09             	or     $0x9,%ecx
80108b97:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108b9d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108ba4:	83 c9 10             	or     $0x10,%ecx
80108ba7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108bad:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108bb4:	83 e1 9f             	and    $0xffffff9f,%ecx
80108bb7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108bbd:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108bc4:	83 c9 80             	or     $0xffffff80,%ecx
80108bc7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108bcd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108bd4:	83 e1 f0             	and    $0xfffffff0,%ecx
80108bd7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108bdd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108be4:	83 e1 ef             	and    $0xffffffef,%ecx
80108be7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108bed:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108bf4:	83 e1 df             	and    $0xffffffdf,%ecx
80108bf7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108bfd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108c04:	83 c9 40             	or     $0x40,%ecx
80108c07:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108c0d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108c14:	83 e1 7f             	and    $0x7f,%ecx
80108c17:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108c1d:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108c23:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c29:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c30:	83 e2 ef             	and    $0xffffffef,%edx
80108c33:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108c39:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c3f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108c45:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c4b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108c52:	8b 52 08             	mov    0x8(%edx),%edx
80108c55:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108c5b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108c5e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108c65:	e8 ef f7 ff ff       	call   80108459 <ltr>
  if(p->pgdir == 0)
80108c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80108c6d:	8b 40 04             	mov    0x4(%eax),%eax
80108c70:	85 c0                	test   %eax,%eax
80108c72:	75 0c                	jne    80108c80 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108c74:	c7 04 24 bf 98 10 80 	movl   $0x801098bf,(%esp)
80108c7b:	e8 bd 78 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108c80:	8b 45 08             	mov    0x8(%ebp),%eax
80108c83:	8b 40 04             	mov    0x4(%eax),%eax
80108c86:	89 04 24             	mov    %eax,(%esp)
80108c89:	e8 01 f8 ff ff       	call   8010848f <v2p>
80108c8e:	89 04 24             	mov    %eax,(%esp)
80108c91:	e8 ee f7 ff ff       	call   80108484 <lcr3>
  popcli();
80108c96:	e8 a0 d0 ff ff       	call   80105d3b <popcli>
}
80108c9b:	83 c4 14             	add    $0x14,%esp
80108c9e:	5b                   	pop    %ebx
80108c9f:	5d                   	pop    %ebp
80108ca0:	c3                   	ret    

80108ca1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108ca1:	55                   	push   %ebp
80108ca2:	89 e5                	mov    %esp,%ebp
80108ca4:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108ca7:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108cae:	76 0c                	jbe    80108cbc <inituvm+0x1b>
    panic("inituvm: more than a page");
80108cb0:	c7 04 24 d3 98 10 80 	movl   $0x801098d3,(%esp)
80108cb7:	e8 81 78 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108cbc:	e8 16 a7 ff ff       	call   801033d7 <kalloc>
80108cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108cc4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ccb:	00 
80108ccc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108cd3:	00 
80108cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd7:	89 04 24             	mov    %eax,(%esp)
80108cda:	e8 1b d1 ff ff       	call   80105dfa <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce2:	89 04 24             	mov    %eax,(%esp)
80108ce5:	e8 a5 f7 ff ff       	call   8010848f <v2p>
80108cea:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108cf1:	00 
80108cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108cf6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108cfd:	00 
80108cfe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108d05:	00 
80108d06:	8b 45 08             	mov    0x8(%ebp),%eax
80108d09:	89 04 24             	mov    %eax,(%esp)
80108d0c:	e8 a4 fc ff ff       	call   801089b5 <mappages>
  memmove(mem, init, sz);
80108d11:	8b 45 10             	mov    0x10(%ebp),%eax
80108d14:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d18:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d22:	89 04 24             	mov    %eax,(%esp)
80108d25:	e8 a3 d1 ff ff       	call   80105ecd <memmove>
}
80108d2a:	c9                   	leave  
80108d2b:	c3                   	ret    

80108d2c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108d2c:	55                   	push   %ebp
80108d2d:	89 e5                	mov    %esp,%ebp
80108d2f:	53                   	push   %ebx
80108d30:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d36:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d3b:	85 c0                	test   %eax,%eax
80108d3d:	74 0c                	je     80108d4b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108d3f:	c7 04 24 f0 98 10 80 	movl   $0x801098f0,(%esp)
80108d46:	e8 f2 77 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108d4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d52:	e9 ad 00 00 00       	jmp    80108e04 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d5d:	01 d0                	add    %edx,%eax
80108d5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d66:	00 
80108d67:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d6e:	89 04 24             	mov    %eax,(%esp)
80108d71:	e8 a9 fb ff ff       	call   8010891f <walkpgdir>
80108d76:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d79:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d7d:	75 0c                	jne    80108d8b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108d7f:	c7 04 24 13 99 10 80 	movl   $0x80109913,(%esp)
80108d86:	e8 b2 77 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d8e:	8b 00                	mov    (%eax),%eax
80108d90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d95:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d9b:	8b 55 18             	mov    0x18(%ebp),%edx
80108d9e:	89 d1                	mov    %edx,%ecx
80108da0:	29 c1                	sub    %eax,%ecx
80108da2:	89 c8                	mov    %ecx,%eax
80108da4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108da9:	77 11                	ja     80108dbc <loaduvm+0x90>
      n = sz - i;
80108dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dae:	8b 55 18             	mov    0x18(%ebp),%edx
80108db1:	89 d1                	mov    %edx,%ecx
80108db3:	29 c1                	sub    %eax,%ecx
80108db5:	89 c8                	mov    %ecx,%eax
80108db7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108dba:	eb 07                	jmp    80108dc3 <loaduvm+0x97>
    else
      n = PGSIZE;
80108dbc:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc6:	8b 55 14             	mov    0x14(%ebp),%edx
80108dc9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108dcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dcf:	89 04 24             	mov    %eax,(%esp)
80108dd2:	e8 c5 f6 ff ff       	call   8010849c <p2v>
80108dd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108dda:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108de2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108de6:	8b 45 10             	mov    0x10(%ebp),%eax
80108de9:	89 04 24             	mov    %eax,(%esp)
80108dec:	e8 10 98 ff ff       	call   80102601 <readi>
80108df1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108df4:	74 07                	je     80108dfd <loaduvm+0xd1>
      return -1;
80108df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108dfb:	eb 18                	jmp    80108e15 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108dfd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e07:	3b 45 18             	cmp    0x18(%ebp),%eax
80108e0a:	0f 82 47 ff ff ff    	jb     80108d57 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e15:	83 c4 24             	add    $0x24,%esp
80108e18:	5b                   	pop    %ebx
80108e19:	5d                   	pop    %ebp
80108e1a:	c3                   	ret    

80108e1b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108e1b:	55                   	push   %ebp
80108e1c:	89 e5                	mov    %esp,%ebp
80108e1e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108e21:	8b 45 10             	mov    0x10(%ebp),%eax
80108e24:	85 c0                	test   %eax,%eax
80108e26:	79 0a                	jns    80108e32 <allocuvm+0x17>
    return 0;
80108e28:	b8 00 00 00 00       	mov    $0x0,%eax
80108e2d:	e9 c1 00 00 00       	jmp    80108ef3 <allocuvm+0xd8>
  if(newsz < oldsz)
80108e32:	8b 45 10             	mov    0x10(%ebp),%eax
80108e35:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e38:	73 08                	jae    80108e42 <allocuvm+0x27>
    return oldsz;
80108e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e3d:	e9 b1 00 00 00       	jmp    80108ef3 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108e42:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e45:	05 ff 0f 00 00       	add    $0xfff,%eax
80108e4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108e52:	e9 8d 00 00 00       	jmp    80108ee4 <allocuvm+0xc9>
    mem = kalloc();
80108e57:	e8 7b a5 ff ff       	call   801033d7 <kalloc>
80108e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108e5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e63:	75 2c                	jne    80108e91 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108e65:	c7 04 24 31 99 10 80 	movl   $0x80109931,(%esp)
80108e6c:	e8 30 75 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108e71:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e74:	89 44 24 08          	mov    %eax,0x8(%esp)
80108e78:	8b 45 10             	mov    0x10(%ebp),%eax
80108e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108e82:	89 04 24             	mov    %eax,(%esp)
80108e85:	e8 6b 00 00 00       	call   80108ef5 <deallocuvm>
      return 0;
80108e8a:	b8 00 00 00 00       	mov    $0x0,%eax
80108e8f:	eb 62                	jmp    80108ef3 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108e91:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108e98:	00 
80108e99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108ea0:	00 
80108ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea4:	89 04 24             	mov    %eax,(%esp)
80108ea7:	e8 4e cf ff ff       	call   80105dfa <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eaf:	89 04 24             	mov    %eax,(%esp)
80108eb2:	e8 d8 f5 ff ff       	call   8010848f <v2p>
80108eb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108eba:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108ec1:	00 
80108ec2:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108ec6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ecd:	00 
80108ece:	89 54 24 04          	mov    %edx,0x4(%esp)
80108ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed5:	89 04 24             	mov    %eax,(%esp)
80108ed8:	e8 d8 fa ff ff       	call   801089b5 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108edd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee7:	3b 45 10             	cmp    0x10(%ebp),%eax
80108eea:	0f 82 67 ff ff ff    	jb     80108e57 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108ef0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108ef3:	c9                   	leave  
80108ef4:	c3                   	ret    

80108ef5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108ef5:	55                   	push   %ebp
80108ef6:	89 e5                	mov    %esp,%ebp
80108ef8:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108efb:	8b 45 10             	mov    0x10(%ebp),%eax
80108efe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f01:	72 08                	jb     80108f0b <deallocuvm+0x16>
    return oldsz;
80108f03:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f06:	e9 a4 00 00 00       	jmp    80108faf <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108f0b:	8b 45 10             	mov    0x10(%ebp),%eax
80108f0e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108f1b:	e9 80 00 00 00       	jmp    80108fa0 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f2a:	00 
80108f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f32:	89 04 24             	mov    %eax,(%esp)
80108f35:	e8 e5 f9 ff ff       	call   8010891f <walkpgdir>
80108f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108f3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f41:	75 09                	jne    80108f4c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108f43:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108f4a:	eb 4d                	jmp    80108f99 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f4f:	8b 00                	mov    (%eax),%eax
80108f51:	83 e0 01             	and    $0x1,%eax
80108f54:	84 c0                	test   %al,%al
80108f56:	74 41                	je     80108f99 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5b:	8b 00                	mov    (%eax),%eax
80108f5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f62:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108f65:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f69:	75 0c                	jne    80108f77 <deallocuvm+0x82>
        panic("kfree");
80108f6b:	c7 04 24 49 99 10 80 	movl   $0x80109949,(%esp)
80108f72:	e8 c6 75 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108f77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f7a:	89 04 24             	mov    %eax,(%esp)
80108f7d:	e8 1a f5 ff ff       	call   8010849c <p2v>
80108f82:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108f85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f88:	89 04 24             	mov    %eax,(%esp)
80108f8b:	e8 ae a3 ff ff       	call   8010333e <kfree>
      *pte = 0;
80108f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108f99:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fa6:	0f 82 74 ff ff ff    	jb     80108f20 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108fac:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108faf:	c9                   	leave  
80108fb0:	c3                   	ret    

80108fb1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108fb1:	55                   	push   %ebp
80108fb2:	89 e5                	mov    %esp,%ebp
80108fb4:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108fb7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108fbb:	75 0c                	jne    80108fc9 <freevm+0x18>
    panic("freevm: no pgdir");
80108fbd:	c7 04 24 4f 99 10 80 	movl   $0x8010994f,(%esp)
80108fc4:	e8 74 75 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108fc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108fd0:	00 
80108fd1:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108fd8:	80 
80108fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80108fdc:	89 04 24             	mov    %eax,(%esp)
80108fdf:	e8 11 ff ff ff       	call   80108ef5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108fe4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108feb:	eb 3c                	jmp    80109029 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff0:	c1 e0 02             	shl    $0x2,%eax
80108ff3:	03 45 08             	add    0x8(%ebp),%eax
80108ff6:	8b 00                	mov    (%eax),%eax
80108ff8:	83 e0 01             	and    $0x1,%eax
80108ffb:	84 c0                	test   %al,%al
80108ffd:	74 26                	je     80109025 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109002:	c1 e0 02             	shl    $0x2,%eax
80109005:	03 45 08             	add    0x8(%ebp),%eax
80109008:	8b 00                	mov    (%eax),%eax
8010900a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010900f:	89 04 24             	mov    %eax,(%esp)
80109012:	e8 85 f4 ff ff       	call   8010849c <p2v>
80109017:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010901a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010901d:	89 04 24             	mov    %eax,(%esp)
80109020:	e8 19 a3 ff ff       	call   8010333e <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109025:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109029:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109030:	76 bb                	jbe    80108fed <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109032:	8b 45 08             	mov    0x8(%ebp),%eax
80109035:	89 04 24             	mov    %eax,(%esp)
80109038:	e8 01 a3 ff ff       	call   8010333e <kfree>
}
8010903d:	c9                   	leave  
8010903e:	c3                   	ret    

8010903f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010903f:	55                   	push   %ebp
80109040:	89 e5                	mov    %esp,%ebp
80109042:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109045:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010904c:	00 
8010904d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109050:	89 44 24 04          	mov    %eax,0x4(%esp)
80109054:	8b 45 08             	mov    0x8(%ebp),%eax
80109057:	89 04 24             	mov    %eax,(%esp)
8010905a:	e8 c0 f8 ff ff       	call   8010891f <walkpgdir>
8010905f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109066:	75 0c                	jne    80109074 <clearpteu+0x35>
    panic("clearpteu");
80109068:	c7 04 24 60 99 10 80 	movl   $0x80109960,(%esp)
8010906f:	e8 c9 74 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80109074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109077:	8b 00                	mov    (%eax),%eax
80109079:	89 c2                	mov    %eax,%edx
8010907b:	83 e2 fb             	and    $0xfffffffb,%edx
8010907e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109081:	89 10                	mov    %edx,(%eax)
}
80109083:	c9                   	leave  
80109084:	c3                   	ret    

80109085 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109085:	55                   	push   %ebp
80109086:	89 e5                	mov    %esp,%ebp
80109088:	53                   	push   %ebx
80109089:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010908c:	e8 b8 f9 ff ff       	call   80108a49 <setupkvm>
80109091:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109094:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109098:	75 0a                	jne    801090a4 <copyuvm+0x1f>
    return 0;
8010909a:	b8 00 00 00 00       	mov    $0x0,%eax
8010909f:	e9 fd 00 00 00       	jmp    801091a1 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801090a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090ab:	e9 cc 00 00 00       	jmp    8010917c <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801090b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801090ba:	00 
801090bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801090bf:	8b 45 08             	mov    0x8(%ebp),%eax
801090c2:	89 04 24             	mov    %eax,(%esp)
801090c5:	e8 55 f8 ff ff       	call   8010891f <walkpgdir>
801090ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
801090cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801090d1:	75 0c                	jne    801090df <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801090d3:	c7 04 24 6a 99 10 80 	movl   $0x8010996a,(%esp)
801090da:	e8 5e 74 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801090df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090e2:	8b 00                	mov    (%eax),%eax
801090e4:	83 e0 01             	and    $0x1,%eax
801090e7:	85 c0                	test   %eax,%eax
801090e9:	75 0c                	jne    801090f7 <copyuvm+0x72>
      panic("copyuvm: page not present");
801090eb:	c7 04 24 84 99 10 80 	movl   $0x80109984,(%esp)
801090f2:	e8 46 74 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801090f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090fa:	8b 00                	mov    (%eax),%eax
801090fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109101:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109104:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109107:	8b 00                	mov    (%eax),%eax
80109109:	25 ff 0f 00 00       	and    $0xfff,%eax
8010910e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109111:	e8 c1 a2 ff ff       	call   801033d7 <kalloc>
80109116:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109119:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010911d:	74 6e                	je     8010918d <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010911f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109122:	89 04 24             	mov    %eax,(%esp)
80109125:	e8 72 f3 ff ff       	call   8010849c <p2v>
8010912a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109131:	00 
80109132:	89 44 24 04          	mov    %eax,0x4(%esp)
80109136:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109139:	89 04 24             	mov    %eax,(%esp)
8010913c:	e8 8c cd ff ff       	call   80105ecd <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109141:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109144:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109147:	89 04 24             	mov    %eax,(%esp)
8010914a:	e8 40 f3 ff ff       	call   8010848f <v2p>
8010914f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109152:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80109156:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010915a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109161:	00 
80109162:	89 54 24 04          	mov    %edx,0x4(%esp)
80109166:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109169:	89 04 24             	mov    %eax,(%esp)
8010916c:	e8 44 f8 ff ff       	call   801089b5 <mappages>
80109171:	85 c0                	test   %eax,%eax
80109173:	78 1b                	js     80109190 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109175:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010917c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109182:	0f 82 28 ff ff ff    	jb     801090b0 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109188:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010918b:	eb 14                	jmp    801091a1 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010918d:	90                   	nop
8010918e:	eb 01                	jmp    80109191 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109190:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109191:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109194:	89 04 24             	mov    %eax,(%esp)
80109197:	e8 15 fe ff ff       	call   80108fb1 <freevm>
  return 0;
8010919c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801091a1:	83 c4 44             	add    $0x44,%esp
801091a4:	5b                   	pop    %ebx
801091a5:	5d                   	pop    %ebp
801091a6:	c3                   	ret    

801091a7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801091a7:	55                   	push   %ebp
801091a8:	89 e5                	mov    %esp,%ebp
801091aa:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801091ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801091b4:	00 
801091b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801091b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801091bc:	8b 45 08             	mov    0x8(%ebp),%eax
801091bf:	89 04 24             	mov    %eax,(%esp)
801091c2:	e8 58 f7 ff ff       	call   8010891f <walkpgdir>
801091c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801091ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cd:	8b 00                	mov    (%eax),%eax
801091cf:	83 e0 01             	and    $0x1,%eax
801091d2:	85 c0                	test   %eax,%eax
801091d4:	75 07                	jne    801091dd <uva2ka+0x36>
    return 0;
801091d6:	b8 00 00 00 00       	mov    $0x0,%eax
801091db:	eb 25                	jmp    80109202 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801091dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e0:	8b 00                	mov    (%eax),%eax
801091e2:	83 e0 04             	and    $0x4,%eax
801091e5:	85 c0                	test   %eax,%eax
801091e7:	75 07                	jne    801091f0 <uva2ka+0x49>
    return 0;
801091e9:	b8 00 00 00 00       	mov    $0x0,%eax
801091ee:	eb 12                	jmp    80109202 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801091f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f3:	8b 00                	mov    (%eax),%eax
801091f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091fa:	89 04 24             	mov    %eax,(%esp)
801091fd:	e8 9a f2 ff ff       	call   8010849c <p2v>
}
80109202:	c9                   	leave  
80109203:	c3                   	ret    

80109204 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109204:	55                   	push   %ebp
80109205:	89 e5                	mov    %esp,%ebp
80109207:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010920a:	8b 45 10             	mov    0x10(%ebp),%eax
8010920d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109210:	e9 8b 00 00 00       	jmp    801092a0 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80109215:	8b 45 0c             	mov    0xc(%ebp),%eax
80109218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010921d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109220:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109223:	89 44 24 04          	mov    %eax,0x4(%esp)
80109227:	8b 45 08             	mov    0x8(%ebp),%eax
8010922a:	89 04 24             	mov    %eax,(%esp)
8010922d:	e8 75 ff ff ff       	call   801091a7 <uva2ka>
80109232:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109235:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109239:	75 07                	jne    80109242 <copyout+0x3e>
      return -1;
8010923b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109240:	eb 6d                	jmp    801092af <copyout+0xab>
    n = PGSIZE - (va - va0);
80109242:	8b 45 0c             	mov    0xc(%ebp),%eax
80109245:	8b 55 ec             	mov    -0x14(%ebp),%edx
80109248:	89 d1                	mov    %edx,%ecx
8010924a:	29 c1                	sub    %eax,%ecx
8010924c:	89 c8                	mov    %ecx,%eax
8010924e:	05 00 10 00 00       	add    $0x1000,%eax
80109253:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109259:	3b 45 14             	cmp    0x14(%ebp),%eax
8010925c:	76 06                	jbe    80109264 <copyout+0x60>
      n = len;
8010925e:	8b 45 14             	mov    0x14(%ebp),%eax
80109261:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109264:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109267:	8b 55 0c             	mov    0xc(%ebp),%edx
8010926a:	89 d1                	mov    %edx,%ecx
8010926c:	29 c1                	sub    %eax,%ecx
8010926e:	89 c8                	mov    %ecx,%eax
80109270:	03 45 e8             	add    -0x18(%ebp),%eax
80109273:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109276:	89 54 24 08          	mov    %edx,0x8(%esp)
8010927a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010927d:	89 54 24 04          	mov    %edx,0x4(%esp)
80109281:	89 04 24             	mov    %eax,(%esp)
80109284:	e8 44 cc ff ff       	call   80105ecd <memmove>
    len -= n;
80109289:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010928f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109292:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109295:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109298:	05 00 10 00 00       	add    $0x1000,%eax
8010929d:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801092a0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801092a4:	0f 85 6b ff ff ff    	jne    80109215 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801092aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092af:	c9                   	leave  
801092b0:	c3                   	ret    
