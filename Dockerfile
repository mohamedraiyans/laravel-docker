# Dockerfile
FROM php:8.2-apache

# Install required packages and PHP extensions
RUN apt-get update && \
    apt-get install -y libzip-dev zip unzip git curl && \
    docker-php-ext-install pdo_mysql zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set Apache document root to Laravel public folder
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Run composer install **only if vendor folder is missing**, then start Apache
CMD bash -c "if [ ! -d vendor ]; then composer install --no-interaction --optimize-autoloader; fi && apache2-foreground"

# Expose port 80
EXPOSE 80