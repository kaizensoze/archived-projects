server {
    listen   80;
    server_name beta.tastesavant.com;
    client_max_body_size 20M;

    access_log /var/log/nginx/access.beta.tastesavant.com.log;
    error_log /var/log/nginx/error.beta.tastesavant.com.log;

    location /media {
        alias /var/www/beta.tastesavant.com/taste/media;
    }

    location ~* ^/(favicon.ico|robots.txt)$ {
    	root /var/www/static/;
    }

    location / {
        include     /etc/nginx/proxy.conf;
        proxy_pass  http://beta.tastesavant.com;
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location = /favicon.ico {
        return 204;
        access_log off;
        log_not_found off;
    }
    
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /var/www/beta.tastesavant.com/taste/templates;
    }
}
