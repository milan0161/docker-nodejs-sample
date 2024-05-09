FROM node:18.10.0 as dev

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY . .

CMD [ "npm", "run", "dev" ]

FROM node:18.10.0-alpine as prod

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --only=production

COPY --from=dev /usr/src/app/src ./src

CMD ["node","src/index.js"]