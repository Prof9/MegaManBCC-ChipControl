// Data Layout
//
// The Program Deck handler has the following bytes of temporary state variables:
//
// Address   Size  Usage
// 02005166  u8    cursor location & timer
// 02005167  u8    flags
//                 0x01 = close popup with description
//                 0x02 = player can reroll
// 020051A6  u8    popup states
//                 0x03 = chip popup state
//                 0x0C = description state
//                 0xF0 = description y-offset
// 020051A7  u8    shown chip
// 020051A8  s8    chip popup x
//

.align 2
battle_programDeckHandler_state2_0:
	// r5 = state data
	ldrb	r0,[r5,0x3]		// state3
	lsl	r0,r0,0x2
	add	r1,=@@states
	ldr	r0,[r1,r0]
	bx	r0

.align 4
@@states:
	.dw	battle_programDeckHandler_state2_0_0|1	// init
	.dw	battle_programDeckHandler_state2_0_1|1	// wait then spawn cursor
	.dw	battle_programDeckHandler_state2_0_2|1	// player control
	.dw	battle_programDeckHandler_state2_0_3|1	// animate OK button
	.dw	battle_programDeckHandler_state2_0_4|1	// multiplayer sync
	.dw	battle_programDeckHandler_state2_0_5|1	// finish

battle_programDeckHandler_state2_0_0:
	// Enable highlight
	bl	@getProgramDeckForMySide
	mov	r1,0x0
	strb	r1,[r0,0x1E]	// only highlight navi chip
	ldrb	r1,[r0,0x1F]	// flags
	mov	r2,0x6
	bic	r1,r2
	mov	r2,0x3		// highlight + visual update
	orr	r1,r2
	strb	r1,[r0,0x1F]	// flags

	// Initialize chip popup
	bl	popup_init

	// Get queue for player
	bl	battle_getMySide
	lsl	r1,r0,0x3		// side*0x8
	mov	r2,0x1C
	mul	r2,r0			// side*0x1C
	ldr	r0,=(addr_0x200B810+0x140)
	add	r1,r0,r1
	ldr	r0,=(addr_0x200B810+0x150)
	add	r2,r0,r2

	// If chip1 already set, do not allow player to choose chips
	ldrb	r0,[r1,(3)]
	cmp	r0,0x0
	beq	@@empty

	// Chips already chosen, skip to end of selection
	bl	@updatePath

	// Set state + timer already expired
	mov	r0,0x3
	strb	r0,[r5,0x3]
	mov	r0,0xFE
	strb	r0,[r5,0x6]

	b	battle_programDeckHandler_state2_0_3

@@empty:
	// Empty queue
	mov	r0,0x0
	strb	r0,[r1,(3)]
	strb	r0,[r1,(4)]
	strb	r0,[r1,(5)]
	str	r0,[r2,(3)*0x4]
	str	r0,[r2,(4)*0x4]
	str	r0,[r2,(5)*0x4]

	// Set state + timer
	mov	r0,0x1
	strb	r0,[r5,0x3]
	mov	r0,(2)
	strb	r0,[r5,0x6]

	// Fall through

battle_programDeckHandler_state2_0_1:
	// Run timer
	ldrb	r0,[r5,0x6]
	cmp	r0,0x0		// check timer 0
	beq	@@state1_run
	sub	r0,0x1
	strb	r0,[r5,0x6]
	b	battle_programDeckHandler_state2_0_end

@@state1_run:
	// Spawn cursor
	ldr	r0,=addr_0x2004CE0	// cursor 1

	mov	r1,(120)
	strh	r1,[r0,0x28]	// x
	mov	r1,(80)
	strh	r1,[r0,0x2A]	// y

	ldrh	r1,[r0,0x2C]	// flags
	ldr	r2,=0xFC01
	and	r1,r2
	mov	r2,0x1		// 0x40, 0x80, 0xC0 = different animations
	orr	r1,r2
	strh	r1,[r0,0x2C]

//	ldr	r0,=addr_0x2004CE0
	mov	r1,0x0		// cursor sprite
	ldr	r2,=addr_0x800800C|1
	bl	bx_r2

	bl	popup_open

	// Go to next state
	mov	r0,0x2
	strb	r0,[r5,0x3]
	mov	r0,0x1		// cursor position 1
	strb	r0,[r5,0x6]

	bl	@updateCursorPos

	b	battle_programDeckHandler_state2_0_end

battle_programDeckHandler_state2_0_2:
	bl	description_isClosed
	cmp	r0,0x0
	bne	battle_programDeckHandler_state2_0_2_descClosed

	bl	description_isOpen
	cmp	r0,0x0
	bne	battle_programDeckHandler_state2_0_2_descOpen

	b	battle_programDeckHandler_state2_0_end

battle_programDeckHandler_state2_0_2_descOpen:
	// Check Select pressed
	ldr	r0,=addr_0x2002F50
	ldrh	r0,[r0,0x4]		// button down

@@checkSelect:
	lsr	r1,r0,0x3		// test 0x4
	bcc	@@checkAny

	bl	popup_isOpen
	cmp	r0,0x0
	beq	@@closeDescription

	b	@@closePopup

@@checkAny:
	cmp	r0,0x0
	beq	@@end

	ldrb	r0,[r5,0x7]
	lsr	r0,r0,0x1		// test 0x1
	bcc	@@closeDescription

//	b	@@closePopup

@@closePopup:
	bl	popup_close

