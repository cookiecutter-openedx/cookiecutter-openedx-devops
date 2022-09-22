#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       sep-2022
#
# usage:      enables arb64 helpers for tutor installs to M1 arm64-base architectures
#--------------------------------------------------------

git clone https://github.com/open-craft/tutor-contrib-arm64.git
tutor plugins enable arm64
tutor config save --set DOCKER_IMAGE_MYSQL=mariadb:10.4
