FROM openresty/openresty:1.25.3.1-4-bionic

#====== Настройка окружения

RUN apt-get update \
    && apt-get install -y git libssl-dev libyaml-dev \
    && apt-get clean all

#====== Настройка окружения закончена

LABEL maintainer="Dmitry"

#====== Настройка кодировки

RUN apt-get install -y language-pack-ru
RUN locale-gen ru_RU.UTF-8
ENV LANG=ru_RU.UTF-8 \
    LANGUAGE=ru_RU:ru \
    LC_ALL=ru_RU.UTF-8

#====== Настройка кодировки закончена

#====== Установка зависимостей для Lua

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http \
    && /usr/local/openresty/luajit/bin/luarocks install pgmoon \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-cookie \
    && /usr/local/openresty/luajit/bin/luarocks install luafilesystem \
    && /usr/local/openresty/luajit/bin/luarocks install --server=https://luarocks.org/dev ltn12 \
    && /usr/local/openresty/luajit/bin/luarocks install luasocket \
    && /usr/local/openresty/luajit/bin/luarocks install luasec \
    && /usr/local/openresty/luajit/bin/luarocks install --server=http://rocks.moonscript.org lyaml \
    && /usr/local/openresty/luajit/bin/luarocks install xml2lua \
    && /usr/local/openresty/luajit/bin/luarocks install luaposix

#====== Установка зависимостей для Lua закончена