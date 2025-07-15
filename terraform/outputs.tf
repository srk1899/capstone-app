output "ecr_repository_url" {
  value = aws_ecr_repository.my_app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}
output "green_tg_arn" {
  value = aws_lb_target_group.green.arn
}

output "blue_tg_arn" {
  value = aws_lb_target_group.blue.arn
}

output "alb_listener_arn" {
  value = aws_lb_listener.http.arn
}
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}
