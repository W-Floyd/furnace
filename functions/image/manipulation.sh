################################################################################
# Manipulation Functions
################################################################################

################################################################################
#
# __fade <INPUT> <OUTPUT> <AMOUNT>
#
# Fade image
# Makes an image transparent. Note that AMOUNT must be a value
# 0-1, 0 being fully transparent, 1 being unchanged
#
################################################################################

__fade () {
if ! [ "$(__strip_zero <<< "${3}")" = '1' ]; then

    local __tmptrans=$(echo '1/'"${3}" | bc)
    convert "${1}" -alpha set -channel Alpha -evaluate Divide "${__tmptrans}" $(__imagemagick_define) "${2}"

else

    cp "${1}" "${2}"

fi

}

################################################################################
#
# __tile <FILE> <GRID> <OUTPUT> <DIVIDER>
#
# Tile
# Tiles image at the specified grid size, with an optional
# divider width
#
################################################################################

__tile () {

if ! [ -z "${4}" ]; then
	local __spacer="${4}"
else
	local __spacer=0
fi

local __imgseq=$(for __tile in $(seq 1 "$(sed 's/x/\*/' <<< "${2}" | bc)"); do echo -n "${1} "; done)

# TODO - Find why Imagemagick throws warnings here about fonts.
# Example:
# montage: unable to read font `(null)' @ error/annotate.c/RenderFreetype/1388.
montage $(__imagemagick_define) -geometry "+${__spacer}+${__spacer}" -background none -tile "${2}" ${__imgseq} "${3}" 2> /dev/null

if ! [ -e "${3}" ]; then
    __force_warn "File \"${3}\" was not produced when tiling"
fi

}

################################################################################
#
# __custom_tile <FILE1> <FILE2> ... <GRID> <SPACER> <OUTPUT>
#
# Custom Tile
# Tiles images. Takes input files. Third last option is grid
# (e.g. '2x3'), second last is the spacer (e.g. '2'), last is
# the output image.
#
# Example:
# __custom_tile dirt.png grass.png plank.png plank.png 2x2 1 mash.png
#
################################################################################

__custom_tile () {

if [ "${#}" -lt '4' ]; then
    __error "Not enough options specified for __custom_tile"
fi

__num_sub () {
__option_num="$((__option_num-1))"
}

local __option_num="${#}"

local __output="${!__option_num}"
__num_sub
local __spacer="${!__option_num}"
__num_sub
local __grid="${!__option_num}"
__num_sub

local __imgseq="$(for __num in $(seq 1 "${__option_num}"); do echo -n "${!__num} "; done)"

montage $(__imagemagick_define) -geometry "+${__spacer}+${__spacer}" -background none -tile "${__grid}" ${__imgseq} "${__output}" 2> /dev/null

if ! [ -e "${__output}" ]; then
    __force_warn "File \"${__output}\" was not produced when custom tiling"
fi

}

################################################################################
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
################################################################################

__crop () {
convert $(__imagemagick_define) "${1}" -crop "${2}x${2}+$(bc <<< "${3}*${2}")+$(bc <<< "${4}*${2}")" "${5}"
}

################################################################################
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
################################################################################

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

mogrify $(__imagemagick_define) -rotate "${__angle}" "${1}"

}

################################################################################
#
# __rotate_exact <INPUT.png> <OUTPUT.png> <AMOUNT>
#
# Rotate Exact
# Rotates the image by the given amount, from 0 to 1.
#
# 0.0 = 0 degrees
# 0.5 = 180 degrees
# 1.0 = 360 degrees
################################################################################

__rotate_exact () {

convert -background none $(__imagemagick_define) -distort SRT "$(bc <<< "${3}*360")" "${1}" "${2}"

}

################################################################################
#
# __shift <IMAGE> <PROPORTION>
#
# Shift
# Tiles an image vertically, then crops at the specified
# proportion. Equivalent to looping by shifting UP
#
################################################################################

__shift () {
__tile "${1}" 1x2 "${1}"_
mv "${1}"_ "${1}"
convert $(__imagemagick_define) "${1}" -crop "$(identify -format "%wx%w" "${1}")+0+$(printf "%.0f" "$(echo "$(identify -format "%w" "${1}")*${2}" | bc)")" "${1}"_
mv "${1}"_ "${1}"
}
