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
  access_key = "AKIAUDS56RQSBVIDNX7M"
  secret_key = "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"
  region     = "eu-central-1" # Frankfurt region
}

resource "aws_key_pair" "pub_key" {
  key_name   = "assignment_ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8G7ScblyK6UIG+cN/lInKvX99/5UYZ1IfEvgPayruDz/Cm/H9KctSxHMN9gM/sQ1BtqwV3U/mvBzih+xB7HlOzwO84IwpPSxtEXevh0nZalZhiIV5bGrkmqJvMSc3g7lcLTIHUZkLcPn7GkyKyl1hdusWi8uVP6I9VdBWHN0C6cTLtdnyeSjBn1rpnqs6NuixXhqInckjIY4oW3jkZUl8bbexUUJJf4EYUgsJA4Vxen1xXFPNi/airZoCzGUX4ithZHkBSOzrWXuUBE7K3hTajNEvgMqss+J5pn8SYJTDXLD1YAfgM8ykUvx3Ka/3i4cZi7ZZuBaNDValfKgW6lRHRHybobPV+o97QDGH3VMjOLGchVebtXv1QgcTZmHKTsxYYMxR0sw6Rz51/qIER7CH26Prhu0vimG4U1Lbmn8UpY1ht7r20mscXy2t1zkdEs/kMm/1GTlHWKwK2q1cZcq2sn1xSyfozVAh5xDYNG82sbbJTacm7HHJ+MAPRTPAws8="

  tags = {
    "Name" = "pub_key"
  }
}




#-- outputs

# output "nginx_server_lb_dns" {
#   value = module.aws_alb.nginx_server_lb
# }

# output "app_server_lb_dns" {
#   value = module.aws_alb.app_server_lb
# }

#-- outputs