=========================
OS X Bundle Build Scripts
=========================

**Note:**
    In case you want just want to run Quod Libet from source you can ignore
    all this and use the released bundle as a development environment.
    Download the official bundle, git clone the quodlibet repo and do
    ``./QuodLibet.app/Contents/MacOS/run quodlibet.py``.


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

1) Call ``bootstrap.sh`` to install jhbuild and set up dummy ``$HOME`` as base.
2) Call ``build.sh`` to download and build all the dependencies.
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

Bundling your application
-------------------------

After you've finished running ``build.sh``, all of the generic requirements for
a GTK/GST python application are installed into the jhbuild environment.

* execute ``source env.sh``, followed by ``jhbuild shell`` to get into the
  jhbuild environment
* Use ``pip`` to install any python modules that are required to run
  your application
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

I've noticed that python doesn't link properly the first time it gets built
by jhbuild, and links to the system python instead. If you run into this,
try running::

  source env.sh
  jhbuild build -f python

This has been commonly seen when trying to build itstool. 

| [0] https://developer.apple.com/xcode/downloads/
| [1] https://git-scm.com/download/mac
| [2] https://git.gnome.org/browse/gtk-osx/
| [3] https://git.gnome.org/browse/jhbuild/
