===================
Windows SDK Builder
===================

Requirements
------------

Building this SDK requires an MSYS2_ environment. Please run all commands in
the MSYS2 MinGW (32/64)bit command prompt. Also, both your application and this
SDK should be located inside MSYS2 native home directory, instead of MSYS2
mapping to Windows directory, i.e. they should be in ~, instead of /c/.

.. _MSYS2: http://www.msys2.org/

SDK Environment
---------------

The SDK relies on MSYS2 pacman package manager to fetch and install binary
dependencies. By default, it installs GTK3, GStreamer (with plugins) and NSIS
to do this, you can specify more dependencies by changing your `Target project
configuration`_

In order to set up the SDK, you should run build_win32_sdk.sh from within your
target project directory::

  cd myapp/installer
  /path/to/sdk/win_installer/build_win32_sdk.sh

Afterwards, all the dependencies will be included in the _build_root directory.
This includes a completely separate pacman root from your MSYS2 environment,
which means that the SDK will *not* disturb your environment at all.

In order to clean up the SDK::

  cd myapp/installer
  /path/to/sdk/win_installer/clean_win32.sh


Target project configuration
----------------------------

You must define a project.config and place it in your target directory. An
example project.config is as follows::

  # The binary dependencies for your application that should be installed by pacman
  TARGET_DOWNLOAD_PKGS="make git tar"

Optional files:

* requirements.txt

A `requirements.txt` file contains python dependencies to download + install.
If you require a wheel or some other package that cannot be downloaded using
pip, install it with pacman instead.

Target project build script
---------------------------

After the SDK has been set up, and you have defined your project configuration,
you can use build_win32_installer.sh in order to create an installer.You must define a _build.sh in your project directory, which will be called by
build_win32_installer.sh once all the dependencies have been installed.

For convenience, NSIS has been installed in the SDK environment.

Some useful utility functions available in your _build.sh:

* `package_installer`: Package your application using NSIS. Arg 1: your NSI file.

* `build_python`: Run your python script using the SDK bundled python.

* `build_pip`: Run pip using the SDK bundled pip.

* `build_pacman`: Run pacman using the SDK build root.

Bundling your application
-------------------------

There are a lot of different ways to create a 'frozen' version of your
application, but we highly recommend using pyinstaller. You can run it
like this in your _build.sh file::

  build_python -m pyinstaller -w myapp.py

pyinstaller has the necessary hooks to detect GTK/GST dependencies and
properly package them inside your application.

Troubleshooting
---------------

The bash scripts aren't always as robust as one would like, so if you need to
figure out what's going wrong, you can make the scripts more verbose by
setting the GTK_SDK_VERBOSE environment variable, for example::

  GTK_SDK_VERBOSE=1 ./build_win32_sdk.sh

Known bugs
----------

On OSX, the git for windows installer runs rebase.exe and it crashes. But,
just ignore it and it's probably ok too.
