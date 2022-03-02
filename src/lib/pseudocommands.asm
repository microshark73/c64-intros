#importonce

#import "constants.asm"

.filenamespace MicroPseudoCommands

.function _16bitNextArgument(arg) {
    .if (arg.getType() == AT_IMMEDIATE) {
        .return CmdArgument(arg.getType(), >arg.getValue())
    }
    
    .return CmdArgument(arg.getType(), arg.getValue() + 1)
}

.pseudocommand @wait cycles {
    .var value = cycles.getValue()
    .var type = cycles.getType()

    .if (value < 2) .error "We could not wait less than 2 cycles"
    .if (type != AT_IMMEDIATE) .error "We need an IMMEDIATE value, eg. #$10 or similar"

    .if (mod(value, 2) == 1) {
        bit $ea
        .fill floor(value / 2) - 1, NOP
    } else {
        .fill round(value / 2), NOP
    }
}

.pseudocommand @inc16 arg {
    inc arg
    bne skip
    inc _16bitNextArgument(arg)
skip:
}

.pseudocommand @dec16 arg {
    dec arg
    beq skip
    dec _16bitNextArgument(arg)
skip:
}

.pseudocommand @mov16 src:dst {
    lda src
    sta dst
    lda _16bitNextArgument(src)
    sta _16bitNextArgument(dst)
}

.pseudocommand @pusha {
	// 13 cycles
	pha // 3
	txa // 2
	pha // 3
	tya // 2
	pha // 3
}

.pseudocommand @popa {
	// 16 cycles
	pla // 4
	tay // 2
	pla // 4
	tax // 2
	pla // 4
}

.pseudocommand @ack {
    asl VIC.INTERRUPT_STATUS
}

.assert ":wait #$02", {:wait #$02}, {nop}
.assert ":wait #$03", {:wait #$03}, {bit $ea}
.assert ":wait #$04", {:wait #$04}, {nop; nop}
.assert ":wait #$05", {:wait #$05}, {bit $EA; nop}