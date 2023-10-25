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
                    sh "./gradlew runDocker"                    
                    }
                }
            }
        stage('Login into Nexus') {
            steps {
                script {
                    sh "docker login localhost:8082 -u admin -p test123"
                    }
                }
            }
        stage('Push docker image') {
            steps {
                script {
                    sh "docker push localhost:8082/repository/spring-petclinic/petclinic-test:latest"
                    }
                }
    }
        post{
            always {
                script {
                    sh "docker stop petclinic"
                    sh "docker rm petclinic"
                    sh "docker rmi petclinic-test:latest"
                    sh "docker rmi localhost:8082/repository/spring-petclinic/petclinic-test:latest"                 
                    }
                }
            }
        }