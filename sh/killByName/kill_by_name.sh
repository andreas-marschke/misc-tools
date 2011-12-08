#!/bin/bash

# This script will search for the 
# application given as option and kills it.

#list of processes list PID and COMMAND
ps=$(ps axo pid,cmd | grep $1 | grep -v "grep" | cut -d" " -f2 ) 
#cut_name=         #Command and arguments 
for i in $ps 
do 
    echo "Do you really want to quit the application?(y|n):"
    echo "$(echo $ps | grep $i | cut -d" " -f3- )"
    in="x"
    echo $( read ) | $in;
    if [ "$in" = "y" ]; then
       kill $i
    fi
done