#!/bin/bash

###############################
# Defaults
###############################

__size='128'
__quiet='0'
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
__list_changed='0'
__should_optimize='0'
__re_optimize='0'
__show_progress='0'
__render_optional='0'

###############################################################
# Setting up functions
###############################################################

if [ -z "${__run_dir}" ]; then
    __error "Running directory has not been set for some reason"
fi

# temporary timer for quick timing automatically toggles
__time_var='temporary timer'
__tmp_time () {
if [ -z "${__tmp_time_var}" ] || [ "${__tmp_time_var}" = 'end' ]; then
    __tmp_time_var='start'
elif [ "${__tmp_time_var}" = 'start' ]; then
    __tmp_time_var='end'
fi

__time "${__time_var}" "${__tmp_time_var}"
}

# print help
__usage () {
echo "$(basename "${0}") <OPTIONS> <SIZE>

Renders the texture pack at the specified size (or default 128)
Order of options and size are not important.

Options:
  -h  --help  -?        This help message
      --progress        Show a progress report
  -f  --force           Discard pre-rendered data
  -v  --verbose         Verbose
  -p  --process-id      Using PID as given after
  -d  --debug           Debugging mode
  -l  --lengthy         Very verbose debugging mode
  -x  --xml-only        Only process XML files
  -n  --name-only       Print output folder name
  -m  --mobile          Make mobile resource pack
  -s  --slow            Use slower render engine (Inkscape)
  -q  --quick           Use quicker render engine (rsvg-convert)
  -t  --time            Time operations (for debugging)
  -w  --warn            Show warnings
  -o  --optimize        Optimize final PNG files
      --no-optimize     Do not optimize final PNG files
      --quiet           No output unless specified
      --optional        Actually render any optional files,
                        though they still won't be included
      \
"
}

__start_debugging () {
    set -x
}

__stop_debugging () {
    set +x
}

###############################################################
# Set variables from config
###############################################################

# Master folder
__working_dir="$(pwd)"

###############################################################
# Read options
__force_time "Read options" start
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

# Whether or not to show a progress indicator
                "--progress")
                    __show_progress='1'
                    ;;

                "--quiet")
                    __quiet='1'
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
# If we're supposed to be in debugging mode and be very verbose
                    if [ "${__debug}" = '1' ]; then
                        if [ "${__very_verbose}" = '1' ]; then
                            __start_debugging
                        fi
                    fi
                    ;;

# only process XML files
                "-x" | "--xml-only")
                    __force_announce "Only processing XML files"
                    __xml_only='1'
                    ;;

# Whether or not to just print the exported folder name
                "-n" | "--name-only")
                    __name_only='1'
                    ;;

# whether to make mobile resource pack
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

# hidden option to list changed files only
                "--list-changed")
                    __list_changed='1'
                    ;;

# whether to optimize images
                "-o" | "--optimize")
                    __should_optimize='1'
                    ;;

                "--no-optimize")
                    __warn "Forcing optimization off"
                    __should_optimize='0'
                    ;;

                "--re-optimize")
                    __re_optimize='1'
                    ;;

                "--optional")
                    __render_optional='1'
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

# set tmp_dir if not set already
if [ -z "${__tmp_dir}" ]; then
    __tmp_dir="/tmp/smelt/texpack${__pid}"
else
    __warn "Using custom temporary directory \"${__tmp_dir}\""
fi

# set quick if not set already
if [ -z "${__quick}" ]; then
    __warn "Quick/Slow mode not set, defaulting to quick"
    export __quick='1'
fi

###############################################################
# Derived variables
###############################################################

# Rendered folder name
__pack="${__name}-${__size}px"

# if we're supposed to make a mobile pack,
if [ "${__mobile}" = '1' ]; then

# set a special end pack folder
    __pack_end="${__pack}_mobile"

# otherwise
else

# set the end pack name the same as normal
    __pack_end="${__pack}"

# end mobile if statement
fi

###############################################################
# Print pack name
###############################################################

# if we're only supposed to print the pack name
if [ "${__name_only}" = '1' ]; then

# print the pack end pack folder name
    echo "${__pack_end}"

# and exit
    exit

# exit the name only if statement
fi

###############################################################
# Any warnings
###############################################################

