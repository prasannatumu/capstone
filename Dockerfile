FROM httpd:latest
MAINTAINER RakeshKadam
COPY index.html /var/www/html/
CMD [“/usr/sbin/httpd”, “-D”, “FOREGROUND”]
EXPOSE 80