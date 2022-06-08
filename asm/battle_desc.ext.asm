.definelabel @DESC_STATE_IDLE,	0x0
.definelabel @DESC_STATE_OPENING,	0x1
.definelabel @DESC_STATE_CLOSING,	0x2

.align 2
description_open:
	// r5 = state data
	mov	r1,0x46
	ldrb	r0,[r5,r1]		// description popup state
	mov	r2,(0x3 << 0x2)
	bic	r0,r2
	add	r0,(@DESC_STATE_OPENING << 0x2)
	strb	r0,[r5,r1]		// description popup state

	bx	r14


.align 2
description_close:
	// r5 = state data
	mov	r1,0x46
	ldrb	r0,[r5,r1]		// description popup state
	mov	r2,(0x3 << 0x2)
	bic	r0,r2
	add	r0,(@DESC_STATE_CLOSING << 0x2)
	strb	r0,[r5,r1]		// description popup state

	bx	r14


.align 2
description_openFast:
	// r5 = state data
	mov	r1,0x46
	ldrb	r0,[r5,r1]		// description popup state
	mov	r2,((0x3 << 0x2) | (0xF << 0x4))
	bic	r0,r2
	add	r0,(@DESC_STATE_IDLE << 0x2)
	add	r0,((0) << 0x4)
	strb	r0,[r5,r1]

	bx	r14


.align 2
description_closeFast:
	// r5 = state data
	mov	r1,0x46
	ldrb	r0,[r5,r1]		// description popup state
	mov	r2,((0x3 << 0x2) | (0xF << 0x4))
	bic	r0,r2
	add	r0,(@DESC_STATE_IDLE << 0x2)
	add	r0,((8) << 0x4)
	strb	r0,[r5,r1]

	bx	r14


.align 2
description_isOpen:
	// r5 = state data
	push	r14

	mov	r0,0x46
	ldrb	r0,[r5,r0]		// description popup state
	lsl	r1,r0,0x1C
	lsr	r1,r1,0x1E
	cmp	r1,@DESC_STATE_IDLE
	bne	@@returnFalse

	lsr	r0,r0,0x4
	cmp	r0,(0)
	bne	@@returnFalse

@@returnTrue:
	mov	r0,0x1
	b	@@end
@@returnFalse:
	mov	r0,0x0
//	b	@@end
@@end:
	pop	r15


.align 2
description_isClosed:
	// r5 = state data
	push	r14

	mov	r0,0x46
	ldrb	r0,[r5,r0]		// description popup state
	lsl	r1,r0,0x1C
	lsr	r1,r1,0x1E
	cmp	r1,@DESC_STATE_IDLE
	bne	@@returnFalse

	lsr	r0,r0,0x4
	cmp	r0,(8)
	bne	@@returnFalse

@@returnTrue:
	mov	r0,0x1
	b	@@end
@@returnFalse:
	mov	r0,0x0
//	b	@@end
@@end:
	pop	r15


.align 2
description_handler:
	// r5 = state data
	push	r14

	mov	r0,0x46
	ldrb	r0,[r5,r0]		// popup state
	lsl	r0,r0,0x1C
	lsr	r0,r0,0x1E
//	cmp	r0,@DESC_STATE_IDLE
//	beq	@@end
	cmp	r0,@DESC_STATE_OPENING
	beq	@@stateOpening
	cmp	r0,@DESC_STATE_CLOSING
	beq	@@stateClosing
	b	@@end

@@stateOpening:
	// Check already shown
	mov	r0,0x46
	ldrb	r1,[r5,r0]		// popup state
	lsr	r2,r1,0x4
	cmp	r2,(0)
	beq	@@gotoIdle

	// Sub twice
	sub	r2,(1)
	cmp	r2,(4)
	ble	@@stateOpening_storeY
//	cmp	r2,(0)
//	beq	@@stateOpening_storeY
	sub	r2,(1)
