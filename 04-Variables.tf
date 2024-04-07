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
