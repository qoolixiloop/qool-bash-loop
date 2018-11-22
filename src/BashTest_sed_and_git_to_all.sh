#!/bin/bash
#shellcheck disable=SC2015

# Script to test functions
# ========================

# new webpages
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
); 
#declare -p URL_ARRAY
url="${URL_ARRAY[0]}"
echo "$url"

#source file to test
# shellcheck disable=SC2034
DEBUG="y" 
# shellcheck disable=SC1091
. Bash_sed_and_git_to_all.sh

test_case_1() {

  # TEST: not the first page for that wiki repository
  #      apart from Home.md
  # EXPECT: append below last reference of that
  #         repository 

  echo "1. test_case_1()"
  local file="BashTest_sed_and_git_to_all/README.md"
  local filetmp="BashTest_sed_and_git_to_all/tmp.md"
  local appendurl="http://github.com/qoolixiloop/qool-markdown-loop/wiki/TEST"
  sed_append_url "$file" "$filetmp" "$appendurl"
  echo "2. text_case_1()"

}
test_case_2() {

  # TEST: the first page for that wiki repository
  #       apart from Home.md
  # EXPECT: append it's newly assigned reference number
  #         to the right position
  
  echo "1. test_case_2()"
  local file="BashTest_sed_and_git_to_all/README.md"
  local filetmp="BashTest_sed_and_git_to_all/tmp.md"
  local appendurl="http://github.com/qoolixiloop/qool-vim-loop/wiki/TEST"
  sed_append_url "$file" "$filetmp" "$appendurl"
  echo "2. text_case_2()"
}
test_case_3() {
  
  # TEST: the URL reference string for that page already exists
  # EXPECT: leave function with message
  
  echo "1. test_case_3()"
  local file="BashTest_sed_and_git_to_all/README.md"
  local filetmp="BashTest_sed_and_git_to_all/tmp.md"
  local
  appendurl="https://github.com/qoolixiloop/qool-markdown-loop/wiki/add-images"
  sed_append_url "$file" "$filetmp" "$appendurl"
  echo "2. text_case_3()"
}

echo "1. script"

# call test cases
#test_case_1 "$@"
#test_case_2 "$@"
test_case_3 "$@"

echo "2. script"



