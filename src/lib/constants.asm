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

// KERNAL routines

.const SCINIT = $FF81 // Initialize VIC; restore default input/output to keyboard/screen; clear screen; set PAL/NTSC switch and interrupt timer.
.const IOINIT = $FF84 // Initialize CIA's, SID volume; setup memory configuration; set and start interrupt timer.
.const RAMTAS = $FF87 // Clear memory addresses $0002-$0101 and $0200-$03FF; run memory test and set start and end address of BASIC work area accordingly; set screen memory to $0400 and datasette buffer to $033C.
.const RESTOR = $FF8A // Fill vector table at memory addresses $0314-$0333 with default values.
.const VECTOR = $FF8D // Copy vector table at memory addresses $0314-$0333 from or into user table.
.const SETMSG = $FF90 // Set system error display switch at memory address $009D.
.const LSTNSA = $FF93 // Send LISTEN secondary address to serial bus. (Must call LISTEN beforehands.)
.const TALKSA = $FF96 // Send TALK secondary address to serial bus. (Must call TALK beforehands.)
.const MEMBOT = $FF99 // Save or restore start address of BASIC work area.
.const MEMTOP = $FF9C // Save or restore end address of BASIC work area.
.const SCNKEY = $FF9F // Query keyboard; put current matrix code into memory address $00CB, current status of shift keys into memory address $028D and PETSCII code into keyboard buffer.
.const SETTMO = $FFA2 // Unknown. (Set serial bus timeout.)
.const IECIN  = $FFA5 // Read byte from serial bus. (Must call TALK and TALKSA beforehands.)
.const IECOUT = $FFA8 // Write byte to serial bus. (Must call LISTEN and LSTNSA beforehands.)
.const UNTALK = $FFAB // Send UNTALK command to serial bus.
.const UNLSTN = $FFAE // Send UNLISTEN command to serial bus.
.const LISTEN = $FFB1 // Send LISTEN command to serial bus.
.const TALK   = $FFB4 // Send TALK command to serial bus.
.const READST = $FFB7 // Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
.const SETLFS = $FFBA // Set file parameters.
.const SETNAM = $FFBD // Set file name parameters.
.const OPEN   = $FFC0 // Open file. (Must call SETLFS and SETNAM beforehands.)
.const CLOSE  = $FFC3 // Close file.
.const CHKIN  = $FFC6 // Define file as default input. (Must call OPEN beforehands.)
.const CHKOUT = $FFC9 // Define file as default output. (Must call OPEN beforehands.)
.const CLRCHN = $FFCC // Close default input/output files (for serial bus, send UNTALK and/or UNLISTEN); restore default input/output to keyboard/screen.
.const CHRIN  = $FFCF // Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
.const CHROUT = $FFD2 // Write byte to default output. (If not screen, must call OPEN and CHKOUT beforehands.)
.const LOAD   = $FFD5 // Load or verify file. (Must call SETLFS and SETNAM beforehands.)
.const SAVE   = $FFD8 // Save file. (Must call SETLFS and SETNAM beforehands.)
.const SETTIM = $FFDB // Set Time of Day, at memory address $00A0-$00A2.
.const RDTIM  = $FFDE // read Time of Day, at memory address $00A0-$00A2.
.const STOP   = $FFE1 // Query Stop key indicator, at memory address $0091; if pressed, call CLRCHN and clear keyboard buffer.
.const GETIN  = $FFE4 // Read byte from default input. (If not keyboard, must call OPEN and CHKIN beforehands.)
.const CLALL  = $FFE7 // Clear file table; call CLRCHN.
.const UDTIM  = $FFEA // Update Time of Day, at memory address $00A0-$00A2, and Stop key indicator, at memory address $0091.
.const SCREEN = $FFED // Fetch number of screen rows and columns.
.const PLOT   = $FFF0 // Save or restore cursor position.
.const IOBASE = $FFF3 // Fetch CIA #1 base address.