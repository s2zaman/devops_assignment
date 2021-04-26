#-- LB and ASG for nginx server

resource "aws_alb_target_group" "nginx_server_lb_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    "Name" = "nginx_server_lb_tg"
  }
}

resource "aws_alb" "nginx_server_lb" {
  name               = "nginx-server-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.nginx_server_lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
}

resource "aws_alb_listener" "nginx_server_lb_listener" {
  load_balancer_arn = aws_alb.nginx_server_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.nginx_server_lb_tg.arn
    type             = "forward"
  }
}


resource "aws_launch_configuration" "nginx_server_lc" {
  image_id        = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.nginx_server_sg.id]
  key_name        = aws_key_pair.pub_key.key_name
  user_data       = data.template_file.nginx_server_lc_user_data.rendered

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "nginx_server_asg" {
  launch_configuration = aws_launch_configuration.nginx_server_lc.name
  min_size             = 2
  max_size             = 2
  target_group_arns    = [ aws_alb_target_group.nginx_server_lb_tg.arn ]
  vpc_zone_identifier  = [ aws_subnet.public_subnet.id, aws_subnet.private_subnet.id ]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_alb.nginx_server_lb, aws_launch_configuration.nginx_server_lc ]

  tags = [{
    "Name" = "nginx_server_asg"
  }]
}

data "template_file" "nginx_server_lc_user_data" {
  template = file("${path.module}/asg_launch_configurations/nginx_server_lc_user_data.tpl")
}

#-- LB and ASG for nginx server



#-- LB and ASG for app (nodejs) server

resource "aws_elb" "app_server_lb" {
  name = "app-server-lb"
  availability_zones = ["eu-central-1a", "eu-central-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_launch_configuration" "app_server_lc" {
  image_id        = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type   = "t2.micro"
  security_groups = [ aws_security_group.app_server_sg.id ]
  key_name        = aws_key_pair.pub_key.key_name
  user_data       = data.template_file.app_server_lc_user_data.rendered

}

resource "aws_autoscaling_group" "app_server_asg" {
  launch_configuration = aws_launch_configuration.app_server_lc.name
  min_size             = 2
  max_size             = 3
  load_balancers = [ aws_elb.app_server_lb.name ]
  vpc_zone_identifier  = [ aws_subnet.public_subnet.id, aws_subnet.private_subnet.id ]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_elb.app_server_lb, aws_launch_configuration.app_server_lc ]

  tags = {
    "Name" = "app_server_asg"
  }
}

data "template_file" "app_server_lc_user_data" {
  template = file("${path.module}/asg_launch_configurations/app_server_lc_user_data.tpl")
}

#-- LB and ASG for app (nodejs) server