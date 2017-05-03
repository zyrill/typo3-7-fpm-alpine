FROM php:7.1.4-fpm-alpine
MAINTAINER Dr. Philipp Krüger <p.a.c.krueger@gmail.com>

# Set UID and GID
RUN deluser www-data && addgroup -g 101 www-data && adduser -u 100 -D -s /bin/false -G www-data www-data
# Install TYPO3
RUN apk update && \
	apk upgrade && \
	apk add autoconf freetype freetype-dev file gcc g++ imagemagick libc-dev libjpeg-turbo libjpeg-turbo-dev libpng libpng-dev libxml2-dev make musl-dev openssl wget && \
	rm -rf /var/cache/apk/*
RUN mkdir -p /var/www/html && \
	cd /var/www/html && \
	wget -O - https://get.typo3.org/7 | tar -xzf - && \
	ln -s typo3_src-* typo3_src && \
	ln -s typo3_src/index.php && \
    ln -s typo3_src/typo3 && \
    ln -s typo3_src/_.htaccess .htaccess && \
	mkdir typo3temp && \
    mkdir typo3conf && \
    mkdir fileadmin && \
    mkdir uploads && \
    touch FIRST_INSTALL && \
    chown -R www-data. .
# Configure PHP
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd mysqli opcache soap zip
RUN { \
		echo 'always_populate_raw_post_data=-1'; \
		echo 'max_execution_time=240'; \
		echo 'max_input_vars=1500'; \
		echo 'upload_max_filesize=32M'; \
		echo 'post_max_size=32M'; \
	} > /usr/local/etc/php/conf.d/typo3.ini

# set recommended PHP.ini settings # see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN mkdir -p /tmp/pear/download/ && \
	cd /tmp/pear/download/ && \
	wget -O apcu.tgz https://pecl.php.net/get/APCu && \
	echo "" | pear install apcu.tgz && \
	wget -O redis.tgz https://pecl.php.net/get/redis && \
	pear install redis.tgz && \
	docker-php-ext-enable apcu redis

# Clean up
RUN apk del autoconf file gcc g++ imagemagick libc-dev libxml2-dev make musl-dev wget

# Configure volumes
VOLUME /var/www/html/
