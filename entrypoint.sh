#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# If required environment variables are not set.
if [[ -z "$USER" || -z "$UID" ]]; then
  if [[ -z "$USER" ]]; then
    echo "Need to set USER"
  fi

  if [[ -z "$UID" ]]; then
    echo "Need to set UID"
  fi

  exit 1
fi

# If the user has not already been created.
if [[ ! $(id -u $USER) =~ ^-?[0-9]+$ ]]; then
  # Create the user.
  adduser --group --system --uid $UID $USER

  # Add the www-data user to the $USER group.
  usermod -a -G $USER www-data
fi

# If a remote file server has been specified.
if [[ ! -z "$REMOTE_FILE_SERVER" ]]; then
  # If a remote file server has not been set in the default apache conf file.
  if ! grep -q remote-file-server.conf /etc/apache2/sites-available/default; then
    # Include the remote file server configuration file.
    sed -i '/<\/VirtualHost>/i \
      "    Include sites-configuration/remote-file-server.conf"' /etc/apache2/sites-available/default
  fi

  # If a remote file server has not been set in the default-ssl apache conf
  # file.
  if ! grep -q remote-file-server.conf /etc/apache2/sites-available/default-ssl; then
    # Include the remote file server configuration file.
    sed -i '/<\/VirtualHost>/i \
      "        Include sites-configuration/remote-file-server.conf"' /etc/apache2/sites-available/default-ssl
  fi
fi

exec "$@"
