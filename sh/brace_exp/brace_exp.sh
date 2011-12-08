# !/bin/bash

#this is a small example for using brace expansion 
for i in $@; do
    case "$i" in
	"$(i#'--prefix=')" ) #matches pattern '--prefix='
	    cmakePrefix=${i :${i#'--prefix='} :${#i}}  #removes '--prefix=' adn assigns the tail left to cmakePrefix
	    echo "$cmakePrefix"
	    ;;
	"$(i#'--buildtype=')" )
	    cmakeBT=${i :${#--buildtype=} :${#i}}
	    echo "xxx$cmakeBT"
	    ;;
	*)
	    if [ -e $i ]; then
		:
	    else
		doHelp
	    fi
	    echo $1 $2 "Huh?"
	    ;;
    esac
done
