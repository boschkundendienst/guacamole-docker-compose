sudo systemctl enable docker
sudo systemctl start docker 
sudo docker volume create --name=db
git clone https://github.com/tankmek/guacamole-docker-compose.git
cd guacamole-docker-compose/guacamole
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ssl/nginx-priv.key -out ssl/nginx-pub.crt
openssl dhparam -out ssl/dhparam.pem 4096
sudo docker run --rm guacamole/guacamole:1.4.0 /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
sudo setenforce 0
sudo docker-compose -p guacamole up -d
sudo docker cp initdb.sql db:/tmp
sudo docker exec -it db bash
mysql -u root -p
use mysql;
drop user guacamole_user;
create user guacamole_user@'%' identified by 'GuacUserPasswd';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'%'; 
flush privileges;
use guacamole_db;
source /tmp/initdb.sql
exit
exit