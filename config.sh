#smeltconfig#
echo 'something to use a pipe' | rev > /dev/null
compgen -A variable > /tmp/tmpvars
################################################################
# Start customizing from here
################################################################

# Name of the pack, defaults to folder name if missing
__name='Pack'

# Default render sizes
__sizes='1 2 4 8 16 32 64 128 256 512 1024 2048 4096'

# Temporary directory to use. Defaults to /tmp/texpack${__pid}
# if missing
__tmp_dir="$(pwd)/tmp/${__pid}"

# Script to use for mobile conversion. No default currently,
# will disable mobile conversion if missing
__smelt_make_mobile_bin='./convert_to_mobile.sh'

# Whether or not to render in quick mode (if applicable).
# Defaults to quick mode if missing
__quick='1'

# Whether or not the final images should be optimized
__should_optimize='1'

# Largest size to optimize
__max_optimize='512'

# Whether or not to ignore the max optimize size
__ignore_max_optimize='1'

################################################################
# Stop customizing from here
################################################################
compgen -A variable > /tmp/tmpvars2
for __variable in $(grep -Fxvf /tmp/tmpvars /tmp/tmpvars2); do
    export "${__variable}"
done
