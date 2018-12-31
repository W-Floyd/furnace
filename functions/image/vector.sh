################################################################################
# Vector Render Functions
################################################################################

################################################################################
#
# In all cases:
# __vector_render_<ENGINE> <RES> <FILE.svg>
#
# <ENGINE> Render
# Accepts a SVG file as an input, processes with <ENGINE>.
#
################################################################################

__routine__vector_render__inkscape() {

    local __dpi="$(echo "(${__vector_ppi}*${1})/${__vector_scale}" | bc -l | sed 's/0*$//')"

    inkscape \
        --export-dpi="${__dpi}" \
        --export-png "$(__mext "${2}").png" "${2}" 1> /dev/null

}

__routine__vector_render__rsvg-convert() {

    rsvg-convert \
        -z "$(bc -l <<< "${1}/${__vector_scale}" | __strip_zero)" \
        -a \
        "${2}" \
        -o "$(__mext "${2}").png" 1> /dev/null

}

__routine__vector_render__convert() {

    local __dpi="$(echo "(${__vector_ppi}*${1})/${__vector_scale}" | bc -l | sed 's/0*$//')"

    convert \
        $(__imagemagick_define) \
        -background none \
        -density "${__dpi}" \
        "${2}" \
        "$(__mext "${2}").png"

}

################################################################################
#
# __vector_render <RES> <FILE.svg>
#
# Render Vector Image
# Renders the specified .svg to a .png of the same name
#
################################################################################

__vector_render() {

    if ! [ "$(__oext "${2}")" = 'svg' ]; then
        __error "File \"${2}\" is not an svg file"
    fi

    if [ -z "${__vector_ppi}" ]; then
        export __vector_ppi='96'
    fi

    if [ -z "${__vector_scale}" ]; then
        export __vector_scale='128'
    fi

    __short_routine 'vector_render' 'vector rendering' 'rsvg-convert inkscape convert' "${1}" "${2}"

    if ! [ -e "$(__mext "${2}").png" ]; then
        __force_warn "File \"$(__mext "${2}").png\" was not rendered"
        return 1
    else

        convert "$(__mext "${2}").png" $(__imagemagick_define) "$(__mext "${2}")_.png"
        mv "$(__mext "${2}")_.png" "$(__mext "${2}").png"

    fi

}
