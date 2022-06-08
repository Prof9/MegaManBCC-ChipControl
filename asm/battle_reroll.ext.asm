.align 2
battle_setCanReroll:
	push	r14

	ldr	r0,=addr_0x2005160
	ldrb	r1,[r0,0x7]
	mov	r2,0x2
	orr	r1,r2
	strb	r1,[r0,0x7]

	pop	r15


	.pool
