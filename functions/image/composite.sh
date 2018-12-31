################################################################################
# Composition Functions
################################################################################

################################################################################
#
# __composite_common <METHOD> <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, using specified blending method (eg. 'Multiply').
#
################################################################################

__composite_common() {
    composite $(__imagemagick_define) -compose "${1}" "${3}" "${2}" "${4}"
}

__routine__image_overlay__composite() {
    __routine__image_src_over__composite "${@}"
}

__routine__image_multiply__composite() {
    __composite_common Multiply "${@}"
}

__routine__image_screen__composite() {
    __composite_common Screen "${@}"
}

__routine__image_src_over__composite() {
    __composite_common src-over "${@}"
}

__routine__image_dst_over__composite() {
    __composite_common dst-over "${@}"
}

__routine__image_src_in__composite() {
    __composite_common src-in "${@}"
}

__routine__image_dst_in__composite() {
    __composite_common dst-in "${@}"
}

__routine__image_src_out__composite() {
    __composite_common src-out "${@}"
}

__routine__image_dst_out__composite() {
    __composite_common dst-out "${@}"
}

__routine__image_src_atop__composite() {
    __composite_common src-atop "${@}"
}

__routine__image_dst_atop__composite() {
    __composite_common dst-atop "${@}"
}

__routine__image_xor__composite() {
    __composite_common xor "${@}"
}

################################################################################
#
# __composite_manager <METHOD> <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Manager
# Manages composite routine running.
#
################################################################################

__composite_manager() {

    local __first="${1}"

    shift

    __short_routine "$(sed 's/-/_/g' <<< "image_${__first}")" "compositing (${__first})" 'composite' "${@}"

}

################################################################################
#
# __overlay <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Overlay Images
# Composites specified images, one on the other
# Same as src-over, but this is easier to remember
#
################################################################################

__overlay() {

    __composite_manager overlay "${@}"

}

################################################################################
#
# __multiply <BASE.png> <OVERLAY_TO_MULTIPLY.png> <OUTPUT.png>
#
# Multiply Images
# Composites specified images, with a multiply blending method
#
################################################################################

__multiply() {

    __composite_manager multiply "${@}"

}

################################################################################
#
# __screen <BASE.png> <OVERLAY_TO_SCREEN.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with a screen blending method
#
################################################################################

__screen() {

    __composite_manager screen "${@}"

}

################################################################################
#
# __multiscreen <BASE.png> <OVERLAY_TO_SCREEN_&_MULTIPLY.png> <OUTPUT.png>
#
# Multiply and Screen
# Chains __multiply and __screen in that order
#
################################################################################

__multiscreen() {

    local __tmp="$(__mext "${3}")_.$(__oext "${3}")"

    __multiply "${1}" "${2}" "${__tmp}"

    __screen "${__tmp}" "${2}" "${3}"

    rm "${__tmp}"

}

################################################################################
#
# __clip_src_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-over alpha blending
#
################################################################################

__clip_src_over() {

    __composite_manager src-over "${@}"

}

################################################################################
#
# __clip_dst_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-over alpha blending
#
################################################################################

__clip_dst_over() {

    __composite_manager dst-over "${@}"

}

################################################################################
#
# __clip_src_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-in alpha blending
#
################################################################################

__clip_src_in() {

    __composite_manager src-in "${@}"

}

################################################################################
#
# __clip_dst_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-in alpha blending
#
################################################################################

__clip_dst_in() {

    __composite_manager dst-in "${@}"

}

################################################################################
#
# __clip_src_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-out alpha blending
#
################################################################################

__clip_src_out() {

    __composite_manager src-out "${@}"

}

################################################################################
#
# __clip_dst_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-out alpha blending
#
################################################################################

__clip_dst_out() {

    __composite_manager dst-out "${@}"

}

################################################################################
#
# __clip_src_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-atop alpha blending
#
################################################################################

__clip_src_atop() {

    __composite_manager src-atop "${@}"

}

################################################################################
#
# __clip_dst_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-atop alpha blending
#
################################################################################

__clip_dst_atop() {

    __composite_manager dst-atop "${@}"

}

################################################################################
#
# __clip_xor <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with xor alpha blending
#
################################################################################

__clip_xor() {

    __composite_manager xor "${@}"

}

################################################################################
#
# __stack <OUTPUT> <LAYER_1> <LAYER_2> <LAYER_3> ...
#
# Stack
# Stacks images (last is top), outputing to first option.
#
################################################################################

__routine__image_stack__convert() {

    local __output="${1}"

    shift

    convert -background none $(__imagemagick_define) "${@}" -flatten "${__output}"

}

__stack() {

    __short_routine 'image_stack' 'image stacking' 'convert' "${@}"

}
