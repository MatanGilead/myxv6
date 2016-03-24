// Console input and output.
// Input is from the keyboard or serial port.
// Output is written to the screen and serial port.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "fs.h"
#include "file.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"


static void consputc(int);

static int panicked = 0;

static struct {
  struct spinlock lock;
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;

  i = 0;
  do{
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
    consputc(buf[i]);
}
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    if(c != '%'){
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
      consputc(c);
      break;
    }
  }

  if(locking)
    release(&cons.lock);
}

void
panic(char *s)
{
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
  for(;;)
    ;
}

//PAGEBREAK: 50
#define BACKSPACE 0x100
#define CRTPORT 0x3d4
#define KEY_LF 0xE4
#define KEY_RT 0xE5

#define KEY_UP 0xE2
#define KEY_DN 0xE3
#define INPUT_BUF 128
#define MAX_HISTORY 16




char historyArray[MAX_HISTORY][INPUT_BUF];
int commandExecuted = 0;
int historyArrayIsFull = 0; // 1 = FULL , 0 = empty
int currentHistoryPos = 0;

static int tmpPos = 0;
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory


int
modThatDealsWithNegatives(int num1, int num2){
  int r = num1 % num2;
  if(r<0)
    return r+num2;
  else return r;
}


static void
cgaputc(int c)
{
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);


  if(c == '\n'){
    pos += 80 - pos%80;
    tmpPos = 0; // tmpPos means the offset to the right, means how many you need to go right to get to the end
  }
  else if(c == BACKSPACE){
     if(pos > 0) {
      --pos;
      int startingPos = pos;
      int i;
      for (i = 0 ; i < tmpPos ; i++){
  memmove(crt+startingPos, crt+startingPos+1, 1); // take the rest of the line on the right 1 place to the left
  startingPos++;
      }
     crt[pos+tmpPos] = ' ' | 0x0700; // the last place which held the last char should now be blank
    }
  }
  else  if (c == KEY_LF) {
    if (pos > 0) {
      --pos;
      tmpPos++; // counter for how left are we from the last char in the line
    }
  }
  else if (c == KEY_RT) {
    if (tmpPos > 0) {
      ++pos;
      tmpPos--; // counter for how left are we from the last char in the line
    }
  }
  else if(c == KEY_UP) { // take the historyCommand of calculated current index and copy it to crt, command not executed gets deleted once pressing up
      int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
      int i;
      for (i = 0; i < strlen(historyArray[historyIndex])-1 ; i++) {
        c = historyArray[historyIndex][i];
        memmove(crt+pos, &c, 1);
        crt[pos++] = (c&0xff) | 0x0700;  // black on white
      }
      crt[pos+strlen(historyArray[historyIndex])] = ' ' | 0x0700;

  }
  else if(c == KEY_DN) {
     int historyIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
      int i2;
      for (i2 = 0; i2 < strlen(historyArray[historyIndex])-1 ; i2++) {
        c = historyArray[historyIndex][i2];
        memmove(crt+pos, &c, 1);
        crt[pos++] = (c&0xff) | 0x0700;
      }
      crt[pos+strlen(historyArray[historyIndex])] = ' ' | 0x0700;
  }
  else
    if ( !tmpPos ) { // if we are at the end of the line, just write c to crt (tmpPos = 0 => the most right, !tmpPos=1 means we can write regular)
      crt[pos++] = (c&0xff) | 0x0700;
    }
    else { // if we're typing in the middle of the command, we shift the remaining right sentene from tmpPos to the right and write c
      int endPos = pos + tmpPos -1; // go to the end of the line
      int i;
      for (i = 0; i < tmpPos ; i++) {
        memmove(crt+endPos+1, crt+endPos, 1); // go backwards and copy forward in the process
        endPos--;
      }
      crt[pos++] = (c&0xff) | 0x0700;
    }

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  }

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);

  if (c != KEY_LF && c != KEY_RT && c != KEY_UP && c != KEY_DN && c != '\n' && !tmpPos )
    crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
  if(panicked){
    cli();
    for(;;)
      ;
  }

  switch(c) {
    case BACKSPACE:
      uartputc('\b'); uartputc(' '); uartputc('\b'); break;
    default:
      uartputc(c);
  }
  cgaputc(c);
}