@@closeDescription:
	bl	description_close

	ldrb	r0,[r5,0x7]
	mov	r1,0x1
	bic	r0,r1
	strb	r0,[r5,0x7]

	// Play SFX
	mov	r0,0x66
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

@@end:
	b	battle_programDeckHandler_state2_0_end

battle_programDeckHandler_state2_0_2_descClosed:
	// Check Start pressed
	ldr	r0,=addr_0x2002F50
	ldrh	r0,[r0,0x4]		// button down

@@checkStart:
	lsr	r1,r0,0x4		// test 0x8
	bcc	@@checkSelect

	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]
	cmp	r0,0x0		// check OK button
	bne	@@gotoOK
	b	battle_programDeckHandler_state2_0_end

@@gotoOK:
	// Cursor to OK
	mov	r0,0x0C
	bl	@setCursor

	// Play SFX
	mov	r0,0x66
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

	b	battle_programDeckHandler_state2_0_end

@@checkSelect:
	lsr	r1,r0,0x3		// test 0x4
	bcc	@@checkLR

@@checkOpen:
	bl	popup_isOpen
	cmp	r0,0x0
	beq	@@checkClosed

	bl	popup_close

	b	@@openCloseSFX

@@checkClosed:
	bl	popup_isClosed
	cmp	r0,0x0
	beq	@@openCloseEnd

	bl	popup_open

//	b	@@openCloseSFX

@@openCloseSFX:
	// Play SFX
	mov	r0,0x66
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

@@openCloseEnd:
	b	battle_programDeckHandler_state2_0_end

@@checkLR:
	lsr	r1,r0,0x8		// get L/R
	beq	@@checkB

	ldrb	r0,[r5,0x6]		// cursor position
	bl	battle_getChipAtCursor
	cmp	r0,0x00		// no data
	beq	@@checkLRend
	cmp	r0,0xC4		// empty
	beq	@@checkLRend
	cmp	r0,0xC6		// ok
	beq	@@checkLRend

	bl	popup_isOpen
	cmp	r0,0x0
	bne	@@openDescription

	bl	popup_open

	// Set popup to close with description
	ldrb	r0,[r5,0x7]
	mov	r1,0x1
	orr	r0,r1
	strb	r0,[r5,0x7]

@@openDescription:
	bl	description_open

	// Play SFX
	mov	r0,0x66
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

@@checkLRend:
	b	battle_programDeckHandler_state2_0_end

@@checkB:
	lsr	r1,r0,0x2		// test 0x2
	bcc	@@checkA

	bl	@removeLastChip

	b	battle_programDeckHandler_state2_0_end

@@checkA:
	lsr	r1,r0,0x1		// check 0x1
	bcc	@@checkDpad

	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]
	cmp	r0,0x0		// check OK button
	beq	@@finishDeck

	bl	@selectChip

	b	battle_programDeckHandler_state2_0_end

@@checkDpad:
	ldr	r0,=addr_0x2002F50
	ldrh	r3,[r0,0x6]		// repeated button down

@@checkUp:
	lsr	r0,r3,0x7		// test 0x40
	bcc	@@checkDown

	bl	battle_getMySide
	cmp	r0,0x0
	beq	@@gotoMainUp

	bl	@getItemData
	ldrb	r0,[r0,@menuData_otherSideUp]
	cmp	r0,0xFF
	bne	@@setCursorUpDown

@@gotoMainUp:
	bl	@getItemData
	ldrb	r0,[r0,@menuData_targetUp]
	cmp	r0,0xFF
	beq	@@checkLeft

	b	@@setCursorUpDown

@@checkDown:
	lsr	r0,r3,0x8		// test 0x80
	bcc	@@checkLeft

	bl	battle_getMySide
	cmp	r0,0x0
	beq	@@gotoMainDown

	bl	@getItemData
	ldrb	r0,[r0,@menuData_otherSideDown]
	cmp	r0,0xFF
	bne	@@setCursorUpDown

@@gotoMainDown:
	bl	@getItemData
	ldrb	r0,[r0,@menuData_targetDown]
	cmp	r0,0xFF
	beq	@@checkLeft

//	b	@@setCursorUpDown

@@setCursorUpDown:
	bl	@setCursor

	// Play SFX
	mov	r0,0x66
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

//	b	@@checkLeft

@@checkLeft:
//	ldr	r0,=addr_0x2002F50
//	ldrh	r3,[r0,0x4]		// single button down
	lsr	r0,r3,0x6		// test 0x20
	bcc	@@checkRight

	bl	battle_getMySide
	cmp	r0,0x0
	bne	@@gotoRightTarget

@@gotoLeftTarget:
	bl	@getItemData
	ldrb	r0,[r0,@menuData_targetLeft]
	cmp	r0,0xFF
	beq	@@state2_end
	bl	@setCursor

	b	@@playCursorSFXLeftRight

@@checkRight:
	lsr	r0,r3,0x5		// test 0x10
	bcc	@@state2_end

	bl	battle_getMySide
	cmp	r0,0x0
	bne	@@gotoLeftTarget

@@gotoRightTarget:
	bl	@getItemData
	ldrb	r0,[r0,@menuData_targetRight]
	cmp	r0,0xFF
	beq	@@state2_end
	bl	@setCursor

@@playCursorSFXLeftRight:
	// Play SFX
	mov	r0,0x66
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

//	b	@@state2_end

@@state2_end:
	bl	@updateCursorPos
	b	battle_programDeckHandler_state2_0_end

