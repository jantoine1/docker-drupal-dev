[![DockerPulls](https://img.shields.io/docker/pulls/jantoine/drupal-dev.svg)](https://registry.hub.docker.com/u/jantoine/drupal-dev/)
[![DockerStars](https://img.shields.io/docker/stars/jantoine/drupal-dev.svg)](https://registry.hub.docker.com/u/jantoine/drupal-dev/)

# What this image contains

This image builds from the [`jantoine/drupal`](https://hub.docker.com/r/jantoine/drupal/) image adding the following development configuration and tools:

* Composer
* GIT
  This is required by composer projects using dev releases or applying patches.
* Disables PHP's opcache extension so code changes take effect immediately.
* Sets the following PHP config variables:
  * 'max_execution_time=0' (unlimited)
  * 'memory_limit=-1' (unlimited)
  * 'post_max_size=0' (unlimited)
  * 'upload_max_filesize=0' (unlimited)
* Xdebug (latest stable release) configured for remote debugging.
* drupal/coder via Composer.
* Node.js v12.x.

# How to use this image

This image provides **required** HOST_UID and HOST_USER environment variables that are used to create a user within the container that is granted sudo access with no password requirement. The intention is that this user would match the current user on the host to avoid file ownership issues that arise when operating as a different user within the container.

This first example creates a container setting the HOST_UID and HOST_USER environment variables and starts an interactive BASH session as the created user. It also sets the APACHE_RUN_USER environment variable from the php:apache image to the same user.

```
docker run -e APACHE_RUN_USER="user" -e HOST_UID="1000" -e HOST_USER="user" -it --rm jantoine/drupal-dev su - user
```

This second example execs into an existing container as the current user.

```
docker exec -it -u="user" [CONTAINER_NAME] bash
```
