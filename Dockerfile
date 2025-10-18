FROM php:8.2-fpm

# PHP kengaytmalari
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Composer o‘rnatish
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

ENTRYPOINT ["/var/www/docker/entrypoint.sh"]

# PHP-FPM ishga tushadi
CMD ["php-fpm"]