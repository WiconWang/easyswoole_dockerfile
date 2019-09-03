FROM centos:latest
MAINTAINER WICON.WANG

#version defined
ENV SWOOLE_VERSION 4.4.4
ENV EASYSWOOLE_VERSION 3.3.0

#update core
RUN yum update -y  \
    && yum install -y curl zip unzip  wget openssl-devel gcc-c++ make autoconf git

#install php
RUN yum install -y epel-release \
    && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
    && yum clean all \
    && yum update -y \
    && yum install -y php72w-devel php72w-openssl php72w-gd php72w-mbstring php72w-mysqli php72w-bcmath php72w-opcache php72w-pecl-redis  php72w-pecl-mongodb  php72w-pecl-memcached php72w-pecl-xdebug

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# swoole ext
RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
    && phpize \
    && ./configure --enable-openssl \
    && make \
    && make install \
    ) \
    && sed -i "2i extension=swoole.so" /etc/php.ini \
    && rm -r swoole

# Dir
WORKDIR /easyswoole

# install easyswoole

RUN cd /easyswoole \
    && composer require easyswoole/easyswoole=${EASYSWOOLE_VERSION} \
    && php vendor/bin/easyswoole install

EXPOSE 9501