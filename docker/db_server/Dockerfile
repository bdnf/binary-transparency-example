FROM gcr.io/trillian-opensource-ci/mysql5:5.7

# expects the build context to be: $GOPATH/src/github.com/google/trillian
COPY ./docker/db_server/mysql/mysql.cnf /etc/mysql/conf.d/trillian.cnf
COPY ./docker/db_server/mysql/storage.sql /docker-entrypoint-initdb.d/storage.sql
RUN chmod -R 775 /docker-entrypoint-initdb.d

