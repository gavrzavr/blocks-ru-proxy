#!/bin/sh
# Timeweb VPS user-data: turns a fresh Ubuntu into the Moscow front (nginx -> Amsterdam edge -> Vercel).
mkdir -p /root/.ssh && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5YOXgZNvNDcaeZodqgui+h+wBeZPDaLdsilkPtqNxU blocks-ru-proxy" >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y nginx
curl -fsSL https://raw.githubusercontent.com/gavrzavr/blocks-ru-proxy/main/moscow/nginx.conf -o /etc/nginx/nginx.conf
sed -i 's#pid /tmp/nginx.pid;#pid /run/nginx.pid;#; s#access_log /dev/stdout;#access_log /var/log/nginx/access.log;#; s#error_log /dev/stderr warn;#error_log /var/log/nginx/error.log warn;#' /etc/nginx/nginx.conf
mkdir -p /srv
curl -fsSL https://raw.githubusercontent.com/gavrzavr/blocks-ru-proxy/main/moscow/test.html -o /srv/test.html
head -c 300000 /dev/zero | tr '\0' a > /srv/big.txt
systemctl restart nginx
