FROM jantoine/drupal:7

# Configure PHP for development.
RUN echo "max_execution_time = 0" >> /usr/local/etc/php/php.ini \
  && echo "max_input_vars = 2000" >> /usr/local/etc/php/php.ini \
  && echo "memory_limit = -1" >> /usr/local/etc/php/php.ini

# Install Xdebug.
RUN pecl install xdebug \
  && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/ext-xdebug.ini \
  && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/ext-xdebug.ini \
  && echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/ext-xdebug.ini \
  && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/ext-xdebug.ini \
  && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/ext-xdebug.ini

# Copy the remote file server site include configuration file.
COPY conf/apache2/conf-available/remote-file-server.conf /etc/apache2/conf-available/

# Overwrite the base images entrypoint.sh file.
COPY entrypoint.sh /

CMD ["apache2-foreground"]