__calculated_log="$(__log2 "${__size}")"

if ! [ "${__size}" = "$(echo "2^${__calculated_log}" | bc)" ]; then
    __force_warn "Given size is not a power of 2"
fi

###############################################################
# Check software deps
###############################################################

# check inkscape
if which inkscape &> /dev/null; then
    __has_inkscape='1'

else
    __has_inkscape='0'
fi

# check rsvg-convert
if which rsvg-convert &> /dev/null; then
    __has_rsvg_convert='1'

# if that did return an error, we know it doesn't exist
else
    __has_rsvg_convert='0'
fi

# if inkscape exists, but rsvg-convert doesn't exist, and we're
# wanting to use rsvg-convert, say so and force inkscape
if [ "${__has_inkscape}" = '1' ] && [ "${__has_rsvg_convert}" = '0' ] && [ "${__quick}" = '1' ]; then
    __force_warn "Missing rsvg-convert. Cannot continue in quick mode.
Please install 'librsvg-devel', changing to inkscape"
    export __quick='0'

# if rsvg-convert exists, but inkscape doesn't exist, and we're
# wanting to use inkscape, say so and force rsvg-convert
elif [ "${__has_inkscape}" = '0' ] && [ "${__has_rsvg_convert}" = '1' ] && [ "${__quick}" = '0' ]; then
    __force_warn "Missing Inkscape. Must continue in quick mode.
Please install 'inkscape', changing to rsvg-convert"
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

    __announce "Will make mobile resource pack."

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

__list_name='list'
__list_file="${__tmp_dir}/${__list_name}"

__dep_list_tsort="${__tmp_dir}/${__tsort_file}"

__dep_list_name='tmp_deps'
__dep_list_folder="${__tmp_dir}/${__dep_list_name}"

__cleanup_file='cleanup'

__cleanup_all="${__tmp_dir}/${__cleanup_file}"
touch "${__cleanup_all}"

__optimize_file='optimize_list'
__optimize_list="${__tmp_dir}/${__optimize_file}"
touch "${__optimize_list}"

__cleaned_catalogue="${__tmp_dir}/${__catalogue}"

__time "Cleaned pack" start

__clean_pack < "${__catalogue}" > "${__cleaned_catalogue}"

__time "Cleaned pack" end

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
    __old_catalogue_hash="$(md5sum "${__catalogue}" | sed 's/ .*//')"

# remove the catalogue
    rm "${__catalogue}"

# end the if statement if the catalogue exists
fi

# get back into the main directory
__popd

# md5sum hash the current catalogue
__new_catalogue_hash="$(md5sum "${__cleaned_catalogue}" | sed 's/ .*//')"

# if the new catalogue is the same as the old catalogue, then
if [ "${__old_catalogue_hash}" = "${__new_catalogue_hash}" ] && [ -e "./src/xml/${__tsort_file}" ] && [ -d "./src/xml/${__dep_list_name}" ] && [ -e "./src/xml/${__cleanup_file}" ] && [ -e "./src/xml/${__optimize_file}" ] && [ -e "./src/xml/${__list_name}" ]; then

# say so
    __announce "No changes to XML catalogue."

# tell the script to re-use the xml files
    __re_use_xml='1'

# make sure tsort file exists
    mv "./src/xml/${__tsort_file}" "${__dep_list_tsort}"

    mv "./src/xml/${__dep_list_name}" "${__tmp_dir}"

    mv "./src/xml/${__cleanup_file}" "${__cleanup_all}"

    mv "./src/xml/${__optimize_file}" "${__optimize_list}"

    mv "./src/xml/${__list_name}" "${__list_file}"

# end if statement whether the catalogues are the same
fi

# If we're told not to re-use xml, then
if [ "${__re_use_xml}" = '0' ]; then

__announce "Splitting XML files."

# Where current xml files are split off to temporarily
__xml_current="${__tmp_dir}/xml_current"

# For every ITEM in catalogue,
__get_range "${__cleaned_catalogue}" ITEM | while read -r __range ; do

# TODO
# Optimize xml functions more

# Actually read the range into a variable. This now contains an ITEM.
    __tmp_read="$(__read_range "${__cleaned_catalogue}" "${__range}")"

