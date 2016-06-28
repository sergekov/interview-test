#!/bin/bash -v
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
sudo yum update -y
sudo yum install -y nginx git
# some code to configire nginx
mkdir -p /usr/share/nginx/html/interview-test ;  cd /usr/share/nginx/html/interview-test ; sudo  git clone --depth 1 https://github.com/sergekov/interview-web.git .  && rm -rf .git
chkconfig nginx on
service nginx start
#systemctl enable nginx
#systemctl start nginx
