FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Cloud Run requires port 8080
ENV PORT=8080

EXPOSE 8080

CMD ["npm", "start"]
