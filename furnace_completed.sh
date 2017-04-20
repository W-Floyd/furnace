#!/bin/bash

__un_named='0'
__catalogue="${1}"

__clean_pack < "${__catalogue}" > "/tmp/texpackcatalogue"

for __range in $(__get_range "/tmp/texpackcatalogue" ITEM); do

__read_range "/tmp/texpackcatalogue" "${__range}" > "/tmp/readrangetmp"

touch "/tmp/readrangetmp" "/tmp/commontmp" "/tmp/nametmp"

if [ "$(__get_value "/tmp/readrangetmp" KEEP)" = 'YES' ]; then

	__common="$(__get_value "/tmp/readrangetmp" COMMON)"

	if ! [ -z "${__common}" ]; then
	    echo "${__common}" >> "/tmp/commontmp"
	else
	    __get_value "/tmp/readrangetmp" NAME >> "/tmp/nametmp"
	    __un_named="$(echo "${__un_named}+1" | bc)"
	fi
fi

done

echo "Completed features are:

$(sort "/tmp/commontmp" | uniq)

as well as ${__un_named} un-named items, with raw values:

$(sort "/tmp/nametmp")"

rm "/tmp/readrangetmp" "/tmp/commontmp" "/tmp/nametmp" "/tmp/texpackcatalogue"

exit
