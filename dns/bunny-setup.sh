#!/bin/sh
# Populates Bunny DNS zone 918026 (blocks.zone): 1:1 copy of the Squarespace records + geo "nearest point" sets
# for @ and www: Russian anchor points -> Moscow proxy, world anchor points -> Vercel.
set -e
K=$(cat ~/.config/bunny.key); Z=918026
add() { curl -s -X PUT "https://api.bunny.net/dnszone/$Z/records" -H "AccessKey: $K" -H "Content-Type: application/json" -d "$1" \
  | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("Id"),d.get("Type"),repr(d.get("Name")),str(d.get("Value"))[:40],d.get("Message") or "")'; }

# --- 1:1 copy of Squarespace ---
add '{"Type":2,"Name":"_domainconnect","Value":"_domainconnect.domains.squarespace.com","Ttl":3600}'
for mx in "1 aspmx.l.google.com" "5 alt1.aspmx.l.google.com" "5 alt2.aspmx.l.google.com" "10 alt3.aspmx.l.google.com" "10 alt4.aspmx.l.google.com"; do
  set -- $mx; add "{\"Type\":4,\"Name\":\"\",\"Value\":\"$2\",\"Priority\":$1,\"Ttl\":14400}"
done
add '{"Type":0,"Name":"ru","Value":"178.209.127.53","Ttl":14400}'
add '{"Type":4,"Name":"send","Value":"feedback-smtp.us-east-1.amazonses.com","Priority":10,"Ttl":14400}'
add '{"Type":3,"Name":"","Value":"google-site-verification=ijknblBxaZ7iBEjRUzUos1P1qcXn2X2jPZ5ViYWBjqE","Ttl":14400}'
add '{"Type":3,"Name":"_dmarc","Value":"v=DMARC1; p=none;","Ttl":14400}'
add '{"Type":3,"Name":"resend._domainkey","Value":"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCs6urpkVj1+Pl1+eEI4mKmw+yH8IKxgnI6Hy5NTIxhW/tQiV02DwUgmZExzqI+6k1eAwj+UYoOZ+vKlcMk/PoJFiYr2yN8ZSprYw6Q9CsT98uu+CEKjoz5BYYjfDsMC07lKAH+pQAgo/oMtqsX/npkAPFPrlBye14SK0hBPMFdhQIDAQAB","Ttl":14400}'
add '{"Type":3,"Name":"send","Value":"v=spf1 include:amazonses.com ~all","Ttl":14400}'

# --- geo sets for @ and www (SmartRoutingType 2 = geolocation, nearest point wins) ---
MOSCOW=200.165.226.129; VERCEL=216.198.79.1
RU="55.75,37.62 59.93,30.34 54.71,20.51 68.97,33.07 51.67,39.18 47.23,39.70 45.04,38.98 43.60,39.73 48.71,44.51 53.20,50.15 55.79,49.12 54.74,55.97 56.84,60.60 54.99,73.37 55.03,82.92 56.01,92.85 52.29,104.30 52.03,113.50 62.03,129.73 48.48,135.08 43.12,131.89 59.57,150.80 53.02,158.65 69.35,88.20"
WORLD="50.11,8.68 51.51,-0.13 48.86,2.35 40.42,-3.70 52.23,21.01 41.01,28.98 32.09,34.78 25.20,55.27 19.08,72.88 39.90,116.40 35.68,139.69 1.35,103.82 -33.87,151.21 40.71,-74.01 41.88,-87.63 37.77,-122.42 -23.55,-46.63 -26.20,28.05"
for name in "" "www"; do
  for p in $RU;    do add "{\"Type\":0,\"Name\":\"$name\",\"Value\":\"$MOSCOW\",\"Ttl\":300,\"SmartRoutingType\":2,\"GeolocationLatitude\":${p%,*},\"GeolocationLongitude\":${p#*,}}"; done
  for p in $WORLD; do add "{\"Type\":0,\"Name\":\"$name\",\"Value\":\"$VERCEL\",\"Ttl\":300,\"SmartRoutingType\":2,\"GeolocationLatitude\":${p%,*},\"GeolocationLongitude\":${p#*,}}"; done
done
echo done
