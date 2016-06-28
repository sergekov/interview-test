#!/bin/bash -v
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
yum install -q -y java-1.8.0-openjdk git
yum update  -q -y
cd /usr/local && wget -c http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.3.10.v20160621/jetty-distribution-9.3.10.v20160621.tar.gz && tar -zxvf jetty-distribution-9.3.10.v20160621.tar.gz &&  mkdir jetty && mv jetty-dist*/* jetty/ && rm -rf jetty-distribution-*
echo "export JETTY_HOME=/usr/local/jetty" >> /etc/profile.d/custom.sh
echo "export JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64" >> /etc/profile.d/custom.sh
. /etc/profile.d/custom.sh
mkdir /usr/local/jetty/webapp && cd /usr/local/jetty/webapp && git clone --depth 1 https://github.com/sergekov/interview-app.git .  && rm -rf .git
$JETTY_HOME/bin/jetty.sh run 
