# How to use this image

This image builds off of the [`jantoine/drupal`](https://hub.docker.com/r/jantoine/drupal/) image adding the following development configuration and tools:

* Sets PHP's max_execution_time to 0 (unlimited)
* Sets PHP's max_input_vars to 2000\
  This is required for dealing with really large features.
* Sets PHP's memory_limit to -1 (unlimited)
* Installs the latest stable release of Xdebug and configures for remote debugging.
* Provides USER and UID variables for creating a user within the container that matches a user on the host to eliminate file ownership issues between the container and the host.
  ```
  -e USER="user" -e UID="1000"
  ```
* Provides a REMOTE_FILE_SERVER variable for defining a remote server to fetch files from if they're not found locally.
  ```
  -e REMOTE_FILE_SERVER="example.com"
  ```
