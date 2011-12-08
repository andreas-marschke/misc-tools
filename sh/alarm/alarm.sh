#! /bin/sh
# This is a simple alarm clock!

if [ ! $(echo $1 | egrep [0-2][0-9]:[0-6][0-9]) ];then
    echo "$1 not a proper format"
    exit 0
fi

while [ ! "$(date +%H:%M)" = "$1" ];
do
    sleep 1 
done 
shift
$($@)
