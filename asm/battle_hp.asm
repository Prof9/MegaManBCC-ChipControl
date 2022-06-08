.org addr_0x8007908	// Override base tile for HP bar
	ldr	r2,=hp_baseTile|1
	bl	addr_0x804DCD4	// bx r2
.org addr_0x8007932
	ldr	r2,=hp_baseTile|1
	bl	addr_0x804DCD4	// bx r2
.org addr_0x8007958
	ldr	r2,=hp_baseTile|1
	bl	addr_0x804DCD4	// bx r2
.org addr_0x800798A	// clear up space in pool
	mov	r2,(0xB000 >> 0xC)
	lsl	r0,r2,0xC
.org addr_0x8007996
	ldr	r2,=hp_baseTile|1
	bl	addr_0x804DCD4	// bx r2
.org addr_0x80079B2
	ldr	r2,=hp_baseTile|1
	bl	addr_0x804DCD4	// bx r2
.org addr_0x80079E4
	.pool
