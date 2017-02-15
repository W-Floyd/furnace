#!/bin/bash

###############################
# Defaults
###############################

__smelt_functions_bin='/usr/share/smelt/smelt_functions.sh'

__size='128'
__verbose='0'
__very_verbose='0'
__force='0'
__re_use_xml='0'
export __pid="$$"
__debug='0'
__xml_only='0'
__name_only='0'
__mobile='0'
__time='0'
__should_warn='0'
__dry='0'

###############################################################
# Setting up functions
###############################################################

# get functions from file
source "${__smelt_functions_bin}" &> /dev/null || { echo "Failed to load functions '${__smelt_functions_bin}'"; exit 1; }

# temporary timer for quick timing
__time_var='temporary timer'
__tmp_time () {
__time "${__time_var}" "${1}"
}

# print help
__usage () {
echo "$0 <OPTIONS> <SIZE>

Renders the texture pack at the specified size (or default 128)
Order of options and size are not important.

Options:
  -h  --help  -?        This help message
  -f  --force           Discard pre-rendered data
  -v  --verbose         Verbose
  -p  --process-id      Using PID as given after
  -d  --debug           Debugging mode
  -l  --lengthy         Very verbose debugging mode
  -x  --xml-only        Only process xml files
  -n  --name-only       Print output folder name
  -m  --mobile          Make mobile resource pack
  -s  --slow            Use slower render engine (Inkscape)
  -q  --quick           Use quicker render engine (rsvg-convert)
  -t  --time            Time operations (for debugging)
  -w  --warn            Show warnings\
"
}

__start_debugging () {
    PS4='Line ${LINENO}: '
    set -x
}

###############################################################
# Set variables from config
###############################################################

# Master folder
__working_dir="$(pwd)"

if ! [ -e 'config.sh' ]; then
    __warn "No config file was found, using default values"
else
    source 'config.sh' || __error "Config file has an error"
fi

###############################################################
# Read options
__time "Read options" start
###############################################################

# If there are are options,
if ! [ "${#}" = 0 ]; then

# then let's look at them in sequence.
while ! [ "${#}" = '0' ]; do

# So, let's say the last given option was
    case "${__last_option}" in

# to use a special PID.
        "-p" | "--process-id")

# So, if it's a number,
            if [ "${1}" -eq "${1}" ] 2>/dev/null; then

# set the PID to this
                export __pid="${1}"

# If it isn't though,
            else

# warn the user and exit, because they're doing it wrong.
                __usage
                __error "Invalid process ID \"${1}\""
            fi
            ;;

# Now, with the option to the last option out of the way, let's
# look at regular options.
        *)

# So, again, if the options matches any of these:
            case "${1}" in

# help the user out if they ask and exit nicely,
                "-h" | "--help" | "-?")
                    __usage
                    exit 0
                    ;;

# let the script and user know it should and will force rendering,
                "-f" | "--force")
                    __force='1'
                    __force_warn "Discarding pre-rendered data"
                    ;;

# tell the script to be verbose,
                "-v" | "--verbose")
                    __verbose='1'
                    ;;

# tell the script to be very verbose,
                "-l" | "--lengthy")
                    __verbose='1'
                    __very_verbose='1'
                    __start_debugging
                    ;;

# tell the script to use a specified PID (this is taken care of
# earlier) using the last option which is set later,
                "-p" | "--process-id")
                    ;;

# make the script be verbose and not clean up,
                "-d" | "--debug")
                    __force_announce "Debugging mode enabled"
                    __debug='1'
                    __verbose='1'
# If we're supposed to be in debugging mode and be very verbose
                    if [ "${__debug}" = '1' ]; then
                        if [ "${__very_verbose}" = '1' ]; then
                            __start_debugging
                        fi
                    fi
                    ;;

# only process xml files
                "-x" | "--xml-only")
                    __force_announce "Only processing xml files"
                    __xml_only='1'
                    ;;

# Whether or not to just print the exported folder name
                "-n" | "--name-only")
                    __name_only='1'
                    ;;

# whether to make mobile reousource pack
                "-m" | "--mobile")
                    __mobile='1'
                    ;;

# whether to use quick render engine
                "-s" | "--slow")
                    export __quick='0'
                    ;;

# whether to use quick render engine
                "-q" | "--quick")
                    export __quick='1'
                    ;;

# whether to time functions
                "-t" | "--time")
                    __time='1'
                    ;;

# whether to warn
                "-w" | "--warn")
                    __should_warn='1'
                    ;;

# hidden option to do a dry run (to test options and output)
                "--dry")
                    __dry='1'
                    ;;

