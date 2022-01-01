#!/bin/bash
#
# test ansible configuration in docker container

echo ""
echo "build docker image"
echo "---------------------------------"
docker build -t myapp .
echo ""

echo ""
echo "launch container"
echo "---------------------------------"
docker run --name myapp_container --rm -dt --privileged=true -v ${PWD}:/data myapp /usr/sbin/init
echo ""

echo ""
echo "update repo in docker container"
echo "---------------------------------"
#docker exec -it myapp_container ansible --version 
#docker exec -it myapp_container python --version 
docker exec -it myapp_container yum update -y
echo ""

echo ""
echo "install curl ansible in docker container"
echo "---------------------------------"
docker exec -it myapp_container yum install -y epel-release
docker exec -it myapp_container yum install -y curl ansible
echo ""

echo ""
echo "execute tomcat_test.sh in docker container"
echo "---------------------------------"
docker exec -it myapp_container /bin/bash data/tomcat_test.sh DEV
echo ""
