###############################################################
# Image Functions
###############################################################

###############################################################
#
# __pngchunks <FILE.png>
#
# Finds the chunks in a PNG file - currently being used to test
# for changed colour profiles with zopflipng, since Minecraft is
# borked, and doesn't like anything other than color_type 6
#
###############################################################

__pngchunks () {
identify -verbose "${1}" | pcregrep -M " Properties(\n|.)* Artifacts:" | sed -e '1d' -e '$d' | sed 's/ *//' | grep '^png'
}

###############################################################
#
# __minecraft_verify <FILE.png>
#
# Checks if an image has color_type's known not be to loaded
# correctly by Minecraft. If all clear, returns 0, if failed, 1
#
###############################################################

__minecraft_verify () {
local __color_type="$(__pngchunks "${1}" | grep '^png:IHDR.color_type:' | sed 's/.* \(.\) .*/\1/')"
if [ "${__color_type}" = '0' ] || [ "${__color_type}" = '4' ]; then
    return 1
else
    return 0
fi
}

###############################################################
#
# __vector_render <RES> <FILE.svg>
#
# Render Vector Image
# Renders the specified .svg to a .png of the same name
#
###############################################################

__vector_render () {
if [ -z "${__quick}" ]; then
    export __quick='1'
    __force_warn "__quick has not been set correctly. Defaulting to rsvg-convert"
fi

if ! [ "$(__oext "${2}")" = 'svg' ]; then
    __error "File \"${2}\" is not an svg file"
fi

__dpi="$(echo "(96*${1})/128" | bc -l | sed 's/0*$//')"
if [ "${__quick}" = '1' ]; then
# GOD awful hack to catch svg size, since rsvg-convert seems
# buggy
# TODO
# FIX THIS vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
rsvg-convert \
--width="$(echo "($(grep "^   width=\"*\"" < "${2}" | sed -e 's/.*="//' -e 's/"$//')*${1})/128" | bc)" \
-a \
"${2}" \
-o "$(__mext "${2}").png" 1> /dev/null
convert "$(__mext "${2}")"".png" -define png:color-type=6 "$(__mext "$2")"'_'".png"
mv "$(__mext "${2}")"'_'".png" "$(__mext "${2}")"".png"

elif [ "${__quick}" = '0' ]; then
inkscape \
--export-dpi="${__dpi}" \
--export-png "$(__mext "${2}").png" "${2}" 1> /dev/null
convert "$(__mext "${2}")"".png" -define png:color-type=6 "$(__mext "${2}")"'_'".png"
mv "$(__mext "${2}")"'_'".png" "$(__mext "${2}")"".png"
fi
}

###############################################################
#
# __gimp_export <FILE.xcf>
#
# GIMP Export
# Exports a given GIMP file to a PNG file of the same name
#
# Shamelessly stolen from:
# http://stackoverflow.com/a/5846727/7578643
#
###############################################################

__gimp_export () {

if ! [ "$(__oext "${1}")" = 'xcf' ]; then
    __error "File \"${1}\" is not a xcf file"
fi

__gimp_sub () {
gimp -i --batch-interpreter=python-fu-eval -b - << EOF
import gimpfu

def convert(filename):
    img = pdb.gimp_file_load(filename, filename)
    new_name = filename.rsplit(".",1)[0] + ".png"
    layer = pdb.gimp_image_merge_visible_layers(img, 1)

    pdb.gimp_file_save(img, layer, new_name, new_name)
    pdb.gimp_image_delete(img)

convert('${1}')

pdb.gimp_quit(1)
EOF
}

# My instance of GIMP throws some errors no matter what, so
__gimp_sub "${1}" &> /dev/null

}

###############################################################
# Optimizer Functions
###############################################################
#
# In all cases:
# __optimize_<OPTIMIZER> <IMAGE.png>
#
# <OPTIMIZER> Optimize
# Accepts a PNG file as an input, optimizes with <OPTIMIZER> and
# replaces if smaller.
#
###############################################################

# with -nc set, it seems to be loaded perfectly by Minecraft,
# because the color_type is retained
__optimize_optipng () {
local __tmpname="/tmp/$$)"
local __file="${1}"

local __size="$(identify -format "%w*%h" "${__file}" | sed 's/$/\n/' | bc)"
local __small='1024'
local __large='262144'

if ! [ "${__size}" -gt "${__small}" ]; then
    local __options='-o7'
elif [ "${__size}" -gt "${__large}" ]; then
    local __options='-o1'
else
    local __options='-o4'
fi

optipng ${__options} -strip all -nc -silent -force "${__file}" -out "${__tmpname}"

local __oldsize="$(stat "${__file}" -c %s)"
local __newsize="$(stat "${__tmpname}" -c %s)"

if [ "${__newsize}" -lt "${__oldsize}" ]; then
    mv "${__tmpname}" "${__file}"
else
    rm "${__tmpname}"
fi
}

