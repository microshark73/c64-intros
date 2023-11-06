// Music by A-Man/Tropic
// Original font by Spacie/G*P
// Code, idea, logo and font "improvement" by Microshark/Damage

//#define DEBUG

#import "lib/constants.asm"
#import "lib/irq.asm"
#import "lib/macros.asm"
#import "lib/pseudocommands.asm"
#import "lib/sinetabgenerator.asm"

#import "utils.asm"

// Character line positions
.const TOP_LOGO_LINE = 0
.const SCROLLER_TOP_LINE = 10
.const TOP_LOGO_STABILIZATION_LINE = SCROLLER_TOP_LINE - 1
.const BOTTOM_LOGO_LINE = 16

// Raster positions
.const VSP1_LINE = CharLineToVSPLine(TOP_LOGO_LINE) // Top logo
.const VSP2_LINE = CharLineToVSPLine(TOP_LOGO_STABILIZATION_LINE) // Top logo VSP "stabilization"
.const VSP3_LINE = CharLineToVSPLine(BOTTOM_LOGO_LINE) // Bottom logo

.var sineData = GenerateSine(256, 0, 6 * 2 * 8 - 1) // Moving 2 - 2 sprites (6 - 6 chars)
.var music = LoadSid("assets/Harmonic_River.sid")

:BasicUpstart2(main)

.segment Default "Main"

main: 
!:	bit $d011
	bpl !-
!:	bit $d011
	bmi !-

	jsr initScreen
	jsr calculateLogoPositions

	lda #$00
	tax
	tay
	jsr music.init
	sei
	lda #$35
	sta $01
	lda #$7f
	sta CIA1.CONTROL_STATUS // Disable CIA1 interrupts
	sta CIA2.CONTROL_STATUS // Disable CIA2 interrupts
	lda CIA1.CONTROL_STATUS // Clear CIA1
	lda CIA2.CONTROL_STATUS // Clear CIA2
	lda #$01
	sta CIA1.CONTROL_STATUS
	sta VIC.INTERRUPT_CONTROL // Enable raster interrupts
	:AckAndSetNextIRQ(VSP1_LINE, irq1)
	cli
	jmp *

//.align $100

irq1:
	:pusha
	:StabilizeIrq()
upperLogoVSP: 
	:VSP()

	jsr upperSprites.render

	ldx #58
!:	dex
	bne !-
	nop

	lda #$1b
	sta VIC.VERTICAL_CONTROL

	ldx upperLogoVSP.CharOffsetLo
	lda #$07
	ldy #$00

	jsr openLogoBorder

	:AckAndSetNextIRQ(VSP2_LINE, irq2)
	:popa
	rti

//.align $100
irq2:
	:pusha
	:StabilizeIrq()

stabilizationVSP:
	:VSP()

	jsr scrollSprites.render

	ldx #76
!:	dex
	bne !-
	bit $ea

	lda #$1b
	sta VIC.VERTICAL_CONTROL

	ldx #40
!:	dex 
	bne !-

	ldx stabilizationVSP.CharOffsetLo // Scroller horizontal offset stored there...
	lda #$07
	ldy #$00

	jsr openScrollerBorder

	:AckAndSetNextIRQ(VSP3_LINE, irq3)
	:popa
	rti

//.align $100
irq3:
	:pusha
	:StabilizeIrq()
lowerLogoVSP:
	:VSP()

	jsr lowerSprites.render

	ldx #58
!:	dex
	bne !-
	nop

	lda #$1b
	sta VIC.VERTICAL_CONTROL

	ldx lowerLogoVSP.CharOffsetLo
	lda #$07
	ldy #$00

	jsr openLogoBorder

	jsr music.play
	jsr calculateLogoPositions
	jsr scroller.update

	jsr blinkScroll

	:AckAndSetNextIRQ(VSP1_LINE, irq1)
	:popa
	rti

upperSprites:
	:LogoSprites(VSP1_LINE + 7)
lowerSprites:
	:LogoSprites(VSP3_LINE + 7)
scrollSprites:
	:ScrollSprites(SCROLLER_TOP_LINE)

