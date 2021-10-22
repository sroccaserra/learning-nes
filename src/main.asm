; vim: set filetype=asmM6502:

.include "constants.inc"
.include "header.inc"
.include "macros.inc"

.segment "ZEROPAGE"
; state variables
player_x: .res 1
player_y: .res 1
player_dir: .res 1
scroll_y: .res 1
.exportzp player_x, player_y, scroll_y

; temp variables for various arithmetics
lo_1: .res 1
hi_1: .res 1
lo_2: .res 1
hi_2: .res 1

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  jsr update_player
  jsr draw_player
  dec scroll_y
  lda scroll_y
  cmp #MAX_Y
  bcc :+
  lda #MAX_Y
  sta scroll_y
  :

  LDA #$00
  STA PPUSCROLL
  LDA scroll_y
  STA PPUSCROLL
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write palettes
  LDX PPUSTATUS     ; resets the address latch
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR       ; sets #$3f00 (first palette index) as address
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #32
  BNE load_palettes

  jsr add_bricks

  ; finally, attribute table
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$c2
  STA PPUADDR
  LDA #%01000000
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$e0
  STA PPUADDR
  LDA #%00001100
  STA PPUDATA

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

.proc add_bricks
  push_registers

  ldy #$30          ; tile number

  lda #$20          ; start high memory address
  sta hi_1
  lda #$00          ; start low memory address
  sta lo_1

  lda #$23          ; end high memory address
  sta hi_2
  lda #$c0          ; end low memory address
  sta lo_2

loop:
  ; load values to PPU
  lda PPUSTATUS
  lda hi_1
  sta PPUADDR
  lda lo_1
  sta PPUADDR
  sty PPUDATA
  ; arithmetics
  clc
  lda lo_1
  adc #1
  sta lo_1
  lda hi_1
  adc #0
  sta hi_1

  ;;
  ; compare
  lda lo_1
  cmp lo_2
  bne loop

  lda hi_1
  cmp hi_2
  bne loop

  pop_registers
  rts
.endproc

.proc draw_player
  push_registers

  ; tile numbers
  lda #$05
  sta $0201
  lda #$06
  sta $0205
  lda #$07
  sta $0209
  lda #$08
  sta $020d

  ; tile attributes (palette 0)
  lda #$00
  sta $0202
  sta $0206
  sta $020a
  sta $020e

  ; tile locations
  lda player_y
  sta $0200
  lda player_x
  sta $0203

  lda player_y
  sta $0204
  lda player_x
  clc
  adc #$08
  sta $0207

  lda player_y
  clc
  adc #$08
  sta $0208
  lda player_x
  sta $020b

  lda player_y
  clc
  adc #$08
  sta $020c
  lda player_x
  clc
  adc #$08
  sta $020f

  pop_registers
  rts
.endproc

.proc update_player
  push_registers

  lda player_x
  cmp #224
  bcc not_at_right_edge
  ; if BCC is not taken, we are greater than 224
  lda #0
  sta player_dir    ; start moving left
  jmp direction_set ; we already chose a direction,
                    ; so we can skip the left side check
not_at_right_edge:
  lda player_x
  cmp #16
  bcs direction_set
  ; if BCS not taken, we are less than 16
  lda #1
  sta player_dir   ; start moving right

direction_set:
  ; now, actually update player_x
  lda player_dir
  cmp #1
  beq move_right
  ; if player_dir minus 1 is not zero,
  ; that means player_dir was 0 and
  ; we need to move left
  dec player_x
  jmp exit_subroutine

move_right:
  inc player_x

exit_subroutine:
  pop_registers
  rts
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"

palettes:
.byte $0f, $12, $23, $27  ; Background palettes
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $2d, $10, $15  ; Sprites palettes
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

.segment "CHR"
.incbin "graphics.chr"
