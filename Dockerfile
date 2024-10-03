FROM php:8.2.20-apache


COPY ./src /var/www/html


RUN chown -R $USER:www-data /var/www/html/*

RUN chmod -R 775 /var/www/html/*

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]