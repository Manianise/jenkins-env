# Related to docker

variable "docker_ports" {
  type = object({
    int = number
    ext = number
  })
  default = {
      int = 22
      ext = 2222
    }
}

variable "networks" {
  type = list(string)
  default = ["network1", "network2"]
}

variable "postgres_user" {
  description = "The username for the PostgreSQL database"
  type        = string
  default     = "default_user"
}

variable "postgres_password" {
  description = "The password for the PostgreSQL database"
  type        = string
  default     = "default_password"
  sensitive   = true
}

variable "postgres_db" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "default_db"
}

variable "postgres_version" {
  description = "The version of PostgreSQL to use"
  type        = string
  default     = "latest"
}

variable "jenkins_version" {
  description = "Jenkins version"
  type = string
  default = "lts-jdk17"
}

variable "nameservers" {
  description = "default dns for containers"
  type = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}

# Related to AWS

variable "private_ips" {
  description = "List of private IPs for the instances"
  type        = list(string)
  default     = ["10.0.1.10", "10.0.1.11"]
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "my-eks-cluster"
}

