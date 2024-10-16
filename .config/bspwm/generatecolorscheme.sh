#!/bin/sh

if [ -z $1 ]; then
	echo "First argument is the path to the file"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "file: '$1' doesn't exist"
	exit 2
fi

wal -i $(readlink -f $1) -nst

cp $HOME/.cache/wal/colors.Xresources $HOME/.Xresources
echo Copied .Xresources
cp $HOME/.cache/wal/colors.sh $HOME/.config/bspwm/
echo Copied colors.sh
