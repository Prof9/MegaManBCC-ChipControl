.align 2
battle_chipPanelAreaGrab:
	// r1 = chip ID
	ldrb	r0,[r2]
	cmp	r1,0xD5	// PanelGrab
	bne	@@areaGrab
@@panelGrab:
	sub	r0,(10)	// +10 -> -10
	b	@@checkMin
@@areaGrab:
	sub	r0,(30)	// +20 -> -30
//	b	@@checkMin
@@checkMin:
	bpl	@@end
	mov	r0,(0)
@@end:
	strb	r0,[r2]
	bx	r14


	.pool
