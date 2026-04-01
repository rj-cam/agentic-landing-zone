FROM httpd:2.4

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY pages/ /usr/local/apache2/pages/

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
