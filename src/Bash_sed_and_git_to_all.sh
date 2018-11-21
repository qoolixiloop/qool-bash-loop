#!/bin/bash
#shellcheck disable=SC2015

#==============================================================================
#doc_begin---------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Bash Script:  SED substitution on all md files.
#               Git status, add, commit and push on all repos.
#               Automatic generation of docs.
# Framework:    own template
# Syntax check: shellcheck
# Autor:        Roland Benz
# Date:         9.Nov.2018
# -----------------------------------------------------------------------------
#doc_end-----------------------------------------------------------------------
#help_begin--------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Ways to run the script: 
#   1.) to get help:         $ ./Scriptname --help
#   2.) to get version info: $ ./Scriptname --version (or -v)
#   3.) to get doc info:     $ ./Scriptname --doc
#   4.) to run tasks:        get a complete task list with --help option
#   4.1)   general cases:    $ ./Scriptname --task task_1_ { _3_, _4_ }
#   4.2)   special cases:    $ SEARCH="mySearch" REPLACE="myReplacment" \
#          (with global vars)    ./Scriptname --task_2_ { home_md, readme_md }
#   5.) run with debug info: $ DEBUG='y' ./Scriptname --debug
# 
# Show debug info:
#   For full debug mode start your script with the following command. 
#   | Command line: $ DEBUG='t' ./Scriptname.sh --debug
#   | DEBUG='t'   : gives output for the code before main() calls get_options()
#   | --debug     : gives output for the code after that.
#   or start the script with: $ bashdb bashdb-options -- script script-args
#
# Useful navigation keystokes in vim's normal mode:
#   gg, Shift-g   jump to start, end
#   gd, gD:       jump to local, global function definition (word under cursor)
#   gf:           jump to file under cursor
#   Ctrl-o,-i,'': jump navigation history backwards, forwards, toogle
#   g*, g#:       search for next word under cursor
#   n, Shift-n    go to next search word forwards, backwards
#
# Vim manual folding: 
#   zD, zf        delete, create fold (in visual mode)
#   zM, zr, za    close, open all folds, toggle folds
# -----------------------------------------------------------------------------
#help_end----------------------------------------------------------------------
#==============================================================================


#==============================================================================
#doc_begin---------------------------------------------------------------------
# -----------------------------------------------------------------------------
# TODO: here is the place where you put you framework related functions
#         1.) version():          to print version info 
#         2.) doc():              to print documentation info
#         3.) generate_doc()      to automatically parse the script with AWK
#         4.) get_options():      to parse your script options
#         5.) ask_user():         to navigate
#         6.) script_sourced_executed(): debug info
# -----------------------------------------------------------------------------
#doc_end-----------------------------------------------------------------------
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
    Author:  Roland Benz
    Version: 1.0.0
    Date:    12. Nov.2018
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
  #   --doc: running script with this options will print the doc info
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
    #      depending on the command line options.
    #  - I can print a list of tasks with --help (or --doc) option
    #  - After each step there is a user interaction, which asks
    #      whether to continue or to stop the script.
    # =========================================================================
____EOF

  # print function descriptions
  generate_doc "$1" "${1##*-}"
  
  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


