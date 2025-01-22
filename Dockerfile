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

# Set permissions for Laravel storage and cache and public directory
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage && \
    chmod -R 775 /var/www/html/bootstrap/cache && \
    chmod -R 755 /var/www/html/public && \
    chown -R www-data:www-data /var/www/html/public

# Enable Apache mod_rewrite for Laravel's routing
RUN a2enmod rewrite

# Set a ServerName to avoid warnings
RUN echo "ServerName rental-payments-management-system.onrender.com" >> /etc/apache2/apache2.conf

# Configure Apache to use port 80 and set DocumentRoot to /public
RUN echo 'Listen 80' >> /etc/apache2/ports.conf && \
    echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
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

# Expose the dynamic port provided by Render
EXPOSE 80

# Restart Apache to apply changes
RUN apache2ctl restart

# Start the Apache service in the foreground
CMD ["apache2-foreground"]
