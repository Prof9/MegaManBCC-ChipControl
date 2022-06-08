.gba
.thumb
.if ROM_IN == ROM_OUT
.open ROM_IN,0x8000000
.else
.open ROM_IN,ROM_OUT,0x8000000
.endif

.ifdef VER_EN

	.table "bcc-utf8.tbl"
	.include "address_en.asm"

.endif
.ifdef VER_JP

	.table "exebcgp-utf8.tbl"
	.include "address_jp.asm"
.endif


.include "asm/battle_chip.asm"
.include "asm/battle_deck.asm"
.include "asm/battle_hp.asm"
.include "asm/battle_reroll.asm"
.include "asm/gfx.asm"
.include "asm/screen.asm"
.include "asm/text.asm"


// FREE SPACE - CODE
//.orga filesize(ROM_IN)
.org addr_0x82350E8
.area addr_0x82C0000-.


.include "asm/common.ext.asm"

.include "asm/battle_chip.ext.asm"
.include "asm/battle_deck.ext.asm"
.include "asm/battle_desc.ext.asm"
.include "asm/battle_hp.ext.asm"
.include "asm/battle_popup.ext.asm"
.include "asm/battle_reroll.ext.asm"
.include "asm/screen.ext.asm"

.align 0x4


.endarea

// FREE SPACE - DATA
.org addr_0x87B3E64


.include "asm/text.ext.asm"
.include "asm/gfx.ext.asm"

.align 0x4


.close
