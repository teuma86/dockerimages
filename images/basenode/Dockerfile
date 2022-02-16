ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN apk add --no-cache --virtual .build-deps ca-certificates wget python make g++ \
  && apk add --no-cache git \
  && apk del .build-deps

COPY ./cmds/ /usr/local/bin/