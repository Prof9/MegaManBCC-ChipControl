.org addr_0x806AFFC	// Program Deck left tilemap (battle)
.area 0x118,0x00
	.import TEMP+"/programdeck-left.map.bin"
.endarea
.org addr_0x806B114	// Program Deck right tilemap (battle)
.area 0x118,0x00
	.import TEMP+"/programdeck-right.map.bin"
.endarea

.org addr_0x806B22C	// Program Deck paths tilemaps (battle)
.area 0x4*(1+2+3),0x00
	.import TEMP+"/programdeck-path-l0.map.bin"
	.import TEMP+"/programdeck-path-l0.map.bin"
	.import TEMP+"/programdeck-path-l0.map.bin"
	.import TEMP+"/programdeck-path-l0.map.bin"
	.import TEMP+"/programdeck-path-l0.map.bin"
	.import TEMP+"/programdeck-path-l0.map.bin"
.endarea
.org addr_0x806B244
.area 0x4*(1+2+3),0x00
	.import TEMP+"/programdeck-path-l1.map.bin"
	.import TEMP+"/programdeck-path-l1.map.bin"
	.import TEMP+"/programdeck-path-l1.map.bin"
	.import TEMP+"/programdeck-path-l1.map.bin"
	.import TEMP+"/programdeck-path-l1.map.bin"
	.import TEMP+"/programdeck-path-l1.map.bin"
.endarea
.org addr_0x806B25C
.area 0x4*(1+2+3),0x00
	.import TEMP+"/programdeck-path-l2.map.bin"
	.import TEMP+"/programdeck-path-l2.map.bin"
	.import TEMP+"/programdeck-path-l2.map.bin"
	.import TEMP+"/programdeck-path-l2.map.bin"
	.import TEMP+"/programdeck-path-l2.map.bin"
	.import TEMP+"/programdeck-path-l2.map.bin"
.endarea
.org addr_0x806B274
.area 0x4*(1+2+3),0x00
	.import TEMP+"/programdeck-path-r0.map.bin"
	.import TEMP+"/programdeck-path-r0.map.bin"
	.import TEMP+"/programdeck-path-r0.map.bin"
	.import TEMP+"/programdeck-path-r0.map.bin"
	.import TEMP+"/programdeck-path-r0.map.bin"
	.import TEMP+"/programdeck-path-r0.map.bin"
.endarea
.org addr_0x806B28C
.area 0x4*(1+2+3),0x00
	.import TEMP+"/programdeck-path-r1.map.bin"
	.import TEMP+"/programdeck-path-r1.map.bin"
	.import TEMP+"/programdeck-path-r1.map.bin"
	.import TEMP+"/programdeck-path-r1.map.bin"
	.import TEMP+"/programdeck-path-r1.map.bin"
	.import TEMP+"/programdeck-path-r1.map.bin"
.endarea
.org addr_0x806B2A4
.area 0x4*(1+2+3),0x00
	.import TEMP+"/programdeck-path-r2.map.bin"
	.import TEMP+"/programdeck-path-r2.map.bin"
	.import TEMP+"/programdeck-path-r2.map.bin"
	.import TEMP+"/programdeck-path-r2.map.bin"
	.import TEMP+"/programdeck-path-r2.map.bin"
	.import TEMP+"/programdeck-path-r2.map.bin"
.endarea

.org addr_0x806B2BC	// Program Deck palette (battle)
.area 0x20,0x00
	.import TEMP+"/programdeck.pal.bin"
.endarea

.org addr_0x830B3A4	// Program Deck tileset (battle)
	.dw	(tileset_programDeck - .)
	.dw	filesize(TEMP+"/programdeck.img.bin")

.ifdef VER_EN

.org 0x871D738	// Copyright US tilemap
.area 0x4B4,0x00
	.dh	(30), (20)
	.import TEMP+"/copyright-us.map.bin"
.endarea

.org 0x871E520	// Copyright US tileset
	.dw	(tileset_copyright_us - .)
	.dw	filesize(TEMP+"/copyright-us.img.bin")

.org 0x871E030	// Copyright EU tilemap
.area 0x4B4,0x00
	.dh	(30), (20)
	.import TEMP+"/copyright-eu.map.bin"
.endarea

.org 0x872393C	// Copyright US palette
.area 0x20,0x00
	.import TEMP+"/copyright-us.pal.bin"
.endarea

.org 0x871E548	// Copyright EU tileset
	.dw	(tileset_copyright_eu - .)
	.dw	filesize(TEMP+"/copyright-eu.img.bin")

.org 0x87259BC	// Copyright EU palette
.area 0x20,0x00
	.import TEMP+"/copyright-eu.pal.bin"
.endarea

.endif

.ifdef VER_JP

.org 0x8732228	// Copyright JP tilemap
.area 0x4B4,0x00
	.dh	(30), (20)
	.import TEMP+"/copyright-jp.map.bin"
.endarea

.org 0x873765C	// Copyright JP palette
.area 0x20,0x00
	.import TEMP+"/copyright-jp.pal.bin"
.endarea

.org 0x8732BD4	// Copyright JP tileset
	.dw	(tileset_copyright_jp - .)
	.dw	filesize(TEMP+"/copyright-jp.img.bin")

.endif
