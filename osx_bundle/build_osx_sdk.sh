#!/bin/bash

set -e

source env.sh

jhbuild build meta-bootstrap
jhbuild build python
jhbuild build meta-gtk-osx-bootstrap
jhbuild build python-gtk3-gst-sdk

if [ -f requirements.txt ]; then
    jhbuild run pip install -r requirements.txt
fi
