#!/bin/bash
if [ x`which inkscape` = x ]; then 
    echo "$0 cant be run because inkscape is not installed!"
else
    if [ -f $1 ] && [ ! x$(echo $1 | grep svg) = x ]; then
	inkscape --export-height=8 --export-width=8 --export-area-page --export-png=hi8-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=16 --export-width=16 --export-area-page --export-png=hi16-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=22 --export-width=22 --export-area-page --export-png=hi22-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=32 --export-width=32 --export-area-page --export-png=hi32-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=48 --export-width=48 --export-area-page --export-png=hi48-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=64 --export-width=64 --export-area-page --export-png=hi64-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=128 --export-width=128 --export-area-page --export-png=hi128-app-$(echo $1 | cut -d. -f1).png  $1
	inkscape --export-height=256 --export-width=256 --export-area-page --export-png=hi256-app-$(echo $1 | cut -d. -f1).png  $1
    fi
fi