calculateLogoPositions:
	// Calculate upper logo position
	inc upperLogoSinePos
	ldx upperLogoSinePos: #0
	lda sineTabHi, x
	sta upperLogoVSP.CharOffsetHi
	lda sineTabLo, x
	eor #$07
	ora #$08
	sta upperLogoVSP.CharOffsetLo

	jsr upperSprites.calculate

	// Stabilization after upper logo VSP
	lda #40
	sec
	sbc sineTabHi, x
	sta stabilizationVSP.CharOffsetHi
	// lda #$c8
	// sta stabilizationVSP.CharOffsetLo

	// Calculate lower logo position
	inc lowerLogoSinePos
	ldx lowerLogoSinePos: #$40
	lda sineTabHi, x
	sta lowerLogoVSP.CharOffsetHi
	lda sineTabLo, x
	eor #$07
	ora #$08
	sta lowerLogoVSP.CharOffsetLo

	jsr lowerSprites.calculate
	rts

	.import source "openborders.asm"

	* = music.location "Music"
	.fill music.size, music.getData(i)

	* = $2000 "Sprites, fonts, screen and tables"

logoFont:
	.import binary "assets/logo - Chars.bin"
	.align $400
screen: {
	// Logo is shifted to the right and clipped 6 characters from both sides (sprites will cover the clipped part)
	.var logoMap = LoadBinary("assets/logo - Map.bin")
	// Upper logo
	.fill 5, 0
	.fill 7 * 40 - 5, logoMap.get(i)
	.fill 3 * 40, 0
	// Scroller
	.fill 3 * 40, 0
	// Lower logo
	.fill 2 * 40 + 5, 0
	.fill 7 * 40 - 5, logoMap.get(i)
}
	.align $0800
scrollFont:
	.import binary "assets/gp intro 07 2x3 extended - Chars.bin"

scrollFontMap: {
	.var map = LoadBinary("assets/gp intro 07 2x3 extended - Map.bin")
	// 32 chars in one row, 2x3 format (1 row is 32*2 = 64 bytes)
	row1: 
	.fill 64, map.get(i)
	.fill 64, map.get(3 * 64 + i)
	row2:
	.fill 64, map.get(64 + i)
	.fill 64, map.get(64 + 3 * 64 + i)
	row3:
	.fill 64, map.get(128 + i)
	.fill 64, map.get(128 + 3 * 64 + i)
}

	.align $40
logoSpriteData:
	.import binary "assets/logo - Sprites.isp"

	.align $40
scrollSpriteData:
	.fill 64 * 8, 0 

//.align $100
sineTabHi:
	.fill sineData.size(), sineData.get(i) / 8
sineTabLo:
	.fill sineData.size(), mod(sineData.get(i), 8)
sineTabAbs:
	.fill sineData.size(), 12 * 8 - 1 - sineData.get(i)

blinkTable:
	.var blinkTableStart = *
	.fill 30, $01
	.byte $01, $0d, $0f, $0a, $08, $02, $09, $00, $00, $00, $00, $00, $00, $09, $02, $08, $0a, $0f, $0d, $01
	.var blinkTableSize = * - blinkTableStart

blinkScroll: {
	ldx blinkPos: #$00
	bpl !+
	rts
!:
	lda blinkTable, x
	sta scrollSprites.color
	dec blinkPos
	ldy #39
!:
	.for(var i = 0; i < 3; i++) {
		sta $d800 + (SCROLLER_TOP_LINE + i) * 40, y
	}
	dey
	bpl !-

	cpx #$00
	bne !+
	// When blink animation finished, we should re-enable scrolling...
	lda #$01
	sta scroller.speed
!:
	rts
}

.segment Default "Methods"

openScrollerBorder: {
	jsr normalAndBadline
	jsr normalLine
	jsr normalLine
	jsr normalLine
	jsr normalLine
	jsr normalLine
	jsr moveSpritesDown
	jsr moveSpritePointersAndBadline
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
	jsr normalLine
	rts
}

openLogoBorder: {
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
	jsr moveSpritesDown
	jsr normalAndBadline
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
	jsr moveSpritesDown
	jsr normalAndBadline
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
	//jsr normalLine
	rts
}

