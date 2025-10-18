# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# Copy the application files into the container
COPY . /var/www/html/

# Set the working directory
WORKDIR /var/www/html/

# Install MySQL client to interact with the database
RUN apt-get update && apt-get install -y default-mysql-client

# Expose port 80
EXPOSE 80
