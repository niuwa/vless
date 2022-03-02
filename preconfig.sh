#!/bin/sh

# Download and install ssray
mkdir /tmp/ssray
curl -L -H "Cache-Control: no-cache" -o /tmp/ssray/temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/ssray/temp.zip -d /tmp/ssray
install -m 755 /tmp/ssray/xray /usr/local/bin/ssray
install -m 755 /tmp/ssray/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/ssray/geoip.dat /usr/local/bin/geoip.dat

#ssray -version

# Remove temporary directory
rm -rf /tmp/ssray

# ssray new configuration
install -d /usr/local/etc/ssray
cat << EOF > /usr/local/etc/ssray/config.json
{
  "log": {
    "loglevel": "info"
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
                        "dest": 2222,
                        "xver": 1
                    },
                    {
                        "path": "$VM", 
                        "dest": 3333,
                        "xver": 1
                    },
                    {
                        "path": "$TR",
                        "dest": 4444,
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
        },
        
        
          {
            "port": 4444,
            "listen": "127.0.0.1",
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

#echo "App is running" > /var/www/localhost/htdocs/index.html

# Run ssray
/usr/local/bin/ssray -config /usr/local/etc/ssray/config.json 

