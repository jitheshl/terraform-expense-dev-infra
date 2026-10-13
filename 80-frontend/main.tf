resource "aws_instance" "frontend-instance" {
  ami                    = data.aws_ami.ami_id.id
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id[0]

  tags = merge(
    var.common_tags, {
      Name = "${var.project_name}-${var.environment}-frontend"
    }
  )
}

resource "null_resource" "frontend" {
  triggers = {
    instance_id = aws_instance.frontend-instance.id
  }

  connection {
    host     = aws_instance.frontend-instance.public_ip
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend.sh",
      "sudo bash /tmp/frontend.sh ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "frontend" {
  instance_id = aws_instance.frontend-instance.id
  state       = "stopped"

  depends_on = [null_resource.frontend]
}

resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = aws_instance.frontend-instance.id

  depends_on = [aws_ec2_instance_state.frontend]
}

resource "null_resource" "frontend_delete" {
  triggers = {
    instance_id = aws_instance.frontend-instance.id
    ami_id      = aws_ami_from_instance.frontend.id
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${self.triggers.instance_id} --region us-east-1"
  }

  depends_on = [
    aws_ami_from_instance.frontend
  ]
}

resource "aws_lb_target_group" "frontend"{
  name = local.resource_name
  port = 80
  protocol = "HTTP"
  vpc_id = local.vpc_id
  health_check{
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    port = 80
    protocol = "HTTP"
    path = "/"
    matcher = "200-299"
    interval = 10
    }
}
resource "aws_launch_template" "frontend" {
  name                                   = local.resource_name
  image_id                               = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior   = "terminate"
  instance_type                          = "t3.micro"
  update_default_version                 = true

  vpc_security_group_ids = [local.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags, {
        Name = local.resource_name
      }
    )
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 180
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.frontend.arn]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  vpc_zone_identifier = local.public_subnet_id

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 60
    }

    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  timeouts {
    delete = "5m"
  }
}

resource "aws_autoscaling_policy" "frontend" {
  name                   = "${local.resource_name}-frontend"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = local.web_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}