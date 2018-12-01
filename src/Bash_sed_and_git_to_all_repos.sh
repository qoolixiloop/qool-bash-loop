#!/bin/bash
#shellcheck disable=SC2015

#==============================================================================
#doc_begin---------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Bash Script:  SED substitution on all md files.
#               Git diff, status, add, commit and push on all repos.
#               Automatic generation of docs.
# Framework:    own template
# Syntax check: shellcheck
# Autor:        Roland Benz
# Date:         01.Dez.2018
# -----------------------------------------------------------------------------
#doc_end-----------------------------------------------------------------------
#help_begin--------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Ways to run the script: 
#   1.) to get help:         $ ./Scriptname --help
#   2.) to get version info: $ ./Scriptname --version (or -v)
#   3.) to get doc info:     $ ./Scriptname --doc
#   4.) to run task 2:       $ GLOBAL_VARNAME="value"... \
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd command_name
#   4.1) command: a         $ [COMMAND_LINE_OPTIONS=""] && [SEPARATOR=""] \
#        (SED append)         && (ADDRESS_RANGE="N,M || M" || \
#                                 REGEX_RANGE="/reg_from/,/reg_to/ || /reg/") \
#                             && COMMAND_OPTIONS="append_text" \  
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd a
#   4.2) command: i         $ [COMMAND_LINE_OPTIONS=""] && [SEPARATOR=""] \
#        (SED insert)         && (ADDRESS_RANGE="N,M || M" || \
#                                  REGEX_RANGE="/reg_from/,/reg_to/ || /reg/") \ 
#                             && COMMAND_OPTIONS="insert_text" \ 
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd i
#   4.3) command: d         $ [COMMAND_LINE_OPTIONS=""] && [SEPARATOR=""] \
#        (SED delete)          && ((ADDRESS_RANGE="N,M || M" && \
#                                   [REGEX_RANGE="/reg_from/,/reg_to/ || /reg/"]) || \
#                                  ([ADDRESS_RANGE="N,M || M"] && \
#                                   REGEX_RANGE="/reg_from/,/reg_to/ || /reg/")) \   
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd d
#   4.4) command: =         $ [COMMAND_LINE_OPTIONS=""] && [SEPARATOR=""] \
#        (SED print line num)  && ((ADDRESS_RANGE="N,M || M" && \
#                                   [REGEX_RANGE="/reg_from/,/reg_to/ || /reg/"]) || \
#                                  ([ADDRESS_RANGE="N,M || M"] && \
#                                   REGEX_RANGE="/reg_from/,/reg_to/ || /reg/")) \   
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd =
#   4.5) command: p         $ [COMMAND_LINE_OPTIONS=""] && [SEPARATOR=""] \
#        (SED print lines)     && ((ADDRESS_RANGE="N,M || M" && \
#                                   [REGEX_RANGE="/reg_from/,/reg_to/ || /reg/"]) || \
#                                  ([ADDRESS_RANGE="N,M || M"] && \ 
#                                   REGEX_RANGE="/reg_from/,/reg_to/ || /reg/")) \   
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd p
#   4.6) command: s         $ [COMMAND_LINE_OPTIONS=""] && [SEPARATOR=""] \
#        (SED substitute)      && ((ADDRESS_RANGE="N,M || M" && \
#                                   [REGEX_RANGE="/reg_from/,/reg_to/ || /reg/"]) || \
#                                  ([ADDRESS_RANGE="N,M || M"] && \
#                                   REGEX_RANGE="/reg_from/,/reg_to/ || /reg/")) \   
#                              && COMMAND_OPTIONS="none || g || c || gc" \
#                                   SUBSTITUTE_SEARCH="reg_search" 
#                                   SUBSTITUTE_REPLACE="text_replace"
#                                ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd s
#   4.7) command: a_url      $ APPENDURL="my_new_Wiki_page_URL" \
#        (append url)            ./Scriptname \
#                                  --task Task_2_{ home_md || readme_md } \
#                                  --cmd a_url
#   5.) to run other tasks:  get a complete task list with --help option
#   5.1)  pattern:           $ ./Scriptname --task Task_1_ { _3_, _4_ }
#   6.) run with debug info: $ DEBUG='y' ./Scriptname --debug
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
# TODO: here is the place where you put the framework related functions
#         1.) version():          to print version info 
#         2.) doc():              to print documentation info
#         3.) ihelp()             to print available tasks and options
#         4.) generate_doc()      to automatically parse the script with AWK
#         5.) get_options():      to parse your script options
#         6.) ask_user():         to navigate with user interaction
#         7.) script_sourced_executed(): debug info
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
    Version: 2.0.0
    Date:    01.Dez.2018
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


