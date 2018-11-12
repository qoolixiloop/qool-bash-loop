#!/bin/bash


#==============================================================================
#doc_begin---------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Bash Script: SED on md all files, git add, commit and push on all repos
# Framework: own template
# Syntax check: shellcheck
# Roland Benz
# 9.Nov.2018
# -----------------------------------------------------------------------------
#doc_end-----------------------------------------------------------------------
# Task to run: choose option -t or --task with value task_1 { _2, _3, _4}
# Debug info:
#   For full debug mode start your script with the following command. 
#   | DEBUG='t'  : gives output for the code before main() can call get_options()
#   | --debug    : gives output for the code after that.
#   $ DEBUG='t' ./Scriptname.sh --debug
# Other options:
#   Version info: -v or --version
#   Doc info:     -d or --doc
# Useful navigation keystokes in vim's normal mode
#   gd, gD:       jump to local, global function definition (word under cursor)
#   gf:           jump to file under cursor
#   Ctrl-o,-u,'': jump navigation history backwards, forwards, toogle
#   g*, g#:       search for next word under cursor
#   n, Shift-n    go to next search word forwards, backwards
# -----------------------------------------------------------------------------
#==============================================================================


#==============================================================================
# -----------------------------------------------------------------------------
# TODO: here is the place where you put you framework related functions
#         1.) version():          to print version info 
#         2.) doc():              to print documentation info
#         3.) generate_doc()      to automatically parse the script with AWK
#         4.) get_options():      to parse your script options
#         5.) ask_user():         to navigate
#         6.) script_sourced_executed(): debug info
# -----------------------------------------------------------------------------
#==============================================================================