generate_doc() { # called by the function doc()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # generate_doc(): this is a parser
  #
  # purpose:
  #  1.) Used to generate all the function descriptions for the doc option.
  #  2.) Used to generate the descriptions for the help option. 
  #
  # How it is called:
  #  It prints the descriptions when the script is called with the 
  #  following command line option:
  #    --doc   # this calls the function doc() which then calls this
  #              function.
  #    --help  # this calls the function help() which then calls this
  #              function.
  #
  # How it works:
  #  The code in this function parses through this whole script and prints
  #  each text, for which it finds the two markers doc._begin and doc._end
  #  for the doc() and the two markers help._begin and help._end for the help()
  #  (on a side note: the dot in (help._ instead of help_) is necessary so that 
  #  the lines the line above and below is not printed by this function)
  #
  # TODO: set the markers "doc._begin", "doc._end", "help._begin", "help._end"
  #       for each text you would like to have printed
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
  #             (these take only bash variables or match() must be used.)
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
  docType="$2"
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
      /'"$docType"'_begin/{doc=1;doc_b=1;doc_e=0;next;};
      /'"$docType"'_end/{doc=0;doc_b=0;doc_e=1;next};
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
# -----------------------------------------------------------------------------


ihelp() { # this function is calle from get_options()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # ihelp(): prints script information
  #          (you will see all the available tasks, this scrip can run)
  # purpose:
  #   --help: running script with this options will print the help info
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:doc()" 
  # ---------------------------------------------------------------------------
  #============================================================================
  
  # print function descriptions.
  # in the right variable you see bash style to cut the string stored in $1 
  generate_doc "$1" "${1##*-}"

  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


get_options() { # this function is called from main()

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # get_options(): Command line option parser
  #
  # purpose:
  #   after starting this scipt this function will be called in main() 
  #   it reads your command line string, parses the options
  #   and acts as defined in the code below.
  #
  # options parsed:
  #   the code below recoginizes:
  #     -v and --version :        to print version info (ex. for function call)
  #     --doc:                    to print doc info (ex. for function call)
  #     --help:                   to print help info (ex. for function call)
  #     --verbose and --debug:    to print debug info (ex. for function call)
  #     -t and --task             to start script at task a particular task
  #     -o and --output-file      to set the outputfile (ex. for global variable)
  #     -o= and --output-file=    to set the outputfile (ex. for global variable)
  #                               (not implemented, just here as examples)
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
  # -gt is used if string ($#) shall be interpreted as integer
  while [[ $# -gt 0 ]]; do
    [[ $DEBUG == 'y' ]] && \
      echo "--$LINENO ${BASH_SOURCE[0]}:start loop" || true

    # check the command line arguments string $@
    key="$1"
    case "$key" in

      # This is a flag type option. Will catch either -f or --foo
      -v|--version)

      # call function to print version info
      version
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:printed version" || true

      # return 1 to indicate that the script shall terminate
      return 1

      ;;

      # Also a flag type option. Will catch either -h or --help
      --help)

      # call function to print help info
      ihelp "$1"
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:printed help" || true

      # return 1 to indicate that the script shall terminate
      return 1

      ;;
      # Also a flag type option. Will catch either -d or --doc
      --doc)

      # call function to print doc info
      doc "$1"
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:printed doc" || true

      # return 1 to indicate that the script shall terminate
      return 1

      ;;

      # Also a flag type option. Will catch --verbose or --debug
      --verbose|--debug)

      # Set global variable DEBUG to 'y' 
      DEBUG='y'
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:set DEBUG='y'" || true

      ;;

      # This is an arg value type option.
      # Will catch -t value or --task value
      -t|--task)

      # Set global variable START_AT_TASK by shifting first
      shift # past the key and to the value
      START_AT_TASK="$1"; echo "$START_AT_TASK"

      ;;

      # This is an arg value type option.
      # Will catch -c value or --cmd value
      -c|--cmd)

      # Set global variable TASK_2_COMMAND by shifting first
      shift # past the key and to the value
      TASK_2_COMMAND="$1"; echo "$TASK_2_COMMAND"

      ;;

      # This is an arg value type option.
      # Will catch -o value or --output-file value
      -o|--output-file)

      # Set the global variable OUTPUTFILE by shifting first
      shift # past the key and to the value
      OUTPUTFILE="$1"
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:set OUTPUTFILE" || true

      ;;

      # This is an arg=value type option. 
      # Will catch -o=value or --output-file=value
      -o=*|--output-file=*)

      # No need to shift here since the value is part of the same string
      OUTPUTFILE="${key#*=}"
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:set OUTPUTFILE" || true

      ;;

      # If nothing else matches, get in here
      *)
      echo "Unknown option '$key'"
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:hit unknown option" || true

      # return 1 to indicate that the script shall terminate
      return 1

      ;;

    esac

    # Shift after checking all the cases to get the next option
    shift

  done

  # return status of the last statement executed.
  # Important: make sure any line of debugging code always returns true (0)
  # otherwise parts may only run in debug mode, and others not at all.
  # this line a && b || c is always true, it means: 
  #     if a is false go to c. 
  #     if a is true go to b.
  #     if b is false go to c
  # but shellcheck warns about it, thats why in line 2, SC2015 is disabled
  [[ $DEBUG == 'y' ]] && 
    echo "--$LINENO ${BASH_SOURCE[0]}:return" || true

  return

}
# -----------------------------------------------------------------------------


ask_user() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # ask_user(): For user interaction
  #
  # Purpose:
  #   Ask user wether he wants to:
  #     Continue: does nothing (go to next line)
  #     Return:   calls return statement (to leave the function or script)
  #     Skip:     can be used outside to skip the next code block  
  #
  # Arguments:
  #     $1:       name of the next code block (will be printed)
  #     $2:       line number of the code that called this function
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:ask_user()" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # assign input output variable to local variable
  local __in_out="$3"

  # print line number and name of the next code block
  echo; echo "$2" "$1" 

  # print instructions
  echo " apply (a), skip loop (c), skip function (b), terminate script (t)?"

  # wait for, read and store user input into
  local ANSWER

  # check users answer and act as explained in the function discription
  # endless loop until a, b, c, or t are entered
  while true; do
    read -r ANSWER
    case "$ANSWER" in
      a) echo "a"
        #return C Style with eval
        if [[ "$__in_out" ]]; then
          #shellcheck disable=2086
          eval $__in_out='a'
        else
          echo "you forgot to pass in an output argument"
          return 1
        fi
        return
        ;;
      c) echo "c"
        #return C Style with eval
        if [[ "$__in_out" ]]; then
          #shellcheck disable=2086
          eval $__in_out='c'
        else
          echo "you forgot to pass in an output argument"
          return 1
        fi
        return
        ;;
      b) echo "b"
        #return C Style with eval
        if [[ "$__in_out" ]]; then
          #shellcheck disable=2086
          eval $__in_out='b'
        else
          echo "you forgot to pass in an output argument"
          return 1
        fi
        return
        ;;
      t) echo "t"
        #return C Style with eval
        if [[ "$__in_out" ]]; then
          #shellcheck disable=2086
          eval $__in_out='t'
        else
          echo "you forgot to pass in an output argument"
          return 1
        fi
        return
        ;;
      *) echo \
        "apply (a), skip loop (c), skip function (b), terminate script (t)?"
        ;;
    esac
  done

  # this line should never be reached
  # return 1 to indicate that the script shall terminate
  return 1

}
# -----------------------------------------------------------------------------


