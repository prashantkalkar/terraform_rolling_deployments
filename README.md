# terraform_rolling_deployments
Terraform script to implement rolling deployment for Autoscaling group and ELB

#### Nginx AMI

Ami folder contains the packer configuration to create the nginx AMI. Use following command to create the AMI
(Use default if you are just using the default profile)
```shell script
packer build -var aws_profile=<name_of_your_aws_profile> nginx.json
```
#### Use the AMI in the Terraform code.

Update the terraform launch configuration to include the AMI Id created with above packer command.

#### Create the infrastructure with Terraform for the first time

```shell script
terraform plan -out tfplan

terraform apply tfplan
```  

#### Simulate new application version release

Create a new AMI to represent new version of the application. 

```shell script
packer build -var aws_profile=<name_of_your_aws_profile> nginx.json
```
Update terraform with new AMI just created.

Execute terraform plan

```shell script
terraform plan -out tfplan
```
This will offer the changes that will perform the rolling deployment. 

Apply the changes to see the rolling deployment in action

```shell script
terraform apply tfplan
```