version() { # this function is called from get_options()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # version(): prints version information
  # purpose: 
  #   -v or --version: running script with these options will print the info
  #
  # TODO: write version info into the heredoc, that is the part 
  #       between the EOF markers. Do not indent the last EOF!
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:version()" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # Everything between the two EOF's will be printed 
  cat << ____EOF
    Author: Roland Benz
    Version: 1
    Date: 9 Nov.2018
____EOF

  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


doc() { #this function is called from get_options()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # doc(): prints script information
  # purpose:
  #   -d or --doc: running script with these options will print the doc info
  # 
  # TODO: write about the overall purpose into the heredoc, that is the part
  #       between the EOF markers. Do not indent the last EOF!
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:doc()" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # Everything between the two EOF's will be printed 
  cat <<____EOF
    
    # =========================================================================
    # I use this script for the GitHub repositories:
    #  - I can apply the same substitution on all md files with sed.
    #      For each file a backup copy is made and 
    #      the changes made are printed by applying diff command.
    #  - I can apply git commands on all repositories.
    #  - I can start the script for different tasks 
    #      depending on the command line options
    #  - After each step there is a user interaction, which asks
    #      whether to continue or to stop the script.
    # =========================================================================
____EOF

  # print load function description
  generate_doc "$1"

  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


generate_doc() { # called by the function doc()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # generate_doc(): function description parser
  # purpose:
  #  Used to generate all the function descriptions for the doc option.
  #  It prints the descriptions when the script is called with the following
  #  command line option:
  #     --doc or -d   # this calles the function doc() which then calls this
  #                     function.
  #
  #  The code in this function parses through this whole script and prints
  #  each text, for which it finds the two markers doc._begin and doc._end
  #
  # TODO: set the markers "doc._begin" and "doc._end" for each text
  #       you would like to have printed
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:get_options" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # line 1: awk call
  # line 2-6: feed arguments into awk code
  # line 7: single quotes to start AWK program
  # line 8-15: BEGIN block, do this before file is read
  # line 16-17: filters applied on every line in the files
  # line 18-24: BODY block, do this for every line in the file
  # line 25-27: END block, do this after file is read
  # line 28: single quote to end AWK program
  #          and file name to which to apply the AWK program
  # Remarks: 1. bash variable as well as command line variables can be 
  #             fed into AWK. 
  #          2. use a backslash for at the end of each line for options
  #          3. within the string use the backslash for special charcters
  #          4. try to make one statement per line and end it with a
  #             semicolon. Backslash to cut a statement into two lines 
  #             works, but bash sytax check might compain.

  date="11.Nov.2018"
  commandLineOption="$1"
  awk \
    -v arg1="\t# Docu: \t automatically generated" \
    -v arg2="${BASH_SOURCE[0]}" \
    -v arg3="\t# Author: \t Roland Benz" \
    -v arg4="$date" \
    -v arg5="$commandLineOption" \
    '
      BEGIN {
        ORS="\n";
        print ("\n\t\t#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        print ("\t" arg1 "\n\t" "\t# Script: \t " arg2 "\n");
        print ("\t\t# Command line option: \t " arg5 "\n\t");
        print ("\t" arg3 "\n\t" "\t# Date: \t " arg4 "\n");
        print ("\n\t\t#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
      };
      /doc_begin/{doc=1;doc_b=1;doc_e=0;next;};
      /doc_end/{doc=0;doc_b=0;doc_e=1;next};
      {
        if (doc_b==1) {print ("..")};
        if (doc==1) {print (NR-1 "\t"  $0)};
        if (doc_e==1) {print ("..")};
        doc_b=0;
        doc_e=0;
      };
      END {
      print ("\n" "end of script." "\n");
      };
    ' "${BASH_SOURCE[0]}"

  # returns the status of the last command
  return

}


get_options() { # this function is called from main()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # get_options(): Command line option parser
  # purpose:
  #   after starting this scipt this function will be called in main() 
  #   it reads your command line string, parses the options
  #   and acts as defined in the code below.
  # options parsed:
  #   the code below recoginizes:
  #     -v and --version :        to print version info (ex. for function call)
  #     -d and --doc:             to print doc info (ex. for function call)
  #     --verbose and --debug:    to print debug info (ex. for function call)
  #     -t and --task             to start at task 1, 2, 3 or 4
  #     -o and --output-file      to set the outputfile (ex. for global variable)
  #     -o= and --output-file=    to set the outputfile (ex. for global variable)
  #
  # TODO: adapt the function for your own script options
  #       only make an extra shift when an option takes a value (--option value)
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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
        doc "$1"
        [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:printed doc" 
        return 1
      ;;
      # Also a flag type option. Will catch --verbose or --debug
      --verbose|--debug)
        # Set global variable DEBUG to 'y' 
        DEBUG='y'
        [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:set DEBUG='y'" 
      ;;
      # This is an arg value type option.
      # Will catch -t value or --task value
      -t|--task)
        # Set global variable START_AT_TASK by shifting first
        shift # past the key and to the value
        START_AT_TASK="$1"
      ;;
      # This is an arg value type option.
      # Will catch -o value or --output-file value
      -o|--output-file)
        # Set the global variable OUTPUTFILE by shifting first
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
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # ask_user(): For User Interaction
  # Purpose:
  #   Ask user wether he wants to:
  #     Continue: does nothing (go to next line)
  #     Return:   calls return statement (to leave the function or script)
  #     Skip:     can be used outside to skip the next code block  
  # Arguments:
  #     $1:       name of the next code block (will be printed)
  #     $2:       path/filename of a temporary file (used to return decision)
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:ask_user()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # print name of the next code block
  echo "$1" 
  
  # print instructions
  echo "continue (c), skip (s), return (r)?"
  
  # wait for, read and store user input into
  local ANSWER
  
  # check users answer and act as explained in the function discription
  # endless loop until c, s, or r are entered
  while true; do
    read -r ANSWER
    case "$ANSWER" in
      c) echo "continue"   > "$2"
        return 0
        ;;
      s) echo "skip (not implemented, same as return"   > "$2"
        return 1
        ;;
      r) echo "returns"   > "$2"
        return 1
        ;;
      *) echo "type c: continue, s: skip, r: return" 
        ;;
    esac
  done
  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


