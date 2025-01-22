# Use the official PHP image with Apache
FROM php:8.0-apache

# Enable Apache mod_rewrite (important for Laravel)
RUN a2enmod rewrite

# Copy your application files into the container
COPY . /var/www/html

# Set the working directory to the public folder
WORKDIR /var/www/html/public

# Update Apache configuration
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Create a custom Apache config to handle Laravel's public directory
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html/public' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
