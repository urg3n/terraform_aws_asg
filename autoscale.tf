variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "us-east-1"
}

resource "aws_autoscaling_group" "ASG-urgen" {
    availability_zones = ["us-east-1c"]
    name = "ASG-urgen"
    max_size = "8"
    min_size = "2"
    health_check_grace_period = 600
    desired_capacity = 2
    force_delete = true
    launch_configuration = "${aws_launch_configuration.TFLC.name}"
    load_balancers = ["${aws_elb.ELB-Terraform.name}"]
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "ec2-auto-scale-terraform"
        propagate_at_launch = true
    }
}

resource "aws_launch_configuration" "TFLC" {
    name_prefix = "TFLC"
    image_id = "ami-9c1bbb8a"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.ELB-Terraform-SG.id}"]
    user_data = "${file("userdata.sh")}"

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "10"
    }
}
########### ELB #####################
resource "aws_elb" "ELB-Terraform" {
name = "ELB-Terraform"
security_groups = ["${aws_security_group.ELB-Terraform-SG.id}"]
availability_zones = [ "us-east-1b", "us-east-1c"]
   
health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    interval = 60
    target = "HTTP:80/"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}
########## Security Group ##################
resource "aws_security_group" "ELB-Terraform-SG" {
  name = "terraform-SG"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "elb_dns_name" {
  value = "${aws_elb.ELB-Terraform.dns_name}"
}
