# Mega Man Battle Chip Challenge - Chip Control

A mod that changes the battle system in Mega Man Battle Chip Challenge to let you freely choose your chips in battle.

This repository contains the source code. [**Looking for the download link? Grab the patch from The Rockman EXE Zone!**](https://forums.therockmanexezone.com/mega-man-battle-chip-challenge-chip-control-mod-t16681.html)

## Reporting Bugs

Please report any bugs and suggestions in the project topic on The Rockman EXE Zone Forums:

https://forums.therockmanexezone.com/mega-man-battle-chip-challenge-chip-control-mod-t16681.html

## Credits

* **[Prof. 9](https://twitter.com/Prof9)** - Planning, Programming
* **[weenie](https://github.com/bigfarts)** - Translation (Japanese)

## Setup

Place any of the following ROM file in the `_rom` folder:

* `mmbcc-us.gba` - Mega Man Battle Chip Challenge - US ROM
* `mmbcc-eu.gba` - Mega Man Battle Chip Challenge - EU ROM
* `exebcgp.gba` - Rockman EXE Battle Chip GP - JP ROM

You can also use the Wii U Virtual Console version ROMs.

Place the required third-party tools in the `_tools` folder. See `_tools\tools_go_here.txt` for details.

* [armips](https://github.com/Kingcom/armips/) by Kingcom. [v0.11.0-140-g87d44e4](https://github.com/Kingcom/armips/tree/87d44e4db7cbdfc99b8808f2c345ffcc3bfd1ecd) is used, but any newer version should also work.

A compatible version of PixelPet is included.

## Building

Building is supported on Windows 10 and up.

Run the following command:

```
make <target>
```

Target can be any of the following:

| Target name | Description                    |
| ----------- | ------------------------------ |
| `us`        | Builds for North American ROM. |
| `eu`        | Builds for European ROM.       |
| `jp`        | Builds for Japanese ROM.       |
| `clean`     | Removes all output files.      |

If no target is specified, it defaults to `us`.

The output ROM will be built in the `_rom` folder, as well as a symfile (for use with No$gba).

## License

This project is licensed under the terms of the MIT License. See `license.txt` for more details.

## Legal

This project is not endorsed by or affiliated with Capcom in any way. Mega Man and Mega Man Battle Network are registered trademarks of Capcom. All rights belong to their respective owners.
