; vim: set filetype=asmM6502:

PPUMASK = $2001
PPUSTATUS = $2002
PPUADDR = $2006
PPUDATA = $2007

.segment "HEADER"
.byte "NES", 26, 2, 1, 0, 0

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  RTI
.endproc

.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX $2000
  STX $2001
vblankwait:
  BIT $2002
  BPL vblankwait
  JMP main
.endproc

.proc main
  LDX PPUSTATUS ; resets the address latch
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDA #$11
  STA PPUDATA

  LDA #%00011110
  STA PPUMASK
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
.res 8192
.segment "STARTUP"
