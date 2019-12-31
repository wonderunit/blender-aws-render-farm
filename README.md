# blender-aws-render-farm

These are simple instructions and a couple scripts to set up a AWS EC2/S3 Blender Render Farm.

The benefits of rendering through AWS is that it is nearly infinitely scalable and the rates are better than any render farm I've seen.

I built this because I needed to render a 400 frames and on my Mac Pro with 24 cores, each frame was taking 14 minutes. That is 93 hours (almost 4 days) of render time!!! When I use my Blender-AWS-Render-Farm, I spin up 96 core instances for roughly $1/hour. Each instance can render a frame in 3.5 minutes. That means one instance can render the frames in 24 hours. So if you spawn up 24 instances, the sequence will be done in 1 hour. 93 times faster for $24. 

If you set everything up nicely, you just upload your .blend file to your specified S3 bucket and create a spot instance fleet of EC2 servers, as many as you want. It will automatically render that .blend file and save all the frames to S3. You can run a follow up script on a tiny instance to create a zip of all your rendered frames so you can easily download it.

The downside: You have to have to know how AWS works or be willing to figure it out. The upside: You're not a dummy and I have faith in you.

# How it works

You create a spot instance fleet that runs a configured script that downloads all the stuff needed to render. It automatically gets the latest .blend file on the S3 bucket and starts rendering it. The rendered frames are automatically saved to S3 so if an instance stops, it doesn't matter, you still have the frames! Also in your blender file, you have to set the render outputs to: [ ] Overwrite AND [X] Use Placeholders. This means that other instances will know when instances are rendering and it will not overwrite other frames. When it's done, the instances will shut themselves down, and you can run the cleanup script to generate a zip file and download it.

There's another project called Brenda https://github.com/gwhobbs/brenda which is a way more complicated but customizable version of this. It appears to be abandoned by the orginal author. I wanted to make something that was super simple at its core: 1 bash script. If something stops working, it's easy to figure out!

# Setting up AWS Account

Create a bucket
Create security user
Create IAM role
Create S3 full access
Create an Instance Template

# Preparing your Blend File

# Starting an instance fleet

# Checking it 

Terminal 
S3

# Starting over

# MAKE SURE YOUR INSTANCES ARE STOPPED WHEN YOU ARE DONE!

If you don't cancel, you could get a bill for a lot!