@@finishDeck:
	bl	@getLastColInPath
	cmp	r0,(5)
	bne	battle_programDeckHandler_state2_0_error

	// Play SFX
	mov	r0,0x67
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

	// Hide cursor
	ldr	r0,=addr_0x2004CE0
	ldrh	r1,[r0,0x2C]	// flags
	mov	r2,0x1
	bic	r1,r2
	strh	r1,[r0,0x2C]	// flags

	bl	popup_close

	// Set state + timer
	mov	r0,0x3
	strb	r0,[r5,0x3]
	mov	r0,(0)
	strb	r0,[r5,0x6]

	// Clear Start button queued up
	ldr	r1,=addr_0x200B810
	ldrb	r0,[r1,0xB]
	cmp	r0,0x1
	bne	@@end
	mov	r0,0x0
	strb	r0,[r1,0xB]

@@end:
	// Fall through

battle_programDeckHandler_state2_0_3:
	// Run timer
	ldrb	r0,[r5,0x6]
	add	r1,r0,0x1
	strb	r1,[r5,0x6]

	cmp	r0,(0)
	beq	@@pressed
	cmp	r0,(4)
	beq	@@unpressed
	cmp	r0,(10)
	bge	@@state3_run

	b	battle_programDeckHandler_state2_0_end

@@unpressed:
	// Draw OK button unpressed
	ldr	r0,=tilemap_programDeck_ok_unpressed
	bl	@drawButton
	
	b	battle_programDeckHandler_state2_0_end

@@pressed:
	// Draw OK button pressed
	ldr	r0,=tilemap_programDeck_ok_pressed
	bl	@drawButton

	b	battle_programDeckHandler_state2_0_end

@@state3_run:
	// Check if multiplayer
	ldr	r1,=addr_0x200B810
	ldrb	r1,[r1,0x6]		// flags
	lsr	r1,r1,0x5		// test 0x10
	bcc	@@singlePlayer

@@multiPlayer:
	// Start sync barrier and send path to other player
	bl	@getProgramDeckForMySide
	ldrb	r0,[r0,0x1D]	// path
	ldr	r1,=addr_0x804AC88|1
	bl	bx_r1

	mov	r0,0x4		// state 4 for multiplayer
	strb	r0,[r5,0x3]
	b	battle_programDeckHandler_state2_0_end

@@singlePlayer:
	mov	r0,0x5		// state 5 for single player
	strb	r0,[r5,0x3]
	b	battle_programDeckHandler_state2_0_end

battle_programDeckHandler_state2_0_4:
	// Wait for sync barrier
	ldr	r0,=addr_0x804ACAC|1
	bl	bx_r0

@@checkError:
	mov	r1,0x2
	cmn	r0,r1			// check -2
	bne	@@checkWaiting

	// Finish Program Deck handler
	mov	r0,0x0
	ldr	r1,=addr_0x8010508|1
	bl	bx_r1

	// Connection error will be handled in upper layer
	b	battle_programDeckHandler_state2_0_end_skipDraw

@@checkWaiting:
	mov	r1,0x1
	cmn	r0,r1			// check -1
	beq	@@end

	// Apply path to other side
	push	r0
	bl	@getOtherSide
	mov	r1,r0
	pop	r0
	bl	@applyPathToSide

	// Go to state 5
	mov	r0,0x5
	strb	r0,[r5,0x3]

@@end:
	b	battle_programDeckHandler_state2_0_end

battle_programDeckHandler_state2_0_5:
	// Run rest of program deck states
	ldr	r0,=addr_0x800F0A0|1
	bx	r0

battle_programDeckHandler_state2_0_error:
	mov	r0,0x6C
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

battle_programDeckHandler_state2_0_end:
	// End of state machine handler
	bl	popup_handler
	bl	description_handler

	sub	sp,0xC

	// Set up BG0 drawing struct
	mov	r0,sp
	mov	r1,0xBA
	strh	r1,[r0]		// max letters
	mov	r1,0x0
	strh	r1,[r0,0x2]		// num of letters
	ldr	r1,=addr_0x2004854
	str	r1,[r0,0x4]		// letters buffer
	ldr	r1,=(0x133-(2))
	strh	r1,[r0,0x8]		// last tile in VRAM
	mov	r1,0x0
	strb	r1,[r0,0xA]		// flags
	mov	r1,0x2
	strb	r1,[r0,0xB]		// layer

//	mov	r0,sp
	bl	popup_draw
	mov	r0,sp
	bl	description_draw

	// Load letters into VRAM
	mov	r0,sp
	ldr	r1,=(0x333-(2))
	strh	r1,[r0,0x8]		// last tile in VRAM
	ldr	r1,=addr_0x80086AC|1
	bl	bx_r1

	// Copy BG0 tilemap to VRAM immediately
	// Note: if DMA used here, causes glitch on the background
	ldr	r0,=addr_0x2000000
	ldr	r1,=addr_0x6000000
	ldr	r2,=0x200
	ldr	r3,=addr_0x804DB24|1
	bl	bx_r3

	add	sp,0xC

	bl	@getLastColInPath
	cmp	r0,(5)
	beq	@@end

	ldr	r0,=tilemap_programDeck_ok_disabled
	bl	@drawButton

@@end:
battle_programDeckHandler_state2_0_end_skipDraw:
	ldr	r0,=addr_0x800F28C|1
	bx	r0


	.pool


