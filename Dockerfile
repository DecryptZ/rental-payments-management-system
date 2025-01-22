# Use the official PHP Apache image as a base
FROM php:8.1-apache

# Install necessary PHP extensions and utilities
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev git unzip curl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy the Laravel app files to the container
COPY . /var/www/html

# Copy the environment file
COPY .env /var/www/html/.env

# Install Laravel dependencies using Composer
RUN composer install --no-dev --optimize-autoloader

# Set Laravel application key
RUN php artisan key:generate

# Set permissions for Laravel storage and cache and public directory
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage && \
    chmod -R 775 /var/www/html/bootstrap/cache && \
    chmod -R 755 /var/www/html/public && \
    chown -R www-data:www-data /var/www/html/public

# Clear and cache Laravel configuration and routes
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear && \
    php artisan config:cache && \
    php artisan route:cache

# Enable Apache mod_rewrite for Laravel's routing
RUN a2enmod rewrite

# Set a ServerName to avoid warnings
RUN echo "ServerName rental-payments-management-system.onrender.com" >> /etc/apache2/apache2.conf

# Configure Apache to set DocumentRoot to /public
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerName rental-payments-management-system.onrender.com' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html/public' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Enable the site
RUN a2ensite 000-default.conf

# Expose port 80
EXPOSE 80

# Start the Apache service in the foreground
CMD ["apache2-foreground"]
