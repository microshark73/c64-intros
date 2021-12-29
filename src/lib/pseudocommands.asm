#importonce

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
        bit $EA
        .fill floor(value / 2) - 1, NOP
    } else {
        .fill round(value / 2), NOP
    }
}

.pseudocommand inc16 arg {
    inc arg
    bne skip
    inc _16bitNextArgument(arg)
skip:
}

.pseudocommand mov16 src:dst {
    lda src
    sta dst
    lda _16bitNextArgument(src)
    sta _16bitNextArgument(dst)
}

.assert ":wait #$02", {:wait #$02}, {nop}
.assert ":wait #$03", {:wait #$03}, {bit $ea}
.assert ":wait #$04", {:wait #$04}, {nop; nop}
.assert ":wait #$05", {:wait #$05}, {bit $EA; nop}