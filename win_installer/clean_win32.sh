#!/bin/bash
# Copyright 2014 Christoph Reiter
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

if [ ! -z "$GTK_SDK_VERBOSE" ]; then
  set -x
fi

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$BASEDIR"/_base.sh
echo "${BUILD_ROOT}"
rm -rf "${BUILD_ROOT}"

[ -f _clean.sh ] && source _clean.sh