generate_doc() { # called by the functions doc() and ihelp()
 
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
  #    --help  # this calls the function ihelp() which then calls this
  #              function.
  #
  # How it works:
  #  The code in this function parses through this whole script and prints
  #  each text, for which it finds the two markers doc._begin and doc._end
  #  for the doc() and the two markers help._begin and help._end for the help()
  #  (on a side note: the dot in (help._ instead of help_) is necessary so that 
  #  the line above and below is not printed by this function)
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
  # line 8-15: BEGIN block, to do those tasks before the file is read
  # line 16-17: filters applied on every line in the files 
  #             (these take only bash variables or match() must be used.)
  # line 18-24: BODY block, to do those tasks for every line in the file
  # line 25-27: END block, to do those task after the file is read
  # line 28: single quote to end the AWK program
  #          and the file name, to which to apply the AWK program
  # Remarks: 1. bash variable as well as command line variables can be 
  #             fed into AWK. 
  #          2. use a backslash at the end of each line for the options in
  #             line 2-6
  #          3. within a string use the backslash for special characters
  #          4. try to make one statement per line and end it with a
  #             semicolon. Backslash to cut a statement into two lines 
  #             works, but bash sytax check might complain.

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


ihelp() { # this function is called from get_options()

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
  #     -t and --task             to start script at a particular task
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
  unset START_AT_TASK

  # As long as there is at least one more argument, keep looping
  # -gt is used if string ($#) shall be interpreted as integer
  while [[ $# -gt 0 ]]; do
    [[ $DEBUG == 'y' ]] && \
      echo "--$LINENO ${BASH_SOURCE[0]}:start loop" || true

    # check the command line arguments string $@
    key="$1"
    case "$key" in

      # This is a flag type option. Will catch either -v or --version
      -v|--version)

      # call function to print version info
      version
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:printed version" || true

      # return 1 to indicate that the script shall terminate
      return 1

      ;;

      # Also a flag type option. Will catch --help
      --help)

      # call function to print help info
      ihelp "$1"
      [[ $DEBUG == 'y' ]] && \
        echo "--$LINENO ${BASH_SOURCE[0]}:printed help" || true

      # return 1 to indicate that the script shall terminate
      return 1

      ;;
      # Also a flag type option. Will catch --doc
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
      # global variable is used in function main()
      # as a CASE condition to call the right function
      shift # past the key and to the value
      START_AT_TASK="$1"; echo "$START_AT_TASK"

      ;;

      # This is an arg value type option.
      # Will catch -c value or --cmd value
      -c|--cmd)

      # Set global variable TASK_2_COMMAND by shifting first
      # global variable is used in function sed_in_files_md()
      # as a CASE condition to call the right function
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
  #   Ask user whether he wants to:
  #     Apply the task:           go to next line and apply the task
  #     Return function:          calls the return statement
  #     Continue loop with next:  go directly to next file or repo  
  #     Break:                    leave the loop
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
  echo; echo "line number: $2"  
  echo "message: $1" 

  # print instructions
  echo "apply (a), cont. with next in loop (c), break loop (b), terminate (t)?"

  # wait for, read and store user input into
  local ANSWER

  # check users answer and act as explained in the function discription
  # endless loop until a, b, c, or t are entered
  while true; do
    read -r ANSWER
    case "$ANSWER" in
      a) echo "you entered: a"
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
      c) echo "you entered: c"
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
      b) echo "you entered: b"
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
      t) echo "you entered: t"
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
        "apply (a), cont with next in loop (c), break loop (b), terminate (t)?"
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
#           sed_in_files_md():        make substituion
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
  #===========================================================================

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


sed_in_files_md() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # sed_in_files_md(): For Task II and Task III
  # Purpose:
  #   1) I use it to loop through all README.md and Home.md files
  #      make a backup of each file and call one of two funcions:
  #   2) If the function sed_wrapper() is called in a loop, each file will
  #      be edited by SED. Available SED commands are delete, append, insert,
  #      print line, print line numbers, or substitute with respect to  one 
  #      or more filters applied.
  #   3) If the function sed_append_url() is called, a new GitHub Wiki 
  #      page URL referece is appended to all Home.md and README.md files.
  # Arguments:
  #   $1    file; the input file to read from; will be overwritten by $2
  #   $2    backup directory for all your files
  #   $3    commandLineOptions; SED Options; see "$ sed --help";
  #                           -E is hard coded here 
  #                           e.g. use -n with command 'p' or command '='
  #   $4    separator"; use it, if your strings contain many "/"
  #   $5    addressRange; either "N_from,M_to" or "M"
  #   $6    regexPattern; either "/reg_from/,/reg_to/" or "/reg/"
  #   $7    commandOptions "for a,i:'TEXT' to add; for s: 'g' or '' "
  #   ${8}  substituteSearch; reg
  #   ${9}  substituteReplace; text
  #   ${10} new wiki page url to append
  #  
  #-----------------------------------------------------------------------------
  # SED
  # ===
  # 1.) command line call:
  #   sed -options 'command' file
  #   sed -options 'command' < infile > outfile
  #   sed -options 'command1; command2' file
  # 2.) options:
  #   -n do not print buffer/file
  #   -i apply/print to file
  #   -E or -r extended Regex also for GNU (-E for POSIX portability)
  # 3.a) commands for search and print, delete, append, insert:
  #   N,M[!]p  or Np                  print OR [not] line(s)
  #   /pattern/[!]p                   print or [not] pattern(s)
  #   /pattern1/,/pattern2/[!]p       print or [not] between patterns
  #   N,M[!]d  or  Nd                 delete OR [not] line(s) 
  #   /pattern/[!]d                   delete OR [not] pattern(s)
  #   /pattern1/,/pattern2/[!]d       delete OR [not] between patterns
  #   N,M[!]a Text  or Na Text        append Text OR [not] to lines(s) 
  #   /pattern/[!]a Text              append Text OR [not] to pattern
  #   /pattern1/,/pattern2/[!]a Text  append Text OR [not] between patterns
  #   N,M[!]i Text  or Ni Text        insert Text OR [not] to line(s) 
  #   /pattern/[!]i Text              insert Text OR [not] to pattern
  #   /pattern1/,/pattern2/[!]i Text  insert Text OR [not] between patterns
  #   /pattern/=                      print line numbers
  # 3.b) command list
  #   { ; }                           list of commands colon separated
  #   {p;q}                           Example: print first (p) and quit (q)
  #   {/pattern/{ ; }}                nested with pattern
  # 3.b) command for search and replace on lines where pattern matches
  #   Index,/pattern/s/search/replace/sr_options
  #   Index
  #   0              apply only to first match
  #   sr_options
  #   g              apply to all search instances
  #   n              apply only to nth search instance
  #   p              print only replaced lines
  #   w file         print to file
  # 4.a) Range before search pattern, then enclose pattern search in {}
  #   N,M{/pattern/}
  # 4.b) Examples: only search in range of line number 300 to end (\$) 
  #   print (p) first and quit (q). Expressions in nested { { }}
  #   Escape characters with special meaning like $.
  #   300,\${/pattern/{p;q;}}
  # 4.c) Examples: apply only to first match
  #   -n '/RE/{p;q;}' file       # print only the first match
  #   '0,/RE/{//d;}' file        # delete only the first match
  #   '0,/RE/s//to_that/' file   # change only the first match
  # 4.d) Examples: regex goups
  #   search and replace only last occurence of search pattern in line
  #   \1: print content of first braces
  #   \2: print content of second braces
  #   sed -r 's/(.*)search/\1replace/'
  #   sed -r 's/(.*)search(.*)/\1replace\2/
  #
  # sort
  # ====
  # -r reverse the result 1,2,3 -> 3,2,1
  # -n string numerical value
  # -o write to file
  # -u unique
  #
  # GREP
  # ====
  # grep options "pattern" file(s)       # apply grep to file(s), directorie(s)
  # echo string | grep options "pattern" #apply grep to string
  # -E: extended Regex (GNU basic is already extended)
  # -c: count instead of normal ouput
  # -n: lines number of matches and line
  # -o: only matching part of line
  # -v: invert match
  #
  # CUT
  # ===
  # cut option 'value'
  # -c character(s)
  # -f field(s) or column(s)
  # -d delimiter for characters
  # -d$ delimiter for \n, \t
  #
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sed_in_files_md()"
  # ---------------------------------------------------------------------------
  #============================================================================

  # INPUT: arguments
  local file="$1"
  local dirbak="$2"
  local commandLineOptions="$3"
  local separator="$4"
  local addressRange="$5"
  local regexRange="$6"
  local commandOptions="$7"
  local substituteSearch="${8}"
  local substituteReplace="${9}"
  local appendurl="${10}"

  # sedScript: holds the instructions applied to each line of the file 
  local sedScript 

  # CHECK: input arguments
  echo "--$LINENO file: $file"
  echo "--$LINENO dirbak: $dirbak"
  echo "--$LINENO commandLineOptions: $commandLineOptions"
  echo "--$LINENO separator: $separator"
  echo "--$LINENO addressRange: $addressRange"
  echo "--$LINENO regexRange: $regexRange"
  echo "--$LINENO command: $TASK_2_COMMAND"  # set via --cmd & get_options()
  echo "--$LINENO commandOptions: $commandOptions"
  echo "--$LINENO substituteSearch: $substituteSearch"
  echo "--$LINENO substituteReplace: $substituteReplace"
  echo "--$LINENO appendurl: $appendurl";

  #CHECK: number of arguments
  if [[ "$#" -ne 10 ]]; then
    echo "ERROR: number of arguments: $#; but should be 10"
    return
  fi
  echo "number of arguments: $#"

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
      elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
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
        a|i|d|=|p|s)
          echo "sed_in_files_md() case: sed_wrapper; a,i,d,=,p,s"
          if ! sed_wrapper "$file" "$filetmp" \
            "$commandLineOptions" "$separator" "$addressRange" "$regexRange" \
            "$TASK_2_COMMAND" "$commandOptions" \
            "$substituteSearch" "$substituteReplace"; then
            /bin/rm -v -i $filetmp || true
            echo "exit: $LINENO"; return 1; 
          fi
          ;;
        a_url)
          echo "sed_in_files_md() case: sed_append_url(); a_url"
          if ! sed_append_url "$file" "$filetmp" "$appendurl"; then
            /bin/rm -v -i $filetmp || true
            echo "exit: $LINENO"; return 1; 
          fi
          ;;
        *)
          echo "sed_in_files_md() case: command not available"
          return 1
          ;;
      esac    

      echo "--------------------------------------------------------------"
      echo "--$LINENO checked file: $file"
      echo "          (if you see no diff, no changes were made)";echo
      echo "--------------------------------------------------------------"

      # print substitutions with diff
      echo "--------------------------------------------------------------"
      diff --color "$file" "$dirbak/$newfilename"
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


