# Smelt
## A Minecraft resource pack builder
## Undergoing major changes, do not use for now.

![Logo](https://github.com/W-Floyd/smelt/raw/master/logo.png)

cd into an appropriate folder, then run:

```
git clone https://github.com/W-Floyd/smelt.git
cd smelt
sudo ln -s "$(pwd)/smelt.sh" "/usr/bin/smelt"  
sudo ln -s "$(pwd)/autocomplete.sh" "/usr/share/bash-completion/completions/smelt"  
```

Then you can run `smelt` in the appropriate folder, and it should render.
Run `smelt -h` for help. 

If things don't render properly after modifying some stuff, run `smelt --force`, or delete the appropriate folders and re-render. This shouldn't happen, so if it does, please add an issue and describe which files were changed so I can fix it.

If, however, it was because you forget some dependencies and it tried to use a file that wasn't there, you need to fix your stuff, then see if it still has an issue.

It is wise to render fresh packs upon significant script changes. Though smelt should handle the changes gracefully, I cannot be sure.

***

Recommended:
* Imagemagick (**most HIGHLY** recommended)
* Inkscape and/or rsvg-convert (recommended)
* GIMP (recommended)
* optipng (good for preparing pack releases)

This tool is pretty much neutered without Imagemagick, so though it's not required *per se*, you won't get far without it. The only weird case where you might never need it is if you use this tool solely to automatically export, optimize and pack, in which it might be worth it.

Where it really comes into its own is doing the boring jobs, like overlaying a wool pattern on all 16 colours, so when the overlay or colour changes, so do the dependant wool pieces. Same with planks, logs, glass, etc.

### Known issues

At one point I had to compile a newer version of Imagemagick from source to make some compositing work. If you get odd results, that may be the issue. This *seems* to have been solved by setting some options on all image operations.

Sizes above 1024px **will not** not to be loaded in Minecraft at all, and even 1024px has not always loaded for me (needs optifine for sure), so 512px is the largest default size. 4096px is the largest size I have successfully processed, as 8192px is killed when I run out of memory (16gb RAM + 4gb swap). Even 4096px runs out of memory when processing some demo images. Really though, why anyone needs anything larger than 4096px is beyond me - a single texture is larger than a 4K screen. Certainly large enough for print usage.

If a render run is cancelled, it may leave incomplete images. If you find you have odd results, or get errors about missing dependencies, forcefully re-render to fix it. Using a cancelled render is never recommended, nor supported!

Documentation could be better - I may eventually clean things up.

***

See https://github.com/W-Floyd/Angl-Resource-Pack for the reference resource pack. It's easy enough to base your work from that.
