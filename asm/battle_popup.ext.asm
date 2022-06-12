.definelabel @POPUP_STATE_IDLE,	0x0
.definelabel @POPUP_STATE_OPENING,	0x1
.definelabel @POPUP_STATE_CLOSING,	0x2

.align 2
popup_init:
	// r5 = state data
	push	r14

	mov	r1,0x46
	mov	r0,((@POPUP_STATE_IDLE) | ((8) << 4))
	strb	r0,[r5,r1]		// chip popup state

	mov	r0,0xFF
	mov	r1,0x47
	strb	r0,[r5,r1]		// shown chip

	bl	@getMyPopupData
	ldrb	r0,[r0,@popupData_hiddenX]
	mov	r1,0x48
	strb	r0,[r5,r1]		// chip popup x

	// Enable BG0
	ldr	r2,=addr_0x20031E0
	ldrh	r1,[r2]
	mov	r0,0x1
	lsl	r0,r0,0x8
	orr	r1,r0
	strh	r1,[r2]

	// Setup BG0
	ldr	r0,=0x0008
	strh	r0,[r2,0x4]		// BG0CNT
	ldr	r0,=0x00000000
	str	r0,[r2,0xC]		// BG0HOFS+BG0VOFS
//	ldr	r0,=0x0000
//	strh	r0,[r2,0xC]		// BG0HOFS
//	strh	r0,[r2,0xE]		// BG0VOFS

	// Load empty font tiles
	ldr	r0,=tileset_fontEmpty
	ldr	r1,=addr_0x600A640
	mov	r2,((2)*0x20 / 0x4)
	ldr	r3,=addr_0x804DB24|1
	bl	bx_r3

	// Load popups tileset
	ldr	r0,=tileset_battleChip
	ldr	r1,=0x8C00
	ldr	r2,=addr_0x8002300|1
	bl	bx_r2

	// Load additional HP bar tileset
	ldr	r0,=addr_0x830E420
	ldr	r1,=addr_0x600BF20
	mov	r2,(0xE0 >> 0x2)
	ldr	r3,=addr_0x804DB24|1
	bl	bx_r3

//	// Load palette (should already be loaded)
//	ldr	r0,=addr_0x805C95C
//	mov	r1,(11)		// palette number
//	ldr	r2,=addr_0x8007BEC|1	// load palette
//	bl	bx_r2

	pop	r15


.align 2
popup_open:
	// r5 = state data
	mov	r1,0x46
	ldrb	r0,[r5,r1]		// chip popup state
	lsr	r0,r0,0x2
	lsl	r0,r0,0x2
	add	r0,@POPUP_STATE_OPENING
	strb	r0,[r5,r1]		// chip popup state

	bx	r14


.align 2
popup_close:
	// r5 = state data
	mov	r1,0x46
	ldrb	r0,[r5,r1]		// chip popup state
	lsr	r0,r0,0x2
	lsl	r0,r0,0x2
	add	r0,@POPUP_STATE_CLOSING
	strb	r0,[r5,r1]		// chip popup state

	bx	r14


.align 2
popup_openFast:
	// r5 = state data
	push	r14

	mov	r1,0x46
	ldrb	r0,[r5,r1]		// chip popup state
	lsr	r0,r0,0x2
	lsl	r0,r0,0x2
	add	r0,@POPUP_STATE_IDLE
	strb	r0,[r5,r1]		// chip popup state

	bl	@getMyPopupData
	ldrb	r0,[r0,@popupData_shownX]
	mov	r1,0x48
	strb	r0,[r5,r1]		// chip popup x

	pop	r15


.align 2
popup_closeFast:
	// r5 = state data
	push	r14

	mov	r1,0x46
	ldrb	r0,[r5,r1]		// chip popup state
	lsr	r0,r0,0x2
	lsl	r0,r0,0x2
	add	r0,@POPUP_STATE_IDLE
	strb	r0,[r5,r1]		// chip popup state

	bl	@getMyPopupData
	ldrb	r0,[r0,@popupData_hiddenX]
	mov	r1,0x48
	strb	r0,[r5,r1]		// chip popup x

	pop	r15


