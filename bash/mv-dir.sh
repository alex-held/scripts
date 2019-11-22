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
  shift
  dest=$1
  shift
fi


OPTS=$(gnu-getopt -u --options "hvdg:" --long "verbose,dry-run,help,glob:" --name "$(basename $0)" -- "$@")
if [ $? != 0 ] ; then echo "Error in command line arguments." >&2 ; exit 1 ; fi
eval set -- "$OPTS"


while true;
do
  case "$1" in
    -h|--help|-\?) usage; exit;;
    -v|--verbose) verbose=true;;
    -d|--dry-run) dryrun=true;;
    -g|--glob) glob="$2"; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage; exit 1;;
    (*) break;;
  esac
  shift
done


if [ $verbose == true ]; then
    cat <<EOM

--- verbose output ---
src:        $src
dest:       $dest

glob:       $glob
verbose:    $verbose
dry-runn:   $dryrun
----------------------

EOM
fi


if [ -z $glob ]; then
  cmd="ls -1 $src | xargs -J {} mv {} $dest" 
else
  cmd="ls -1 $src | grep --line-buffered -e \"$glob\" | xargs -J {} mv {} $dest"
fi 


if [ "$dryrun" == "true" ]; then
 
    cat <<EOM

--- DRY RUN ---
source directory:        $src
target directory:        $dest

command: $cmd
----------------------

EOM

else
  echo "$cmd"
fi

