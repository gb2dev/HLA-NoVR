# HLA-NoVR
NoVR Script for Half-Life: Alyx

Mod repository note: due to regular (and huge) NoVR main mod changes, I'm constantly updating this repo by manually making reset to clear state, and applying all mod support changes again.

## Mod support
With this fork of NoVR mod, you will be able to also play & complete next modifications (you can get them from Steam Workshop):
- ``Levitation`` (campaign, 7 maps + intro)
- ``Extra-Ordinary Value`` (campaign, 4 maps) 
- ``Resident Alyx: biohazard`` (campaign, 6 maps + epilogue)
- ``GoldenEye Alyx 007 - Dam`` (part 1)
- ``Belomorskaya Station`` (1 map)
- ``Overcharge`` (1 map)
- ``Red Dust`` (1 map)

## Wrist pockets
Note: this feature is already included in main NoVR mod.
Also you will be able to carry some objects in pockets, like in original game. Most of objects will be placed into pockets only by pulling them with Gravity Gloves. Press Z button to use available health pen, and press C to drop one of objects from pockets.
Items you can carry: ``Health Pen, Combine Battery, Key Cards, Health Station Vials, Vodka, Reviver's Heart``.

## Installation
[Install the official launcher for easy updates](https://github.com/bfeber/HLA-NoVR-Launcher#installation-and-usage).

You can also get the [NoVR Map Edits addon](https://steamcommunity.com/sharedfiles/filedetails/?id=2956743603) for smoother traversal and less out of bounds glitches.

## Controls
To change the controls/rebind buttons or change your FOV, edit ``game\hlvr\scripts\vscripts\bindings.lua`` in your main Half-Life: Alyx installation folder.

If you get stuck try to move back or crouch! In case that does not help you can enable noclip with V.

### Keyboard and Mouse
Left Click: Select in Main Menu/Throw Held Object/Primary Attack

W, A, S, D: Move

Space: Jump

Ctrl: Crouch

Shift: Sprint

E: Interact/Pick Up Object/Gravity Gloves/Put Valuable Item in Wrist Pocket

Z: Use Health Pen in Wrist Pocket

X: Use Grenade in Wrist Pocket

C: Drop Object in Wrist Pocket

F: Flashlight (if you have it)

H: Cover your mouth

F5: Quick Save

F9: Quick Load

M: Main Menu

P: Pause

V: Noclip (if you get stuck)

C: Console

## Official Discord Server
https://discord.gg/AyfBeuZXsR

## Old installation method
If the launcher doesn't work, then you can try the old installation method:

Copy the ``game`` folder into your main Half-Life: Alyx installation folder (e.g. ``C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx``).

Then start the game with the launch options ``-novr -vsync``.

## Special Thanks
- JJL772 for making the flashlight and jump scripts: https://github.com/JJL772/half-life-alyx-scripts
- Withoutaface for making the amazing HUD: https://github.com/withoutaface/HLA-NoVR-alyxhl2-ui-weapons
- FrostElex for Storage script from his tools package: https://github.com/FrostSource/hla_extravaganza
