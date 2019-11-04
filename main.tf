terraform {
  required_version = "0.12.9"

// Use backend in your projects.
//  backend "s3" {
//    bucket = "your_bucket_name_to_store_state"
//    key    = "path_to_state_file"
//    region = "us-east-1"
//    encrypt = true
//    dynamodb_table = "dynamo_lock_table"
//  }
}

provider "aws" {
  profile = "personal"
  region = "us-east-1"
  version = "~> 2.33"
}

resource "aws_launch_configuration" "rolling_deployment_launch_config" {
  name_prefix = "rolling_deployment_lc_"
  // Sample ami with nginx running on it.
  image_id = "ami-00e58f8044c7f8ad1" // TODO - Create AMI.
  instance_type = "t3.nano"

  security_groups = [aws_security_group.rolling_deployment_instance_sg.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "rolling_deployment_asg" {
  name_prefix          = "rolling_deployment_asg_"
  launch_configuration = aws_launch_configuration.rolling_deployment_launch_config.name
  load_balancers = [aws_elb.rolling_deployment_elb.name]

  // Generally equal to availability zones available in the region
  min_size             = 3
  max_size             = 3

  // ELB health check should mark the instance as healthy before this time.
  health_check_grace_period = 300
  health_check_type         = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_elb" "rolling_deployment_elb" {
  name               = "rolling-deployment-elb"
  availability_zones = data.aws_availability_zones.zones.names
  security_groups = [aws_security_group.rolling_deployment_elb_sg.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 30
  }

  connection_draining         = true
  connection_draining_timeout = 300
}
