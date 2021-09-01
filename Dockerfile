
FROM    python:3.9 as builder

WORKDIR balzac-doc
COPY    source source
COPY    lexers lexers
COPY    Makefile Makefile
RUN     pip install sphinx pygments sphinxcontrib-inlinesyntaxhighlight
RUN     make full-build


FROM    nginx:1.21.1

COPY    --from=builder /balzac-doc/build/html/ /usr/share/nginx/html/
RUN     ls -lh /usr/share/nginx/html
RUN     ls -lh /usr/share/nginx/html


EXPOSE  80
MAINTAINER atzeinicola@gmail.com
