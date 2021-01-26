FROM golang:1.11

RUN apt-get update && \
    apt-get install -y mysql-client

ADD . /trillian
WORKDIR /trillian

# This is used to wait for new MySQL deployments to become ready e.g.
#  ./wait-for-it.sh localhost:3306 -- mysql
RUN ./download-wait-for-it.sh

CMD [ 'mysql' ]
