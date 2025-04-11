# Use official PHP image with Apache
FROM php:8.2-apache

# Set an argument for the Omeka S version to install
ARG OMEKA_VERSION=4.1.1

# Install required PHP extensions and dependencies
RUN apt-get update && apt-get install -y \
    bc \
    git \
    ffmpeg \
    icu-devtools \
    imagemagick \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng-dev \
    mariadb-client \
    pdftk \
    unzip \
    vim \
    zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql intl iconv \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Download and extract Omeka S, then move its contents directly into /var/www/html
RUN curl -L -o omeka-s.zip https://github.com/omeka/omeka-s/releases/download/v${OMEKA_VERSION}/omeka-s-${OMEKA_VERSION}.zip \
    && unzip omeka-s.zip \
    && rm omeka-s.zip \
    && mv omeka-s/* omeka-s/.* ./ || true \
    && rm -rf omeka-s

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependencies via Composer
RUN composer install --no-dev --prefer-dist

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 775 /var/www/html

# Expose Apache port
EXPOSE 80

# Start Apache
CMD ["entrypoint.sh"]
