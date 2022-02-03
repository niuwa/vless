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
            "alterId": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "allowInsecure": false,      
        "wsSettings": {
          "path": "$VL"
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
      "outboundTag": "blocked"
    },
    {
      "type": "field",
      "domain": [
        "geosite:cn"
      ],
      "outboundTag": "blocked"
    }
  ]
},
  
  "outbounds": [
    {
      "protocol": "freedom"
    },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        }
  ]
}
EOF

# Run xray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
