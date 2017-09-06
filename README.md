# typo3-7-fpm-alpine
Latest Typo3 7 LTS based on php:fpm-alpine:latest with opcode caching enabled for performance.

Typo3 Version: 7.6.22

Note: the vulnerabilities stem from the upstream Alpine image, so there's nothing that can be done here downstream. The affected packages are required by php plugins so it's not possible to simply remove them. Also, I've checked the findings and while critical, they should not impede the security of the Typo3 installation.

For security reasons, consider disabling or even better: redirecting port 80 with a HTTP 302 redirection to 443 and enable TLS (SSL). Use the nginx config file for this.

Unless you absolutely need direct access to the database, don't expose the MariaDB port. Obviously, the DB details need to be changed, too.

Example docker-compose.yml file:

    version: "2"
    services:
      nginx:
        image: nginx:alpine
        restart: always
        ports:
          - "80:80/tcp"
          - "443:443/tcp"
        links:
          - typo3
        volumes:
          - nginx.conf:/etc/nginx/nginx.conf:ro
          - site.conf:/etc/nginx/conf.d/site.conf:ro
          - nginx.crt:/etc/nginx/nginx.crt:ro
          - nginx.key:/etc/nginx/nginx.key:ro
          - /letsencrypt:/var/www/letsencrypt
          - /var/nginx/cache
        volumes_from:
          - typo3
        depends_on:
          - typo3
      typo3:
        image: zyrill/typo3
        restart: always
        expose:
          - 9000
        links:
          - redis
          - mariadb
        volumes:
          - /var/www/html
        depends_on:
          - redis
          - mariadb
      redis:
        image: redis:alpine
        restart: always
      mariadb:
        image: mariadb:latest
        restart: always
        ports:
          - 3306
        environment:
          - MYSQL_ROOT_PASSWORD=!!!ChangeThis!!!
          - MYSQL_DATABASE=!!!ChangeThis!!!
          - MYSQL_USER=!!!ChangeThis!!!
          - MYSQL_PASSWORD=!!!AndThis!!!
        volumes:
          - /var/lib/mysql