script_sourced_or_executed() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # scripts_sourced_or executed():
  #
  # Purpose:
  #   Function to check whether the script is sourced or executed
  #     1) if you started the script with the command below on the command line
  #        then the script will be sourced from bash and your main() will not 
  #        be executed. The same is true if you source this script into another
  #        script, main() will not be executed.
  #          $ . Scriptname.sh
  #     2) if you make the script executable and instead of sourcing it, 
  #        executing it with the following commands, the behaviour changes.
  #        With the lines at the end of the script main() will then be run.
  #          $ chmod +x scriptname.sh
  #          $ ./scriptname.sh
  #
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
    echo; echo "--$LINENO executed"
  else
    echo; echo "--$LINENO sourced from $0"
  fi

  # return status of the last statement executed
  return

}
# -----------------------------------------------------------------------------



#==============================================================================
#doc_begin---------------------------------------------------------------------
# -----------------------------------------------------------------------------
# TODO: This is the place where you put your:
#         1.) sourced modules (need not to be executable, but can be)
#             they are started in the current shell (script or -bash). 
#             any variable you export , any directory you change take affect 
#             in the current shell. 
#             when the script stops they are still visible. 
#               source or . filename
#         2.) your executed modules (need to be executable +x flag)
#             they are started in a new shell. any variable you export, any
#             directory you change is only visible as long a the script runs.
#             i.e. the environment of the calling script is not affected.
#               ./filename  (./ means current directory)
#               filename    (not necessary when directory is in $PATH)
#
# Additional comments:
#         3.) the following script prints the process number. 
#             if sourced, that of the current shell. 
#             if executed that of a newly created subshell.
#                #!/bin/sh echo $$
#         4.) if you have two scripts a and b, and you start a, the only way 
#             the current starting shell is affected by b, is when both a and
#             b are sourced.
#         5.) $(func) also starts a subshell to execute func. But in this case
#             not even the echos in func() are visible in the current shell.
#
#Examples and shellcheck behaviour:
# shell.check disable=SC1091   # if shell.check complains about sourcing
# shell.check source=./M_01.sh # this has no affect, shellcheck still complains
#. ./M_01.sh                  # this means source M_01.sh
#./M_01.sh                    # this means executing M_01.sh
# -----------------------------------------------------------------------------
#doc_end-----------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sourced modules" 
# -----------------------------------------------------------------------------
#==============================================================================

# shellcheck disable=SC1091



# -----------------------------------------------------------------------------



