# Assignment 7

Harshila Jagtap
NEU ID : 002743674

# Setup Virtual Private Network using terraforms

1. Create Virtual Private Cloud (VPC)
2. Create subnets in the above VPC. 3 public subnets and 3 private subnets, each in a different availability zone in the same region in the same VPC.
3. Create an Internet Gateway resource and attach the Internet Gateway to the VPC.
4. Create a public route table. Attach all public subnets created to the route table.
5. Create a private route table. Attach all private subnets created to the route table.
6. Create a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target.

# Setup Security Group using terraforms

1. Create an EC2 security group for EC2 instances that will host web applications.
2. Add ingress rule to allow TCP traffic on ports 22, 80, 443, and port on which your application runs.
3. Name of the security group is "application".

# Setup EC2 instance using using terraforms with below specifications

1. AMI : Custom AMI provisioned by dev account
2. Instance Type : t2.micro
3. Protect against accidental termination : No
4. Root Volume Size : 50
5. Root Volume Type : General Purpose SSD (GP2)
6. Security Group created above by terraform
7. VPC created above by terraform

# DB Security Group

1 . Create an EC2 security group for your RDS instances.

2. Add ingress rule to allow TCP traffic on the port 3306 for MySQL

3. The Source of the traffic should be the application security group. 

4. Restrict access to the instance from the internet.
This security group will be referred to as the database security group.


S3 Bucket 

1. Private random generated S3 Bucket

2. Make sure Terraform can delete the bucket even if it is not empty.

3. To delete all objects from the bucket manually use the CLI before you delete the bucket you can use the following AWS CLI command that may work for removing all objects from the bucket. aws s3 rm s3://bucket-name --recursive. 
4. Enable default encryption for S3 BucketsLinks to an external site..
Create a lifecycle policy for the bucket to transition objects from STANDARD storage class to STANDARD_IA storage class after 30 days.

RDS Instance
WARNING: Setting Public accessibility to true will expose your instance to the internet.

Your RDS instance should be created with the following configuration. You may use default values/settings for any property not mentioned below.

Property	Value
Database Engine	MySQL/PostgreSQL
DB Instance Class	db.t3.micro
Multi-AZ deployment	No
DB instance identifier	csye6225
Master username	csye6225
Master password	pick a strong password
Subnet group	Private subnet for RDS instances
Public accessibility	No
Database name	csye6225
Database security group should be attached to this RDS instance.


Created Route53 using the Terraform template.
The Terraform template  add/update A record to the Route53 zone so that the domain points to the EC2 instance and the web application is accessible


Added CloudWatch Logs resources to monitor logs and metrics.

# Autorun has been setup using Systemd

reboot the instance and check again

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

aws configure --profile demo

# Create Resources commands

1. terraform init 

2. terraform plan 

3. terraform apply --auto-approve

4. terraform destroy --auto-approve
