# Nginx Website Deployment with Jenkins Pipeline

This project demonstrates a Jenkins pipeline for deploying an Nginx website to Heroku. The pipeline is triggered by a GitHub webhook on every push to the repository. Below is a detailed explanation of each step in the pipeline.

## Table of Contents

1.  [Prerequisites](#prerequisites)
2.  [Project Setup](#project-setup)
3.  [Jenkins Pipeline Configuration](#jenkins-pipeline-configuration)
4.  [Step-by-Step Pipeline Explanation](#step-by-step-pipeline-explanation)
    1.  [Build Docker Image](#1-build-docker-image)
    2.  [Clean Up Existing Containers](#2-clean-up-existing-containers)
    3.  [Launch Docker Container](#3-launch-docker-container)
    4.  [Run Tests](#4-run-tests)
    5.  [Upload Image to DockerHub](#5-upload-image-to-dockerhub)
    6.  [Deploy to Heroku Staging](#6-deploy-to-heroku-staging)
    7.  [Deploy to Heroku Production](#7-deploy-to-heroku-production)
5.  [Screenshots](#screenshots)
6.  [Conclusion](#conclusion)
7.  [Lessons Learned](#lessons-learned)

## Prerequisites

-   Jenkins installed and configured
-   Docker installed on the Jenkins server
-   GitHub repository for your project
-   DockerHub account
-   Heroku account

## Project Setup

1.  **Dockerfile**: Ensure you have a `Dockerfile` for building your Nginx website image.
2.  **Jenkinsfile**: Create a `Jenkinsfile` in your GitHub repository with the pipeline script.
3.  **GitHub Webhook**: Configure a webhook in your GitHub repository to trigger the Jenkins pipeline on every push.

## Jenkins Pipeline Configuration

Create a new pipeline job in Jenkins and link it to your GitHub repository. Ensure Jenkins has access to Docker, DockerHub, and Heroku CLI.

## Step-by-Step Pipeline Explanation

### 1. Build Docker Image

This step uses the `Dockerfile` in your repository to build a Docker image of your Nginx website.



`stage('Build Docker Image') {
    steps {
        script {
            dockerImage = docker.build("your-dockerhub-username/your-image-name:${env.BUILD_ID}")
        }
    }
}` 

### 2. Clean Up Existing Containers

Before launching a new container, the pipeline checks for and removes any existing containers from previous runs.

groovy

Code kopieren

`stage('Clean Up Existing Containers') {
    steps {
        script {
            try {
                sh 'docker rm -f nginx-container || true'
            } catch (Exception e) {
                echo 'No existing container to remove'
            }
        }
    }
}` 

### 3. Launch Docker Container

The built Docker image is used to start a new container.

groovy

Code kopieren

`stage('Launch Docker Container') {
    steps {
        script {
            dockerImage.run('-d --name nginx-container -p 80:80')
        }
    }
}` 

### 4. Run Tests

A test is performed to ensure the website is working correctly by using `curl` and `grep`.

groovy

Code kopieren

`stage('Run Tests') {
    steps {
        script {
            sh 'sleep 10' // Wait for the container to be fully up
            sh 'curl localhost | grep "dimension"'
        }
    }
}` 

### 5. Upload Image to DockerHub

If the tests pass, the Docker image is uploaded to DockerHub.

groovy

Code kopieren

`stage('Upload Image to DockerHub') {
    steps {
        script {
            docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                dockerImage.push("${env.BUILD_ID}")
            }
        }
    }
}` 

### 6. Deploy to Heroku Staging

Deploy the Docker image to a Heroku staging environment.

groovy

Code kopieren

`stage('Deploy to Heroku Staging') {
    steps {
        script {
            sh '''
            heroku container:login
            heroku container:push web --app your-heroku-staging-app
            heroku container:release web --app your-heroku-staging-app
            '''
        }
    }
}` 

### 7. Deploy to Heroku Production

After verifying the staging deployment, the image is then deployed to the production environment.

groovy

Code kopieren

`stage('Deploy to Heroku Production') {
    steps {
        input message: 'Deploy to production?', ok: 'Deploy'
        script {
            sh '''
            heroku container:login
            heroku container:push web --app your-heroku-production-app
            heroku container:release web --app your-heroku-production-app
            '''
        }
    }
}` 

## Screenshots

Include screenshots of the following:

1.  **Jenkins Job Configuration**: Display the configuration settings for the Jenkins pipeline job.
    
2.  **GitHub Webhook**: Show the webhook configuration in your GitHub repository.
    
3.  **Jenkins Pipeline Steps**: Screenshots of each step in the Jenkins pipeline.
    -   Build Docker Image
    -   Clean Up Existing Containers
    -   Launch Docker Container
    -   Run Tests
    -   Upload Image to DockerHub
    -   Deploy to Heroku Staging
    -   Deploy to Heroku Production

(Insert individual screenshots here as needed)

## Conclusion

This project showcases the automation of deploying an Nginx website to Heroku using Jenkins. By leveraging Docker for containerization, Jenkins for continuous integration and continuous deployment (CI/CD), and Heroku for application hosting, we achieved a streamlined and efficient deployment pipeline. This setup ensures that any code changes pushed to the GitHub repository are automatically tested and deployed, minimizing manual intervention and reducing the risk of errors.

## Lessons Learned

During this project, I learned:

-   **Pipeline Automation**: How to create and configure a Jenkins pipeline to automate the build, test, and deployment process.
-   **Containerization**: The importance of Docker in packaging applications and its role in consistent deployment environments.
-   **Continuous Integration and Continuous Deployment (CI/CD)**: The benefits of implementing CI/CD practices to ensure rapid and reliable delivery of software.
-   **Heroku Deployment**: How to deploy Docker containers to Heroku, including the staging and production environments.
-   **Problem-Solving**: Troubleshooting various issues that arose during the configuration and execution of the pipeline, enhancing my debugging skills.

This project has not only enhanced my technical skills but also emphasized the importance of automation and modern development practices in achieving efficient and reliable software delivery.
