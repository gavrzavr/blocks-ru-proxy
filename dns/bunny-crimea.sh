#!/bin/sh
# 2026-11-17 (Misha): Crimea through Moscow too, the rest as bunny-countries.sh drew it. Crimean towns + Donetsk, Mariupol,
# Luhansk held on Moscow (a Crimea point alone pulled them); the Kherson region, Berdyansk and Kramatorsk / Sloviansk /
# Pokrovsk kept on Vercel. Modelled before applying; adds records only.
set -e
K=$(cat ~/.config/bunny-blocks.key); Z=941695
MOSCOW=200.165.226.129; VERCEL=216.198.79.1
RU="44.95,34.1 44.62,33.53 45.36,36.47 45.19,33.37 45.03,35.38 45.71,34.39 44.5,34.17 46.11,33.69 47.1,37.55 48.0,37.8 48.57,39.31"
WORLD="46.12,32.91 46.75,33.37 46.17,34.8 46.76,36.79 48.74,37.58 48.85,37.61 48.29,37.18"
add() { curl -s -X PUT "https://api.bunny.net/dnszone/$Z/records" -H "AccessKey: $K" -H "Content-Type: application/json" -d "$1" | grep -o '"Id":[0-9]*' | head -1; }
for name in "" "www"; do
  for p in $RU;    do add "{\"Type\":0,\"Name\":\"$name\",\"Value\":\"$MOSCOW\",\"Ttl\":300,\"SmartRoutingType\":2,\"GeolocationLatitude\":${p%,*},\"GeolocationLongitude\":${p#*,}}"; done
  for p in $WORLD; do add "{\"Type\":0,\"Name\":\"$name\",\"Value\":\"$VERCEL\",\"Ttl\":300,\"SmartRoutingType\":2,\"GeolocationLatitude\":${p%,*},\"GeolocationLongitude\":${p#*,}}"; done
done