# Get the NAME of this ITEM
    __item_name="$(__get_value_piped NAME <<< "${__tmp_read}")"

# Make the correct directory for dumping the xml into an
# appropriately named file

    __goal_dir="${__xml_current}/${__item_name//.\//}"

    mkdir -p "${__goal_dir%/*}"

# Move that temporary read range file from before to somewhere
# more useful, according to the item's name

    echo "${__tmp_read}" > "${__xml_current}/${__item_name}"

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
# Check for files to __optimize
__announce "Checking for files to optimize."

touch "${__optimize_list}"

__time "Found files to optimize" start

__pushd ./src/xml/

# NOTE: We can shortcut with grep here since it should never be
# written any other way than this
grep -rlw '<IMAGE>YES</IMAGE>' | grep -F "$(grep -rlw '<KEEP>YES</KEEP>')" | sed 's#^#\./#' | sort | uniq > "${__optimize_list}"

__popd

__time "Found files to optimize" end

###############################################################
# Inherit deps and cleanup
__announce "Inheriting and creating dependencies and cleanup files."
###############################################################

# End if statement whether to split xml again or not
fi

# Get into the xml directory
__pushd ./src/xml/

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

__time "Read base dependencies" start

# For every xml file,
while read -r __xml; do

    echo "${__xml} ${__xml}" >> "${__dep_list_tsort}"

    __get_values "${__xml}" DEPENDS CONFIG | sort | uniq | grep -v '^$' | while read -r __line; do
        echo "${__xml} ${__line}" >> "${__dep_list_tsort}"
    done

# Finish loop
done < "${__list_file}"

__time "Read base dependencies" end

__time "tsort-ed" start

tsort "${__dep_list_tsort}" | tac > "${__dep_list_tsort}_"

mv "${__dep_list_tsort}_" "${__dep_list_tsort}"

__time "tsort-ed" end

__time "Made directories" start

while read -r __xml; do

    if [ -e "${__xml}" ]; then

        __dep_list="${__dep_list_folder}/${__xml}"

        dirname "${__dep_list}"

    fi

done < "${__dep_list_tsort}" | sort | uniq | while read -r __dir; do

# Make the directory for the dep list if need be
    mkdir -p "${__dir}"

done

__time "Made directories" end

__time "Read and inherited dep files" start

while read -r __xml; do

    if [ -e "${__xml}" ]; then

# Set the location for the dep list
        __dep_list="${__dep_list_folder}/${__xml}"

        touch "${__dep_list}"

        __get_values "${__xml}" CONFIG CLEANUP DEPENDS | sort | uniq | sed '/^$/d' | tee "${__dep_list}" | while read -r __suspect_dep; do

            if [ -e "${__suspect_dep}" ] && ! [ "${__dep_list_folder}/${__suspect_dep}" = "${__dep_list}" ]; then

                cat "${__dep_list_folder}/${__suspect_dep}"

            fi

        done | sort | uniq | sed '/^$/d' > "${__dep_list}"

    fi

done < "${__dep_list_tsort}"

__time "Read and inherited dep files" end

__time "Setting deps from file" start

while read -r __xml; do

    __set_value "${__xml}" DEPENDS < "${__dep_list_folder}/${__xml}"

done < "${__list_file}"

__time "Setting deps from file" end

__time "Getting cleanup files" start

while read -r __xml; do

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

__time "Getting cleanup files" end

# Go back to the regular directory
__popd

__time "Inherited and created dependencies" end

# Else, if we're supposed to re-use xml files
else

# Let the user know we're re-using xml
__announce "Re-using XML files."

# End if statement whether to split xml again or not
fi

###############################################################
# If not only xml splitting
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

# Hash source files into designated file, excluding xml files
__hash_folder "${__source_hash_new}" xml

# Get back to main directory
__popd

# Get to old xml directory again
__pushd "./${__pack}"

# Hash source files into designated file, excluding xml files
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

    if [ "${__list_changed}" = '0' ]; then

        __force_announce "No changes to source."

    fi

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
sort "${__changed_source}" "${__changed_xml}" "${__new_split_source_list}" "${__new_split_xml_list}" | uniq | grep -v '^$' > "${__changed_both}"

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

