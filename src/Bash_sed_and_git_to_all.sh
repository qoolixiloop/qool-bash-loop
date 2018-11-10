#!/bin/bash



#==============================================================================
# Bash Script Template
# Roland Benz
# 9.Nov.2018
# -----------------------------------------------------------------------------
# Debug info:
#   For full debug mode start your script with the following command. 
#   | DEBUG='t'  : gives output for the code before main() can call get_options()
#   | --debug    : gives output for the code after that.
#   $ DEBUG='t' ./Scriptname.sh --debug
# Other options:
#   Version info: -v or --version
#   Doc info:     -d or --doc
#==============================================================================



#==============================================================================
# -----------------------------------------------------------------------------
# TODO: here is the place where you put you framework related functions
#         1.) version():          to print version info 
#         2.) doc():              to print documentation info
#         3.) get_options():      to parse your script options
#         4.) ask_user():         to navigate
#         5.) script_sourced_executed(): debug info
# -----------------------------------------------------------------------------
#==============================================================================

version() { # this function is called from get_options()
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # Version information
  # purpose: 
  #   -v or --version: running script with these options will print the info
  #
  # TODO: write version info into the heredoc, that is the part 
  #       between the EOF markers. Do not indent the last EOF!
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:version()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  	
  # Everything between the two EOF's will be printed 
	cat <<EOF
Author: Roland Benz
Version: 1
Date: 9 Nov.2018
EOF

# return 1 to indicate that the script shall terminate
return 1

}
# -----------------------------------------------------------------------------


doc() { #this function is called from get_options()

  #============================================================================
  # ---------------------------------------------------------------------------
  # Script information
  # purpose:
  #   -d or --doc: running script with these options will print the doc info
  # 
  # TODO: write about the overall purpose into the heredoc, that is the part
  #       between the EOF markers. Do not indent the last EOF!
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:doc()" 
  # ---------------------------------------------------------------------------
  #============================================================================
	
  # Everything between the two EOF's will be printed 
	cat <<EOF
your script description goes here
	and here
			and here
EOF
# return 1 to indicate that the script shall terminate
return 1

}
# -----------------------------------------------------------------------------