# general catch all for any number input that isn't for the PID
# which is set as the render size,
                [0-9]*)
                    __size="${1}"
                    ;;

# any other options are invalid so the script says what it was
# and exits after telling you how to use it.
	            *)
	                __usage
                    __error "Unknown option \"${1}\""
                    ;;

# We're done with single flag options
            esac
            ;;

# We're done with 2 flag options
    esac

# Let the script know what the last option was, for use in two
# flag options
    __last_option="${1}"

# Make option 2 option 1, so we can loop through nicely
    shift

# Done with option loop and if statement
done
fi

__time "Read options" end

__time "Set variables" start

###############################################################
# Fill the blanks that the config didn't fill
###############################################################

if [ -z "${__name}" ]; then
    __name="$(basename "${__working_dir}")"
    __force_warn "Pack name not defined, defaulting to ${__name}"
fi

if [ -z "${__tmp_dir}" ]; then
    __tmp_dir="/tmp/texpack${__pid}"
else
    __warn "Using custom tempory directory '${__tmp_dir}'"
fi

# Location of catalogue file
if [ -z "${__catalogue}" ]; then
    __catalogue='catalogue.xml'
    if ! [ -e "${__catalogue}" ]; then
        __error "Catalogue '${__catalogue}' is missing"
    fi
else
    if ! [ -e "${__catalogue}" ]; then
        __error "Custom catalogue '${__catalogue}' is missing"
    fi
fi

if ! [ -e "${__catalogue}" ]; then
    __error "Missing catalogue"
fi

if [ -z "${__quick}" ]; then
    __warn "Quick/Slow mode not set, defaulting to quick"
    export __quick='1'
fi

# Rendered folder name
__pack="${__name}-${__size}px"

# if we're supossed to make a mobile pack,
if [ "${__mobile}" = '1' ]; then

# set a special end pack folder
    __pack_end="${__pack}_mobile"

# otherwise
else

# set the end pack name the same as normal
    __pack_end="${__pack}"

# end mobile if statement
fi

# if we're only supposed to print the pack name
if [ "${__name_only}" = '1' ]; then

# print the pack end pack folder name
    echo "${__pack_end}"

# and exit
    exit

# exit the name only if statement
fi

###############################################################
# Check software deps
###############################################################

# check tsort
if ! which tsort &> /dev/null; then
    __error "Please install 'tsort' to continue. It is required for dependency resolution"
fi

# check inkscape
if which inkscape &> /dev/null; then
    __has_inkscape='1'

else
    __has_inkscape='0'
fi

# ceck rsvg-convert
if which rsvg-convert &> /dev/null; then
    __has_rsvg_convert='1'

# if that did return an error, we know it doesn't exist
else
    __has_rsvg_convert='0'
fi

# if both inkscape and rsvg-convert don't exist, say so and exit
if [ "${__has_inkscape}" = '0' ] && [ "${__has_rsvg_convert}" = '0' ]; then
    echo "Missing both inkscape and rsvg-convert. Please install either/both to continue."
    echo "Please install 'librsvg-devel' to obtain rsvg-convert, and 'inkscape' for Inkscape"
    exit 1

# if inkscape exists, but rsvg-convert doesn't exist, and we're
# wanting to use rsvg-convert, say so and force inkscape
elif [ "${__has_inkscape}" = '1' ] && [ "${__has_rsvg_convert}" = '0' ] && [ "${__quick}" = '1' ]; then
    __warn "Missing rsvg-convert. Cannot continue in quick mode.
Please install 'librsvg-devel', defaulting to inkscape"
    export __quick='0'

# if rsvg-convert exists, but inkscape doesn't exist, and we're
# wanting to use inkscape, say so and force rsvg-convert
elif [ "${__has_inkscape}" = '0' ] && [ "${__has_rsvg_convert}" = '1' ] && [ "${__quick}" = '0' ]; then
    echo "Missing Inkscape. Must continue in quick mode."
    echo "Please install 'inkscape'. Defaulting to rsvg-convert."
    export __quick='1'
fi

__time "Set variables" end

if [ "${__dry}" = '1' ]; then
    exit
fi

###############################################################
# If not only doing xml
if [ "${__xml_only}" = '0' ]; then

__time "Set up folders" start

###############################################################
# Announce size
__announce "Using size ${__size}px."
###############################################################
# Announce PID
__announce "Using PID ${__pid}."
###############################################################

###############################################################
# Announce mobile if set on
if [ "${__mobile}" = '1' ]; then

    __announce "Making mobile resource pack."

