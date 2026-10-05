module "alb" {
  source = "terraform-aws-modules/alb/aws"
  internal = true

  name    = "${var.project_name}-${var.environment}-alb"
  # deletion_protection = false
  vpc_id  = local.vpc_id
  create_security_group = false
  security_groups = [local.alb-sg-id]
  subnets = local.private-subnet-id
  tags =merge( 
    var.common_tags,{
        Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

resource "aws_lb_listener" "http"{
    load_balancer_arn = module.alb.arn
    port = "80"
    protocol = "HTTP"

    default_action{
        type = "fixed-response"

        fixed_response {
            content_type = "text/html"
            message_body = "<h1> hello world fromalb </h1>"
            status_code = "200"
        }
    }
}