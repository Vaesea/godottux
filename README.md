This is not even nearly finished yet. If you want something that's finished, I'd recommend waiting or even contributing to this yourself. There are most likely a lot of bugs.

If the code is a bit messy... oops. I still hope that people can make actual decent SuperTux fangames from this.

# GodotTux
A SuperTux 0.3.2 remake in Godot, but in a way that makes it easy to make SuperTux fangames! (If you know how to code, and if you can understand the worst code you've ever seen in your life)

The worldmaps are like PepperTux-Haxe's worldmaps, which means they're more RPG-like, but since this is Godot, you should easily be able to make worldmaps similar to SuperTux.

## Pre-Beta TODOs
- Fix placing holdable objects in another holdable object (doesn't seem like it can be done right now?)
- Stop holdable objects from being placed in walls (I remember this being a bug)
- Dart Trap
- Dart
- Forest Exit Tiles

## After-Beta / Pre-Release TODOs
- Fish
- Mole
- Zeekling
- Skullyhop
- Ispy
- Button
- Plant (Default version would wake up even when Small Tux is detected, but you'd be able to change options in it to make it like the actual Plant enemy)
- Toad
- End Sequence "Stop Tux" thing that pauses everything
- Add stars when Tux reaches the end of the level, not just when Tux gets the star powerup.
- Use onready variables instead of calling the nodes with $ (will be done after release)
- BadGuy.gd should be maintainable at some point. To do this, any enemy that breaks should be made it's own separate thing.
- Improve certain enemies (like Igel)

## What this doesn't recreate / use
- Levels (Except Welcome To Antarctica)
- Accurate Main Menu
- Accurate Options Menu
- Multiple Profiles (if someone were to add this in, along with a way to change which profile you're using, that'd be cool!)
- SuperTux-style Worldmaps
- Completely accurate Tux movement (if someone were to add this in, that'd be cool!)
- Add-on Support
- Completely accurate HUD (I tried to make it as accurate as I could)
- In-game console (Use the Godot Output thing to debug your code instead)
- The same scripting system (While there is scripting, it's done using variables in a block instead)
- Magic Tiles (sounds too difficult for me to make. if someone were to add this in, that'd be cool!)
- Snowman (although previously listed in the planned list, i realized it's not a 0.3.2 enemy. has a small chance of still being added, though)
- Level Flipping (this sounds too difficult for me to make. if someone were to add this in, that'd be cool!)
- Angry Stone (Too complicated to add. If someone were to add this in, that'd be cool!)
- Totem (Too complicated to add. If someone were to add this in, that'd be cool!)
- Kugelblitz

There also isn't a level editor, not even as a separate program. I might try to make one at some point, but for now, just use the template level and worldmap as a base for your level or worldmap. You also get to learn Godot while doing this.

## Extra Features
### Debug Mode
You activate this by pressing the \ key.

When you activate this, instructions are given to you through a message (I'm not sure if it works on Linux or not, but it should)

There is currently no way to disable this other than to delete your save file.

### New Enemies
Smartball / Mrs Snowball and Smartblock / Mrs Iceblock are some new enemies here.

## Credits
- SuperTux Team (SuperTux 0.3.2 images, music and more)
- Vaesea (Coding, Test Levels)
- AnatolyStev (Coding) (i'm kind of sure he has worked on every supertux fangame i've ever made)
- FilipOK (Art) (New logo, icon, new main menu)
