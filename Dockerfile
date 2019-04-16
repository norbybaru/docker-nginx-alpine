ARG VERSION
ARG BASE_IMAGE

FROM nginx:${VERSION}-${BASE_IMAGE}

LABEL maintainer="Norby Baruani <norbybaru@gmail.com/>"

RUN apk add --update bash

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data;

RUN cp -a /etc/nginx/conf.d /etc/nginx/.conf.d.orig && \
    rm -f /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf/ /etc/nginx/conf.d/

WORKDIR /var/www/public

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]