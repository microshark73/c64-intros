#import "constants.asm"
#import "macros.asm"
#import "pseudocommands.asm"

.var music = LoadSid("assets\UJ4.sid")
.var logoSprites = LoadBinary("assets\sprites.isp")

.var rasterpos = $37

BasicUpstart2(main)

* = $0810 "main"


jsr IOINIT

main:
    lda #$01
    jsr $e544

    lda #$1b
    sta VIC_MEM_POINTERS

    ldx #$00
!loop:
.for(var i = 0; i < 7; i++) {
    lda logoScreen + i * 40, x
    sta $0428 + i * 40, x
}
    inx
    cpx #40
    bne !loop-

    lda #$00
    tax
    tay
    jsr music.init
    sei
    // lda #<irq1
    // sta IRQ_SERVICE_ADDRESS_LO
    // lda #>irq1
    // sta IRQ_SERVICE_ADDRESS_HI
    lda #<irqx
    sta IRQ_SERVICE_ADDRESS_LO
    lda #>irqx
    sta IRQ_SERVICE_ADDRESS_HI
    lda #$7f
    sta CIA1_CONTROL_STATUS // Disable CIA1 interrupts
    sta CIA2_CONTROL_STATUS // Disable CIA2 interrupts
    lda #$01
    sta VIC_INTERRUPT_CONTROL // Enable raster interrupts
    //lda #$37
    lda #rasterpos
    sta VIC_RASTER_COUNTER
    lda #$1b
    sta VIC_CONTROL_REG_1
    jsr resetLogoSprites

    cli
    //rts
    jmp *

irqx:
    // + 7 (Store PC in stack)

    asl VIC_INTERRUPT_STATUS // 6
    ldx #$0d // 2
!loop:
    dex  // 2
    bne !loop- // 2*
    lda VIC_RASTER_COUNTER // 4
    //cmp #$38
    cmp #rasterpos + 1 // 2
    beq !skip+ // 2*
!skip:
    ldx #$08 // 2
!loop:
    dex // 2 * 8
    bne !loop- // 2* * 8
    nop // 2

    lda VIC_RASTER_COUNTER // 4
    //cmp #$39
    cmp #rasterpos + 2 // 2
    beq !skip+ // 2*
!skip:
    ldx #$05 // 2
!loop:
    dex // 2 * 5
    bne !loop- // 2* * 5

    lda #$00 // 2
    ldx #$08 // 2
    ldy #$00 // 2
    bit $ea // 3
    nop // 2
    sta VIC_CONTROL_REG_2 // 4
    stx VIC_CONTROL_REG_2 // 4
    sta VIC_CONTROL_REG_2, y // 4
    stx VIC_CONTROL_REG_2 // 4
    nop
    nop
    nop

    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalAndBadline

    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr moveSpritesDownAndBadline

    jsr moveSpritePointers
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalAndBadline

    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr moveSpritesDownAndBadline

    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr moveSpritePointers
    jsr normalAndBadline

    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalAndBadline

    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    jsr normalLine
    // jsr normalAndBadline
    jsr normalLine

    :nextIrq(irqy, $c0)

irqy:
    asl VIC_INTERRUPT_STATUS

    jsr resetLogoSprites

    dec BORDER_COLOR
    jsr music.play
    inc BORDER_COLOR

    :nextIrq(irqx, $37)

irq1:
    asl VIC_INTERRUPT_STATUS

    lda spos: #$07 
    sta VIC_CONTROL_REG_2 

    lda #$18
    sta $d018 
    lda #$60
    sta $d012
    lda #<irq2
    sta IRQ_SERVICE_ADDRESS_LO
    lda #>irq2
    sta IRQ_SERVICE_ADDRESS_HI
    jmp DEFAULT_IRQ_HANDLER_WITH_CURSOR


irq2:
    asl VIC_INTERRUPT_STATUS

    lda #$c8
    sta VIC_CONTROL_REG_2
    lda #$15
    sta VIC_MEM_POINTERS


    inc BORDER_COLOR
    jsr music.play
    inc BORDER_COLOR

    jsr scroller

    dec BORDER_COLOR
    dec BORDER_COLOR

    :nextIrq(irq1, $30)

    jmp DEFAULT_IRQ_HANDLER_WITHOUT_CURSOR

scroller:
    lda spos
    sec
    sbc scrollspeed: #$01
    bcc !skip+
    sta spos
    rts
!skip:
    adc #$08
    sta spos

    jsr moveScrollerLeft

writeNextChar:
    lda tpos: scrolltext
    cmp #$ff
    bne !skip+
    mov16 scrolltext : tpos
    jmp writeNextChar
!skip:
    sta $0427
    clc
    adc #$80
    sta $044f
    inc16 tpos
    rts

normalLine:
    @wait #32
    sta VIC_CONTROL_REG_2 // 4
    stx VIC_CONTROL_REG_2 // 4
    rts

normalAndBadline:
    @wait #32
    sta VIC_CONTROL_REG_2 // 4
    stx VIC_CONTROL_REG_2 // 4
    sta VIC_CONTROL_REG_2, y // 5
    stx VIC_CONTROL_REG_2 // 4
    rts // 6

moveSpritesDownAndBadline:
    lda SPRITE_4_Y // 4
    clc // 2
    adc #21 // 2
    sta SPRITE_4_Y // 4
    sta SPRITE_5_Y // 4
    sta SPRITE_6_Y // 4
    sta SPRITE_7_Y // 4
    lda #0 // 2

    @wait #6

    sta VIC_CONTROL_REG_2 // 4
    stx VIC_CONTROL_REG_2 // 4
    sta VIC_CONTROL_REG_2, y // 5
    stx VIC_CONTROL_REG_2 // 4
    rts

moveSpritePointers:
    inc $07fc // 6
    inc $07fd // 6
    inc $07fe // 6
    inc $07ff // 6
    @wait #8
    sta VIC_CONTROL_REG_2 // 4
    stx VIC_CONTROL_REG_2 // 4
    rts


moveScrollerLeft:
    :MoveScreenLeftUnrolled($0400, 2)
    rts

resetLogoSprites:
    lda #$f0
    sta SPRITE_ENABLE

    lda #rasterpos
    sta SPRITE_4_Y
    sta SPRITE_5_Y
    sta SPRITE_6_Y
    sta SPRITE_7_Y

    lda #%11010000
    sta SPRITE_MSB_X
    lda #$e0
    sta SPRITE_4_X
    lda #$00
    sta SPRITE_5_X
    lda #$58
    sta SPRITE_6_X
    lda #$70
    sta SPRITE_7_X

    clc
    lda #(spriteData / 64)
    sta $07fc
    adc #3
    sta $07fd
    adc #3
    sta $07fe
    adc #3
    sta $07ff

    lda #$01
    sta SPRITE_4_COLOR
    sta SPRITE_5_COLOR
    sta SPRITE_6_COLOR
    sta SPRITE_7_COLOR
    rts

* = music.location "Music"

.fill music.size, music.getData(i)

* = $2000
spriteData:
.fill logoSprites.getSize(), (logoSprites.get(i) ^ 255)

.align $0800
logoFont:
.import binary "assets/logo - Chars.bin"

.align $0800
.import binary "assets/peetmuzaxfont_1x2.bin"

//* = $3000 "scrolltext"
.align $100
scrolltext:

.encoding "screencode_mixed"
.text "Hello hallo Elektor Kalandorok!   " 
.byte $ff

.align $400
logoScreen:
.import binary "assets\\logo - Map.bin"