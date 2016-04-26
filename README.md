# BundleInstaller
Shell script to download and build version-tagged bundle of PROSPECT analysis codes

This is a start at a proposed installation script for a more "official" PROSPECT analysis codebase installation.
The script configures cloning of a particular set of version-tagged git repositories for analysis, producing a well-defined installation "bundle."
Git versioning of the script itself provides the method to distinctly identify a particlar bundle to be used for analysis.

The installall.sh bash script expects some environment variables to be set to indicate install location and external dependencies:
APP_DIR directory in which PROSPECT-Bundle-[version]/ will be installed
HDF5_INSTALL location of HDF5 install; DocDB 600 includes instructions on setting up HDF5
ROOTSYS indicating your ROOT(6) install, which should be set by running the thisroot.sh setup script that comes with ROOT.

Modify the script at the "git clone --branch XYZ ..." lines to update the code versions downloaded.
Compile instructions (mainly relying on the make system of each package) come below this.
Periodically, we will tag new releases of this repository, when all seems in a good state, for "official" analysis passes.

