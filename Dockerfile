FROM php:7.4-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install only the required packages and clean cache to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html/

# Copy only required files (exclude unnecessary files via .dockerignore)
COPY . .

# Expose port
EXPOSE 80

