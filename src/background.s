; vim: set filetype=asmM6502:

.MACPACK generic

.include "constants.inc"

.importzp p_1, p_2, lo_1, lo_2, hi_1, hi_2

.segment "CODE"

.export load_background
.proc load_background
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

        rts
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

.segment "RODATA"

moon = $32
big_star = $29

small_stars_pos:                ; null terminated, PPU addresses
.dbyt $212d, $237b, $22b4, $2186
.dbyt $2059, $2289, $2087, $238c
.dbyt $2859, $2a89, $2887, $2b8c
.dbyt $292d, $2b7b, $2ab4, $2986
.byte $00
