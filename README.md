# Smelt
## A Minecraft resource pack builder

![Logo](https://github.com/W-Floyd/smelt/raw/master/logo.png)

From this directory, run:

```
sudo mkdir -p /usr/share/smelt  
sudo ln -s "$(pwd)/make-pack.sh" "/usr/share/smelt/smelt.sh"  
sudo ln -s "/usr/share/smelt/smelt.sh" "/usr/bin/smelt"  
sudo ln -s "$(pwd)/functions.sh" "/usr/share/smelt/smelt_functions.sh"  
sudo ln -s "$(pwd)/render.sh" "/usr/share/smelt/smelt_render.sh"  
```

Requires:
* Inkscape and/or rsvg-convert
* tsort

Then you can run `smelt` in the appropriate folder, and it should render.
Run `smelt -h` for help. 

If things don't render properly after modifying some stuff, just delete the appropriate folders and re-render. This shouldn't happen, so if it does, please add an issue and describe which files were changed so I can fix it.

It is highly recommended that fresh packs are rendered upon significant script changes. Though the script should handle the changes gracefully, I cannnot be sure.

###Known issues

At one point I had to compile a newer version of Imagemagick from source to make some compositing work. If you get odd results, that may be the issue. This *seems* to have been solved by setting some options on all image operations.

If you cancel a partial render, there will be an initial delay as the xml catalogue is parsed. Will see if I can do anything about that.

Sizes 1024px and above are known not to be loaded in Minecraft, and so 512px is the largest default size. 4096px is the largest size I have sucessfully processed, as 8192px segfaults when I run out of memory (16gb RAM + 4gb swap).

Documentation could be better - I may eventually clean things up.

See https://github.com/W-Floyd/Angl-Resource-Pack for the reference resource pack from which you can reference.
