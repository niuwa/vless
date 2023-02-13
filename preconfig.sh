#!/bin/sh

###note:
### tinyurl =  g i th 🐎 ub .co m / X 🐎T L S/ X r🐎 ay -c or e/rel ea ses/la🐎 test/dow🐎 nload/ X r ay -🐎 l i n u x - 64.zip
###curl -L -H "Cache-Control: no-cache" -o /tmp/zip/temp.zip https://tinyurl.com/yc3v8rbm
###curl -L -H "Cache-Control: no-cache" -o /tmp/zip/temp.zip https://git🐎hub.c🐎om /XT🐎 LS/Xr🐎 ay-core/releases/downl🐎oad/v1.7🐎.5/Xr ay-linux-6🐎4.zip

# direct download in dockerfile leading to Banned Dependency Detected

# Download and install 

mkdir /tmp/ssray
curl -L -H "Cache-Control: no-cache" -o /tmp/ssray/temp.zip https://tinyurl.com/2564mfmj
unzip /tmp/ssray/temp.zip -d /tmp/ssray

#install -m 755 /tmp/ssray/xray /usr/local/bin/ssray
install -m 755 /tmp/ssray/web /usr/local/bin/ssray
install -m 755 /tmp/ssray/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/ssray/geoip.dat /usr/local/bin/geoip.dat

ssray -version

# Remove temporary directory
rm -rf /tmp/ssray

# ssray new configuration

install -d /usr/local/etc/ssray
cat << EOF > /usr/local/etc/ssray/config.json
{
  "log": {
    "loglevel": "info"
  },
  
    "dns": {
    "servers": [
      "https+local://1.1.1.1/dns-query", 
      "8.8.8.8",
      "localhost"
    ]
  },
  
  "inbounds": [
    { 
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "email": "vless接入tcp"
          }
        ],
        "decryption": "none",
                "fallbacks": [
                    {
                        "dest": "109.228.56.253:80"  //198.49.23.144
                    },
                    {
                        "path": "${VL}", 
                        "dest": "/dev/shm/vl.socket",// 2222,
                        "xver": 1
                    },
                    
                    {
                        "path": "/${GR}/Tun", 
                        "dest": "/dev/shm/gr.socket",//  5555,
                        "xver": 1
                    }
                ]        
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none"
      }
    },
        {
            //"port": 2222,
            //"listen": "127.0.0.1",
            "listen": "/dev/shm/vl.socket,0666",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}", 
                        "level": 0,
                        "email": "vless接入websocket"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "allowInsecure": false,  
                "wsSettings": {
                    "acceptProxyProtocol": true, 
                    "path": "${VL}" 
                }
            },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
        },     
        {
            //"port": 5555,  GRPC需要cadd y分流才可以
            //"listen": "127.0.0.1",
            "listen": "/dev/shm/gr.socket,0666",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}", 
                        "level": 0,
                        "email": "vless接入grpc"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "grpc",
                "security": "none",
                "allowInsecure": false,  
                "grpcSettings": {
                    "acceptProxyProtocol": true, 
                    "serviceName": "${GR}" 
                }
            },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
        } 

  ],
"routing": {

"domainStrategy": "IPIfNonMatch",

  "rules": [


    {
			"type": "field",
			"ip": ["geoip:private"],
			"outboundTag": "blocked"
		},
      
    {  
      "type": "field",
      "domain": [
         "domain:aefasdk43fsdafda.com"
        // "geosite:category-ads-all"    //广告不拦截 free
      ], 
      "outboundTag": "blocked"
    },
      
    {
        "domain": [
            "domain:google.co.nz",
            "geosite:cn"
        ],
        "outboundTag": "SSout",
        "type": "field"
    },              
		{
  			"ip": [
  				"geoip:cn"
  			],
			"outboundTag": "SSout",
			"type": "field"
		},  
      
    {
        "domain": [  //但是这些域名不要传到 SS out
                "domain:sharepoint.com",          
                "domain:googlevideo.com",
                "domain:google.co.uk"
        ],
        "outboundTag": "allow",
        "type": "field"
    },     
    {
        "domain": [  //这些域名都要放到SS out去 
         
                "geosite:google",
                "geosite:microsoft",
                "geosite:facebook",
                "geosite:twitter",
                "geosite:github",
                "geosite:netflix",
                "domain:exoticaz.to",
                "domain:openai.com"
        ],
        "outboundTag": "SSout",
        "type": "field"
    } 

  ]
},
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": { "domainStrategy": "UseIPv4" },
      "tag":"allow"
    },
    
    {
      "protocol": "shadowsocks",
      "settings": {
          "servers": [
              {
                  "address": "${SShost}",
                  "port": 32824,
                  "method": "chacha20-ietf-poly1305",
                  "password": "${SSkey}"
              }
          ]
      },
      "streamSettings": {
          "network": "tcp"
      },
      "tag": "SSout"
    },  
    
        {
            "protocol": "blackhole",
            "tag": "block"
        }
  ]
}
EOF

#echo "App is running" > /var/www/localhost/htdocs/index.html

# Run tailscale and ray  refer to https://tailscale.com/kb/1112/userspace-networking/

if ${TAILSCALE} = "true"; then

/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1059 & 
until /app/tailscale up --authkey=${AUTH} --hostname=${HOST} --advertise-exit-node 
do 
    echo "Waiting for Tailscale Authentication"
    sleep 3 
done 

#echo Tailscale started
#ALL_PROXY=socks5://localhost:1059/

/usr/local/bin/ssray -config /usr/local/etc/ssray/config.json

else
#tailscale false

/usr/local/bin/ssray -config /usr/local/etc/ssray/config.json

fi
