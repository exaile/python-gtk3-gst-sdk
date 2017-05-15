Python + GTK3 + GStreamer SDK
=============================

The goal of this SDK is to make it easier to package python applications that
use GTK3+GStreamer. This environment is particularly targeted towards creating
your application packages with pyinstaller, as it works consistently across
OSX and Windows.

* To build applications for OSX, see the osx_bundle directory
* To build applications for Windows, see the win_installer directory
* To build applications for Linux, this SDK isn't really necessary

Usage
-----

This SDK is designed to be used alongside your application. You set up a
directory with the correct configuration files, then you can run the SDK
from that directory. If you're packaging for OS X, you can run `create_links.sh`
to create symlinks in your application directory for easier bootstrapping:

```
  cd my_app/installer
  /path/to/sdk/create_links.sh osx
```

If you're packing for Windows, you need to have [MSYS2](http://www.msys2.org/)
set up and running. Unfortunately, MSYS2 doesn't create symlinks by default,
so `create_links.sh` won't help you here. See the `win_installer` directory
for more information.

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
