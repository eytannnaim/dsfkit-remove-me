# # aws ec2 create-volume --volume-type gp2 --size 8500 --availability-zone eu-west-2a --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=hadr}]' --region eu-west-2 --output text --query 'VolumeId'
aws autoscaling create-launch-configuration \
    --launch-configuration-name my-lc \
    --image-id ami-03a6c38b3c0aa74f9 \
    --instance-type m5.large \
    --block-device-mappings '[{"DeviceName":"/dev/sdh","Ebs":{"SnapshotId":"snap-0d33f992350ad77a9"}}]' --region eu-west-2 

aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-asg \
    --launch-configuration-name my-lc \
    --min-size 1 \
    --max-size 5 \
     --region eu-west-2 \
     --vpc-zone-identifier "subnet-bf83f1c5"