sed_append_url() {
   
  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # sed_append_url(): For Task II: 
  # Purpose: 
  #   It adds a new Wiki URL reference to the list, which is at the end 
  #   of the input file. Within this list the right place for the reference is
  #   found and the new Wiki URL inserted.
  #   For now, I use it for all my README.md and Home.md GitHub pages.  
  # Arguments:
  #   $1:   filename of the file to change:
  #   $2:   a temporary file $filetmp used for SED to avoid the SED -i option
  #   $3:   the new URL to append
  # How it is called:
  #   It is called from function sed_in_files_md(), which is called inside 
  #   main() function.
  # Assumptions about the file structure:
  #   It searches for two of the three comment strings above the URL reference
  #   list. They must be there, unaltered and with a newline between it, and
  #   the first URL entry.
  # Why is the function so long, what does it check ...
  #   1.) whether the entry is already there. Then it returns to the calling
  #       function.
  #   2.) whether the assigned reference number, which follows strict rules,
  #       is the highest number. In that case it is added at the end.
  #   3.) whether there is already at least one Wiki page for that repository.
  #   3.1) if yes: it searches for the highest reference of those pages,
  #        increments that value by one and adds the new reference after the
  #        the last of this group.
  #   3.2) if no: the new reference gets a number within its repository range
  #        ending with a 3. Then it is added at the right place.
  #   4.) whether something went wrong. E.g. if for some reason a search
  #       did find nothing, when it should have.
  # How 3.) works in a nutshell:
  #   It gets the URL of the new Wiki page and a filename of the page, to which
  #   the URL should be appended. 
  #   First it extracts the repository from the URL and and then fills this
  #   information into a pattern. The pattern is used by SED to find all
  #   matching lines. From those lines, the last one is determined as the place
  #   to append. Its reference number is extracted. With this information a 
  #   new reference for the new URL is constructed, which is then appended by a 
  #   SED append command.
  #   In case no match is found, a new reference is constructed and the URL
  #   added to its right place.
  #   For all extraction tasks GREP -o is applied to a string.
  # ---------------------------------------------------------------------------
  #doc_end---------------------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sed_append_url()"
  # ---------------------------------------------------------------------------
  #============================================================================

  echo "entering sed_append_url()"

  # INPUT arguments
  local file="$1"
  local filetmp="$2"
  local appendurl="$3"

  # PATTERN: define line number range to apply SED pattern search
  # this pattern searches for the comment entries, they must be there.
  local pat_commentline_1
  local pat_commentline_2
  pat_commentline_1="\[\/\/\]: # .*'Code: README.*Home" 
  pat_commentline_2="\[\/\/\]: # .*all other 'Wiki"
  echo "pat_commentline_1: $pat_commentline_1" 
  echo "pat_commentline_2: $pat_commentline_2" 

  # SED: find pattern and return its line number
  # now we now in which line the two comments are
  local linenum_commentline_1
  local linenum_commentline_2
  linenum_commentline_1=$(sed -E -n\
    "/$pat_commentline_1/{=;}" "$file")
  linenum_commentline_2=$(sed -E -n\
    "/$pat_commentline_2/{=;}" "$file")
  echo "linenum_commentline_1: $linenum_commentline_1"
  echo "linenum_commentline_2: $linenum_commentline_2"
  
  # RANGE: create a SED search range.
  # now we have something like sed_range=(267,\$) twice.
  local sed_range1
  local sed_range2
  sed_range1="$linenum_commentline_1,\$"
  sed_range2="$linenum_commentline_2,\$"
  echo "sed_range1: $sed_range1" 
  echo "sed_range2: $sed_range2" 
  
  # PATTERN: define repositories name pattern
  # all repository names have this pattern
  local pat_repos="qool-.*-loop"

  # GREP: extract qool-XXX-loop from string
  # -o: only print matching part
  # now we know the repo name e.g. repo_name= qool-markdown-loop
  local repo_name
  repo_name=$(echo "$appendurl" | grep -E -o "$pat_repos" )
  echo "search this repository: $repo_name"
  
  # PATTERN: to search for references that already might be there
  # all URL references follow this pattern
  local pat_url_ref
  pat_url_ref="^\[.*github\.com\/qoolixiloop\/$repo_name\/wiki"
  echo "pattern to search: $pat_url_ref"

  # SED: now we search in range $sed_range1 with that pattern and 
  #      print all matching lines into a variable.
  # -n do not print buffer, /p print
  local list_repo_url_refs
  list_repo_url_refs=$(sed -E -n "$sed_range1{/$pat_url_ref/p}" "$file")
  echo "list_repo_url_refs: $list_repo_url_refs"
  
  # SED: now we search in range $sed_range1 with that pattern and 
  #      print all line numbers of all matching lines into variable
  # -n do not print buffer, /{=;} output only line numbers
  local linenum_repo_url_refs
  linenum_repo_url_refs=$(sed -E -n "$sed_range1{/$pat_url_ref/{=;}}" \
    "$file")
  echo "linenum_repo_url_refs: $linenum_repo_url_refs"
  
  # ALTERNATIVE: now we check for all the cases 1.) to 4.) described in the
  #       function description. 
  # This condition must always be true. 
  if [[ -n "$list_repo_url_refs"  ]]; then 
  
    # ALTERNATIVE: check if URL already exist for that repo
    #       if yes return to calling function
    
    # READARRAY: transform newline separated string into an array
    local arr_repo_url_refs
    readarray -t arr_repo_url_refs <<<"$list_repo_url_refs"
    declare -p arr_repo_url_refs;

    # LOOP: loop through all URL references of repo
    local repo_url_ref
    for repo_url_ref in "${arr_repo_url_refs[@]}"; do
      
      echo "repo_url_ref: $repo_url_ref"
      local pat_repo_url_ref
      local repo_url
      pat_repo_url_ref="https://\S*"
      repo_url=$(echo "$repo_url_ref" | grep -E -o "$pat_repo_url_ref" )
      
      echo "repo_url: $repo_url"
      echo "appendurl: $appendurl"

      if [[ "$repo_url" == "$appendurl"  ]]; then
        echo $'==================\nURL already exists\n==================='
        return 1
      fi 
    
    done

    # ALTERNATIVE: $appendurl does not yet exist
    #       search for highest entry for this repo

    # TAIL: extract highest line number
    # $linenum_repo_url_refs is a space separated string
    # -n: string(s) as numerical values
    local linenum_max_repo_url_ref
    linenum_max_repo_url_ref=$(echo "${linenum_repo_url_refs}" | sort -n | tail -1)
    echo "linenum_max_repo_url_ref: $linenum_max_repo_url_ref"

    # SED: extract line with that line number
    # -n do not print buffer, N,p print line
    local max_repo_url_ref
    max_repo_url_ref=$(sed -E -n "${linenum_max_repo_url_ref}p" "$file")
    echo "max_repo_url_ref: $max_repo_url_ref"

    #PATTERN: url reference and url reference number
    local pat_url_ref
    local pat_url_ref_nr
    pat_url_ref='\[[0-9]{3,4}]:'
    pat_url_ref_nr='[0-9]{3,4}'
    
    # GREP: extract the URL reference number of that line, using GREP -o
    # beware: break line with backslash and no spaces before and after \
    local num_max_repo_url_ref
    num_max_repo_url_ref=$(echo "$max_repo_url_ref" | grep -E -o "$pat_url_ref"\
      | grep -E -o "$pat_url_ref_nr")
    echo "num_max_repo_url_ref: $num_max_repo_url_ref"

    # ARITHMETIC: construct the new reference [1234]: http://...
    # beware: spaces are part of the syntax, and variables without $
    local num_new_repo_url_ref
    num_new_repo_url_ref=$(( num_max_repo_url_ref + 1 ))
    echo "num_new_repo_url_ref: $num_new_repo_url_ref"
    local new_repo_url_ref
    new_repo_url_ref="[$num_new_repo_url_ref]: $appendurl"
    echo "new_repo_url_ref: $new_repo_url_ref"

    # CUT SUBSTRING: ${string_varible: pos_from : length_to_the_right}
    #      cut out a substring
    # beware: as always in Bash, spaces are part of the syntax
    local num_last_digit
    num_last_digit=${num_max_repo_url_ref: -1 : 1}
    echo "num_last_digit: $num_last_digit"

    # ALTERNATIVE: find out if last digit of num_max_repo_url_ref is a 2
    #       that means it only has a README.md and a Home.md page
    if  (( "$num_last_digit" == 2 )); then

      # ARITHMETIC: line of first url reference
      local num_iter_line_file
      num_iter_line_file=$(( linenum_commentline_2 + 2 ))
      
      # WC: nr of line in the file: also grep -c '' $file
      local num_lines_file
      num_lines_file=$(wc -l < "$file")
      echo "nr of lines in file: $num_lines_file"
      
      # LOOP,ARITHMETIC: find the place to insert the $new_repo_url_ref
      while (( num_iter_line_file <= num_lines_file )); do 
        
        # SED: get line of file
        local line_file
        line_file=$(sed -E -n "${num_iter_line_file}p" "$file")
        echo "line_file: $line_file"
        
        # GREP: get URL reference number of line of file
        local num_repo_url_ref
        num_repo_url_ref=$(echo "$line_file" | grep -E -o "$pat_url_ref_nr")
        echo "num_repo_url_ref: $num_repo_url_ref"
        
        #print numbers to shell
        echo "num_new_repo_url_ref: $num_new_repo_url_ref"
        echo "num_iter_line_file: $num_iter_line_file"
        echo "num_lines_file: $num_lines_file"
        
        # ALTERNATIVE: last entry reached.
        #       test if num_repo_url_ref empty, 
        #       that means $num_new_repo_url_ref is the overall highest number
        #       then insert the $new_repo_url_ref and break loop 
        if [[ -z $num_repo_url_ref  ]]; then

          echo "reached last line, num_iter_line_file: $num_iter_line_file"

          # SED: place found to insert  
          # command: $i $text to $file at line $N
          # write to $filetmp 
          # at end of function move that file to $file (overwrite)
          # in order to avoid inline editing by writing into $filetmp
          # beware: sed -n will copy an empty buffer to the file. 
          #         don't use it here.
          local N="$num_iter_line_file"
          local cmd="i"
          local text="$new_repo_url_ref"
          local cmd="${N}${cmd} $text"
          echo "cmd: $cmd"
          sed -E "$cmd" "$file" >  "$filetmp"
          
          break;

        fi

        # ALTERNATIVE: not yet at the end of file
        #       not yet found line to insert, move on

        # ARITHMETIC: compare the numbers
        if (( num_new_repo_url_ref > num_repo_url_ref )); then
         
          echo "not yet, num_iter_line_file: $num_iter_line_file"
       
        else  
          
        # ALTERNATIVE: $num_new_repo_url_ref is lower than $num_repo_url_ref
        #       insert it here, break the loop

          echo "found line, num_iter_line_file: $num_iter_line_file"

          # SED: place found to insert  
          # command: $i $text to $file at line $N
          # write to $filetmp and move that file to $file (overwrite)
          # to avoid inline editing by writing into $filetmp
          # beware: sed -n will copy an empty buffer to the file. 
          #         don't use it here.
          local N="$num_iter_line_file"
          local cmd="i"
          local text="$new_repo_url_ref"
          local cmd="${N}${cmd} $text"
          echo "cmd: $cmd"
          sed -E "$cmd" "$file" >  "$filetmp"
          
          break;

        fi
        
        # ARITHMETIC: increase line iterator for loop
        num_iter_line_file=$(( num_iter_line_file + 1 ))

      done

    # ALTERNATIVE: $num_max_repo_url_ref is greater than 2
    #       that means it has additional Wiki pages
    #       just jump to that line number and append $new_repo_url_ref

    elif (( "$num_last_digit" > 2 )); then 
      
      echo "num_last digit > 2"
      
      # SED: command $a $text to $file at line $N
      # write to $filetmp and move that file to $file (overwrite)
      # to avoid inline editing by writing into $filetmp
      # beware: sed -n will copy an empty buffer to the file. 
      #         don't use it here.
      local N="$linenum_max_repo_url_ref"
      local cmd="a"
      local text="$new_repo_url_ref"
      local cmd="${N}${cmd} $text"
      echo "cmd:sed -E $cmd"
      sed -E "$cmd" "$file" >  "$filetmp"

    # ALTERNATIVE: $num_last_digit < 2
    #       this means there is a README.md or Home.md missing
    #       or $num_last_digit was erroneously extracted  
    else

      echo "someting went wrong"
   
    fi
    
    #DIFF: show differences before and after
    diff "$file" "$filetmp"
    
    #MV: move/ overwrite $file with $filetmp
    mv "$filetmp" "$file"

  # ALTERNATIVE: $list_repo_url_refs is empty
  #       this means no Wiki pages found, 
  #       also README.md and Home.md are missing
  #       or $list_repo_url_refs was erroneously extracted
  else
    echo "no matches found. something went wrong."
  fi
  
  # return status of the last statement executed
  echo "leaving sed_append_url"
  return 

}
# -----------------------------------------------------------------------------

