#!/bin/bash

##############################################
## CLEAN UP BASH SCRIPT
## All this script does is:
## 1) download all rendered frames,
## 2) zip them up
## 3) upload them to s3 so you can just DL one file.
##
## You can copy / paste run this on tiny instance.
## Make sure to edit the config below.
##
##                      - <3 Charles
##                       \\ WONDER UNIT
##############################################

###### UPDATE APT-GET
sudo apt-get update

###### INSTALL AWS CLI & DOWNLOAD BLENDER FILE TO INSTANCE
sudo apt --yes install awscli zip unzip


##############################################
##############################################
## CONFIGURATION
##############################################
##############################################

## AWS BUCKET
AWS_BUCKET=your_bucket_name

##############################################

## AWS BUCKET REGION (https://docs.aws.amazon.com/general/latest/gr/rande.html)
AWS_REGION=us-east-1

##############################################

## GET THE LATEST BLEND FILE ON S3 TO RENDER
BLENDER_FILENAME=`aws s3 ls s3://$AWS_BUCKET | grep -v / | sort | tail -n 1 | awk '{print $4}' | while read spo; do basename -s .blend $spo; done`
## OPTIONAL: USE A SPECIFIC BLEND NAME _____.blend 
# BLENDER_FILENAME=slater

##############################################

mkdir /home/ubuntu/frames
aws s3 sync s3://$AWS_BUCKET/renders/$BLENDER_FILENAME/frames /home/ubuntu/frames --region $AWS_REGION
zip -r -0 /home/ubuntu/frames.zip /home/ubuntu/frames
aws s3 cp /home/ubuntu/frames.zip s3://$AWS_BUCKET/renders/$BLENDER_FILENAME/ --region $AWS_REGION

sudo shutdown now
