#importonce

// Misc - Must be categorized later...
// and better names welcome...
.const DEFAULT_IRQ_HANDLER_WITH_CURSOR = $EA31
.const DEFAULT_IRQ_HANDLER_WITHOUT_CURSOR = $EA81

// Interrupt
.const IRQ_SERVICE_ADDRESS      = $0314
.const IRQ_SERVICE_ADDRESS_LO   = $0314
.const IRQ_SERVICE_ADDRESS_HI   = $0315

CIA1: {
    .label DATA_PORT_A    = $DC00
    .label DATA_PORT_B    = $DC01
    .label CONTROL_STATUS = $DC0D
}

CIA2: {
    .label DATA_PORT_A    = $DD00
    .label DATA_PORT_B    = $DD01
    .label CONTROL_STATUS = $DD0D
}


VIC: {
    .label SPRITE_0_X               = $D000
    .label SPRITE_0_Y               = $D001
    .label SPRITE_1_X               = $D002
    .label SPRITE_1_Y               = $D003
    .label SPRITE_2_X               = $D004
    .label SPRITE_2_Y               = $D005
    .label SPRITE_3_X               = $D006
    .label SPRITE_3_Y               = $D007
    .label SPRITE_4_X               = $D008
    .label SPRITE_4_Y               = $D009
    .label SPRITE_5_X               = $D00A
    .label SPRITE_5_Y               = $D00B
    .label SPRITE_6_X               = $D00C
    .label SPRITE_6_Y               = $D00D
    .label SPRITE_7_X               = $D00E
    .label SPRITE_7_Y               = $D00F
    .label SPRITE_MSB_X             = $D010 // Sprite 0-7 horizontal position MSB
    .label VERTICAL_CONTROL         = $D011 // RST8 ECM- BMM- DEN- RSEL [   YSCROLL   ]
    .label RASTER_COUNTER           = $D012
    .label LIGHT_PEN_X              = $D013
    .label LIGHT_PEN_Y              = $D014
    .label SPRITE_ENABLE            = $D015
    .label HORIZONTAL_CONTROL       = $D016 //  RES- MCM- CSEL [   XSCROLL   ]
    .label SPRITE_EXPAND_Y          = $D017
    .label MEM_POINTERS             = $D018 // VM13 VM12 VM11 VM10 CB13 CB12 CB11 ----
    .label INTERRUPT_STATUS         = $D019 // IRQ- ---- ---- ---- ILP- IMMC IMBC IRST
    .label INTERRUPT_CONTROL        = $D01A // ---- ---- ---- ---- ELP- EMMC EMBC ERST
    .label SPRITE_PRIORITY          = $D01B
    .label SPRITE_MULTICOLOR        = $D01C
    .label SPRITE_EXPAND_X          = $D01D
    .label SPRITE_COLLISION_SPR     = $D01E
    .label SPRITE_COLLISION_DATA    = $D01F
    .label BORDER_COLOR             = $D020
    .label BACKGROUND_COLOR         = $D021
    .label BACKGROUND_COLOR_1       = $D022
    .label BACKGROUND_COLOR_2       = $D023
    .label BACKGROUND_COLOR_3       = $D024
    .label SPRITE_MULTICOLOR_0      = $D025
    .label SPRITE_MULTICOLOR_1      = $D026
    .label SPRITE_0_COLOR           = $D027
    .label SPRITE_1_COLOR           = $D028
    .label SPRITE_2_COLOR           = $D029
    .label SPRITE_3_COLOR           = $D02A
    .label SPRITE_4_COLOR           = $D02B
    .label SPRITE_5_COLOR           = $D02C
    .label SPRITE_6_COLOR           = $D02D
    .label SPRITE_7_COLOR           = $D02E
}
// KERNAL routines
KERNAL: {
    .label SCINIT = $FF81 // Initialize VIC; restore default input/output to keyboard/screen; clear screen; set PAL/NTSC switch and interrupt timer.
    .label IOINIT = $FF84 // Initialize CIA's, SID volume; setup memory configuration; set and start interrupt timer.
    .label RAMTAS = $FF87 // Clear memory addresses $0002-$0101 and $0200-$03FF; run memory test and set start and end address of BASIC work area accordingly; set screen memory to $0400 and datasette buffer to $033C.
    .label RESTOR = $FF8A // Fill vector table at memory addresses $0314-$0333 with default values.
    .label VECTOR = $FF8D // Copy vector table at memory addresses $0314-$0333 from or into user table.
    .label SETMSG = $FF90 // Set system error display switch at memory address $009D.
    .label LSTNSA = $FF93 // Send LISTEN secondary address to serial bus. (Must call LISTEN beforehands.)
    .label TALKSA = $FF96 // Send TALK secondary address to serial bus. (Must call TALK beforehands.)
    .label MEMBOT = $FF99 // Save or restore start address of BASIC work area.
    .label MEMTOP = $FF9C // Save or restore end address of BASIC work area.
    .label SCNKEY = $FF9F // Query keyboard; put current matrix code into memory address $00CB, current status of shift keys into memory address $028D and PETSCII code into keyboard buffer.
    .label SETTMO = $FFA2 // Unknown. (Set serial bus timeout.)
    .label IECIN  = $FFA5 // Read byte from serial bus. (Must call TALK and TALKSA beforehands.)
    .label IECOUT = $FFA8 // Write byte to serial bus. (Must call LISTEN and LSTNSA beforehands.)
    .label UNTALK = $FFAB // Send UNTALK command to serial bus.
    .label UNLSTN = $FFAE // Send UNLISTEN command to serial bus.
    .label LISTEN = $FFB1 // Send LISTEN command to serial bus.
    .label TALK   = $FFB4 // Send TALK command to serial bus.
    .label READST = $FFB7 // Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
    .label SETLFS = $FFBA // Set file parameters.
    .label SETNAM = $FFBD // Set file name parameters.
    .label OPEN   = $FFC0 // Open file. (Must call SETLFS and SETNAM beforehands.)
    .label CLOSE  = $FFC3 // Close file.
    .label CHKIN  = $FFC6 // Define file as default input. (Must call OPEN beforehands.)
    .label CHKOUT = $FFC9 // Define file as default output. (Must call OPEN beforehands.)
    .label CLRCHN = $FFCC // Close default input/output files (for serial bus, send UNTALK and/or UNLISTEN); restore default input/output to keyboard/screen.
    .label CHRIN  = $FFCF // Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
    .label CHROUT = $FFD2 // Write byte to default output. (If not screen, must call OPEN and CHKOUT beforehands.)
    .label LOAD   = $FFD5 // Load or verify file. (Must call SETLFS and SETNAM beforehands.)
    .label SAVE   = $FFD8 // Save file. (Must call SETLFS and SETNAM beforehands.)
    .label SETTIM = $FFDB // Set Time of Day, at memory address $00A0-$00A2.
    .label RDTIM  = $FFDE // read Time of Day, at memory address $00A0-$00A2.
    .label STOP   = $FFE1 // Query Stop key indicator, at memory address $0091; if pressed, call CLRCHN and clear keyboard buffer.
    .label GETIN  = $FFE4 // Read byte from default input. (If not keyboard, must call OPEN and CHKIN beforehands.)
    .label CLALL  = $FFE7 // Clear file table; call CLRCHN.
    .label UDTIM  = $FFEA // Update Time of Day, at memory address $00A0-$00A2, and Stop key indicator, at memory address $0091.
    .label SCREEN = $FFED // Fetch number of screen rows and columns.
    .label PLOT   = $FFF0 // Save or restore cursor position.
    .label IOBASE = $FFF3 // Fetch CIA #1 base address.

    .label NMI_ADDRESS   = $FFFA
    .label RESET_ADDRESS = $FFFC
    .label IRQ_ADDRESS   = $FFFE
}
