#!/bin/bash
# Copyright 2013, 2014 Christoph Reiter
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

if [ readlink -f "$0" 2> /dev/null ]; then
    BASEDIR="$( cd "$( dirname "$(readlink -f "$0")" )" && pwd )"
else
    BASEDIR="$( cd "$( dirname "$(readlink "$0")" )" && pwd )"
fi

source "$BASEDIR"/_base.sh

download_and_verify;

init_wine;
init_build_env;

extract_deps;
setup_deps;

cleanup;
setup_sdk;