@@stateOpening_storeY:
	lsl	r1,r1,0x1C
	lsr	r1,r1,0x1C
	lsl	r2,r2,0x4
	orr	r1,r2
	strb	r1,[r5,r0]

	b	@@end

@@stateClosing:
	// Check already shown
	mov	r0,0x46
	ldrb	r1,[r5,r0]		// popup state
	lsr	r2,r1,0x4
	cmp	r2,(8)
	beq	@@gotoIdle

	// Add twice
	add	r2,(1)
	cmp	r2,(4)
	ble	@@stateClosing_storeY
	cmp	r2,(8)
	beq	@@stateClosing_storeY
	add	r2,(1)
@@stateClosing_storeY:
	lsl	r1,r1,0x1C
	lsr	r1,r1,0x1C
	lsl	r2,r2,0x4
	orr	r1,r2
	strb	r1,[r5,r0]

	b	@@end

@@gotoIdle:
	mov	r1,0x46
	ldrb	r0,[r5,r1]
	mov	r2,(0x3 << 0x2)
	bic	r0,r2
	add	r0,(@DESC_STATE_IDLE << 0x2)
	strb	r0,[r5,r1]

//	b	@@end

@@end:
	pop	r15


.align 2
description_draw:
	// r0 = background data
	// r5 = state data
	push	r6-r7,r14
	sub	sp,((4)*0x4)
	mov	r6,r0

	bl	description_isClosed
	cmp	r0,0x0
	bne	@@end

	// Load description tilemap
	mov	r0,(8)		// height
	str	r0,[sp]
	ldr	r0,=0x60		// base tile
	str	r0,[sp,0x4]
	mov	r0,(11)		// palette
	str	r0,[sp,0x8]
	ldr	r0,=tilemap_description
	str	r0,[sp,0xC]

	bl	battle_getMySide
	mov	r1,(10)
	mul	r1,r0			// x
	mov	r0,r6			// background data
	mov	r2,0x46
	ldrb	r2,[r5,r2]
	lsr	r2,r2,0x4		// y offset
	add	r2,(11)		// y
	mov	r3,(20)		// width
	ldr	r7,=addr_0x8006374|1	// draw tilemap
	bl	bx_r7

	// Get chip description line 1
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x80246E0|1
	bl	bx_r1
	ldr	r1,[r0]

	// Draw chip description line 1
	mov	r0,(18)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	bl	battle_getMySide
	mov	r2,(10)
	mul	r2,r0
	add	r2,(1)		// x
	mov	r0,r6			// background data
	mov	r3,0x46
	ldrb	r3,[r5,r3]
	lsr	r3,r3,0x4		// y offset
	add	r3,(12)		// y
	ldr	r7,=addr_0x8006AD8|1
	bl	bx_r7

	// Get chip description line 2
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x80246E0|1
	bl	bx_r1
	ldr	r1,[r0,0x4]

	// Draw chip description line 2
	mov	r0,(18)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	bl	battle_getMySide
	mov	r2,(10)
	mul	r2,r0
	add	r2,(1)		// x
	mov	r0,r6			// background data
	mov	r3,0x46
	ldrb	r3,[r5,r3]
	lsr	r3,r3,0x4		// y offset
	add	r3,(14)		// y
	ldr	r7,=addr_0x8006AD8|1
	bl	bx_r7

	// Get chip description line 3
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x80246E0|1
	bl	bx_r1
	ldr	r1,[r0,0x8]

	// Draw chip description line 3
	mov	r0,(18)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x8]

	bl	battle_getMySide
	mov	r2,(10)
	mul	r2,r0
	add	r2,(1)		// x
	mov	r0,r6			// background data
	mov	r3,0x46
	ldrb	r3,[r5,r3]
	lsr	r3,r3,0x4		// y offset
	add	r3,(16)		// y
	ldr	r7,=addr_0x8006AD8|1
	bl	bx_r7

@@end:
	add	sp,((4)*0x4)
	pop	r6-r7,r15


	.pool
