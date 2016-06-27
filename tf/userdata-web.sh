#!/bin/bash -v
yum install -y nginx 
# some code to configire nginx
cd /var/www/html ;  git clone --depth 1 git@github.com:sergekov/interview-web.git .  && rm -rf .git
systemctl enable nginx
systemctl start nginx
