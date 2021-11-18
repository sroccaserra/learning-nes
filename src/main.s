; vim: set filetype=asmM6502:

.MACPACK generic

.include "constants.inc"
.include "header.inc"
.include "macros.inc"

.segment "ZEROPAGE"

; state variables
player_x: .res 1
player_y: .res 1
player_dir: .res 1
scroll_y: .res 1
ppu_ctrl: .res 1
.exportzp player_x, player_y, scroll_y, ppu_ctrl

joypad_1: .res 1
.exportzp joypad_1

; temp variables
p_1: .res 1
p_2: .res 1

; temp variables for 16 bit values
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
        blt @write_scroll_values
        lda #MAX_Y
        sta scroll_y
        lda ppu_ctrl
        eor #%00000010          ; switch nametable between $2000 (%00) and  $2800 (%10)
        sta ppu_ctrl
        sta PPUCTRL
@write_scroll_values:
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

        lda #moon
        sta p_1
        lda #$02
        sta p_2
        lda #$20
        sta hi_1
        lda #$00
        sta lo_1
        jsr draw_meta_tile

        lda #$28
        sta hi_1
        lda #$16
        sta lo_1
        jsr draw_meta_tile

        lda #big_star
        sta p_1
        lda #$21
        sta hi_1
        lda #$90
        sta lo_1
        jsr draw_meta_tile

        lda #$29
        sta hi_1
        lda #$C6
        sta lo_1
        jsr draw_meta_tile

        ldy #$2d
        ldx #0
@small_stars:
        lda PPUSTATUS
        lda small_stars_pos,X
        bze @end_small_stars
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
        sta ppu_ctrl

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
        lda lo_1
        add #1
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
        add #$08
        sta $0207

        lda player_y
        add #$08
        sta $0208
        lda player_x
        sta $020b

        lda player_y
        add #$08
        sta $020c
        lda player_x
        add #$08
        sta $020f

        rts
.endproc

.proc update_player
        lda joypad_1
        and #PAD_U
        bze :+
        dec player_y
        dec player_y
        :
        lda joypad_1
        and #PAD_D
        bze :+
        inc player_y
        inc player_y
        :
        lda joypad_1
        and #PAD_L
        bze :+
        dec player_x
        dec player_x
        :
        lda joypad_1
        and #PAD_R
        bze :+
        inc player_x
        inc player_x
        :
        rts
.endproc

; p_1: first tile index
; p_2: nb lines of the meta tiles
; lo_1: low byte of destination address
; hi_1: high byte of destination address
.proc draw_meta_tile
        ldx p_1
        ldy p_2
@loop:
        lda PPUSTATUS           ; first row starting at hi_1 lo_1
        lda hi_1
        sta PPUADDR
        lda lo_1
        sta PPUADDR

        stx PPUDATA
        inx
        stx PPUDATA
        inx

        dey
        bze @end

        add #$20
        sta lo_1
        lda hi_1
        adc #0
        sta hi_1

        jmp @loop
@end:
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

moon = $32
big_star = $29

small_stars_pos:                ; null terminated, PPU addresses
.dbyt $212d, $237b, $22b4, $2186
.dbyt $2059, $2289, $2087, $238c
.dbyt $2859, $2a89, $2887, $2b8c
.dbyt $292d, $2b7b, $2ab4, $2986
.byte $00

.segment "CHR"
.incbin "graphics.chr"
