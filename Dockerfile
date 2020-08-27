FROM alpine:latest

LABEL maintainer="Gennadiy Popov <gennadiy.popov.87@yandex.ru>"
LABEL description="Alpine based image for develop Drupal projects"

RUN apk upgrade -U -v  --progress && \
    # apk --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    apk --update -v  --progress add \
    supervisor \
    # nginx \
    autoconf dpkg-dev dpkg \
    php7-zlib \
    php7-simplexml \
    php7-mbstring \
    php7-pgsql \
    php7-pdo_pgsql \
    php7-mcrypt \
    php7-openssl \
    php7-gmp \
    php7-pdo_odbc \
    php7-pdo \
    php7-zip \
    php7-mysqli \
    php7-bcmath \
    php7-common \
    php7-odbc \
    php7-pdo_sqlite \
    php7-pdo_mysql \
    php7-gettext \
    php7-xmlreader \
    php7-xmlrpc \
    php7-xml \
    php7-curl \
    php7-bz2 \
    php7-ctype \
    php7-session \
    php7-redis \
    php7-gd \
    php7-dom \
    php7-tokenizer \
    php7-opcache \
    php7-session \
    php7-sqlite3 \
    php7-mysqlnd \
    php7-pdo_sqlite \
    php7-phar \
    php7-json \
    php7-iconv \
    php-fpm \
    php7-intl \
    php7-openssl \
    php7-pear \
    php7-imagick \
    # php7-posix \
    php7-calendar \
    php-cli \
    git \
    gzip \
    ca-certificates \
    mysql-client \
    openssh \
    libcap \
    imagemagick \
    curl \
    && rm -f /var/cache/apk/* \
    && mkdir -p /opt/utils \
    && mkdir /htdocs

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN curl -s https://getcomposer.org/installer | php; \
    mv composer.phar /usr/local/bin/composer; \
    chmod +x /usr/local/bin/composer


ARG plugins=http.git,http.cache,http.expires,http.minify,http.realip
RUN curl --show-error --fail --location \
    -o "/usr/bin/caddy" "https://caddyserver.com/api/download?os=linux&plugins=${plugins}&arch=amd64&license=personal&telemetry=off" \
    && chmod 0755 /usr/bin/caddy \
    && setcap cap_net_bind_service=+ep `readlink -f /usr/bin/caddy` \
    && /usr/bin/caddy version

RUN adduser developer --disabled-password
ADD --chown=developer:developer ./containers/server/config/ /etc/config/
WORKDIR /etc/application

RUN mkdir -p /var/service/log && \
    mkdir -p /var/service/run && \
    # mkdir -p /var/service/nginx/logs && \
    # mkdir -p /var/service/temp/body && \
    # mkdir -p /var/service/temp/proxy && \
    # mkdir -p /var/service/temp/fastcgi && \
    # mkdir -p /var/service/temp/uwsgi && \
    chown developer:developer -R /var/service

USER 1000:1000

# boosting composer install speed
RUN composer global require hirak/prestissimo 

RUN composer global require drush/drush
ENV PATH /home/developer/.composer/vendor/bin:$PATH 

EXPOSE 9000 2015 9035

# ENTRYPOINT 'bash -c "supervisord -c /etc/config/supervisor.conf'