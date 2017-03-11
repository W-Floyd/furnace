#!/bin/bash

# vector_any_texture.sh <SIZE> <FILE> <BG_COLOUR>
#                                    |  optional |

__vector_render "${1}" "${2}.svg"

if ! [ -z "${3}" ]; then
    convert -size "${1}x${1}" "canvas:${3}" "${2}_.png"
    __overlay "${2}_.png" "${2}.png" "${2}__.png"
    rm "${2}_.png"
    mv "${2}__.png" "${2}.png"
fi

exit
