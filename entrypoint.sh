#!/bin/sh
chown -R www-data:www-data /var/www/html/files
exec apache2-foreground