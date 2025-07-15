provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "my_app" {
  name = "simple-app"
}

resource "aws_ecs_cluster" "main" {
  name = "simple-fargate-cluster"
}

resource "aws_lb" "app_alb" {
  name               = "simple-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "blue" {
  name        = "simple-blue-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "simple-green-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/simple-app"
  retention_in_days =7
}


resource "aws_ecs_task_definition" "app" {
  family                   = "simple-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_exec_role_arn

  container_definitions = jsonencode([
    {
      name      = "simple-app"
      image     = "${aws_ecr_repository.my_app.repository_url}:${var.image_tag}"
      portMappings = [
        {
          containerPort = 80
          protocol       = "tcp"
        }
      ]
      logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/simple-app"
      awslogs-region        = var.region
      awslogs-stream-prefix = "ecs"
    }
  }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "simple-app-service"
  cluster         = aws_ecs_cluster.main.id
   task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.ecs_sg]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "simple-app"
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [task_definition]
  }


  depends_on = [aws_lb_listener.http]
}

resource "aws_codedeploy_app" "ecs_app" {
  name             = "simple-codedeploy-app"
  compute_platform = "ECS"
}
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_codedeploy_deployment_group" "ecs_group" {
  app_name              = aws_codedeploy_app.ecs_app.name
  deployment_group_name = "simple-deploy-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    # green_fleet_provisioning_option {
    #   action = "DISCOVER_EXISTING"
    # }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.app.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}
