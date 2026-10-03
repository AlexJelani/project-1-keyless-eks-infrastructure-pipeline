variable "aws_region" {
  type        = string
  description = "AWS region."
}
variable "cluster_name" {
  type    = string
  default = "keyless-eks"
}
variable "kubernetes_version" {
  type    = string
  default = "1.31"
}
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "az_count" {
  type    = number
  default = 3
}
variable "single_nat_gateway" {
  type    = bool
  default = false
}
variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}
variable "desired_nodes" {
  type    = number
  default = 2
}
variable "min_nodes" {
  type    = number
  default = 2
}
variable "max_nodes" {
  type    = number
  default = 4
}
variable "github_owner" {
  type        = string
  description = "GitHub organization or user."
}
variable "github_repository" {
  type        = string
  description = "Repository name without owner."
}
variable "github_branch" {
  type    = string
  default = "main"
}
variable "ecr_repository_name" {
  type    = string
  default = "keyless-eks/app"
}
variable "tags" {
  type    = map(string)
  default = { Project = "keyless-eks", ManagedBy = "terraform" }
}

