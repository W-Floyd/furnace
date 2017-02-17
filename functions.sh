###############################################################
# Functions
###############################################################
#
# __mext <string>
#
# Minus Extension
# Strips last file extension from string
#
###############################################################

__mext () {
sed 's|\(.*\)\(\.\).*|\1|' <<< "${1}"
}

###############################################################
#
# __oext <string>
#
# Only Extension
# Returns the final extension of a filename
# Opposite of __mext
#
###############################################################

__oext () {
sed 's|\(.*\)\(\.\)\(.*\)|\3|' <<< "$1"
}

###############################################################
#
# __render <RES> <FILE.svg>
#
# Render Image
# Renders the specified .svg to a .png of the same name
#
###############################################################

__render () {
if [ -z "${__quick}" ]; then
    __quick='1'
    echo "__quick has not been set correctly. Defaulting to rsvg-convert."
fi
__dpi="$(echo "(96*${1})/128" | bc -l | rev | sed 's/0*//' | rev)"
if [ "${__quick}" = '1' ]; then
# GOD awful hack to catch svg size, TODO
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
# __optimize <IMAGE.png>
#
# Optimize Image
# Accepts a PNG file as an input, optimizes with optipng, and
# replaces if smaller. Will ignore if given file is not a
# '.png' file.
#
###############################################################

__optimize () {
if [ "$(__oext "${1}")" = 'png' ]; then
    optipng "${1}"
else
    echo "File ${1} cannot be optimized."
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
composite -define png:color-type=6 -compose src-over "${2}" "${1}" "${3}"
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
__tmptrans=$(echo '1/'"${3}" | bc)
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
	__spacer="${4}"
else
	__spacer=0
fi

__imgseq=$(for __tile in $(seq 1 "$(echo "${2}" | sed 's/x/\*/' | bc)"); do echo -n "${1} "; done)

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
		__angle="0"
		;;
	"1")
		__angle="90"
		;;
	"2")
		__angle="180"
		;;
	"3")
		__angle="270"
		;;
	"4")
		__angle="360"
		;;
	"-1")
		__angle="270"
		;;
	"-2")
		__angle="180"
		;;
	"-3")
		__angle="90"
		;;
	"-4")
		__angle="360"
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
# XML Functions
###############################################################
#
# __get_range <FILE> <FIELD_NAME>
#
# Get Range
# Gets the range/s in a <FILE> between each set of <FIELD_NAME>
#
#
# Example:
#
# __get_range catalogue.xml ITEM
#
# will print
#
# 2,10
# 11,19
# 20,28
# 31,39
#
###############################################################

# Slower optionally piped input version
#__get_range () {
#if ! [ "$#" = '1' ] && ! [ "$#" = '2' ]; then
#    echo "Incorrect number of options"
#    exit 1
#fi

#if read -t 0 && [ "$#" = '1' ]; then

#    __value="$(cat)"
#    __option="${1}"

#elif ! read -t 0 && [ "$#" = '2' ]; then

#    __value="$(cat "${1}")"
#    __option="${2}"

#fi

#echo "${__value}" | grep -n '[</|<]'"${__option}"'>' | sed 's/\:.*//' |  sed 'N;s/\n/,/'
#}

__get_range () {
grep -n '[</|<]'"${2}"'>' < "${1}" | sed 's/\:.*//' |  sed 'N;s/\n/,/'
}

###############################################################
#
# __read_range <FILE> <RANGE>
#
# Read Range
# Reads the <RANGE> from a <FILE>, as generated by __get_range
# Must be single line input.
#
###############################################################

# Slower optionally piped input version
#__read_range () {
#if ! [ "$#" = '1' ] && ! [ "$#" = '2' ]; then
#    echo "Incorrect number of options"
#    exit 1
#fi

#if read -t 0 && [ "$#" = '1' ]; then

#    __value="$(cat)"
#    __option="${1}"

#elif ! read -t 0 && [ "$#" = '2' ]; then

#    __value="$(cat "${1}")"
#    __option="${2}"

#fi

