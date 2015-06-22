
upstream backend_nodejs {
  server 192.168.133.101:3000 max_fails=0 fail_timeout=10s;
  keepalive 512;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  
  listen 443 ssl;
  ssl_certificate     /etc/nginx/ssl/wgwapi.com/comodo/server.crt;
  ssl_certificate_key /etc/nginx/ssl/wgwapi.com/comodo/server.key;
  
  server_name wgwapi.com;

  include /etc/nginx/common.conf;

  keepalive_timeout 10;

  location / {
    try_files $uri $uri/ @node;
  }

  location @node {
    proxy_pass http://backend_nodejs;
    include /etc/nginx/proxy_params;
  }
}
