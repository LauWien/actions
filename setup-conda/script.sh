#!/bin/bash

# Change to the direction containing the action's code
pushd $GITHUB_ACTION_PATH

# Create a temporary directory
mkdir -p conda
BASE=$(realpath conda)

# GAMS source URL fragment, and path fragment for extracted files
if [$INSTALLER] == 'anaconda'; then
  case $RUNNER_OS in
    Linux)
      CACHE_PATH="$GITHUB_ACTION_PATH/conda.sh"
      GAMS_OS=Linux
      FRAGMENT=$VERSION_ANACONDA-${GAMS_OS}-x86_64.sh
      ;;
    macOS)
      CACHE_PATH="$GITHUB_ACTION_PATH/conda.pkg"
      GAMS_OS=MacOSX
      FRAGMENT=$VERSION_ANACONDA-${GAMS_OS}-x86_64.pkg
      ;;
    Windows)
      CACHE_PATH="$GHA_PATH\\conda.exe"
      GAMS_OS=Windows
      FRAGMENT=$VERSION_ANACONDA-${GAMS_OS}-x86_64.exe
      ;;
  esac

if [$INSTALLER] == 'miniconda'; then
  case $RUNNER_OS in
    Linux)
      PATH_ENDING = conda.sh
      CACHE_PATH="$GITHUB_ACTION_PATH/$PATH_ENDING"
      GAMS_OS=Linux
      FRAGMENT=$VERSION_MINICONDA-${GAMS_OS}-x86_64.sh
      ;;
    MacOS)
      PATH_ENDING = conda.pkg
      CACHE_PATH="$GITHUB_ACTION_PATH/$PATH_ENDING"
      GAMS_OS=MacOSX
      FRAGMENT=$VERSION_MINICONDA-${GAMS_OS}-x86_64.pkg
      ;;
    Windows)
      PATH_ENDING = conda.exe
      CACHE_PATH="$GHA_PATH\\$PATH_ENDING"
      GAMS_OS=Windows
      FRAGMENT=$VERSION_MINICONDA-${GAMS_OS}-x86_64.exe
      ;;
  esac

# ToDo adjust the following
# Path fragment for extraction or install
DEST=gams$(echo $GAMS_VERSION | cut -d. -f1-2)_$FRAGMENT


# Retrieve
if [$INSTALLER] == 'Anaconda'; then
  BASE_URL=https://repo.anaconda.com/archive/Anaconda3-
  URL=$BASE_URL/$FRAGMENT

if [$INSTALLER] == 'Miniconda'; then
  BASE_URL=https://repo.anaconda.com/miniconda/Miniconda3-
  URL=$BASE_URL/$FRAGMENT

# curl --time-cond only works if the named file exists
if [ -x $PATH_ENDING ]; then
  # Don't retrieve if the remote file is older than the cached one
  TIME_CONDITION=--remote-time --time-cond $PATH_ENDING
fi

curl --silent $URL


# ToDo adjust the following
if [ $GAMS_OS = "windows" ]; then
  # Write a PowerShell script. Install to the same directory as *nix unzip
  cat << EOF >install-gams.ps1
Start-Process "gams.exe" "/SP-", "/SILENT", "/DIR=$GHA_PATH\\$DEST", "/NORESTART" -Wait
EOF
  cat install-gams.ps1

  # Invoke the script
  pwsh install-gams.ps1
else
  # Extract files
  unzip -q gams.exe
fi

# Return to the last directory
popd
