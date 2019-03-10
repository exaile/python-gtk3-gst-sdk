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
# This module cannot work under MSYS2 and triggers setuptools bug:
# https://github.com/pypa/setuptools/issues/1118
if [ -f "${BUILD_ROOT}/mingw32/lib/python2.7/distutils/msvc9compiler.py" ]; then
  echo 'raise ImportError' > "${BUILD_ROOT}/mingw32/lib/python2.7/distutils/msvc9compiler.py"
fi

install_pydeps "$SDK_DATA"/requirements.txt
