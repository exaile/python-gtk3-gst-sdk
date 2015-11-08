Python + GTK3 + GStreamer SDK
=============================

The goal of this SDK is to make it easier to package python applications that
use GTK3+GStreamer.

* To build applications for OSX, see the osx_bundle directory
* To build applications for Windows, see the win_bundle directorys

If the target application is already set up to use this SDK, you can create
convenience symlinks by running the `create_links.sh` script.

  cd my_app/win_installer
  /path/to/sdk/create_links.sh windows

Authors
=======

This repository + SDK is a fork of the work done by the
[Quod Libet](https://github.com/quodlibet/quodlibet) project. The original
code was copied starting at commit e8f3fcc83db88e6cf69f777ba10f24b7e93ca5e2.

