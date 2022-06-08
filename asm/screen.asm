.org addr_0x8006C38	// Override empty tile for BG0 drawing
.area 0xC,0x00
	ldr	r1,=screen_adjustEmptyTextTileForBG0|1
	bl	addr_0x804DCD0	// blx r1
	b	@@end
	.pool
.endarea
@@end:


.org addr_0x8008610	// Add support for another background layer
.area 0x18,0x00
	ldr	r1,=screen_getBaseTileMap|1
	bx	r1
	.pool
.endarea
.org addr_0x8008682
	cmp	r0,0x1
	beq	addr_0x80086A4


.org addr_0x8009ABC	// Add chip VRAM slot
	.dw	screen_chipVramSlots
.org addr_0x8009F6C
	.dw	screen_chipVramSlots
.org addr_0x8009FC4
	.dw	screen_chipVramSlots
