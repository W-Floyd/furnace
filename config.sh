#furnaceconfig#

################################################################################
# Name of the pack.
#
# Defaults to folder name if missing.
################################################################################

#__name='Pack'

################################################################################
# Default render sizes.
#
# Defaults to '32 64 128 256 512 1024'
################################################################################

#__sizes='1 2 4 8 16 32 64 128 256 512 1024 2048'

################################################################################
# Temporary directory to use (will be created if need be).
#
# Defaults to /tmp/furnace/${__name}_${__id} if missing.
################################################################################

#__tmp_dir="$(pwd)/tmp/${__id}"

################################################################################
# Script to use for mobile conversion.
#
# No default currently, will disable mobile conversion if missing.
################################################################################

#__furnace_make_mobile_bin='./convert_to_mobile.sh'

################################################################################
# Custom functions to use when rendering images. May override default functions.
################################################################################

#__custom_function_bin='./functions.sh'

################################################################################
# Whether or not the final images should be optimized.
#
# Defaults to no optimization ('0') if missing.
################################################################################

#__should_optimize='1'

################################################################################
# Largest size to optimize.
#
# Defaults to '512' if missing.
################################################################################

#__max_optimize='512'

################################################################################
# Whether or not to ignore the max optimize size.
#
# Defaults to off ('0') if missing.
################################################################################

#__ignore_max_optimize='1'

################################################################################
# Whether or not to render optional images (usually demo images).
#
# Defaults to off ('0') if missing.
################################################################################

#__render_optional='0'

################################################################################
# Largest size to render optional images for.
#
# Defaults to '2048' if missing.
################################################################################

#__max_optional='2048'

################################################################################
# Whether or not to ignore the max optional size.
#
# Defaults to off ('0') if missing.
################################################################################

#__ignore_max_optional='1'

################################################################################
# Scale that vector images are assumed to be created at (should be possible to
# override per script).
#
# Defaults to '128' if missing.
################################################################################

#__vector_scale='128'

################################################################################
# PPI that vector images are assumed to be created at (should be possible to
# override per script).
# Note that this value is available as Inkscape used to use a non-standard
# value of 90. When using an older version of Inkscape, or when processing files
# that have not been converted, this value will need to be set.
#
# Defaults to '96' if missing, as that's the new standard.
################################################################################

#__vector_ppi='96'

################################################################################
# Required software for the pack. This is a semi-temporary measure, I need to
# muck out the IM calls and make sure they're verified, probably like optimizers
# and renderers.
################################################################################

#__depends='convert composite montage mogrify identify'

################################################################################
# Routines
################################################################################
#
# Routines that may be specified in the config.
#
# Either declare:
# __function_<PREFIX>=<ROUTINE>
# or use
# __set_routine <PREFIX> <ROUTINE>
#
# The latter function will ride out any changes in semantics, though it is not
# any easier to invoke. For the sake of example, __set_routine shall be used.
#
################################################################################

################################################################################
# What routine to use for SVG rendering.
#
# Standard values include:
# rsvg-convert
# inkscape
# convert

# Defaults to 'rsvg-convert' if available.
################################################################################

# __set_routine 'vector_render' 'rsvg-convert'

################################################################################
# What routine to use for PNG optimization.
#
# Standard values include:
# optipng
# pngcrush
# zopflipng
#
# Defaults to 'optipng' if available.
################################################################################

# __set_routine 'optimize' 'optipng'

################################################################################
# What routine to use for file hashing.
# Standard values include:
# md5sum
# sha1sum
# sha224sum
# sha256sum
# sha384sum
# sha512sum
#
# Defaults to 'md5sum' if available.
################################################################################

# __set_routine 'hash' 'md5sum'
