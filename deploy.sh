#!/bin/bash

CURRENT=`pwd`
cd $(dirname $0)

if [ $# != 3 ] ; then
   echo Error ! $0 app.jar config_dir name
   echo PORT in yml/properties file to config AND SPRING_PROFILES_ACTIVE=online
   exit 1;
fi

DOCKER_NAME=$3
TAG_NAME=`date +%s`

set -e -x

TMP="/tmp/docker-template/"
rm -rf $TMP
mkdir $TMP

cp $CURRENT/$1 "$TMP/app.jar"
cp -r $CURRENT/$2 "$TMP/config/"
cp Dockerfile "$TMP/Dockerfile"

cd $TMP

sudo /usr/bin/docker build . -t $DOCKER_NAME:$TAG_NAME --build-arg JAR=app.jar
sudo /usr/bin/docker tag $DOCKER_NAME:$TAG_NAME $DOCKER_NAME:latest

sudo /usr/bin/docker ps|grep $DOCKER_NAME && sudo /usr/bin/docker stop $DOCKER_NAME
sudo /usr/bin/docker ps -a|grep $DOCKER_NAME && sudo /usr/bin/docker rm $DOCKER_NAME
sudo /usr/bin/docker run -d --net host --restart always --name $DOCKER_NAME -v /var/log/:/var/log/ $DOCKER_NAME:$TAG_NAME

rm -rf $TMP
