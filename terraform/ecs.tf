resource "aws_ecs_cluster" "main" {
  name = "flask-express-cluster"
}

resource "aws_ecs_task_definition" "flask" {
  family                   = "flask-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "flask"
      image     = "${aws_ecr_repository.flask_repo.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 8000
        hostPort      = 8000
      }]
    }
  ])
}

resource "aws_ecs_task_definition" "express" {
  family                   = "express-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "express"
      image     = "${aws_ecr_repository.express_repo.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
    }
  ])
}

resource "aws_ecs_service" "flask" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_tg.arn
    container_name   = "flask"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "express" {
  name            = "express-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.express.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.public_subnet_1.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express_tg.arn
    container_name   = "express"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}


