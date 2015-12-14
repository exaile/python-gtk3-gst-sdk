#!/bin/sh

if [ ! -z "$GTK_SDK_VERBOSE" ]; then
  set -x
fi

if [ readlink -f "$0" 2> /dev/null ]; then
    BASEDIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
else
    BASEDIR="$( cd "$( dirname "$(readlink "${BASH_SOURCE[0]}")" )" && pwd )"
fi

DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "$DIR"

export HOME="$DIR/_home"
export PATH="$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export QL_OSXBUNDLE_MODULESETS_DIR="$BASEDIR/modulesets"
alias jhbuild="python2.7 `which jhbuild`"
