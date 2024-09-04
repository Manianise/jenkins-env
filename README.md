# Quick Devops Tools installation using Terraform

![jenkins](https://img.shields.io/badge/Jenkins-20%25-D24939?logo=jenkins)
![sonarqube](https://img.shields.io/badge/Sonarqube-10%25-4E9BCD?logo=sonarqube)
![terraform](https://img.shields.io/badge/Terraform-30%25-844FBA?logo=terraform)
![docker](https://img.shields.io/badge/Docker-30%25-2496ED?logo=docker)
![ansible](https://img.shields.io/badge/Ansible-10%25-EE0000?logo=ansible)
![grafana](https://img.shields.io/badge/Grafana-10%25-D24938?logo=grafana)

Quick Test environment for using Jenkins pipelines, Grafana monitoring, Sonarqube for testing. Installation with Terraform

## Installation requirements :

- You need to have Terraform installed : [Terraform install](https://developer.hashicorp.com/terraform/tutorials/docker-get-started/install-cli)
- You need to have Docker Desktop or Docker Engine installed : [Docker install](https://docs.docker.com/engine/install/)

### This will automatically do the following :

- Quick installation of Jenkins
- Quick installation of Sonarqube with postgres database (/!\ credentials unsafe, change them here : [creds](./modules/variables.tf))

### Run the following commands to initialize :
```
Terraform init
```
```
Terraform apply
```

> Containers will listen on port 8080 and 9000 for both Jenkins and Sonarqube on your local machine

***

### Jenkins configuration

- You will need to install the SonarQube Scanner plugin. Go to Manage Jenkins > System and set SonarQube URL :

```
http://172.216.0.5:9000
```

>   Installing SSH on Jenkins
>   
>   If you want to map your ssh folder to jenkins, just run the following command :
>   
>   ```
>   docker run -d --restart on-failure -u jenkins:jenkins --network dev-tools-network -v <path_to_ssh>:/var/.ssh -p > 8080:8080 -p 50000:50000 --name devops-pipeline jenkins/jenkins:lts
>   ```

### Initiating Jenkins agent

- To create an agent go to Manage jenkins > Node :

<img src="./assets/img/screen-4.png" alt="screen1" width="700px" />

- Then create a new node :

<img src="./assets/img/screen-1.png" alt="screen2" width="700px" />

- Save the node, then head to your newly created agent and get the secret :

<img src="./assets/img/screen-3.png" alt="screen3" width="700px" />

#### Run the following command

```
 docker run --init --network=dev-tools-network --name=node_agent mechameleon/node_agent:0.0.5 -url http://devops-pipeline:8080 -workDir=/home/jenkins/agent -secret <your_secret> -name node_agent
```
> /!\ : don't forget to replace <your_secret> by the secret provided by jenkins (i.e image above) !

### Setting up a Pipeline

- Create a docker hub personal access token [link to your settings](https://hub.docker.com/settings/general)

<img src="./assets/img/access_token_docker.jpg" alt="screen4" width="700px" />

- Make sure you copy somewhere (you won't see it anymore afterwards)

<img src="./assets/img/access_token_docker_2.jpg" alt="screen5" width="700px" />

- Create a credential for your docker hub pat by going to Manage Jenkins > Credentials > New credential

<img src="./assets/img/creds_jenkins.png" alt="screen6" width="700px" />

- In the pipeline script, simply chose SCM, Git (no credentials needed)

<img src="./assets/img/pipeline-git.jpg" alt="screen6" width="700px" />

### Setting up Sonarqube

- Create a SonarQube webhook by going in Administration > Webhooks > Create

<img src="./assets/img/sonar-wh.png" alt="screen7" width="700px" />

- Setup a SonarQube project (default creds are admin/admin)

<img src="./assets/img/sonar-screen1.png" alt="screen8" width="700px" />

- Copy/paste your id in the corresponding step in the Jenkins pipeline

<img src="./assets/img/sonar-s2.jpg" alt="screen9" width="700px" />

### Installing Grafana, the monitoring tool !





### Easy to delete instance

- Simply run a Terraform destroy command

## Bare in mind !

- Master should never be used as an agent for security purposes. Change settings in "system administration > number of executors" to 0
- Git projects must be linked with webhooks : [learn more about git webhooks](https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks)
- Sonarqube must be linked to your Jenkins pipelines in order to start testing : [Learn more about Sonarqube webhooks](https://docs.sonarsource.com/sonarqube/latest/project-administration/webhooks/)
- You will need an aws cluster installed as well as your credentials and personnal access token.