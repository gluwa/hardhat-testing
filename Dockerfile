FROM node:12

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# Bundle app source
COPY . .
RUN chmod +x /usr/src/app/entrypoint.sh

EXPOSE 8545

RUN yarn install
RUN yarn compile

CMD ["/bin/sh", "/usr/src/app/entrypoint.sh"]