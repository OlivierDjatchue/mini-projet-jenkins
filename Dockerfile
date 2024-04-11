FROM nginx:latest
COPY . /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
CMD sed -i -e '/$PORT/'"$PORT"'/g' /etc/nginx/conf.de/default.conf && nginx -g daemon off;'

