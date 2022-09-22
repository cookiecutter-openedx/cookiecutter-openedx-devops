#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       sep-2022
#
# usage:      builds a local development environment
#             on Ubuntu or macOS M1 using tutor.
#
# see:        https://docs.tutor.overhang.io/tutorials/TUTOR_ARM64.html
#--------------------------------------------------------
TUTOR_ARM64=false
TUTOR_PLATFORM="local"
TUTOR_REQUIREMENTS_PATH=$(tutor config printroot)/env/build/openedx/requirements
TUTOR_THEMES_PATH=$(tutor config printroot)/env/build/openedx/themes

if [[ $PAT -eq "" ]]
then
  echo "WARNING: PAT environment variable not set. You need this in order to clone private github repos."
  echo "Refer to this documentation for creating a Github PAT and how to clone a private repository:"
  echo "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"
else
  echo "using PAT environment variable for Github user: ${PAT_USER}"
fi

# I. Add custom Python packages for openedx
# -----------------------------------------------------------------------------
sudo rm -r ${TUTOR_REQUIREMENTS_PATH}/edx-ora2 && git clone https://${PAT}@github.com/openedx/edx-ora2.git ${TUTOR_REQUIREMENTS_PATH}/edx-ora2
sudo rm -r ${TUTOR_REQUIREMENTS_PATH}/xblock-google-drive && git clone https://${PAT}@github.com/openedx/xblock-google-drive.git ${TUTOR_REQUIREMENTS_PATH}/xblock-google-drive

rm "${TUTOR_REQUIREMENTS_PATH}/private.txt" && touch "${TUTOR_REQUIREMENTS_PATH}/private.txt"
echo "-e ./edx-ora2" >> "$(tutor config printroot)/env/build/openedx/requirements/private.txt"
echo "-e ./xblock-google-drive" >> "$(tutor config printroot)/env/build/openedx/requirements/private.txt"

echo "finished adding custom Python requirements."

# II. Add Custom theme packages for openedx
# -----------------------------------------------------------------------------
sudo rm -r ${TUTOR_THEMES_PATH}/edx-theme-example && git clone https://${PAT}@github.com/lpm0073/edx-theme-example.git ${TUTOR_THEMES_PATH}/edx-theme-example

echo "finished adding custom theme repo."

# III. Add custom tutor plugins
# -----------------------------------------------------------------------------
if [ $TUTOR_ARM64 = true ]; then
./tutor-enable-arm64.sh
fi

# plugin to auto-mount locally-created openedx Python virtual environment
./tutor-enable-automount.sh

echo "finished adding custom tutor plugins."

# IV. configure and build
# see: https://docs.tutor.overhang.io/tutorials/TUTOR_ARM64.html
# -----------------------------------------------------------------------------
echo "beginning tutor build process. (This might take a while)."

tutor config save --interactive
tutor images build openedx permissions

if [ $TUTOR_PLATFORM = "dev" ] ; then
  tutor dev settheme stepwise-edx-theme
  tutor dev dc build lms
  tutor dev quickstart    # or tutor dev start -d
  tutor dev init
else
  tutor local settheme stepwise-edx-theme
  tutor local quickstart
fi