.align 2
popup_isOpen:
	// r5 = state data
	push	r14

	mov	r0,0x46
	ldrb	r0,[r5,r0]		// chip popup state
	lsl	r0,r0,0x1E
	lsr	r0,r0,0x1E
	cmp	r0,@POPUP_STATE_IDLE
	bne	@@returnFalse

	bl	@getMyPopupData
	ldrb	r0,[r0,@popupData_shownX]

	mov	r1,0x48
	ldrb	r1,[r5,r1]		// chip popup x
	cmp	r0,r1
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
popup_isClosed:
	// r5 = state data
	push	r14

	mov	r0,0x46
	ldrb	r0,[r5,r0]		// chip popup state
	lsl	r0,r0,0x1E
	lsr	r0,r0,0x1E
	cmp	r0,@POPUP_STATE_IDLE
	bne	@@returnFalse

	bl	@getMyPopupData
	ldrb	r0,[r0,@popupData_hiddenX]

	mov	r1,0x48
	ldrb	r1,[r5,r1]		// chip popup x
	cmp	r0,r1
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
popup_handler:
	// r5 = state data
	push	r14

	mov	r0,0x46
	ldrb	r0,[r5,r0]		// popup state
	lsl	r0,r0,0x1E
	lsr	r0,r0,0x1E
//	cmp	r0,@POPUP_STATE_IDLE
//	beq	@@end
	cmp	r0,@POPUP_STATE_OPENING
	beq	@@stateOpening
	cmp	r0,@POPUP_STATE_CLOSING
	beq	@@stateClosing
	b	@@end

@@stateOpening:
	bl	@getMyPopupData

	// Check already shown
	mov	r2,0x48
	ldsb	r3,[r5,r2]		// chip popup x
	ldrb	r1,[r0,@popupData_shownX]
	lsl	r1,r1,0x18
	asr	r1,r1,0x18
	cmp	r3,r1
	beq	@@gotoIdle

	// Add twice
	ldrb	r0,[r0,@popupData_deltaX]
	lsl	r0,r0,0x18
	asr	r0,r0,0x18
	add	r3,r3,r0
	cmp	r3,r1
	beq	@@stateOpening_storeX
	add	r3,r3,r0
@@stateOpening_storeX:
	strb	r3,[r5,r2]

	b	@@end

@@stateClosing:
	bl	@getMyPopupData

	// Check already hidden
	mov	r2,0x48
	ldsb	r3,[r5,r2]		// chip popup x
	ldrb	r1,[r0,@popupData_hiddenX]
	lsl	r1,r1,0x18
	asr	r1,r1,0x18
	cmp	r3,r1
	beq	@@gotoIdle

	// Sub twice
	ldrb	r0,[r0,@popupData_deltaX]
	lsl	r0,r0,0x18
	asr	r0,r0,0x18
	sub	r3,r3,r0
	cmp	r3,r1
	beq	@@stateClosing_storeX
	sub	r3,r3,r0
@@stateClosing_storeX:
	strb	r3,[r5,r2]

	b	@@end

@@gotoIdle:
	mov	r1,0x46
	ldrb	r0,[r5,r1]
	lsr	r0,r0,0x2
	lsl	r0,r0,0x2
	add	r0,@POPUP_STATE_IDLE
	strb	r0,[r5,r1]

//	b	@@end

@@end:
	pop	r15


	.pool


.align 2
popup_draw:
	// r0 = background data
	// r5 = state data
	push	r4,r6-r7,r14
	sub	sp,((4)*0x4)
	mov	r4,r0

	// If closing, do not refresh
	mov	r0,0x46
	ldrb	r0,[r5,r0]		// chip popup state
	lsl	r0,r0,0x1E
	lsr	r0,r0,0x1E
	cmp	r0,@POPUP_STATE_CLOSING
	beq	@@drawPopup

	// Refresh for new chip
	ldrb	r0,[r5,0x6]		// cursor position
	bl	battle_getChipAtCursor
	mov	r7,r0

	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor

	ldrb	r1,[r5,0x6]		// cursor position
	mov	r2,0x47
	strb	r1,[r5,r2]		// shown chip

	cmp	r7,r0
	beq	@@drawPopup

@@load:
	// Set chip open timer
	ldrb	r0,[r5,0x7]
	mov	r1,(0xF << 0x4)
	bic	r0,r1
	mov	r1,((9) << 0x4)
	orr	r0,r1
	strb	r0,[r5,0x7]		// chip open timer

	// Load chip image
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	mov	r1,r0
	mov	r0,0x4		// newly added slot
	ldr	r2,=addr_0x8009EDC|1	// load chip image and palette
	bl	bx_r2

	// Flush palettes to VRAM immediately
	ldr	r0,=addr_0x80026E4|1
	bl	bx_r0

@@drawPopup:
	bl	popup_isClosed
	cmp	r0,0x0
	beq	@@drawPopup2

	// Clear chip open timer
	ldrb	r0,[r5,0x7]
	mov	r1,(0xF << 0x4)
	bic	r0,r1
	strb	r0,[r5,0x7]

	b	@@timer

