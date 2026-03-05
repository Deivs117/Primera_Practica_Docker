FROM ubuntu

RUN apt-get update -y && \
    apt-get install -y apache2 apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY voldocker/ /var/www/html/

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
