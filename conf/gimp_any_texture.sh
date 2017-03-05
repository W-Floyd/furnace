#!/bin/bash

# gimp_any_texture <SIZE> <NATIVESIZE> <IMAGE>

__gimp_export "${3}.xcf"

__resize "$(echo "${1}/${2}" | bc -l | sed 's/\(\.[0-9]*[1-9]\)0*/\1/')" "./${3}.png" "./${3}_.png"

mv "./${3}_.png" "./${3}.png"

exit
