# ---------------------------------------------
# This HCL provisions
#   - nginx web server
#   - app web server
# ---------------------------------------------

resource "aws_key_pair" "webserver_pub_key" {
  key_name   = "webserver_ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfV1aKoGvgK6pFKSjko12jsXuLY0VG+AKkVS0pLmjykPcTlru8R4Zlel2wrfXlmX5PLa7omYDqOM67rcDqspKI3VYXVEangvIVthlE1ipDM1/4kHTLBQpdB0SFcz0E+T6/CBrMotlu5ey2Nxkt7P1cAtshyK56cOvXyEVK9UevTNq17tMge7BZ1RUIumP+PfDKp9SaWApOLS6jWgjIwFTZHqZ4ep2oVKHusgpasM8taGMFDqoHRPkIjjvXdQtkB1Afvt4X5tFRGNkf/9kNzRvzrulAQjFPrrr2Abvor4wO2aKtGZv68kZSsBwgkTKPNqjv0b6lILfX5c8hQY0Qi15JeSpWm6viIHIcnmZd6Uv95KQMCJK6Uny9DXkTgF+371HdyzTCNfi9WSqfwRMuchaBXu4kBAPu5wwmNqfhiaqKXmwRDgHmXlHXKFTxqo2P7tgUASLI3YJweNRG6oFOujBtlNOi4E5DOkp6n6iMfLHB/j9WOCSMUfSz7WkVVavEKl8="

  tags = {
    "Name" = "webserver_pub_key"
  }
}

#-- LB and ASG for nginx server

resource "aws_lb_target_group" "nginx_server_lb_tg" {
  name                 = "nginx-server-lb-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  target_type          = "instance"
  deregistration_delay = 120

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 6
    interval            = 30
    enabled             = true
    port                = 80
    protocol            = "HTTP"
  }
}

resource "aws_alb" "nginx_server_lb" {
  name               = "nginx-server-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.nginx_server_lb_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_alb_listener" "nginx_server_lb_listener" {
  load_balancer_arn = aws_alb.nginx_server_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx_server_lb_tg.arn
    type             = "forward"
  }
}


resource "aws_launch_configuration" "nginx_server_lc" {
  name_prefix                 = "nginx_server_lc-"
  image_id                    = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type               = "t3.micro"
  security_groups             = [aws_security_group.nginx_server_sg.id]
  key_name                    = aws_key_pair.webserver_pub_key.key_name
  user_data                   = data.template_file.nginx_server_lc_user_data.rendered
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "nginx_server_asg" {
  name_prefix          = "nginx_server_asg-"
  launch_configuration = aws_launch_configuration.nginx_server_lc.name
  min_size             = 2
  max_size             = 2
  target_group_arns    = [aws_lb_target_group.nginx_server_lb_tg.arn]
  vpc_zone_identifier  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_alb.nginx_server_lb, aws_launch_configuration.nginx_server_lc]
}

data "template_file" "nginx_server_lc_user_data" {
  template = file("${path.module}/asg_launch_configurations/nginx_server_lc_user_data")
}

#-- LB and ASG for nginx server



#-- LB and ASG for app (nodejs) server

resource "aws_elb" "app_server_lb" {
  name               = "app-server-lb"
  availability_zones = ["eu-central-1a", "eu-central-1c"]
  security_groups    = [aws_security_group.app_server_lb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 6
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_launch_configuration" "app_server_lc" {
  name_prefix                 = "app_server_lc-"
  image_id                    = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type               = "t3.micro"
  security_groups             = [aws_security_group.app_server_sg.id]
  key_name                    = aws_key_pair.webserver_pub_key.key_name
  user_data                   = data.template_file.app_server_lc_user_data.rendered
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "app_server_asg" {
  name_prefix          = "app_server_asg-"
  launch_configuration = aws_launch_configuration.app_server_lc.name
  min_size             = 2
  max_size             = 3
  load_balancers       = [aws_elb.app_server_lb.name]
  vpc_zone_identifier  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_elb.app_server_lb, aws_launch_configuration.app_server_lc]
}

data "template_file" "app_server_lc_user_data" {
  template = file("${path.module}/asg_launch_configurations/app_server_lc_user_data")
}

#-- LB and ASG for app (nodejs) server
