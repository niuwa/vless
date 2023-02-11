FROM alpine:latest as tailscalealpine 
WORKDIR /app 
COPY . ./ 
ENV TSFILE=tailscale_1.37.0_amd64.tgz 
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \ 
   tar xzf ${TSFILE} --strip-components=1 


FROM alpine:latest
RUN apk update && apk add --no-cache --virtual .build-deps ca-certificates curl unzip 

COPY --from=tailscalealpine /app/tailscaled /app/tailscaled
COPY --from=tailscalealpine /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
RUN chmod +x /app/tailscaled
RUN chmod +x /app/tailscale

ADD preconfig.sh /preconfig.sh
RUN chmod +x /preconfig.sh

#CMD /preconfig.sh
ENTRYPOINT ["/preconfig.sh"]
