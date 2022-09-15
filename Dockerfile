FROM    nginx:1.21.1

ARG     html

ENV     HTML=${html:-build/html/}

COPY    $HTML /usr/share/nginx/html/

EXPOSE  80
MAINTAINER atzeinicola@gmail.com
