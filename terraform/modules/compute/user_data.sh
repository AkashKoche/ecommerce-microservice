#!/bin/bash

yum update -y
yum install -y docker git
service docker start
usermod -a -G docker ec2-user


AWS_REGION="${AWS_REGION}"
ECR_REGISTRY="${ECR_REGISTRY}"


aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}


git clone https://github.com/AkashKoche/ecommerce-microservice.git /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/app

cd /home/ec2-user/app


/usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d
