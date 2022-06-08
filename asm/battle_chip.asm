// Fix PanlGrab/AreaGrab effect glitch
.org addr_0x802C248	// enemy Navi dodge rate +10/+20 -> -10/-30
.area 0xC,0x00
	ldr	r0,=battle_chipPanelAreaGrab|1
	bl	addr_0x804DCCC	// blx r0
	b	@@end
	.pool
.endarea
@@end:


// Fix Wind effect glitch
.org addr_0x802C47A	// Sword accuracy +10 -> -10
.area 0xE,0x00
	ldrb	r0,[r1,0x1]		// chip accuracy
	cmp	r0,(10)
	bls	@@setMin
	sub	r0,(10)
	b	@@end
@@setMin:
	mov	r0,(0)
@@end:
	strb	r0,[r1,0x1]		// chip accuracy
.endarea

.org addr_0x802C498	// Dodge rate -10 -> +10 (left)
.area 0x10,0x00
	ldrb	r0,[r7,0x8]		// left Navi dodge rate
	cmp	r0,(189)
	bhi	@@setMax
	add	r0,(10)
	strb	r0,[r7,0x8]		// left Navi dodge rate
	b	@@end
@@setMax:
	mov	r0,(200)
	strb	r0,[r7,0x8]		// left Navi dodge rate
@@end:
.endarea

.org addr_0x802C4AA	// Dodge rate -10 -> +10 (right)
.area 0xE,0x00
	ldrb	r0,[r7,0x9]		// right Navi dodge rate
	cmp	r0,(189)
	bhi	@@setMax
	add	r0,(10)
	b	@@end
@@setMax:
	mov	r0,(200)
@@end:
	strb	r0,[r7,0x9]		// right Navi dodge rate
.endarea


// Fix Fan effect glitch
.org addr_0x802C574	// Sword accuracy -10 -> +10
.area 0xE,0x00
	ldrb	r0,[r1,0x1]		// chip accuracy
	cmp	r0,(189)
	bhi	@@setMax
	add	r0,(10)
	b	@@end
@@setMax:
	mov	r0,(200)
@@end:
	strb	r0,[r1,0x1]		// chip accuracy
.endarea

.org addr_0x802C592	// Dodge rate +10 -> -10 (left)
.area 0x10,0x00
	ldrb	r0,[r7,0x8]		// left Navi dodge rate
	cmp	r0,(10)
	bls	@@setMin
	sub	r0,(10)
	strb	r0,[r7,0x8]		// left Navi dodge rate
	b	@@end
@@setMin:
	mov	r0,(0)
	strb	r0,[r7,0x8]		// left Navi dodge rate
@@end:
.endarea

.org addr_0x802C5A4	// Dodge rate +10 -> -10 (right)
.area 0xE,0x00
	ldrb	r0,[r7,0x9]		// right Navi dodge rate
	cmp	r0,(10)
	bls	@@setMin
	sub	r0,(10)
	b	@@end
@@setMin:
	mov	r0,(0)
@@end:
	strb	r0,[r7,0x9]		// right Navi dodge rate
.endarea
