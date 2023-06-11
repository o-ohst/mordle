FROM node:lts-slim
WORKDIR /app

COPY ["package.json", "package-lock.json", "."]
RUN npm ci --omit=dev

COPY . .

ARG REACT_APP_SERVER_HOSTNAME
ENV REACT_APP_SERVER_HOSTNAME=$REACT_APP_SERVER_HOSTNAME

RUN npm run build
RUN npm install -g serve

EXPOSE 3000

ENTRYPOINT ["serve", "build"]