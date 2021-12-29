#importonce

#import "constants.asm"

.macro nextIrq (addr, y) {
    lda #<addr
    sta IRQ_SERVICE_ADDRESS_LO
    lda #>addr
    sta IRQ_SERVICE_ADDRESS_HI
    lda #y
    sta VIC_RASTER_COUNTER
    jmp DEFAULT_IRQ_HANDLER_WITHOUT_CURSOR
}

.macro MoveScreenLeft(addr, rows) {
    ldx #$00
!loop:
    .for(var y = 0; y < rows; y++) {
        lda addr + 1, x
        sta addr, x

        .eval addr += 40
    }
    inx
    cpx #40
    bne !loop-
}

.macro MoveScreenRight(addr, rows) {
    ldx #38
!loop:
    .for(var y = 0; y < rows; y++) {
        lda addr, x
        sta addr + 1, x

        .eval addr += 40
    }
    dex
    bpl !loop-
}



.macro MoveScreenLeftUnrolled(addr, rows) {
    .for(var y = 0; y < rows; y++) {
        .for(var x = 0; x < 40; x++) {
            lda addr + x + 1
            sta addr + x
        }

        .eval addr += 40
    }
}

.macro MoveScreenRightUnrolled(addr, rows) {
    .for(var y = 0; y < rows; y++) {
        .for(var x = 38; x >= 0; x--) {
            lda addr + x
            sta addr + x + 1
        }

        .eval addr += 40
    }
}
