#!/bin/bash
set -e

java_version=$1
repo_url=$2
shutdown_threshold=$3

#system update
sudo apt update -y
sudo apt install -y openjdk-${java_version}-jdk git

# Cloning repo
git clone ${repo_url}
REPO_NAME=$(basename -s .git ${repo_url})
cd $REPO_NAME

# chmod mvnw
chmod +x mvnw

# Build 
./mvnw clean package

# Find the built JAR and run it (Spring Boot default target)
JAR_FILE=$(find target -type f -name "*.jar" | head -n 1)
nohup java -jar $JAR_FILE --server.port=8080 > app.log 2>&1 &

sudo shutdown -h +${shutdown_threshold}