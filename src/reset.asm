; vim: set filetype=asmM6502:

.include "constants.inc"

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
  JMP main
.endproc