#==============================================================================
#doc_begin---------------------------------------------------------------------
# -----------------------------------------------------------------------------
# TODO: This is the place where to put your: 
#
#       1.) shell variables (have global scope in script and functions)
#           (define all other variables within functions with scope "local")
#
#       2.) function definitions (API)
#           load_file_vars():         generate filesystem related global vars
#           check_filelist():         check the file list
#           check_dirlist():          check the directory list
#           sed_in_files_md():      make substituion
#           git_status_dirlist():     apply git status to directory list
#           git_add_dirlist():        apply git add . to directory list
#           git_commit_dirlist():     apply git commit to directory list
#           git_push_dirlist():       apply git push to directory list
#           git_all_steps_dirlist():  apply all git steps
#           main():                   main function
# -----------------------------------------------------------------------------
#doc_end-----------------------------------------------------------------------
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
  #   prints filesystem information in order to visually check:
  #     => to make sure you apply the script to the right direcory 
  # Arguments:
  #   $1: directory the script must be and run (take no risks)
  #     => qoolixiloopAgithub/ (that's my local directory)
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #=============================== ============================================

  echo "--------------------------------------------------------------"
  # running script: extract filename and path information
  fullpath_with_scriptname=$(realpath "${BASH_SOURCE[0]}")
  echo; echo "--$LINENO \
    fullpath_with_scriptname: $fullpath_with_scriptname"

  relativepath_no_scriptname=$(dirname "${BASH_SOURCE[0]}")
  echo "--$LINENO \
    relativepath_no_scriptname: $relativepath_no_scriptname"

  fullpath_no_scriptname=${fullpath_with_scriptname%/*}
  echo "--$LINENO \
    fullpath_no_scriptname: $fullpath_no_scriptname"

  # cd into the script directory (to be sure)
  cd "$fullpath_no_scriptname" || return
  echo "--$LINENO \
    pwd: $(pwd)"
  scriptname=$(basename "${BASH_SOURCE[0]}")
  scriptname_=${fullpath_with_scriptname##*/}
  echo "--$LINENO \
    scriptname: $scriptname"
  echo "--$LINENO \
    scriptname: $scriptname_"

  parent_directory=${fullpath_no_scriptname##*/}
  echo "--$LINENO \
    parent_directory: $parent_directory"
  echo "--------------------------------------------------------------"

  # make main() know, if script is running in the wrong directory
  if [[ $parent_directory != "$1" ]]; then
    
    # return 1 to indicate that the script shall terminate
    return 1
  
  fi
  
  # return status of the last statement executed
  return

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
  echo; echo "--$LINENO filelist: $filelist"; echo

  # loop through list and print the file infos
  for file in $filelist; do
    # if $file exists (-e) go on
    # otherwise continue with next file in $filelist
    [ -e "$file" ] || continue

    # print file infos
    echo "--$LINENO this file (relative path): $file"
    fname=$(basename "$file")
    echo "--$LINENO has the name: $fname"
    fdir=$(dirname "$file")
    echo "--$LINENO and is in the directory: $fdir"

  done
  
  # return status of the last statement executed
  return

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
  local pwd_script="$2"
  echo "--------------------------------------------------------------"
  echo; echo "--$LINENO dirlist: $dirlist"; echo
  echo "--------------------------------------------------------------"

  # loop through list and print the directory infos
  for directory in $dirlist; do

    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue

    # print directory infos
    echo "--------------------------------------------------------------"
    echo "--$LINENO this directory (relative path): $directory"
    echo "--$LINENO pwd: $(pwd)"
    echo "--$LINENO pwd_script: $pwd_script"
    echo "--$LINENO ls directory: $(ls "$directory")"
    echo "--------------------------------------------------------------"

  done

  # return status of the last statement executed
  return

}
# -----------------------------------------------------------------------------


sed_append_url(){
  
  # input arguments
  local file="$1"
  local filetmp="$2"
  local appendurl="$3"

  # grep extract qool-XXX-loop from string
  # -o: only print matching part
  local pattern_repositories="qool-.*-loop"
  local search_repository
  search_repository=$(echo "$appendurl" | grep -o "$pattern_repositories" )
  echo "search this repository: $search_repository"
  
  # pattern to search for (hard coded)
  local pattern
  pattern="^\[.*github\.com\/qoolixiloop\/$search_repository\/wiki.*wiki page"
  echo "pattern to search: $pattern"

  # print to variable: all matched lines
  local sed_found_matches
  sed_found_matches=$(sed -n "/$pattern/p" "$file")
  
  # print to variable: line numbers of all matched lines
  local sed_found_matches_on_lines
  sed_found_matches_on_lines=$(sed -n "/$pattern/{=;}" "$file")
    
  if [[ -n "$sed_found_matches"  ]]; then 
    
    echo "1.SED) found matches: ${sed_found_matches}"
    echo "2.SED) found matches on lines: ${sed_found_matches_on_lines}"
  
    # extract highest line number
    # $sed_found_matches_on_lines is a space separated string
    # -n: string(s) as numerical values
    local N
    N=$(echo "${sed_found_matches_on_lines}" | sort -n | tail -1)
    
    # apply sed: command $a $text to $file at line $N
    # avoid inline editing by writing into $filetmp
    local cmd="a"
    local text="$appendurl"
    sed "$N $cmd $text" "$file" >  "$filetmp" \
          && mv "$filetmp" "$file"
    
  fi
  
  # return status of the last statement executed
  return 

}
# -----------------------------------------------------------------------------


