FROM nginx:1.25.4-alpine

COPY /static /usr/share/nginx/html
RUN chown nginx.nginx /usr/share/nginx/html/ -R

EXPOSE 80
