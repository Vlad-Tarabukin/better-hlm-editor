# BETTER HLM2 EDITOR
Program to create custom levels for Hotline Miami 2: Wrong number

## Running from source on Linux

Tested with Godot 4.7 Stable (`4.7.stable.official.5b4e0cb0f`) on Linux x86_64.
Open `project.godot` in that version of Godot and run the project, or launch it
from the repository root:

```bash
godot --path .
```

The editor requires a compatible, legally obtained local `base.wad` beside
`project.godot`. Do not add game data to contributions. `version.txt` is optional:
source checkouts without it skip the release updater.

Custom data uses the system Documents directory followed by
`My Games/Better HLM Editor`. The game mod lookup uses
`My Games/HotlineMiami2/mods` under that same Documents directory. Proton paths
are not discovered automatically.

### Verification

Run these commands with the tested Godot binary from the repository root:

```bash
godot --version
godot --headless --editor --path . --quit
godot --headless --path . --quit-after 2
```

The application requires the local WAD. Run startup checks with disposable
user-data and config directories.

These checks cover source import and startup. Interactive
editing, Windows startup, exported-level compatibility in Hotline Miami 2, and
game/Proton playtest automation still require manual testing. Bounded headless
application runs currently report resource leaks at shutdown.

Tiles with a known sheet ID but unavailable atlas coordinates show a placeholder.
The diagnostics panel identifies the floor, tile ID, and atlas coordinates;
the tooltip lists all affected tiles. Saving preserves the original tile fields.

## CONTROLS:
 - MMB - move camera
 - Scroll wheel - zoom
 - Double click LMB - edit object
 - Shift + LMB - move object
### Build tab:
**Tile mode:**
 - LMB - place tiles
 - RMB - delete tile
 - Ctrl + RMB - clear area
 - Ctrl + MMB - pick tile

**Wall mode:**
 - LMB - place walls
 - RMB - delete wall
 - Ctrl + RMB - clear area
 - Shift + RMB - choose other variant of the wall
 - Ctrl + MMB - pick wall
   
**Corner mode:**
 - LMB - place corner
 - RMB - delete corner
 - Ctrl + MMB - pick corner
### Items tab:
 - LMB - place object
 - RMB - delete object
 - Shift + RMB - rotate 90 degrees
 - Shift + Scroll wheel - rotate 15 degrees
 - Ctrl + Scroll wheel - rotate 1 degrees
 - Alt + Scroll wheel - change frame
### Gameplay tab:
 - LMB - place object
 - RMB - delete object
 - Shift + RMB - rotate 90 degrees
 - Shift + Scroll wheel - rotate 15 degrees
 - Ctrl + Scroll wheel - rotate 1 degrees
### Level tab:
 - LMB - place object
 - RMB - delete object
 - Shift + RMB - rotate 90 degrees

**Custom .tsv folder: "Documents/My Games/Better HLM Editor"**

*Special thanks to Maxim_s*
