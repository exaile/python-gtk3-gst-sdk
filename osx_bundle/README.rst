=========================
OS X Bundle Build Scripts
=========================

Uses jhbuild [3] and the stable module set provided by gtk-osx [2] with a
customized specific module set overlay to build all needed dependencies for
an application that uses GTK/GStreamer and Python on OSX. Everything will
be downloaded/installed into this directory and your user directory will
not be touched.


Creating a development environment
----------------------------------

Prerequisites: `OS X` 10.7+ and a working `Xcode` [0] and `git` [1]

Verify that Xcode and git is installed and in your ``$PATH`` by invoking ``git
--version`` and ``gcc --version``. Also make sure that other pacakge managers
like homebrew or macports aren't in your ``$PATH``.

(Tested on OS X 10.10)

1) Call ``bootstrap_osx.sh`` to install jhbuild and set up dummy ``$HOME`` as base.
2) Call ``build_osx_sdk.sh`` to download and build all the dependencies.
   This should not lead to errors; if it does please file a bug.

Note: XCode 7.x has some compile errors, but XCode 6.x works fine.

Development
-----------

* After ``bootstrap.sh`` has finished executing ``source env.sh`` will put you
  in the build environment. After that jhbuild can be used directly.
* ``fetch_modules()`` downloads the git master of the gtk-osx module set
  and replaces the modules under "modulessets" and the
  ``misc/gtk-osx-jhbuildrc`` file. Doing so so should ideally be followed by a
  review of the sdk module to reduce duplication and a rebuilt to verify
  that everything still works.

Using this as a development environment
---------------------------------------

After you've finished running ``build.sh``, all of the generic requirements for
a GTK/GST python application are installed into the jhbuild environment.

* execute ``source env.sh``, followed by ``jhbuild shell`` to get into the
  jhbuild environment
* You should be able to execute your application from here

Bundling your application
-------------------------

After you've finished running ``build.sh``, all of the generic requirements for
a GTK/GST python application are installed into the jhbuild environment.

* execute ``source env.sh``, followed by ``jhbuild shell`` to get into the
  jhbuild environment
* Use ``python -m pip`` to install any python modules that are required to run
  your application (there's a bug with the normal pip command)
* Install your application

Once your app is installed, then you can use the installed version of
pyinstaller to build the application bundle. Something like::

  pyinstaller -w myprogram.py

The version of pyinstaller included with this SDK build environment has the
correct build/runtime hooks to properly package up a PyGObject application.
However, refer to the pyinstaller documentation for more information on how
to build your application.

TODO: integration with the Windows environment scripts

Content Description
-------------------

* ``modulesets`` contains the gtk-osx stable module set and a
  python-gtk3-gst-sdk module which adds new packages and replaces others.
* ``misc``: see each file or directory README for a description.

Bugs
----

If you get an error similar to "EnvironmentError: MacOSX10.11.sdk not found",
then this means that the SDK corresponding to your OS isn't installed. You can
see the installed SDKs via:

  ls /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
  
In jhbuildrc-custom, in 'setup_sdk(target="10.9", sdk_version="native")',
replace 'native' with the latest SDK that is installed on your system.

I've noticed that sometimes python doesn't link properly the first time it gets
built by jhbuild, and links to the system python instead. If you run into this,
try running::

  source env.sh
  jhbuild build -f python

This has been commonly seen when trying to build itstool. 

| [0] https://developer.apple.com/xcode/downloads/
| [1] https://git-scm.com/download/mac
| [2] https://git.gnome.org/browse/gtk-osx/
| [3] https://git.gnome.org/browse/jhbuild/