@@drawPopup2:
	// Load popup tilemap
	mov	r0,(19)		// height
	str	r0,[sp]
	ldr	r0,=0x60		// base tile
	str	r0,[sp,0x4]
	mov	r0,(11)		// palette
	str	r0,[sp,0x8]
	ldr	r0,=tilemap_battleChip
	str	r0,[sp,0xC]

	mov	r0,r4			// background data
	mov	r1,0x48
	ldsb	r1,[r5,r1]		// x
	mov	r2,(0)		// y
	mov	r3,(12)		// width
	ldr	r7,=addr_0x8006374|1	// draw tilemap
	bl	bx_r7

	// Draw chip sprite
//	ldr	r0,=addr_0x3002C30
//	ldr	r1,[r0]		// OAM write pointer
	ldr	r1,=addr_0x70003F8	// last OAM in VRAM
	ldr	r2,=0xC0001000

	ldrb	r7,[r5,0x7]		// chip open timer
	lsr	r7,r7,0x4
	cmp	r7,(7)
	bgt	@@drawName

	mov	r3,(25)		// y
	cmp	r7,0x0
	beq	@@setChipY
	sub	r3,(32)

@@setChipY:
	lsl	r3,r3,0x18
	lsr	r3,r3,0x18
	orr	r2,r3

	mov	r3,0x48
	ldsb	r3,[r5,r3]		// x
	lsl	r3,r3,0x3
	add	r3,(16)
	cmp	r7,0x0
	beq	@@setChipX
	sub	r3,(32)

	// Also set rot/scal settings
	// r7 no longer used for a bit
	mov	r7,(31)		// rot/scal params
	lsl	r7,r7,0x19
	orr	r2,r7
	mov	r7,0x3
	lsl	r7,r7,0x8
	orr	r2,r7

@@setChipX:
	lsl	r3,r3,0x17
	lsr	r3,r3,0x7
	orr	r2,r3
	ldr	r3,=0x2100
	str	r2,[r1]
	strh	r3,[r1,0x4]
	add	r1,0x8
	str	r1,[r0]

@@drawName:
	// Get chip name
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x80246A8|1
	bl	bx_r1
	mov	r1,r0

	// Draw chip name
	mov	r0,(8)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	mov	r0,r4			// background data
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(2)		// x
	mov	r3,(1)		// y
	ldr	r7,=addr_0x8006AD8|1
	bl	bx_r7

	// Get chip attack type
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x80246C4|1
	bl	bx_r1
	mov	r1,r0

	// Draw chip attack type
	mov	r0,(8)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	mov	r0,r4			// background data
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(2)		// x
	mov	r3,(10)		// y
	ldr	r7,=addr_0x8006AD8|1
	bl	bx_r7

	// Determine whether to show HP bar
	mov	r0,0x47
	ldrb	r0,[r5,r0]
	cmp	r0,0xC		// OK button
	bge	@@drawParameters
	bl	battle_getChipAtCursor
	cmp	r0,0xC4
	beq	@@drawParameters
	cmp	r0,0xC6
	beq	@@drawParameters
	cmp	r0,0xC7
	beq	@@drawParameters

	// Get max HP
	ldr	r1,=addr_0x8024554|1
	bl	bx_r1
	mov	r6,r0			// chip max HP
	beq	@@drawParameters

	// Get current HP
	bl	battle_getMySide
	mov	r1,0x90
	mul	r0,r1
	mov	r1,0x47
	ldrb	r1,[r5,r1]		// shown chip
	mov	r2,0xC
	mul	r1,r2
	add	r1,r0,r1
	ldr	r0,=(addr_0x200B810+0x20)
	add	r0,r0,r1
	ldrh	r0,[r0,0x2]		// current HP
	cmp	r0,0x0
	ble	@@drawParameters
	cmp	r0,r6
	ble	@@calcHP
	mov	r0,r6

@@calcHP:
	mov	r1,(24)
	mul	r0,r1			// current HP * 24
	mov	r1,r6			// max HP
	ldr	r2,=addr_0x804DD08|1	// div
	bl	bx_r2
	mov	r1,r0

	// Draw chip HP bar
	mov	r0,r4			// background data
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(2)		// x
	mov	r3,(12)		// y
	ldr	r7,=addr_0x8007840|1
	bl	bx_r7

