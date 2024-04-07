variable "objects" {
  type = map(string)
}

# Create a VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text

# Add a tag to the VPC
aws ec2 create-tags --resources vpc-0f3feedb2b7452c52 --tags Key=Name,Value=CBTVPC --output text

aws ec2 modify-vpc-attribute --vpc-id vpc-0f3feedb2b7452c52 --enable-dns-hostnames '{"Value":true}'

aws ec2 create-subnet --vpc-id vpc-0f3feedb2b7452c52 --cidr-block 10.0.1.0/24 --output text

aws ec2 create-tags --resources subnet-0478960f44954c740   --tags Key=Name,Value=MyPublicSubnet --output text

# Create an Internet Gateway
aws ec2 create-internet-gateway --output text

# Add a tag to the Internet Gateway
aws ec2 create-tags --resources igw-089922953fb7ae8b7  --tags Key=Name,Value=MyInternetGateway --output text

aws ec2 attach-internet-gateway --internet-gateway-id igw-089922953fb7ae8b7 --vpc-id vpc-0f3feedb2b7452c52 --output text

aws ec2 create-route-table --vpc-id vpc-0f3feedb2b7452c52 --output text

aws ec2 create-tags --resources rtb-0aa319aba447b3fe0  --tags Key=Name,Value=PublicRouteTable --output text

aws ec2 create-route --route-table-id rtb-0aa319aba447b3fe0  --destination-cidr-block 0.0.0.0/0 --gateway-id igw-089922953fb7ae8b7 --output text

aws ec2 associate-route-table --route-table-id rtb-0aa319aba447b3fe0 --subnet-id subnet-0478960f44954c740 --output text

aws ec2 create-security-group --group-name KuleSecurityGroup --description "My security group" --vpc-id vpc-0f3feedb2b7452c52 --output text

aws ec2 create-tags --resources sg-09e23467075b71bc6 --tags Key=Name,Value=MySecurityGroup --output text

aws ec2 authorize-security-group-ingress --group-id sg-09e23467075b71bc6 --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-id sg-09e23467075b71bc6 --protocol tcp --port 80 --cidr 0.0.0.0/0 --output text

aws ec2 run-instances --image-id ami-0900fe555666598a2 --count 1 --instance-type t2.micro --key-name us-east-2-key2 --security-group-ids sg-09e23467075b71bc6  --subnet-id subnet-0478960f44954c740 --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=instance-public-a}]' --user-data file://user-data-script.sh

#Obtain Public DNS
aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicDnsName" 
http://ec2-3-22-77-79.us-east-2.compute.amazonaws.com
 
Troubleshooting
#Next ssh into the instance
ssh -i "secure.pem" ec2-34-241-207-140.eu-west-1.compute.amazonaws.com
# Generate Locale (Optional):
sudo localedef -i en_US -f UTF-8 en_US.UTF-8
Sudo Commands
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd

#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
# Fetch and store metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
MAC_ADDRESS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/mac)
VPC_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC_ADDRESS/vpc-id)
# Generate the HTML content
cat <<EOF > /var/www/html/index.html
<!doctype html>
<html lang="en" class="h-100">
<head>
<title>EC2 Instance Details</title>
</head>
<body>
<div>
<h1>Instance Details</h1>
<p><strong>Instance Name:</strong> $(hostname -f)</p>
<p><strong>Instance Private IP Address:</strong> $LOCAL_IPV4</p>
<p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
<p><strong>Virtual Private Cloud (VPC):</strong> $VPC_ID</p>
</div>
</body>
</html>
EOF

