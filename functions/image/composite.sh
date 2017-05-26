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

__composite_common () {
composite $(__imagemagick_define) -compose "${1}" "${3}" "${2}" "${4}"
}

__routine__image_overlay__composite () {
__routine__image_src_over__composite ${@}
}

__routine__image_multiply__composite () {
__composite_common Multiply $@
}

__routine__image_screen__composite () {
__composite_common Screen $@
}

__routine__image_src_over__composite () {
__composite_common src-over $@
}

__routine__image_dst_over__composite () {
__composite_common dst-over $@
}

__routine__image_src_in__composite () {
__composite_common src-in $@
}

__routine__image_dst_in__composite () {
__composite_common dst-in $@
}

__routine__image_src_out__composite () {
__composite_common src-out $@
}

__routine__image_dst_out__composite () {
__composite_common dst-out $@
}

__routine__image_src_atop__composite () {
__composite_common src-atop $@
}

__routine__image_dst_atop__composite () {
__composite_common dst-atop $@
}

__routine__image_xor__composite () {
__composite_common xor $@
}

################################################################################
#
# __composite_manager <METHOD> <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Manager
# Manages composite routine running.
#
################################################################################

__composite_manager () {
local __prefix="$(sed 's/-/_/g' <<< "image_${1}")"

__choose_function -e -d "compositing (${1})" -p 'composite' "${__prefix}"

shift

__run_routine "${__prefix}" "${1}" "${2}" "${3}"
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

__overlay () {

__composite_manager overlay $@

}

################################################################################
#
# __multiply <BASE.png> <OVERLAY_TO_MULTIPLY.png> <OUTPUT.png>
#
# Multiply Images
# Composites specified images, with a multiply blending method
#
################################################################################

__multiply () {

__composite_manager multiply $@

}

################################################################################
#
# __screen <BASE.png> <OVERLAY_TO_SCREEN.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with a screen blending method
#
################################################################################

__screen () {

__composite_manager screen $@

}

################################################################################
#
# __clip_src_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-over alpha blending
#
################################################################################

__clip_src_over () {

__composite_manager src-over $@

}

################################################################################
#
# __clip_dst_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-over alpha blending
#
################################################################################

__clip_dst_over () {

__composite_manager dst-over $@

}

################################################################################
#
# __clip_src_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-in alpha blending
#
################################################################################

__clip_src_in () {

__composite_manager src-in $@

}

################################################################################
#
# __clip_dst_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-in alpha blending
#
################################################################################

__clip_dst_in () {

__composite_manager dst-in $@

}

################################################################################
#
# __clip_src_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-out alpha blending
#
################################################################################

__clip_src_out () {

__composite_manager src-out $@

}

################################################################################
#
# __clip_dst_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-out alpha blending
#
################################################################################

__clip_dst_out () {

__composite_manager dst-out $@

}

################################################################################
#
# __clip_src_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with src-atop alpha blending
#
################################################################################

__clip_src_atop () {

__composite_manager src-atop $@

}

################################################################################
#
# __clip_dst_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with dst-atop alpha blending
#
################################################################################

__clip_dst_atop () {

__composite_manager dst-atop $@

}

################################################################################
#
# __clip_xor <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Composite Images
# Composites specified images, with xor alpha blending
#
################################################################################

__clip_xor () {

__composite_manager xor $@

}
