FROM php:5.6-apache
RUN apt-get update && \
apt-get install -y wget nginx supervisor libapache2-mod-rpaf sudo git mc net-tools openssh-server mysql-client vim nano msmtp \
	cron gcc make libjpeg-dev libpng-dev libtiff-dev libvpx-dev libxpm-dev libfontconfig1-dev libxpm-dev checkinstall \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2 \
        libxml2-dev \
        libcurl4-openssl-dev \
        libpspell-dev \
        libtidy-dev \
        libxslt1-dev 

WORKDIR /usr/src
#RUN apt-get install wget -y
RUN wget https://github.com/libgd/libgd/releases/download/gd-2.1.1/libgd-2.1.1.tar.gz
RUN tar zxvf libgd-2.1.1.tar.gz
WORKDIR /usr/src/libgd-2.1.1
#RUN apt-get install cron gcc make libjpeg-dev libpng-dev libtiff-dev libvpx-dev libxpm-dev libfontconfig1-dev libxpm-dev checkinstall -y
RUN ./configure
RUN make
RUN checkinstall --pkgname=libgd3
#RUN apt-get update && apt-get install -y \
#        libfreetype6-dev \
#        libjpeg62-turbo-dev \
#        libmcrypt-dev \
#        libpng12-dev \
#        libxml2 \
#        libxml2-dev \
#        libcurl4-openssl-dev \
#        libpspell-dev \
#        libtidy-dev \
#        libxslt1-dev \
RUN docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-gd=/usr/src/libgd-2.1.1/src/ \
    && docker-php-ext-install gd 
RUN docker-php-ext-install bcmath ctype curl dom gettext hash iconv json mbstring mysqli opcache posix pspell  session shmop simplexml  soap sockets
RUN docker-php-ext-install tidy tokenizer wddx 
RUN docker-php-ext-install xsl zip
RUN docker-php-ext-install pdo pdo_mysql 
RUN docker-php-ext-install xml  xmlrpc xmlwriter 


RUN a2enmod rpaf rewrite
ADD apache-security.conf /etc/apache2/conf-enabled/security.conf

ADD supervisord.conf /etc/supervisor/

RUN /usr/bin/ssh-keygen -A

RUN useradd -d /home/sftpdev/ -s /bin/bash -o -g 33 -u 33 sftpdev; \
    usermod -d /home/sftpdev/ www-data && \
    echo "sftpdev ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers; \
    ln -s /var/www/html/ /home/sftpdev/ ; \
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers



RUN mkdir /var/run/sshd; chmod 0755 /var/run/sshd
RUN sed -i "s/Listen 80/Listen 81/g" /etc/apache2/ports.conf

ADD nginx.conf /etc/nginx/

RUN echo "DOCKER PHP_VERSION=$PHP_VERSION; BUILD DATE: `date -I`" > /etc/motd


RUN echo 'sendmail_path = "/usr/bin/msmtp -C /var/www/.msmtprc  -t"' > /usr/local/etc/php/conf.d/sendmail-msmtp.ini

WORKDIR /home/sftpdev

ADD start.sh /
CMD ["/start.sh"]


#RUN apt-get install wget -y
#RUN wget https://github.com/libgd/libgd/releases/download/gd-2.1.1/libgd-2.1.1.tar.gz
#RUN tar zxvf libgd-2.1.1.tar.gz
#WORKDIR /usr/src/libgd-2.1.1
#RUN apt-get install gcc make libjpeg-dev libpng-dev libtiff-dev libvpx-dev libxpm-dev libfontconfig1-dev libxpm-dev checkinstall -y
#RUN ./configure
#RUN make
#RUN checkinstall
