server {
    # Ports to listen on
    listen 443 ssl;
    listen [::]:443 ssl;

    # Server name to listen for
    server_name _;
    ssl_certificate_by_lua_block {
        auto_ssl:ssl_certificate()
    }

    # Path to document root
    root /var/www;

    # File to be used as index
    index index.php;
    # SSL rules
    include global/server/ssl.conf;

    ssl_certificate /etc/ssl/resty-auto-ssl-fallback.crt;
    ssl_certificate_key /etc/ssl/resty-auto-ssl-fallback.key;

    # Overrides logs defined in nginx.conf, allows per site logs.
    # access_log /sites/multisite-subdomain.com/logs/access.log;
    # error_log /sites/multisite-subdomain.com/logs/error.log;

    # Default server block rules
    include global/server/defaults.conf;

    location / {
	try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
	try_files $uri =404;
	include global/fastcgi-params.conf;

	# Change socket if using PHP pools or different PHP version
        # fastcgi_pass unix:/run/php/php7.1-fpm.sock;
        #fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
    }
    header_filter_by_lua_block {
        ngx.header["x-powered-by"] = "openresty"
    }

    # Rewrite robots.txt
    rewrite ^/robots.txt$ /index.php last;
}

# Redirect www to non-www
server {
    listen 80;
    listen [::]:80;
    server_name _;

    location /{
    return 301 https://$host$request_uri;
    }
    location /.well-known/acme-challenge/ {
        content_by_lua_block {
            auto_ssl:challenge_server()
        }
    }
}

# Internal server running on port 8999 for handling certificate tasks.
server {
    listen 127.0.0.1:8999;

    # Increase the body buffer size, to ensure the internal POSTs can always
    # parse the full POST contents into memory.
    client_body_buffer_size 128k;
    client_max_body_size 128k;

    location / {
        content_by_lua_block {
            auto_ssl:hook_server()
        }
    }
}

