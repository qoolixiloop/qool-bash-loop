#!/bin/bash
#shellcheck disable=SC2015

# Script to run Task 2
# ====================
# cmd: a-url
# ==========
# call the script in a loop 
# to append all new urls to all README.md and Home.md
# -----------------------------------------------------------------------------
# $ APPENDURL="my_new_Wiki_page_URL" \
  #     ./Scriptname \
  #       --task Task_2_{ home_md | readme_md } \
  #       --cmd a_url
# -----------------------------------------------------------------------------

# APPENDURL: new webpages to append
URL_ARRAY=(
https://github.com/qoolixiloop/qool-bash-loop/wiki/bash-script-to-learn-from-example
https://github.com/qoolixiloop/qool-bash-loop/wiki/bash-script-template
https://github.com/qoolixiloop/qool-bash-loop/wiki/bash-scripting-cheetsheet
https://github.com/qoolixiloop/qool-bash-loop/wiki/bash-scripting-reference-cards
https://github.com/qoolixiloop/qool-tmux-loop/wiki/pair-programming-with-tmate
https://github.com/qoolixiloop/qool-tmux-loop/wiki/tmux-cheet-sheet
https://github.com/qoolixiloop/qool-tmux-loop/wiki/tmux-start-up-script
https://github.com/qoolixiloop/qool-awk-loop/wiki/awk-cheet-sheet
https://github.com/qoolixiloop/qool-awk-loop/wiki/bash-script-with-awk-to-learn-from-example
https://github.com/qoolixiloop/qool-linux-loop/wiki/sed-in-a-nutshell
https://github.com/qoolixiloop/qool-linux-loop/wiki/bash-script-with-sed-to-learn-from-example
https://github.com/qoolixiloop/qool-linux-loop/wiki/grep-in-a-nutshell
https://github.com/qoolixiloop/qool-linux-loop/wiki/bash-script-with-grep-to-learn-from-example
https://github.com/qoolixiloop/qool-linux-loop/wiki/cut-in-a-nutshell
);  declare -p URL_ARRAY

# start loop over url array
for url in "${URL_ARRAY[@]}"; do

  # user interaction
  echo "new url: $url"
  echo "go on? type: y"
  read -r answer

  if [[ "$answer" != "y" ]]; then

    echo "bye"
    break

  else

  # call the script
  DEBUG="y" APPENDURL="$url" \
    ./Bash_sed_and_git_to_all.sh \
    --task Task_2_readme_md \
    --cmd a_url

  fi

done


# -----------------------------------------------------------------------------
# cmd: sr
# =======
# -----------------------------------------------------------------------------
# call the script in a loop 
# to append all new urls to all README.md and Home.md
# -----------------------------------------------------------------------------
# $ SEARCH="mySearch" REPLACE="myReplacment" \
#     ./Scriptname \
#       --task Task_2_{ home_md | readme_md } \
#       --cmd sr
# ---------------------------------------------------------------------------
# sed_search_replace(): For Task II: 
# Purpose: 
#   A wrapper to perform a search and replace with SED. 
# Arguments:
#   $1             : filename of the file to change
#   $2             : a temporary file $filetmp to avoid the SED -i option
#   $3, $RANGE     : the range of lines N,M or just one line M to apply SED
#   $4, $PATTERN   : pattern to find lines
#   $5, $SEARCH    : if pattern is given search only within those lines
#   $6, $REPLACE   : replace what is matched by search
#   $7, $OPTIONS   : option e.g. g, gc, p, d, a, i
#   $8, $SEPARATOR : separator (if you have many backslashes use e.g | or #)
# Escape:
#  "      : used to build the command string -> must be escaped everywhere
#  /      : used to separate command strings -> must be escaped everywhere
#         : or use $8 to define a new separator, e.g. | or #
#  '      : must not be escaped
#  \      : ignored if not necessary, except before a separator, () or []
#         : any symbol can be escaped, whether necessary or not
#  \\     : to escape an escape
#  \\\    : if you have a literal separator
#  &      : used in the replacement to include the match into the replacement
#         : -> escape it in the replacement if literal meaning is wanted
#  in $4  : regex! any symbol must be escaped if literal meaning is wanted
#         : exception within () and []
#  in $5  : regex! any symbol must be escaped if literal meaning is wanted
#         : exception within () and []
#  in $6  : text!
# ---------------------------------------------------------------------------

# SEARCH: search pattern (REGEX, literal meaning within group () )
SEARCH_ARRAY=(
'([302]: https://github.com/qoolixiloop/qool-awk-loop/ \"wikiqool-awk-loop.wiki\")'
'([402]: https://github.com/qoolixiloop/qool-bash-loop/ \"wikiqool-bash-loop.wiki\")'
);  declare -p SEARCH_ARRAY


# REPLACE: replace string (TEXT, only escape " and use separator | )
REPLACE_ARRAY=(
'[302]: https://github.com/qoolixiloop/qool-awk-loop/wiki \"wikiqool-awk-loop.wiki\"'
'[402]: https://github.com/qoolixiloop/qool-bash-loop/wiki \"wikiqool-bash-loop.wiki\"'
);  declare -p REPLACE_ARRAY

# get the array size (number of elements)
array_size="${#SEARCH_ARRAY[@]}"
echo "array_size: $array_size"

# array indexes start at 0
index=0

# start loop over search array (use < sign not <= )
while [[ "$index" < "$array_size" ]]; do

  #assign values
  search="${SEARCH_ARRAY[index]}"
  replace="${REPLACE_ARRAY[index]}"
  echo "search: $search"
  echo "replace: $replace"

  # user interaction
  echo "new search: $search"
  echo "go on? type: y"
  read -r answer

  if [[ "$answer" != "y" ]]; then

    echo "bye"
    break

  else

  # call the script README.md
  DEBUG="y" SEARCH="$search" REPLACE="$replace" SEPARATOR="|" \
    ./Bash_sed_and_git_to_all.sh \
    --task Task_2_readme_md \
    --cmd sr

  # call the script for Home.md
  DEBUG="y" SEARCH="$search" REPLACE="$replace" SEPARATOR="|" \
    ./Bash_sed_and_git_to_all.sh \
    --task Task_2_home_md \
    --cmd sr

  fi

  # increment index ( no $ sign within (()) )
  (( index++  ))

done
