; vim: set filetype=asmM6502:

PPUCTRL = $2000
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
  SEI               ; set interrupt ignore bit
  CLD               ; clear decimal mode bit
  LDX #$00
  STX PPUCTRL       ; turn off non maskable interrupts (NMI)
  STX PPUMASK       ; disable rendering
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait    ; loop waiting for vblank
  JMP main
.endproc

.proc main
  LDX PPUSTATUS     ; resets the address latch
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR       ; sets #$3f00 (first palette index) as address
  LDA #$11
  STA PPUDATA       ; writes #$11 as background color index

  LDA #%00011110
  STA PPUMASK       ; enable rendering
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
.res 8192           ; the 8 kB graphics mem, all zeros
.segment "STARTUP"
