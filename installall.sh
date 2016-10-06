#!/bin/bash

##########################################
# command line arguments (optional):
# -ssh    use SSH instead of HTTPS for
#         git cloning
#
GIT_CLONE_PREFIX="https://github.com/"
while [[ $# -gt 1 ]]
do
    key="$1"
    case $key in
        -ssh)
            printf "Using SSH for git cloning\n"
            GIT_CLONE_PREFIX="git@github.com:"
            shift # past argument
        ;;
        *) 
            # unknown option
        ;;
    esac
    shift # past argument or value
done

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
git clone --branch v1.10.1 ${GIT_CLONE_PREFIX}PROSPECT-collaboration/PROSPECT-G4.git
git clone --branch v3.2.1 ${GIT_CLONE_PREFIX}mpmendenhall/MPMUtils.git
git clone --branch v3.3.0 ${GIT_CLONE_PREFIX}PROSPECT-collaboration/PROSPECT2x_Analysis.git
git clone --branch v2r2 ${GIT_CLONE_PREFIX}PROSPECT-collaboration/OscSens_CovMatrix.git

################
# build packages

printf "\n-------------------------\nBuilding PROSPECT-G4\n"
export PG4_CODE=${INSTALL_DIR}/PROSPECT-G4/
export PG4_BUILD=${INSTALL_DIR}/PG4_build/
mkdir $PG4_BUILD; cd $PG4_BUILD
cmake ${PG4_CODE} -DWITH_HDF5=ON
make -j`nproc`

printf "\n--------------------------\nBuilding MPMUtils dependency\n"
export MPMUTILS=${INSTALL_DIR}/MPMUtils/
cd $MPMUTILS
make rootutils -j`nproc`

printf "\n--------------------------\nBuilding MPM Analysis\n"
export P2X_ANALYSIS_CODE=$INSTALL_DIR/PROSPECT2x_Analysis/cpp/
cd $P2X_ANALYSIS_CODE/Analysis
make -j`nproc`
printf "\n--------------------------\nBuilding h5 -> root converters\n"
cd ../Examples/
make converters -j`nproc`
printf "\n--------------------------\nBuilding PulseCruncher\n"
cd ../../PulseCruncher
make -j`nproc`

printf "\n--------------------------\nBuilding OscSens_CovMatrix Package\n"
export OSCSENS_COVMATRIX_PACKAGE=$INSTALL_DIR/OscSens_CovMatrix/
cd $OSCSENS_COVMATRIX_PACKAGE/OscSensFitterCC/
make 
printf "\n--------------------------\nBuilding Executable 'estimateSensitivity'\n"
make estimateSensitivity


cd $INSTALL_DIR
printf "\n\n---- Bundle Install Complete! ------\n\n"

