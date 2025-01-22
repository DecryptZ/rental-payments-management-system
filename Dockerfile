# Use the official PHP image with Apache
FROM php:8.0-apache

# Install necessary PHP extensions and dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip git unzip \
    curl gnupg2 lsb-release ca-certificates \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql \
    && a2enmod rewrite

# Install Node.js and npm (for npm install)
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the application files into the container
COPY . /var/www/html

# Set the proper file permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod 644 /var/www/html/app/Helpers/responder.php

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP dependencies using Composer
RUN composer install --no-dev --optimize-autoloader

# Install NPM dependencies (now that npm is available)
RUN npm install

# Clear Laravel configuration and cache
RUN php artisan config:clear && php artisan cache:clear

# Expose the port Apache is listening on
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
