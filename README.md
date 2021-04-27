# DevOps Assignment

## Pre-requisites
 - Download and install Terraform binary from https://learn.hashicorp.com/tutorials/terraform/install-cli
 - IAM access keys from respective AWS account. Will be used by Terraform to launch AWS resources.

### Terraform commands
Execute from the root of this repository
```bash
terraform init

terraform validate

terraform plan

terraform apply
```
Then to destroy
```bash
terraform destroy
```

## The access keys that I used
I used disposable Access Keys from my personal AWS account, for this assignment
I have discarded those keys.

## SSH keys
 - The `webserver_ssh_key` can be used to connect to nginx server (having nginx installed) and app server (having nodejs installed)
 - The `dbserver_ssh_key` can be used to connect to database servers (hosting mongodb and its replicasets)

---
## Desired state
 Servers are launched in the desired state as mentioned in the Assignment document.