scroller: {
update:
	lda scrollerOffset: #$07
	sec
	sbc speed: #$01
	bcc !+
	sta scrollerOffset

	jsr scrollSprites.calculate
	rts
!:
	clc
	adc #$08
	sta scrollerOffset

	jsr scrollSprites.calculate

	jsr moveLeft

	// Write next character data to right side of shadow screen
	jsr getNextChar
	asl
	ldx charColumn: #$02
	dex
	bne !+
	:inc16 scrollPos
	ldx #$02 // Font width
	tay
	iny
	tya
!:
	stx charColumn
	tay
	lda scrollFontMap.row1, y
	sta shadowScreen + 0 * 6 + 5
	lda scrollFontMap.row2, y
	sta shadowScreen + 1 * 6 + 5
	lda scrollFontMap.row3, y
	sta shadowScreen + 2 * 6 + 5

	jsr shiftRightSprites
	jsr calculateRightSpriteData
	rts

getNextChar: 
	// Returns the next scroller character in A. Control characters are always skipped
	lda scrollPos: scrollText
	cmp #$ff
	beq reset
	bmi setSpeed
	rts
setSpeed:
	and #$07
	sta speed
	cmp #$00
	bne !+
	// Speed 0 means we should blink the scroller
	lda #blinkTableSize - 1
	sta blinkScroll.blinkPos
!:
	:inc16 scrollPos
	jmp getNextChar
reset:
	:mov16 #scrollText : scrollPos
	lda #$02
	sta charColumn
	jmp getNextChar

moveLeft:	
	jsr shiftLeftSprites
	jsr calculateLeftSpriteData

	// Move scroller screen left
	:MoveScreenLeft(screen + 10 * 40, 3) 

	// Write shadow screen data to right side of scroller
	lda shadowScreen + 0 * 6
	sta screen + 10 * 40 + 39
	lda shadowScreen + 1 * 6
	sta screen + 11 * 40 + 39
	lda shadowScreen + 2 * 6
	sta screen + 12 * 40 + 39
	// Move shadow screen left
	ldx #0
!:
	.for(var i = 0; i < 3; i++) {
		lda shadowScreen + i * 6 + 1, x
		sta shadowScreen + i * 6, x
	}
	inx
	cpx #6
	bne !-
	rts
}

calculateCharDataPointer:
	sta $fb
	lda #$00
	sta $fc
	clc
	asl $fb
	rol $fc
	asl $fb
	rol $fc
	asl $fb
	rol $fc
	lda $fc
	clc
	adc #>scrollFont
	sta $fc
	rts

initScreen:
	lda #$00
	sta VIC.BORDER_COLOR
	sta VIC.BACKGROUND_COLOR

	lda #%1111_0000
	sta VIC.SPRITE_ENABLE

	lda #$01
	sta upperSprites.color
	sta lowerSprites.color
	sta scrollSprites.color
	ldx #39
!:
	.for(var i = 0; i < 25; i++) {
		sta $d800 + i * 40, x
	}
	dex
	bpl !-
	rts

shadowScreen:
	// Screen data of right-border (sprite) part of the scroller
	// 3 rows x 6 char columns
	.fill 3 * 6, 0

calculateLeftSpriteData:
	// Create sprite data from left side of scroller screen:
	:RenderCharDataToSprite(screen + 10 * 40, scrollSpriteData + 2 * 64 + 2 + (21 - 8) * 3)
	:RenderCharDataToSprite(screen + 11 * 40, scrollSpriteData + 3 * 64 + 2)
	:RenderCharDataToSprite(screen + 12 * 40, scrollSpriteData + 3 * 64 + 2 + 8 * 3)
	rts

calculateRightSpriteData:
	// Create sprite data from right side of shadow scroller
	:RenderCharDataToSprite(shadowScreen + 0 * 6 + 5, scrollSpriteData + 6 * 64 + 2 + (21 - 8) * 3)
	:RenderCharDataToSprite(shadowScreen + 1 * 6 + 5, scrollSpriteData + 7 * 64 + 2)
	:RenderCharDataToSprite(shadowScreen + 2 * 6 + 5, scrollSpriteData + 7 * 64 + 2 + 8 * 3)
	rts

shiftLeftSprites:
	:MoveSpriteColumnsLeft(scrollSpriteData)
	rts

shiftRightSprites:
	:MoveSpriteColumnsLeft(scrollSpriteData + 4 * 64)
	rts

	.segment Default "Scrolltext"
scrollText:
	//.encoding "screencode_upper"
	.byte $85
	.text "damage[hun] presents   "
	.byte $80
	.text "a brand new c64 intro experiment     "
	.byte $85
	.text "created by microshark  "
	.byte $80
	.byte $20, $81, $20, $82, $20, $83, $20
	.text "   music by a-man      "
	.byte $80
	.byte $20, $81, $20, $82, $20, $83, $20
	.text "                          microshark73@gmail.com  "
	.byte $80
	//.byte $81
	.text @"             @abcdefghijklmnopqrstuvwxyz["; .byte 28, 29, 30, 31; .text @"!\"#$%&'()*+,-./0123456789:;<=>?"
	.byte $85
	.text "                        "
	.byte $ff


.function CharLineToVSPLine(charLine) {
	// We need 3 lines for stabilize raster and setup VSP timing correctly
	.return 51 + charLine * 8 - 3;
}
