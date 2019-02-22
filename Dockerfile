FROM php:7.2-fpm-alpine

MAINTAINER Alberto Conteras <a.contreras@catchdigital.com>

# Install dependencies
RUN apk update \
    && apk --no-cache add \
    bash \
    less \
    groff \
    jq \
    git \
    curl \
    python3 \
    py-pip \
    openssh-client \
    shadow \
    patch \
    zip \
    zlib-dev

# Install GD and other dependencies
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd zip && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN pip3 install --upgrade pip \
    awsebcli \
    awscli

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_HOME '/usr/composer'

# Install node
RUN apk --no-cache add nodejs nodejs-npm

# Set directory and working permissions
WORKDIR /var/www

# Set www-data user
RUN usermod -u 1000 www-data
RUN usermod -g users www-data
RUN chown -R www-data:www-data /var/www