script_sourced_or_executed() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # scripts_sourced_or executed():
  # Purpose:
  #   Function to check whether the script is sourced or executed
  #		  1) if you started the script with the command below on the command line
  #       then the script will be sourced from bash and your main() will not 
  #       be executed. The same is true if you source this script into another
  #				script, main() will not be executed.
  #					$ . Scriptname.sh
  #     2) if you make the script executable and instead of sourcing it, 
  #        executing it with the following commands, the behaviour changes.
  #        With the lines at the end of the script main() will then be run.
  #					$ chmod +x scriptname.sh
  #					$ ./scriptname.sh
  # Arguments:
  # Variables:
  #   DEBUG:        global variable (set in cmd line or with option --debug)
  #   LINENO:       line number (bash magic)
  #   BASH_SOURCE:  script name of sourced script (bash environment variable)
  #   0:            script name of executed script (command line argument)
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sourced?, executed?"
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
# -----------------------------------------------------------------------------
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
#             git_push_dirlist():   apply git push to directory list
#             main():               main function
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:function definitions" 
# -----------------------------------------------------------------------------
#==============================================================================

# ** GLOBAL VARIABLES **
# -----------------------------------------------------------------------------



# ** FUNCTIONS **
# -----------------------------------------------------------------------------


load_file_vars() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # load_file_vars(): For Task I
  # Purpose:
  #   prints filesystem information 
  #   check the info to make sure you apply the script to the direcory 
  #   => qoolixiloopAgithub/ (hardcoded below)
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #=============================== ============================================

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
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # check_filelist(): For Task II and Task III: 
  # Purpose:
  #   makes a list of all files to which you will apply your script
  #   check the output before you move on
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # check_dirlist(): For Task IV: 
  # Purpose: 
  #   makes a list of all directories to which you will apply your script
  #   check the output before you move on
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # sed_files_md(): For Task II and Task III
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
  #doc_end---------------------------------------------------------------------
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
      # if file exists make a backup filename.~1~/~2~/...
      local tmp="${file%/*}_${file##*/}"
      local newfilename=${tmp##*/}
      /bin/cp --backup=t "$file" "$dirbak/$newfilename"
      echo "made copy: $newfilename (and backup if file existed)"

      # apply sed substitution to $file to whole line (g)
      # avoid inline editing by writing into $filetmp
      sed "s/$searchpattern/$replacment/g" "$file" > $filetmp \
        && mv $filetmp "$file"
      echo "checked file: $file (if you see no diff no changes were made)"

      # check replacements with diff
      diff "$file" "$dirbak/$newfilename"
      ask_user 'next sed' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi
            

      # else if $file is not a file or not readable
    else
      echo "Error: cannot read $file"
    fi

  done

  # delete temporary file if it not exist || move on
  /bin/rm -v -i $filetmp || true

  return 

}
# -----------------------------------------------------------------------------


git_status_dirlist() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_status_dirlist(): For Task IV
  # Purpose:
  #   apply git status to all your directories
  #   it uses the shell function 
  #     $ git status
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_add_dirlist(): For Task IV
  # Purpose:
  #   apply git add . to all your directories
  #   it uses the shell function 
  #     $ git add .
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_commit_dirlist(): For Task IV
  # Purpose:
  #   apply git commit to all your directories
  #   it uses the shell function 
  #     $ timestamp date
  #     $ git commit -m "batch run at $timestamp"
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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


git_push_dirlist(){

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_push_dirlist(): For Task IV
  # Purpose:
  #   apply git push to all your directories
  #   it uses the shell function 
  #     $ git push
  # Arguments:
  #   $1:   list of all directories to apply the job
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
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
    /usr/bin/git push

    # user interaction
    ask_user 'next git push' "./tmp"
  done
  return 0

}
# -----------------------------------------------------------------------------



