FROM alpine:latest as tailscalealpine 
WORKDIR /app 
COPY . ./ 
ENV TSFILE=tailscale_1.22.2_amd64.tgz 
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \ 
   tar xzf ${TSFILE} --strip-components=1 
#RUN mkdir /tmp/ssray
#RUN curl -L -H "Cache-Control: no-cache" -o /tmp/ssray/temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip   
#RUN unzip /tmp/ssray/temp.zip -d /tmp/ssray

FROM alpine:latest
RUN apk update && apk add --no-cache --virtual .build-deps ca-certificates curl unzip 

COPY --from=tailscalealpine /app/tailscaled /app/tailscaled
COPY --from=tailscalealpine /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
RUN chmod +x /app/tailscaled
RUN chmod +x /app/tailscale

#RUN mkdir /usr/local/bin
#COPY --from=tailscalealpine /tmp/ssray/xray /usr/local/bin/ssray
#COPY --from=tailscalealpine /tmp/ssray/geosite.dat /usr/local/bin/geosite.dat
#COPY --from=tailscalealpine /tmp/ssray/geoip.dat /usr/local/bin/geoip.dat
#RUN chmod +x /usr/local/bin/ssray

ADD preconfig.sh /preconfig.sh
RUN chmod +x /preconfig.sh

CMD /preconfig.sh
