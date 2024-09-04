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

variable "grafana_version" {
  description = "The version of Grafana to use"
  type        = string
  default     = "latest"
}

variable "postgres_version" {
  description = "The version of postgres to use"
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


# Variables with secrets

variable "postgres_info" {
  description = "postgres information"
  type        = object({
    user_name = string
    user_pwd = string
    db_name = string
  })
  sensitive   = true
}