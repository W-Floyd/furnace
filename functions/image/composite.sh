################################################################################
# Composition Functions
################################################################################

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
__clip_src_over ${@}
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
composite $(__imagemagick_define) -compose Multiply "${2}" "${1}" "${3}"
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
composite $(__imagemagick_define) -compose Screen "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_src_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-over alpha blending
#
################################################################################

__clip_src_over () {
composite $(__imagemagick_define) -compose src-over "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_dst_over <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-over alpha blending
#
################################################################################

__clip_dst_over () {
composite $(__imagemagick_define) -compose dst-over "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_src_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-in alpha blending
#
################################################################################

__clip_src_in () {
composite $(__imagemagick_define) -compose src-in "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_dst_in <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-in alpha blending
#
################################################################################

__clip_dst_in () {
composite $(__imagemagick_define) -compose dst-in "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_src_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-out alpha blending
#
################################################################################

__clip_src_out () {
composite $(__imagemagick_define) -compose src-out "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_dst_out <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-out alpha blending
#
################################################################################

__clip_dst_out () {
composite $(__imagemagick_define) -compose dst-out "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_src_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with src-atop alpha blending
#
################################################################################

__clip_src_atop () {
composite $(__imagemagick_define) -compose src-atop "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_dst_atop <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with dst-atop alpha blending
#
################################################################################

__clip_dst_atop () {
composite $(__imagemagick_define) -compose dst-atop "${2}" "${1}" "${3}"
}

################################################################################
#
# __clip_xor <BASE.png> <OVERLAY.png> <OUTPUT.png>
#
# Screen Images
# Composites specified images, with xor alpha blending
#
################################################################################

__clip_xor () {
composite $(__imagemagick_define) -compose xor "${2}" "${1}" "${3}"
}
