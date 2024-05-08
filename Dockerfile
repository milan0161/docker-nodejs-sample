FROM node:18.10.0 as dev

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run prettify

FROM node:18.10.0-alpine as prod

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --only=production

COPY --from=dev /usr/src/app/src ./src
COPY --from=dev /usr/src/app/.env ./

EXPOSE 3000

CMD ["node","src/index.js"]