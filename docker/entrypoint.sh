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

# # .env yaratish agar yo'q bo'lsa
# if [ ! -f ".env" ]; then
#     cp .env.example .env

#     # Docker Compose dagi MySQL sozlamalarini .env ga yozish
#     sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=mysql/" .env
#     sed -i "s/DB_HOST=.*/DB_HOST=db/" .env
#     sed -i "s/DB_PORT=.*/DB_PORT=3306/" .env
#     sed -i "s/DB_DATABASE=.*/DB_DATABASE=docker_1/" .env
#     sed -i "s/DB_USERNAME=.*/DB_USERNAME=root/" .env
#     sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=1/" .env

#     php artisan key:generate
# fi


if [ ! -f ".env" ]; then
    cp .env.example .env

    # Barcha eski DB qatorlarini olib tashlaymiz
    sed -i '/DB_/d' .env

    # To‘g‘ri DB sozlamalarini yozamiz
    {
      echo "DB_CONNECTION=mysql"
      echo "DB_HOST=db"
      echo "DB_PORT=3306"
      echo "DB_DATABASE=docker_1"   
      echo "DB_USERNAME=root"
      echo "DB_PASSWORD=1"
    } >> .env

    php artisan key:generate
fi

# MySQL tayyor bo'lishini kutish PDO orqali
until php -r "try { new PDO('mysql:host=db;dbname=docker_1','root','1'); exit(0); } catch (\PDOException \$e) { exit(1); }"; do
    echo "Waiting for MySQL..."
    sleep 2
done

# Migration ishga tushurish
php artisan migrate --force


# PHP-FPM ishga tushadi (CMD orqali)
exec "$@"