sed_wrapper() {

  #============================================================================
  #doc_begin; help_begin-------------------------------------------------------
  # ---------------------------------------------------------------------------
  # sed_wrapper(): For Task II: 
  # Purpose: 
  #   A wrapper with predefined SED strings.
  #   Serves as a reminder of the syntax for the different SED Commands
  #
  # Arguments:
  #  There are a lot of input arguments, and they must all be passed at the 
  #  right position, for the function to work. Not used arguments are passed
  #  as an own separate empty string "". Because I only use the function
  #  programmatically, this is rather an advantage than a disadvantage.
  #   $1: file; the input file to read from; will be overwritten by $2
  #   $2  filetmp; the output file to write to; overwrites $1
  #   $3  commandLineOptions; SED Options; see "$ sed --help";
  #                           -E is hard coded here 
  #                           e.g. use -n with command 'p' or command '='
  #   $4  separator"; use it, if your strings contain many "/"
  #   $5  addressRange; either "N_from,M_to" or "M"
  #   $6  regexPattern; either "/reg_from/,/reg_to/" or "/reg/"
  #   $7  command; one of "a, i, d, p, =, s" (see "$ man sed" for a list)
  #   $8  commandOptions "for a,i:'TEXT' to add; for s: 'g' or '' "
  #   ${9} substituteSearch; reg
  #   ${10} substituteReplace; text
  # 
  # SED: Usage
  #  SED -E sedOptions sedScript <inputfile >outputFile
  #
  # REGEX Extended 
  #   1.)  use sedOption -E (set here by default) 
  #   2.)  Literal vs Special meaning  of characters and digits
  #   2.1) Escape "\" rules of extended Regex:
  #          a-z, A-Z, 0-9: all have literal meaning unescaped
  #          \a-\z, \A-\Z : some have special meaning escaped
  #          \specialCharacters: all have literal meaning escaped
  #         specialCharacters: some have special meaning unescaped 
  #   2.2) additional escape "\" rules of SED specific special characters:
  #          ": used to build the command string -> must be escaped everywhere
  #          /: used to separate command strings -> must be escaped everywhere
  #             or use a new separator, e.g. | or #
  #          ': must not be escaped
  #
  # Source to learn SED
  #   $ info sed  ("$ man sed", and "$ sed --help" are just summaries)
  #
  # In a nutshell, how SED work
  #   Because Regex as well as SED commands and options are single characters,
  #   digits or symbols, they are not easy to read, but extremly compact and
  #   short in size.
  #   By default SED reads a file line by line, and applies the whole sedScript
  #   to one line at a time. This is called a cycle. But the default behaviour 
  #   can be changed by certain commands. It is even possible to read a whole
  #   file without ever ending one cycle.
  #   SED has two buffers, called pattern space and holding space.
  #   The pattern space is a one line buffer, where the whole sedScript is 
  #   applied for each line of the file. Before a new line is read, this 
  #   buffer is emptied. 
  #   The holding space is a multi line buffer. It gets it's input
  #   from the pattern space buffer. 
  #   Because there is a mechanism to switch the content of the two buffers, 
  #   the pattern space buffer can actually hold several lines of a file, 
  #   to which the whole sedScript is applied in one cycle. 
  #   There is also a mechanism to jump to labels within the sedScript, 
  #   which can be used to skip certain commands of the sedScript, similar to 
  #   the goto command in certain languages. 
  #   SED has no if-else statments, but it has a mechanism to determine lines, 
  #   to which the commands of the sedScript shall be applied. 
  #   This is either a "line number from,line number to" range, 
  #   a "regex from,regex to" range, or just a regex. 
  #   For certain commands, like substitute "s" or delete "d", it is even
  #   possible to define both a line number and a regex range.
  # ---------------------------------------------------------------------------
  #doc_end; help_end-----------------------------------------------------------
  [[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:sed_wrapper()"
  # ---------------------------------------------------------------------------
  #============================================================================

  echo "entering sed_wrapper()"

  # INPUT: arguments
  local file="$1"
  local filetmp="$2"
  local commandLineOptions="$3"
  local separator="$4"
  local addressRange="$5"
  local regexRange="$6"
  local command="$7"
  local commandOptions="$8"
  local substituteSearch="${9}"
  local substituteReplace="${10}"

  # sedScript: holds the instructions applied to each line of the file 
  local sedScript 

  # CHECK: input arguments
  echo "file: $file"
  echo "filetmp: $filetmp"
  echo "commandLineOptions: $commandLineOptions"
  echo "separator: $separator"
  echo "addressRange: $addressRange"
  echo "regexRange: $regexRange"
  echo "command: $command"
  echo "commandOptions: $commandOptions"
  echo "substituteSearch: $substituteSearch"
  echo "substituteReplace: $substituteReplace"


  #CHECK: number of arguments
  if [[ "$#" -ne 10 ]]; then
    echo "ERROR: number of arguments: $#; but should be 10"
    return
  fi
  echo "number of arguments: $#"

  #EMPTY: empty the file to write to 
  if [[ -n "$filetmp" ]]; then 
    echo "---------------------EMPTY begin------------------------------------"
    true > "$filetmp"
    echo "---------------------EMPTY end--------------------------------------"
  fi


  echo "---------------------BUILD_SED_SCIPT begin-----------------------"
  # Depending on the command used, the SedScript can have different forms:
  #
  #   [addressRange] {command  [commandOptions]; command [commandOptions]; ...}
  #   [regexRange] {command [commandOptions]; command [commandOptions]; ...}
  # ---------------------------------------------------------------------------
  # apply default separator, if argument is empty
  if [[ -z "$separator" ]]; then
    sep="/"
  else
    sep="$separator"
  fi

  case "$command" in
    a)
      echo "command: a"
      if [[ -n "$addressRange" ]]; then
        sedScript="${addressRange}a $commandOptions"
      elif [[ -n "$regexRange" ]]; then
        sedScript="${regexRange}a $commandOptions"
      else
        echo "wrong application of command a"
      fi
      ;;
    i)
      echo "command: i"
      if [[ -n "$addressRange" ]]; then
        sedScript="${addressRange}i $commandOptions"
      elif [[ -n "$regexRange" ]]; then
        sedScript="${regexRange}i $commandOptions"
      else
        echo "wrong application of command i"
      fi
      ;;
    d)
      echo "command: d"
      if [[ -n "$addressRange" ]] && [[ -n "$regexRange" ]]; then
        sedScript="${addressRange}{${regexRange}d}"
      elif [[ -n "$addressRange" ]]; then
        sedScript="${addressRange}d $commandOptions"
      elif [[ -n "$regexRange" ]]; then
        sedScript="${regexRange}d $commandOptions"
      else
        echo "wrong application of command d"
      fi
      ;;
    =)
      echo "command: ="
      if [[ -n "$addressRange" ]] && [[ -n "$regexRange" ]]; then
        sedScript="${addressRange}{${regexRange}=}"
      elif [[ -n "$addressRange" ]]; then
        sedScript="${addressRange}= $commandOptions"
      elif [[ -n "$regexRange" ]]; then
        sedScript="${regexRange}= $commandOptions"
      else
        echo "wrong application of command ="
      fi
      ;;
    p)
      echo "command: p"
      if [[ -n "$addressRange" ]] && [[ -n "$regexRange" ]]; then
        sedScript="${addressRange}{${regexRange}p}"
      elif [[ -n "$addressRange" ]]; then
        sedScript="${addressRange}p $commandOptions"
      elif [[ -n "$regexRange" ]]; then
        sedScript="${regexRange}p $commandOptions"
      else
        echo "wrong application of command p"
      fi
      ;;
    s)
      echo "command: s"
      
      if [[ -n "$substituteSearch" ]] && [[ -n "$substituteReplace" ]]; then
        if [[ -n "$addressRange" ]] && [[ -n "$regexRange" ]]; then
          sedScript="${addressRange}{${regexRange}\
            s${sep}${substituteSearch}${sep}${substituteReplace}${sep}\
            ${commandOptions}}"
        elif [[ -n "$addressRange" ]]; then
          sedScript="${addressRange}\
            {s${sep}${substituteSearch}${sep}${substituteReplace}${sep}\
              ${commandOptions}}"
        elif [[ -n "$regexRange" ]]; then
          sedScript="${regexRange}\
            {s${sep}${substituteSearch}${sep}${substituteReplace}${sep}\
              ${commandOptions}}"
        else
          sedScript="\
            {s${sep}${substituteSearch}${sep}${substituteReplace}${sep}\
              ${commandOptions}}"
        fi
      else
        echo "wrong application of command s"
        echo "substituteSearch: $substituteSearch\ 
          substituteReplace: $substituteReplace"
      fi
      ;;
  esac
  
  echo "sedScript: $sedScript"
  echo "---------------------BUILD_SCRIPT end---------------------------------"

  # user interaction: 
  # if the function returns 1, do exit function with return 1
  # if user answer a, c, b, t act accordingly
  # answer is passed as a reference not a value! $answer won't work out
  local answer="the answer will be stored here"
  echo "--------------------------------------------------------------"
  echo $'do you want to apply this command?\n$cmd'
  if ! ask_user 'next_sed' "$LINENO" answer; then
    echo "exit: $LINENO"; return 1; 
  fi
  if [[ "$answer" == "a" ]]; then echo "apply to this file"
  elif [[ "$answer" == "c" ]]; then echo "no loop, return"; return
  elif [[ "$answer" == "b" ]]; then echo "no loop, return"; return
  elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
  else echo "$LINENO : something went wrong"
  fi
  echo "--------------------------------------------------------------"


  echo "---------------------SED begin----------------------------------------"
  # apply sed substitution to $file to whole line (g)
  # avoid inline editing by writing into $filetmp
  if [[ -n "$filetmp" ]]; then
    if [[ -n "$commandLineOptions" ]]; then
      echo "sed_1"
      sed -E "$commandLineOptions" -e "$sedScript" <"$file" >"$filetmp" 
    else
      echo "sed_2"
      sed -E -e "$sedScript" <"$file" >"$filetmp"
    fi
  else
    if [[ -n "$commandLineOptions" ]]; then
      echo "sed_3"
      sed -E "$commandLineOptions" -e "$sedScript" <"$file" 
    else
      echo "sed_4"
      sed -E -e "$sedScript" <"$file"
    fi
  fi
  echo "---------------------SED end------------------------------------------"


  #DIFF: show differences before and after
  if [[ -n "$filetmp" ]]; then 
    echo "---------------------DIFF begin-------------------------------------"
    diff -u --color "$file" "$filetmp"
    echo "---------------------DIFF end---------------------------------------"
  fi

  #MV: move/ overwrite $file with $filetmp
  if [[ -n "$filetmp" ]]; then 
    echo "---------------------MV begin---------------------------------------"
    mv "$filetmp" "$file"
    echo "---------------------MV begin---------------------------------------"
  fi

}
# -----------------------------------------------------------------------------