sed_in_files_md() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # sed_in_files_md(): For Task II and Task III
  # Purpose:
  #   1.)  make a backup of all files you pass to the function
  #   2.a) make substitutions on all files you pass to the function
  #        |  it uses sed and uses the input arguments as follows:
  #        |    sed "s/$1/$2/g $3
  #        |  and reassigns them as follows:
  #        |    sed "s/searchpattern/replacement/g" "$filelist"
  #   2.b) append new GitHub Wiki page URL to all Home.md and README.md
  # Arguments:
  #   $1: sed file list with all the files to apply your substitutions
  #   $2: backup directory for all your files
  #   $3: sed searchpattern
  #   $4: sed replacement
  #   $5: new wiki page url to append
  #  
  #-----------------------------------------------------------------------------
  # SED
  # ===
  # sed -options 'command' file
  # sed -options 'command' < infile > outfile
  # sed -options 'command1; command2' file
  # options:
  # -n do not print buffer/file
  # -i apply/print to file
  # -E or -r extended regular expression
  # commands for search and print, delete, append, insert:
  # N,M[!]p                         print OR [not] line(s)
  # /pattern/[!]p                   print or [not] pattern(s)
  # /pattern1/,/pattern2/[!]p       print or [not] between patterns
  # N,M[!]d  OR  N,M!d              delete OR [not] line(s) 
  # /pattern/[!]d                   delete OR [not] pattern(s)
  # /pattern1/,/pattern2/[!]d       delete OR [not] between patterns
  # N,M[!]a Text                    append Text OR [not] to lines(s) 
  # /pattern/[!]a Text              append Text OR [not] to pattern
  # /pattern1/,/pattern2/[!]a Text  append Text OR [not] between patterns
  # N,M[!]i Text                    insert Text OR [not] to line(s) 
  # /pattern/[!]i Text              insert Text OR [not] to pattern
  # /pattern1/,/pattern2/[!]i Text  insert Text OR [not] between patterns
  # /pattern/=                      print line numbers
  # { ; }                           list of commands colon separated
  # {p;q}                           print first (p) and quit (q)
  # 
  # command for search and replace on lines where pattern matches
  # Index,/pattern/s/search/replace/sr_options
  # Index
  # 0              apply only to first match
  # sr_options
  # g              apply to all search instances
  # n              apply only to nth search instance
  # p              print only replaced lines
  # w file         print to file
  #
  # apply only to first match
  # -n '/RE/{p;q;}' file       # print only the first match
  # '0,/RE/{//d;}' file        # delete only the first match
  # '0,/RE/s//to_that/' file   # change only the first match
  #
  # regex goups
  # search and replace only last occurence of search pattern in line
  # \1: print content of first braces
  # \2: print content of second braces
  # sed -r 's/(.*)search/\1replace/'
  # sed -r 's/(.*)search(.*)/\1replace\2/
  #
  # sort
  # ====
  # -r reverse the result 1,2,3 -> 3,2,1
  # -n string numerical value
  # -o write to file
  # -u unique
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sed_in_files_md()"
  # ---------------------------------------------------------------------------
  #============================================================================

  # input arguments
  local filelist=$1
  local dirbak=$2  #backup folder
  local searchpattern=$3
  local replacement=$4
  local appendurl=$5
  echo; echo "--$LINENO search pattern: $searchpattern"
  echo "--$LINENO replacement: $replacement";
  echo "--$LINENO appendurl: $appendurl";


  # temporary file: used for sed, and then moved
  # (if for some reason it still exists, 
  #  it will be deleted at the end of the function)
  local filetmp="/tmp/out.tmp.$$"

  # you may come across a line like the following. Ignore it.
  #   if [ ! -d "$dirbak" ]; then mkdir -p "$dirbak" || :; fi
  # the -p flag is doing all that already: it checks whether
  # the directory exists, if not creates it with all its parent
  # directories. If it exists it does not complain, just goes on.
  mkdir -p "$dirbak"

  # loop through the file list
  for file in $filelist; do

    # if $file is a file (-f) and (&&) readable (-r)
    # do not use depreciated "-a" for and use (&&)
    if [ -f "$file" ] && [ -r "$file" ]; then

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "next file to apply sed: $file"
      if ! ask_user 'next_sed' "$LINENO" answer; then
        echo "exit: $LINENO"; return 1; 
      fi
      if [[ "$answer" == "a" ]]; then echo "apply to this file"
      elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
      elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # make a new name with $file: it is a relative path incl. file name. 
      # cut the string three times to get "formerParentFolder_fileName"
      local newfilename_intermediate_step="${file%/*}_${file##*/}"
      local newfilename=${newfilename_intermediate_step##*/}

      # make a backup copy of $file into $dirbak before anything else.
      # $file is a relative path with filename.
      # the $newfilename string we have just created.
      # if $newfilename already exists  in the filesystem, 
      # make a backup filename.~1~/~2~/... (--backup=t)
      /bin/cp --backup=t "$file" "$dirbak/$newfilename"
      echo "--------------------------------------------------------------"
      echo "--$LINENO made copy: $newfilename"
      echo "          (and a backup if the file already existed)"
      echo "--------------------------------------------------------------"
      
      
      # the value assigned to command line option -c or -cmd
      # is assigned to global variable $TASK_2_COMMAND
      case "$TASK_2_COMMAND" in 
        sr)
          # apply sed substitution to $file to whole line (g)
          # avoid inline editing by writing into $filetmp
          sed "s/$searchpattern/$replacement/g" "$file" > "$filetmp" \
            && mv "$filetmp" "$file"
          ;;
        a_url)
          echo "a_url"
          sed_append_url "$file" "$filetmp" "$appendurl"
          ;;
        a)
          echo "a"
          ;;
        i)
          echo "i"
          ;;
        s)
          echo "s"
          ;;
        *)
          echo "command not available"
          return 1
          ;;
      esac    

      echo "--------------------------------------------------------------"
      echo "--$LINENO checked file: $file"
      echo "          (if you see no diff, no changes were made)";echo
      echo "--------------------------------------------------------------"

      # print replacements with diff
      echo "--------------------------------------------------------------"
      diff "$file" "$dirbak/$newfilename"
      echo "--------------------------------------------------------------"


      # else if $file is not a file or not readable
    else
      echo "Error: cannot read $file"
    fi

  done

  # delete temporary file if it not exists (||) then  move on (true)
  /bin/rm -v -i $filetmp || true

  # return status of the last statement executed
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
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:git_status_dirlst()"
  # ---------------------------------------------------------------------------
  #============================================================================

  # input arguments
  local dirlist="$1"
  local pwd_script="$2"

  # loop through the list of directories
  for directory in $dirlist; do

    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue

    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "next repository to apply git status: $directory"
    if ! ask_user 'next_git_status' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"

    # move to local repository, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$directory"  || return 1

    # show status
    echo "--------------------------------------------------------------"
    echo "$directory"
    echo "--------------------------------------------------------------"
    /usr/bin/git status

    # move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$pwd_script"  || return 1

  done

  # return status of the last statement executed
  return

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
  local pwd_script="$2"

  #loop through list of directories
  for directory in $dirlist; do

    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue

    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "next repository to apply git add: $directory"
    if ! ask_user 'next_git_add' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"

    # move to local repository, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$directory"  || return 1

    # add changes and new files to local stash
    echo "--------------------------------------------------------------"
    echo "$directory"
    echo "--------------------------------------------------------------"
    /usr/bin/git add .

    # move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$pwd_script"  || return 1

  done

  # return status of the last statement executed
  return

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
  local pwd_script="$2"
  local message="$3"
  
  # loop through directory list
  for directory in $dirlist; do

    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue

    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "next repository to apply git commit: $directory"
    if ! ask_user 'next_git_commit' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"

    # move to local repository, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$directory"  || return 1

    # execute task: commit with message (m)
    echo "--------------------------------------------------------------"
    echo "$directory"
    echo "--------------------------------------------------------------"
    /usr/bin/git commit -m "$message"

    # move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$pwd_script"  || return 1

  done
  
  # return status of the last statement executed
  return
  
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
  local pwd_script="$2"

  # loop through directory list
  for directory in $dirlist; do

    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue

    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "next repository to apply git commit: $directory"
    if ! ask_user 'next_git_push' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"

    # move to local repository, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$directory"  || return 1

    # push from local to remote repository on GitHub
    echo "--------------------------------------------------------------"
    echo "$directory"
    echo "--------------------------------------------------------------"
    /usr/bin/git push

    # move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$pwd_script"  || return 1

  done
  
  # return status of the last statement executed
  return
   
}
# -----------------------------------------------------------------------------