.align 2
battle_toggleAutoplay:
	ldr	r0,=addr_0x2005160
	ldr	r1,[r0]
	ldr	r2,=0x02000201
	cmp	r1,r2
	beq	@@end
@@toggle:
	mov	r1,0x44
	ldrb	r2,[r0,r1]
	mov	r3,0x1
	eor	r2,r3
	strb	r2,[r0,r1]
@@end:
	bx	r14


.align 2
battle_clearProgramCells:
	push	r14

	// Do normal update
	ldr	r0,=addr_0x200B810
	mov	r1,0x0
	ldr	r2,=addr_0x8034C1C|1
	bl	bx_r2
	ldr	r0,=addr_0x200B810
	mov	r1,0x1
	ldr	r2,=addr_0x8034C1C|1
	bl	bx_r2

	// Clear the cells
	ldr	r0,=(addr_0x2005160+0x8)
	mov	r1,0x3
	strb	r1,[r0,0x2]
	strb	r1,[r0,0x3]
	strb	r1,[r0,0x4]
	strb	r1,[r0,(0x2+0x14)]
	strb	r1,[r0,(0x3+0x14)]
	strb	r1,[r0,(0x4+0x14)]

	pop	r15


.align 2
battle_prepareStepHighlightingForOtherSide_col1:
	push	r14
	mov	r0,(3)
	bl	@drawCellsForOtherSide
	bl	battle_prepareStepHighlightingForOtherSide
	pop	r15
battle_prepareStepHighlightingForOtherSide_col2:
	push	r14
	mov	r0,(4)
	bl	@drawCellsForOtherSide
	bl	battle_prepareStepHighlightingForOtherSide
	pop	r15
battle_prepareStepHighlightingForOtherSide_col3:
	push	r14
	mov	r0,(5)
	bl	@drawCellsForOtherSide
	bl	battle_prepareStepHighlightingForOtherSide
	pop	r15

battle_prepareStepHighlightingForOtherSide:
	push	r14

	// Fix where chip icons are written...
	bl	@getOtherSide
	mov	r1,0x18
	mul	r0,r1			// side*0x18
	ldr	r1,=addr_0x2004848
	strh	r0,[r1,0x2]		// chip tile idx
	ldrh	r0,[r1,0xA]		// flags
	mov	r2,0x1		// clear reset flag
	bic	r0,r2
	strh	r0,[r1,0xA]		// flags

	bl	@getProgramDeckForOtherSide
	pop	r15


.align 2
battle_programDeckDraw:
	mov	r0,r2
	mov	r2,(14)
	mov	r3,(10)
	ldr	r6,=addr_0x80062B4|1	// draw tilemap on foreground
	bl	bx_r6

	// Check matching side
	bl	battle_getMySide
	ldr	r1,[sp,0xC]		// side
	cmp	r0,r1
	bne	@@end

	// Check custom screen mode
	ldr	r0,=addr_0x2005160
	ldrb	r1,[r0,0x1]
	ldrb	r2,[r0,0x2]
	ldrb	r3,[r0,0x3]
	ldrb	r0,[r0]		// mode
	cmp	r0,0x1
	bne	@@end

	// Draw OK button
	ldr	r0,=tilemap_programDeck_ok_unpressed

	push	r0-r3
	bl	@getLastColInPath
	cmp	r0,(5)
	pop	r0-r3
	bne	@@disabled

@@checkPressed:
	// Check if OK button should be pressed
	cmp	r1,0x1
	beq	@@disabled
	cmp	r1,0x2
	bne	@@draw
	cmp	r2,0x0
	bne	@@draw
	cmp	r3,0x3		// state 3
	bne	@@draw

	ldr	r0,=tilemap_programDeck_ok_pressed
	b	@@draw

@@disabled:
	ldr	r0,=tilemap_programDeck_ok_disabled

@@draw:
	bl	@drawButton

	// Load extra palette
	ldr	r0,=palette_programDeck_buttons
	mov	r1,(9)		// palette number
	ldr	r2,=addr_0x8007BEC|1	// load palette
	bl	bx_r2

@@end:
	ldr	r0,=addr_0x8008926|1
	bx	r0


.align 2
@drawButton:
	// r0 = tilemap
	push	r7,r14
	sub	sp,0xC
	mov	r7,r0

	bl	battle_getMySide
	cmp	r0,0x0
	beq	@@setTilemap
	add	r7,(0x2*(4*2))	// right version

@@setTilemap:
	str	r7,[sp,0x8]

	bl	@getProgramDeckForMySide
	mov	r7,r0

	ldr	r0,=0x13D		// base tile
	str	r0,[sp]
	mov	r0,0x9		// palette
	str	r0,[sp,0x4]

	ldrb	r0,[r7,0x0]		// x base
	ldrb	r1,[r7,0x1]		// y base
	add	r0,(5)		// x offset
	add	r1,(8)		// y offset
	mov	r2,(4)		// width
	mov	r3,(2)		// height
	lsl	r0,r0,0x18
	asr	r0,r0,0x18
	lsl	r1,r1,0x18
	asr	r1,r1,0x18
	ldr	r7,=addr_0x80062B4|1	// draw tilemap on foreground
	bl	bx_r7

	add	sp,0xC
	pop	r7,r15


