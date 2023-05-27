FROM jantoine/drupal:7

# Install Composer.
RUN set -eux; \
  \
  COMPOSER_SIGNATURE=$(curl https://composer.github.io/installer.sig); \
  curl -fSL "https://getcomposer.org/installer" -o composer-setup.php; \
  echo "${COMPOSER_SIGNATURE} composer-setup.php" | sha384sum -c -; \
  php composer-setup.php; \
  rm composer-setup.php; \
  mv composer.phar /usr/local/bin/composer

# Install GIT.
RUN set -eux; \
  \
  apt update; \
  apt install -y --no-install-recommends \
    git \
    openssh-client \
  ; \
  rm -rf /var/lib/apt/lists/*

# Configure PHP for development.
RUN set -eux; \
  \
  # Disable PHP's opcache extension so code changes take effect immediately.
  rm /usr/local/etc/php/conf.d/opcache-recommended.ini; \
  rm /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini; \
  \
  { \
    echo 'max_execution_time=0'; \
    echo 'max_input_vars = 2000'; \
    echo 'memory_limit=-1'; \
    echo 'post_max_size=0'; \
    echo 'upload_max_filesize=0'; \
  } >> /usr/local/etc/php/php.ini

# Install Xdebug.
RUN set -ex; \
  \
  pecl install xdebug; \
  { \
    echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20200930/xdebug.so'; \
    echo 'xdebug.mode=debug'; \
    echo 'xdebug.start_with_request=yes'; \
    echo 'xdebug.discover_client_host=true'; \
    echo 'xdebug.client_port=9000'; \
  } > /usr/local/etc/php/conf.d/ext-xdebug.ini

# Install Coder.
RUN set -eux; \
  \
  export COMPOSER_HOME="/usr/local/composer"; \
  \
  composer global config \
    --no-plugins \
    allow-plugins.dealerdirect/phpcodesniffer-composer-installer true; \
  \
  composer global require drupal/coder; \
  { \
    echo ''; \
    echo '# Include global composer binaries in PATH.'; \
    echo 'export PATH="$PATH:/usr/local/composer/vendor/bin"'; \
  } | tee -a ~/.bashrc /etc/skel/.bashrc; \
  export PATH="$PATH:/usr/local/composer/vendor/bin"; \
  phpcs --config-set installed_paths /usr/local/composer/vendor/drupal/coder/coder_sniffer; \
  { \
    echo ''; \
    echo '# Custom phpcs aliases.'; \
    echo "alias drupalcs=\"phpcs --standard=Drupal --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' --ignore=*\.bean.inc,*\.context.inc,*\.current_search.inc,*\.default_breakpoint_group.inc,*\.default_breakpoints.inc,*\.default_picture_mapping.inc,*\.entityqueue_default.inc,*\.facetapi_defaults.inc,*\.features.commerce_checkout_panes.inc,*\.features.field_base.inc,*\.features.field_instance.inc,*\.features.filter.inc,*\.features.inc,*\.features.media_wysiwyg.inc,*\.features.taxonomy.inc,*\.features.user_permission.inc,*\.features.user_role.inc,*\.features.wysiwyg.inc,*\.field_group.inc,*\.file_default_displays.inc,*\.file_type.inc,*\.flexslider_default_preset.inc,*\.flexslider_picture_optionset.inc,*\.rules_defaults.inc,*\.strongarm.inc,*\.views_default.inc,*/themes/custom/*\.css\""; \
    echo "alias drupalcsp=\"phpcs --standard=DrupalPractice --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' --ignore=*\.bean.inc,*\.context.inc,*\.current_search.inc,*\.default_breakpoint_group.inc,*\.default_breakpoints.inc,*\.default_picture_mapping.inc,*\.entityqueue_default.inc,*\.facetapi_defaults.inc,*\.features.commerce_checkout_panes.inc,*\.features.field_base.inc,*\.features.field_instance.inc,*\.features.filter.inc,*\.features.inc,*\.features.media_wysiwyg.inc,*\.features.taxonomy.inc,*\.features.user_permission.inc,*\.features.user_role.inc,*\.features.wysiwyg.inc,*\.field_group.inc,*\.file_default_displays.inc,*\.file_type.inc,*\.flexslider_default_preset.inc,*\.flexslider_picture_optionset.inc,*\.rules_defaults.inc,*\.strongarm.inc,*\.views_default.inc,*/themes/custom/*\.css\""; \
    echo "alias drupalcbf=\"phpcbf --standard=Drupal --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' --ignore=*\.bean.inc,*\.context.inc,*\.current_search.inc,*\.default_breakpoint_group.inc,*\.default_breakpoints.inc,*\.default_picture_mapping.inc,*\.entityqueue_default.inc,*\.facetapi_defaults.inc,*\.features.commerce_checkout_panes.inc,*\.features.field_base.inc,*\.features.field_instance.inc,*\.features.filter.inc,*\.features.inc,*\.features.media_wysiwyg.inc,*\.features.taxonomy.inc,*\.features.user_permission.inc,*\.features.user_role.inc,*\.features.wysiwyg.inc,*\.field_group.inc,*\.file_default_displays.inc,*\.file_type.inc,*\.flexslider_default_preset.inc,*\.flexslider_picture_optionset.inc,*\.rules_defaults.inc,*\.strongarm.inc,*\.views_default.inc,*/themes/custom/*\.css\""; \
    echo "alias gitcs=\"drupalcs \$(git diff --name-only | tr '\n' ' ')\""; \
    echo "alias gitcsp=\"drupalcsp \$(git diff --name-only | tr '\n' ' ')\""; \
    echo "alias gitcbf=\"drupalcbf \$(git diff --name-only | tr '\n' ' ')\""; \
  } | tee -a ~/.bashrc /etc/skel/.bashrc

# Install Node.js 16.
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt update; \
  apt install -y --no-install-recommends \
    gnupg \
  ;\
  curl -sL https://deb.nodesource.com/setup_16.x | bash -; \
  apt install -y --no-install-recommends \
    nodejs \
  ; \
  # Reset apt-mark's 'manual' list so that 'purge --auto-remove' will remove all
  # build dependencies.
  apt-mark auto '.*' > /dev/null; \
  [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
  apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

# Install sudo.
RUN set -eux; \
  \
  apt update; \
  apt install -y --no-install-recommends \
    sudo \
    unzip \
  ; \
  rm -rf /var/lib/apt/lists/*

# Copy scripts.
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