struct {
  struct spinlock lock;
  char buf[INPUT_BUF];
  uint r;  // Read index
  uint w;  // Write index
  uint e;  // Edit index
} input;

#define C(x)  ((x)-'@')  // Control-x


void
DeleteCurrentUnfinishedCommand()
{
  while(input.w < input.e) { // if we're in the middle of the command - go to the right
        input.w++;
        consputc(KEY_RT);
  }
  while(input.e != input.r && input.buf[(input.e-1) % INPUT_BUF] != '\n'){ // same as BACKSPACE: do it for entire line
    input.e--;
    if(input.w != input.r)
      input.w--;
      consputc(BACKSPACE);
  }
}



void
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.w != input.r) {
  int forwardPos = input.w;
  int j;
  for (j = 0 ; j < input.e-input.w ; j++){ // take the rest of the line on the right 1 place to the left
    input.buf[forwardPos-1 % INPUT_BUF] = input.buf[forwardPos % INPUT_BUF];
    forwardPos++;
  }
  input.e--;
  input.w--;
        consputc(BACKSPACE);
      }
      break;
    case KEY_LF:
      if(input.r < input.w) {
        input.w--;
        consputc(KEY_LF);
      }
      break;
    case KEY_RT:
      if(input.w < input.e) {
        input.w++;
        consputc(KEY_RT);
      }
      break;
    case KEY_UP:
      if (commandExecuted == 0 && historyArrayIsFull == 0) { // no history yet, nothing been executed
        break;
      }
      else if (commandExecuted-currentHistoryPos == 0 && historyArrayIsFull==0) { // we are at the last command executed, can't go up
        break;
      }
      else if (currentHistoryPos != MAX_HISTORY) { // can perform history execution.
  if(currentHistoryPos < MAX_HISTORY){
    currentHistoryPos = currentHistoryPos + 1;
  }
        DeleteCurrentUnfinishedCommand();
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
    c = historyArray[tmpIndex][j];
          input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
        consputc(KEY_UP);
      }
      break;

    case KEY_DN:
      if (commandExecuted == 0 && historyArrayIsFull == 0) {
        break;
      }
      else if (currentHistoryPos==0 ) {
        break;
      }
      else if (currentHistoryPos) {
  currentHistoryPos = currentHistoryPos - 1;
        DeleteCurrentUnfinishedCommand();
        int tmpIndex = modThatDealsWithNegatives((commandExecuted - currentHistoryPos), MAX_HISTORY);
  int j;
  for (j = 0 ; j<strlen(historyArray[tmpIndex])-1 ; j++){
    c = historyArray[tmpIndex][j];
          input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
        consputc(KEY_DN);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
  if (c != '\n') { // regular write, not execute
    int forwardPos = input.e;
    int j;
    for (j = 0 ; j<input.e-input.w ; j++){
      input.buf[forwardPos % INPUT_BUF] = input.buf[forwardPos-1 % INPUT_BUF];
      forwardPos--;
    }
    input.buf[input.w++ % INPUT_BUF] = c;
    input.e++;
  }
  else {
    input.buf[input.e++ % INPUT_BUF] = c;
  }
        consputc(c);
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
    currentHistoryPos=0;
          int tmpHistoryIndex;
    for (tmpHistoryIndex = 0 ; tmpHistoryIndex < input.e-input.r ; tmpHistoryIndex++){ // copy the command from the buffer to the historyArray at current position
      historyArray[commandExecuted][tmpHistoryIndex] = input.buf[input.r+tmpHistoryIndex % INPUT_BUF]; // copy chars from buffer to array
    }

          if (commandExecuted == MAX_HISTORY-1)
            historyArrayIsFull = 1;
    commandExecuted = (commandExecuted+1) % MAX_HISTORY;

          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
    }
  }
  release(&input.lock);
}

int
consoleread(struct inode *ip, char *dst, int n)
{
  uint target;
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
    consputc(buf[i] & 0xff);
  release(&cons.lock);
  ilock(ip);

  return n;
}

void
consoleinit(void)
{
  initlock(&cons.lock, "console");
  initlock(&input.lock, "input");

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
  ioapicenable(IRQ_KBD, 0);
}
