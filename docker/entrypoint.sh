#!/bin/bash
set -e

cd /var/www

# Agar vendor bo'sh bo'lsa composer install
if [ ! -d "vendor" ] || [ -z "$(ls -A vendor)" ]; then
    echo "Installing composer dependencies..."
    composer install --no-interaction --prefer-dist
fi

# Storage va bootstrap/cache ruxsatlari
chmod -R 777 storage bootstrap/cache

# .env yaratish agar yo'q bo'lsa
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate
fi

# PHP-FPM ishga tushadi (CMD orqali)
exec "$@"
