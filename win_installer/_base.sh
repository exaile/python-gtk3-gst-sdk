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

[ -f deps.txt ] || (echo "deps.txt not found! Are you calling this from the target directory and is the target project setup properly?" && exit 1)
[ -f hashes.txt ] || (echo "hashes.txt not found! Are you calling this from the target directory and is the target project setup properly?" && exit 1)

DIR="$( cd "$( dirname "$(readlink -f "$0")" )" && pwd )"

SDK_BIN="$DIR"/_bin
SDK_DATA="$DIR"/data
SDK_SCRIPTS="$DIR"/sdk_scripts

TARGET_BIN="$TARGET"/_bin
TARGET_DATA="$TARGET"

BUILD_ENV="$TARGET"/_build_env"$BUILD_ENV_SUFFIX"
DEPS="$BUILD_ENV"/deps

#QL_REPO="$DIR"/..
#BUILD_BAT="$MISC"/build.bat
#INST_ICON="$MISC"/quodlibet.ico
#NSIS_SCRIPT="$MISC"/win_installer.nsi

#QL_REPO_TEMP="$BUILD_ENV"/ql_temp
#QL_TEMP="$QL_REPO_TEMP"/quodlibet


PYGI_AIO_VER="3.14.0_rev22"


function _download_and_verify {
  THISBIN="$1"
  THISDATA="$2"
  
  mkdir -p "$THISBIN"
  
  if (cd "$THISBIN" && cat "$THISDATA"/hashes.txt | sha256sum --status --strict -c -); then
    echo "all installers present in $THISBIN, continue.."
  else
    for f in `cat "$THISDATA"/deps.txt`; do
      wget -P "$THISBIN" -c "$f"
    done
    
    [ -f "$THISDATA"/requirements.txt ] && pip install --download="$THISBIN" -r "$THISDATA"/requirements.txt
    
    # Make sure we got everything right
    (cd "$THISBIN" && cat "$THISDATA"/hashes.txt | sha256sum --strict -c -) || exit
  fi
}


function download_and_verify {
  
    # download all installers and check with sha256sum
    _download_and_verify "$SDK_BIN" "$SDK_DATA"
    _download_and_verify "$TARGET_BIN" "$TARGET_DATA"
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

    # link the batch file and nsis file in
    #ln -s "$BUILD_BAT" "$BUILD_ENV"
    #ln -s "$NSIS_SCRIPT" "$BUILD_ENV"
    #ln -s "$INST_ICON" "$BUILD_ENV"
}

# Argument 1: the git tag
function clone_repo {

    if [ -z "$1" ]
    then
        echo "missing arg"
        exit 1
    fi

    # clone repo
    git clone "$QL_REPO" "$QL_REPO_TEMP"
    (cd "$QL_REPO_TEMP" && git checkout "$1") || exit 1
    QL_VERSION=$(cd "$QL_TEMP" && python -c "import quodlibet.const;print quodlibet.const.VERSION,")

    if [ "$1" = "master" ]
    then
        local GIT_REV=$(git rev-list --count HEAD)
        local GIT_HASH=$(git rev-parse --short HEAD)
        QL_VERSION="$QL_VERSION-rev$GIT_REV-$GIT_HASH"
    fi
}

function extract_deps {
  [ -f "$SDK_DATA"/extract_deps.sh ] && source "$SDK_DATA"/extract_deps.sh
  [ -f "$TARGET_DATA"/extract_deps.sh ] && source "$TARGET_DATA"/extract_deps.sh
}

function setup_deps {
  [ -f "$SDK_DATA"/setup_deps.sh ] && source "$SDK_DATA"/setup_deps.sh
  [ -f "$TARGET_DATA"/setup_deps.sh ] && source "$TARGET_DATA"/setup_deps.sh
  
  install_pydeps
}

function install_pydeps {
  local PYTHON="$PYDIR"/python.exe
  
  if [ -f "$SDK_DATA"/requirements.txt ]; then    
    (wine $PYTHON -m pip install -f "$SDK_BIN" -r "$SDK_DATA"/requirements.txt)
  fi
  
  if [ -f "$TARGET_DATA"/requirements.txt ]; then
    (wine $PYTHON -m pip install -f "$TARGET_BIN" -r "$TARGET_DATA"/requirements.txt)
  fi
}

