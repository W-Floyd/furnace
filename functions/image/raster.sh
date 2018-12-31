################################################################################
# Raster Render Functions
################################################################################

################################################################################
#
# __gimp_export <FILE.xcf>
#
# GIMP Export
# Exports a given GIMP file to a PNG file of the same name
#
# Shamelessly stolen from
# http://stackoverflow.com/a/5846727/7578643
# and wrapped up as a function.
#
################################################################################

__routine__image_gimp_export__gimp() {

    __gimp_sub() {
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
    # it's made silent. Bad idea, I know...
    __gimp_sub "${1}" &> /dev/null

    __image_conform "$(__mext "${1}").png"

}

__gimp_export() {

    if ! [ "$(__oext "${1}")" = 'xcf' ]; then
        __error "File \"${1}\" is not a GIMP file"
    fi

    __short_routine 'image_gimp_export' 'Gimp exporting' 'gimp' "${1}"

}

################################################################################
#
# __krita_export <FILE.kra>
#
# Krita Export
# Exports a given Krita file to a PNG file of the same name
#
################################################################################

__routine__image_krita_export__krita() {

    # My instance of Krita throws some errors no matter what, so
    # it's made silent. Bad idea, I know...
    # TODO - Find out why Krita is throwing warnings.
    krita --export --export-filename "$(__mext "${1}").png" "${1}" &> /dev/null

    __image_conform "$(__mext "${1}").png"

}

__krita_export() {

    if ! [ "$(__oext "${1}")" = 'kra' ]; then
        __error "File \"${1}\" is not a Krita file"
    fi

    __short_routine 'image_krita_export' 'Krita exporting' 'krita' "${1}"

}
