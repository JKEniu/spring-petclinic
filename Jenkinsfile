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
        }
    }