FROM node:18-alpine
WORKDIR /app
COPY app.js .
RUN npm init -y && npm install express
EXPOSE 80
CMD ["node", "app.js"]
