#First container step: Build our Angular application based on a NodeJS official image
#Building from a nodejs base image
FROM node:6 as node

#Retrieving arguments such as SSH key and Git repository
ARG gitrepourl=https://github.com/breowicz/dockertest.git
ARG branch=master
#ARG env=prod

#Copying private key to local cert repository
COPY ./id_rsa /etc/.ssh/id_rsa

#Applying appropriate permissions since files created from Windows come in completely open permission wise
RUN chmod 700 /etc/.ssh/id_rsa

#Setting the appropriate application directory
WORKDIR /source

#Retrieve source code
RUN eval $(ssh-agent -s) && ssh-add /etc/.ssh/id_rsa && git clone --branch $branch $gitrepourl /source

#Reconcile all NPM packages
RUN npm install

#Build the application
RUN npm run ng -- build --prod --build-optimizer

#Second container step: Expose our application based on an official NGINX image
FROM nginx

#Copy all compiled files over to the NGINX share area
COPY --from=node /source/dist/ /usr/share/nginx/html

#Copy the customized NGINX configuration to the NGINX configuration area
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf	