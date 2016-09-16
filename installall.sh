#!/bin/bash

# check required environment variables
# base "applications" directory; packes will be installed in subdirectory of this
: "${APP_DIR:?Need to set APP_DIR for install location base}"
# HDF5
: "${HDF5_INSTALL:?Need to set HDF5_INSTALL directory to your cmake-based HDF5 install}"
export HDF5_DIR=${HDF5_INSTALL}/share/cmake/
# ROOT
: "${ROOTSYS:?ROOTSYS not set... ROOT not installed and configured?}"


# determine version tag from git repository containing this script
VERSION_TAG="$(git describe --tags)"
: "${VERSION_TAG:?Failed to determine install script git version tag}"
INSTALL_DIR=${APP_DIR}/PROSPECT-Bundle-${VERSION_TAG}

# create installation directory (ensuring it does not already exist)
if [ -d "$INSTALL_DIR" ]; then
  echo "Install directory '${INSTALL_DIR}' already exisits; remove if you really want to proceed!"
  exit 1
fi
echo "Installing componenents in '${INSTALL_DIR}'"
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# clone correct repository versions --- update tags here!
echo "Dowloading code repositories"
git clone --branch v1.8 https://github.com/PROSPECT-collaboration/PROSPECT-G4.git
git clone --branch v3.2.1 https://github.com/mpmendenhall/MPMUtils.git
git clone --branch v3.2.0 https://github.com/PROSPECT-collaboration/PROSPECT2x_Analysis.git
git clone --branch v1r0 https://github.com/PROSPECT-collaboration/OscSens_CovMatrix.git

################
# build packages

echo "Building PROSPECT-G4"
export PG4_CODE=${INSTALL_DIR}/PROSPECT-G4/
export PG4_BUILD=${INSTALL_DIR}/PG4_build/
mkdir $PG4_BUILD; cd $PG4_BUILD
cmake ${PG4_CODE} -DWITH_HDF5=ON
make -j`nproc`

echo "Building MPMUtils dependency"
export MPMUTILS=${INSTALL_DIR}/MPMUtils/
cd $MPMUTILS
make rootutils -j`nproc`

echo "Building MPM Analysis"
export MPM_P2X_ANALYSIS=$INSTALL_DIR/PROSPECT2x_Analysis/cpp/
cd $MPM_P2X_ANALYSIS/Analysis
make -j`nproc`
echo "Building PulseCruncher"
cd ../../PulseCruncher
make -j`nproc`

cd $INSTALL_DIR