@@drawParameters:
	// Get chip max HP
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x8024554|1
	bl	bx_r1
	mov	r1,r0

	// Draw chip max HP
	mov	r0,(3)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	mov	r0,r4			// background data
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(3)		// x
	mov	r3,(15)		// y
	ldr	r7,=addr_0x8006E6C|1
	bl	bx_r7

	// Get chip AP
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x8024570|1
	bl	bx_r1
	mov	r1,r0

	// Draw chip AP
	mov	r0,(3)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	mov	r0,r4			// background data
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(8)		// x
	mov	r3,(15)		// y
	ldr	r7,=addr_0x8006E6C|1
	bl	bx_r7

	// Get chip MB
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x8024634|1
	bl	bx_r1
	mov	r7,r0			// base MB

	ldrb	r0,[r5,0x6]		// cursor position
	cmp	r0,0x0		// NaviChip
	bne	@@drawMB

	ldr	r1,=addr_0x8024F08|1
	bl	bx_r1			// additional Navi MB
	add	r7,r7,r0

@@drawMB:
	// Draw chip MB
	mov	r0,(3)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	mov	r0,r4			// background data
	mov	r1,r7
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(3)		// x
	mov	r3,(17)		// y
	ldr	r7,=addr_0x8006E6C|1
	bl	bx_r7

	// Get chip element
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	ldr	r1,=addr_0x80245E0|1
	bl	bx_r1
	lsl	r0,r0,0x10
	lsr	r0,r0,0x1C
	lsl	r0,r0,0x2
	ldr	r1,=addr_0x8232B90
	ldr	r1,[r1,r0]
	ldr	r1,[r1]		// element string

	// Draw chip element
	mov	r0,(4)		// width
	str	r0,[sp]
	mov	r0,(0)		// font
	str	r0,[sp,0x4]

	mov	r0,r4			// background data
	mov	r2,0x48
	ldsb	r2,[r5,r2]
	add	r2,(7)		// x
	mov	r3,(17)		// y
	ldr	r7,=addr_0x8006AD8|1
	bl	bx_r7

@@timer:
	// Check chip open timer
	ldrb	r0,[r5,0x7]		// chip open timer
	lsr	r1,r0,0x4
	cmp	r1,0x0
	beq	@@reloadPalette

	// Decrement chip open timer
	sub	r0,((1) << 0x4)
	strb	r0,[r5,0x7]		// chip open timer

	sub	r1,0x1
	cmp	r1,(7)
	bge	@@end

	// Set rot/scal parameters
	lsl	r1,r1,0x1		// chip open timer * 2
	ldr	r0,=addr_0x70003E0	// last rot/scal params
	add	r2,=@chipRotScalX
	ldrh	r2,[r2,r1]
	strh	r2,[r0,0x6]
	mov	r2,0x0
	strh	r2,[r0,0xE]
	strh	r2,[r0,0x16]
	add	r2,=@chipRotScalY
	ldrh	r2,[r2,r1]
	strh	r2,[r0,0x1E]

@@reloadPalette:
	// Reload chip palette
	mov	r0,0x47
	ldrb	r0,[r5,r0]		// shown chip
	bl	battle_getChipAtCursor
	mov	r1,r0
	mov	r0,0x4		// newly added slot
	ldr	r2,=addr_0x8009F78|1	// load chip palette
	bl	bx_r2

	// Apply blending to chip palette
	ldr	r0,=(addr_0x3002420+0x240)
	ldr	r1,=0x677C
	ldr	r2,=(addr_0x3002420+0x240)
	ldrb	r3,[r5,0x7]		// chip open timer
	lsr	r3,r3,0x4
	add	r7,=@chipPalBlend
	ldrb	r3,[r7,r3]
	ldr	r7,=addr_0x8023598|1	// load palette blended
	bl	bx_r7

	// Flush palettes to VRAM immediately
	ldr	r0,=addr_0x80026E4|1
	bl	bx_r0

@@end:
	add	sp,((4)*0x4)
	pop	r4,r6-r7,r15


.align 4
@chipRotScalX:
	.dh	0x100, 0x115, 0x135, 0x16A, 0x1CD, 0x2A3, 0x539

.align 4
@chipRotScalY:
	.dh	0x100, 0x0FF, 0x0FF, 0x0FF, 0x0FF, 0x0FF, 0x0FF

.align 4
@chipPalBlend:
	.db	0x0, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE


.align 2
@getMyPopupData:
	push	r14

	bl	battle_getMySide
	mov	r1,@popupData_sizeof
	mul	r0,r1
	add	r1,=@popupData
	add	r0,r1,r0

	pop	r15


	.pool


.align 4
@popupData:
.definelabel @popupData_hiddenX,	0x0
.definelabel @popupData_shownX,	0x1
.definelabel @popupData_deltaX,	0x2
.definelabel @popupData_sizeof,	0x3
	// My side
	.db	(31), (19), (-1)
	// Other side
	.db	(-13), (-1), (1)
