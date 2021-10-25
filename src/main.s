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

joypad_1: .res 1
.exportzp joypad_1

; temp variables for various arithmetics
lo_1: .res 1
hi_1: .res 1
lo_2: .res 1
hi_2: .res 1

.segment "CODE"

.proc nmi_handler
        push_registers
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA

        jsr draw_player
        dec scroll_y
        lda scroll_y
        cmp #MAX_Y
        bcc :+
        lda #MAX_Y
        sta scroll_y
        :

        lda #$00
        sta PPUSCROLL
        lda scroll_y
        sta PPUSCROLL

        pop_registers
        rti
.endproc

.import reset_handler

.proc irq_handler
        rti
.endproc

.export main
.proc main
        ; write palettes
        ldx PPUSTATUS           ; resets the address latch
        ldx #$3f
        stx PPUADDR
        ldx #$00
        stx PPUADDR             ; sets #$3f00 (first palette index) as address
@load_palettes:
        lda palettes,X
        sta PPUDATA
        inx
        cpx #32
        bne @load_palettes

        jsr clear_background

        ; moon
        lda PPUSTATUS           ; first row starting at $2000
        lda #$20
        sta PPUADDR
        lda #$00
        sta PPUADDR

        ldx #0
        lda moon,X
        sta PPUDATA
        inx
        lda moon,X
        sta PPUDATA

        lda PPUSTATUS           ; second row starting at $2020
        lda #$20
        sta PPUADDR
        lda #$20
        sta PPUADDR

        inx
        lda moon,X
        sta PPUDATA
        inx
        lda moon,X
        sta PPUDATA

        ; big star
        lda PPUSTATUS           ; first row starting at $2090
        lda #$20
        sta PPUADDR
        lda #$90
        sta PPUADDR

        lda #$29
        sta PPUDATA
        lda #$2a
        sta PPUDATA

        lda PPUSTATUS           ; second row starting at $20b0
        lda #$20
        sta PPUADDR
        lda #$b0
        sta PPUADDR

        lda #$2b
        sta PPUDATA
        lda #$2c
        sta PPUDATA

        ldy #$2d
        ldx #0
@small_stars:
        lda PPUSTATUS
        lda small_stars_pos,X
        beq @end_small_stars
        sta PPUADDR
        inx
        lda small_stars_pos,X
        sta PPUADDR
        inx
        sty PPUDATA
        jmp @small_stars
@end_small_stars:

        ; finally, attribute table
        lda PPUSTATUS
        lda #$23
        sta PPUADDR
        lda #$c2
        sta PPUADDR
        lda #%01000000
        sta PPUDATA

        lda PPUSTATUS
        lda #$23
        sta PPUADDR
        lda #$e0
        sta PPUADDR
        lda #%00001100
        sta PPUDATA

@waitvb:                        ; wait for another vblank before continuing
        bit PPUSTATUS
        bpl @waitvb

        lda #%10010000
        sta PPUCTRL             ; turn on NMIs, sprites use first pattern table

        lda #%00011110
        sta PPUMASK             ; enable rendering
@loop:
        bit PPUSTATUS
        bpl @loop

        jsr read_joypad
        jsr update_player
        jmp @loop
.endproc

.proc clear_background
        ldy #$00                ; tile number

        lda #$20                ; start high memory address
        sta hi_1
        lda #$00                ; start low memory address
        sta lo_1

        lda #$23                ; end high memory address
        sta hi_2
        lda #$c0                ; end low memory address
        sta lo_2

        lda PPUSTATUS
        lda hi_1
        sta PPUADDR
        lda lo_1
        sta PPUADDR

@loop:  ; load values to PPU
        sty PPUDATA
        ; arithmetics
        clc
        lda lo_1
        adc #1
        sta lo_1
        lda hi_1
        adc #0
        sta hi_1
        ; compare
        lda lo_1
        cmp lo_2
        bne @loop
        lda hi_1
        cmp hi_2
        bne @loop

        rts
.endproc

.import read_joypad

.proc draw_player
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

        rts
.endproc

.proc update_player
        lda joypad_1
        and #PAD_U
        beq :+
        dec player_y
        dec player_y
        :
        lda joypad_1
        and #PAD_D
        beq :+
        inc player_y
        inc player_y
        :
        lda joypad_1
        and #PAD_L
        beq :+
        dec player_x
        dec player_x
        :
        lda joypad_1
        and #PAD_R
        beq :+
        inc player_x
        inc player_x
        :
        rts
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"

palettes:
.byte $0f, $12, $23, $27        ; Background palettes
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $11, $21, $20        ; Sprites palettes
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

moon:
.byte $32, $33, $34, $35

small_stars_pos:                ; null terminated, PPU addresses
.dbyt $212d, $237b, $22b4, $2186
.dbyt $2059, $2289, $2087, $238c
.byte $00

.segment "CHR"
.incbin "graphics.chr"
