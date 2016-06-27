#!/bin/bash -v
yum install -y jetty-server
cd /var/jetty ;  git clone --depth 1 git@github.com:sergekov/interview-app.git .  && rm -rf .git
systemctl enable jetty-server
systemctl start jetty-server
