# Get jenkins from DckHub
resource "docker_image" "jenkins" {
  name = "jenkins/jenkins:${var.jenkins_version}"
  keep_locally = false
}

# App needs an agent to run

resource "docker_image" "j-agent" {
  name = "mechameleon/node_agent:0.0.5"
}

# get grafana image

resource "docker_image" "grafana" {
  name = "grafana/grafana:${var.grafana_version}"
  keep_locally = false
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

# Grafana container

resource "docker_container" "grafana" {

  image = docker_image.grafana.image_id
  name  = "devops-monitoring"

  env = [
    "GRAFANA_JDBC_URL=jdbc:postgres://${docker_container.postgres.hostname}:3306/${var.postgres_info.db_name}",
    "GRAFANA_JDBC_USERNAME=${var.postgres_info.user_name}",
    "GRAFANA_JDBC_PASSWORD=${var.postgres_info.user_pwd}",
  ]

  networks_advanced {
    name = docker_network.dev-tools-network.name
    ipv4_address = "172.216.0.3"
  }
  dns = var.nameservers
  ports {
    internal = 3000
    external = 3333
  }
}

# Database container

# Create a Docker volume for persistent storage
resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}


resource "docker_container" "postgres" {
  name  = "terraform-postgres"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_DB=${var.postgres_info.db_name}",
    "POSTGRES_USER=${var.postgres_info.user_name}",
    "POSTGRES_PASSWORD=${var.postgres_info.user_pwd}",
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

  # Mount the volume for persistent storage
  mounts {
    target = "/var/lib/postgresql/data"
    source = docker_volume.postgres_data.name
    type   = "volume"
  }

  # Optional: depends_on to ensure the network is created first
  depends_on = [
    docker_network.dev-tools-network,
    docker_volume.postgres_data
  ]
}

# Sonarqube container

resource "docker_container" "sonarqube" {

  image = docker_image.sonarqube.image_id
  name  = "devops-testing"

  env = [
    "SONAR_JDBC_URL=jdbc:postgresql://${docker_container.postgres.hostname}:5432/${var.postgres_info.db_name}",
    "SONAR_JDBC_USERNAME=${var.postgres_info.user_name}",
    "SONAR_JDBC_PASSWORD=${var.postgres_info.user_pwd}",
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

