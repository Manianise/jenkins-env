# Get jenkins from DckHub
resource "docker_image" "jenkins" {
  name = "jenkins/jenkins:${var.jenkins_version}"
  keep_locally = false
}

# App needs an agent to run
resource "docker_image" "j-agent" {
  name = "mechameleon/node_agent:0.0.5"
}

# Get sonarqube image
resource "docker_image" "sonarqube" {
  name = "sonarqube:community"
  keep_locally = false
}

# Sonarqube needs to run with a database

resource "docker_image" "postgres" {
  name = "postgres:${var.postgres_version}"
  keep_locally = false
}

# configure a docker network

resource "docker_network" "dev-tools-network" {
  name = "dev-tools-network"
  ipam_config {
    subnet = "172.216.0.0/16"
    gateway = "172.216.0.1"
  }
  
}


# All containers are linked to the same docker network

resource "docker_container" "jenkins" {

  image = docker_image.jenkins.image_id
  name  = "devops-pipeline" 

  networks_advanced {
    name = docker_network.dev-tools-network.name
    ipv4_address = "172.216.0.2"
    
  }
  dns = var.nameservers
  ports {
    internal = 8080
    external = 8080
  }

}

# Database container

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "devops-db"

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
    
  ]

  networks_advanced {
    name = docker_network.dev-tools-network.name
    ipv4_address = "172.216.0.4"
  }
  dns = var.nameservers
  ports {
    internal = 5432
    external = 5432
  }
}

# Sonarqube container

resource "docker_container" "sonarqube" {

  image = docker_image.sonarqube.image_id
  name  = "devops-testing"

  env = [
    "SONAR_JDBC_URL=jdbc:postgresql://${docker_container.postgres.hostname}:5432/${var.postgres_db}",
    "SONAR_JDBC_USERNAME=${var.postgres_user}",
    "SONAR_JDBC_PASSWORD=${var.postgres_password}",
  ]

  networks_advanced {
    name = docker_network.dev-tools-network.name
    ipv4_address = "172.216.0.5"
  }
  dns = var.nameservers
  ports {
    internal = 9000
    external = 9000
  }
}

