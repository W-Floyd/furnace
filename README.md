# Smelt
## A Minecraft resource pack builder

![Logo](https://github.com/W-Floyd/smelt/raw/master/logo.png)

cd into an appropriate folder, then run:

```
git clone https://github.com/W-Floyd/smelt.git
cd smelt
sudo ln -s "$(pwd)/smelt.sh" "/usr/bin/smelt"  
sudo ln -s "$(pwd)/autocomplete.sh" "/usr/share/bash-completion/completions/smelt"  
```

Recommended:
* Imagemagick (**most HIGHLY** recommended)
* Inkscape and/or rsvg-convert (**HIGHLY** recommended)
* GIMP (recommended)

Then you can run `smelt` in the appropriate folder, and it should render.
Run `smelt -h` for help. 

If things don't render properly after modifying some stuff, just delete the appropriate folders and re-render. This shouldn't happen, so if it does, please add an issue and describe which files were changed so I can fix it.

It is highly recommended that fresh packs are rendered upon significant script changes. Though the script should handle the changes gracefully, I cannnot be sure.

###Known issues

At one point I had to compile a newer version of Imagemagick from source to make some compositing work. If you get odd results, that may be the issue. This *seems* to have been solved by setting some options on all image operations.

Sizes above 1024px and above are known not to be loaded in Minecraft at all, and even 1024px has not always loaded for me, so 512px is the largest default size. 4096px is the largest size I have sucessfully processed, as 8192px is killed when I run out of memory (16gb RAM + 4gb swap). Even 4096px runs out of memory when processing some demo images. Really though, why anyone needs anything larger than 4096px is beyond me - a single texture is larger than a 4K screen.

If a render run is cancelled, it may leave incomplete images. If you find you have odd results, or get errors about missing dependencies, forcefully re-render to fix it. Using a cancelled render is never recommended!

Documentation could be better - I may eventually clean things up.

See https://github.com/W-Floyd/Angl-Resource-Pack for the reference resource pack from which you can reference.