# Should be be okay with -noreduce, but is stupid and changes it
# anyway, so it's checked for color_type correctness
__optimize_pngcrush () {
local __tmpname="/tmp/$$)"
local __file="${1}"

pngcrush -noreduce -force "${__file}" "${__tmpname}" &> /dev/null

local __oldsize="$(stat "${__file}" -c %s)"
local __newsize="$(stat "${__tmpname}" -c %s)"

if [ "${__newsize}" -lt "${__oldsize}" ]; then
    if __minecraft_verify "${__tmpname}"; then
        mv "${__tmpname}" "${__file}"
    else
        rm "${__tmpname}"
    fi
else
    rm "${__tmpname}"
fi
}

# Is stupid and won't let us specify a color_type to force, so
# we attempt to optimize anyway, then check the chunk, because
# Minecraft is stupid and won't load greyscale images correctly
__optimize_zopflipng () {
local __tmpname="/tmp/$$)"
local __file="${1}"

local __size="$(identify -format "%w*%h" "${__file}" | sed 's/$/\n/' | bc)"
local __small='1024'
local __large='262144'

if ! [ "${__size}" -gt "${__small}" ]; then
    local __options='-m'
elif [ "${__size}" -gt "${__large}" ]; then
    local __options='-q'
else
    local __options=''
fi

zopflipng ${__options} --keepchunks=gAMA --always_zopflify "${__file}" "${__tmpname}" &> /dev/null

local __oldsize="$(stat "${__file}" -c %s)"
local __newsize="$(stat "${__tmpname}" -c %s)"

if [ "${__newsize}" -lt "${__oldsize}" ]; then
    if __minecraft_verify "${__tmpname}"; then
        mv "${__tmpname}" "${__file}"
    else
        rm "${__tmpname}"
    fi
else
    rm "${__tmpname}"
fi
}

###############################################################
#
# __choose_optimizer
#
# Choose an optimizer
# Chooses an optimizer from a list, based on order, then
# availability
#
###############################################################

__choose_optimizer () {
local __possible_optimizers='optipng
zopflipng
pngcrush'

while read -r __possible_optimizer; do

    if __check_optimizer "${__possible_optimizer}"; then
        __optimizer="${__possible_optimizer}"
        break
    fi

done <<< "${__possible_optimizers}"

if [ -z "${__optimizer}" ]; then
    __error "No valid optimizer is available"
fi
}

###############################################################
#
# __optimize <IMAGE.png>
#
# Optimize Image
# Accepts a PNG file as an input, optimizes with optipng, and
# replaces if smaller. Will ignore if given file is not a
# '.png' file.
#
###############################################################

__optimize () {

if [ -z "${__optimizer}" ]; then
    __choose_optimizer
fi

if [ "$(__oext "${1}")" = 'png' ]; then

    if __check_optimizer "${__optimizer}"; then
        __optimize_${__optimizer} "${1}"
    else
        __error "Optimizer \"${__optimizer}\" is not valid"
    fi

else
    __force_warn "File \"${1}\" cannot be optimized."
fi
}

################################################################
#
# __resize <SCALE> </dir/to/src/IMAGE.png> </dir/to/dest/IMAGE.png>
#
# Rescale Image
# Accepts a scale, source and dest PNG files as inputs, rescales
# to the given scale (0-1.0). Will ignore if given file is not a
# '.png' file.
#
################################################################

__resize () {

if [ "$(__oext "${2}")" = 'png' ] && [ "$(__oext "${3}")" = 'png' ]; then
    convert "${2}" -define png:color-type=6 -scale "$(echo "${1}*100" | bc -l | sed 's/\(\.[0-9]*[1-9]\)0*/\1/')%" "${3}"
else
    __force_warn "File ${2} is not a PNG image and cannot be resized"
fi

}

###############################################################
# Composition functions
###############################################################
#
# __overlay <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Overlay Images
# Composites specified images, one on the other
# Same as src-over, but this is easier to remember
#
###############################################################

__overlay () {
__clip_src_over "${1}" "${2}" "${3}"
}

###############################################################
#
# __multiply <BASE.png> <OVERLAY_TO_MULTIPLY.png> <OUTPUT.png>
#
# Multiply Images
# Composites specified images, with a multiply blending method
#
###############################################################

__multiply () {
composite -define png:color-type=6 -compose Multiply "${2}" "${1}" "${3}"
}

###############################################################
#
# __screen <BASE.png> <OVERLAY_TO_SCREEN.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with a screen blending method
#
###############################################################

