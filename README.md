# Assignment 3

Harshila Jagtap
NEU ID : 002743674

# Setup Virtual Private Network using terraforms

Scope --->


1. Create Virtual Private Cloud (VPC)
2. Create subnets in the above VPC. 3 public subnets and 3 private subnets, each in a different availability zone in the same region in the same VPC.
3. Create an Internet Gateway resource and attach the Internet Gateway to the VPC.
4. Create a public route table. Attach all public subnets created to the route table.
5. Create a private route table. Attach all private subnets created to the route table.
6. Create a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target.

# Pre-requisite Installed : 

AWS CLI >= 3.15
Terraform >= 0.12.26
Visual Studio Code

# Providers

aws >= 3.15

# Clone Instructions :

1. Make a directory : 
mkdir vpc

2. cd vpc

3. git clone git@github.com:NEU-Cloud-Harshila/aws-infra.git

------

Login to the respective root AWS account.

1. Create a IAM User with AdministatorAccess.

2. Create Access Key and Secret Key

Point 1 and 2 are needed as pre-requisuite to configure the aws cli

Configure the AWS account in the required region closer to the user for specific account profile like 'dev' or 'demo'

Use command : 

aws configure



# Create Resources commands

1. terraform init 

2. terraform plan 

3. terraform apply --auto-approve

4. terraform destroy --auto-approve
