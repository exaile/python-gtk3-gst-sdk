#!/bin/sh

set -e

source env.sh

# to allow bootstrapping again, try to delete everything first
rm -Rf "$QL_OSXBUNDLE_JHBUILD_DEST"
rm -Rf "$HOME/.local"
rm -f "$HOME/.jhbuildrc"
rm -f "$HOME/.jhbuildrc-custom"

# https://git.gnome.org/browse/gtk-osx/tree/jhbuild-revision
JHBUILD_REVISION="7c8d34736c3804"

mkdir -p "$HOME"
git clone git://git.gnome.org/jhbuild "$QL_OSXBUNDLE_JHBUILD_DEST"
(cd "$QL_OSXBUNDLE_JHBUILD_DEST" && git checkout "$JHBUILD_REVISION" && ./autogen.sh && make -f Makefile.plain DISABLE_GETTEXT=1 install >/dev/null)
cp misc/gtk-osx-jhbuildrc "$HOME/.jhbuildrc"
cp misc/jhbuildrc-custom "$HOME/.jhbuildrc-custom"

echo "Bootstrap complete. Run ./build_osx_sdk.sh next."