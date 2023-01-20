# syntax=docker/dockerfile:1.3-labs
FROM debian:stable-20220328-slim AS serverOS
RUN apt-get update -y
RUN apt-get install sudo -y && \
apt-get install openssl -y && \
apt-get install nginx -y && \
apt-get install ufw -y
# RUN apt-get install mariadb-server -y
ENV ADMIN="esstat17"
ARG homedir=/home/$ADMIN
RUN useradd -rm -d /home/$ADMIN -s /bin/bash -g root -G sudo -u 1001 $ADMIN \
-p "$(openssl passwd -1 )"
USER ${ADMIN}
WORKDIR $homedir
#Where the web files resides
COPY ./public ./public
# Recursively change the file permission
WORKDIR $homedir/tmp
# Copying config file from local machine to server
COPY ./config ./config

# Generating CSR and Private Key
RUN sudo openssl req -new -newkey rsa:2048 -nodes -out test1_com.csr -keyout test1_com.key -subj "/C=PH/ST=STATEorPROVINCE/L=CITY/O=ORGANIZATION/OU=DEPTPARTMENT/CN=*.test1.com"

#Copy from server config to nginx config
RUN sudo cp -r ./config/nginx/nginx.conf /etc/nginx/nginx.conf
RUN sudo cp -r ./config/nginx/default /etc/nginx/sites-available/default
RUN sudo cp -r ./config/nginx/test1.com /etc/nginx/sites-available/test1.com
RUN sudo cp -r ./config/nginx/test2.com /etc/nginx/sites-available/test2.com

#First remove the default and replace it in the next line
RUN sudo rm -rf /etc/nginx/sites-enabled/default
#Symlink from sites-available to sites-enabled
RUN sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
RUN sudo ln -s /etc/nginx/sites-available/test1.com /etc/nginx/sites-enabled/
RUN sudo ln -s /etc/nginx/sites-available/test2.com /etc/nginx/sites-enabled/

# COPY ./config/nginx/default /etc/nginx/sites-available/default
# RUN ls -s /etc/nginx/sites-available/default /etc/nginx/sites-available/enable
#sudo ln -s sites-available/foo.conf sites-enabled/

RUN sudo useradd -rm -d /home/userspy -s /bin/bash userspy -p "$(openssl passwd -1 userspy)"
CMD ["sudo", "nginx", "-g", "daemon off;"]
 
#ENTRYPOINT ["echo", "Hello"]
#CMD ["World!"]


# ENTRYPOINT ["sh","./cmd/start_server.sh"]
# RUN ["chmod", "+x", "./cmd/start_server.sh"]
# CMD ["./cmd/start_server.sh"]
#CMD ["/config/cmd/start_server.sh"]

