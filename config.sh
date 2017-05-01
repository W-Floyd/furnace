#furnaceconfig#

# Name of the pack.
# Defaults to folder name if missing.
#__name='Pack'

# Default render sizes.
#__sizes='1 2 4 8 16 32 64 128 256 512 1024 2048'

# Temporary directory to use.
# Defaults to /tmp/texpack${__pid} if missing.
#__tmp_dir="$(pwd)/tmp/${__pid}"

# Script to use for mobile conversion.
# No default currently, will disable mobile conversion if missing.
#__furnace_make_mobile_bin='./convert_to_mobile.sh'

# Custom functions to use. Please follow the same format as the standard
# functions.sh file. May include both image functions and any other you find you
# need when rendering images.
#__custom_function_bin='./functions.sh'

# Whether or not to render in quick mode (if applicable).
# Defaults to quick mode if missing.
#__quick='1'

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
