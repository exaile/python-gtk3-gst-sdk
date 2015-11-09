===================
Windows SDK Builder
===================

Requirements:

* 7zip
* wine (tested with 1.7.53)
* wget
* git
* 1.5GB free space

SDK Environment
---------------

After running build_sdk.sh, ./_sdk contains a development environment
including all dependencies and the needed launchers.


Target project configuration
----------------------------

You must define a project.config and place it in your target directory. An
example project.config is as follows:

  # If you don't require files/hashes
  #DOWNLOAD_FILES_NOT_SET=1
  #DOWNLOAD_HASHES_NOT_SET=1
  
  # Defines files to download from the web
  DOWNLOAD_FILES=$(cat <<EOF
  http://example.com/example.zip
  EOF
  )

  # Defines sha256sum of files downloaded 
  # Note that the last line must end in a \
  DOWNLOAD_HASHES="\
  0aa011707785fe30935d8655380052a20ba8b972aa738d4f144c457b35b4d699  mutagen-1.31.tar.gz\
  "
  
  # URL to clone your repository from
  GIT_CLONE_URL="https://github.com/my/project.git"

Optional files:

* requirements.txt

A `requirements.txt` file contains python dependencies to download + install.
If you require a wheel or some other package that cannot be downloaded using
the linux version of pip, then prefix the requirement with #bindep and add
the download link to the project download list instead.

* _extract_deps.sh: files are in $TARGET_BIN directory
* _install_deps.sh: files are in $TARGET_BIN

SDK scripts

* Any files in the target/sdk_scripts will be linked to the built SDK directory
  so that you can provide test, build, etc scripts specific to your app
  
Target project build script
---------------------------

For build_installer.sh to work, you must define a _build.sh which will be called
once the installer build environment has been set up.

For convenience, a version of pyinstaller that has the correct hooks for
GTK3/GSTreamer is installed in the wine environment, and NSIS 2.46 has also
been installed.

When _build.sh is executed, the following is available:

* Executing commands via `wine` will execute in the build environment
* `$DEPS` points to the directory that holds the extracted PyGObject files
* `$TARGET` points to the target directory of your application

There are two useful functions available:

* `copy_pygi_data`
  * Arg 1: directory where your frozen exe is
  * Arg 2: directory that contains your translations (*.mo files)
* `package_installer`
  * Arg 1: your NSI file
