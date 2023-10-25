pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/patry77/spring-petclinic.git']]])
            }
        }
        
        
        stage('Build docker image') {
            steps {
                script {
                    sh "./gradlew pushDockerImage"                    
                    }
                }
            }
        stage('Cleanup Docker') {
            steps {
                script {
                    sh "docker stop petclinic"
                    sh "docker rm petclinic"
                    sh "docker rmi petclinic-test:latest"
                    sh "docker rmi localhost:8082/repository/spring-petclinic/petclinic-test:latest"
                    sh "docker logout localhost:8082"                    
                    }
                }
            }
        }
    }