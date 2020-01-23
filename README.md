## wonderfall/isso

![](https://i.goopics.net/q1.png)


#### What is this?
Isso is a commenting server similar to Disqus. More info on the [official website](https://posativ.org/isso/).

#### Features
- Based on Alpine Linux 3.3.
- Latest Isso installed with `pip`.

#### Build-time variables
- **ISSO_VER** : version of Isso.

#### Environment variables
- **GID** : isso group id *(default : 991)*
- **UID** : isso user id *(default : 991)*

#### Volumes
- **/config** : location of configuration files.
- **/db** : location of SQLite database.

#### Ports
- **8080** [(reverse proxy!)](https://github.com/hardware/mailserver/wiki/Reverse-proxy-configuration).

#### Example of simple configuration
Here is the full documentation : https://posativ.org/isso/docs/

 # /mnt/docker/isso/config/isso.conf
```
[general]
dbpath = /db/comments.db
host = https://cats.schrodinger.io/
[server]
listen = http://0.0.0.0:8080/
```
 # docker-compose.yml
```
version: "3"
services:
    isso:
        image: kiwilightweight/isso
        environment:
            GID: 1000
            UID: 1000
        volumes:
            - /home/data/example.nz/config:/config
            - /home/data/example.nz/db:/db
        ports:
            - "127.0.0.1:8070:8080"

```

### Example nginx reverse-proxy configuration

Assuming you're running a Debian-based system: In /etc/nginx/sites-available/example.conf - link it into /etc/nginx/sites-enabled via `sudo ln -sf /etc/nginx/sites-available/example.conf /etc/nginx/sites-enabled` and then test `sudo nginx -t`, and if all good, `sudo service nginx reload`

Replace "example.nz" with your domain name.

```
#
# HTTP does *soft* redirect to HTTPS
#
server {
    # add [IP-Address:]80 in the next line if you want to limit this to a single interface
    listen 80;
    listen [::]:80;

    server_name example.nz ;
    root /home/data/example.nz;
    index index.php;

    # change the file name of these logs to include your server name
    # if hosting many services...
    access_log /var/log/nginx/example.nz_access.log;
    error_log /var/log/nginx/example.nz_error.log;
    
    include includes/letsencrypt.conf;

    # redirect all HTTP traffic to HTTPS.
    location / {
        return  302 https://example.nz$request_uri;
    }
}
#
# HTTPS
#
# This assumes you're using Let's Encrypt for your SSL certs (and why wouldn't
# you!?)... https://letsencrypt.org
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl on;
    ssl_certificate /etc/letsencrypt/live/example.nz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.nz/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    # to create this, see https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    keepalive_timeout 20s;

    server_name example.nz;
    root /home/data/example.nz;
    index index.php;

    # change the file name of these logs to include your server name
    # if hosting many services...
    access_log /var/log/nginx/example.nz_access.log;
    error_log /var/log/nginx/example.nz_error.log;

    location / {
        proxy_pass http://127.0.0.1:8070; # replace 8070 with whatever you've put in your docker-compose.yml
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        #proxy_set_header Host $http_host;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 2400;
        proxy_read_timeout 2400;
        proxy_send_timeout 2400;
    }
    #
    # These "harden" your security
    #add_header 'Access-Control-Allow-Origin' "*";
}

```
