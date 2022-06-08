.align 4
tileset_fontEmpty:
	.fill 0x20,0x11
	.fill 0x20,0x99


.align 4
tileset_programDeck:
	.import	TEMP+"/programdeck.img.bin"


.align 2
palette_programDeck_buttons:
	.import TEMP+"/programdeck-buttons.pal.bin"


.align 2
tilemap_programDeck_ok_unpressed:
	.import TEMP+"/programdeck-ok0.map.bin"
	.import TEMP+"/programdeck-ok1.map.bin"


.align 2
tilemap_programDeck_ok_pressed:
	.import TEMP+"/programdeck-ok2.map.bin"
	.import TEMP+"/programdeck-ok3.map.bin"


.align 2
tilemap_programDeck_ok_disabled:
	.import TEMP+"/programdeck-ok4.map.bin"
	.import TEMP+"/programdeck-ok5.map.bin"


.align 2
tilemap_battleChip:
	.import TEMP+"/battlechip.map.bin"


.align 2
tilemap_description:
	.import TEMP+"/description.map.bin"


.align 4
tileset_battleChip:
	.dw	@@tiles-.
	.dw	filesize(TEMP+"/battlechip.img.bin")
	.dh	0x100
	.dh	0x20
	.dw	@@palette-.
	.dw	filesize(TEMP+"/battlechip.pal.bin")
@@tiles:
	.import TEMP+"/battlechip.img.bin"
@@palette:
	.import TEMP+"/battlechip.pal.bin"


.ifdef VER_EN

.align 4
tileset_copyright_us:
	.import TEMP+"/copyright-us.img.bin"

.align 4
tileset_copyright_eu:
	.import TEMP+"/copyright-eu.img.bin"

.endif

.ifdef VER_JP

.align 4
tileset_copyright_jp:
	.import TEMP+"/copyright-jp.img.bin"

.endif
