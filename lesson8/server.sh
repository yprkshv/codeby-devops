#!/bin/bash
set -euo pipefail

DOMAIN="codebyles8.local"

echo "# установка Apache и OpenSSL #"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apache2 openssl
a2enmod ssl rewrite headers

echo "# Генерация сертификата #"
mkdir -p /etc/ssl/private /etc/ssl/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "/etc/ssl/private/${DOMAIN}.key" \
    -out "/etc/ssl/certs/${DOMAIN}.crt" \
    -subj "/CN=${DOMAIN}" \
    -addext "subjectAltName=DNS:${DOMAIN},DNS:www.${DOMAIN}"

chmod 600 "/etc/ssl/private/${DOMAIN}.key"

echo "# добавления html страницы #"
mkdir -p "/var/www/${DOMAIN}"
cat > "/var/www/${DOMAIN}/index.html" <<EOF
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Welcome</title></head>
<body>
    <h1>Hello codeby</h1>
</body>
</html>
EOF

echo "# конфигурация apache #"
cat > "/etc/apache2/sites-available/${DOMAIN}.conf" <<EOF
# HTTP -> HTTPS редирект (и для домена, и для www)
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    Redirect permanent / https://${DOMAIN}/
</VirtualHost>

# www.${DOMAIN} -> ${DOMAIN} (по HTTPS)
<VirtualHost *:443>
    ServerName www.${DOMAIN}

    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/${DOMAIN}.crt
    SSLCertificateKeyFile   /etc/ssl/private/${DOMAIN}.key

    Redirect permanent / https://${DOMAIN}/
</VirtualHost>

# Основной хост ${DOMAIN} по HTTPS
<VirtualHost *:443>
    ServerName ${DOMAIN}
    DocumentRoot /var/www/${DOMAIN}

    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/${DOMAIN}.crt
    SSLCertificateKeyFile   /etc/ssl/private/${DOMAIN}.key

    <Directory /var/www/${DOMAIN}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

echo "# включение сайта #"
a2ensite "${DOMAIN}.conf"
a2dissite 000-default.conf || true
apache2ctl configtest
systemctl restart apache2
systemctl enable apache2

echo "# копирование сертификата для клиента #"
cp "/etc/ssl/certs/${DOMAIN}.crt" "/vagrant/${DOMAIN}.crt"
