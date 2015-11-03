===========
Windows SDK
===========

Requirements:

* 7zip
* wine (tested with 1.6.1)
* wget
* git
* 1.5GB free space

How To
------

* Run "build_installer.sh $VERSION"
* _bin will be created which contains installers of various dependencies
* _build_env will be created which contains all files created during the
  build process.
* After the build is finished, quodlibet-$VERSION-installer.exe and
  quodlibet-$VERSION-portable.exe will be placed in this directory.


SDK Environment
---------------

After running build_sdk.sh, ./_sdk contains a development environment
including all dependencies and the needed launchers.


Target stuff
------------

Required files:

* deps.txt: line-delimited file of binary dependencies to download
* requirements.txt: pip file of python dependencies to download + install
* hashes.txt: sha256sum checksums of files

Optional files:

* install_deps.sh: files are in $TARGET_BIN

SDK scripts

* Any files in the target/sdk_scripts will be linked to the built SDK directory
  so that you can provide test, build, etc scripts specific to your app
