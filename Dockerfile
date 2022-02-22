FROM alpine:latest

RUN apk add --no-cache --virtual .build-deps ca-certificates curl unzip caddy lighttpd

ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
