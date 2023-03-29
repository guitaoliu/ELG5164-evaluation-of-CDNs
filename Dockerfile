FROM nginx:1.23.2-alpine

COPY /app/.vitepress/dist /usr/share/nginx/html

RUN touch /var/run/nginx.pid
RUN chown -R nginx:nginx /var/run/nginx.pid /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

USER nginx
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
