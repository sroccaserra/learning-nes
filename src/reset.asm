; vim: set filetype=asmM6502:

.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, scroll_y

.segment "CODE"

.import main

.export reset_handler
.proc reset_handler
  SEI               ; set interrupt ignore bit
  CLD               ; clear decimal mode bit
  LDX #$00
  STX PPUCTRL       ; turn off non maskable interrupts (NMI)
  STX PPUMASK       ; disable rendering

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait    ; loop waiting for vblank

  LDX #$00
  LDA #$ff
clear_oam:
  STA $0200,X       ; set all sprite y-positions off the screen
  INX
  INX
  INX
  INX
  BNE clear_oam

  lda #128
  sta player_x
  lda #160
  sta player_y
  lda #0
  sta scroll_y

vblankwait2:
  BIT PPUSTATUS
  BPL vblankwait2

  JMP main
.endproc
