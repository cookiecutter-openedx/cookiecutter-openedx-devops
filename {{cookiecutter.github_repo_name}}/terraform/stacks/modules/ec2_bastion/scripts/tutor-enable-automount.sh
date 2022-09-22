#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       sep-2022
#
# usage:      plugin to auto-mount locally-created openedx Python virtual environment
#
# see:        https://discuss.openedx.org/t/a-tiny-tutor-plugin-for-auto-mouting-virtual-environments-from-the-host/7658
#--------------------------------------------------------

echo "Note: adding tutor plugin 'automountvenvs' (https://github.com/kdmccormick/tutor-contrib-kdmccormick)"
echo "      This plugin mounts your locally-created openedx Python venv to your local openedx container"
echo "      Using this configuration you are able to make real-time modifications to the pip packages installed"
echo "      in /openedx/venv/ without needing to rebuild your openedx container, which would otherwise"
echo "      take around 40 minutes."
echo ""

pip install git+https://github.com/kdmccormick/tutor-contrib-kdmccormick
tutor plugins enable automountvenvs
tutor config save

echo "automountvenvs example usage:""
echo "tutor dev start -d -m edx-platform -m venv-openedx -m course-discovery -m venv-discovery"
echo "tutor local start -d -m edx-platform -m venv-openedx"
echo ""
