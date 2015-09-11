## -*- docker-image-name: "scaleway/pydio:trusty" -*-
FROM scaleway/ubuntu:trusty
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter


# Install packages
RUN apt-get -q update \
 && apt-get -y -q upgrade \
 && apt-get install -y -q \
        apache2 \
        libapache2-mod-php5 \
        php5 \
        php5-cgi \
        php5-cli \
        php5-curl \
        php5-gd \
        php5-intl \
        php5-mcrypt \
        php5-mysqlnd \
        pwgen \
		sqlite	\
 && apt-get clean

ENV PYDIO_VERSION 6.0.8

# Install Pydio
RUN wget -qO /tmp/pydio.deb http://dl.ajaxplorer.info/repos/apt/pool/main/p/pydio/pydio_${PYDIO_VERSION}_all.deb \
 && dpkg -i /tmp/pydio.deb \
 && rm -f /tmp/pydio.deb


# Configues Apache/PHP
RUN a2enmod rewrite \
 && ln -sf /usr/share/doc/pydio/apache2.sample.conf /etc/apache2/sites-enabled/pydio.conf \
 && ln -sf /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/


# Patch rootfs
ADD ./patches/etc/ /etc/
ADD ./patches/usr/local/ /usr/local/
ADD ./patches/usr/share/ /usr/share/


ENV AWSSDK_VERSION 2.8.20

# Install Pydio dependencies
RUN cd /usr/share/pydio && curl -sS https://getcomposer.org/installer | php \
 && cd /usr/share/pydio && php composer.phar install \
 && wget -qO /usr/share/pydio/aws.phar https://github.com/aws/aws-sdk-php/releases/download/$AWSSDK_VERSION/aws.phar


# Update permissions
RUN chown -R www-data:www-data /usr/share/pydio/


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
