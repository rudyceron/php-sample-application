# syntax=docker/dockerfile:1


################################################################################

# Create a stage for installing app dependencies defined in Composer.
FROM composer:lts as deps

WORKDIR /app

RUN --mount=type=bind,source=composer.json,target=composer.json \
    --mount=type=bind,source=composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-interaction

################################################################################

FROM php:7.1-apache as final

# Use the default production configuration for PHP runtime arguments, see
# https://github.com/docker-library/docs/tree/master/php#configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy the app dependencies from the previous install stage.
COPY --from=deps app/vendor/ /var/www/html/vendor
# Copy the app files from the app directory.
COPY . /var/www/html

# Enable mod_rewrite de Apache
RUN a2enmod rewrite

# Configure Server Apache - ServerName, relative dir and permissions
RUN echo "ServerName phpapp" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername && \
    sed -i 's|/var/www/html|/var/www/html/web|g' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf && \
    sed -i '/<\/VirtualHost>/i\\tphp_admin_value include_path "/var/www/html/"' /etc/apache2/sites-available/000-default.conf && \
    sed -i '/<\/VirtualHost>/i\\tInclude /var/www/html/config-dev/vhost.conf' /etc/apache2/sites-available/000-default.conf

# Installing mysqli
RUN docker-php-ext-install mysqli pdo pdo_mysql

#ch user
USER www-data