fi
###############################################################

###############################################################
# Set up folders
__announce "Setting up folders."
###############################################################

# End conditional if only doing xml processing
fi

# Clean out the temporary directory if need be
if [ -d "${__tmp_dir}" ]; then
    rm -r "${__tmp_dir}"
fi

# Make the temporary directory
mkdir -p "${__tmp_dir}"

###############################################################
# If not only doing xml
if [ "${__xml_only}" = '0' ]; then

# If the pack folder already exists, then
if [ -d "${__pack}" ]; then

# If we must remove it
    if [ "${__force}" = 1 ]; then

# Announce and remove it
        __announce "Purging rendered data."
        rm -r "${__pack}"
        mkdir -p "${__pack}/xml"

# Otherwise, re-use rendered data
    else
        __announce "Re-using rendered data."
    fi

# Otherwise, make the pack and xml folder
else
    mkdir -p "${__pack}/xml"
fi

__time "Set up folders" end

# End conditional if only doing xml processing
fi

###############################################################
# Split XML
###############################################################

__time "Split XML" start

__tsort_file='tsort'

__dep_list_tsort="${__tmp_dir}/${__tsort_file}"

__dep_list_name='tmp_deps'
__dep_list_folder="${__tmp_dir}/${__dep_list_name}"

__cleanup_file='cleanup'

__cleanup_all="${__tmp_dir}/${__cleanup_file}"
touch "${__cleanup_all}"

# if the xml folder does not exist,
if ! [ -d ./src/xml/ ]; then

# make the xml folder
    mkdir ./src/xml/

# end the xml folder if statement
fi

# get into the xml folder
__pushd ./src/xml

# if the catalogue exists
if [ -e "${__catalogue}" ]; then

# get the md5sum hash of the catalogue
    __old_catalogue_hash="$(md5sum "${__catalogue}")"

# remove the catalogue
    rm "${__catalogue}"

# end the if statement if the catalogue exists
fi

# get back into the main directory
__popd

# md5sum hash the current catalogue
__new_catalogue_hash="$(md5sum "${__catalogue}")"

# if the new catalogue is the same as the old catalogue, then
if [ "${__old_catalogue_hash}" = "${__new_catalogue_hash}" ] && [ -e "./src/xml/${__tsort_file}" ] && [ -d "./src/xml/${__dep_list_name}" ] && [ -e "./src/xml/${__cleanup_file}" ]; then

# say so
    __announce "No changes to xml catalogue."

# tell the script to re-use the xml files
    __re_use_xml='1'

# make sure tsort file exists
    mv "./src/xml/${__tsort_file}" "${__dep_list_tsort}"

    mv "./src/xml/${__dep_list_name}" "${__tmp_dir}"

    mv "./src/xml/${__cleanup_file}" "${__cleanup_all}"

# end if statement whether the catalogues are the same
fi

# If we're told not to re-use xml, then
if [ "${__re_use_xml}" = '0' ]; then

__announce "Splitting XML files."

# Where current xml files are split off to temporarily
__xml_current="${__tmp_dir}/xml_current"

# For every ITEM in catalogue,
for __range in $(__get_range "${__catalogue}" ITEM); do

# File to use for reading ranges
    __read_range_file="${__tmp_dir}/${__range}"

# Actually read the range into file. This now contains an ITEM.
    __read_range "${__catalogue}" "${__range}" > "${__read_range_file}"

# TODO
# Optimize xml functions more
# Currently way too slow (though better than before)

# Get the NAME of this ITEM
    __item_name="$(__get_value "${__read_range_file}" NAME)"

# Make the correct directory for dumping the xml into an
# appropriately named file
    mkdir -p "$(__odir "${__xml_current}/${__item_name}")"

# Move that temporary read range file from before to somewhere
# more useful, according to the item's name
    mv "${__read_range_file}" "${__xml_current}/${__item_name}"

# Finish loop, but don't block the loop until it finishes
done

# If xml files currently exist, and we're not told to re-use
# them, delete them and move new xml in
if [ -d './src/xml/' ]; then
    rm -r './src/xml/'
fi

# Move xml into src now, so it can be used later
mv "${__xml_current}" './src/xml/'

__time "Split XML" end

###############################################################
# Inherit deps and cleanup
__announce "Inheriting and creating dependencies and cleanup files."
###############################################################

# End if statement whether to split xml again or not
fi

# Get into the xml directory
__pushd ./src/xml/

__list_file="${__tmp_dir}/listing_complete"
touch "${__list_file}"

