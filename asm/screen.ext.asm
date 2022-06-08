.align 2
screen_getBaseTileMap:
	ldrb	r0,[r0,0xB]
	cmp	r0,0x1
	beq	@@layer1
	bgt	@@layer2
@@layer0:	// BG1
	ldr	r0,=addr_0x2003674
	ldr	r0,[r0]
	b	@@end
@@layer1:	// BG2
	ldr	r0,=addr_0x2004AA0
	b	@@end
@@layer2:	// BG0
	ldr	r0,=addr_0x2000000
@@end:
	bx	r14


.align 2
screen_adjustEmptyTextTileForBG0:
	push	r14

	ldrb	r1,[r0,0xB]		// layer
	cmp	r1,0x2
	bne	@@end

	ldr	r1,[sp,(0x10+0x4)]
	ldr	r2,=(0x132-0x32)	// 0x32 = old, 0x132 = new
	add	r1,r1,r2
	str	r1,[sp,(0x10+0x4)]

@@end:
	ldr	r1,=addr_0x8008610|1	// get base tilemap buffer
	bl	bx_r1
	mov	r5,r0
	asr	r0,r4,0x10
	ldr	r2,[sp,(0x1C+0x4)]
	lsl	r1,r2,0x18
	pop	r15


	.pool


.align 2
screen_chipVramSlots:
	.dh	0x17, 0x18, 0x19, 0x1A
	.dh	0x39	// added, overrides player's intro card
