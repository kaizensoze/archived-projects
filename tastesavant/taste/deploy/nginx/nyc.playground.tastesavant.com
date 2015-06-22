server {
    listen   80;
    server_name nyc.playground.tastesavant.com;
    client_max_body_size 20M;

    access_log /var/log/nginx/access.nyc.playground.tastesavant.com.log;
    error_log /var/log/nginx/error.nyc.playground.tastesavant.com.log;

    location /media {
        alias /var/www/playground.tastesavant.com/taste/media;
    }

    location ~* ^/(favicon.ico|robots.txt)$ {
        root /var/www/static/;
    }

    location / {
        include     /etc/nginx/proxy.conf;
        proxy_pass  http://nyc.playground.tastesavant.com;
    }

    location = /favicon.ico {
        return 204;
        access_log off;
        log_not_found off;         
    }
    
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /var/www/playground.tastesavant.com/taste/templates;
    }
}
