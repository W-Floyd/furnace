#furnaceconfig#

# Name of the pack.
# Defaults to folder name if missing.
#__name='Pack'

# Default render sizes.
#__sizes='1 2 4 8 16 32 64 128 256 512 1024 2048'

# Temporary directory to use.
# Defaults to /tmp/furnace/${__name}_${__id} if missing.
#__tmp_dir="$(pwd)/tmp/${__id}"

# Script to use for mobile conversion.
# No default currently, will disable mobile conversion if missing.
#__furnace_make_mobile_bin='./convert_to_mobile.sh'

# Custom functions to use. Please follow the same format as the standard
# functions.sh file. May include both image functions and any other you find you
# need when rendering images.
#__custom_function_bin='./functions.sh'

# Whether or not the final images should be optimized.
# Defaults to no optimization if missing.
#__should_optimize='1'

# Largest size to optimize.
# Defaults to 512 if missing.
#__max_optimize='512'

# Whether or not to ignore the max optimize size.
# Defaults to off if missing.
#__ignore_max_optimize='1'

# What optimizer to use. May be a custom optimizer, so long as a function named
# __optimize_<OPTIMIZER> exists, and replaces the given file.
# Defaults to an existing optimizer, selected from a list and by availability.
# If available, optipng is first on the list, due to compatability.
#__optimizer='zopflipng'

# Whether or not to render optional images (usually demo images).
# Defaults to off if missing.
#__render_optional='0'

# Largest size to render optional images for.
# Defaults to 2048 if missing.
#__max_optional='2048'

# Whether or not to ignore the max optional size.
# Defaults to off if missing.
#__ignore_max_optional='1'

# Scale that vector images are assumed to be created at (should be possible to
# override per script).
# Defaults to 128 if missing.
#__vector_scale='128'

# PPI that vector images are assumed to be created at (should be possible to
# override per script).
# Note that this value is available as Inkscape used to use a non-standard
# value of 90. When using an older version of Inkscape, or when processing files
# that have not been converted, this value will need to be set.
# Defaults to 96 if missing, as that's the new standard.
#__vector_ppi='96'
