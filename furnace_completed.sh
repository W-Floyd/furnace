#!/bin/bash

__un_named='0'

__catalogue="/tmp/${__name}_catalogue"

__clean_pack < "${1}" > "${__catalogue}"

for __range in $(__get_range "${__catalogue}" ITEM); do

    __read_range "${__catalogue}" "${__range}" > "/tmp/readrangetmp"

    touch "/tmp/readrangetmp" "/tmp/commontmp" "/tmp/nametmp"

    if [ "$(__get_value "/tmp/readrangetmp" KEEP)" = 'YES' ]; then

        __common="$(__get_value "/tmp/readrangetmp" COMMON)"

        if ! [ -z "${__common}" ]; then
            echo "${__common}" >> "/tmp/commontmp"
        else
            __get_value "/tmp/readrangetmp" NAME >> "/tmp/nametmp"
            __un_named="$(bc <<< "${__un_named}+1")"
        fi
    fi

done

echo "Completed features are:

$(sort "/tmp/commontmp" | uniq)

as well as ${__un_named} un-named items, with raw values:

$(sort "/tmp/nametmp")"

rm "/tmp/readrangetmp" "/tmp/commontmp" "/tmp/nametmp" "${__catalogue}"

exit
