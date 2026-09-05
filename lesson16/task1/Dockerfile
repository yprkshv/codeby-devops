FROM alpine:latest

RUN apk update && apk add --no-cache nginx

RUN mkdir -p /opt/www

COPY index.html /opt/www/index.html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]