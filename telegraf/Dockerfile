FROM golang

COPY ./build/telegraf /go/src/github.com/bonitoo-io/telegraf
WORKDIR /go/src/github.com/bonitoo-io/telegraf

RUN make

EXPOSE 8200

CMD ["./telegraf"]