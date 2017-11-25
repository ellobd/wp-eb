upstream odoo {
    server 127.0.0.1:8069;
}
upstream odoochat {
    server 127.0.0.1:8072;
}

server {
    # Ports to listen on
    listen 443 ssl;
    listen [::]:443 ssl;

    # Server name to listen for
    server_name erp.*;
    ssl_certificate_by_lua_block {
        auto_ssl:ssl_certificate()
    }

    #importing wp-configurations

    include global/server/ssl.conf;
    include global/server/security.conf;

    ssl_certificate /etc/ssl/resty-auto-ssl-fallback.crt;
    ssl_certificate_key /etc/ssl/resty-auto-ssl-fallback.key;

    
    proxy_read_timeout 720s;
    proxy_connect_timeout 720s;
    proxy_send_timeout 720s;

    # Add Headers for odoo proxy mode
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;

    # log
    access_log /var/log/nginx/odoo.access.log;
    error_log /var/log/nginx/odoo.error.log;

    # Redirect requests to odoo backend server
    location / {
        proxy_redirect off;
        proxy_pass http://odoo;
    }
    location /longpolling {
        proxy_pass http://odoochat;
    }

}

# Redirect www to non-www
server {
    listen 80;
    listen [::]:80;
    server_name erp.*;
    include global/server/security.conf;

    location /{
        rewrite ^(.*) https://$host$1 permanent;
    }
    location /.well-known/acme-challenge/ {
        content_by_lua_block {
            auto_ssl:challenge_server()
        }
    }
}

