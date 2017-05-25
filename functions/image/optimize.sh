################################################################################
# Optimizer Functions
################################################################################

################################################################################
#
# In all cases:
# __routine__optimize__<OPTIMIZER> <IMAGE.png>
#
# <OPTIMIZER> Optimize
# Accepts a PNG file as an input, optimizes with <OPTIMIZER> and
# replaces if smaller.
#
################################################################################

################################################################################
# Optipng
# with -nc set, it seems to be loaded perfectly by Minecraft, because the
# color_type is retained
################################################################################

__routine__optimize__optipng () {
local __tmpname="/tmp/${RANDOM})"
local __file="${1}"

optipng -strip all -nc -silent -force "${__file}" -out "${__tmpname}"

local __oldsize="$(stat "${__file}" -c %s)"
local __newsize="$(stat "${__tmpname}" -c %s)"

if [ "${__newsize}" -lt "${__oldsize}" ]; then
    mv "${__tmpname}" "${__file}"
else
    rm "${__tmpname}"
fi
}

################################################################################
# PNGCrush
# Should be be okay with -noreduce, but is stupid and changes it anyway, so it's
# checked for color_type correctness
################################################################################

__routine__optimize__pngcrush () {
local __tmpname="/tmp/${RANDOM})"
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

################################################################################
# Zopflipng
# Is stupid and won't let us specify a color_type to force, so
# we attempt to optimize anyway, then check the chunk, because
# Minecraft is stupid and won't load greyscale images correctly
################################################################################

__routine__optimize__zopflipng () {
local __tmpname="/tmp/${RANDOM})"
local __file="${1}"

zopflipng -q --always_zopflify "${__file}" "${__tmpname}" &> /dev/null

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

################################################################################
#
# __optimize <IMAGE.png>
#
# Optimize Image
# Accepts a PNG file as an input, optimizes with, and replaces if smaller. Will
# ignore if given file is not a '.png' file.
#
################################################################################

__optimize () {

local __prefix='optimize'

__choose_function -d 'optimization' -p 'optipng pngcrush zopflipng' "${__prefix}"

if ! __test_routine "${__prefix}"; then
    __force_warn "No valid optimizer is available, disabling optimization"
    export __no_optimize='1'
else

    if [ "$(__oext "${1}")" = 'png' ]; then
        __run_routine "${__prefix}" "${1}"
    else
        __force_warn "File \"${1}\" cannot be optimized."
    fi

fi

}
