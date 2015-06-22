server {
    listen   80;
    server_name beta.tastesavant.com;
    rewrite ^(.*) http://www.tastesavant.com$1 permanent;
}

server {
    listen 443;
    ssl on;
    ssl_certificate /etc/nginx/certs/rapidssl.crt;
    ssl_certificate_key /etc/nginx/certs/domain.key;

    server_name tastesavant.com;
    location / {
        include     /etc/nginx/proxy.conf;
        proxy_pass  http://www.tastesavant.com;
        proxy_set_header X-Forwarded-Ssl on;
	     add_header X-Handled-By "production";
    }
}

server {
    listen   80;

    server_name tastesavant.com www.tastesavant.com;

    if ($host !~* ^www\.){
        rewrite ^(.*)$ http://www.tastesavant.com$1 permanent;
    }    
    client_max_body_size 20M;

    access_log /var/log/nginx/access.production.tastesavant.com.log;
    error_log /var/log/nginx/error.production.tastesavant.com.log;

    location /media {
        alias /var/www/www.tastesavant.com/taste/media;
    }

    location /google45587d46681e9a0e.html {
        root /home/web/google-verification/;
    }

    location ~* ^/(favicon.ico|robots.txt)$ {
    	root /var/www/static/production/;
    }

    location / {
        if (-f /var/www/maintenance.html) {
            return 503;
        }
        include     /etc/nginx/proxy.conf;
        proxy_pass  http://www.tastesavant.com;
	add_header X-Handled-By "production";
    }

    error_page 503 @maintenance;
    location @maintenance {
        try_files /var/www/maintenance.html =503;
    }

    location = /favicon.ico {
        return 204;
        access_log off;
        log_not_found off;
    }
    
    error_page 500 502 504 /500.html;
    location = /500.html {
        root /var/www/www.tastesavant.com/taste/templates;
    }
}