find . -type f > "${__list_file}"

# Go back to the regular directory
__popd

# If we're told not to re-use xml, then
if [ "${__re_use_xml}" = '0' ]; then

__time "Inherited and created dependencies" start

if [ -e "${__dep_list_tsort}" ]; then
    rm "${__dep_list_tsort}"
fi
touch "${__dep_list_tsort}"

if [ -d "${__dep_list_folder}" ]; then
    rm -r "${__dep_list_folder}"
fi

# Make directory for dependency work
mkdir -p "${__dep_list_folder}"

# Get into the xml directory
__pushd ./src/xml/

# For every xml file,
while read -r __xml; do

    __tmp_deps="$(__get_value "${__xml}" DEPENDS | sed '/^$/d')"

    echo "${__xml} ${__xml}" >> "${__dep_list_tsort}"

    for __line in ${__tmp_deps}; do
        echo "${__xml} ${__line}" >> "${__dep_list_tsort}"
    done

# Finish loop
done < "${__list_file}"

tsort "${__dep_list_tsort}" | tac > "${__dep_list_tsort}_"

mv "${__dep_list_tsort}_" "${__dep_list_tsort}"

while read -r __xml; do

    if [ -e "${__xml}" ]; then

# Set the location for the dep list
        __dep_list="${__dep_list_folder}/${__xml}"

# Make the directory for the dep list if need be
        mkdir -p "$(__odir "${__dep_list}")"

        touch "${__dep_list}"

        { __get_value "${__xml}" CONFIG; __get_value "${__xml}" CLEANUP; __get_value "${__xml}" DEPENDS; } >> "${__dep_list}"

        for __dep in $(__get_value "${__xml}" DEPENDS); do

            if [ -e "${__dep}" ]; then

                cat "${__dep_list_folder}/${__dep}" >> "${__dep_list}"

            fi

        done

        touch "${__dep_list}_"

        sort "${__dep_list}" | uniq | sed '/^$/d' > "${__dep_list}_"

        mv "${__dep_list}_" "${__dep_list}"

    fi

done < "${__dep_list_tsort}"

while read -r __xml; do

    __set_value "${__xml}" DEPENDS "$(cat "${__dep_list_folder}/${__xml}")"

done < "${__list_file}"

while read -r __xml; do

    sed -i -e '1d' -e '$d' "${__xml}"

# get the cleanup files, and list it to a file
    __get_value "${__xml}" CLEANUP >> "${__cleanup_all}"

# if the file is not to be kept,
    if [ "$(__get_value "${__xml}" KEEP)" = "NO" ]; then

# add it to the cleanup file list
        echo "${__xml}" >> "${__cleanup_all}"

# end the if statement
    fi

done < "${__list_file}"

sort "${__cleanup_all}" | uniq > "${__cleanup_all}_"

mv "${__cleanup_all}_" "${__cleanup_all}"

# Go back to the regular directory
__popd

__time "Inherited and created dependencies" end

# Else, if we're supposed to re-use xml files
else

# Let the user know we're re-using xml
__announce "Re-using xml files."

# End if statement whether to split xml again or not
fi

###############################################################
# If only xml splitting
if [ "${__xml_only}" = '0' ]; then

###############################################################
# List new and matching XML entries
__announce "Listing new and matching XML entries."
###############################################################

__time "Listed new and matching XML entries" start

# This is where all new xml files are listed
__new_xml_list="${__tmp_dir}/xml_list_new"
touch "${__new_xml_list}"

# This is where all old xml files are listed
__old_xml_list="${__tmp_dir}/xml_list_old"
touch "${__old_xml_list}"

# This is files only in the new list
__new_split_xml_list="${__tmp_dir}/xml_list_new_split"
touch "${__new_split_xml_list}"

# This is files shared between list_new and list_old
__shared_xml_list="${__tmp_dir}/xml_list_shared"
touch "${__shared_xml_list}"

# This is files only in old list
__old_split_xml_list="${__tmp_dir}/xml_list_old_split"
touch "${__old_split_xml_list}"

# Get to xml directory again
__pushd ./src/xml

# List all files into new list
find . -type f > "${__new_xml_list}"

# Get back to main directory
__popd

# Get to old xml directory again
__pushd "./${__pack}/xml"

# List all files into old list
find . -type f > "${__old_xml_list}"

# Get back to main directory
__popd

# Grep stuff to get uniq entries from different lists
grep -Fxvf "${__old_xml_list}" "${__new_xml_list}" > "${__new_split_xml_list}"
grep -Fxvf "${__new_xml_list}" "${__old_xml_list}" > "${__old_split_xml_list}"
grep -Fxf "${__old_xml_list}" "${__new_xml_list}" > "${__shared_xml_list}"

