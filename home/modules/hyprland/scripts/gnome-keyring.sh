#/usr/bin/bash

secret_file=$1

cat "$secret_file" | gnome-keyring-daemon --unlock
gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