# List of files to copy across
__copy_list="${__tmp_dir}/copy_list"
touch "${__copy_list}"

touch "./${__pack}/.${__optimize_file}"

if [ "${__should_optimize}" = '1' ]; then
# Make sure the files yet to be optimized are added to the list
# of changed files

    if [ "${__re_optimize}" = '1' ]; then

        cat "${__optimize_list}" >> "${__changed_both}"

    else

        grep -Fxvf "./${__pack}/.${__optimize_file}" "${__optimize_list}" >> "${__changed_both}"

    fi

else

# Or make sure previously optimized files are redone, and not
# optimized
    cat "./${__pack}/.${__optimize_file}" >> "${__changed_both}"

fi

rm "./${__pack}/.${__optimize_file}"

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

__pushd "${__pack}"

while read -r __xml; do

    if ! [ -e "${__xml}" ]; then

        echo "${__xml}" >> "${__check_list}"

    fi

done < "${__list_file}"

__popd

# Get into the dependency folder
__pushd "${__dep_list_folder}"

# List files that depend on changed files
grep -rlxf "${__changed_both}" | sed 's#^#./#' >> "${__list_file_proc}"

# List ITEMS that have changed
grep -Fxf "${__changed_both}" "${__new_xml_list}" >> "${__list_file_proc}"

# List all deps
find . -type f -exec cat {} + | sort | uniq > "${__all_deps}"

# Get back to main directory
__popd

# List any files in the dep list that are not on the file list
grep -Fxvf "${__list_file}" "${__all_deps}" >> "${__check_list}"

# Get into the source directory
__pushd ./src

# Slim check list to only files which do not exist
while read -r __file; do
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
grep -rlxf "${__check_list}" | sed 's#^#./#' >> "${__check_list}_"

# Get back to source directory
__popd

# Make sure check list sorted and uniq
sort "${__check_list}_" | uniq > "${__check_list}"
rm "${__check_list}_"

# Get back to main directory
__popd

# Add check list to process list
cat "${__check_list}" >> "${__list_file_proc}"

sort "${__list_file_proc}" | uniq > "${__list_file_proc}_"
mv "${__list_file_proc}_" "${__list_file_proc}"

# Make a backup of the process list for debugging
if [ "${__debug}" = '1' ]; then
    cp "${__list_file_proc}" "${__list_file_proc}_original"
fi

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

# for every ITEM that is *not* in the render list
grep -Fxvf "${__render_list}" "${__list_file}" | sort | uniq | while read -r __xml; do

# set cleaned xml name
    __xml_name="${__xml//.\//}"

# if a rendered file for it exists
    if [ -e "${__working_dir}/${__pack}/${__xml_name}" ]; then

        echo "${__xml_name}" >> "${__copy_list}"

# if the file does not exist, re-render
    else

        echo "./${__xml_name}" >> "${__render_list}"

# Done with if statement
    fi

# Finish loop
done

__time "Copied existing files" start

if [ -s "${__copy_list}" ]; then
    mapfile -t __dir_array <<< "$(sed "s#^#${__working_dir}/${__pack_new}/#" < "${__copy_list}")"
    mkdir -p "${__dir_array[@]%/*}"
fi

while read -r __xml_name; do

    { cp "${__working_dir}/${__pack}/${__xml_name}" "${__working_dir}/${__pack_new}/${__xml_name}" &> /dev/null || __force_warn "File './${__xml_name} does not exist even though we just checked"; } &

    echo "./${__xml_name}" >> "${__rendered_list}"

done < "${__copy_list}"

sort "${__render_list}" | uniq > "${__render_list}_"

mv "${__render_list}_" "${__render_list}"

cp "${__render_list}" "${__render_list}_backup"

if [ -s "${__render_list}" ]; then
    mapfile -t __dir_array <<< "$(sed "s#^#${__working_dir}/${__pack_new}/#" < "${__render_list}")"
    mkdir -p "${__dir_array[@]%/*}"
fi

wait

__time "Copied existing files" end

__time "Checked for items to re/process" end

