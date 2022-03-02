normalLine:
	@wait #32
#if DEBUG
	sta VIC.BACKGROUND_COLOR // 4
	stx VIC.BACKGROUND_COLOR // 4
#else
	sta VIC.HORIZONTAL_CONTROL // 4
	stx VIC.HORIZONTAL_CONTROL // 4
#endif
	rts

normalAndBadline:
	@wait #32
#if DEBUG
	sta VIC.BACKGROUND_COLOR // 4
	stx VIC.BACKGROUND_COLOR // 4
	sta VIC.BACKGROUND_COLOR, y // 5
	stx VIC.BACKGROUND_COLOR // 4
#else
	sta VIC.HORIZONTAL_CONTROL // 4
	stx VIC.HORIZONTAL_CONTROL // 4
	sta VIC.HORIZONTAL_CONTROL, y // 5
	stx VIC.HORIZONTAL_CONTROL // 4
#endif
	rts

moveSpritePointersAndBadline:
	inc screen + $03fc // 6
	inc screen + $03fd // 6
	inc screen + $03fe // 6
	inc screen + $03ff // 6
	@wait #8
#if DEBUG
	sta VIC.BACKGROUND_COLOR // 4
	stx VIC.BACKGROUND_COLOR // 4
	sta VIC.BACKGROUND_COLOR, y // 5
	stx VIC.BACKGROUND_COLOR // 4
#else
	sta VIC.HORIZONTAL_CONTROL // 4
	stx VIC.HORIZONTAL_CONTROL // 4
	sta VIC.HORIZONTAL_CONTROL, y // 5
	stx VIC.HORIZONTAL_CONTROL // 4
#endif
	rts

moveSpritesDown:
	lda VIC.SPRITE_4_Y // 4
	clc // 2
	adc #21 // 2
	sta VIC.SPRITE_4_Y // 4
	sta VIC.SPRITE_5_Y // 4
	sta VIC.SPRITE_6_Y // 4
	sta VIC.SPRITE_7_Y // 4
	lda #7 // 2
	:wait #6
#if DEBUG
	sta VIC.BACKGROUND_COLOR // 4
	stx VIC.BACKGROUND_COLOR // 4
#else
	sta VIC.HORIZONTAL_CONTROL // 4
	stx VIC.HORIZONTAL_CONTROL // 4
#endif
	rts

moveSpritePointers:
	inc screen + $03fc // 6
	inc screen + $03fd // 6
	inc screen + $03fe // 6
	inc screen + $03ff // 6
	@wait #8
#if DEBUG
	sta VIC.BACKGROUND_COLOR // 4
	stx VIC.BACKGROUND_COLOR // 4
#else
	sta VIC.HORIZONTAL_CONTROL // 4
	stx VIC.HORIZONTAL_CONTROL // 4
#endif
	rts

