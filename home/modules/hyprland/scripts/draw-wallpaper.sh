#/usr/bin/env bash

# This is a script to draw wallpaper.
# First argument must exist and targets to image path.
#
# Requirements:
# 1. hyprland
# 2. swww
# 3. GraphicsMagick
# 4. wallust

if [ "$1" == "" ]; then
	echo "Image path must be given"
	exit 1
fi

image_file=$1
target="$HOME/.cache/wallpaper/current"
blur_target="$HOME/.cache/wallpaper/blurred.png"

mkdir -p "$HOME/.cache/wallpaper"
echo "$image_file" >"$HOME/.cache/wallpaper/origin.txt"
cp "$image_file" "$target"
swww img "$target"
wallust run "$target"
gm convert -resize 75% -blur 50x30 "$target" "$blur_target"
