output "web_public_ip" {
  value = module.web.public_ip
}

output "app_private_ip" {
  value = module.app.private_ip
}
output "rds_endpoint" {
  value = module.rds.endpoint
}