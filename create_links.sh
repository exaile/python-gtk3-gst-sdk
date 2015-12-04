#!/bin/bash
#
# This creates symlinks from the SDK directory to your project's directory,
# to make it easier to run the various build commands from your project
#
#

DIR="$( cd "$( dirname "$0" )" && pwd )"

# Sanity check
if [ "`pwd`" == "$DIR" ]; then
  echo "Run this script from within the target project to create the appropriate"
  echo "symlinks inside of the project."
  echo 
  echo "Don't run this from the SDK directory."
  exit 1
fi

PLATFORM="$1"

if [ "$PLATFORM" == "windows" ]; then
  BASEDIR="$DIR"/win_installer
  source "$DIR"/win_installer/_base.sh
    
  # Create win_installer links
  for file in build_win32_sdk.sh build_win32_installer.sh clean_win32.sh; do 
    [ -h $file ] && rm $file
    ln -s "$DIR"/win_installer/$file $file
  done
  
  echo "Done! Use ./build_win32_sdk.sh to create your SDK environment!"
  exit 0

elif [ "$PLATFORM" == "osx" ]; then
  
  for file in bootstrap_osx.sh build_osx_sdk.sh build_osx_installer.sh clean_osx.sh env.sh misc; do 
    [ -h $file ] && rm $file
    ln -s "$DIR"/osx_bundle/$file $file
  done

  echo "Done! Use ./bootstrap_osx.sh followed by ./build_osx_sdk.sh to create"
  echo "your SDK environment!"

else
  echo "Usage: create_links.sh [windows|osx]"
  echo 
  echo "Creates symlinks within the target project to make using the SDK easier"
  exit 1  
fi



