Python + GTK3 + GStreamer SDK
=============================

The goal of this SDK is to make it easier to package python applications that
use GTK3+GStreamer. This environment is particularly targeted towards creating
your application packages with pyinstaller, as it works consistently across
OSX and Windows.

* To build applications for OSX, see the osx_bundle directory
* To build applications for Windows, see the win_bundle directory
* To build applications for Linux, this SDK isn't really necessary

Usage
-----

This SDK is designed to be used alongside your application. You set up a
directory with the correct configuration files, and then run `create_links.sh`
to create symlinks in your application directory. Then you can run the 
SDK commands from there.

If the target application is already set up to use this SDK, you can create
convenience symlinks by running the `create_links.sh` script.

  cd my_app/installer
  /path/to/sdk/create_links.sh windows

  cd my_app/installer
  /path/to/sdk/create_links.sh osx

Contributing
============

This SDK is still a work in progress, please feel free to fix some bugs or
update documentation -- and issue a pull request!

Authors
=======

This repository + SDK is a fork of the work done by the
[Quod Libet](https://github.com/quodlibet/quodlibet) project. The original
code was copied starting at commit e8f3fcc83db88e6cf69f777ba10f24b7e93ca5e2.

License
=======

The scripts in this SDK are covered under the GNU Public License, but packages
that are installed have their own licenses. If you create an application using
this SDK, the resulting application can have whatever license you wish (subject
to the terms of any software that you may link to).
