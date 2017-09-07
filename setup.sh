#!/bin/bash
#
#   Copyright (c) 2017, Christian Muehlhaeuser <muesli@gmail.com>
#
#     For license see LICENSE
#
set -e
pwd="$(pwd)"

. setup_helpers.sh

# create required dirs
mkdir -p "$HOME/Sources/go"

# source .profile so we got correct env-vars for setup
source "shell/profile"

if [[ "$OSTYPE" == "linux"* ]]; then
        # Linux
        echo "Running additional setup for Linux..."
        ./setup_linux.sh

        . /etc/os-release
        OSID="$ID"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "Running additional setup for macOS..."
        ./setup_osx.sh

        OSID="macos"
else
        # Unknown
        echo "Sorry, but setup for '$OSTYPE' is not supported (yet)!"
        exit 1
fi

# Setup profile
linkTo "shell/$OSID/profile" "$HOME/.profile"

# Setup git
linkTo "git/gitconfig" "$HOME/.gitconfig"

# Setup zsh
linkTo "shell/zshrc" "$HOME/.zshrc"

# Setup joe
linkTo "joe/joerc" "$HOME/.joerc"

# Setup elvish
mkdir -p "$HOME/.elvish"
linkTo "shell/rc.elv" "$HOME/.elvish/rc.elv"
linkTo "shell/elvish/lib" "$HOME/.elvish/lib"

cd "$pwd"
