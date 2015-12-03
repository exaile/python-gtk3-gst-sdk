#!/bin/bash
# Copyright 2013-2015 Christoph Reiter
# Modified 2015 Dustin Spicuzza
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

trap 'exit 1' SIGINT;

# Data directory for program that is getting packaged
TARGET=$(pwd)
SDK_PLATFORM="win32"

#
# Valdiate project configuration
#

[ -f project.config ] || (echo "project.config not found! Are you calling this from the target directory and is the target project setup properly?" && exit 1)
source project.config

function _check_project_var {
  local NOT_SET="${1}_NOT_SET"
  if [[ "$2" == "1" && "${!NOT_SET}" == "1" ]]; then
    echo
  elif [ -z "${!1}" ]; then
    echo "ERROR: $1 was not set in project.config"
    if [ "$2" == "1" ]; then
      echo "-- if you don't need to set it, set $1_NOT_SET=1"
    fi
    exit 1
  fi
}

_check_project_var DOWNLOAD_FILES 1
_check_project_var DOWNLOAD_HASHES 1
_check_project_var GIT_CLONE_URL

if [ -z "$BASEDIR" ]; then
  echo "Cannot source _base.sh without setting BASEDIR variable"
  exit 1
fi

SDK_BIN="$BASEDIR"/_bin
SDK_DATA="$BASEDIR"/data
SDK_MISC="$BASEDIR"/misc
SDK_SCRIPTS="$BASEDIR"/sdk_scripts

TARGET_BIN="$TARGET"/_bin
TARGET_DATA="$TARGET"

BUILD_ENV="$TARGET"/_build_env"$BUILD_ENV_SUFFIX"
DEPS="$BUILD_ENV"/deps

source "$SDK_DATA"/sdk.config


function _download_and_verify {
  local THISBIN="$1"
  local THISDATA="$2"
  local HASHES="$3"
  local DOWNLOADS="$4"
  
  mkdir -p "$THISBIN"
  
  if [ -z "$HASHES" ] || (cd "$THISBIN" && echo "$HASHES" | shasum -a 256 -b --status -c -); then
    echo "all installers present in $THISBIN, continue.."
  else
    for f in $DOWNLOADS; do
      [ -z "$f" ] || wget -P "$THISBIN" -c "$f"
    done
    
    [ -f "$THISDATA"/requirements.txt ] && pip install --no-use-wheel --download="$THISBIN" -r "$THISDATA"/requirements.txt
    
    # Make sure we got everything right
    (cd "$THISBIN" && echo "$HASHES" | shasum -a 256 -b -c -) || exit
  fi
}


function download_and_verify {
    # download all installers and check with shasum
    _download_and_verify "$SDK_BIN" "$SDK_DATA" "$SDK_DOWNLOAD_HASHES" "$SDK_DOWNLOAD_FILES"
    _download_and_verify "$TARGET_BIN" "$TARGET_DATA" "$DOWNLOAD_HASHES" "$DOWNLOAD_FILES"
}

function init_wine {
    # set up wine environ
    export WINEARCH=win32
    export WINEPREFIX="$BUILD_ENV"/wine_env
    export WINEDEBUG=-all

    # try to limit the effect on the host system when installing with wine.
    export HOME="$BUILD_ENV"/home
    export XDG_DATA_HOME="$HOME"/.local/share
    export XDG_CONFIG_HOME="$HOME"/.config
    export XDG_CACHE_HOME="$HOME"/.cache
    export DISPLAY_SAVED=$DISPLAY
    export DISPLAY=be_quiet_damnit

    mkdir -p "$WINEPREFIX"
    wine wineboot -u
}

function init_build_env {
    # create a fresh build env and link the binaries in
    rm -Rf "$BUILD_ENV"
    mkdir "$BUILD_ENV"
    ln -s "$SDK_BIN" "$BUILD_ENV"/bin
}


function extract_deps {
  [ -f "$SDK_DATA"/_extract_deps.sh ] && source "$SDK_DATA"/_extract_deps.sh
  [ -f "$TARGET_DATA"/_extract_deps.sh ] && source "$TARGET_DATA"/_extract_deps.sh
}

function setup_deps {
  [ -f "$SDK_DATA"/_setup_deps.sh ] && source "$SDK_DATA"/_setup_deps.sh
  [ -f "$TARGET_DATA"/_setup_deps.sh ] && source "$TARGET_DATA"/_setup_deps.sh
  
  install_pydeps
}

function _install_pydep {
  # arg1: requirements.txt, arg2: output dir
  local PYTHON="$PYDIR"/python.exe
  if [ -f "$1" ]; then
    sed 's/^#bindep\s*//' "$1" > "$1".tmp
    (wine "$PYTHON" -m pip install -f "$2" -r "$1".tmp)
    rm "$1".tmp
  fi
}

function install_pydeps {
  local PYTHON="$PYDIR"/python.exe
  _install_pydep "$SDK_DATA"/requirements.txt "$SDK_BIN"
  _install_pydep "$TARGET_DATA"/requirements.txt "$TARGET_BIN"
}


function setup_sdk {
    SDK="$BUILD_ENV"/python-gtk3-gst-sdk
    mkdir "$SDK"

    # launchers, README
    ln -s "$SDK_SCRIPTS"/* "$SDK"
    [ -d "$TARGET"/sdk_scripts ] && ln -s "$TARGET"/sdk_scripts/* "$SDK"
    
    # Create a clone script
    echo "git clone $GIT_CLONE_URL" > "$SDK"/clone.bat

    # bin deps
    ln -s "$DEPS" "$SDK"/deps
    ln -s "$PYDIR" "$SDK"/python
    ln -s "$GITDIR" "$SDK"/git

    # link to base dir
    ln -s "$SDK" "$TARGET"/_sdk

    # create the distributable archive
    echo "Creating distribution tarball (ctrl-c if you don't care)"
    tar --dereference -zcvf "$TARGET"/python-gtk3-gst-win32-sdk.tar.gz _sdk/ \
        --exclude=_sdk/_wine_prefix &> /dev/null
}

function cleanup {
    # no longer needed, save disk space
    rm -Rf "$PYGI"
}

#
# Utility functions for building installers
#

# Arg 1: directory where your frozen exe is
# Arg 2: directory that contains your translations (*.mo files)
function prune_translations {
  local DIST="$1"
  local PROJECT_LOCALE="$2"

   MAIN_LOCALE="$DIST"/share/locale
   python "$SDK_MISC"/prune_translations.py "$PROJECT_LOCALE" "$MAIN_LOCALE"
}


# Arg 1: installer NSI path
# After this function is called, the installer will be in $BUILD_ENV
function package_installer {
    local INSTALLER_NSI="$1"
    local NSIS_PATH=$(winepath "C:\\Program Files\\NSIS\\")
    
    # now package everything up
    (cd "$BUILD_ENV" && wine "$NSIS_PATH/makensis.exe" "$INSTALLER_NSI")
    #mv "$BUILD_ENV/quodlibet-LATEST.exe" "$TARGET/quodlibet-$QL_VERSION-installer.exe"
}


