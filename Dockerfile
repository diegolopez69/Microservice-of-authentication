FROM alpine:edge AS deployment-stage

#Package installation
RUN apk --no-cache add php7 php7-fpm php7-opcache php7-mysqli php7-pdo_mysql php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-gd php7-sockets php7-xmlwriter php7-tokenizer nginx supervisor curl && \
    rm /etc/nginx/conf.d/default.conf && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Configuration files
COPY ./etc/php/deploy-www.conf /etc/php7/php-fpm.d/www.conf
COPY ./etc/nginx/deploy-nginx.conf /etc/nginx/nginx.conf
COPY ./etc/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Manage user and create folders
RUN addgroup -g 1000 userphp && adduser -G userphp -g userphp -s /bin/sh -D userphp &&\
    mkdir -p /var/www/html && \
    chown userphp:userphp /var/www/html && \
    chown -R userphp:userphp /run && \
    chown -R userphp:userphp /var/lib/nginx && \
    chown -R userphp:userphp /var/log/nginx

USER userphp


WORKDIR /var/www/html
COPY --chown=userphp:userphp src/ /var/www/html/
RUN composer install --no-dev --no-interaction
EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 