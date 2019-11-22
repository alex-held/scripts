#!/bin/bash


function usage() {
    cat <<EOM

    Usage: $progname [--glob PATTERN] [--dry-run] [--verbose]
    
    optional arguments:
    
    -h, --help			show this help message and exit
    -g, --glob			globbing Pattern to filter directories
    -d, --dry-run			do a dry run, dont change any files
    -v, --verbose			prints all arguments
    
EOM
    exit 0	  
}


# initialize variables
progname=$(basename $0)
dryrun=false
verbose=false
glob=
src=
dest=
cmd=

# ensure src and dest is set
if (( $# < 2 )); then
    echo "$0: At least two arguments are required <src> <dest>"
    usage
    exit 1
else
  src=$1 
  dest=$2 
fi

# use getopt and store the output into $OPTS
# note the use of -o for the short options, --long for the long name options
# and a : for any option that takes a parameter

short=hdvg:
long=help,dry-run,verbose,glob:


OPTS=$(getopt --options $short --long $long --name "$progname" -- "$@")
if [ $? != 0 ] ; then echo "Error in command line arguments." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
  # uncomment the next line to see how shift is working
  echo "\$1:\"$1\" \$2:\"$2\""
  
  case "$1" in
    -h | --help)
	usage
	exit 0
	;;
    -d | --dry-run)
	dryrun=true
	shift
	;;
    -v | --verbose)
	verbose=true
	shift
	;;
    -g | --glob)
	glob="$2";
	shift 2
	;;
    -- )
	shift
	break
	;;
    * ) 
	break
	usage
	exit 1
	;;
  esac
done


if [ "$verbose" == "true" ]; then

    cat <<EOM
    src=$src
    dest=$dest
    glob=$glob
    verbose=$verbose
    dryrun=$dryrun
EOM
fi


if [ -n $glob ]; then
  cmd="ls -1 $src | xargs -J {} mv {} $dest" 
else
  cmd="ls -1 $src | grep --line-buffered -e '$glob' | xargs -J {} mv {} $dest"
fi 




if [ "$dryrun" == "true" ]; then
 
  echo "DRYRUN: Not moving any files..." 
  echo "Command to be executed: '$cmd'"

else
  echo "Executing command!!"
  echo "$cmd"
fi

