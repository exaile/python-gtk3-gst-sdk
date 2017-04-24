#!/bin/bash
# Copyright 2013-2015 Christoph Reiter
# Modified 2015 Dustin Spicuzza
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

function catch_sigint {
  echo "Caught kill signal, exiting..."
  exit 1
}

trap catch_sigint SIGINT;

# Data directory for program that is getting packaged
TARGET=$(pwd)
SDK_PLATFORM="win32"

#
# Valdiate project configuration
#

[ -f project.config ] || (echo "project.config not found! Are you calling this from the target directory and is the target project setup properly?" && exit 1)
source project.config

if [ -z "$BASEDIR" ]; then
  echo "Cannot source _base.sh without setting BASEDIR variable"
  exit 1
fi

SDK_DATA="$BASEDIR"/data
SDK_MISC="$BASEDIR"/misc

source "$SDK_DATA"/sdk.config

ARCH="${ARCH:-i686}"
PYTHON_VERSION="2"

PYTHON_ID="python${PYTHON_VERSION}"
if [ "${ARCH}" = "x86_64" ]; then
  MINGW="mingw64"
else
  MINGW="mingw32"
fi

function set_build_root {
  BUILD_ROOT="$1"
  MINGW_ROOT="${BUILD_ROOT}/${MINGW}"
}
set_build_root "${TARGET}/_build_root"

function build_pacman {
  pacman --root "${BUILD_ROOT}" "$@"
}


function build_pip {
  "${BUILD_ROOT}"/"${MINGW}"/bin/"${PYTHON_ID}".exe -m pip "$@"
}

function build_python {
  "${BUILD_ROOT}"/"${MINGW}"/bin/"${PYTHON_ID}".exe "$@"
}

function build_makensis {
  "${BUILD_ROOT}"/"${MINGW}"/bin/makensis.exe "$@"
}

function create_root {
  mkdir -p "${BUILD_ROOT}"

  mkdir -p "${BUILD_ROOT}"/var/lib/pacman
  mkdir -p "${BUILD_ROOT}"/var/log
  mkdir -p "${BUILD_ROOT}"/tmp

  build_pacman --noconfirm -Syu
  build_pacman --noconfirm -S base
}

function install_deps {
  if [ -n "$1" ]; then
    build_pacman --noconfirm -S $1
  fi
    
}

function install_pydeps {
  # Since we need pywin32_ctypes to install *before* PyInstaller for Exaile,
  # we will iterate over the requirements file and install one by one, which
  # guarantees the order
  while IFS='' read -r line || [[ -n "$line" ]]; do
    build_pip install $line
  done < "$1"
}

#
# Utility functions for building installers
#
# Arg 1: installer NSI path
function package_installer {
  build_makensis $1
}

#
# Utility function to init the SDK environment, essentially adding the build
# root bin dirs to PATH
#
function init_env {
  export PATH="${BUILD_ROOT}"/"${MINGW}"/bin/:"${BUILD_ROOT}"/usr/bin/:$PATH
}

# Arg 1: directory that contains your translations (*.mo files)
# Arg 2: directory where your frozen exe is
function prune_translations {
  local PROJECT_LOCALE="$1"
  local DIST="$2"

  MAIN_LOCALE="$DIST"/share/locale
  build_python "$SDK_MISC"/prune_translations.py "$PROJECT_LOCALE" "$MAIN_LOCALE"
}

