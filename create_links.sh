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
  source "$DIR"/win_installer/_base.sh
    
  # Create win_installer links
  for file in build_sdk.sh build_installer.sh clean.sh; do 
    [ -h $file ] && rm $file
    ln -s "$DIR"/win_installer/$file $file
  done
  
  echo "Done! Use ./build_sdk.sh to create your SDK environment!"
  
  exit 0
elif [ "$PLATFORM" == "osx" ]; then
  
  for file in bootstrap.sh build_sdk.sh clean.sh env.sh misc; do 
    [ -h $file ] && rm $file
    ln -s "$DIR"/osx_bundle/$file $file
  done

  echo "Done! Use ./bootstrap.sh followed by ./build_sdk.sh to create"
  echo "your SDK environment!"

else
  echo "Usage: create_links.sh [windows|osx]"
  echo 
  echo "Creates symlinks within the target project to make using the SDK easier"
  exit 1  
fi