__screen () {
composite -define png:color-type=6 -compose Screen "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_src_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-over alpha blending
#
###############################################################

__clip_src_over () {
composite -define png:color-type=6 -compose src-over "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_dst_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-over alpha blending
#
###############################################################

__clip_dst_over () {
composite -define png:color-type=6 -compose dst-over "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_src_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-in alpha blending
#
###############################################################

__clip_src_in () {
composite -define png:color-type=6 -compose src-in "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_dst_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-in alpha blending
#
###############################################################

__clip_dst_in () {
composite -define png:color-type=6 -compose dst-in "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_src_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-out alpha blending
#
###############################################################

__clip_src_out () {
composite -define png:color-type=6 -compose src-out "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_dst_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-out alpha blending
#
###############################################################

__clip_dst_out () {
composite -define png:color-type=6 -compose dst-out "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_src_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-atop alpha blending
#
###############################################################

__clip_src_atop () {
composite -define png:color-type=6 -compose src-atop "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_dst_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-atop alpha blending
#
###############################################################

__clip_dst_atop () {
composite -define png:color-type=6 -compose dst-atop "${2}" "${1}" "${3}"
}

###############################################################
#
# __clip_xor <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with xor alpha blending
#
###############################################################

__clip_xor () {
composite -define png:color-type=6 -compose xor "${2}" "${1}" "${3}"
}

###############################################################
# Image manipulation functions
###############################################################
#
# __fade <INPUT> <OUTPUT> <AMOUNT>
#
# Fade image
# Makes an image transparent. Note that AMOUNT must be a value
# 0-1, 0 being fully transparent, 1 being unchanged
#
###############################################################

__fade () {
local __tmptrans=$(echo '1/'"${3}" | bc)
convert "${1}" -alpha set -channel Alpha -evaluate Divide "${__tmptrans}" -define png:color-type=6 "${2}"
}

###############################################################
#
# __tile <FILE> <GRID> <OUTPUT> <DIVIDER>
#
# Tile
# Tiles image at the specified grid size, with an optional
# divider width
#
###############################################################

__tile () {
if ! [ -z "${4}" ]; then
	local __spacer="${4}"
else
	local __spacer=0
fi

local __imgseq=$(for __tile in $(seq 1 "$(echo "${2}" | sed 's/x/\*/' | bc)"); do echo -n "${1} "; done)

montage -geometry "+${__spacer}+${__spacer}" -background none -tile "${2}" ${__imgseq} "${3}" 2> /dev/null

}

###############################################################
#
# __crop <INPUT> <RESOLUTION> <X-CORD> <Y-CORD> <OUTPUT>
#
# Crop
# Crops an image to the specified square
#
# Example:
# __crop image.png 128 2 1 out.png
#
# That will crop the image to the third square across and the
# second square down.
#
# Example:
# __crop image.png 512 0 0 out.png
#
# That will crop the top-left square, assuming a resolution of
# 512px
#
###############################################################

__crop () {
convert "${1}" -crop "${2}x${2}+$(echo "${3}*${2}" | bc)+$(echo "${4}*${2}" | bc)" "${5}"
}

###############################################################
#
# __rotate <IMAGE> <STEP>
#
# Rotate
# Rotates the image 0, 90, 180, 270, 360
# Give option +/- 0, 1, 2, 3 or 4
#
# 0 = 0 degrees
# 1, -3 = 90 degrees
# 2, -2 = 180 degrees
# 3, -1 = 270 degrees
# 4, -4 = 360 degrees
#
###############################################################

__rotate () {
case "${2}" in
	"0")
		local __angle="0"
		;;
	"1")
		local __angle="90"
		;;
	"2")
		local __angle="180"
		;;
	"3")
		local __angle="270"
		;;
	"4")
		local __angle="360"
		;;
	"-1")
		local __angle="270"
		;;
	"-2")
		local __angle="180"
		;;
	"-3")
		local __angle="90"
		;;
	"-4")
		local __angle="360"
		;;
esac

mogrify -rotate "${__angle}" "${1}"
}

###############################################################
#
# __shift <IMAGE> <PROPORTION>
#
# Shift
# Tiles an image vertically, then crops at the specified
# proportion. Equivalent to looping by shifting UP
#
###############################################################

__shift () {
__tile "${1}" 1x2 "${1}"_
mv "${1}"_ "${1}"
convert "${1}" -crop "$(identify -format "%wx%w" "${1}")+0+$(printf "%.0f" "$(echo "$(identify -format "%w" "${1}")*${2}" | bc)")" "${1}"_
mv "${1}"_ "${1}"
}

###############################################################
# Export functions
###############################################################
#
# Do this so that any child shells have these functions
###############################################################
for __function in $(compgen -A function); do
	export -f ${__function}
done
