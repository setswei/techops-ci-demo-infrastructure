# -------------------------------------------
# Create an External ALB for the web applications
# -------------------------------------------

# Create a security grop for ALB
resource "aws_security_group" "alb_security_group" {
  name        = "idea11-ci-demo-alb-sg"
  description = "Security Group for Idea 11 CI Demo ALB"
  vpc_id      = aws_vpc.demo_vpc.id

  # Allow Ingress Traffic HTTP
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all HTTP Traffic"
  }

  # Allow Ingress Traffic HTTPS
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all HTTPS Traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all Outbound Traffic"
  }

  tags = {
    Name      = "idea11-cid-demo-alb-sg"
    Terraform = "True"
  }
}

# Create an AWS ALB
resource "aws_alb" "ci_demo_alb" {
  name               = "idea11-ci-demo-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_aza.id, aws_subnet.public_subnet_azb.id, aws_subnet.public_subnet_azc.id]
  security_groups    = [aws_security_group.alb_security_group.id]

  tags = {
    Name      = "idea11-ci-demo-alb"
    Terraform = "True"
  }
}

# Create target grop and health check for the ALB
resource "aws_lb_target_group" "external_alb_tg" {
  name     = "idea11-demo-web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo_vpc.id

  tags = {
    Name = "idea11-demo-web-target-group"
  }

  # Alter the destination of the health check to be traffic port on ec2 server.
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# Create http listener on ALB
resource "aws_lb_listener" "external_alb_listener_http" {
  load_balancer_arn = aws_alb.ci_demo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.external_alb_tg.arn
    type             = "forward"
  }
}