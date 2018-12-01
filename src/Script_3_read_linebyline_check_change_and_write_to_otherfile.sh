#!/bin/bash

# Original Purpose of the script:
#  this new string should be added to many webpage files
input_string_url="https://github.com/qoolixiloop/qool-markdown-loop/wiki/add-paypal-button"
echo "1.) new input string: $input_string_url"
#-----------------------------------------------------------------------------

# LO 6) Purpose of these lines:
#   cut out the XXX part from qool-XXX-loop
#   grep -o: only print matching part
pattern_repo="qool-.*-loop"
search_repo=$(echo "$input_string_url" | grep -o "$pattern_repo" )
echo "2.) search repo: $search_repo"
#-----------------------------------------------------------------------------

# LO 6) Purpose of these lines:
#   pattern to search for in the webpage file 
pattern="^\[.*github\.com\/qoolixiloop\/$search_repo\/wiki.*wiki page"
echo "3.) patter to search: $pattern"
#-----------------------------------------------------------------------------

# Purpose of these lines:
#   assign file list of webpages to read from, put them in an array

# list of files to read from
file_r_1="file_r.md"
file_r_2="file_r.md"
file_r_3="file_r.md"

# LO 7) assign to arrays
arr_file_r=("$file_r_1" "$file_r_2" "$file_r_3")
#-----------------------------------------------------------------------------

# Purpose of these lines:
#   assign file list of webpages to read from, put them in an array
#   and empty the former content of the files.

# list of files to write to
file_w_S1_1="file_w_S1_1.md"
file_w_S1_2="file_w_S1_2.md"
file_w_S1_3="file_w_S1_3.md"
file_w_S2_1="file_w_S2_1.md"
file_w_S2_2="file_w_S2_2.md"
file_w_S2_3="file_w_S2_3.md"
file_w_S3_1="file_w_S3_1.md"
file_w_S3_2="file_w_S3_2.md"
file_w_S3_3="file_w_S3_3.md"

# LO 7) assign files to arrays
arr_file_w_S1=("$file_w_S1_1" "$file_w_S1_2" "$file_w_S1_3")
arr_file_w_S2=("$file_w_S2_1" "$file_w_S2_2" "$file_w_S2_3")
arr_file_w_S3=("$file_w_S3_1" "$file_w_S3_2" "$file_w_S3_3")

# LO 8) to empty the files
true > "$file_w_S1_1"
true > "$file_w_S1_2"
true > "$file_w_S1_3"
true > "$file_w_S2_1"
true > "$file_w_S2_2"
true > "$file_w_S2_3"
true > "$file_w_S3_1"
true > "$file_w_S3_2"
true > "$file_w_S3_3"
#-----------------------------------------------------------------------------

# BASH: WHILE READ LINE: three different solutions 
# ================================================

# LO 4) define global variables
ANSWER1="1" #global variable
ANSWER2="2" #global variable

# LO 5) define main function
main() {
  
  file_nr=0

  # LO 9) loop through files array
  for file in "${arr_file_r[@]}"; do

    echo "ANSWER1: $ANSWER1"  # LO 4) first time prints 1 (global variable)
    local ANSWER1=3  # LO 4) local variable
    echo "ANSWER1: $ANSWER1"  # LO 4) first time prints 3 (now it is local)
    #------------------
    # LO 2) read-command for user interaction
    echo "give ANSWER1: just press enter" 
    read -r ANSWER1  # "$ANSWER1" would not work
    #------------------
    echo "ANSWER1: $ANSWER1" # LO 4) prints empty character
    echo "file: $file"
    echo "file_nr: $file_nr"
    echo "arr_file_r: ${arr_file_r["$file_nr"]}"

    # LO 2) create new file descriptor fd=3
    exec 3<"$file"

    # LO 9) loop through lines, -r do read backslashes '\' literally
    # LO 2) -u fd, read from file descriptor fd=3
    line_nr=0
    while read -r -u 3 line; do

      # increment line number counter
      (( line_nr ++ ))

      echo "ANSWER2: $ANSWER2" # LO 4) first time prints 2 (global variable) 
      #-------------------
      # LO 3) read command for user interaction
      # LO 2)-u fd, read from file descriptor fd=1
      echo "give ANSWER2: just press enter"       
      read -r -u 0 ANSWER2  #"$ANSWER2" wourld not work
      #-------------------
      echo "ANSWER2: $ANSWER2" # LO 4) prints empty characters
      echo "line_nr: $line_nr"

      # LO 1) ==Solution 1==
      # LO 6)rhs is a regex; don't surround it with double quotes ""
      if [[ "$line" =~ $pattern ]]; then
        # writes to shell
        echo "1.BashRegex) we are on line nr: $line_nr"
        echo "2.BashRegex) we are on line: $line"; 
        # writes to file
        echo "[123456789]$line" >> "${arr_file_w_S1["$file_nr"]}" 
      else
        # writes to shell
        echo "3.BashRegex) we are on line nr: $line_nr"
        echo "4.BashRegex) we are on line: $line"; 
        # writes to file
        echo "$line" >> "${arr_file_w_S1["$file_nr"]}" 
      fi
      echo "arr_file_w_S1: ${arr_file_w_S1["$file_nr"]}" 

      # LO 1) ==Solution 2==
      # -E: extended Reges
      echogrep_found_pattern=$(echo "$line" | grep -E "$pattern")

      # -n: if string is not empty 
      if [[ -n "$echogrep_found_pattern"  ]]; then 
        # writes to shell
        echo "1.EchoGrep) we are on line nr: $line_nr"
        echo "2.EchoGrep) we are on line: $line"; 
        echo "3.EchoGrep) found pattern: ${echogrep_found_pattern}"
        # writes to file
        echo "[123456789]$line" >> "${arr_file_w_S2["$file_nr"]}" 
      else
        # writes to shell
        echo "4.EchoGrep) we are on line nr: $line_nr"
        echo "5.EchoGrep) we are on line: $line"; 
        # writes to file
        echo "$line" >> "${arr_file_w_S2["$file_nr"]}" 
      fi
      echo "arr_file_w_S2: ${arr_file_w_S2["$file_nr"]}" 

      # LO 1) ==Solution 3==
      # $pattern can be put within double quotes for grep
      if grep -q "$pattern" <<<"$line"; then
        # writes to shell
        echo "1.StringToGrep) we are on line nr: $line_nr"
        echo "2.StringToGrep) we are on line: $line"; 
        # writes to file
        echo "[123456789]$line" >> "${arr_file_w_S3["$file_nr"]}" 
      else
        # writes to shell
        echo "3.StringToGrep) we are on line nr: $line_nr"
        echo "4.StringToGrep) we are on line: $line"; 
        # writes to file
        echo "$line" >> "${arr_file_w_S3["$file_nr"]}" 
      fi
      echo "arr_file_w_S3: ${arr_file_w_S3["$file_nr"]}" 

    done #<"$file"   #LO 3) would also work instead of -u 3   

    # increment file number counter
    (( file_nr ++ ))

  done
}

# LO 5) call main
main "$@"

# LO 4) this variable was NOT overwritten in main()
echo "End of script: $ANSWER1" # prints 1

# LO 4) this variable was overwritten in main()
echo "End of script: $ANSWER2" # prints entered empty character