git_diff_head_dirlist() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_diff_head_dirlist(): For Task III
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
    echo "next repository to apply git diff HEAD: $directory"
    if ! ask_user 'next_git_status' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1; 
    fi
    if [[ "$answer" == "a" ]]; then echo "apply to this file"
    elif [[ "$answer" == "c" ]]; then echo "cont. with next file"; continue
    elif [[ "$answer" == "b" ]]; then echo "break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
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
    /usr/bin/git diff HEAD

    # move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    cd "$pwd_script"  || return 1

  done

  # return status of the last statement executed
  return

}
# -----------------------------------------------------------------------------


git_status_dirlist() {

  #============================================================================
  #doc_begin-------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # git_status_dirlist(): For Task III
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
    elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
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
  # git_add_dirlist(): For Task III
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
    elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
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
  # git_commit_dirlist(): For Task III
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
    elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
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
  # git_push_dirlist(): For Task III
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
    elif [[ "$answer" == "t" ]]; then echo "terminate function"; return 1
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
  # git_all_steps_dirlist(): For Task IV
  # Purpose:
  #   apply git status, add, commit, push to one repository after another,
  #     for all your directories. It uses the shell function
  #     $ git status
  #     $ git add .
  #     $ git commit --reedit-message=HEAD   # OR
  #     $ git commit -m "some default message"
  #     $ git push
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
  echo "--------------------------------------------------------------"
  echo "enter function: git_all_steps_dirlist()"
  echo "message: $message"
  echo "--------------------------------------------------------------"

  # loop through directory list
  for directory in $dirlist; do
    
    # 1.) move to local script path, or if it fails
    # return 1 to indicate that the script shall terminate
    if ! cd "$pwd_script"; then
      echo "couldn't cd to pwd_script"; return 1
    fi

    # 2.) if $directory exists (-e) go on
    # otherwise continue with next directory in $dirlist
    if ! [ -e "$directory" ]; then
      echo "dir doesn't exist, go to next"; continue
    fi

    # 3.) move to local repository, or if it fails
    # return 1 to indicate that the script shall terminate
    if ! cd "$directory"; then
      echo "couldn' change directory"; return 1
    fi

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
    echo ">> Q: apply git status to repository: $directory ?"
    if ! ask_user 'git_status' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1
    fi
    if [[ "$answer" == "a" ]]; then echo ">> Ok, apply to this repo"
    elif [[ "$answer" == "c" ]]; then echo ">> cont. with next repo"; continue
    elif [[ "$answer" == "b" ]]; then echo ">> break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo ">> terminate function"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # show git status
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$directory"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    /usr/bin/git status
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo ">> Q: apply git add . to repository: $directory ?"
    if ! ask_user 'git_add_.' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1
    fi
    if [[ "$answer" == "a" ]]; then echo ">> Ok, apply to this repo"
    elif [[ "$answer" == "c" ]]; then echo ">> cont. with next repo"; continue
    elif [[ "$answer" == "b" ]]; then echo ">> break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo ">> terminate function"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # apply git add .
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$directory"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    /usr/bin/git add .
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo ">> Q: apply git commit to repository: $directory ?"
    if ! ask_user 'git_commit' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1
    fi
    if [[ "$answer" == "a" ]]; then echo ">> Ok, apply to this repo"
    elif [[ "$answer" == "c" ]]; then echo ">> cont. with next repo"; continue
    elif [[ "$answer" == "b" ]]; then echo ">> break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo ">> terminate function"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # apply git commit
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$directory"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    /usr/bin/git commit -m "$message"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    # user interaction: 
    # if the function returns 1, do exit function with return 1
    # if user answer a, c, b, t act accordingly
    # answer is passed as a reference not a value! $answer won't work out
    local answer="the answer will be stored here"
    echo "--------------------------------------------------------------"
    echo ">> Q: apply git push to repository: $directory ?"
    if ! ask_user 'git_push' "$LINENO" answer; then
      echo "exit: $LINENO"; return 1 
    fi
    if [[ "$answer" == "a" ]]; then echo ">> Ok, apply to this repo"
    elif [[ "$answer" == "c" ]]; then echo ">> cont. with next repo"; continue
    elif [[ "$answer" == "b" ]]; then echo ">> break this loop"; break
    elif [[ "$answer" == "t" ]]; then echo ">> terminate function"; return 1
    else echo "$LINENO : something went wrong"
    fi
    echo "--------------------------------------------------------------"
    
    # apply git push
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$directory"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    /usr/bin/git push
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

  done
  
  # return status of the last statement executed
  echo "leaving function: git_all_steps_dirlist()" 
  return
  
}
# -----------------------------------------------------------------------------


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
  #                   - prints doc, help or version info, if script is executed
  #                     with ---doc, --help or --version options and exits.
  #                   - prints debug info if script is run with --debug option
  #                 $@: passes the command line arguments to the function
  #                 $?: catches the return status of the last command.
  #
  # TODO: adapt the function get_options() to your use case.
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
  #  Task_3_git_repos:     show all repos.
  #  Task_3_git_diff_head  show diffs between working directory and last commit
  #  Task_3_git_status:    apply git status to all repos.
  #  Task_3_git_add:       apply git add . to all repos.
  #  Task_3_git_commit:    apply git commit to all repos.
  #  Task_3_git_push:      apply git push to all repos.
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
      local filelist_Home_md="./*-loop.wiki/Home.md"
      if ! check_filelist "$filelist_Home_md"; then
        echo "exit: $LINENO"; exit 1
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to go on?"
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
      
      # b.) GLOBAL variable from command line:
      #shellcheck disable=2153
      local commandLineOptions="$COMMAND_LINE_OPTIONS"
      #shellcheck disable=2153
      local separator="$SEPARATOR"
      #shellcheck disable=2153
      local addressRange="$ADDRESS_RANGE"
      #shellcheck disable=2153
      local regexRange="$REGEX_RANGE"
      #shellcheck disable=2153
      local commandOptions="$COMMAND_OPTIONS"
      #shellcheck disable=2153
      local substituteSearch="$SUBSTITUTE_SEARCH"
      #shellcheck disable=2153
      local substituteReplace="$SUBSTITUTE_REPLACE"
      #shellcheck disable=2153
      local appendurl="$APPENDURL"
      echo "--$LINENO commandLineOptions: $commandLineOptions"
      echo "--$LINENO separator: $separator"
      echo "--$LINENO addressRange: $addressRange"
      echo "--$LINENO regexRange: $regexRange"
      echo "--$LINENO commandOptions: $commandOptions"
      echo "--$LINENO substituteSearch: $substituteSearch"
      echo "--$LINENO substituteReplace: $substituteReplace"
      echo "--$LINENO appendurl: $appendurl";
      
      # c.) apply sed to filelist_Home_md 
      #     for each file change the diff will be printed
      #     after every diff there is a user interaction
      local dirbak_Home_md=./bak_Home_md/
      if ! sed_in_files_md "$filelist_Home_md" "$dirbak_Home_md" \
        "$commandLineOptions" "$separator" "$addressRange" "$regexRange" \
        "$commandOptions" "$substituteSearch" "$substituteReplace" \
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
      echo "would you like to go on?"
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

      # b.) GLOBAL variable from command line:
      #shellcheck disable=2153
      local commandLineOptions="$COMMAND_LINE_OPTIONS"
      #shellcheck disable=2153
      local separator="$SEPARATOR"
      #shellcheck disable=2153
      local addressRange="$ADDRESS_RANGE"
      #shellcheck disable=2153
      local regexRange="$REGEX_RANGE"
      #shellcheck disable=2153
      local commandOptions="$COMMAND_OPTIONS"
      #shellcheck disable=2153
      local substituteSearch="$SUBSTITUTE_SEARCH"
      #shellcheck disable=2153
      local substituteReplace="$SUBSTITUTE_REPLACE"
      #shellcheck disable=2153
      local appendurl="$APPENDURL"
      echo "--$LINENO commandLineOptions: $commandLineOptions"
      echo "--$LINENO separator: $separator"
      echo "--$LINENO addressRange: $addressRange"
      echo "--$LINENO regexRange: $regexRange"
      echo "--$LINENO commandOptions: $commandOptions"
      echo "--$LINENO substituteSearch: $substituteSearch"
      echo "--$LINENO substituteReplace: $substituteReplace"
      echo "--$LINENO appendurl: $appendurl";

      # c.) apply sed to filelist_README_md 
      #     for each file change the diff will be printed
      #     after every diff there is a user interaction
      local dirbak_README_md=./bak_README_md/
      if ! sed_in_files_md "$filelist_README_md" "$dirbak_README_md" \
        "$commandLineOptions" "$separator" "$addressRange" "$regexRange" \
        "$commandOptions" "$substituteSearch" "$substituteReplace" \
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
      echo "would you like to move on to Task_3_git_diff_HEAD?"
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

    #doc_begin_main----------Task_3_git_diff-----------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_diff_HEAD: 
    #   apply git diff HEAD to all repos
    # -------------------------------------------------------------------------
    #doc_end_main--------------------------------------------------------------
    Task_3_git_diff_head|t3_git_diff_head|3_gdh)
      # Code
      
      # list of all directories to which you will apply your script
      local pwd_script
      pwd_script="$(pwd)"
      local directorylist="./*-loop*/"
      
      # check status
      if ! git_diff_head_dirlist "$directorylist" "$pwd_script"; then
        echo "exit: $LINENO"; exit 1 
      fi

      # user interaction: 
      # if the function returns 1, do exit function with return 1
      # if user answer a, c, b, t act accordingly
      # answer is passed as a reference not a value! $answer won't work out
      local answer="the answer will be stored here"
      echo "--------------------------------------------------------------"
      echo "would you like to move on to Task_3_git_status?"
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
 
    #doc_begin_main----------Task_3_git_status---------------------------------
    # -------------------------------------------------------------------------
    # Task_3_git_status: 
    #   apply git status to all repos
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



#==============================================================================
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
#doc_end------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:before calling main()"
# -----------------------------------------------------------------------------
#==============================================================================
unset BASH_SOURCE 2>/dev/null
test ".$0" != ".${BASH_SOURCE[0]}" || main "$@"
# -----------------------------------------------------------------------------
if [[ $? == 1 ]]; then exit 1; fi
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:leaving script"
# only exit if not sourced 
# otherwise it would also stops execution of calling script
test ".$0" != ".${BASH_SOURCE[0]}" || exit 0
# -----------------------------------------------------------------------------
