#! /bin/bash
###################################################
# This shell script should help developers lookup #
# and read on which parts of their applications   # 
# the crash or segfault happened.                 #
###################################################

helpme=$(echo $@ | sed 's:\ :\n:g' | grep "--help")
hme=$(echo $@ | sed 's:\ :\n:g' | grep "-h")

function doHelp()
{
    echo "Usage: btraceview [BACKTRACE-FILE] [PROJECT-DIRECTORY] [PROJECT-NAME]"
    echo "[BACKTRACE-FILE]: The saved Backtrace of your application."
    echo "[PROJECT-DIRECTORY]: The root dir of the project (full path)"
    echo "[PROJECT-NAME]: The name of the executable or project"
    echo "This will run a full code search of what lines are concerned. "
    echo "It will return a nice list of all parts of the backtrace"
    echo "that are directly related to your applicaton and not some"
    echo "underlying technology."
    exit 0
}

#I couldnt find anything else except that to filter out the hexnumber at the beginning 
#Im open for suggestions

if [ $helpme ] || [ $hme ]; then
    doHelp
else
    $file=$1
    $projDir=$2
    $projName=$3
    found=$(grep $projName $file | sed s/\#[0-9][0-9]//g | sed s/\#[0-9]//g | sed 's;0x[[:xdigit:]]*\ in;;g' | sed s/\ \ //g | sort | sed 's/:\ /:/g')
    for i in $found
    do
	echo -o ''
    done
fi