.align 2
@removeLastChip:
	push	r7,r14

	bl	battle_getMySide
	mov	r7,r0

	bl	@getLastColInPath
	cmp	r0,0x0
	beq	@@end

	// Remove chip
	ldr	r1,=(addr_0x200B810+0x140)
	lsl	r2,r7,0x3		// side*0x8
	add	r1,r1,r2
	ldrb	r3,[r1,r0]		// get prev chip index
	cmp	r3,0x0
	beq	@@end

	mov	r2,0x0
	strb	r2,[r1,r0]		// clear chip index

	ldr	r1,=(addr_0x200B810+0x150)
	lsl	r0,r0,0x2
	mov	r2,0x1C
	mul	r2,r7			// side*0x1C
	add	r1,r1,r2
	mov	r2,0x0
	str	r2,[r1,r0]		// clear chip pointer

	// Move cursor to removed chip
	mov	r0,r3
	bl	@setCursor

@@playSFX:
	mov	r0,0x68
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

	bl	@updatePath

@@end:
	pop	r7,r15


.align 2
@getLastColInPath:
	push	r14

	bl	battle_getMySide
	lsl	r0,r0,0x3		// side*0x8

	ldr	r2,=(addr_0x200B810+0x140)
	add	r2,r2,r0
	mov	r0,(5)

@@loop:
	cmp	r0,(3)
	blt	@@none

	ldrb	r1,[r2,r0]		// chip idx
	cmp	r1,0x0
	bne	@@end			// exit if found a chip

@@next:
	sub	r0,0x1
	b	@@loop

@@none:
	mov	r0,0x0
@@end:
	pop	r15			// return col idx


.align 2
@selectChip:
	// r5 = state data
	push	r7,r14

	bl	battle_getMySide
	mov	r7,r0

	// Check if chip is in valid column
	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]
	cmp	r0,(3)
	blt	@@error
	cmp	r0,(5)
	bgt	@@error

	ldrb	r0,[r5,0x6]		// chip index
	bl	@checkHaveLeftPathToChip
	cmp	r0,0x0
	beq	@@error

	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]
	ldrb	r1,[r5,0x6]		// chip index

	// Set index
	ldr	r2,=(addr_0x200B810+0x140)
	lsl	r3,r7,0x3		// side*0x8
	add	r2,r2,r3
	strb	r1,[r2,r0]

	// Set chip pointer
	mov	r2,0xC
	mul	r1,r2
	ldr	r2,=(addr_0x200B810+0x20)
	mov	r3,0x90
	mul	r3,r7			// side*0x90
	add	r2,r2,r3
	add	r1,r2,r1		// chip pointer
	lsl	r0,r0,0x2
	ldr	r2,=(addr_0x200B810+0x150)
	mov	r3,0x1C
	mul	r3,r7			// side*0x1C
	add	r2,r2,r3
	str	r1,[r2,r0]

	// Play SFX
	mov	r0,0x72
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

	bl	@removeDisconnectedChipsToRight

	bl	@updatePath

	// Go to next chip already in path
	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]
	add	r0,0x1
	cmp	r0,(5)
	bgt	@@gotoOK

	ldr	r1,=(addr_0x200B810+0x140)
	lsl	r2,r7,0x3		// side*0x8
	add	r1,r1,r2
	ldrb	r0,[r1,r0]
	cmp	r0,0x0
	bne	@@setCursor

@@gotoNextChipMain:
	// Go to next chip (main target)
	bl	@getItemData
	ldrb	r0,[r0,@menuData_targetRight]
	cmp	r0,0xFF
	beq	@@end
	b	@@setCursor

@@gotoOK:
	ldr	r0,=tilemap_programDeck_ok_unpressed
	bl	@drawButton

	mov	r0,0x0C
//	b	@@setCursor

@@setCursor:
	bl	@setCursor
	b	@@end

@@error:
	mov	r0,0x6C
	ldr	r1,=addr_0x804A378|1
	bl	bx_r1

@@end:
	pop	r7,r15


	.pool


.align 2
@updatePath:
	push	r7,r14
	sub	sp,0x8

	// Get new path masks
	bl	battle_getMySide
	str	r0,[sp]
	str	r0,[sp,0x4]		// paths
	mov	r0,sp
	add	r1,r0,0x4
	add	r2,r0,0x5
	add	r3,r0,0x6
	ldr	r0,=addr_0x200B810
	ldr	r7,=addr_0x8034B4C|1
	bl	bx_r7

	bl	@getProgramDeckForMySide
	mov	r7,r0

	// Set new path
	ldr	r0,[sp,0x4]
	lsr	r1,r0,0x8
	lsr	r2,r0,0x10
	orr	r0,r1
	orr	r0,r2
	strb	r0,[r7,0x1D]	// path

	// Set path highlighting
	bl	battle_getMySide
	lsl	r0,r0,0x3		// side*0x8
	ldr	r1,=(addr_0x200B810+0x140)
	add	r0,r1,r0
	mov	r1,0x0

@@checkCol1:
	ldrb	r2,[r0,(3)]
	cmp	r2,0x0
	beq	@@checkCol2
	add	r1,0x1
@@checkCol2:
	ldrb	r2,[r0,(4)]
	cmp	r2,0x0
	beq	@@checkCol3
	add	r1,0x2
@@checkCol3:
	ldrb	r2,[r0,(5)]
	cmp	r2,0x0
	beq	@@setHighlight
	add	r1,0x4

