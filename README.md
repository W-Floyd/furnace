![Logo](https://github.com/W-Floyd/furnace/raw/master/logo.png)
# Furnace
## A Minecraft resource pack builder
### Undergoing major changes (in another branch). Here be dragons.

## Installation
cd into an appropriate folder, then run:

```
git clone https://github.com/W-Floyd/furnace.git
cd furnace
sudo ln -s "$(pwd)/furnace.sh" "/usr/bin/furnace"  
sudo ln -s "$(pwd)/autocomplete.sh" "/usr/share/bash-completion/completions/furnace"  
```

## Instructions

Then you can run `furnace` in the appropriate folder, and it should render.
Run `furnace -h` for help. 

See https://github.com/W-Floyd/Angl-Resource-Pack for the reference resource pack. It's easy enough to base your work from that, and will save you a lot of time.

If things don't render properly after modifying some stuff, run `furnace --force-render`, or delete the appropriate folders and re-render. This shouldn't happen, so if it does, please add an issue and describe which files were changed so I can fix it.

If, however, it was because you forget some dependencies and it tried to use a file that wasn't there, you need to fix your stuff, then see if it still has an issue.

It is wise to render fresh packs upon significant script changes.

***

## Requirements

Required:
* pcregrep

Recommended:
* Imagemagick (practically required)
* Inkscape and/or rsvg-convert (recommended - if you're using SVG)
* GIMP (recommended - if you're using GIMP)
* optipng (recommended - good for preparing pack releases)

This tool is pretty much neutered without Imagemagick, so though it's not required *per se*, you won't get far without it. The only weird case where you might never need it is if you use this tool solely to automatically export, optimize and pack, in which it might be worth it.

Where it really comes into its own is doing the boring jobs, like overlaying a wool pattern on all 16 colours, so when the overlay or colour changes, so do the dependent wool pieces. Same with planks, logs, glass, beds, concrete, clay, etc.

***

## Some notes

Personally, I see no difference between 512px and 1024px at 4K unless I mash myself up close to some blocks and look close, so I recommend 512px as a maximum for day to day use. You're free to do what you like though...

A good rule of thumb - if you can't render it, you can't play it, or the size below it.

## Known issues

Sizes above 1024px **will not** not to be loaded in Minecraft at all, so 1024px is the largest default size.

Small sizes look terrible, especially angles. In order to solve this, I plan on implementing a system that allows variants, and thus allow low resolution specific variants. I also wish to investigate sharpening filters for use on those variants, when the time comes.

If a render run is canceled, it may leave incomplete images. If you find you have odd results, or continue to get errors about missing dependencies, forcefully re-render to fix it. Using a canceled render is never recommended, nor supported!

Documentation could be better - I may eventually clean things up.
