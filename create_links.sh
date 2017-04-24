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
  echo "Deprecated! MSYS2 does not support symlink by default!"
  exit 1

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