git_all_steps_dirlist() {
 
  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_all_steps_dirlist(): For Task V
  # Purpose:
  #   apply git status, add, commit, push to one repository after another,
  #     for all your directories. It uses the shell function
  #     $ git status
  #     $ git add .
  #     $ git push
  #     $ git commit --reedit-message=HEAD   # OR
  #     $ git commit -m "some default message"
  #
  # From git commit --help
  #   --reuse-message=<commit>
  #     Take an existing commit object, and reuse the log message and the authorship 
  #     information (including the timestamp) when creating the commit.
  #   --reedit-message=<commit>
  #     Like --reuse-message but editor is invoked, so that the user can further
  #     edit the commit message.
  #
  # Arguments:
  #   $1:   list of all directories to apply the job
  #   $2:   parent path of all direcories, where this script is.
  #   $3:   default message to commit
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:load_file_vars()" 
  # ---------------------------------------------------------------------------
  #============================================================================

  # input arguments
  local dirlist="$1"
  local pwd_script="$2"
  local message="$3"
  echo "$message"
  # loop through directory list
  for directory in $dirlist; do

    # if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    [ -e "$directory" ] || continue

    # move to local repository, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$directory"  || return 1
    
    # carry out all steps:
    # show status
    # add changes and new files to local stash
    # commit with message (m) or with HEAD
    # push from local to remote repository on GitHub
    echo "--------------------------------------------------------------"
    echo "$directory"
    echo "--------------------------------------------------------------"
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "apply git status to repository: $directory"
    if ! ask_user 'git_status' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # show git status
    /usr/bin/git status
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "apply git add . to repository: $directory"
    if ! ask_user 'git_add_.' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # apply git add .
    /usr/bin/git add .
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "apply git commit to repository: $directory"
    if ! ask_user 'git_commit' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # apply git commit
    /usr/bin/git commit -m "$message"
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo "apply git push to repository: $directory"
    if ! ask_user 'git_push' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate script"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # apply git push
    /usr/bin/git push

    # move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$pwd_script"  || return 1

  done
  
  # return status of the last statement executed
  return
  
}



