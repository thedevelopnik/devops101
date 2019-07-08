FROM alpine:3.10.0

RUN apk add --update nodejs npm

RUN addgroup -S app && \
  adduser -G app -g "App Runner" -s /bin/ash -D app && \
  mkdir /app &&\
  chown app:app /app

WORKDIR /app

COPY package-lock.json package-lock.json
COPY package.json package.json

RUN npm install --production

RUN apk del npm

USER app

COPY src src

CMD node src/index.js
