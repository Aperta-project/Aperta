FROM phusion/passenger-customizable:0.9.14

MAINTAINER Tahi Project Team <tahiprojectteam@plos.org>
# VERSION 0.0.1

# Install git and build tools
RUN /build/utilities.sh
# Install Ruby
RUN /build/ruby2.1.sh
# Install Node
RUN /build/nodejs.sh

# enable nginx
RUN      rm -f /etc/service/nginx/down
RUN      rm /etc/nginx/sites-enabled/default

# nginx config
ADD      nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD      nginx-env.conf /etc/nginx/main.d/nginx-env.conf

# Clean up APT when done
RUN     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add all files from the project directory to the container
RUN     su app -c "cd /home/app && git clone https://github.com/tahi-project/ihat.git"

WORKDIR /home/app/ihat
RUN sudo -u app -H bundle install --deployment --without test

# install our startup
COPY     rc.local /etc/rc.local
RUN      chmod u+x /etc/rc.local