@@setHighlight:
	strb	r1,[r7,0x1E]	// highlighted cols

	// Set path refresh
	ldrb	r1,[r7,0x1F]	// flags
	mov	r0,0x1
	orr	r1,r0
	strb	r1,[r7,0x1F]	// flags

	// Fix where chip icons are written...
	bl	battle_getMySide
	mov	r1,0x18
	mul	r0,r1			// side*0x18
	ldr	r1,=addr_0x2004848
	strh	r0,[r1,0x2]		// chip tile idx
	ldrh	r0,[r1,0xA]		// flags
	mov	r2,0x1		// clear reset flag
	bic	r0,r2
	strh	r0,[r1,0xA]		// flags

	// Update program icons at the top
	bl	battle_getMySide
	mov	r7,r0

	ldr	r0,=addr_0x200B810
	mov	r1,r7
	ldr	r2,=addr_0x8034C1C|1
	bl	bx_r2

	// Erase empty columns
	bl	@getLastColInPath
	ldr	r1,=(addr_0x2005160+0x8)
	mov	r2,0x14
	mul	r2,r7			// side*0x14
	add	r1,r1,r2
	mov	r2,0x3		// empty cell

@@eraseCol1:
	cmp	r0,(2)
	bgt	@@eraseCol2
	strb	r2,[r1,0x2]
@@eraseCol2:
	cmp	r0,(3)
	bgt	@@eraseCol3
	strb	r2,[r1,0x3]
@@eraseCol3:
	cmp	r0,(4)
	bgt	@@end
	strb	r2,[r1,0x4]

@@end:
	add	sp,0x8
	pop	r7,r15


.align 2
@checkHaveLeftPathToChip:
	push	r6-r7,r14
	mov	r7,r0			// desired chip

	bl	battle_getMySide
	mov	r6,r0

	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]

@@loop:
	// check in valid column except first
	cmp	r0,(3)
	ble	@@isConnected
	cmp	r0,(5)
	bgt	@@isConnected

	ldr	r2,=(addr_0x200B810+0x140)
	lsl	r1,r6,0x3		// side*0x8
	add	r2,r2,r1
	add	r2,r2,r0
	sub	r2,0x1
	ldrb	r1,[r2]		// chip idx in prev column
	cmp	r7,0x0
	beq	@@loadThisChip
	mov	r2,r7			// use desired chip idx
	mov	r7,0x0
	b	@@checkEmpty

@@loadThisChip:
	ldrb	r2,[r2,0x1]		// chip idx in this column

@@checkEmpty:
	cmp	r1,0x0		// if prev chip empty, not connected
	beq	@@notConnected

	mov	r3,@menuData_sizeof
	mul	r1,r3
	add	r3,=@menuData
	add	r1,r3,r1		// menu data for chip in prev column

@@checkTarget1:
	ldrb	r3,[r1,@menuData_targetRight]
	cmp	r3,0xFF
	beq	@@checkTarget2
	cmp	r2,r3
	beq	@@prevCol

@@checkTarget2:
	ldrb	r3,[r1,@menuData_otherRight]
	cmp	r3,0xFF
	beq	@@notConnected
	cmp	r2,r3
	bne	@@notConnected

@@prevCol:
	sub	r0,(1)
	b	@@loop

@@notConnected:
	mov	r0,0x0
	b	@@end

@@isConnected:
	mov	r0,0x1
//	b	@@end

@@end:
	pop	r6-r7,r15


.align 2
@removeDisconnectedChipsToRight:
	push	r7,r14

	bl	battle_getMySide
	mov	r7,r0

	bl	@getItemData
	ldrb	r0,[r0,@menuData_queueIdx]

@@loop:
	// check in valid column except last
	cmp	r0,(2)
	blt	@@end
	cmp	r0,(5)
	bge	@@end

	ldr	r2,=(addr_0x200B810+0x140)
	lsl	r1,r7,0x3		// side*0x8
	add	r2,r2,r1
	add	r2,r2,r0
	ldrb	r1,[r2]		// chip idx in this column
	ldrb	r2,[r2,0x1]		// chip idx in next column

	cmp	r1,0x0		// if this chip empty, not connected
	beq	@@notConnected

	mov	r3,@menuData_sizeof
	mul	r1,r3
	add	r3,=@menuData
	add	r1,r3,r1		// menu data for chip in this column

@@checkTarget1:
	ldrb	r3,[r1,@menuData_targetRight]
	cmp	r3,0xFF
	beq	@@checkTarget2
	cmp	r2,r3
	beq	@@nextCol

@@checkTarget2:
	ldrb	r3,[r1,@menuData_otherRight]
	cmp	r3,0xFF
	beq	@@notConnected
	cmp	r2,r3
	beq	@@nextCol

@@notConnected:
	// Remove chip in next column
	add	r3,r0,(1)
	ldr	r2,=(addr_0x200B810+0x140)
	lsl	r1,r7,0x3		// side*0x8
	add	r2,r2,r1
	mov	r1,0x0
	strb	r1,[r2,r3]		// index
	ldr	r2,=(addr_0x200B810+0x150)
	mov	r1,0x1C
	mul	r1,r7			// side*0x1C
	add	r2,r2,r1
	lsl	r3,r3,0x2
	mov	r1,0x0
	str	r1,[r2,r3]

@@nextCol:
	add	r0,(1)
	b	@@loop

@@end:
	pop	r7,r15


.align 2
@getItemData:
	// r5 = state data
	ldrb	r0,[r5,0x6]		// cursor position
	mov	r1,@menuData_sizeof
	mul	r0,r1
	add	r1,=@menuData
	add	r0,r1,r0
	bx	r14


