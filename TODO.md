# TODO list

***
#### Render script
Add \_\_check\_field function to ensure a field exists. Act accordingly (\_\_error out when required)  

For starters, allow not having SCRIPT, SIZE, OPTIONS, DEPENDS, CLEANUP, and COMMON.
Also to be considered are default values for KEEP, IMAGE and OPTIONAL.
KEEP should default to NO, IMAGE to YES (better yet, check the files name for extension when field is missing), OPTIONAL to NO.
Only required field should be NAME.  

***

## Planned features
#### Allow pack variants. 
Will require a field named 'variant', which describes what variants it belongs to.  
This feature will be tricky to implement gracefully, and will certainly require major restructuring of catalogue splitting (though, hopefully, minimal changes to the catalogue itself). The catalogue will be split per-variant, into their own folders. Non catalogue files (that is, listings, tsort, optimization, etc.) should go into their own folder/s - the catalogue folder should just be for the catalogue.  

Variants should stack, and calling order will dictate variant combination. Definition order, however, does not matter.

Examples where allowing variants will be useful:  
* **most** importantly, size specific variants. For example in Angl, wool sizes 32 and below are a blurred blob, due to the way the stripes run (half pixel). Allowing a size variant would afford me the opportunity to do differently spaced striped for 32, and few stripes for lower textures.
* animated/non-animated pack (non-animated would be default)
* themed/non-themed pack (Halloween, Candy Land, whatever sets your pants on fire)

To define variants, the field VARIANT will be used.

The planned calling syntax for this would be like so:

furnace 32.base,animated,32,halloween

The first part is the size used, which is separated by a period. This means different sizes may be called with different variants in the same pass, and defaults may be declared in a config (and by furnace itself if all else fails)

Would render size 32, using 'base' items, some of which might be overridden by 'animated' item variants, some of which might be overridden by '32' specific variants, some of which might be overridden by 'halloween' variants. Any 'animated' '32' specific variants will override the previous mix of 'animated' and '32', then any '32' 'halloween' variants will override any previous mix of '32' and 'halloween', then any 'animated' '32' 'halloween' variants will override any previous variants from all others.

To include an item in a variant, or combination of variants, plus symbols ('+') should be used to prefix and separate the variant combination, like so:  
```<VARIANT>+animated+32+halloween</VARIANT>```

