FROM alpine:3.12

LABEL Maintainer="Yoga Hanggara <yohang88@gmail.com>" \
      Description="Lightweight Laravel (Octane) app container with Nginx 1.16 & PHP-FPM 8 based on Alpine Linux."

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# make sure you can use HTTPS
RUN apk --update-cache add ca-certificates && \
    echo "https://dl.bintray.com/php-alpine/v3.12/php-8.0" >> /etc/apk/repositories

# Install packages
RUN apk --update-cache add php8 php8-pcntl php8-posix php8-swoole php8-sockets php8-opcache \
    php8-openssl php8-curl php8-phar php8-session php8-pdo php8-pdo_mysql php8-mysqli php8-mbstring php8-dom \
    curl

# https://github.com/codecasts/php-alpine/issues/21
RUN ln -s /usr/bin/php8 /usr/bin/php

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
COPY --chown=nobody . /var/www/html

# Install composer from the official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Run composer install to install the dependencies
RUN composer install --no-cache --no-dev --prefer-dist --optimize-autoloader --no-interaction --no-progress && \
    composer dump-autoload --optimize

# Expose the port nginx is reachable on
EXPOSE 8000

ENTRYPOINT ["php", "artisan", "octane:start", "--host=0.0.0.0"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8000
