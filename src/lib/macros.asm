#importonce

#import "constants.asm"
#import "pseudocommands.asm"

.macro WaitCycles(cycles) {
	.if (cycles < 2) .error "We could not wait less than 2 cycles"
	.if (cycles < 8) {
		:wait #cycles
	} else {
		// TODO
	}
}

.macro nextIrq (addr, y) {
	lda #<addr
	sta IRQ_SERVICE_ADDRESS_LO
	lda #>addr
	sta IRQ_SERVICE_ADDRESS_HI
	lda #y
	sta VIC.RASTER_COUNTER
	jmp DEFAULT_IRQ_HANDLER_WITHOUT_CURSOR
}

.macro SetNextRaster(line_number) {
	lda #line_number
	sta VIC.RASTER_COUNTER

	lda VIC.VERTICAL_CONTROL
	.if (line_number > 255) {
		ora #%10000000
	} else {
		and #%01111111
	}
	sta VIC.VERTICAL_CONTROL
}

.function CalculateCharacterMemoryPointers(fontAddress, screenAddress) {
	.return  (screenAddress & $3fff) / $0400 * 16 + (fontAddress & $3fff) / $0800 * 2
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
	cpx #39
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
