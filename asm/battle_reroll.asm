.org addr_0x800EF66	// Change read from special action buttons
.area 0x1A,0x00
	ldr	r2,[addr_0x800EFB4]	// 0x2002F50

	// Check if we can reroll
	ldrb	r0,[r5,0x7]
	lsr	r0,r0,0x2	// test 0x2
	bcc	@@end

	// Check L+R held
	ldrh	r0,[r2]	// buttons held
	lsl	r0,r0,0x16
	lsr	r0,r0,0x1E
	cmp	r0,0x3	// L+R
	bne	@@end

	// Set auto close program deck
	mov	r0,0x1
	mov	r8,r0

	b	@@end
.endarea
@@end:


.org addr_0x80291EC	// Rewrite choose random chips function
.area 0xC4,0x00
	// r0, sp+00 = action plan
	// r1, r4    = program deck chips
	// r2, r5    = action plan indexes
	// r3        = is reroll
	// r6        = chip index
	// r7        = slot index

	push	r0,r4-r7,r14
	mov	r4,r1
	mov	r5,r2

	// Set static chips
	mov	r1,0x0
	str	r4,[r0,0x8]		// navi chip
	str	r1,[r0]		// chip0
	str	r1,[r0,0x4]		// slot in chip
	str	r1,[r0,0x18]	// chip6
	str	r1,[r5]		// chip0, slot in chip, navi chip, chip1 (overwritten below)

	// Check if simulating
	// If so, always run
	ldr	r0,=addr_0x200B810
	ldrb	r0,[r0,0x6]
	lsr	r0,r0,0x4		// test 0x8
	bcs	@@run

	// Check if multiplayer
	// If so, exit (do not call random at all)
	ldr	r1,=addr_0x200B810
	ldrb	r1,[r1,0x6]		// flags
	lsr	r1,r1,0x5		// test 0x10
	bcs	@@end

	// Get player side
	bl	addr_0x804A3F0		// r0 = my side

	// Infer if we are choosing from left or right...
	ldr	r1,=addr_0x200B950
	sub	r1,r5,r1
	lsr	r1,r1,0x3

	// If choosing for player side, leave chip1 blank and exit
	cmp	r0,r1
	beq	@@end

@@run:
	// Otherwise choose random chips
	mov	r6,0x0
	mov	r7,(3)
@@loop:
	bl	addr_0x80400A8		// random()
	lsl	r2,r0,0x1E
	lsr	r2,r2,0x1E		// [0..3]

	sub	r0,r7,(2)
	add	r6,r6,r0		// top path chip index

	// Get top and bottom HP
	lsl	r0,r6,0x1
	add	r0,r0,r6
	lsl	r0,r0,0x2		// chip index * 0xC
	add	r1,r4,r0		// top chip data
	ldrh	r0,[r1,0x2]		// top chip HP
	ldrh	r1,[r1,0x2+0xC]	// bottom chip HP

	// Choose threshold
	mov	r3,0x2		// 50/50 threshold...
	cmp	r0,r1
	beq	@@choose		// ...if both zero or both nonzero equal
	mov	r3,0x1		// 25/75 threshold...
	cmp	r0,0x0
	beq	@@choose		// ...if top zero, bottom nonzero
	mov	r3,0x3		// 75/25 threshold
	cmp	r1,0x0
	beq	@@choose		// bottom nonzero, top zero
	mov	r3,0x2		// 50/50 threshold if both nonzero not equal

@@choose:
	mov	r0,0x0		// top chip
	cmp	r2,r3
	blt	@@store
	mov	r0,0x1		// bottom chip

@@store:
	// Set chip index
	add	r6,r6,r0		// next chip index
	strb	r6,[r5,r7]		// set chip index

	// Set chip data pointer
	lsl	r0,r6,0x1
	add	r0,r0,r6
	lsl	r0,r0,0x2		// chip index * 0xC
	add	r0,r4,r0		// chip data
	ldr	r1,[sp]		// action plan
	lsl	r2,r7,0x2		// slot index * 0x4
	str	r0,[r1,r2]		// set chip data

	// Go to next slot
	add	r7,(1)
	cmp	r7,(5)
	ble	@@loop

@@end:
	pop	r0,r4-r7,r15

	.pool
.endarea


.org addr_0x8030566	// Change L+R reroll flag
.area 0x8,0x00
	ldr	r0,=battle_setCanReroll|1
	bl	addr_0x804DCCC	// blx r0
.endarea
.org addr_0x803056E
	add	r1,r4,0x1
.org addr_0x8030588
.area 0x8,0x00
	ldr	r0,=battle_setCanReroll|1
	bl	addr_0x804DCCC	// blx r0
.endarea
.org addr_0x8030614
.area 0x4,0x00
	.pool
.endarea


.org addr_0x8034D18	// Disable L+R reroll handler
.area 0xA0,0x00
	// r0 = battle struct
	// r1 = [r0+0x6] & 0x88

	// Check ???
	ldrb	r1,[r0,0x6]
	mov	r2,0x88
	and	r1,r2
	bne	@@end

	// Check state: after choosing chips
	ldr	r2,=addr_0x2005160
	ldrb	r3,[r2,0x1]
	cmp	r3,0x2
	blt	@@end
//	ldrb	r3,[r2,0x2]
//	cmp	r3,0x0
//	blt	@@end
	ldrb	r3,[r2,0x3]
	cmp	r3,0x4
	blt	@@end

	// Check L+R held
	ldr	r2,=addr_0x2002F50
	ldrh	r2,[r2]	// buttons held
	lsl	r2,r2,0x16
	lsr	r2,r2,0x1E
	cmp	r2,0x3	// L+R
	bne	@@end

@@checkLeft:
	mov	r3,(0x1000 >> 0x5)
	lsl	r3,r3,0x5

	// Check if we are right side
	ldrh	r2,[r0,0x16]
	cmp	r2,r3
	beq	@@checkGaugeRight

	// Check if we are left side
	ldrh	r2,[r0,0x14]
	cmp	r2,r3
	bne	@@end

@@checkGaugeLeft:
	add	r0,0xFF
	add	r0,(0x18A-0xFF)
	ldrb	r2,[r0,(0x18A-0x18A)]	// left custom gauge
	cmp	r2,(49)
	bls	@@end

	// Queue reroll prompt
	ldrb	r2,[r0,(0x190-0x18A)]
	mov	r3,0xF
	bic	r2,r3
	add	r2,0x4
	strb	r2,[r0,(0x190-0x18A)]

	ldr	r2,=addr_0x2005160
	strb	r1,[r2,(0x8+0xE)]

	b	@@end

@@checkGaugeRight:
	add	r0,0xFF
	add	r0,(0x18A-0xFF)
	ldrb	r2,[r0,(0x18B-0x18A)]	// left custom gauge
	cmp	r2,(49)
	bls	@@end

	// Queue reroll prompt
	ldrb	r2,[r0,(0x190-0x18A)]
	mov	r3,0xF0
	bic	r2,r3
	add	r2,0x40
	strb	r2,[r0,(0x190-0x18A)]

	ldr	r2,=addr_0x2005160
	add	r2,0x14
	mov	r1,0x0
	strb	r1,[r2,(0x8+0xE)]

//	b	@@end

@@end:
	bx	r14

	.pool
.endarea
