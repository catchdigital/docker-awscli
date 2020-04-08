FROM php:7.4-fpm

MAINTAINER Alberto Conteras <a.contreras@catchdigital.com>

# Install dependencies
RUN apt update \
    && apt install -y \
    less \
    groff \
    jq \
    git \
    curl \
    rsync \
    ssh \
    python3 \
    python3-pip \
    zip \
    libzip-dev \
    gnupg2

# Install GD and other dependencies
RUN apt install -y \
        libjpeg-dev \
        libpng-dev \
        libjpeg62-turbo \
        libfreetype6-dev && \
  docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd zip && \
  apt remove -y libfreetype6-dev libpng-dev libfreetype6-dev

# Install aws cli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install aws eb cli
RUN pip3 install --upgrade pip awsebcli

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_HOME '/usr/composer'

# Install node and npm
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt -y install nodejs

# Clean up installations
RUN apt -y autoremove && apt -y clean


# Set directory and working permissions
WORKDIR /var/www
ENV PATH=/var/www/vendor/bin:${PATH}

# Set www-data user
RUN usermod -u 1000 www-data
RUN usermod -g users www-data
RUN chown -R www-data:www-data /var/www
