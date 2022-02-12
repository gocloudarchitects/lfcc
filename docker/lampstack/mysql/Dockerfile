FROM mysql:5.6
COPY ./my.cnf /etc/mysql/conf.d/
MAINTAINER Nathan Curry

ENV MYSQL_DATABASE=lamp \
    MYSQL_ROOT_PASSWORD=root

ADD ./data.sql /docker-entrypoint-initdb.d

EXPOSE 3306
