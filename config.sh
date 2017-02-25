echo 'something to use a pipe' | rev > /dev/null
compgen -A variable > /tmp/tmpvars
################################################################
# Start customizing from here
################################################################

# Name of the pack, defaults to folder name if missing
__name='Pack'

# Temporary directory to use. Defaults to /tmp/texpack${__pid}
# if missing
__tmp_dir="$(pwd)/tmp/${__pid}"

# Catalogue file to use. Defaults to catalogue.xml if missing
__catalogue='./catalogue.xml'

# Script to use for mobile conversion. No default currently,
# will disable mobile conversion if missing
__smelt_make_mobile_bin='./convert_to_mobile.sh'

# Whether or not to render in quick mode (if applicable).
# Defaults to quick mode if missing
__quick='1'

################################################################
# Stop customizing from here
################################################################
compgen -A variable > /tmp/tmpvars2
for __variable in $(grep -Fxvf /tmp/tmpvars /tmp/tmpvars2); do
    export "${__variable}"
done
