# Guacamole with docker-compose
This is a small documentation how to run a fully working **Apache Guacamole (incubating)** instance with docker (docker-compose). The goal of this project is to make it easy to test Guacamole.

## About Guacamole
Apache Guacamole (incubating) is a clientless remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH. It is called clientless because no plugins or client software are required. Thanks to HTML5, once Guacamole is installed on a server, all you need to access your desktops is a web browser.

It supports RDP, SSH, Telnet and VNC and is the fastest HTML5 gateway I know. Checkout the projects [homepage](https://guacamole.incubator.apache.org/) for more information.

## Prerequisites
You need a working **docker** installation and **docker-compose** running on your machine.

## Quick start
Clone the GIT repository and start guacamole:

~~~bash
git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"
cd guacamole-docker-compose
./prepare.sh
docker-compose up -d
~~~

Your guacamole server should now be available at `https://ip of your server:8443/`. The default username is `guacadmin` with password `guacadmin`.

## Details
To understand some details let's take a closer look at parts of the `docker-compose.yml` file:

### Networking
The following part of docker-compose.yml will create a network with name `guacnetwork_compose` in mode `bridged`.
~~~python
...
# networks
# create a network 'guacnetwork_compose' in mode 'bridged'
networks:
  guacnetwork_compose:
    driver: bridge
...
~~~

### Services
#### guacd
The following part of docker-compose.yml will create the guacd service. guacd is the heart of Guacamole which dynamically loads support for remote desktop protocols (called "client plugins") and connects them to remote desktops based on instructions received from the web application. The container will be called `guacd_compose` based on the docker image `guacamole/guacd` connected to the host network to allow low-level functionality (WOL). Additionally we map the 2 local folders `./drive` and `./record` into the container. We can use them later to map user drives and store recordings of sessions.

~~~python
...
services:
  # guacd
  guacd:
    container_name: guacd_compose
    image: guacamole/guacd
    network_mode: host
    restart: always
    volumes:
    - ./drive:/drive:rw
    - ./record:/record:rw
...
~~~

#### PostgreSQL
The following part of docker-compose.yml will create an instance of PostgreSQL using the official docker image. This image is highly configurable using environment variables. It will for example initialize a database if an initialization script is found in the folder `/docker-entrypoint-initdb.d` within the image. Since we map the local folder `./init` inside the container as `docker-entrypoint-initdb.d` we can initialize the database for guacamole using our own script (`./init/initdb.sql`). You can read more about the details of the official postgres image [here](http://).

~~~python
...
  postgres:
    container_name: postgres_guacamole_compose
    environment:
      PGDATA: /var/lib/postgresql/data/guacamole
      POSTGRES_DB: guacamole_db
      POSTGRES_PASSWORD: ChooseYourOwnPasswordHere1234
      POSTGRES_USER: guacamole_user
    image: postgres
    networks:
      guacnetwork_compose:
    restart: always
    volumes:
    - ./init:/docker-entrypoint-initdb.d:ro
    - ./data:/var/lib/postgresql/data:rw
...
~~~

#### Guacamole
The following part of docker-compose.yml will create an instance of guacamole by using the docker image `guacamole` from docker hub. It is also highly configurable using environment variables. In this setup it is configured to connect to the previously created postgres instance using a username and password and the database `guacamole_db`. Port 8080 is only exposed locally! We will attach an instance of nginx for public facing of it in the next step.

~~~python
...
  guacamole:
    container_name: guacamole_compose
    depends_on:
    - guacd
    - postgres
    extra_hosts:
    - host.docker.internal:host-gateway
    environment:
      GUACD_HOSTNAME: host.docker.internal
      POSTGRES_DATABASE: guacamole_db
      POSTGRES_HOSTNAME: postgres
      POSTGRES_PASSWORD: ChooseYourOwnPasswordHere1234
      POSTGRES_USER: guacamole_user
    image: guacamole/guacamole
    links:
    - guacd
    networks:
      guacnetwork_compose:
    ports:
    - 8080/tcp
    restart: always
...
~~~

#### nginx
The following part of docker-compose.yml will create an instance of nginx that maps the public port 8443 to the internal port 443. The internal port 443 is then mapped to guacamole using the `./nginx.conf` and `./nginx/mysite.template` files. The container will use the previously generated (`prepare.sh`) self-signed certificate in `./nginx/ssl/` with `./nginx/ssl/self-ssl.key` and `./nginx/ssl/self.cert`.

~~~python
...
  nginx:
   container_name: nginx_guacamole_compose
   restart: always
   image: nginx
   volumes:
   - ./nginx/ssl/self.cert:/etc/nginx/ssl/self.cert:ro
   - ./nginx/ssl/self-ssl.key:/etc/nginx/ssl/self-ssl.key:ro
   - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
   - ./nginx/mysite.template:/etc/nginx/conf.d/default.conf:ro
   ports:
   - 8443:443
   links:
   - guacamole
   networks:
     guacnetwork_compose:
   # run nginx
   command: /bin/bash -c "nginx -g 'daemon off;'"
...
~~~

## prepare.sh
`prepare.sh` is a small script that creates `./init/initdb.sql` by downloading the docker image `guacamole/guacamole` and start it like this:

~~~bash
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > ./init/initdb.sql
~~~

It creates the necessary database initialization file for postgres.

`prepare.sh` also creates the self-signed certificate `./nginx/ssl/self.cert` and the private key `./nginx/ssl/self-ssl.key` which are used
by nginx for https.

## reset.sh
To reset everything to the beginning, just run `./reset.sh`.

## WOL

Wake on LAN (WOL) is functional thanks to `guacd` being connected to the host network. Note that port 4822 must be available on the host and host networking is only available on Linux.

**Disclaimer**

Downloading and executing scripts from the internet may harm your computer. Make sure to check the source of the scripts before executing them!
