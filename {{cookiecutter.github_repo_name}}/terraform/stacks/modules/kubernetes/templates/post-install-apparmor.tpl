# install apparmor
sudo apt update -y
sudo apt install -y apparmor
sudo systemctl enable apparmor
sudo systemctl start apparmor
cat > /etc/apparmor.d/docker-edx-sandbox <<EOF
${docker_edx_sandbox}
EOF
sudo apparmor_parser -r /etc/apparmor.d/docker-edx-sandbox
sudo apparmor_parser -r -W /etc/apparmor.d/docker-edx-sandbox
