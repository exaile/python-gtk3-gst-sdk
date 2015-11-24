#!/bin/sh

if [ "$1" == "" ]; then
    echo "Usage: $0 myprogram.app"
    echo
    echo "Creates a dmg from an application bundle."
    exit 1
fi

BUNDLE_PATH="$1"

FILENAME=$(basename "$BUNDLE_PATH")
EXTENSION="${FILENAME##*.}"
FILENAME="${FILENAME%.*}"

if [ "$EXTENSION" != ".app" ]; then
    echo "$BUNDLE_PATH is not an app bundle!"
    exit 1
fi

if [ ! -d "$BUNDLE_PATH" ]; then
    echo "$BUNDLE_PATH is not a directory, are you sure it's an app bundle?"
    exit 1
fi


mkdir -p _dmg/"$FILENAME"

cp -r "$BUNDLE_PATH" _dmg/"$FILENAME"
ln -s /Applications _dmg/"$FILENAME"

pushd _dmg
hdiutil create -srcfolder "$FILENAME" "$FILENAME".dmg
popd

mv _dmg/"$FILENAME".dmg "$FILENAME".dmg

rm -rf _dmg