function main() {

  #============================================================================
  #doc_begin_main--------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # main()
  # Purpose:
  #   Here is the place where you call your functions.
  #   Every instrustruction, command or function is started here.
  #   (No code outside this function should be running automatically)
  #
  # TODO: create your own tasks, 
  #       try to outsource repetitive tasks into 
  # ---------------------------------------------------------------------------
  #doc_end_main----------------------------------------------------------------
  #============================================================================

  # ---------------------------------------------------------------------------
  # Framework related tasks
  # Purpose:
  #   get_options:  parses the command line sting 
  #                 reads passed option arguments and takes defined action:
  #                   - prints doc or version strings if script is executed
  #                     with ---doc or with --version options and exits script.
  #                   - prints debug info if script is run with --debug option
  #                 $@: passes the command line arguments to the function
  #                 $?: catches the return status of last command.
  #
  # TODO: place your own options into the debug string
  # ---------------------------------------------------------------------------

  get_options "$@";
  if [[ $? == 1 ]]; then exit 1; fi
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}: \
        $?", "$*", "$OUTPUTFILE", $DEBUG

  #doc_begin_main--------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # main(): user related tasks
  # Purpose
  #  Task I:    load file system variables
  #  Task II:   apply sed to all Home.md files
  #  Task III:  apply sed to all README.md files
  #  Task IV:   apply git add . and git commit, git push to all repos
  #
  # TODO: place your own options into the debug string
  # ---------------------------------------------------------------------------
  #doc_end_main----------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:main()" 
  # ---------------------------------------------------------------------------


  case "$START_AT_TASK" in
    #doc_begin_main------------------------------------------------------------
    # -------------------------------------------------------------------------
    # Task I
    #   make sure you apply script to direcory qoolixiloopAgithub
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    task_1|Task_1|task1|Task1|t1|T1|1)
      load_file_vars
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task II.1' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # and leave (;;) or  move on (;&) 
      ;&
    #doc_begin_main------------------------------------------------------------
    # -------------------------------------------------------------------------
    # Task II:
    #  apply sed to all Home.md files  
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    task_2|Task_2|task2|Task2|t2|T2|2) 
      # 1. list of all Home.md files to which you will apply your script
      local filelist_home_md="./*-loop.wiki/Home.md"
      check_filelist "$filelist_home_md"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task II.2' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # 2.1 give in the two variables TODO:
      searchpattern='Links to all other repositories'
      replacement='General topics'

      # 2.2 apply sed to $flelist_home_md
      #     for each file change the diff will be printed
      #     after every diff there is a user interaction
      local dirbak_Home_md=./bak_Home_md/
      sed_files_md "$searchpattern" "$replacement" \
        "$filelist_home_md" "$dirbak_Home_md"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction 
      ask_user 'Task III.1' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # and leave (;;) or  move on (;&)
      ;;
    #doc_begin_main------------------------------------------------------------
    # -------------------------------------------------------------------------
    # Task III:
    #   apply sed to all README.md files 
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    task_3|Task_3|task3|Task3|t3|T3|3)
      # 1. list of all README.md files to which you will apply your script
      local filelist_README_md="./*-loop/README.md"
      check_filelist "$filelist_README_md"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task III.2' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # 2.1 give in the two variables TODO:
      searchpattern=''
      replacement=''

      # 2.2 apply sed to filelist_README_md 
      #     for each file change the diff will be printed
      #     after every diff there is a user interaction
      local dirbak_README_md=./bak_README_md/
      sed_files_md "$searchpattern" "$replacement" \
        "$filelist_README_md" "$dirbak_README_md"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task IV.1' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # and leave (;;) or  move on (;&)
      ;;
    #doc_begin_main------------------------------------------------------------
    # -------------------------------------------------------------------------
    # Task IV: 
    #   apply git add ., git commit, git push to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    task_4|Task_4|task4|Task4|t4|T4|4) 
      # 1. list of all directories to which you will apply your script
      local directorylist="./*-loop/"
      check_dirlist "$directorylist"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task IV.2 git status' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # 2. check status
      git_status_dirlist "$directorylist"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task IV.3 git add' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # 3. add
      git_add_dirlist "$directorylist"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task IV.4 git status' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      # 4. check status
      git_status_dirlist "$directorylist"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user 'Task IV.5 git commit' "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      #5. commit
      timestamp=date
      git_commit_dirlist "$directorylist" "batch run at $timestamp"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # user interaction
      ask_user "$directorylist" "./tmp"
      if [[ $? == 1 ]]; then echo "exit: $LINENO"; exit 1; fi

      #6. push
      git push_dirlist "$directorylist"
      if ! $?; then echo "exit: $LINENO"; exit 1; fi

      # Return with code 0
      return 0

      # and leave (;;) or  move on (;&)
      ;;
    *)
      echo "enter: -t task_1, -t task_2, -t task_3 or -t task_4"
      ;;
  esac
}
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Python style: run main() if this script is executed but not if it is sourced
# -----------------------------------------------------------------------------
# I) With the following two lines of code the main() function will be executed,
#    when you EXECUTE the script "Scriptname" with ./Scriptname.sh
#    in all other cases, where the script is sourced, main() will not be run.
#    Let's take a look what the two lines mean:
#       unset BASH_SOURCE 2>/dev/null
#       test ".$0" != ".${BASH_SOURCE[0]}" || main "$@"
#    The first of the two lines tries to unset BASH_SOURCE, if that works out,
#    your script is most certainly somewhere it should not be, and main() is 
#    not called. 
#    The second line tests the condition ".$0" != ".${BASH_SOURCE[0]}". Because
#    BASH_SOURCE is a reversed stack, this condition is true when the script is
#    sourced (from another script). The reason is, because then $0 holds the
#    name of the executed and "${BASH_SOURCE[0}}" the name of the sourced
#    script. If you source your script on the command line with 
#    $ . ./Scriptname or $ . Scriptname, then bash is executing your script and
#    $0 holds the name "-bash". The two bars ( || ) mean that the expression on 
#    the right side is only executed, when the left side is false.
#    Check out the following four cases
#      test 1 == 1 || echo test1   # not printed
#      test 1 == 2 || echo test2   # printed
#      test 1 == 1 && echo test1   # printed
#      test 1 == 2 && echo test2   # printed
#
# II)A side note with respect to command line arguments stored in "$@":
#      The command line string's scope is the script. It is not visible inside
#      any function. There are at least three ways to access the arguments.
#      1.) store them into a global variable args=("$@") and access them 
#          inside the function with "${args[0]}", "${args[1]}", ...
#          $@ does NOT contain the calling script as first argument, and 
#          therefore "${args[0]}" does not contain the calling script.
#      2.) pass them as "$@" as has been done below for the main() function.
#          pass additional arguments before $@, like so:
#           func "$arg1" "$arg2" "$arg3" "$@"
#           after processing the three arguments use shift 3 then you can 
#            access them with the same numbers as in the scope of the script
#      3.) pass them as arguments to the function, i.e. as "$0", "$1", ...
#          but be careful not to change the order, e.g. like so, $3, $1, $2
#          because then you would have to access command line argument $3 with
#          $1 inside the function, and that's a bit of a mess.
#      4.) in extended debug mode (e.g., #!/bin/bash -O extdebug) or with shopt
#          (e.g., shopt -s extdebug) there is a global variable BASH_ARGV which
#          you can access.
#    In this script I use 2.) when I need all command line arguments and 3.) if 
#    if I only need a subset.
# -----------------------------------------------------------------------------
unset BASH_SOURCE 2>/dev/null
test ".$0" != ".${BASH_SOURCE[0]}" || main "$@"
# -----------------------------------------------------------------------------
if [[ $? == 1 ]]; then exit 1; fi
exit 0
