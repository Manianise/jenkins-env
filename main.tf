module "vars" {
  source = "./modules"
  postgres_info = {
    user_name = var.postgres_info.user_name
    user_pwd = var.postgres_info.user_pwd
    db_name = var.postgres_info.db_name
  }
}