if [ "${__list_changed}" = '1' ]; then

    __changed="$(cat "${__render_list}")"

    if [ -z "${__changed}" ]; then
        __force_announce "No changes to \"${__size}\""
    else
        __force_announce "Changes to \"${__size}\":"
        echo "${__changed}" | tac | while read -r __change; do
            __format_text "\e[36m${__size}\e[39m" "File \"${__change}\" has changed." ""
        done
    fi

    if [ -d "${__pack_new}" ]; then
        rm -r "${__pack_new}"
    fi

else

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

__pushd "${__pack}"

touch "${__render_list}_"

if [ "${__render_optional}" = '0' ]; then
    while read -r __item; do
        __config="./xml/${__item//.\//}"
        if [ "$(__get_value "${__config}" OPTIONAL)" = 'NO' ]; then
            echo "${__item}" >> "${__render_list}_"
        fi
    done < "${__render_list}"
    mv "${__render_list}_" "${__render_list}"
else
    rm "${__render_list}_"
fi

__popd

__break_loop='0'

__time "Rendered ${__size}px" start

__pushd './src/xml/'

__process_count="$(while read -r __item; do if ! [ -z "$(__get_value "${__item}" CONFIG)" ]; then echo "${__item}"; fi; done < "${__render_list}" | wc -l)"

__popd

if [ "${__process_count}" = '0' ] && [ "${__quiet}" = '1' ]; then
    __bypass_announce "No changes to \"${__size}\""
fi

__render_num='0'

# get into the pack folder, ready to render
__pushd "${__pack}"

__set_break_loop () {
__break_loop='1'
}

# trap ctrl c in case the user is stupid
# doesn't always work, please use 'q' instead
trap __set_break_loop SIGINT

# while the render list has lines to process,
while [ -s "${__render_list}" ] && [ "${__break_loop}" = '0' ]; do

    __will_optimize='0'

# set the original name of the config file
    __orig_config="$(head -n 1 "${__render_list}")"

# remove the item from the render list
    sed "\|^${__orig_config}$|d" "${__render_list}" -i

    __orig_config_name="${__orig_config//.\//}"

# set the formatted name of the config file
    __config="./xml/${__orig_config_name}"

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

# get the name of the config script, and replace any macro locations
        __config_script="$(__get_value "${__config}" CONFIG)"

# if there is a config script to use, then
        if ! [ -z "${__config_script}" ]; then

            __render_num=$((__render_num+1))

            __failed='0'

            while read -r __dep; do

                if ! [ -e "${__dep}" ]; then
                    __force_warn "Missing dependency \"${__dep}\"
Won't create \".${__config//.\/xml/}\""
                    __failed='1'
                fi

            done < "${__dep_list_folder}/${__orig_config_name}"

            if [ "${__failed}" = '0' ]; then

                if [ "${__should_optimize}" = '1' ] && [ "$(__get_value "${__config}" KEEP)" = "YES" ] && [ "$(__get_value "${__config}" IMAGE)" = 'YES' ]; then
                    __will_optimize='1'
                fi

                if [ "${__will_optimize}" = '1' ]; then
                    __leader="Processing and optimizing"
                else
                    __leader="Processing"
                fi

                if [ "${__render_num}" = '1' ] && [ "${__show_progress}" = '1' ]; then
                    echo
                fi

                if [ "${__show_progress}" = '1' ]; then
# Clears last line
                    tput cuu 1 && tput el
                fi

# announce that we are processing the given config
                if [ "${__quiet}" = '0' ]; then
                    __format_text "\e[36m${__size}\e[39m" "${__leader} \".${__config//.\/xml/}\"" ""
                fi

# copy the config script out so we can use it
                cp "${__config_script}" ./

# execute the script, given the determined size and options set
# in the config
                {
                eval '\./'"$(basename "${__config_script}")" "${__tmp_size}" $(__get_value "${__config}" OPTIONS | tr '\n' ' ')

                if [ "${__will_optimize}" = '1' ]; then

                    __optimize "./${__orig_config_name}"

                fi
                } &

                if [ "${__show_progress}" = '1' ]; then
                    __format_text "\e[36m${__size}\e[39m" "$(echo "100*${__render_num}/${__process_count}" | bc)% done - ${__render_num}/${__process_count}" ""
                fi

                wait

# remove the script now we're done with it
                rm "$(basename "${__config_script}")"

            fi

