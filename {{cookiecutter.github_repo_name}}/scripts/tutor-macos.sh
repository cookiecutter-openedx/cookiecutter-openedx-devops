export TUTOR_ROOT="~/.tutor"
[ ! -d "${TUTOR_ROOT}" ] && mkdir $TUTOR_ROOT

tutor config save --interactive

# resolves a macOS-specific compatibility problem with the
# mysql5.7 container.
tutor config save --set DOCKER_IMAGE_MYSQL=mariadb:10.4

# Open Craft plugin that helps with arm64 computers
pip install git+https://github.com/open-craft/tutor-contrib-arm64
tutor plugins enable arm64

tutor images build openedx permissions
tutor dev dc build lms
tutor dev start -d
tutor dev init
tutor dev quickstart
