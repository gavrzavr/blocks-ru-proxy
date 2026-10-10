#!/bin/sh
# Run on the Moscow VPS: issues Let's Encrypt for blocks.zone + www via DNS-01 while DNS still points at Vercel.
# Prints the two TXT records to add in Squarespace; certbot keeps waiting in the background until they are public.
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq certbot dnsutils >/dev/null 2>&1
cat > /root/acme-hook.sh <<'EOF'
#!/bin/sh
echo "_acme-challenge.$CERTBOT_DOMAIN $CERTBOT_VALIDATION" >> /root/acme.txt
[ "${CERTBOT_REMAINING_CHALLENGES:-0}" = "0" ] || exit 0
while read name value; do
  until dig +short TXT "$name" @8.8.8.8 | grep -q "$value"; do sleep 20; done
done < /root/acme.txt
sleep 30
EOF
chmod +x /root/acme-hook.sh
rm -f /root/acme.txt
nohup certbot certonly --manual --preferred-challenges dns --manual-auth-hook /root/acme-hook.sh \
  -d blocks.zone -d www.blocks.zone --agree-tos -m m@blocks.zone --no-eff-email --non-interactive \
  > /root/certbot.log 2>&1 &
sleep 20
echo "=== Добавь в Squarespace две TXT-записи (Host / Data): ==="
sed 's/\.blocks\.zone / /' /root/acme.txt
