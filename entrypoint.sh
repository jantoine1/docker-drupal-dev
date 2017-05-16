#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# If the html directory doesn't exist or is empty.
if [[ ! -d html || ! $(ls -A html) ]]; then
  # Build the Drupal project.
  composer create-project drupal-composer/drupal-project:8.x-dev /tmp/drupal -s dev --prefer-dist -n
  rsync -a /tmp/drupal/ /var/www/
  rm -fr /tmp/drupal html
  ln -s web html
fi

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
