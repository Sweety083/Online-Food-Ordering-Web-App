# Use official PHP 7.4 with Apache image
FROM php:7.4-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy application source code to container
COPY . /var/www/html/

# Install MySQL client
RUN apt-get update && \
    apt-get install -y default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Expose port 80 for web
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
