#!/bin/bash
# Copyright 2014 Christoph Reiter
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

rm -f _sdk
rm -rf _build_env
rm -rf _build_env_installer

[ -f _clean.sh ] && source _clean.sh
