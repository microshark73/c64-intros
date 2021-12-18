#import "constants.asm"

BasicUpstart2(main)

* = $0900 "main"

main:
    sei
    lda #<irq
    sta IRQ_SERVICE_ADDRESS_LO
    lda #>irq
    sta IRQ_SERVICE_ADDRESS_HI
    lda #$7f
    sta CIA1_CONTROL_STATUS // Disable CIA1 interrupts
    sta CIA2_CONTROL_STATUS // Disable CIA2 interrupts
    lda #$01
    sta VIC_INTERRUPT_CONTROL // Enable raster interrupts
    lda #$60
    sta VIC_RASTER_COUNTER
    lda #$1b
    sta VIC_CONTROL_REG_1
    cli
    rts
irq:
    asl VIC_INTERRUPT_STATUS
    inc BORDER_COLOR
    jmp DEFAULT_IRQ_HANDLER_WITH_CURSOR
