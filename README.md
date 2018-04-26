# How to use this image

This image builds off of the [`jantoine/drupal`](https://hub.docker.com/r/jantoine/drupal/) image adding the following development configuration and tools:

* Installs Composer
* Installs GIT
  This is required by composer projects using dev releases or applying patches.
* Sets the following PHP config variables:
  * 'max_execution_time=0' (unlimited)
  * 'memory_limit=-1' (unlimited)
  * 'post_max_size=0' (unlimited)
  * 'upload_max_filesize=0' (unlimited)
* Installs the latest stable release of Xdebug and configures for remote debugging.
* Installs drupal/coder via Composer.
* Installs Node.js v8.x.
* Installs RVM, the latest stable release of Ruby supported by RVM and bundler.
* Provides USER and UID variables for creating a user within the container that matches a user on the host to eliminate file ownership issues between the container and the host.
  ```
  -e USER="user" -e UID="1000"
  ```
* Provides a REMOTE_FILE_SERVER variable for defining a remote server to fetch files from if they're not found locally.
  ```
  -e REMOTE_FILE_SERVER="example.com"
  ```
