#importonce

// Misc - Must be categorized later...
// and better names welcome...
.const DEFAULT_IRQ_HANDLER_WITH_CURSOR = $EA31
.const DEFAULT_IRQ_HANDLER_WITHOUT_CURSOR = $EA81


// Interrupt
.const IRQ_SERVICE_ADDRESS      = $0314
.const IRQ_SERVICE_ADDRESS_LO   = $0314
.const IRQ_SERVICE_ADDRESS_HI   = $0315


// CIA (Complex Interface Adapter)
.const CIA1_DATA_PORT_A    = $DC00
.const CIA1_DATA_PORT_B    = $DC01
.const CIA1_CONTROL_STATUS = $DC0D

.const CIA2_DATA_PORT_A    = $DD00
.const CIA2_DATA_PORT_B    = $DD01
.const CIA2_CONTROL_STATUS = $DD0D


// VIC
.const SPRITE_0_X            = $D000
.const SPRITE_0_Y            = $D001
.const SPRITE_1_X            = $D002
.const SPRITE_1_Y            = $D003
.const SPRITE_2_X            = $D004
.const SPRITE_2_Y            = $D005
.const SPRITE_3_X            = $D006
.const SPRITE_3_Y            = $D007
.const SPRITE_4_X            = $D008
.const SPRITE_4_Y            = $D009
.const SPRITE_5_X            = $D00A
.const SPRITE_5_Y            = $D00B
.const SPRITE_6_X            = $D00C
.const SPRITE_6_Y            = $D00D
.const SPRITE_7_X            = $D00E
.const SPRITE_7_Y            = $D00F
.const SPRITE_MSB_X          = $D010 // Sprite 0-7 horizontal position MSB
.const VIC_CONTROL_REG_1     = $D011 // RST8 ECM- BMM- DEN- RSEL [   YSCROLL   ]
.const VIC_RASTER_COUNTER    = $D012
.const VIC_LIGHT_PEN_X       = $D013
.const VIC_LIGHT_PEN_Y       = $D014
.const SPRITE_ENABLE         = $D015
.const VIC_CONTROL_REG_2     = $D016 //  RES- MCM- CSEL [   XSCROLL   ]
.const SPRITE_EXPAND_Y       = $D017
.const VIC_MEM_POINTERS      = $D018 // VM13 VM12 VM11 VM10 CB13 CB12 CB11 ----
.const VIC_INTERRUPT_STATUS  = $D019 // IRQ- ---- ---- ---- ILP- IMMC IMBC IRST
.const VIC_INTERRUPT_CONTROL = $D01A // ---- ---- ---- ---- ELP- EMMC EMBC ERST
.const SPRITE_PRIORITY       = $D01B
.const SPRITE_MULTICOLOR     = $D01C
.const SPRITE_EXPAND_X       = $D01D
.const SPRITE_COLLISION_SPR  = $D01E
.const SPRITE_COLLISION_DATA = $D01F
.const BORDER_COLOR          = $D020
.const BACKGROUND_COLOR      = $D021
.const BACKGROUND_COLOR_1    = $D022
.const BACKGROUND_COLOR_2    = $D023
.const BACKGROUND_COLOR_3    = $D024
.const SPRITE_MULTICOLOR_0   = $D025
.const SPRITE_MULTICOLOR_1   = $D026
.const SPRITE_COLORS         = $D027
.const SPRITE_0_COLOR        = $D027
.const SPRITE_1_COLOR        = $D028
.const SPRITE_2_COLOR        = $D029
.const SPRITE_3_COLOR        = $D02A
.const SPRITE_4_COLOR        = $D02B
.const SPRITE_5_COLOR        = $D02C
.const SPRITE_6_COLOR        = $D02D
.const SPRITE_7_COLOR        = $D02E