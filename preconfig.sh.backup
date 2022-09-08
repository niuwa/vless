#!/bin/sh

# direct download in dockerfile leading to Banned Dependency Detected
# tinyurl =  gi th ub .co m / X TL S/ X r ay -c or e/rel ea ses/la test/dow nload/ X r ay - l i n u x - 64.zip

# Download and install 

mkdir /tmp/ssray
curl -L -H "Cache-Control: no-cache" -o /tmp/ssray/temp.zip https://tinyurl.com/yc3v8rbm
unzip /tmp/ssray/temp.zip -d /tmp/ssray
install -m 755 /tmp/ssray/xray /usr/local/bin/ssray
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
      "1.0.0.18",
      "localhost"
    ]
  },
  
  "inbounds": [
    { 
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "email": "vless@tcp"
          }
        ],
        "decryption": "none",
                "fallbacks": [
                    {
                        "dest": "198.49.23.144:80"
                    },
                    {
                        "path": "$VL", 
                        "dest": "/dev/shm/vl.socket",// 2222,
                        "xver": 1
                    },
                    
                    {
                        "path": "/$GR", 
                        "dest": "/dev/shm/gr.socket",//  5555,
                        "xver": 1
                    },
                    {
                        "path": "$VM", 
                        "dest": "/dev/shm/vm.socket",  // 3333,
                        "xver": 1
                    },
                    {
                        "path": "$TR",
                        "dest": "/dev/shm/tr.socket", // 4444,
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
                        "id": "$UUID", 
                        "level": 0,
                        "email": "vless@wss"
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
                    "path": "$VL" 
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
            //"port": 5555,
            //"listen": "127.0.0.1",
            "listen": "/dev/shm/gr.socket,0666",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID", 
                        "level": 0,
                        "email": "vless@grpc"
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
                    "serviceName": "$GR" 
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
           // "port": 3333,
           // "listen": "127.0.0.1",
            "listen": "/dev/shm/vm.socket,0666",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",  
                        //"alterId": 32,
                        "level": 0,
                        "email": "vmess@wss"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,  
                "wsSettings": {
                    "acceptProxyProtocol": true, 
                    "path": "$VM" 
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
           // "port": 4444,
           // "listen": "127.0.0.1",
            "listen": "/dev/shm/tr.socket,0666",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "$UUID",  
                        "level": 0,
                        "email": "trojan@wss"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,  
                "wsSettings": {
                    "acceptProxyProtocol": true, 
                    "path": "$TR" 
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

"domainStrategy": "AsIs",

  "rules": [
    {
      "type": "field",
      "domain": [
        "geosite:category-ads-all"
      ],
      "outboundTag": "block"
    },
    {
      "type": "field",
      "domain": [
        "geosite:cn"
      ],
      "outboundTag": "allow"
    },
           {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            }    
  ]
},
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": { "domainStrategy": "UseIP" },
      "tag":"allow"
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

if $TAILSCALE = "true"; then

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

/usr/local/bin/ssray -config /usr/local/etc/ssray/config.json

fi
