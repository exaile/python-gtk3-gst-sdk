#!/bin/sh

source env.sh

mkdir -p "$HOME"
git clone git://git.gnome.org/jhbuild _jhbuild
(cd _jhbuild && ./autogen.sh && make -f Makefile.plain DISABLE_GETTEXT=1 install >/dev/null)
cp misc/gtk-osx-jhbuildrc "$HOME/.jhbuildrc"
cp misc/jhbuildrc-custom "$HOME/.jhbuildrc-custom"