# Use the official PHP Apache image as a base
FROM php:8.1-apache

# Install necessary PHP extensions and utilities
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev git unzip && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy the Laravel app files to the container
COPY . /var/www/html

# Set permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage && \
    chmod -R 775 /var/www/html/bootstrap/cache

# Enable Apache mod_rewrite for Laravel's routing
RUN a2enmod rewrite

# Set a ServerName to avoid the warning
RUN echo "ServerName rental-payments-management-system.onrender.com" >> /etc/apache2/apache2.conf

# Configure Apache to handle Laravel's public directory and assets
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html/public' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    Alias /css /var/www/html/public/css' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public/css>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    Alias /js /var/www/html/public/js' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public/js>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf

# Enable the site and restart Apache to apply changes
RUN a2ensite 000-default.conf && service apache2 restart

# Expose port 80 for the Apache web server
EXPOSE 80

# Start the Apache service in the foreground
CMD ["apache2-foreground"]
