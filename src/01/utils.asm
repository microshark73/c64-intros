#importonce

#import "lib/constants.asm"
#import "lib/irq.asm"

.macro VSP() {
	lda #$7c // 2
	sta VIC.VERTICAL_CONTROL // 4

	//:wait #30
	ldx #5 // x * 5 + 1
!:
	dex
	bne !-
	nop
	nop

	lda #$00
	beq CharOffsetHi: !+
!:
	.fill 40, CMP_IMM
	bit $ea

	//:wait #24
	ldx #4 // x * 5 + 1
!:
	dex
	bne !-
	bit $ea // 3

	lda #$7b // Keep screen in invalid mode to prevent displaying VSP garbage...
	sta VIC.VERTICAL_CONTROL

	lda CharOffsetLo: #$00
	sta VIC.HORIZONTAL_CONTROL
}

.macro AckAndSetNextIRQ(rasterLine, irqAddress) {
	asl VIC.INTERRUPT_STATUS
	:mov16 #irqAddress : KERNAL.IRQ_ADDRESS
	:SetNextRaster(rasterLine)
}

.macro MoveSpriteColumnsLeft(spriteAddress) {
	// Upper sprites
	:MoveSpriteColumn(spriteAddress + 0 * 64 + 1, spriteAddress + 0 * 64 + 0, 21 - 8, 21)
	:MoveSpriteColumn(spriteAddress + 0 * 64 + 2, spriteAddress + 0 * 64 + 1, 21 - 8, 21)
	:MoveSpriteColumn(spriteAddress + 2 * 64 + 0, spriteAddress + 0 * 64 + 2, 21 - 8, 21)
	:MoveSpriteColumn(spriteAddress + 2 * 64 + 1, spriteAddress + 2 * 64 + 0, 21 - 8, 21)
	:MoveSpriteColumn(spriteAddress + 2 * 64 + 2, spriteAddress + 2 * 64 + 1, 21 - 8, 21)
	// Lower sprites
	:MoveSpriteColumn(spriteAddress + 1 * 64 + 1, spriteAddress + 1 * 64 + 0, 0, 16)
	:MoveSpriteColumn(spriteAddress + 1 * 64 + 2, spriteAddress + 1 * 64 + 1, 0, 16)
	:MoveSpriteColumn(spriteAddress + 3 * 64 + 0, spriteAddress + 1 * 64 + 2, 0, 16)
	:MoveSpriteColumn(spriteAddress + 3 * 64 + 1, spriteAddress + 3 * 64 + 0, 0, 16)
	:MoveSpriteColumn(spriteAddress + 3 * 64 + 2, spriteAddress + 3 * 64 + 1, 0, 16)
}

.macro MoveSpriteColumn(source, target, startRow, endRow) {
	.for(var i = startRow; i < endRow; i++) {
		lda source + i * 3
		sta target + i * 3
	}
}

.macro LogoSprites(ypos) {
render:
	// This is a timing critical section.
	// We need to adjust timing code after calling when changed!!!
	lda #CalculateCharacterMemoryPointers(logoFont, screen)
	sta VIC.MEM_POINTERS

	lda #ypos
	sta VIC.SPRITE_4_Y
	sta VIC.SPRITE_5_Y
	sta VIC.SPRITE_6_Y
	sta VIC.SPRITE_7_Y

	lda spriteshi: #%11000000
	sta VIC.SPRITE_MSB_X
	lda sprite4lo: #24
	sta VIC.SPRITE_4_X
	lda sprite5lo: #24 + 24
	sta VIC.SPRITE_5_X
	lda sprite6lo: #40
	sta VIC.SPRITE_6_X
	lda sprite7lo: #40 + 24
	sta VIC.SPRITE_7_X

	lda #(logoSpriteData / 64)
	sta screen + $03fc
	clc
	adc #3
	sta screen + $03fd
	adc #3
	sta screen + $03fe
	adc #3
	sta screen + $03ff

	lda color: #$01
	sta VIC.SPRITE_4_COLOR
	sta VIC.SPRITE_5_COLOR
	sta VIC.SPRITE_6_COLOR
	sta VIC.SPRITE_7_COLOR
	rts

calculate:
	ldy #$00 // Sprites msb
	lda sineTabAbs, x
	clc
	adc #248
	bcc !skip+
	pha
	tya
	ora #%1100_0000
	tay
	pla
!skip:
	sta sprite6lo
	clc
	adc #24
	bcc !skip+
	pha
	tya
	ora #%1000_0000
	tay
	pla
!skip:
	sta sprite7lo

	lda sineTabAbs, x
	sta sprite5lo
	sec
	sbc #24
	bcs !skip+
	pha
	tya
	ora #%0001_0000
	tay
	pla
	sec
	sbc #8
!skip:
	sta sprite4lo
	sty spriteshi

	rts
}

.macro ScrollSprites(charLine) {
render:
	lda #50 + charLine * 8 - 5  // Shift sprites 5 pixels up. Scroll characters in bottom of upper sprites (1 char) and in top of lower sprites (2 char)
	sta VIC.SPRITE_4_Y
	sta VIC.SPRITE_5_Y
	sta VIC.SPRITE_6_Y
	sta VIC.SPRITE_7_Y

	lda #%1101_0000
	sta VIC.SPRITE_MSB_X
	lda sprite0x: #$e8
	sta VIC.SPRITE_4_X
	lda sprite1x: #$08
	sta VIC.SPRITE_5_X
	lda sprite2x: #$58
	sta VIC.SPRITE_6_X
	lda sprite3x: #$70
	sta VIC.SPRITE_7_X

	lda #scrollSpriteData / 64 + 0
	sta screen + $03fc
	lda #scrollSpriteData / 64 + 2
	sta screen + $03fd
	lda #scrollSpriteData / 64 + 4
	sta screen + $03fe
	lda #scrollSpriteData / 64 + 6
	sta screen + $03ff

	lda color: #$01
	sta VIC.SPRITE_4_COLOR
	sta VIC.SPRITE_5_COLOR
	sta VIC.SPRITE_6_COLOR
	sta VIC.SPRITE_7_COLOR

	lda #CalculateCharacterMemoryPointers(scrollFont, screen)
	sta VIC.MEM_POINTERS
	rts

calculate:
	tax
	ora #$08
	sta stabilizationVSP.CharOffsetLo
	txa
	clc
	sta scrollSprites.sprite1x
	adc #$58
	sta scrollSprites.sprite2x
	adc #$18
	sta scrollSprites.sprite3x
	adc #$70
	sta scrollSprites.sprite0x
	rts
}

// Create sprite data from character data
.macro RenderCharDataToSprite(charAddress, spriteDataPointer)
{
	lda charAddress
	jsr calculateCharDataPointer
	ldy #0
	.for(var i = 0; i < 8; i++) {
		lda ($fb), y
		sta spriteDataPointer + i * 3
		iny
	}
}
