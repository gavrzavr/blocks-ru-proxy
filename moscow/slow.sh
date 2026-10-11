#!/bin/sh
# Slowest requests and per-hop averages from the Moscow nginx log. Usage: slow.sh [lines]
N=${1:-5000}
tail -n "$N" /var/log/nginx/access.log | grep ' rt=' | awk '
  { for (i=1;i<=NF;i++) { split($i,kv,"="); v[kv[1]]=kv[2] }
    rt=v["rt"]+0; n++; s+=rt; if (v["cache"]=="HIT") hit++
    if (v["uh"]!="-" && v["uh"]!="") { up++; su+=v["uh"]; }
    if (v["vercel"]!="-" && v["vercel"]!="") { vc++; sv+=v["vercel"]; }
    print rt, $3, $4, "conn="v["uc"], "ams="v["uh"], "vercel="v["vercel"], v["cache"] > "/tmp/slow.rows" }
  END { printf "requests %d, avg %.3fs, cache hits %d, avg ams %.3fs (n=%d), avg vercel %.3fs (n=%d)\n", n, n?s/n:0, hit, up?su/up:0, up, vc?sv/vc:0, vc }'
echo "--- slowest 15"; sort -rn /tmp/slow.rows | head -15