__time "Listed new and matching XML entries" end

###############################################################
# Check changes in XML files
__announce "Checking changes in XML files."
###############################################################

__time "Checked changes in XML files" start

# Where all new xml files are hashed to
__new_hashes="${__tmp_dir}/new_hashes_xml"
touch "${__new_hashes}"

# Where all old xml files are hashed to
__old_hashes="${__tmp_dir}/old_hashes_xml"
touch "${__old_hashes}"

# Where shared, but changed xml files are listed to
__changed_xml="${__tmp_dir}/changed_xml"
touch "${__changed_xml}"

# Where unchanged xml files are listed
__unchanged_xml="${__tmp_dir}/unchanged_xml"
touch "${__unchanged_xml}"

# Get to xml directory again
__pushd ./src/xml

# Hash the folder, and output to the new hashes file
__hash_folder "${__new_hashes}"

# Get back to main directory
__popd

# Get to old xml directory again
__pushd "./${__pack}/xml"

# Hash the folder, and output to the old hashes file
__hash_folder "${__old_hashes}"

# Get back to main directory
__popd

__time "Checked hash changes" start

if ! [ "$(md5sum < "${__new_hashes}")" = "$(md5sum < "${__old_hashes}")" ]; then

# For every file in the shared xml list,
while read -r __shared; do

# Get the old hash
    __old_hash="$(grep -w "${__shared}" < "${__old_hashes}")"

# Get the new hash
    __new_hash="$(grep -w "${__shared}" < "${__new_hashes}")"

# If the two hashes do not match, we know the xml file
# for that file has changed, and so needs to be re-rendered
    if ! [ "${__old_hash}" = "${__new_hash}" ]; then
        echo "${__shared}" >> "${__changed_xml}"
    else
        echo "${__shared}" >> "${__unchanged_xml}"
    fi

# Done with the hash checking
done < "${__shared_xml_list}"

else

    __announce "No changes to XML."

    if [ -e "${__unchanged_xml}" ]; then

        rm "${__unchanged_xml}"

    fi

     cp "${__shared_xml_list}" "${__unchanged_xml}"

fi

__time "Checked hash changes" end

__time "Checked changes in XML files" end

###############################################################
# List new and matching source files
__announce "Listing new and matching source files."
###############################################################

__time "Listed new and matching source files" start

# This is where all new source files are listed
__new_source_list="${__tmp_dir}/source_list_new"
touch "${__new_source_list}"

# This is where all old source files are listed
__old_source_list="${__tmp_dir}/source_list_old"
touch "${__old_source_list}"

# This is files only in the new list
__new_split_source_list="${__tmp_dir}/source_list_new_split"
touch "${__new_split_source_list}"

# This is files shared between list_new and list_old
__shared_source_list="${__tmp_dir}/source_list_shared"
touch "${__shared_source_list}"

# This is files only in old list
__old_split_source_list="${__tmp_dir}/source_list_old_split"
touch "${__old_split_source_list}"

# Get to source directory again
__pushd ./src

# List all files into new list
find . -not -path "./xml/*" -type f > "${__new_source_list}"

# Get back to main directory
__popd

# Get to old xml directory again
__pushd "./${__pack}"

# List all files into old list
find . -not -path "./xml/*" -type f > "${__old_source_list}"

# Get back to main directory
__popd

# Grep stuff to get uniq entries from different lists
grep -Fxvf "${__old_source_list}" "${__new_source_list}" > "${__new_split_source_list}"
grep -Fxvf "${__new_source_list}" "${__old_source_list}" > "${__old_split_source_list}"
grep -Fxf "${__old_source_list}" "${__new_source_list}" > "${__shared_source_list}"

__time "Listed new and matching source files" end

###############################################################
# Check changes in source files
__announce "Checking changes in source files."
###############################################################

__time "Checked for changes in source files" start

# Where new source files are hashed to
__source_hash_new="${__tmp_dir}/new_hashes_source"
touch "${__source_hash_new}"

# Where old source files are hashed to
__source_hash_old="${__tmp_dir}/old_hashes_source"
touch "${__source_hash_old}"

# Where changed source files are listed
__changed_source="${__tmp_dir}/changed_source"
touch "${__changed_source}"

# Where unchanged source files are listed
__unchanged_source="${__tmp_dir}/unchanged_source"
touch "${__unchanged_source}"

