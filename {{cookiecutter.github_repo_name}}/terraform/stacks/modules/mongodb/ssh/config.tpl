
Host *
  IdentitiesOnly yes

Host mongodb
 Hostname      ${host}
 User          ${user}
 IdentityFile  ~/.ssh/${private_key_filename}
