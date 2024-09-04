# Variables with secrets

variable "postgres_info" {
  description = "mysql information"
  type        = object({
    user_name = string
    user_pwd = string
    db_name = string
  })
  sensitive   = true
}