__shared_source_list_hash="${__tmp_dir}/source_list_shared_hashes"
touch "${__shared_source_list_hash}"

# Get to the source directory
__pushd ./src

# Hash source files into designated file, exluding xml files
__hash_folder "${__source_hash_new}" xml

# Get back to main directory
__popd

# Get to old xml directory again
__pushd "./${__pack}"

# Hash source files into designated file, exluding xml files
__hash_folder "${__source_hash_old}" xml

while read -r __file; do
    md5sum "${__file}" >> "${__shared_source_list_hash}"
done < "${__shared_source_list}"

# Get back to main directory
__popd

if ! [ "$(sort "${__shared_source_list_hash}" | md5sum)" = "$(sort "${__source_hash_new}" | md5sum)" ]; then

# For every file in the shared xml list,
while read -r __shared; do

# Get the old hash
    __old_hash="$(grep -w "${__shared}" < "${__source_hash_old}")"

# Get the new hash
    __new_hash="$(grep -w "${__shared}" < "${__source_hash_new}")"

# If the two hashes do not match, we know the source file
# for that file has changed, and so needs to be re-rendered
    if ! [ "${__old_hash}" = "${__new_hash}" ]; then
        echo "${__shared}" >> "${__changed_source}"
    else
        echo "${__shared}" >> "${__unchanged_source}"
    fi

# Done with the hash checking
done < "${__shared_source_list}"

else

    __force_announce "No changes to source."

    if [ -e "${__unchanged_source}" ]; then

        rm "${__unchanged_source}"

    fi

     cp "${__shared_source_list}" "${__unchanged_source}"

fi

__time "Checked for changes in source files" end

###############################################################
# Before we go on, let's recap. These are the files we want
#
# "${__changed_xml}"
# "${__unchanged_xml}"
#
# "${__changed_source}"
# "${__unchanged_source}"
#
# "${__new_split_xml_list}"
#
# So, the plan is to:
#
# Find all valid existing rendered items to bring across.
# To do so, all files in "${__unchanged_xml}" should be checked
# whether they exist, then put on a list. If yes, just
# list. If not, add to a different list (re/render list)
#
# Combine "${__changed_source}" and "${__changed_xml}", then
# find any xml files that *depend* upon them. Then add
# "${__changed_xml}" itself.
#
# Find entries only in pre-rendered list and not in depends
# list to be re-rendered. Replace that list, and copy all files
# to the new folder.
#
# Next, add files from "${__new_split_xml_list}" to that list.
# These are new entries, and shouldn't have any problems
#
# At this point, we have a file with a list of files to render.
# All resultant files have been cleaned as needed.
#
###############################################################
# Checking files to re/render
__announce "Checking for items to re/process."
###############################################################

__time "Checked for items to re/process" start

# Where we'll start putting new work in, will eventually be
# renamed to regular
__pack_new="${__pack}_new"
if [ -d "${__pack_new}" ]; then
    rm -r "${__pack_new}"
fi
mkdir "${__pack_new}"

# List of xml files to re/render
__render_list="${__tmp_dir}/render_list"
touch "${__render_list}"

# List of xml files that are correctly rendered
__rendered_list="${__tmp_dir}/rendered_list"
touch "${__rendered_list}"

# Combine and sort all changed source and changed xml files (also new)
__changed_both="${__tmp_dir}/changed_all"
touch "${__changed_both}"
sort "${__changed_source}" "${__changed_xml}" "${__new_split_source_list}" "${__new_split_xml_list}" | uniq > "${__changed_both}"

# Combine and sort all unchanged source and unchanged xml files
__unchanged_both="${__tmp_dir}/unchanged_both"
touch "${__unchanged_both}"
sort "${__unchanged_source}" "${__unchanged_xml}" | uniq > "${__unchanged_both}"

# Where files to be processed are listed
__list_file_proc="${__tmp_dir}/listing_processing"
touch "${__list_file_proc}"

# Where all dependencies are listed
__all_deps="${__tmp_dir}/all_deps"
touch "${__all_deps}"

# List of files to check
__check_list="${__tmp_dir}/check_list"
touch "${__check_list}"

# TODO - Make a more efficient method of doing this

################################################################
#
# What's happening here is that all files are checked.
# If it, or a dependency, has been changed, then it is cleaned
# and added to the render list.
#
# If it has not been changed, and exists, copy across and add
# to the rendered list
#
# If it is not changed, but it not rendered (that is, the
# rendered file was deleted for whatever reason, it is added to
# the list to be rendered.
#
################################################################

# Get into the dependency folder
__pushd "${__dep_list_folder}"

