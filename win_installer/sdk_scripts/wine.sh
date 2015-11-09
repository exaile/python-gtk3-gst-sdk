#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
export WINEPREFIX="$DIR"/_wine_prefix
export WINEDEBUG=-all
export WINEARCH=win32

if [ "$1" == "--headless" ]; then
  DISPLAY=be_quiet_damnit wine wineboot -u
else
  wine wineboot -u
fi

wine cmd /k "$DIR"/env.bat
