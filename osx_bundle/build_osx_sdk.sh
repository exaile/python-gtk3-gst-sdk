#!/bin/bash

set -e

source env.sh

jhbuild build meta-bootstrap
jhbuild build python
jhbuild build meta-gtk-osx-bootstrap
jhbuild build python-gtk3-gst-sdk

# Everything under here is added

# Ensure that pip is in the environment
jhbuild run python -m ensurepip

if [ -f requirements.txt ]; then
    # Note that this doesn't execute pip directly... for some reason if you
    # run the 'pip' command, it uses the wrong python
    jhbuild run python -m pip install -r requirements.txt
fi
