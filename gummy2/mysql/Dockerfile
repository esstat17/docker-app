# Check comment check
FROM phpmyadmin/phpmyadmin

RUN a2enmod ssl

RUN echo "world" > /home/hello.txt

# RUN sed -ri -e 's,80,443,' /etc/apache2/sites-available/000-default.conf

# RUN sed -ri -e 's/#ServerName www.example.com/ServerName app1.datacareph.com/' /etc/apache2/sites-available/000-default.conf
# RUN sed -i -e '/^<\/VirtualHost>/i ServerName app1.datacareph.com' /etc/apache2/sites-available/000-default.conf
# RUN sed -i -e '/^<\/VirtualHost>/i SSLEngine on' /etc/apache2/sites-available/000-default.conf
# RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateFile /cert/cert.pem' /etc/apache2/sites-available/000-default.conf
# RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateKeyFile /etc/ssl/letsencrypt/privkey.pem' /etc/apache2/sites-available/000-default.conf
# RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateChainFile /etc/ssl/letsencrypt/fullchain.pem' /etc/apache2/sites-available/000-default.conf


RUN sed -i -e '/^SSLCertificateKeyFile/ s/^/#/' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i -e '/^SSLCertificateFile/ s/^/#/' /etc/apache2/sites-available/default-ssl.conf

RUN sed -i -e '/^<\/VirtualHost>/i ServerName app1.datacareph.com' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateKeyFile /etc/ssl/letsencrypt/privkey.pem' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i -e '/^	</VirtualHost>/i SSLCertificateChainFile /etc/ssl/letsencrypt/fullchain.pem' /etc/apache2/sites-available/default-ssl.conf

RUN ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled

RUN sed -i -e '/^                 SSLCertificateKeyFile/ s/^/#/' /etc/apache2/sites-available/default-ssl.conf