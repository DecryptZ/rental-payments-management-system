# Use the official PHP image with Apache
FROM php:8.1-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy the composer.json and composer.lock to install PHP dependencies
COPY composer.json composer.lock ./

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the application code
COPY . .

# Install Node.js and NPM dependencies for the front-end (if applicable)
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install

# Set up Apache document root to the public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Expose port 80
EXPOSE 80

# Run Laravel migrations (optional, you can also do this manually after deployment)
# RUN php artisan migrate --force

# Start Apache server
CMD ["apache2-foreground"]
