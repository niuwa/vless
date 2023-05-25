#!/bin/sh

###note:
###tinyurl =  g i th 🐎 ub .co m / X  🐎T L S/ X r🐎 ay -c or e/rel ea ses/la🐎 test/dow🐎 nload/ X r ay -🐎 l i n u x - 64.zip
###curl -L -H "Cache-Control: no-cache" -o /tmp/zip/temp.zip https://tinyurl.com/yc3v8rbm
###curl -L -H "Cache-Control: no-cache" -o /tmp/zip/temp.zip https://git🐎hub.c🐎om /XT🐎 LS/Xr🐎 ay-core/releases/downl🐎oad/v1.7🐎.5/Xr ay-linux-6🐎4.zip
###direct download in dockerfile leading to 'Banned Dependency Detected'

#  install   #  #  #  #  #  #  #  #  #  #  

mkdir /tmp/pufa
curl -L -H "Cache-Control: no-cache" -o /tmp/pufa/temp.zip https://tinyurl.com/2564mfmj
unzip /tmp/pufa/temp.zip -d /tmp/pufa

install -m 755 /tmp/pufa/web /usr/local/bin/web
install -m 755 /tmp/pufa/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/pufa/geoip.dat /usr/local/bin/geoip.dat

/usr/local/bin/web -version


# Remove temporary directory #  #  #  #  
rm -rf /tmp/pufa




# service new configuration   #  #  #  #  

install -d /usr/local/etc/web

cat << EOF > /usr/local/etc/web/config.json
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
                        "dest": "109.228.56.253:80"  //  or  198.49.23.144
                    },
                    {
                        "path": "${VL}", 
                        "dest": "/dev/shm/vl.socket",
                        "xver": 1
                    },
                    {
                        "path": "/${GR}/Tun", 
                        "dest": "/dev/shm/gr.socket",
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
            "listen": "/dev/shm/vl.socket,0666",
            "protocol": "vless",
	    "tag":"INPUTvlesswss",
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
         // "geosite:category-ads-all",    //广告拦截
         "domain:aefasdk43fsdafda.com"
      ], 
      "outboundTag": "blocked"
    },
    
    {
        "domain": [  
                //"domain:sharepoint.com",          
                "domain:googlevideo.com",
		"geosite:category-porn",
                //"domain:google.co.uk",
                "domain:srgretegfxret4rdrgsgsdr.com"   
        ],
        "outboundTag": "direct",
        "type": "field"
    },
    

    // 🐎🐎🐎🐎🐎 在这里二选一  🐎🐎🐎🐎🐎 //  这是全局转发到SSout， 如果SSout损坏的时候就注释掉，就直接默认direct(只有cn走SSout  基本上不受影响)
    {
	"type": "field",
	"inboundTag": "INPUTvlesswss",
	"outboundTag": "SSout"
		}, 
    // 🐎🐎🐎🐎🐎 在这里二选一  🐎🐎🐎🐎🐎 //  这是全局转发到SSout， 如果SSout损坏的时候就注释掉，就直接默认direct(只有cn走SSout  基本上不受影响)

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
	} 
      

//    {
//        "domain": [  //这些域名都要放到SS out去 
//                "geosite:google",
//                "geosite:microsoft",
//                "geosite:facebook",
//                "geosite:twitter",
//                "geosite:github",
//                "geosite:netflix",
//                "domain:exoticaz.to",
//		"domain:chat.openai.com",
//                "domain:openai.com"
//        ],
//        "outboundTag": "SSout",
//        "type": "field"
//    } 

  ]
},
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": { "domainStrategy": "UseIPv4" },
      "tag":"direct"
    },
    
    {
      "protocol": "shadowsocks",
      "settings": {
          "servers": [
              {
                  "address": "${SShost}",
                  "port": 32824,
                  "method": "2022-blake3-aes-256-gcm",
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
            "tag": "blocked"
        }
  ]
}
EOF

# echo "App is running" > /var/www/localhost/htdocs/index.html

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

/usr/local/bin/web -config /usr/local/etc/web/config.json

else
#tailscale = false

/usr/local/bin/web -config /usr/local/etc/web/config.json

fi