get_options() { # this function is called from main()

  #============================================================================
  # ---------------------------------------------------------------------------
  # Command line option parser
  # purpose:
  #   after starting this scipt this function will be called in main() 
  #   it reads your command line string, parses the options
  #   and acts as defined in the code below.
  # options parsed:
  #   the code below recoginizes:
  #     -v and --version :        to print version info (ex. for function call)
  #     -d and --doc:             to print doc info (ex. for function call)
  #     --verbose and --debug:    to print debug info (ex. for function call)
  #     -o and --output-file      to set the outputfile (ex. for global variable)
  #     -o= and --output-file=    to set the outputfile (ex. for global variable)
  #
  # TODO: adapt the function for your own script options
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:get_options" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # unset the varibles (in case they are loaded from somewhere)
  unset OUTPUTFILE
  unset DEBUG

  # As long as there is at least one more argument, keep looping
  while [[ $# -gt 0 ]]; do
    [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:start loop" 
    
    # check the command line arguments string $@
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
      # Also a flag type option. Will catch --verbose or --debug
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


ask_user() {

  #============================================================================
  # ---------------------------------------------------------------------------
  # For User Interaction
  # Purpose:
  #   Ask user wether he wants to:
  #     Continue: does nothing (go to next line)
  #     Return:   calls return statement (to leave the function or script)
  #     Skip:     can be used outside to skip the next code block  
  # Arguments:
  #     $1:       name of the next code block (will be printed)
  #     $2:       path/filename of a temporary file (used to return decision)
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:ask_user()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # print name of the next code block
  echo "$1" 
  
  # print instructions
  echo "continue (c), skip (s), return (r)?"
  
  # wait for, read and store user input into
  local ANSWER=''
  read -r $ANSWER
  
  # check users answer and act as explained in the function discription
  case "$ANSWER" in
    c) echo "continue" > "$2"
      ;;
    s) echo "skip" > "$2"
      ;;
    r) echo "return" > "$2"
      return 1
      ;;
    *) echo "type c: continue, s: skip, r: return" 
      ;;
  esac

  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


script_sourced_or_executed() {
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # Purpose:
  #   Function to check whether the script is sourced or executed
  #		  1) if you started your script with the command below on the command line
  #       the script will be sourced from bash and your main() will not 
  #       be executed. The same is true if you source this script into another
  #				script, main() will not be executed.
  #					$ . Scriptname.sh
  #     2) if you make the script executable and instead of sourcing it, execute
  #       it with the following commands the behaviour changes. With the lines 
  #       at the end of the script main() will then be run.
  #					$ chmod +x scriptname.sh
  #					$ ./scriptname.sh
  # Arguments:
  # Variables:
  #   DEBUG:        global variable (set in cmd line or with option --debug)
  #   LINENO:       line number (bash magic)
  #   BASH_SOURCE:  script name of sourced script (bash environment variable)
  #   0:            script name of executed script (command line argument)         
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sourced or executed?" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # compare basename of execution and source name 
  if [[ $(basename "$0") == $(basename "${BASH_SOURCE[0]}") ]]; then
    echo "--$LINENO executed"
  else
    echo "--$LINENO sourced from $0"
  fi

  return 0

}
# -----------------------------------------------------------------------------



#==============================================================================
# -----------------------------------------------------------------------------
# TODO: This is the place where you put your:
#         1.) sourced modules
#         2.) your executed modules
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sourced modules" 
# ----------------------------------------------------------------------------
#==============================================================================

# shellcheck disable=SC1091
# shellcheck source=./M_01.sh
#. ./M_01.sh
#. ./Script_2_scratch.sh
#. Script_2_scratch.sh
./Script_2_scratch.sh
# -----------------------------------------------------------------------------



#==============================================================================
# -----------------------------------------------------------------------------
# TODO: This is the place where to put your: 
#         1.) shell variables (have global scope in script and functions)
#             (define all other variables within functions with scope "local")
#         2.) function definitions (API)
#             load_file_vars():     generate filesystem related global vars
#             check_filelist():     check the file list
#             check_dirlist():      check the directory list
#             sed_files_md():       make substituion
#             git_status_dirlist(): apply git status to directory list
#             git_add_dirlist():    apply git add . to directory list
#             git_commit_dirlist()  apply git commit to directory list
#             main():               main function
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:function definitions" 
# ----------------------------------------------------------------------------
#==============================================================================

# ** GLOBAL VARIABLES **
# -----------------------------------------------------------------------------



# ** FUNCTIONS **
# -----------------------------------------------------------------------------


load_file_vars() {
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task I
  # Purpose:
  #   prints filesystem information 
  #   check the info to make sure you apply the script to the direcory 
  #   => qoolixiloopAgithub/ (hardcoded below)
  # ---------------------------------------------------------------------------  
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
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
    # return 1 to indicate that the script shall terminate
    return 1
  fi
  return 0

}
# -----------------------------------------------------------------------------


check_filelist(){
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task II and Task III: 
  # Purpose:
  #   makes a list of all files to which you will apply your script
  #   check the output before you move on
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:check_filelist()" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # create a file list with all Home.md files
  local filelist="$1"
  echo "filelist: $filelist"

  # loop through list and print the file infos
  for file in $filelist; do
    # if $file exists (-e) go on
    # otherwise continue with next file in $filelist
    [ -e "$file" ] || continue
  
    # print file infos
    echo "++this file (relative path): $file"
    fname=$(basename "$file")
    echo "++has the name: $fname"
    fdir=$(dirname "$file")
    echo "++and is in the directory: $fdir"
  
  done
  return 0

}
# -----------------------------------------------------------------------------


check_dirlist() {
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task IV: 
  # Purpose: 
  #   makes a list of all directories to which you will apply your script
  #   check the output before you move on
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:check_dirlist()"
  # ---------------------------------------------------------------------------
  #============================================================================

  #create a file list with all the directories 
  local dirlist="$1"
  echo "dirlist: $dirlist"

  # loop through list and print the directory infos
  for directory in $dirlist; do
  
    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue
  
    # print directory infos
    echo ">>this directory (relative path): $directory"
    echo ">>pwd: $(pwd)"
    echo ">>ls directory: $(ls directory)"
  done
  
  return 0

}
# -----------------------------------------------------------------------------


sed_files_md() {
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task II and Task III
  # Purpose:
  #   1.) make a backup of all files you pass to the function
  #   2.) make substitutions on all files you pass to the function
  #       |  it uses sed and uses the input arguments as follows:
  #       |    sed "s/$1/$2/g $3
  #       |  and reassigns them as follows:
  #       |    sed "s/searchpattern/replacement/g" "$filelist"
  # Arguments:
  #   $1: sed searchpattern
  #   $2: sed replacement
  #   $3: sed file list with all the files to apply your substitutions
  #   $4: backup directory for all your files
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sed_files_md()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # input arguments
  local searchpattern=$1
  local replacment=$2
  local filelist=$3
  local dirbak=$4  #backup folder
  
  # temporary file (will be deleted at the end of the function)
  local filetmp="/tmp/out.tmp.$$"
  
  # make a backup directory, if it alreay exists move on
  if [ ! -d "$dirbak" ]; then mkdir -p "$dirbak" || :; fi
  
  # loop through the file list
  for file in $filelist; do
    
    # if $file is a file (-f) and (&&) readable (-r)
    if [ -f "$file" ] && [ -r "$file" ]; then
      
      # make a backup copy of $file into $dirbak before applying sed
      # $file is a relative path with filename. Cut away the / and . 
      local tmp="${file%/*}_${file##*/}"
      local newfilename=${tmp##*/}
      /bin/cp -f "$file" "$dirbak/$newfilename"
      
      # apply sed substitution to $file to whole line (g)
      # avoid inline editing by writing into $filetmp
      sed "s/$searchpattern/$replacment/g" "$file" > $filetmp \
        && mv $filetmp "$file"
      
      # check replacements with diff
      diff "$file" "$dirbak/$newfilename"
      if [[ $? == 1 ]]; then return 1; fi
      ask_user 'next sed' "./tmp"
    
      # else if $file is not a file or not readable
    else
      echo "Error: cannot read $file"
    fi
  
  done
  
  # delete temporary file
  /bin/rm $filetmp
  
  return 0

}
# -----------------------------------------------------------------------------


git_status_dirlist() {
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task IV
  # Purpose:
  #   apply git status to all your directories
  #   it uses the shell function 
  #     $ git status
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # input arguments
  local dirlist="$1"
  
  # loop through the list of directories
  for directory in $dirlist; do
    
    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue
    
    # show status
    /usr/bin/git status
    ask_user 'next git status' "./tmp"
  done
  return 0

}
# -----------------------------------------------------------------------------


git_add_dirlist() {
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task IV
  # Purpose:
  #   apply git add . to all your directories
  #   it uses the shell function 
  #     $ git add .
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #============================================================================
 
  # input arguments
  local dirlist="$1"
  
  #loop through list of directories
  for directory in $dirlist; do
    
    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue
    
    # 
    /usr/bin/git add .

    # user interaction
    ask_user 'next git add' "./tmp"
  done
  retrn 0

}
# -----------------------------------------------------------------------------


git_commit_dirlist(){
  
  #============================================================================
  # ---------------------------------------------------------------------------
  # For Task IV
  # Purpose:
  #   apply git commit to all your directories
  #   it uses the shell function 
  #     $ timestamp date
  #     $ git commit -m "batch run at $timestamp"
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # input arguments
  local dirlist="$1"
  
  # loop through directory list
  for directory in $dirlist; do
    
    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue
    
    # execute task
    /usr/bin/git commit -m "$2"

    # user interaction
    ask_user 'next git commit' "./tmp"
  done
  return 0

}
# -----------------------------------------------------------------------------



function main() {

  #============================================================================
  # ---------------------------------------------------------------------------
  # Purpose:
  #   Here is the place where you call your functions.
  #   Every instrustruction, command or function is started here.
  #   (No code outside this function should be running automatically)
  #
  # TODO: create your own tasks, 
  #       try to outsource repetitive tasks into 
  # ---------------------------------------------------------------------------
  #============================================================================
	
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
  ask_user 'Task II.1' "./tmp"
  
  # ----------------------------------------------------------------------------
  # Task II: 
  # ----------------------------------------------------------------------------
  # 1. list of all Home.md files to which you will apply your script
  local filelist_home_md="./*-loop.wiki/Home.md"
  check_filelist "$filelist_home_md"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task II.2' "./tmp"

  # TODO: 2.1 give in the two variables
  searchpattern='Links to all other repositories'
  replacement='General topics'
  # 2.2 apply sed to $flelist_home_md
  local dirbak_Home_md=./bak_Home_md/
  sed_files_md "$searchpattern" "$replacement" \
    "$filelist_home_md" "$dirbak_Home_md"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task III.1' "./tmp"


  # ----------------------------------------------------------------------------
  # Task III: 
  # ----------------------------------------------------------------------------
  # 1. list of all README.md files to which you will apply your script
  local filelist_README_md="./*-loop/README.md"
  check_filelist "$filelist_README_md"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task III.2' "./tmp"

  # TODO: 2.1 give in the two variables
  searchpattern=''
  replacement=''
  # 2.2 apply sed to filelist_README_md 
  local dirbak_README_md=./bak_README_md/
  sed_files_md "$searchpattern" "$replacement" \
    "$filelist_README_md" "$dirbak_README_md"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task IV.1' "./tmp"


  # ----------------------------------------------------------------------------
  # Task IV: 
  # ----------------------------------------------------------------------------
  # 1. list of all directories to which you will apply your script
  local directorylist="./*-loop/"
  check_dirlist "$directorylist"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task IV.2' "./tmp"

  # 2. check status
  git_status_dirlist "$directorylist"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task IV.3' "./tmp"

  # 3. add
  git_add_dirlist "$directorylist"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task IV.4' "./tmp"

  # 4. check status
  git_status_dirlist "$directorylist"
	if [[ $? == 1 ]]; then exit 1; fi
  ask_user 'Task IV.5' "./tmp"

  #5. commit
  timestamp=date
  git_commit_dirlist "$directorylist" "batch run at $timestamp"
  if [[ $? == 1 ]]; then exit 1; fi
  ask_user "./tmp"

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
