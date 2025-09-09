FROM dunglas/frankenphp:latest-php8.2

# Install latest security patches
RUN echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" > /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y

ENV SERVER_NAME=":80"
# ENV CADDY_GLOBAL_OPTIONS="debug"

# add additional extensions here:
ENV PHP_EXTENSTIONS="mysqli intl pcntl gd pdo_mysql bcmath opcache exif zip redis imagick"
RUN install-php-extensions $PHP_EXTENSTIONS

COPY ./image /bd_build

RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh

ENV DEBIAN_FRONTEND="teletype"

CMD ["/sbin/my_init"]