#echo "${__value}" | sed -e "${__option}"'!d' | sed -e 's/^	*//' -e 's/^ *//'
#}

__read_range () {
sed -e "${2}"'!d' "${1}" | sed -e 's/^	*//' -e 's/^ *//'
}

###############################################################
#
# __get_value <DATASET> <FIELD_NAME>
#
# Get Value
# Gets the value/s of <FIELD_NAME> from <DATASET>
# Meant to be used on separated data-sets
#
###############################################################


# Slower optionally piped input version
#__get_value () {
#if ! [ "$#" = '1' ] && ! [ "$#" = '2' ]; then
#    echo "Incorrect number of options"
#    exit 1
#fi

#if read -t 0 && [ "$#" = '1' ]; then

#    __value="$(cat)"
#    __option="${1}"

#elif ! read -t 0 && [ "$#" = '2' ]; then

#    __value="$(cat "${1}")"
#    __option="${2}"

#fi

#echo "${__value}" | pcregrep -M "<${__option}>(\n|.)*</${__option}>" - | sed -e 's/^<'"${__option}"'>//' -e 's/<\/'"${__option}"'>$//'
#}

__get_value () {
pcregrep -M "<${2}>(\n|.)*</${2}>" "${1}" | sed -e 's/^<'"${2}"'>//' -e 's/<\/'"${2}"'>$//'
}

###############################################################
#
# __set_value <DATASET> <FIELD_NAME> <VALUE>
#
# Set Value
# Sets the <VALUE> of the specified <FIELD_NAME>
#
# TODO
#
# Redo in a more efficient way.
#
###############################################################

__set_value () {
perl -i -pe "BEGIN{undef $/;} s#<${2}>.*</${2}>#<${2}>${3}</${2}>#sm" "${1}"
}

###############################################################
# Other stuff
###############################################################
#
# __emergency_exit
#
# Prints the last known command and exits, to be used when a
# command fails
#
# Example:
# cd "${__dir}" || __emergency_exit
#
###############################################################

__emergency_exit () {
echo "Last command run was ["!!"]"
exit 1
}

###############################################################
#
# __hash_folder <FILE> <EXCLUDEDIR>
#
# Hashes the current folder and outputs to <FILE>
# EXCLUDEDIR is optional (in the form of "xml", not "./xml/")
#
###############################################################

