#!/bin/bash

###### UPDATE APT-GET
sudo apt-get update

###### INSTALL AWS CLI & DOWNLOAD BLENDER FILE TO INSTANCE
sudo apt --yes install awscli

## Blender file inside of S3
## GET THE LATEST BLEND FILE ON S3 TO RENDER
BLENDER_FILENAME=`aws s3 ls s3://blenderrender.wonderunit.com | grep -v / | sort | tail -n 1 | awk '{print $4}' | while read spo; do basename -s .blend $spo; done`

##############################################
##############################################
## CONFIGURATION
##############################################

##############################################
## AWS BUCKET
AWS_BUCKET=your_bucket_name_here

##############################################
## AWS BUCKET REGION (https://docs.aws.amazon.com/general/latest/gr/rande.html)
AWS_REGION=us-east-1

##############################################
## AWS USER ID
AWS_USER_ID=X123UNH4567XM7NPSR5

##############################################
## AWS SECRET KEY
AWS_SECRET_KEY=DfgsgS0+948fGshfbIkvXTSzq9gK+ks8V6fv

##############################################
## BLENDER LINUX VERSION DL URL
BLENDER_DL_URL=https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81a-linux-glibc217-x86_64.tar.bz2
BLENDER_FOLDER=blender-2.81a-linux-glibc217-x86_64

##############################################
## OR USE A SPECIFIC BLEND NAME _____.blend (OPTIONAL)
# BLENDER_FILENAME=slater

##############################################

###### DOWNLOAD BLEND FILE FOR RENDERERERRING
aws s3 cp s3://$AWS_BUCKET/$BLENDER_FILENAME.blend /home/ubuntu/ --region $AWS_REGION

###### DOWNLOAD BLENDER AND UNZIP THAT SHIT
curl -o blender.tar.bz2 $BLENDER_DL_URL
tar xvjf blender.tar.bz2
sudo apt-get --yes install libglu1 libxi6 libgconf-2-4 libfontconfig1 libxrender1

###### INSTALL S3FS
sudo apt-get --yes install build-essential libxml2-dev libfuse-dev libcurl4-openssl-dev libssl-dev pkg-config autotools-dev automake
git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure
make
sudo make install

###### SETUP S3FS
AWS_USER_ID=$AWS_USER_ID AWS_SECRET_KEY=$AWS_SECRET_KEY runuser ubuntu -c 'echo $AWS_USER_ID:$AWS_SECRET_KEY > /home/ubuntu/.passwd-s3fs'
runuser ubuntu -c 'chmod 600 /home/ubuntu/.passwd-s3fs'
runuser ubuntu -c 'mkdir /home/ubuntu/blenderrender'
runuser ubuntu -c 'chmod 777 /home/ubuntu/blenderrender'
AWS_BUCKET=$AWS_BUCKET runuser ubuntu -c 's3fs $AWS_BUCKET /home/ubuntu/blenderrender -o passwd_file=/home/ubuntu/.passwd-s3fs -o use_path_request_style'

# EVERY 8 MINUTES, DELETE RENDERS THAT ARE 0 BYTES AND OVER 10 MINUTES OLD (This cleans up ghost instances)
crontab -l | { cat; echo "*/8 * * * * find /home/ubuntu/blenderrender/renders/$BLENDER_FILENAME/frames -name '*' -size 0 -mmin +10 -print0 | xargs -0 rm"; } | crontab -

###### RUN BLENDER AND RENDER THAT POOP
## -s 0 -e 20 for specific frames
BLENDER_FOLDER=$BLENDER_FOLDER BLENDER_FILENAME=$BLENDER_FILENAME runuser ubuntu -c '/$BLENDER_FOLDER/blender -b /home/ubuntu/$BLENDER_FILENAME.blend -o /home/ubuntu/blenderrender/renders/$BLENDER_FILENAME/frames/##### -E CYCLES -a'

###### WE'RE DONE LET'S SHUT DOWN AND SAVE THAT DOSH
sudo shutdown now
