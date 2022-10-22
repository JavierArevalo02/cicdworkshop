#Multi stage Dockerfile
FROM node:16.17-alpine AS build-env

WORKDIR /app

COPY . .

RUN npm install && npm run build

EXPOSE 3000

CMD npm start
