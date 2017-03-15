#!/bin/bash

# gimp_any_texture <SIZE> <NATIVESIZE> <IMAGE>

__gimp_export "${3}.xcf"

if ! [ "${1}" = "${2}" ]; then

    __resize "$(echo "${1}/${2}" | bc -l | __stip_zero)" "./${3}.png" "./${3}_.png"

    mv "./${3}_.png" "./${3}.png"

fi

exit
