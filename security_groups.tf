resource "aws_security_group" "rolling_deployment_instance_sg" {
  name = "rolling_deployment_instance_sg"
}

resource "aws_security_group_rule" "allow_http_traffic_from_elb" {
  security_group_id = aws_security_group.rolling_deployment_instance_sg.id
  from_port = 80
  protocol = "http"
  to_port = 80
  type = "ingress"
  source_security_group_id = aws_security_group.rolling_deployment_elb_sg.id
}

resource "aws_security_group_rule" "allow_outgoing_traffic_from_instance" {
  security_group_id = aws_security_group.rolling_deployment_instance_sg.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "rolling_deployment_elb_sg" {
  name = "rolling_deployment_elb_sg"
}

resource "aws_security_group_rule" "allow_http_traffic" {
  security_group_id = aws_security_group.rolling_deployment_elb_sg.id
  from_port = 80
  protocol = "http"
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_outgoing_traffic_from_elb" {
  security_group_id = aws_security_group.rolling_deployment_elb_sg.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}