################################################################################
# Image Functions
################################################################################

export __imagemagick_define='-define png:color-type=6'

################################################################################
#
# __pngchunks <FILE.png>
#
# Finds the chunks in a PNG file - currently being used to test for changed
# colour profiles when optimizing, since Minecraft is borked, and doesn't seem
# to like color_type 0 and color_type 4.
#
################################################################################

__pngchunks () {
identify -verbose "${1}" | pcregrep -M " Properties(\n|.)* Artifacts:" | sed -e '1d' -e '$d' | sed 's/ *//' | grep '^png'
}

################################################################################
#
# __minecraft_verify <FILE.png>
#
# Checks if an image has "color_type"s known not be to loaded correctly by
# Minecraft. If all clear, returns 0, if failed, 1.
#
################################################################################

__minecraft_verify () {
local __color_type="$(__pngchunks "${1}" | grep '^png:IHDR.color_type:' | sed 's/.* \(.\) .*/\1/')"
if [ "${__color_type}" = '0' ] || [ "${__color_type}" = '4' ]; then
    return 1
else
    return 0
fi
}

################################################################################
#
# __resize <SCALE> </dir/to/src/IMAGE.png> </dir/to/dest/IMAGE.png>
#
# Rescale Image
# Accepts a scale, source and dest PNG files as inputs, rescales to the given
# scale (0-1.0). Will ignore if given file is not a '.png' file.
#
################################################################################

__resize () {

if [ "$(__oext "${2}")" = 'png' ] && [ "$(__oext "${3}")" = 'png' ]; then
    convert "${2}" ${__imagemagick_define} -scale "$(bc -l <<< "${1}*100" | sed 's/\(\.[0-9]*[1-9]\)0*/\1/')%" "${3}"
else
    __force_warn "File ${2} is not a PNG image and cannot be resized"
fi

}

