#!/bin/bash

region='eu-west-1'
acc_id='361041671631'

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

export $acc_id $region

aws ecr get-login-password > ecr_credentials.txt

cat ecr_credentials.txt | sudo docker login -u AWS --password-stdin https://$acc_id.dkr.ecr.$region.amazonaws.com
 
sudo docker pull $acc_id.dkr.ecr.$region.amazonaws.com/internship2024-wro-aws:latest

sudo docker run -p 8080:80 $acc_id.dkr.ecr.$region.amazonaws.com/internship2024-wro-aws:latest