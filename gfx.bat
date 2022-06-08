@echo off

"tools\PixelPet.exe" ^
	Import-Bitmap "img\copyright.pal.png" Read-Palettes Convert-Palettes GBA ^
	Import-Bitmap "img\copyright-us.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\copyright-us.map.bin" ^
	Serialize-Tileset Export-Bytes "%_TEMP%\copyright-us.img.bin" ^
	Serialize-Palettes Export-Bytes "%_TEMP%\copyright-us.pal.bin" ^
	|| exit /b 1

"tools\PixelPet.exe" ^
	Import-Bitmap "img\copyright.pal.png" Read-Palettes Convert-Palettes GBA ^
	Import-Bitmap "img\copyright-eu.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\copyright-eu.map.bin" ^
	Serialize-Tileset Export-Bytes "%_TEMP%\copyright-eu.img.bin" ^
	Serialize-Palettes Export-Bytes "%_TEMP%\copyright-eu.pal.bin" ^
	|| exit /b 1

"tools\PixelPet.exe" ^
	Import-Bitmap "img\copyright.pal.png" Read-Palettes Convert-Palettes GBA ^
	Import-Bitmap "img\copyright-jp.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\copyright-jp.map.bin" ^
	Serialize-Tileset Export-Bytes "%_TEMP%\copyright-jp.img.bin" ^
	Serialize-Palettes Export-Bytes "%_TEMP%\copyright-jp.pal.bin" ^
	|| exit /b 1

"tools\PixelPet.exe" ^
	Import-Bitmap "img\battlechip-dedupl.pal.png" Read-Palettes --palette-number 11 Convert-Palettes GBA ^
	Import-Bitmap "img\battlechip.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\battlechip.map.bin" ^
	Clear-Tilemap ^
	Import-Bitmap "img\description.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\description.map.bin" ^
	Clear-Palettes ^
	Import-Bitmap "img\battlechip.pal.png" Read-Palettes --palette-number 11 Convert-Palettes GBA ^
	Serialize-Tileset Export-Bytes "%_TEMP%\battlechip.img.bin" ^
	Serialize-Palettes Export-Bytes "%_TEMP%\battlechip.pal.bin" ^
	|| exit /b 1

"tools\PixelPet.exe" ^
	Import-Bitmap "img\programdeck.pal.png" Read-Palettes Convert-Palettes GBA ^
	Import-Bitmap "img\programdeck-left.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP -x  0 -y  0 -w 112 -h 80 ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-left.map.bin" ^
	Import-Bitmap "img\programdeck-right.png" Convert-Bitmap GBA ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-right.map.bin" ^
	Import-Bitmap "img\programdeck-paths.png" Convert-Bitmap GBA ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  0 -y  0 -w  8 -h 16 --no-reduce --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-path-l0.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  8 -y  0 -w  8 -h 16 --no-reduce --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-path-l1.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x 16 -y  0 -w  8 -h 16 --no-reduce --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-path-l2.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  0 -y 16 -w  8 -h 16 --no-reduce --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-path-r0.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  8 -y 16 -w  8 -h 16 --no-reduce --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-path-r1.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x 16 -y 16 -w  8 -h 16 --no-reduce --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-path-r2.map.bin" ^
	Serialize-Palettes Export-Bytes "%_TEMP%\programdeck.pal.bin" ^
	Import-Bitmap "img\programdeck-buttons.pal.png" Read-Palettes Convert-Palettes GBA ^
	Import-Bitmap "img\programdeck-buttons.png" Convert-Bitmap GBA ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  0 -y  0 -w 32 -h 16 --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-ok0.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x 32 -y  0 -w 32 -h 16 --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-ok1.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  0 -y 16 -w 32 -h 16 --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-ok2.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x 32 -y 16 -w 32 -h 16 --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-ok3.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x  0 -y 32 -w 32 -h 16 --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-ok4.map.bin" ^
	Clear-Tilemap ^
	Generate-Tilemap GBA-4BPP -x 32 -y 32 -w 32 -h 16 --append ^
	Serialize-Tilemap Export-Bytes "%_TEMP%\programdeck-ok5.map.bin" ^
	Serialize-Palettes Export-Bytes "%_TEMP%\programdeck-buttons.pal.bin" ^
	Serialize-Tileset Export-Bytes "%_TEMP%\programdeck.img.bin" ^
	|| exit /b 1

exit /b 0
