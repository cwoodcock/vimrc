#!/bin/sh

VIM_RUNTIME_DIR="$HOME/.vim_runtime"
INPUT="${VIM_RUNTIME_DIR}/plugin.repos"
PLUGIN_DIR="$HOME/.vim_plugins"

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 1; }

[ ! -d $PLUGIN_DIR ] && { mkdir -p $PLUGIN_DIR; }


function process() {
    line="$@"

    repo="$(echo $line |  tr -s ' ' | cut -f1 -d' ')"
    branch="$(echo $line | tr -s ' ' | cut -f2 -d' ')"

    # Determine the name from the repo
    name="$(echo $repo | sed 's/^.*\///g' | sed 's/\.git$//g')"

    if [[ ! -d "$name" ]]; then
        git clone $repo
        echo "Switching to `pwd`/$name"
        pushd $name > /dev/null
        echo "Checkout $branch in `pwd`"
        git checkout $branch
        popd > /dev/null
    else
        echo "Plugin already installed: $name"
    fi
}


pushd $PLUGIN_DIR > /dev/null
while read -r line; do
    # skip lines that:
    #   - start with # (with optional leading whitespace
    #   - are empty
    if [[ ! "$line" =~ ((^|\s+)#)|^$ ]]; then
        if [[ -z "$@" ]]; then
            process $line
        else
            for p in "$@"; do
                if [[ $line =~ $p ]]; then
                    process $line
                fi
            done
        fi
    fi
done < $INPUT
popd > /dev/null

