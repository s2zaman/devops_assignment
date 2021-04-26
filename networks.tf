# This file holds the networking resources

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    "Name" = "private_subnet"
  }

}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    "Name" = "public_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "igw"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "ngw_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    "Name" = "nat_gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    "Name" = "private_rt"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "public_rt"
  }
}

resource "aws_route_table_association" "rt_private_subnet_association" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet.id
}

resource "aws_route_table_association" "rt_public_subnet_association" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

# resource "aws_route_table_association" "rt_igw_association" {
#   route_table_id = aws_route_table.public_rt.id
#   gateway_id     = aws_internet_gateway.igw.id
# }

resource "aws_security_group" "nginx_server_sg" {
  description = "allow http, https and ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ## cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "nginx_server_sg"
  }
}

resource "aws_security_group" "app_server_sg" {
  description = "allow http, https and ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ## cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "app_server_sg"
  }
}

resource "aws_security_group" "nginx_server_lb_sg" {
  description = "allow http, https and ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ## cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "nginx_server_lb_sg"
  }
}

resource "aws_security_group" "app_server_lb_sg" {
  description = "allow http, https and ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ## cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "app_server_lb_sg"
  }
}

resource "aws_security_group" "db_server_sg" {
  description = "allow mongodb port"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ## cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "db_server_sg"
  }
}
