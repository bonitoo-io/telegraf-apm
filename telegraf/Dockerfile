
## cache go mod dependencies
FROM golang as build_base
WORKDIR /go/src/github.com/bonitoo-io/telegraf
ENV GO111MODULE=on
COPY ./build/telegraf/go.mod .
COPY ./build/telegraf/go.sum .
RUN go mod download

## build telegraf
FROM build_base AS server_builder
COPY ./build/telegraf/ .
RUN make

## run telegraf
FROM golang
COPY --from=server_builder /go/src/github.com/bonitoo-io/telegraf/telegraf ./
EXPOSE 8200
CMD ["./telegraf"]