module "web-alb" {
  source = "terraform-aws-modules/alb/aws"
  internal = false

  name    = "${var.project_name}-${var.environment}-web-alb"
  vpc_id  = local.vpc_id
  create_security_group = false
  security_groups = [local.web-alb-sg-id]
  subnets = local.public-subnet-id
  enable_deletion_protection = false
  tags =merge( 
    var.common_tags,{
        Name = "${var.project_name}-${var.environment}-web-alb"
    }
  )
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = module.web-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action{
        type = "fixed-response"

        fixed_response {
            content_type = "text/html"
            message_body = "<h1> hello world fromalb frontend alb from http</h1>"
            status_code = "200"
        }
    }
}

