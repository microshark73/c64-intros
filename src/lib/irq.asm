#importonce

#import "macros.asm"
#import "pseudocommands.asm"

.macro StabilizeIrq() {
// @see https://codebase64.org/doku.php?id=base:stable_raster_routine

	:mov16 #next : KERNAL.IRQ_ADDRESS

	inc VIC.RASTER_COUNTER

	lda #$01
	sta VIC.INTERRUPT_STATUS

	tsx
	cli

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

next:

	txs
	//:wait #44
	ldx #$08
	!:
	dex
	bne !-
	bit $ea

	lda VIC.RASTER_COUNTER
	cmp VIC.RASTER_COUNTER
	beq * + 2
}