# end loop for when a config script is present
        else

            if [ "${__should_optimize}" = '1' ] && [ "$(__get_value "${__config}" KEEP)" = "YES" ] && [ "$(__get_value "${__config}" IMAGE)" = 'YES' ]; then
                __will_optimize='1'
            fi

            if [ "${__will_optimize}" = '1' ]; then

                __optimize "./${__orig_config_name}"

            fi

        fi

# often enough breaking the loop also breaks an image this will
# delete the image if it exists, since it's unreliable
        if [ "${__break_loop}" = '1' ] && [ -e "./${__orig_config_name}" ]; then
            rm "./${__orig_config_name}"
        fi

# if the config still has dependencies that need to be rendered
    else

# add the config to the end of the render list
        echo "${__orig_config}" >> "${__render_list}"

# end loop to process the top item on the render list
    fi

# finish render loop
done

# untrap ctrl c, so we don't get ourselves into trouble some day
trap - SIGINT

# get out of the render directory
__popd

###############################################################
# Final stats
###############################################################

__announce "Done rendering!"

__time "Rendered ${__size}px" end

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

# if it exists
    if [ -e "${__file}" ]; then

# remove it
        rm "${__file}" &

    else

        __pushd "${__working_dir}/${__pack}"

        __warn_missing_cleanup () {
        __force_warn "File \"${1}\" for cleanup does not exist"
        }

        if [ -e "./xml/${__file//.\//}" ]; then

            if [ "$(__get_value "./xml/${__file//.\//}" OPTIONAL)" = 'YES' ] && [ "${__render_optional}" = '1' ]; then
                __warn_missing_cleanup "${__file}"
            fi

        else

            __warn_missing_cleanup "${__file}"

        fi

        __popd

    fi

# finish loop
done < "${__cleanup_all}"

wait

# remove xml and conf from cleaned pack
rm -r ./xml
rm -r ./conf

# remove all empty directories
find . -type d | while read -r __dir; do
    if ! [ "$(ls -A "${__dir}/")" ]; then
        rmdir "${__dir}"
    fi
done

# get back to the right directory
__popd

__time "Made cleaned folder" end

###############################################################
# Make mobile pack if asked to
###############################################################

# if a mobile pack is supposed to be made, and the mobile script
# doesn't exist
if [ "${__mobile}" = '1' ] && ! [ -e "${__smelt_make_mobile_bin}" ]; then

# complain
    __force_warn "Missing mobile script system, will not make mobile pack"

# disable mobile pack
    __mobile='0'

fi

# if a mobile pack is supposed to be made
if [ "${__mobile}" = '1' ]; then

    __announce "Making mobile pack."

    __time "Made mobile pack" start

# if the end pack folder exists,
    if [ -d "${__pack_end}" ]; then

# remove it
        rm -r "${__pack_end}"

# end the if statement
    fi

# copy the cleaned folder to the end pack folder
    cp -r "${__pack_cleaned}" "${__pack_end}"

# copy the script to the end pack folder
    cp "${__smelt_make_mobile_bin}" "${__pack_end}/$(basename "${__smelt_make_mobile_bin}")"

# get into the end pack folder
    __pushd "${__pack_end}"

# execute the mobile script folder
    "./${__smelt_make_mobile_bin}" || __error "Make mobile script failed"

# remove the mobile script folder
    rm "${__smelt_make_mobile_bin}"

# get back into the main directory
    __popd

    __time "Made mobile pack" end

fi

###############################################################
# End if only xml splitting
fi

###############################################################
# End if listing changed files
fi

# copy the catalogue into the src xml folder
cp "${__cleaned_catalogue}" "./src/xml/${__catalogue}"

cp "${__dep_list_tsort}" "./src/xml/${__tsort_file}"

cp -r "${__dep_list_folder}" "./src/xml/"

cp "${__cleanup_all}" "./src/xml/${__cleanup_file}"

cp "${__optimize_list}" "./src/xml/${__optimize_file}"

cp "${__list_file}" "./src/xml/${__list_name}"

if [ "${__xml_only}" = '0' ]; then

if [ "${__should_optimize}" = '1' ]; then

    cp "${__optimize_list}" "./${__pack}/.${__optimize_file}"

else

    echo '' > "./${__pack}/.${__optimize_file}"

fi

fi

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
