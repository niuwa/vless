FROM alpine:latest

RUN apk add --no-cache --virtual .build-deps ca-certificates curl unzip 

ADD preconfig.sh /preconfig.sh
RUN chmod +x /preconfig.sh
CMD /preconfig.sh
