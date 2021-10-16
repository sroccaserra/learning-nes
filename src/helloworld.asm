; vim: set filetype=asmM6502:

.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write first palette
  LDX PPUSTATUS     ; resets the address latch
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR       ; sets #$3f00 (first palette index) as address
  LDA #$29
  STA PPUDATA       ; writes #$29 as background color index
  LDA #$19
  STA PPUDATA       ; writes 3 other colors
  LDA #$09
  STA PPUDATA
  LDA #$0f
  STA PPUDATA

  ; write sprite data
  LDA #$70
  STA $0200         ; Y-coord of first sprite
  LDA #$05
  STA $0201         ; tile number of first sprite
  LDA #$00
  STA $0202         ; attributes of first sprite
  LDA #$80
  STA $0203         ; X-coord of first sprite

vblankwait:         ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000
  STA PPUCTRL       ; turn on NMIs, sprites use first pattern table

  LDA #%00011110
  STA PPUMASK       ; enable rendering
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"
