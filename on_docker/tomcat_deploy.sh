#!/bin/bash
#
# test ansible configuration in docker container
# mention environnment type in 1rst argument
# mention distribution name in 2nd argument

export ENVIRONMENT=$1
export distribution=$1

usage() {
    echo "Usage:  $0 <ENVIRONMENT>"
    exit 1
}

if [ $# -ne 2 ]
then
    usage
fi

echo ""
echo "build docker image"
echo "---------------------------------"
sudo docker build -t myapp .
echo ""

echo ""
echo "launch container"
echo "---------------------------------"
sudo docker run --name myapp_container --rm -dt -p 8080:80/tcp --privileged=true -v ${PWD}:/data myapp
echo ""

echo ""
echo "retrieve host distribution name"
echo "---------------------------------"
sudo docker exec -it myapp_container cat /etc/*release | grep ^ID* | cut -d= -f2 | xargs
echo ""

if [ $distribution == "redhat" ]
then
    echo ""
    echo "update repo in docker container"
    echo "---------------------------------"
    #docker exec -it myapp_container python --version 
    sudo docker exec -it myapp_container yum update -y
    sudo docker exec -it myapp_container ip link
    echo ""

    echo ""
    echo "install curl ansible in docker container"
    echo "---------------------------------"
    sudo docker exec -it myapp_container yum install -y epel-release
    sudo docker exec -it myapp_container yum install -y curl ansible
    sudo docker exec -it myapp_container ansible-galaxy collection install ansible.posix
    echo ""
elif [ $distribution == "debian" ]
then
    echo ""
    echo "update repo in docker container"
    echo "---------------------------------"
    sudo docker exec -it myapp_container apt-get -y update
    echo ""

    echo ""
    echo "install curl ansible in docker container"
    echo "---------------------------------"
    sudo docker exec -it myapp_container apt-get install --fix-missing -y curl ansible
    echo ""
fi

echo ""
echo "execute tomcat_test.sh in docker container"
echo "---------------------------------"
sudo docker exec -it myapp_container /bin/bash data/tomcat_test.sh ${ENVIRONMENT}
echo ""
