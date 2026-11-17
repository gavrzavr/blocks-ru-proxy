#!/bin/sh
# 2026-11-17 (Misha): only RUSSIA goes through the Moscow proxy; Ukraine, Kazakhstan, Belarus, the Baltics, the Caucasus,
# Central Asia, Mongolia, China and Finland straight to Vercel. Bunny's geo routing is NEAREST POINT, not country, so the
# border is drawn with points: world points inside the neighbours, Russian points in the Russian border cities beside them.
# Modelled on 105 cities before applying (0 wrong but Narva, Ivangorod's twin town). Adds records only; backup of the zone
# before it: dns/bunny-zone-941695-2026-11-17.json.
set -e
K=$(cat ~/.config/bunny-blocks.key); Z=941695
MOSCOW=200.165.226.129; VERCEL=216.198.79.1
RU="50.6,36.59 51.73,36.19 53.24,34.36 54.78,32.05 57.82,28.33 51.77,55.1 51.53,46.03 46.35,48.04 55.16,61.4 55.44,65.34 57.15,65.53 53.35,83.78 43.02,44.68 42.98,47.5 51.83,107.58 50.27,127.53 52.6,39.57 44.04,43.06 51.23,58.47 56.34,30.52 51.51,81.21 60.71,28.75"
WORLD="50.45,30.52 49.99,36.23 46.48,30.72 49.84,24.03 48.46,35.05 47.84,35.14 48.62,22.3 51.49,31.29 43.24,76.89 51.17,71.45 42.32,69.59 49.8,73.1 50.28,57.17 47.09,51.92 51.23,51.37 49.95,82.61 52.29,76.97 53.21,63.62 54.87,69.15 53.9,27.56 52.44,30.98 55.19,30.2 52.1,23.69 56.95,24.11 54.69,25.28 59.44,24.75 60.17,24.94 41.72,44.79 40.18,44.51 40.41,49.87 41.3,69.24 42.87,74.59 38.56,68.79 37.96,58.33 47.89,106.91 45.8,126.53 43.83,87.62 47.01,28.86 50.91,34.8 43.65,51.17 50.41,80.23 58.38,26.72 61.06,28.19"
add() { curl -s -X PUT "https://api.bunny.net/dnszone/$Z/records" -H "AccessKey: $K" -H "Content-Type: application/json" -d "$1" | grep -o '"Id":[0-9]*' | head -1; }
for name in "" "www"; do
  for p in $RU;    do add "{\"Type\":0,\"Name\":\"$name\",\"Value\":\"$MOSCOW\",\"Ttl\":300,\"SmartRoutingType\":2,\"GeolocationLatitude\":${p%,*},\"GeolocationLongitude\":${p#*,}}"; done
  for p in $WORLD; do add "{\"Type\":0,\"Name\":\"$name\",\"Value\":\"$VERCEL\",\"Ttl\":300,\"SmartRoutingType\":2,\"GeolocationLatitude\":${p%,*},\"GeolocationLongitude\":${p#*,}}"; done
done
echo done
