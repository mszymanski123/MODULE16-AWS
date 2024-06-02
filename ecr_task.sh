#!/bin/bash

region="eu-west-1"
vpc_cidr="10.1.0.0/16"
subnet_cidr="10.1.0.0/24"
instance_type="t2.micro"
ami_id="ami-01dd271720c1ba44f"
key_name="internship2024-wro-aws"
acc_id='361041671631'

vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query 'Vpc.{VpcId:VpcId}' --output text --region $region --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=internship2024wro},{Key=Owner,Value=mszymanski},{Key=Project,Value=mszymanski-internship2024-wro}]')

subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr --query 'Subnet.{SubnetId:SubnetId}' --output text --region $region --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=internship2024wro},{Key=Owner,Value=mszymanski},{Key=Project,Value=mszymanski-internship2024-wro}]')

aws ec2 modify-subnet-attribute --subnet-id $subnet_id --map-public-ip-on-launch --region $region

aws ecr create-repository --repository-name 'internship2024-wro-aws' --region $region

sg_id=$(aws ec2 create-security-group --group-name 'internship2024-wro-aws' --vpc-id $vpc_id --output text --region $region)

aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region

instance_id=$(aws ec2 run-instances --image-id $ami_id --instance-type $instance_type --key-name $key_name --subnet-id $subnet_id --security-group-ids $sg_id --associate-public-ip-address --query 'Instances[0].InstanceId' --output text --region $region --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=internship2024wro},{Key=Owner,Value=mszymanski},{Key=Project,Value=mszymanski-internship2024-wro}]')

aws ec2 wait instance-running --instance-ids $instance_id --region $region

public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region $region)

aws ecr get-login-password --region $region > ecr_credentials.txt

docker login -u AWS https://$acc_id.dkr.ecr.$region.amazonaws.com --password-stdin $(cat ecr_credentials.txt)

docker pull mszymanski/spring-petclinic:latest

docker build -t mszymanski/spring-petclinic:latest $acc_id.dkr.ecr.$region.amazonaws.com/internship2024-wro-aws:latest

docker push $acc_id.dkr.ecr.$region.amazonaws.com/internship2024-wro-aws:latest