# List files that depend on changed files
while read -r __changed; do
    grep -rlx "${__changed}" | while read __file; do
        echo "./${__file}" >> "${__list_file_proc}"
    done
done < "${__changed_both}"

# List all deps
find . -type f -exec cat {} + | sort | uniq > "${__all_deps}"

# Get back to main directory
__popd

# List any files in the dep list that are not on the file list
grep -Fxvf "${__list_file}" "${__all_deps}" > "${__check_list}"

# Get into the source directory
__pushd ./src

# Slim check list to only files which do not exist
while read __file; do
    if ! [ -e "${__file}" ]; then
        echo "${__file}" >> "${__check_list}_"
    fi
done < "${__check_list}"

touch "${__check_list}_"
mv "${__check_list}_" "${__check_list}"
touch "${__check_list}_"

# Get into dep list folder
__pushd "${__dep_list_folder}"

# List any files that depend on the check list
while read __file; do
    grep -rlx "${__file}" | while read __dep; do
        echo "./${__dep}" >> "${__check_list}_"
    done
done < "${__check_list}"

# Get back to source directory
__popd

# Make sure check list sorted and uniq
sort "${__check_list}_" | uniq > "${__check_list}"
rm "${__check_list}_"

# Get back to main directory
__popd

# Add check list to process list
cat "${__check_list}" >> "${__list_file_proc}"

# Make a backup of the process list for debugging
cp "${__list_file_proc}" "${__list_file_proc}_original"

# As long as the process list is not empty,
while [ -s "${__list_file_proc}" ]; do

# get the name of the file we're working with,
    __xml="$(head -n 1 "${__list_file_proc}")"

# remove said file from list,
    sed -i '1d' "${__list_file_proc}"

# set trimmed xml name
    __xml_name="${__xml//.\//}"

# ensure the old file does not exist, and make sure to be
# re/rendered
    if [ -e "${__working_dir}/${__pack}/${__xml_name}" ]; then
        rm "${__working_dir}/${__pack}/${__xml_name}"
    fi
    echo "${__xml}" >> "${__render_list}"

# Finish checks
done

# Make sure render list is sorted and uniq
sort "${__render_list}" | uniq > "${__render_list}_"
mv "${__render_list}_" "${__render_list}"

__tmp_time start

# for every ITEM that is *not* in the render list
grep -Fxvf "${__render_list}" "${__list_file}" | sort | uniq | while read -r __xml; do

    __xml_name="${__xml//.\//}"

    if [ -e "${__working_dir}/${__pack}/${__xml_name}" ]; then

# otherwise if file exists, add to a list of properly processed
# files and copy file across,

        mkdir -p "$(__odir "${__working_dir}/${__pack_new}/${__xml_name}")"
        cp "${__working_dir}/${__pack}/${__xml_name}" "${__working_dir}/${__pack_new}/${__xml_name}"
        echo "${__xml}" >> "${__rendered_list}"

# if the file does not exist, re-render
    else

        echo "${__xml}" >> "${__render_list}"

# Done with if statement
    fi

# Finish loop
done

__tmp_time end

sort "${__render_list}" | uniq > "${__render_list}_"

mv "${__render_list}_" "${__render_list}"

cp "${__render_list}" "${__render_list}_backup"

__time "Checked for items to re/process" end

###############################################################
# Copy all source, xml and conf scripts
__announce "Setting up files for processing."
###############################################################

# copy src files into new pack folder
cp -r "./src/"* "${__pack_new}"

# remove old pack
rm -r "${__pack}"

# rename the new pack to the regular pack
mv "${__pack_new}" "${__pack}"

###############################################################
# Render loop
__announce "Starting to render."
###############################################################

__isolated_dir="${__tmp_dir}/isolated"

__render_num='0'

__time "Rendered" start

__start_time="$(date +%s)"

# get into the pack folder, ready to render
__pushd "${__pack}"

# while the render list has lines to process,
while [ -s "${__render_list}" ]; do

# set the original name of the config file
    __orig_config="$(head -n 1 "${__render_list}")"

# remove the item from the render list
    sed "\|^${__orig_config}$|d" "${__render_list}" -i

    __orig_config_name="${__orig_config//.\//}"

# set the formatted name of the config file
    __config="./xml/${__orig_config//.\//}"

# if the dependencies are not yet to be rendered, then
    if ! grep -qFxf "${__dep_list_folder}/${__orig_config_name}" "${__render_list}"; then

# get the size of the texture
        __tmp_val="$(__get_value "${__config}" SIZE)"

