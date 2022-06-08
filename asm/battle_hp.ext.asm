.align 2
hp_baseTile:
	push	r14
	ldr	r3,=addr_0x2000800	// end of BG0 tilemap
	cmp	r0,r3
	bge	@@end
@@adjust:
	add	r1,((0x1F9-0xD2)-0xFF)
	add	r1,0xFF
@@end:
	mov	r2,0x0
	ldr	r3,=addr_0x8008BB8|1
	bl	bx_r3
	pop	r15
