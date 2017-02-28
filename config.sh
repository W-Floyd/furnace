#smeltconfig#
echo 'something to use a pipe' | rev > /dev/null
compgen -A variable > /tmp/tmpvars
################################################################
# Start customizing from here
################################################################

# Name of the pack, defaults to folder name if missing
__name='Pack'

# Default render sizes
__sizes='1 2 4 8 16 32 64 128 256 512 1024 2048 4096'

# Temporary directory to use. Defaults to /tmp/texpack${__pid}
# if missing
__tmp_dir="$(pwd)/tmp/${__pid}"

# Script to use for mobile conversion. No default currently,
# will disable mobile conversion if missing
__smelt_make_mobile_bin='./convert_to_mobile.sh'

# Whether or not to render in quick mode (if applicable).
# Defaults to quick mode if missing
__quick='1'

# Whether or not the image source files are vector.
#
# If yes, '1', then images will be rendered at native scale for
# all sizes.
#
# If no, '0', then images will be rendered at the native scale
# specified first, then directly rescaled to all lower sizes.
#
# Any sizes larger than the native size are not allowed.
#
# This option may be either on or off if all images are vector,
# but must be on if any raster images are present.
__vector_source='0'

# The native size of any raster source files (GIMP, etc.)
# Only useful when __vector_source is off. This value is ignored
# when not used.
__native_size='1024'

################################################################
# Stop customizing from here
################################################################
compgen -A variable > /tmp/tmpvars2
for __variable in $(grep -Fxvf /tmp/tmpvars /tmp/tmpvars2); do
    export "${__variable}"
done
