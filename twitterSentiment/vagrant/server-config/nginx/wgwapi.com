
upstream backend_nodejs {
  server 127.0.0.1:4577 max_fails=0 fail_timeout=10s;
  keepalive 512;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  
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