function build_quodlibet {
    (cd "$QL_TEMP" && python setup.py build_mo)

    # now run py2exe etc.
    (cd "$BUILD_ENV" && wine cmd /c build.bat)

    QL_DEST="$QL_TEMP"/dist
    QL_BIN="$QL_DEST"/bin

    # python dlls
    cp "$PYDIR"/python27.dll "$QL_BIN"

    # copy deps
    cp "$DEPS"/*.dll "$QL_BIN"
    cp -R "$DEPS"/etc "$QL_DEST"
    cp -R "$DEPS"/lib "$QL_DEST"
    cp -R "$DEPS"/share "$QL_DEST"

    # remove translatins we don't support
    QL_LOCALE="$QL_TEMP"/build/share/locale
    MAIN_LOCALE="$QL_DEST"/share/locale
    python "$MISC"/prune_translations.py "$QL_LOCALE" "$MAIN_LOCALE"

    # copy the translations
    cp -RT "$QL_LOCALE" "$MAIN_LOCALE"

    # remove various translations that are unlikely to be visible to the user
    # in our case and just increase the installer size
    find "$MAIN_LOCALE" -name "gtk30-properties.mo" -exec rm {} \;
    find "$MAIN_LOCALE" -name "gsettings-desktop-schemas.mo" -exec rm {} \;
    find "$MAIN_LOCALE" -name "iso_*.mo" -exec rm {} \;
}

function package_installer {
    local NSIS_PATH=$(winepath "C:\\Program Files\\NSIS\\")
    # now package everything up
    (cd "$BUILD_ENV" && wine "$NSIS_PATH/makensis.exe" win_installer.nsi)
    mv "$BUILD_ENV/quodlibet-LATEST.exe" "$DIR/quodlibet-$QL_VERSION-installer.exe"
}

function package_portable_installer {
    local PORTABLE="$BUILD_ENV/quodlibet-$QL_VERSION-portable"
    mkdir "$PORTABLE"

    cp "$MISC"/quodlibet.lnk "$PORTABLE"
    cp "$MISC"/exfalso.lnk "$PORTABLE"
    cp "$MISC"/README-PORTABLE.txt "$PORTABLE"/README.txt
    mkdir "$PORTABLE"/config
    PORTABLE_DATA="$PORTABLE"/data
    mkdir "$PORTABLE_DATA"
    cp -RT "$QL_DEST" "$PORTABLE_DATA"
    cp "$MISC"/conf.py "$PORTABLE_DATA"/bin/quodlibet/

    wine "$SZIPDIR"/7z.exe a "$BUILD_ENV"/portable-temp.7z "$PORTABLE"
    cat "$SZIPDIR"/7z.sfx "$BUILD_ENV"/portable-temp.7z > "$DIR/quodlibet-$QL_VERSION-portable.exe"
    rm "$BUILD_ENV"/portable-temp.7z
}

function setup_sdk {
    SDK="$BUILD_ENV"/python-gtk3-gst-sdk
    mkdir "$SDK"

    # launchers, README
    ln -s "$SDK_SCRIPTS"/* "$SDK"
    [ -d "$TARGET"/sdk_scripts ] && ln -s "$TARGET"/sdk_scripts/* "$SDK"

    # bin deps
    ln -s "$DEPS" "$SDK"/deps
    ln -s "$PYDIR" "$SDK"/python
    ln -s "$GITDIR" "$SDK"/git

    # link to base dir
    ln -s "$SDK" "$TARGET"/_sdk

    # create the distributable archive
    echo "Creating distribution tarball (ctrl-c if you don't care)"
    tar --dereference -zcvf "$TARGET"/python-gtk3-gst-sdk.tar.gz _sdk/ \
        --exclude=_sdk/_wine_prefix &> /dev/null
}


function cleanup {
    # no longer needed, save disk space
    rm -Rf "$PYGI"
}
