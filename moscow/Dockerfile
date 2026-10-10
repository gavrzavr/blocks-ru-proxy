FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY test.html /srv/test.html
# 300 KB payload served locally: tells a 16 KB cut-off apart from an upstream problem.
RUN head -c 300000 /dev/zero | tr '\0' 'a' > /srv/big.txt
EXPOSE 80