# if the size was set,
        if ! [ -z "${__tmp_val}" ]; then

# use it as the real size
            __tmp_size="${__tmp_val}"

# otherwise,
        else

# use the pack size
            __tmp_size="${__size}"

# end size check
        fi

# get the name of the config script
        __config_script="$(__get_value "${__config}" CONFIG)"

# if there is a config script to use, then
        if ! [ -z "${__config_script}" ]; then

            __failed='0'

            while read -r __dep; do

                if ! [ -e "${__dep}" ]; then
                    echo
                    echo "Missing dependency \"${__dep}\""
                    echo "Proceeding without \"${__config}\""
                    __failed='1'
                fi

            done < "${__dep_list_folder}/${__orig_config_name}"

            if [ "${__failed}" = '0' ]; then

# announce that we are processing the given config
                __force_announce "Processing \".${__config//.\/xml/}\""

                __render_num="$((__render_num+1))"

                __config_isolated_dir="${__isolated_dir}/${__render_num}"

# copy the config script out so we can use it
                cp "${__config_script}" ./

# execute the script, given the determined size and options set
# in the config
                eval '\./'"$(basename "${__config_script}")" "${__tmp_size}" "$(__get_value "${__config}" OPTIONS)"

# remove the script now we're done with it
                rm "$(basename "${__config_script}")"

            fi

# end loop for when a config script is present
        fi

# if the config still has dependencies that need to be rendered
    else

# add the config to the end of the render list
        echo "${__orig_config}" >> "${__render_list}"

# end loop to process the top item on the render list
    fi

# finish render loop
done

# get out of the render directory
__popd

__time "Rendered" end

###############################################################
# Final stats
###############################################################

# set the end time for rendering
__end_time="$(date +%s)"

__announce "Done rendering!"
__announce "Rendered ${__size}px in $((__end_time-__start_time)) seconds"

###############################################################
# Make cleaned folder
__announce "Making cleaned folder."
###############################################################

__time "Made cleaned folder" start

sed -i '/^$/d' "${__cleanup_all}"

# set the directory for the cleaned pack
__pack_cleaned="${__pack}_cleaned"

# removed the directory for the cleaned pack, if it exists
if [ -d "${__pack_cleaned}" ]; then
    rm -r "${__pack_cleaned}"
fi

# copy the pack to a new folder to be cleaned
cp -r "${__pack}" "${__pack_cleaned}"

# get into the cleaned folder
__pushd "${__pack_cleaned}"

# for every file to clean
while read -r __file; do

# remove it
    rm "${__file}"

# finish loop
done < "${__cleanup_all}"

# remove xml and conf from cleaned pack
rm -r ./xml
rm -r ./conf

# get back to the right directory
__popd

__time "Made cleaned folder" end

###############################################################
# Make mobile pack if asked to
###############################################################

# if a mobile pack is supposed to be made
if [ "${__mobile}" = '1' ]; then

    __time "Making mobile pack" start

# if the end pack folder exists,
    if [ -d "${__pack_end}" ]; then

# remove it
        rm -r "${__pack_end}"

# end the if statement
    fi

# copy the cleaned folder to the end pack folder
    cp -r "${__pack_cleaned}" "${__pack_end}"

# if the mobile script doesn't exist,
    if ! [ -e "${__smelt_make_mobile_bin}" ]; then

# complain
        __error "Missing mobile script system"

# end if statement whether the mobile script exists
    fi

# copy the script to the end pack folder
    cp "${__smelt_make_mobile_bin}" "${__pack_end}/$(basename "${__smelt_make_mobile_bin}")"

# get into the end pack folder
    __pushd "${__pack_end}"

# excecute the mobile script folder
    "./${__smelt_make_mobile_bin}" || __error "Make mobile script failed"

# remove the mobile script folder
    rm "${__smelt_make_mobile_bin}"

# get back into the main directory
    __popd

    __time "Making mobile pack" end

fi

###############################################################
# End if only xml splitting
fi

# copy the catalogue into the src xml folder
cp "${__catalogue}" "./src/xml/${__catalogue}"

cp "${__dep_list_tsort}" "./src/xml/${__tsort_file}"

cp -r "${__dep_list_folder}" "./src/xml/"

cp "${__cleanup_all}" "./src/xml/${__cleanup_file}"

###############################################################
# General Cleanup
###############################################################

# If we're debugging, don't clean up (it will be done on next
# run anyway)
if [ "${__debug}" = '0' ]; then
    __announce "Cleaning up."
    rm -r "${__tmp_dir}"
fi

exit
