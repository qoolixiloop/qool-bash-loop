#!/bin/bash



#=============================================================================
# Bash Script Template
# Roland Benz
# 9.Nov.2018
# ----------------------------------------------------------------------------
# Debug info:
#   For full debug mode start your script with the following command. 
#   | DEBUG='t'  : gives output for the code before main() can call get_options()
#   | --debug    : gives output for the code after that.
#   $ DEBUG='t' ./Scriptname.sh --debug
# Other options:
#   Version info: -v or --version
#   Doc info:     -d or --doc
#=============================================================================



# -----------------------------------------------------------------------------
# TODO: put your version and documentation info here
# -----------------------------------------------------------------------------
version() { # this function is called from print_info()
	# Everything between the two EOF's will be printed 
	cat <<EOF
Author: Roland Benz
Version: 1
Date: 9 Nov.2018
EOF
# return 1 because "exit 1" would terminate your shell
return 1
}


doc() { #this function is called from print_info()
	# Everything between the two EOF's will be printed 
	cat <<EOF
your script description goes here
	and here
			and here
EOF
# change to "exit 1" will terminate your shell
return 1
}
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# TODO: adapt the function for your own script options
# -----------------------------------------------------------------------------
get_options() { # this function is called from main()
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:get_options" 
  unset OUTPUTFILE
  unset DEBUG
  # As long as there is at least one more argument, keep looping
  while [[ $# -gt 0 ]]; do
    [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:start loop" 
    key="$1"
    case "$key" in
      # This is a flag type option. Will catch either -f or --foo
      -v|--version)
      # call function to print version info and return with 1
      version
      [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:printed version" 
      return 1
      ;;
      # Also a flag type option. Will catch either -b or --bar
      -d|--doc)
      # call function to print doc info and return with 1
      doc
      [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:printed doc" 
      return 1
      ;;
      # Also a flag type option. Will catch --verbatim or --debug
      --verbose|--debug)
      # 
      DEBUG='y'
      [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:set DEBUG='y'" 
      ;;
      # This is an arg value type option.
      # Will catch -o value or --output-file value
      -o|--output-file)
      shift # past the key and to the value
      OUTPUTFILE="$1"
      [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:set OUTPUTFILE" 
      ;;
      # This is an arg=value type option. 
      # Will catch -o=value or --output-file=value
      -o=*|--output-file=*)
      # No need to shift here since the value is part of the same string
      OUTPUTFILE="${key#*=}"
      [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:set OUTPUTFILE" 
      ;;
      *)
      # Do whatever you want with extra options
      echo "Unknown option '$key'"
      [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:hit unknown option" 
      ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
  done
  # return with code 0
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:return 0" 
  return 0
}
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# This checks whether the script is sourced or executed
# -----------------------------------------------------------------------------
#		1) if you started your script with the command below on the command line
#       the script will be sourced from bash and your main() will not 
#       be executed. The same is true if you source this script into another
#				script, main() will not be executed.
#					$ . Scriptname.sh
#   2) if you make the script executable and instead of sourcing it, execute
#       it with the following commands the behaviour changes. With the lines 
#       at the end of the script main() will then be run.
#					$ chmod +x scriptname.sh
#					$ ./scriptname.sh
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sourced or executed?" 

if [[ $(basename "$0") == $(basename "${BASH_SOURCE[0]}") ]]; then
		[[ $DEBUG == 'y' ]] && echo "--$LINENO executed"
else
		[[ $DEBUG == 'y' ]] && echo "--$LINENO sourced from $0"
fi
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# TODO: sourced modules go here
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sourced modules" 

# shellcheck disable=SC1091
# shellcheck source=./M_01.sh
#. ./M_01.sh
#. ./Script_2_scratch.sh
#. Script_2_scratch.sh
./Script_2_scratch.sh
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# TODO: function definitions (API) and shell variables (constants) go here
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:function definitions" 

load_file_vars() {
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ----------------------------------------------------------------------------
  # Task I
  # 1. make sure you apply the script to the direcory qoolixiloopAgithub
  # ----------------------------------------------------------------------------
  # running script: extract filename and path information
  fullpath_with_scriptname=$(realpath "${BASH_SOURCE[0]}")
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]} \
    fullpath_with_scriptname: $fullpath_with_scriptname"
  relativepath_no_scriptname=$(dirname "${BASH_SOURCE[0]}")
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]} \
    relativepath_no_scriptname: $relativepath_no_scriptname"
  fullpath_no_scriptname=${fullpath_with_scriptname%/*}
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]} \
    fullpath_no_scriptname: $fullpath_no_scriptname"
  # cd into this directory to be sure
  cd "$fullpath_no_scriptname" || return
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]} pwd: $(pwd)"
  scriptname=$(basename "${BASH_SOURCE[0]}")
  scriptname_=${fullpath_with_scriptname##*/}
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]} \
    scriptname: $scriptname, $scriptname_"
  parent_directory=${fullpath_no_scriptname##*/}
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]} \
    parent_directory: $parent_directory"
  # running script: check that it is running in the right folder
  if [[ $parent_directory != 'qoolixiloopAgithub' ]]; then
    return 1
  fi
  return 0
}

read_continue_skip_return() {
  # ask whether to return from the script (exit will kill the terminal)
  echo "continue (c), skip(s), return (r)?"
  read -r answer
  case "$answer" in
    c) echo "continue"
      ;;
    r) echo "return"
      return 1
      ;;
    *) echo "type c: continue, s: skip, r: return" 
      ;;
  esac
  return 1
}

