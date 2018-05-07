#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# If required environment variables are not set.
if [[ -z "$HOST_USER" || -z "$HOST_UID" ]]; then
  if [[ -z "$HOST_USER" ]]; then
    echo "Need to set the HOST_USER environment variable"
  fi

  if [[ -z "$HOST_UID" ]]; then
    echo "Need to set the HOST_UID environment variable"
  fi

  exit 1
fi

# If the user has not already been created.
if [[ ! $(id -u $HOST_USER) =~ ^-?[0-9]+$ ]]; then
  # If a folder for the user already exists, i.e. a host folder was bind mounted
  # inside the user folder, manually copy files from the /etc/skel directory.
  if [[ -d /home/$HOST_USER ]]; then
    # Copy files from the /etc/skel directory into the user's home directory.
    cp -a /etc/skel/. /home/$HOST_USER/
  fi

  # Create the user.
  adduser --disabled-password --gecos GECOS --uid $HOST_UID $HOST_USER

  # Ensure the users home directory is owned by them.
  chown -R $HOST_USER:$HOST_USER /home/$HOST_USER

  # Add the user to the sudo group.
  usermod -aG sudo $HOST_USER

  # Allow the user to use sudo to run all commands without a password.
  echo $HOST_USER' ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$HOST_USER

  # Add the user to the rvm group.
  usermod -aG rvm $HOST_USER
fi

# If a remote file server has been specified.
if [[ ! -z "$REMOTE_FILE_SERVER" ]]; then
  # If a remote file server has not been set in the default apache conf file.
  if ! grep -q remote-file-server.conf /etc/apache2/sites-available/000-default.conf; then
    # Include the remote file server configuration file.
    sed -i '/<\/VirtualHost>/i \
      \tInclude conf-available/remote-file-server.conf' /etc/apache2/sites-available/000-default.conf
  fi

  # If a remote file server has not been set in the default-ssl apache conf
  # file.
  if ! grep -q remote-file-server.conf /etc/apache2/sites-available/default-ssl.conf; then
    # Include the remote file server configuration file.
    sed -i '/<\/VirtualHost>/i \
      \t\tInclude conf-available/remote-file-server.conf' /etc/apache2/sites-available/default-ssl.conf
  fi
fi

exec "$@"