__hash_folder () {
if [ -z "${2}" ]; then
__listing="$(find . -type f)"
else
__listing="$(find . -not -path "./${2}/*" -type f)"
fi
if ! [ -z "${__listing}" ]; then
    md5sum ${__listing} > "${1}"
fi
}

###############################################################
#
# __check_hash_folder <FILE> <OUTPUT>
#
# Hashes the current folder and compares to <FILE>, outputting
# to <OUTPUT>
#
###############################################################

__check_hash_folder () {
md5sum -c "${1}" > "${2}"
}

###############################################################
#
# __pushd <DIR>
#
# Same as regular pushd, just quiet unless told not to be
#
###############################################################

__pushd () {
if [ -d "${1}" ]; then
    pushd "${1}" 1> /dev/null
else
    echo "Directory \"${1}\" does not exist!"
    exit 2
fi
}

###############################################################
#
# __popd
#
# Same as regular popd, just quiet unless told not to be
#
###############################################################

__popd () {
popd 1> /dev/null
}

###############################################################
#
# __strip_ansi
#
# Strips ANSI codes from *piped* input
#
###############################################################

__strip_ansi () {
cat | perl -pe 's/\e\[?.*?[\@-~]//g'
}

###############################################################
#
# __print_pad
#
# Prints the given number of spaces
#
###############################################################

__print_pad () {
    seq 1 "${1}" | while read -r __line; do
        echo -n ' '
    done
}

###############################################################
#
# __format_text <LEADER> <TEXT> <TRAILER>
#
# Pads text to a set length, so multiline warnings, info and
# errors can be made
###############################################################

__format_text () {
echo -ne "${1}"
__desired_size='10'
__leader_size="$(echo -ne "${1}" | __strip_ansi | wc -m)"
__clipped_size=$((__desired_size-__leader_size-3))
__front_pad="$(__print_pad "${__clipped_size}") - "
echo -ne "${__front_pad}"
__pad=''
if [ "$(echo "${2}" | wc -l)" -gt '1' ]; then
    echo "${2}" | head -n -1 | while read -r __line; do
        if [ -z "${__pad}" ]; then
            echo -e "${__pad}${__line}"
            __pad="$(__print_pad "${__desired_size}")"
        else
            echo -e "${__pad}${__line}"
        fi
    done
    __pad="$(__print_pad "${__desired_size}")"
    echo -e "${__pad}$(echo "${2}" | tail -n 1)${3}"
else
    echo -e "${2}${3}"
fi
}

###############################################################
#
# __force_announce <MESSAGE>
#
# Announce
# Echos a statement
#
###############################################################

__force_announce () {
if ! [ "${__name_only}" = '1' ]; then
    __format_text "\e[32mInfo\e[39m" "${1}" ""
fi
}

###############################################################
#
# __announce <MESSAGE>
#
# Announce
# Echos a statement, only if __verbose is equal to 1
#
###############################################################

__announce () {
if [ "${__time}" = '0' ]; then
if [ "${__verbose}" = '1' ]; then
    __force_announce "${1}"
fi
fi
}

###############################################################
#
# __force_warn <MESSAGE>
#
# Warn
# Echos a statement when something has gone wrong
#
###############################################################

__force_warn () {
if ! [ "${__name_only}" = '1' ]; then
    __format_text "\e[93mWarning\e[39m" "${1}" ", continuing anyway." 1>&2
fi
}

###############################################################
#
# __warn <MESSAGE>
#
# Warn
# Echos a statement when something has gone wrong, to be used
# when it is tolerable.
#
###############################################################

__warn () {
if [ "${__very_verbose}" = '1' ] || [ "${__should_warn}" = '1' ]; then
if ! [ "${__name_only}" = '1' ]; then
    __force_warn "${@}"
fi
fi
}

###############################################################
#
# __custom_error <MESSAGE>
#
# Custom Error
# Echos an error statement without quiting
#
###############################################################

__custom_error () {
__format_text "\e[31mError\e[39m" "${1}" ", exiting." 1>&2
}

###############################################################
#
# __error <MESSAGE>
#
# Error
# Echos a statement when something has gone wrong, then exits
#
###############################################################

__error () {
__custom_error "${1}"
exit 1
}

###############################################################
#
# __time <MESSAGE> <start/end>
#
# Time
# Times between two occurrences of the function, as set by start
# or end.
#
###############################################################

__time () {
__message="$(echo "${1}" | md5sum | sed 's/ .*//')"

if [ "${2}" = 'start' ]; then
    export "__function_start_time${__message}"="$(date +%s.%N)"
elif [ "${2}" = 'end' ]; then
    export "__function_end_time${__message}"="$(date +%s.%N)"
fi

if ! [ "${__name_only}" = '1' ] && [ "${__time}" = '1' ]; then
    if [ -z "${2}" ]; then
        __force_warn "No input to __time function, disabling timer."
        __time='0'
    else

        if [ "${2}" = 'end' ]; then
            __force_announce "${1} in $(echo "$(eval 'echo '"\$__function_end_time${__message}"'')-$(eval 'echo '"\$__function_start_time${__message}"'')" | bc) seconds"
        elif ! [ "${2}" = 'start' ]; then
            __force_warn "Invalid input to __time, disabling timer."
            __time='0'
        fi

    fi
fi
}

###############################################################
#
# __log2 <NUMBER>
#
# Log base 2
# Finds the log2 of a number, or rounds up to the next power of
# 2
#
# Shamelessly stolen from:
# https://bobcopeland.com/blog/2010/09/log2-in-bash/
#
###############################################################

__log2 () {
    local x=0
    for (( y=$1-1 ; $y > 0; y >>= 1 )) ; do
        let x=$x+1
    done
    echo $x
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
