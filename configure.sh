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
                        "dest": "www.anneleephotography.com:443"
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

cat << EOF > /etc/lighttpd/lighttpd.conf
server.modules = (
            "mod_access",
            "mod_alias",
#            "mod_compress",
            "mod_redirect",
)

server.document-root        = "/var/www/localhost/htdocs/"
#server.upload-dirs          = ( "/var/cache/lighttpd/uploads" )
server.errorlog             = "/var/log/lighttpd/error.log"
server.pid-file             = "/var/run/lighttpd.pid"
#server.username             = "www-data"
#server.groupname            = "www-data"
server.port                 = 8080

index-file.names            = ( "index.php", "index.html", "index.lighttpd.html" )
url.access-deny             = ( "~", ".inc" )
static-file.exclude-extensions = ( ".php", ".pl", ".fcgi" )

#compress.cache-dir          = "/var/cache/lighttpd/compress/"
#compress.filetype           = ( "application/javascript", "text/css", "text/html", "text/plain" )

# default listening port for IPv6 falls back to the IPv4 port
## Use ipv6 if available
#include_shell "/usr/share/lighttpd/use-ipv6.pl " + server.port
#include_shell "/usr/share/lighttpd/create-mime.assign.pl"
#include_shell "/usr/share/lighttpd/include-conf-enabled.pl"

EOF

# Run xray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json &
lighttpd -f /etc/lighttpd/lighttpd.conf


