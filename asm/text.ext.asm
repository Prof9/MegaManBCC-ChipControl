.macro .text,id,string
	id:
	.strn	string
	.dh	(0x8000 | strlen(string))
.endmacro


.ifdef VER_EN

.align 2
.text	en_text_tutorial1_line1,	"Chips are drawn"
.text	en_text_tutorial1_line2,	"from your deck."
.text	en_text_tutorial1_line3,	""

.align 2
.text	en_text_tutorial2_line1,	"Select 3 chips"
.text	en_text_tutorial2_line2,	"in a row to use"
.text	en_text_tutorial2_line3,	"during your turn."
.text	en_text_tutorial2_line4,	"You can only"
.text	en_text_tutorial2_line5,	"select chips that"
.text	en_text_tutorial2_line6,	"are connected."
.text	en_text_tutorial2_line7,	"Press the L or R"
.text	en_text_tutorial2_line8,	"Buttons to view"
.text	en_text_tutorial2_line9,	"chip data."
.text	en_text_tutorial2_line10,	"If you want to"
.text	en_text_tutorial2_line11,	"hide the chip"
.text	en_text_tutorial2_line12,	"and see your"
.text	en_text_tutorial2_line13,	"opponent's deck,"
.text	en_text_tutorial2_line14,	"press Select."

.align 4
en_text_tutorial2:
	.dw	en_text_tutorial2_line1
	.dw	en_text_tutorial2_line2
	.dw	en_text_tutorial2_line3
	.dw	en_text_tutorial2_line4
	.dw	en_text_tutorial2_line5
	.dw	en_text_tutorial2_line6
	.dw	en_text_tutorial2_line7
	.dw	en_text_tutorial2_line8
	.dw	en_text_tutorial2_line9
	.dw	en_text_tutorial2_line10
	.dw	en_text_tutorial2_line11
	.dw	en_text_tutorial2_line12
	.dw	en_text_tutorial2_line13
	.dw	en_text_tutorial2_line14
	.dw	0x0

.endif

.ifdef VER_JP

.align 2
.text	jp_text_tutorial1_line1,	"バトルでは プログラムデッキから"
.text	jp_text_tutorial1_line2,	"チップを せんたくして"
.text	jp_text_tutorial1_line3,	"ナビに シジをあたえます"

.align 2
.text	jp_text_tutorial2_line1,	"ターンで しようしたい"
.text	jp_text_tutorial2_line2,	"チップを 各列から 1まいずつ"
.text	jp_text_tutorial2_line3,	"せんたく します"
.text	jp_text_tutorial2_line4,	"たがいに せつぞく"
.text	jp_text_tutorial2_line5,	"されている チップ のみ"
.text	jp_text_tutorial2_line6,	"せんたく できます"
.text	jp_text_tutorial2_line7,	"L・Rボタンを おすと"
.text	jp_text_tutorial2_line8,	"チップのデータを"
.text	jp_text_tutorial2_line9,	"ひょうじ できます"
.text	jp_text_tutorial2_line10,	"セレクトボタンを おすと"
.text	jp_text_tutorial2_line11,	"チップのデータが ひひょうじに"
.text	jp_text_tutorial2_line12,	"なって あいての"
.text	jp_text_tutorial2_line13,	"プログラムデッキが"
.text	jp_text_tutorial2_line14,	"ひょうじ されます"

.align 4
jp_text_tutorial2:
	.dw	jp_text_tutorial2_line1
	.dw	jp_text_tutorial2_line2
	.dw	jp_text_tutorial2_line3
	.dw	jp_text_tutorial2_line4
	.dw	jp_text_tutorial2_line5
	.dw	jp_text_tutorial2_line6
	.dw	jp_text_tutorial2_line7
	.dw	jp_text_tutorial2_line8
	.dw	jp_text_tutorial2_line9
	.dw	jp_text_tutorial2_line10
	.dw	jp_text_tutorial2_line11
	.dw	jp_text_tutorial2_line12
	.dw	jp_text_tutorial2_line13
	.dw	jp_text_tutorial2_line14
	.dw	0x0

.endif
