FROM node:lts-slim
WORKDIR /app

COPY package*.json .
RUN npm ci --omit=dev

COPY . .

RUN npm run build
RUN npm install -g serve

EXPOSE 3000

ENV NODE_ENV production

ENTRYPOINT ["serve", "build"]