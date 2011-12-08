#! /bin/bash

#############################################################################
#                                                                           #
#   Copyright (C) 2009 Andreas Marschke <xxtjaxx@gmail.com>                 #
#                                                                           #
#   This program is free software; you can redistribute it and/or modify    #
#   it under the terms of the GNU General Public License as published by    #
#   the Free Software Foundation; either version 2 of the License, or       #
#   (at your option) any later version.                                     #
#                                                                           #
#   This program is distributed in the hope that it will be useful,         #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#   GNU General Public License for more details.                            #
#                                                                           #
#   You should have received a copy of the GNU General Public License       #
#   along with this program; if not, write to the                           #
#   Free Software Foundation, Inc.,                                         #
#   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          #
#                                                                           #
#############################################################################

##############################################################################
#                                                                            #
#   This sript should help you cope with the special options of the          #
#   different common buildsystems that are out there such as cmake ,         #
#   automake and GNUmake. For more buildsystems please contact me.           #
#   Suggestions allways wellcome!                                            #
#                                                                            #
##############################################################################

#by default we assume a normal make
buildSystem="make" 
#we assume you really want to install that stuff somewhere lethal
destdir="/usr" 
#Build Type
cmakeBT="Debugfull" 
#Directory prefix
cmakeInstallPrefix="-DCMAKE_INSTALL_PREFIX=$destdir"

function doHelp ()
{
    echo "cbuild - computerized automatic build frontend for common build systems."
    echo ""
    echo "This software is free software you can modify" 
    echo "and redistribuete it under the terms of the "
    echo "GNU GENERAL PUBLIC LICENSE. You should have"
    echo "recieved a copy with this software."
    echo ""
    echo "cbuild ./"
    echo "cbuild --conf [ --prefix=<path> ] [ --buildtype=<buildtype> ]"
}

function doVersion ()
{
    echo "cbuild - computerized automatic build frontend for common build systems."
    echo "version 0.1"
    echo "written by Andreas Marschke <xxtjaxx@gmail.com>"
}

#check for existing out of source builds
function checkDir () 
{
    if [ -d  ./build/ ]; then 
	rm -r build/
    fi
}

function checkBuildSystem () 
{
    if [ -e ./Makefile ]; then
	buildSystem=make
    elif [ -e ./CMakeLists.txt ]; then
	buildSystem=cmake
    elif [ -e ./configure ]; then
	buildSystem=automake
    else
	echo "Can't find a build file."
    fi
}

function onCMake () 
{
    if [ -e ./CMakeLists.txt ]; then 
	checkDir
	mkdir ./build
	cd ./build/
	if [ "x$cmakeOption" = "x" ]; then 
	    cmakeOption=-DCMAKE_BUILD_TYPE=Debugfull -DCMAKE_INSTALL_PREFIX=/usr
	fi
	cmake $cmakeOption .. && make
    fi
}

function onMake ()
{
    if [ -e ./Makefile ] && [ ! -e ./configure ]; then 
	make
    fi
}

function onAutomake () 
{
    if [ -e ./configure ]; then 
	./configure && 	make
    fi
}

doBuild(){
    checkDir
    checkBuildSystem
    
    if [ $buildSystem = "make" ]; then
	onMake
    elif [ $buildSystem = "cmake" ]; then
	onCMake
    elif [ $buildSystem = "automake" ]; then
	onAutomake
    else
	echo "Cant perform build!"
    fi
}

#ćonfigure build 
# function doConf 
# {
#     if [ "$buildSystem" = "cmake" ]; then
#	
#     fi
# }

case "x$1" in 
    "x")
	doBuild
	;;
    "x-v")
	doVersion
	exit 0
	;;
    "x--version")
	doVersion
	exit 0
	;;
    "x--help")
	doHelp
	exit 0
	;;
    "x-h")
	doHelp
	exit 0
	;;
    *)
	
	doConf
	doBuild
	;;
esac