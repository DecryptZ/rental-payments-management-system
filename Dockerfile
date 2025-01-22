# Use the official PHP Apache image as a base
FROM php:8.1-apache

# Install necessary PHP extensions and utilities
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev git unzip curl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Use env.example as .env
RUN cp /var/www/html/.env.example /var/www/html/.env

# Set permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage && \
    chmod -R 775 /var/www/html/bootstrap/cache

# Install Laravel dependencies using Composer
RUN composer install --optimize-autoloader --no-dev

# Generate the application key
RUN php artisan key:generate

# Enable Apache mod_rewrite for Laravel's routing
RUN a2enmod rewrite

# Configure Apache
RUN echo "ServerName rental-payments-management-system.onrender.com" >> /etc/apache2/apache2.conf && \
    echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html/public' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf && \
    a2ensite 000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