function main() {

  #============================================================================
  #doc_begin_main--------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # main()
  #
  # Purpose:
  #   Here is the place where you call your functions.
  #   Every instrustruction, command or function is started here.
  #   No code outside this function should be running automatically.
  #   This also means, that when this script is source by another script,
  #   no code from this script is executed or sourced automatically.
  #
  # TODO: create your own tasks, 
  #       try to outsource repetitive tasks into functions.
  # ---------------------------------------------------------------------------
  #doc_end_main----------------------------------------------------------------
  #============================================================================
 
  # ---------------------------------------------------------------------------
  # Framework related tasks
  #
  # Purpose:
  #   get_options(): parses the command line sting 
  #                  reads passed option arguments and takes defined action:
  #                   - prints doc or version strings if script is executed
  #                     with ---doc or with --version options and exits script.
  #                   - prints debug info if script is run with --debug option
  #                 $@: passes the command line arguments to the function
  #                 $?: catches the return status of the last command.
  #
  # TODO: adapt and improve the framework.
  # ---------------------------------------------------------------------------
  # Code
  if ! get_options "$@"; then exit 1; fi
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}: \
        $?", "$*", "$OUTPUTFILE", $DEBUG  || true

  #doc_begin_main; help_begin--------------------------------------------------
  # ---------------------------------------------------------------------------
  # main(): user related tasks
  #
  # Purpose
  #  Task_1_checkpath:     load file system variables, to check them.
  #  Task_2_home_md:       apply sed to all Home.md files.
  #  Task_2_readme_md:     apply sed to all README.md files.
  #  Task_3_repos:         show all repos.
  #  Task_3_status:        apply git status to all repos.
  #  Task_3_add:           apply git add . to all repos.
  #  Task_3_commit:        apply git commit to all repos.
  #  Task_3_push:          apply git push to all repos.
  #  Task_4_git_all_steps: the same as Task_3_... but only one loop per repo.
  #
  # TODO: write your own tasks.
  # ---------------------------------------------------------------------------
  #doc_end_main; help_end------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:main()" 
  # ---------------------------------------------------------------------------


  case "$START_AT_TASK" in
    #doc_begin_main----------Task_1_checkpath----------------------------------
    # -------------------------------------------------------------------------
    # Task_1_checkpath
    #   make sure you apply script to direcory qoolixiloopAgithub
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_1_checkpath|t1_checkpath|1_checkpath)
      # Code 
      if ! load_file_vars "qoolixiloopAgithub"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_2_home_md?"
      if ! ask_user 'Task_2_home_md' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # and leave (;;) or  move on (;&) 
      ;&
  
    #doc_begin_main----------Task_2_home_md------------------------------------
    # -------------------------------------------------------------------------
    # Task_2_home_md:
    #  apply sed to all Home.md files  
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_2_home_md|t2_home_md|2_home_md)
      # Code 
      # a.) list of all Home.md files to which you will apply your script
      local filelist_home_md="./*-loop.wiki/Home.md"
      if ! check_filelist "$filelist_home_md"; then
        echo "exit: $LINENO"; exit 1
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to search for $SEARCH and replace with $REPLACE?"
      if ! ask_user 'Task_2_home_md' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"
      
      # b.) add the command line variables TODO:
      local searchpattern="$SEARCH"
      local replacement="$REPLACE"
      local appendurl="$APPEND_URL"

      # c.) apply sed to $filelist_home_md
      #     for each file change the diff will be printed
      #     after every diff there is a user interaction
      local dirbak_Home_md=./bak_Home_md/
      if ! sed_in_files_md "$filelist_home_md" "$dirbak_Home_md"
        "$searchpattern" "$replacement" \
        "$appendurl"; then
        echo "exit: $LINENO"; exit 1
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_2_readme_md?"
      if ! ask_user 'Task_2_readme_md' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # and l eave (;;)  or  move on (;&)
      ;&

    #doc_begin_main----------Task_2_readme_md----------------------------------
    # -------------------------------------------------------------------------
    # Task_2_readme_md:
    #   apply sed to all README.md files 
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_2_readme_md|t2_readme_md|2_readme_md)
      # Code
      # a.) list of all README.md files to which you will apply your script
      local filelist_README_md="./*-loop/README.md"
      if ! check_filelist "$filelist_README_md"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to search for $SEARCH and replace with $REPLACE?"
      if ! ask_user 'Task_2_readme_md' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # b.) give in the two variables TODO:
      local searchpattern="$SEARCH"
      local replacement="$REPLACE"
      local appendurl="$APPEND_URL"

      # c.) apply sed to filelist_README_md 
      #     for each file change the diff will be printed
      #     after every diff there is a user interaction
      local dirbak_README_md=./bak_README_md/
      if ! sed_in_files_md "$filelist_README_md" "$dirbak_README_md"
        "$searchpattern" "$replacement" \
        "$appendurl"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_3_git_repos?"
      if ! ask_user 'Task_3_git_repos' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # and  leave (;;)  or  move on (;&)
      ;&
 
    #doc_begin_main----------Task_3_git_repos----------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_repos: 
    #   list all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_3_git_repos|t3_git_repos|3_gr)
    # Code 
      # list of all directories to which you will apply your script
      local pwd_script    # shell.check warns to make 2 lines, because the
      pwd_script="$(pwd)" # return value would be ignored in a 1 liner
      local directorylist="./*-loop*/"
      
      # check directory list
      if ! check_dirlist "$directorylist" "$pwd_script"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_3_git_status?"
      if ! ask_user 'Task_3_git_status' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"
      
      # and leave (;;)  or  move on (;&) 
      ;&
 
    #doc_begin_main----------Task_3_git_status---------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_status: 
    #   apply git add . to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_3_git_status|t3_git_status|3_gs)
      # Code
      
      # list of all directories to which you will apply your script
      local pwd_script
      pwd_script="$(pwd)"
      local directorylist="./*-loop*/"
      
      # check status
      if ! git_status_dirlist "$directorylist" "$pwd_script"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_3_git_add?"
      if ! ask_user 'Task_3_git_add' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1; 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # and  leave (;;)  or  move on (;&)
      ;&
       
    #doc_begin_main----------Task_3_git_add------------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_add: 
    #   apply git add . to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_3_git_add|t3_git_add|3_ga)
     # Code 
      
      # list of all directories to which you will apply your script
      local pwd_script
      pwd_script="$(pwd)"
      local directorylist="./*-loop*/"
      
      # add
      if ! git_add_dirlist "$directorylist" "$pwd_script"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_3_git_commit?"
      if ! ask_user 'Task_3_git_commit' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1; 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # and leave (;;)  or  move on (;&)
      ;&
 
    #doc_begin_main----------Task_3_git_commit---------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_commit: 
    #   apply git commit to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_3_git_commit|t3_git_commit|3_gc)
      # Code
    
      # list of all directories to which you will apply your script
      local pwd_script
      pwd_script="$(pwd)"
      local directorylist="./*-loop*/"
      
      # commit
      local timestamp
      timestamp="$(date)"
      if ! git_commit_dirlist "$directorylist" "$pwd_script" \
        "batch run at $timestamp"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_3_git_status?"
      if ! ask_user 'Task_3_git_status' "$LINENO" answer; then
        echo "exit: $LINENO"; exit 1; 
      fi
      if [[ "$answer" == "a" ]]; then echo "OK, go to task"
      elif [[ "$answer" == "c" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "b" ]]; then echo "no loop, go to task"
      elif [[ "$answer" == "t" ]]; then echo "terminate script"; exit 1
      else echo "$LINENO : something went wrong"
      fi
      echo "--------------------------------------------------------------"

      # a nd  leave (;;)  or  move on (;&)
      ;&
       
    #doc_begin_main----------Task_3_git_push-----------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_push: 
    #   apply git push to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_3_git_push|t3_git_push|3_gp)
      # Code
    
      # list of all directories to which you will apply your script
      local pwd_script
      pwd_script="$(pwd)"
      local directorylist="./*-loop*/"
      
      # push
      if ! git_push_dirlist "$directorylist" "$pwd_script"; then
        echo "exit: $LINENO"; exit 1; fi

      # Return with code 0
      return 0

      # and   leave (;;) or  move on (;&)
      ;;
       
    #doc_begin_main----------Task_4_git_all_steps------------------------------
    # -------------------------------------------------------------------------
    # Task_4_git_all_steps: 
    #   apply git status, git add ., git commit, git push to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_4_git_all_steps|t4_git_all_steps|4_gall)
      # Code
    
      # list of all directories to which you will apply your script
      local pwd_script
      pwd_script="$(pwd)"
      local directorylist="./*-loop*/"
      
      # all steps, only one loop for each repository
      local timestamp
      timestamp="$(date)"
      echo "$timestamp"
      if !  git_all_steps_dirlist "$directorylist" "$pwd_script" \
        "batch run at $timestamp"; then
        echo "exit: $LINENO"; exit 1; fi

      # Return with code 0
      return 0

      # and leave (;;)  or  move on (;&)
      ;;
    *)
      # Code 
      echo; echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" 
      echo ">>> run with option: --task Task_{valid task name}"
      echo ">>> to get list run with option: --help"
      echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"; echo
      ;;
  esac
}
# -----------------------------------------------------------------------------



#doc_begin---------------------------------------------------------------------
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
#doc_end-----------------------------------------------------------------------
unset BASH_SOURCE 2>/dev/null
test ".$0" != ".${BASH_SOURCE[0]}" || main "$@"
# -----------------------------------------------------------------------------
if [[ $? == 1 ]]; then exit 1; fi
exit 0
