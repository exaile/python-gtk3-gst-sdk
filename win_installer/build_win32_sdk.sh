#!/bin/bash
# Copyright 2013, 2014 Christoph Reiter
# Modified 2015 Dustin Spicuzza
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

set -e

if [ ! -z "$GTK_SDK_VERBOSE" ]; then
  set -x
fi
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$BASEDIR"/_base.sh

[[ -d "${BUILD_ROOT}" ]] && (echo "${BUILD_ROOT} already exists"; exit 1)

create_root
install_deps "$SDK_DOWNLOAD_PKGS"
install_pydeps "$SDK_DATA"/requirements.txt