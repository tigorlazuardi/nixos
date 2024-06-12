#/usr/bin/env bash

# This shell script ensures there are wallpaper files in expected locations
# where hyprland ecosystem expected them to find.
#
# Requirements:
#   - GraphicsMagick for the 'gm' command.

if [ "$1" == "" ]; then
	echo "Initial image path is required"
	exit 1
fi

init_wallpaper="$1"
cache_file="$HOME/.cache/wallpaper/current"
blurred="$HOME/.cache/wallpaper/blurred.png"

mkdir -p $HOME/.cache/wallpaper

if [ ! -f "$cache_file" ]; then
	cp "$init_wallpaper" "$cache_file"
fi

if [ ! -f "$blurred" ]; then
	gm convert -resize 75% -blur 50x30 "$cache_file" "$blurred"
fi
