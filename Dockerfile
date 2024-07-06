FROM hyperf/hyperf:8.0-alpine-v3.12-swoole

ARG timezone

ENV TIMEZONE=${timezone:-"UTC"}

# update
RUN set -ex \
    && apk update \
    && apk add --no-cache \
    && apk add openssh-client \
    && apk add php8-gmp \
    && apk add php8-pdo_pgsql \
    && apk add php8-pgsql \
    && apk add yaml yaml-dev \
    # show php version and extensions
    && php -v \
    && php -m \
    && php --ri swoole \
    #  ---------- some config ----------
    && cd /etc/php8 \
    # - config PHP
    && { \
        echo "upload_max_filesize=128M"; \
        echo "post_max_size=128M"; \
        echo "memory_limit=1G"; \
        echo "date.timezone=${TIMEZONE}"; \
    } | tee conf.d/99_overrides.ini \
    # - config timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    &&  curl -L "https://mirrors.aliyun.com/composer/composer.phar" -o /usr/local/bin/composer\
    &&  chmod +x /usr/local/bin/composer\
    # 修改 composer 为国内镜像
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    # ---------- clear works ----------
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

WORKDIR /opt/www
