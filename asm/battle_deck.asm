.org addr_0x800891C	// Hook program deck drawing function
.area 0xA,0x00
	ldr	r0,=battle_programDeckDraw|1
	bx	r0
	.pool
.endarea


.org addr_0x800EE50	// Disable B = autoplay during program deck
.area 0x20,0x00
	push	r14

	ldr	r0,=battle_toggleAutoplay|1
	bl	addr_0x804DCCC	// blx r0

	pop	r15

	.pool
.endarea


.org addr_0x800F088	// Hook pre-program deck function
	.dw	battle_programDeckHandler_state2_0

.org addr_0x800F108	// Disable step highlighting for our program deck
.area 0x18,0x00
	ldr	r0,=battle_prepareStepHighlightingForOtherSide_col1|1
	bl	addr_0x804DCCC	// blx r0
	b	@@next
	.pool
@@next:
	mov	r2,0x1
	mov	r3,0x1
	strb	r3,[r0,0x1E]
	ldrb	r1,[r0,0x1F]
	orr	r1,r2
	strb	r1,[r0,0x1F]
.endarea
.org addr_0x800F13E
.area 0x18,0x00
	ldr	r0,=battle_prepareStepHighlightingForOtherSide_col2|1
	bl	addr_0x804DCCC	// blx r0
	mov	r2,0x1
	b	@@next
	.pool			// 4 byte aligned
@@next:
	mov	r3,0x3
	strb	r3,[r0,0x1E]
	ldrb	r1,[r0,0x1F]
	orr	r1,r2
	strb	r1,[r0,0x1F]
.endarea
.org addr_0x800F174
.area 0x18,0x00
	ldr	r0,=battle_prepareStepHighlightingForOtherSide_col3|1
	bl	addr_0x804DCCC	// blx r0
	b	@@next
	.pool
@@next:
	mov	r2,0x1
	mov	r3,0x7
	strb	r3,[r0,0x1E]
	ldrb	r1,[r0,0x1F]
	orr	r1,r2
	strb	r1,[r0,0x1F]
.endarea


.org addr_0x8030084	// Clear program cells at start of battle
.area 0x10,0x00
	ldr	r0,=battle_clearProgramCells|1
	bl	addr_0x804DCCC	// blx r0
	b	@@end
	.pool
.endarea
@@end:

.org addr_0x8030596	// Clear program cells when program deck opens
.area 0x10,0x00
	ldr	r0,=battle_clearProgramCells|1
	bl	addr_0x804DCCC	// blx r0
	b	@@end
	.pool
.endarea
@@end:
