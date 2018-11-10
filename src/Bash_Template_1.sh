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
# shellcheck source=./Script_2_scratch.sh
#. ./Script_2_scratch.sh
#. Script_2_scratch.sh
./Script_2_scratch.sh
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# TODO: function definitions (API) and shell variables (constants) go here
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:function definitions" 

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
	if [[ $? == 1 ]]; then return 1; fi
	[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}: \
        $?", "$*", "$OUTPUTFILE", $DEBUG

	# TODO: The script's execution part goes here
	[[ $DEBUG == 'y' ]] && echo "--$LINENO ${BASH_SOURCE[0]}:main()" 





  
  
  
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