check_filelist(){
  # ----------------------------------------------------------------------------
  # Task II: 
  # 1. list of all Home.md files to which you will apply your script
  # ----------------------------------------------------------------------------
  # create a file list with all Home.md files
  local filelist="$1"
  echo "filelist: $filelist"
  # loop through list and print the file infos
  for file in $filelist; do
    # if $file exists (-e) go on
    # otherwise continue with next file in $filelist
    [ -e "$file" ] || continue
    echo "++this file (relative path): $file"
    fname=$(basename "$file")
    echo "++has the name: $fname"
    fdir=$(dirname "$file")
    echo "++and is in the directory: $fdir"
  done
  return 0
}

check_dirlist() {
  # ----------------------------------------------------------------------------
  # Task IV: 
  # 1. list of all directories to which you will apply your script
  # ----------------------------------------------------------------------------
  #create a file list with all the directories 
  local dirlist="$1"
  echo "dirlist: $dirlist"
  # loop through list and print the directory infos
  for directory in $dirlist; do
    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue
    echo ">>this directory (relative path): $directory"
    echo ">>pwd: $(pwd)"
    echo ">>ls directory: $(ls directory)"
  done
  return 0
}

sed_files_md() {
  # task: make changes on al Home.md files 
  # ----------------------------------------------------------------------------
  # sed "s/searchpattern/replacement/g" $filelist_home_md
  # sed "s/$1/$2/g $3
  # ----------------------------------------------------------------------------
  # input arguments
  local searchpattern=$1
  local replacment=$2
  local filelist=$3
  # backup folder
  local dirbak=$4
  # temporary file
  local filetmp="/tmp/out.tmp.$$"
  # make a backup directory, if it alreay exists move on
  [ ! -d $dirbak ] && mkdir -p $dirbak || :
  # loop through the $filelist
  for file in filelist; do
    # if $file is a file (-f) and (-a) readable (-r)
    if [ -f $file -a -r $file ]; then
      # make a backup copy of $file into $dirbak before applying sed
      /bin/cp -f $file $dirbak
      # apply sed substitution to $file to whole line (g)
      # avoid inline editing by writing into $filetmp
      sed "s/$searchpattern/$replacment/g" "$file" > $filetmp \
        && mv $filetmp "$file"
    # else if $file is not a file or not readable
    else
      echo "Error: cannot read $file"
    fi
  done
  # delete temporary file
  /bin/rm $filetmp
}

git_status__dirlist() {
# task: apply git status to all your directories
# ----------------------------------------------------------------------------
# git status
# ----------------------------------------------------------------------------
}

git_add__dirlist() {
# task: apply git add to all your directories
# ----------------------------------------------------------------------------
# git add .
# ----------------------------------------------------------------------------
}

git_commit_dirlist(){
# task: apply git commit to all your directories
# ----------------------------------------------------------------------------
# timestamp date
# git commit -m "batch run at $timestamp"
# ----------------------------------------------------------------------------
}
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# TODO: your main()
# -----------------------------------------------------------------------------
function main() {

	# Print doc or version strings if script is executed
	# with ---doc or with --version options and exit script.
	# $@ passes the command line arguments to the function
	# $? catches the return status of last command.
	# TODO: place your own options into the debug string
	get_options "$@";
	if [[ $? == 1 ]]; then exit 1; fi
	[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}: \
        $?", "$*", "$OUTPUTFILE", $DEBUG

	# TODO: The script's execution part goes here
	[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:main()" 


  # ----------------------------------------------------------------------------
  # Task I
  # 1. make sure you apply script to direcory qoolixiloopAgithub
  # ----------------------------------------------------------------------------
  load_file_vars
	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return
  
  # ----------------------------------------------------------------------------
  # Task II: 
  # ----------------------------------------------------------------------------
  # 1. list of all Home.md files to which you will apply your script
  local filelist_home_md="./*-loop.wiki/Home.md"
  check_filelist filelist_home_md
	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return

  # TODO: 2.1 give in the two variables
  searchpattern=''
  replacement=''
  # 2.2 apply sed to $flelist_home_md
  local dirbak_Home_md=./bak_Home_md/
  sed_files_md $searchpattern $replacement \
    $filelist_home_md $dirbak_Home_md
	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return

  # 3. check with replacements with diff 
	
  if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return


  # ----------------------------------------------------------------------------
  # Task III: 
  # ----------------------------------------------------------------------------
  # 1. list of all README.md files to which you will apply your script
  local filelist_README_md="./*-loop/README.md"
  gen_filelist filelist_README_md
	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return

  # TODO: 2.1 give in the two variables
  searchpattern=''
  replacement=''
  # 2.2 apply sed to filelist_README_md 
  local dirbak_README_md=./bak_README_md/
  sed_files_md $searchpattern $replacement \
    $filelist_README_md $dirbak_README_md
	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return

  # 3. check replacements with diff
	
  if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return


  # ----------------------------------------------------------------------------
  # Task IV: 
  # 1. list of all directories to which you will apply your script
  # ----------------------------------------------------------------------------
  local directorylist="./*-loop/"
  gen_dirlist__qoolixiloop
	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return





	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return





	if [[ $? == 1 ]]; then exit 1; fi
  read_continue_skip_return


  # Return with code 0
  return 0
}
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Python style: run main() if this script is executed but not if it is sourced
# -----------------------------------------------------------------------------
# with the following two line the main() function will be executed, when
# you execute the script with ./Scriptname.sh
# in all other cases, where the script is sourced, main() will not be run.
# -----------------------------------------------------------------------------
unset BASH_SOURCE 2>/dev/null
test ".$0" != ".${BASH_SOURCE[0]}" || main "$@"
# -----------------------------------------------------------------------------
if [[ $? == 1 ]]; then exit 1; fi
exit 0
