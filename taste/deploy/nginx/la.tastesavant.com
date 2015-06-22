server {
    listen   80;
    server_name la.tastesavant.com;
    client_max_body_size 20M;

    access_log /var/log/nginx/access.la.tastesavant.com.log;
    error_log /var/log/nginx/error.la.tastesavant.com.log;
    
    location /static {
        alias /var/www/www.tastesavant.com/taste/static;
    }

    location /media {
        alias /var/www/www.tastesavant.com/taste/media;
    }

    location /google45587d46681e9a0e.html {
        root /home/web/google-verification/;
    }

    location ~* ^/(favicon.ico|robots.txt)$ {
    	root /var/www/static/;
    }

    location / {
        include     /etc/nginx/proxy.conf;
        proxy_pass  http://la.tastesavant.com;
    }

    location = /favicon.ico {
        return 204;
        access_log off;
        log_not_found off;
    }
    
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /var/www/www.tastesavant.com/taste/templates;
    }
}
