# blocks-ru-proxy

nginx в Москве (Timeweb App Platform) перед Vercel: из РФ blocks.zone открывается без VPN.
Приложение получает `Host: blocks.zone`, поэтому вход, OAuth-колбэки и редиректы не меняются.

## Деплой
1. Timeweb → App Platform → Добавить → Docker Hub (образ) или Приложение (этот репозиторий, Dockerfile).
   Москва, 1 CPU / 1 ГБ.
2. Проверка по техническому домену: `https://<app>.twc1.net/__proxy_health` → `ok`, затем `/`.
3. В настройках приложения добавить домены `blocks.zone` и `www.blocks.zone` (SSL Let's Encrypt).
4. Squarespace DNS: A `@` и `www` → IP приложения Timeweb (вместо Vercel).
   Откат: вернуть A `@` → 216.198.79.1, `www` → CNAME Vercel.

## Что знать
- Vercel будет показывать «Invalid Configuration» у blocks.zone — это ок, домен остаётся привязан к проекту.
- Аналитика страны (`x-vercel-ip-country`) у всех станет RU: Vercel видит только IP прокси.
