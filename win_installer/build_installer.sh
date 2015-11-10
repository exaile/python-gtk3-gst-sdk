#!/bin/bash
# Copyright 2013, 2014 Christoph Reiter
# Modified 2015 Dustin Spicuzza
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

DIR="$( cd "$( dirname "$(readlink -f "$0")" )" && pwd )"
BUILD_ENV_SUFFIX="_installer"
source "$DIR"/_base.sh

function init_install_env {

  download_and_verify;

  init_wine;
  init_build_env;

  extract_deps;
  setup_deps;

  cleanup;
}

if [ "$1" == "--reuse" ]; then
  shift
  init_wine
else
  init_install_env
fi

# This should actually build your installer
source "$TARGET_DATA"/_build.sh