# config.sh
## Highly recommended

The config file specifies certain variables. It is actually a bash script, in order to provide maximum flexibility. The provided example includes all useable variables, as well as variables that may be used in these variables. It also automatically exports all of these for the parent script to use.

The following variables may be set:  
__name  
__sizes  
__tmp_dir  
__furnace\_make\_mobile_bin  
__custom\_function\_bin  
__quick  
__should_optimize  
__max_optimize  
__ignore\_max\_optimize  
__optimizer  
__render_optional  
__max_optional  
__ignore\_max\_optional  

The following variables may be used:
__pid

# catalogue.xml
## Required

At the most basic level, a catalogue must contain entries like so:  

```
	<ITEM>
		<NAME>./assets/minecraft/textures/blocks/dirt.png</NAME>
		<SCRIPT>./conf/vector_basic_block.sh</SCRIPT>
		<SIZE></SIZE>
		<OPTIONS>dirt</OPTIONS>
		<KEEP>YES</KEEP>
		<IMAGE>YES</IMAGE>
		<DEPENDS></DEPENDS>
		<CLEANUP>./assets/minecraft/textures/blocks/dirt.svg</CLEANUP>
		<OPTIONAL>NO</OPTIONAL>
		<COMMON>Dirt</COMMON>
	</ITEM>
```

The fields are as follow:  

**ITEM** describes where to start and stop looking for each individual file to process.

**NAME** describes the output file name achieved. Formatted relative to the top folder of the resource pack.

**SCRIPT** describes what file is used to process the file. More on this later. Also formatted relative to the top folder of the resource pack. Custom scripts usually go in './conf/'.

**SIZE** describes what size to process the file with. Rarely used. If blank, uses pack size. Mainly included for pack logo. Any positive integer will work.

**OPTIONS** describes any options to pass to the script. Placed after SIZE, as SIZE is passed as an option to all SCRIPT scripts.

**KEEP** describes whether the produced file is intended for inclusion in the final resource pack. YES or NO answer. So if you are processing a working only file (an overlay, for instance), this is set to NO. Otherwise, YES.

**IMAGE** describes whether the produced file is an image or not, for use in rescaling from a large size.

**DEPENDS** describes any files this file **directly** relies on. For instance, if your script pulls in a file derived from wool, the colour file, nor wool overlay are required, only the directly used file. The render script extrapolates this information for use, so there is no need to do it ourselves. It **shouldn't** break things, but it's bad form, and not tested.

**CLEANUP** describes the source files to delete upon completion of the resource pack. Again, formatted relative to the top folder of the resource pack. For images composed entirely from pre-rendered images, this will be blank.

**OPTIONAL** describes if the file is an optional render, useful for demo images.

**COMMON** describes the common name of the texture. This is optional, and might be hard to fill in at times. Only useful on KEEP files.
