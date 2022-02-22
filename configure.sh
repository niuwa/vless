#!/bin/sh

# Download and install xray
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
install -m 755 /tmp/xray/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/xray/geoip.dat /usr/local/bin/geoip.dat

xray -version

# Remove temporary directory
rm -rf /tmp/xray

# xray new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "VLESS",
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
                        "dest": 80
                    },
                    {
                        "path": "$VL", 
                        "dest": 2222,
                        "xver": 1
                    },
                    {
                        "path": "$VM", 
                        "dest": 3333,
                        "xver": 1
                    }
                ]        
        
        
        
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none"
//        "network": "ws",
//        "allowInsecure": false,      
//        "wsSettings": {
//          "path": "$VL"
//        }
      }
    },
        {
            "port": 2222,
            "listen": "127.0.0.1",
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
            }
        },
    
          {
            "port": 3333,
            "listen": "127.0.0.1",
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
            }
        }
    

  ],
  
"routing": {
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
      "tag":"allow"
    },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
  ]
}
EOF

echo "App is running" > /var/www/localhost/htdocs/index.html


# Run xray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json &
rc-service lighttpd start