.align 2
battle_getChipAtCursor:
	// r0 = cursor position
	push	r7,r14
	mov	r7,r0

	bl	@getProgramDeckForMySide

	cmp	r7,(12)		// OK button
	beq	@@ok
	cmp	r7,(11)		// normal chip
	bgt	@@none

	lsl	r1,r7,0x1
	add	r1,0x4
	ldrh	r0,[r0,r1]		// chip ID

	cmp	r0,(0xC7)		// deleted
	bne	@@end
	mov	r0,(0xC4)		// empty

	b	@@end

@@ok:
	mov	r0,0xC6
	b	@@end

@@none:
	mov	r0,0x0
//	b	@@end

@@end:
	pop	r7,r15


.align 2
@setCursor:
	// r5 = state data
	cmp	r0,0xFF
	beq	@@end

	strb	r0,[r5,0x6]

@@end:
	bx	r14


.align 2
@updateCursorPos:
	push	r6-r7,r14

	bl	battle_getMySide
	mov	r7,r0

	bl	@getProgramDeckForMySide
	mov	r6,r0

	bl	@getItemData

	// Update cursor x
	ldrb	r1,[r6,0x0]		// base x

	// Add for chip
	cmp	r7,0x0
	bne	@@getRightX
@@getLeftX:
	ldrb	r2,[r0,@menuData_cursorLeftX]
	b	@@addX
@@getRightX:
	ldrb	r2,[r0,@menuData_cursorRightX]
//	b	@@addX
@@addX:
	add	r1,r1,r2

	// Check screen size
	ldr	r2,=(addr_0x2003670+0x11AE)
	ldrb	r2,[r2]
	lsr	r2,r2,0x3		// test 0x4 (screen size)
	bcs	@@setCursorX
	sub	r1,(1)

@@setCursorX:
	lsl	r1,r1,0x3		// tile x to pixel x
	ldr	r2,=addr_0x2004CE0
	strh	r1,[r2,0x28]

	// Update cursor y
	ldrb	r1,[r6,0x1]		// base y

	// Add for chip
	cmp	r7,0x0
	bne	@@getRightY
@@getLeftY:
	ldrb	r2,[r0,@menuData_cursorLeftY]
	b	@@addY
@@getRightY:
	ldrb	r2,[r0,@menuData_cursorRightY]
//	b	@@addY
@@addY:
	add	r1,r1,r2

	// Get y offset
	ldr	r2,=(addr_0x2004830+0x268)
	ldrb	r2,[r2]
	lsl	r2,r2,0x1C
	lsr	r2,r2,0x1D
	sub	r1,r1,r2

	// Check screen size
	ldr	r2,=(addr_0x2003670+0x11AE)
	ldrb	r2,[r2]
	lsr	r2,r2,0x3		// test 0x4 (screen size)
	bcs	@@setCursorY
	sub	r1,(2)

@@setCursorY:
	lsl	r1,r1,0x3		// tile y to pixel y
	ldr	r2,=addr_0x2004CE0
	strh	r1,[r2,0x2A]

	pop	r6-r7,r15


.align 2
@applyPathToSide:
	// r0 = path
	// r1 = side
	push	r5-r7,r14
	mov	r7,r0			// path
	mov	r6,r1			// side

	// Store program deck path
	mov	r0,r1
	bl	@getProgramDeckForSide
	strb	r7,[r0,0x1D]

	// Store chips for path
	mov	r5,0x0		// index
	add	r1,=@paths
	lsl	r2,r7,0x2		// path*0x4
	add	r7,r1,r2		// path indices
@@loop:
	// Set chip index
	ldr	r0,=(addr_0x200B810+0x140+0x2)
	lsl	r1,r6,0x3		// side*0x8
	add	r0,r0,r1
	ldrb	r1,[r7,r5]		// chip index
	strb	r1,[r0,r5]		// chip index

	// Set chip pointer
	mov	r0,0xC
	mul	r0,r1			// chip*0xC
	ldr	r1,=(addr_0x200B810+0x20)
	mov	r2,0x90
	mul	r2,r6			// side*0x90
	add	r1,r1,r2
	add	r0,r1,r0		// chip pointer

	ldr	r1,=(addr_0x200B810+0x150+0x8)
	mov	r2,0x1C
	mul	r2,r6			// side*0x1C
	add	r1,r1,r2
	lsl	r2,r5,0x2		// index*0x4
	str	r0,[r1,r2]

	// Next chip
	add	r5,0x1
	cmp	r5,0x4
	bcc	@@loop

	pop	r5-r7,r15


.align 2
battle_getMySide:
	push	r14
	ldr	r0,=addr_0x804A3F0|1	// get side
	bl	bx_r0
	pop	r15

//	ldr	r0,=addr_0x200B810
//	ldrh	r0,[r0,0x14]
//	mov	r1,(0x1000 >> 0xC)
//	lsl	r1,r1,0xC
//	cmp	r0,r1
//	bne	@@right
//@@left:
//	mov	r0,0x0
//	b	@@end
//@@right:
//	mov	r0,0x1
////	b	@@end
//@@end:
//	bx	r14

.align 2
@getOtherSide:
	push	r14
	bl	battle_getMySide
	mov	r1,0x1
	eor	r0,r1
	pop	r15

.align 2
@getProgramDeckForSide:
	ldr	r1,=addr_0x2004CA0
	lsl	r0,r0,0x5		// side * 0x20
	add	r0,r1,r0
	bx	r14

.align 2
@getProgramDeckForMySide:
	push	r14
	bl	battle_getMySide
	bl	@getProgramDeckForSide
	pop	r15

