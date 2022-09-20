#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       sep-2022
#
# usage:      completely reinitialize your local Tutor environment
#             - removes all Docker containers
#             - deletes all Docker-related drive volumes
#             - uninstalls tutor and any tutor subsystems
#--------------------------------------------------------

# clean up the Docker environment
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker volume prune

# completely uninstall tutor
sudo rm -rf "$(tutor config printroot)"
pip uninstall tutor-openedx
sudo rm "$(which tutor)"
pip uninstall tutor -y
pip uninstall tutor-xqueue -y
pip uninstall tutor-webui -y
pip uninstall tutor-richie -y
pip uninstall tutor-notes -y
pip uninstall tutor-minio -y
pip uninstall tutor-mfe -y
pip uninstall tutor-license -y
pip uninstall tutor-forum -y
pip uninstall tutor-ecommerce -y
pip uninstall tutor-discovery -y
pip uninstall tutor-android -y

# reinstall tutor latest stable
pip install "tutor[full]"
