FROM jantoine/drupal:6

# Install Xdebug.
RUN pecl install xdebug-2.2.7 \
  && echo "zend_extension=/usr/lib/php5/20090626/xdebug.so" > /etc/php5/conf.d/xdebug.ini \
  && echo "xdebug.max_nesting_level=200" >> /etc/php5/conf.d/xdebug.ini \
  && echo "xdebug.remote_enable=1" >> /etc/php5/conf.d/xdebug.ini \
  && echo "xdebug.remote_autostart=0" >> /etc/php5/conf.d/xdebug.ini \
  && echo "xdebug.remote_connect_back=1" >> /etc/php5/conf.d/xdebug.ini \
  && echo "xdebug.remote_port=9000" >> /etc/php5/conf.d/xdebug.ini

COPY conf/php5/apache2/php.ini /etc/php5/apache2/

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
