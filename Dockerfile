FROM jantoine/drupal

# Install Composer.
RUN set -ex; \
  \
  COMPOSER_SIGNATURE=$(curl https://composer.github.io/installer.sig); \
  curl -fSL "https://getcomposer.org/installer" -o composer-setup.php; \
  echo "${COMPOSER_SIGNATURE} composer-setup.php" | sha384sum -c -; \
  php composer-setup.php; \
  rm composer-setup.php; \
  mv composer.phar /usr/local/bin/composer

# Install GIT.
RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    git \
    openssh-client \
  ; \
  rm -rf /var/lib/apt/lists/*

# Configure PHP for development.
RUN set -ex; \
  \
  # Disable PHP's opcache extension so code changes take effect immediately.
  rm /usr/local/etc/php/conf.d/opcache-recommended.ini; \
  rm /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini; \
  \
  { \
    echo 'max_execution_time=0'; \
    echo 'memory_limit=-1'; \
    echo 'post_max_size=0'; \
    echo 'upload_max_filesize=0'; \
  } >> /usr/local/etc/php/php.ini;

# Install Xdebug.
RUN set -ex; \
  \
  pecl install xdebug; \
  { \
    echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so'; \
    echo 'xdebug.remote_enable=1'; \
    echo 'xdebug.remote_autostart=0'; \
    echo 'xdebug.remote_connect_back=1'; \
    echo 'xdebug.remote_port=9000'; \
  } > /usr/local/etc/php/conf.d/ext-xdebug.ini

# Include global composer binaries in PATH.
ENV PATH="$PATH:/usr/local/composer/vendor/bin"

# Install Coder.
RUN set -ex; \
  \
  export COMPOSER_HOME="/usr/local/composer"; \
  composer global require drupal/coder; \
  phpcs --config-set installed_paths /usr/local/composer/vendor/drupal/coder/coder_sniffer; \
  { \
    echo ''; \
    echo '# Custom phpcs aliases.'; \
    echo "alias drupalcs=\"phpcs --standard=Drupal --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' --ignore=node_modules,bower_components,vendor\""; \
    echo "alias drupalcsp=\"phpcs --standard=DrupalPractice --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' --ignore=node_modules,bower_components,vendor\""; \
    echo "alias drupalcbf=\"phpcbf --standard=Drupal --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' --ignore=node_modules,bower_components,vendor\""; \
    echo "alias gitcs=\"drupalcs \$(git diff --name-only | tr '\n' ' ')\""; \
    echo "alias gitcsp=\"drupalcsp \$(git diff --name-only | tr '\n' ' ')\""; \
    echo "alias gitcbf=\"drupalcbf \$(git diff --name-only | tr '\n' ' ')\""; \
  } | tee -a ~/.bashrc /etc/skel/.bashrc

# Install Node.js 15.x.
RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    gnupg \
  ; \
  curl -sL https://deb.nodesource.com/setup_15.x | bash -; \
  apt-get install -y --no-install-recommends \
    nodejs \
  ; \
  rm -rf /var/lib/apt/lists/*

# Include the custom bin folder in PATH.
ENV PATH="${PATH}:/usr/mnt/bin"

# Create a custom bin folder for mounting custom scripts into.
RUN set -ex; \
  \
  mkdir -p /usr/mnt/bin

# Install sudo for the entrypoint.sh script.
RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    sudo \
  ; \
  rm -rf /var/lib/apt/lists/*

# Copy scripts.
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