This means the texture **only** applies to a combination of animated, 32, and halloween (e.g. a 32 scale animated jack'o'lantern). This takes priority over a combination of '32', 'animated' and/or 'halloween' mixed together. It will not be included in, say, '+animated,+32,+halloween,+high\_contrast', '+animated,+32', '+animated,+32,+high_contrast', or any others, unless it states so separately (we'll get to that)

This allows us to limit to a single level variant, like so:  
```<VARIANT>+animated</VARIANT>```

Commas (',') will separate variants it applies to. e.g.  
```<VARIANT>+animated,+32,+halloween,+animated+32</VARIANT>```

This means it can be used for: 'animated', '32', 'halloween', and 'animated 32'.  
It will not be included in child variants (we'll get to that later)
If variant is missing, it applies to the default 'base' variant. Alternatively, 'base' may be declared. First defined item is the one used. furnace should warn when multiple images of the same definition are declared in the same level of scope, and it should also warn when an image is not available in the current set of variants (but is in others).

To exclude an item from a variant, specific or inherited (we'll get to that), an exclamation mark should be used ('!') to prefix that exclusion, in the same way an inclusion was defined. e.g.  
```<VARIANT>+base,+animated,!animated!32!halloween</VARIANT>```
Note that an inclusion must be specified in this case.
Excludes that item from being considered in '+animated,+32,+halloween', or any specific combinations thereof (when called, that is), though it will be in animated and base, or any combination thereof (it is still included in the base group). Remember, this is specific, so order does not matter.

```<VARIANT>+base,!animated,+animated+32+halloween,+halloween</VARIANT>```
Would mean it will be in 'base', but should not be in 'animated' (so, if 'base' is called, it's included. If 'base,animated', 'animated,base', or 'animated' is called, it's not included.)
'+animated+32+halloween' then includes it specifically with 'animated', '32' and 'halloween' together. 'halloween' on its own is stated, meaning that it is included in 'halloween'. Remember, none of these files are inherited by other variants unless called as such.

To that end, and to make things complete, variants may use a form of regex, like so:  
```<VARIANT>+.\*,!animated!.\*,+animated+32,!.\*\_wood,+dark\_.\*</VARIANT>```
This means the following:
It starts by being included in all variants, specific and non-specific, of any kind ('+.\*' - that is, match any inclusions of any name, which then means all variants)  
Next, it is excluded from any 2 part specific variant in which one variant is 'animated' ('!animated!.\*')  
Then, it is re-included in specific variant 'animated 32', which it would have otherwise been excluded from. ('+animated+32')  
Now, it is excluded from any variants that ends in '\_wood'. ('!.\*\_wood')  
Finally, it is re-included in any variant stating with 'dark\_' (there may be some from the '\_wood' exclusion that get re-included here, so long as they only have one '\_wood' in them.) ('+dark\_.\*')  

Therefore, order of consideration is on a per-group basis (separated by commas)
Specific variants will be chosen in order of specificity.

This is entirely more complicated than I will ever need in full, so here are some examples that I might actually use:  

```<VARIANT>+.\*,!no_animation!\*</VARIANT>```
Use: Animated grass
Variants: All variants, except any with 'no_animation'
Explanation: Include it in all variants (hence, all possible specific and nonspecific combinations also), minus all possible combinations that have, in part or in full, 'no_animation'.

```<VARIANT>+halloween</VARIANT>```
Use: Halloween themed pumpkin
Variants: All variants that include 'halloween'
Explanation: By including 'halloween' as a base variant, and no more, it means it can be overridden by more specific variants. But it will be included in any calling that includes, on its own.

This is also of note then: an inclusive calling ('+foo,+bar,+fizz,+bang') will be extrapolated to include specific variants ('+foo+bar,+fizz+bang'), but a specific calling ('+foo+bar+fizz+bang') will not be carried forward in any way.

Back to the furnace calling syntax, it is to be used in the same way as the definitions. That is, + includes any items that are included in this variant, and any subsequent options will need to be checked for specific variants. Specific variants may be called through furnace directly also. That leaves !, which excludes ITEMS that are included in this variant, or specific variant.

FURTHER NOTES:
Actually, I am not going to allow regex in the definition field, as somehow trying to implement intersecting regexes would be a clusterfuck. Only calling may use regex, definition must be specific. I'm too lazy to go back and make sure that is clear...

***

## Greater goals
* generic mobile render script should allow for any partial stage of completion
* all pack folders should be put into a 'build' directory, as should split catalogue files (keep source clean)
* all current 'conf' files should be moved out of src once again, possibly into a folder of the same name. This is required in order to most pedantically avoid collisions and keep good form
* build-time catalogue splitting (re-used within render batch only). This will require *fast*, *efficient* and *comprehensive* catalogue work, specifically dependency resolution and error reporting before render time

The following features are deemed high priority additions:
* gracefully exiting a render - finishing the current item before performing any cleanup needed, if any (it would be preferred it not exist)
* resumable renders (where good build-time catalogue work and graceful exiting is essential)
* parallel rendering (isolating render environment would be one option, or a reworking of the script system to allow graceful coexistence, later would be preferable)

In the long run, this will require at least one thing:
#### Language change
A more powerful and succinct programming language will be required for the render system (though individual file render scripts should remain). I am currently considering C++ . This would provide a much more robust system with which to work. That, combined with a clearer goal of my render system, should provide the desired speed and functions.

#### Blockers
Time, first and foremost. Though I am putting a great deal of work into this tool, I am in my final year of high school, and struggle to justify the effort and time involved in learning C++ or any other language. 