.align 2
@getProgramDeckForOtherSide:
	push	r14
	bl	@getOtherSide
	bl	@getProgramDeckForSide
	pop	r15


.align 2
@drawCellsForOtherSide:
	push	r6-r7,r14
	mov	r6,r0			// r0 = last column

	// Update program icons at the top
	bl	@getOtherSide
	mov	r7,r0

	ldr	r0,=addr_0x200B810
	mov	r1,r7
	ldr	r2,=addr_0x8034C1C|1
	bl	bx_r2

	// Erase empty columns
	ldr	r1,=(addr_0x2005160+0x8)
	mov	r2,0x14
	mul	r2,r7			// side*0x14
	add	r1,r1,r2
	mov	r2,0x3		// empty cell

@@eraseCol1:
	cmp	r6,(2)
	bgt	@@eraseCol2
	strb	r2,[r1,0x2]
@@eraseCol2:
	cmp	r6,(3)
	bgt	@@eraseCol3
	strb	r2,[r1,0x3]
@@eraseCol3:
	cmp	r6,(4)
	bgt	@@end
	strb	r2,[r1,0x4]

@@end:
	pop	r6-r7,r15


	.pool


.align 4
@menuData:
.definelabel @menuData_queueIdx,		0x0
.definelabel @menuData_cursorLeftX,		0x1
.definelabel @menuData_cursorLeftY,		0x2
.definelabel @menuData_cursorRightX,	0x3
.definelabel @menuData_cursorRightY,	0x4
.definelabel @menuData_targetRight,		0x5	// chip index
.definelabel @menuData_targetLeft,		0x6	// chip index
.definelabel @menuData_targetUp,		0x7	// chip index
.definelabel @menuData_targetDown,		0x8	// chip index
.definelabel @menuData_otherRight, 		0x9	// other chip to the right
.definelabel @menuData_otherSideUp,		0xA	// right side up target
.definelabel @menuData_otherSideDown,	0xB	// right side down target
.definelabel @menuData_sizeof,		0xC
	// Chip 0 (navi chip)
	.db	(2)
	.db	(3), (5), (11), (5)
	.db	0x01, 0xFF, 0x0A, 0x0B
	.db	0x02, 0xFF, 0xFF
	// Chip 1 (col 1 row 1)
	.db	(3)
	.db	(6), (4), (8), (4)
	.db	0x03, 0x00, 0x0C, 0x02
	.db	0x04, 0xFF, 0xFF
	// Chip 2 (col 1 row 2)
	.db	(3)
	.db	(6), (6), (8), (6)
	.db	0x04, 0x00, 0x01, 0x0C
	.db	0x05, 0xFF, 0xFF
	// Chip 3 (col 2 row 1)
	.db	(4)
	.db	(9), (3), (5), (3)
	.db	0x06, 0x01, 0x0C, 0x04
	.db	0x07, 0xFF, 0xFF
	// Chip 4 (col 2 row 2)
	.db	(4)
	.db	(9), (5), (5), (5)
	.db	0x07, 0x02, 0x03, 0x05
	.db	0x08, 0xFF, 0xFF
	// Chip 5 (col 2 row 3)
	.db	(4)
	.db	(9), (7), (5), (7)
	.db	0x08, 0x02, 0x04, 0x0C
	.db	0x09, 0xFF, 0xFF
	// Chip 6 (col 3 row 1)
	.db	(5)
	.db	(12), (2), (2), (2)
	.db	0xFF, 0x03, 0x0C, 0x07
	.db	0xFF, 0xFF, 0xFF
	// Chip 7 (col 3 row 2)
	.db	(5)
	.db	(12), (4), (2), (4)
	.db	0xFF, 0x04, 0x06, 0x08
	.db	0xFF, 0xFF, 0xFF
	// Chip 8 (col 3 row 3)
	.db	(5)
	.db	(12), (6), (2), (6)
	.db	0xFF, 0x05, 0x07, 0x09
	.db	0xFF, 0xFF, 0xFF
	// Chip 9 (col 3 row 4)
	.db	(5)
	.db	(12), (8), (2), (8)
	.db	0xFF, 0x05, 0x08, 0x0C
	.db	0xFF, 0xFF, 0xFF
	// Chip 10 (slot R)
	.db	(1)
	.db	(3), (2), (11), (2)
	.db	0x01, 0xFF, 0x0C, 0x00
	.db	0xFF, 0xFF, 0xFF
	// Chip 11 (slot L)
	.db	(1)
	.db	(3), (8), (11), (8)
	.db	0x02, 0xFF, 0x00, 0x0C
	.db	0xFF, 0xFF, 0xFF
	// Chip 12 (OK button col 1)
	.db	(0)	// OK button
	.db	(6), (9), (6), (9)
	.db	0x09, 0x0B, 0x02, 0x01
	.db	0xFF, 0x05, 0x03


.align 4
@paths:
	.db	(0), (1), (3), (6)	// navi, up, up, up
	.db	(0), (2), (4), (7)	// navi, down, up, up
	.db	(0), (1), (4), (7)	// navi, up, down, up
	.db	(0), (2), (5), (8)	// navi, down, down, up
	.db	(0), (1), (3), (7)	// navi, up, up, down
	.db	(0), (2), (4), (8)	// navi, down, up, down
	.db	(0), (1), (4), (8)	// navi, up, down, down
	.db	(0), (2), (5), (9)	// navi, down, down, down
