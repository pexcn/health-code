#
# Dockerfile for health-code
#

FROM node:19-alpine as builder

#
# Build stage
#
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make \
  && git clone https://codeberg.org/ilovexjp/health-code-simulator.git \
  && cd health-code-simulator \
  && npm i -g uglify-js clean-css-cli html-minifier sass \
  && make build \
  && cp -r build /srv/health-code \
  && cd - \
  && rm -r health-code-simulator \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM nginx:1.22.1-alpine

COPY --from=builder /srv/health-code /srv/health-code
COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
