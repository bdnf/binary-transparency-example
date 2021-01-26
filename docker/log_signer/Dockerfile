#FROM golang:1.11 as build
FROM sconecuratedimages/crosscompilers:ubuntu18.04-scone5.0
RUN apt-get update
RUN apt-get install -y wget  git gcc
RUN apt-get install -y libmpc-dev
RUN wget -P /tmp https://dl.google.com/go/go1.15.6.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.15.6.linux-amd64.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR /trillian

ARG GOFLAGS=""
ENV GOFLAGS=$GOFLAGS
ENV GO111MODULE=on
ENV CGO_ENABLED=1

# Download dependencies first - this should be cacheable.
#COPY go.mod go.sum ./
#RUN go mod download

# Now add the local Trillian repo, which typically isn't cacheable.
COPY . /
WORKDIR /trillian
RUN go mod download

RUN pwd && ls
RUN find / -name gccgo_c.c | tail -n 3

#RUN cp ./examples/deployment/docker/log_signer/patch /go/pkg/mod/golang.org/x/sys@v0.0.0-20201214210602-f9fddec55a1e/unix/patch
RUN cp /docker/gccgo_c.c /go/pkg/mod/golang.org/x/sys@v0.0.0-20201214210602-f9fddec55a1e/unix/gccgo_c.c

#RUN git apply ./examples/deployment/docker/log_signer/patch

# Build the signer.
RUN go get ./cmd/trillian_log_signer
# Run the licensing tool and save licenses, copyright notices, etc.
#RUN go run github.com/google/go-licenses save ./cmd/trillian_log_signer --save_path /THIRD_PARTY_NOTICES

RUN cd ./cmd/trillian_log_signer && go build --compiler gccgo  -x -o /go/bin/trillian_log_signer

# Make a minimal image.
#FROM gcr.io/distroless/base

#COPY --from=build /go/bin/trillian_log_signer /
#COPY --from=build /THIRD_PARTY_NOTICES /THIRD_PARTY_NOTICES


ENTRYPOINT ["/go/bin/trillian_log_signer"]
