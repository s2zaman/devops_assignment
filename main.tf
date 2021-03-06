/* ------------------------------------------------
# This HCL file provisions AWS infrastructure.

Authored: 24th April 2021

Hierarchy
main.tf
   - networks.tf
   - web_servers.tf
   - db_servers.tf

-------------------------------------------------- */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
    }
  }
}

provider "aws" {
  access_key = "XXXXXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  region     = "eu-central-1"  # Frankfurt region
}


#-- outputs

# output "nginx_server_lb_dns" {
#   value = module.aws_alb.nginx_server_lb
# }

# output "app_server_lb_dns" {
#   value = module.aws_alb.app_server_lb
# }

#-- outputs