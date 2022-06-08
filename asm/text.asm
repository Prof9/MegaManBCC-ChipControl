.ifdef VER_EN

.org 0x820F3F4	// Adjust tutorial text
	.dw	en_text_tutorial1_line1
	.dw	en_text_tutorial1_line2
	.dw	en_text_tutorial1_line3

.org 0x820B6F8
	.dw	en_text_tutorial2

.endif


.ifdef VER_JP

.org 0x827252C	// Adjust tutorial text
	.dw	jp_text_tutorial1_line1
	.dw	jp_text_tutorial1_line2
	.dw	jp_text_tutorial1_line3

.org 0x8265478
	.dw	jp_text_tutorial2

.endif