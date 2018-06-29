FROM ubuntu:14.04
MAINTAINER poc-it

ENV DEBIAN_FRONTEND noninteractive

# Get some security updates
RUN apt-get update
RUN apt-get -y upgrade


#install java 8
RUN apt-get update && apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true" | debconf-set-selections
RUN apt-get update && apt-get install -y oracle-java8-installer maven

# install mysql
RUN apt-get -y install mysql-server
RUN apt-get install python-mysqldb

# See readme.md for more information about the accounts and passwords
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections


# add our my.cnf and setup script
ADD conf/my.cnf /etc/mysql/my.cnf
ADD build/setup.sh /home/setup.sh
ADD build/run.sh /home/run.sh
ADD build/checkdb.sh /home/checkdb.sh
ADD build/checkserver.sh /home/checkserver.sh
ADD build/helperfunctions.sh /home/helperfunctions.sh
ADD build/createtenant.sh /home/createtenant.sh
ADD build/deploy.sh /home/deploy.sh
RUN chmod +x /home/setup.sh
RUN chmod +x /home/run.sh
RUN chmod +x /home/checkdb.sh
RUN chmod +x /home/checkserver.sh
RUN chmod +x /home/deploy.sh
RUN chmod +x /home/createtenant.sh
RUN chmod +x /home/helperfunctions.sh

# Define mountable directories.
VOLUME ["/var/lib/mysql"]
# Define working directory.
# Mount with `-v <data-dir>:/var/lib/mysql`
WORKDIR /var/lib/mysql

# expose service port
EXPOSE 3306

# Start mysqld
RUN mysql_tzinfo_to_sql /usr/share/zoneinfo | sed "s/Local time zone .*$/UNSET'\)/g" > /etc/mysql/zoneinfo.sql 
CMD ["/home/setup.sh"]

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2 php5 php5-mysql libapache2-mod-php5 curl lynx-cur

#setup java home
RUN export JAVA_HOME=`update-java-alternatives -l | awk '{print $3}'`

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Expose apache.
EXPOSE 80

# Copy this repo into place.
#ADD www /var/www/site

# Update the default apache site with the config we created.
#ADD conf/apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
#CMD /usr/sbin/apache2ctl start

#create smartuser
RUN useradd -d /home/smartuser -ms /bin/bash -p smartuser smartuser
USER smartuser
WORKDIR /home/smartuser
RUN mkdir scripts
RUN mkdir smartinstall

ADD build/setupsmart.tar /home/smartuser/scripts
WORKDIR /home/smartuser/scripts

#ensure that mysql has started up
CMD ["/home/checkdb.sh"]
RUN ./setupSmart.sh /home/smartuser/smartinstall/ $JAVA_HOME/ eth0
ADD build/smart-upgrade.tar /home/smartuser/smartinstall/lib/org/anon
RUN mkdir -p /home/smartuser/smartinstall/config/org/anon/smart/kernel/config/
ADD conf/SmartConfigSecureServer.cfg /home/smartuser/smartinstall/config/org/anon/smart/kernel/config/SmartConfigSecureServer.cfg

VOLUME [/app]

EXPOSE 9081

