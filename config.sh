echo 'something to use a pipe' | rev > /dev/null
compgen -A variable > /tmp/tmpvars
################################################################
# Start customizing from here
################################################################

__name='Pack'
__tmp_dir="$(pwd)/tmp/${__pid}"
__catalogue='./catalogue.xml'
__smelt_make_mobile_bin='./convert_to_mobile.sh'
__quick='1'

################################################################
# Stop customizing from here
################################################################
compgen -A variable > /tmp/tmpvars2
for __variable in $(grep -Fxvf /tmp/tmpvars /tmp/tmpvars2); do
    export "${__variable}"
done
