pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/patry77/spring-petclinic.git']]])
            }
        }
        
        
        stage('Set up Docker') {
            steps {
                script {
                    def dockerTool = tool name: 'Docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
                    env.PATH = "${dockerTool}:${env.PATH}"
                    sh 'docker --version'
                }
            }
        }
        
        stage('Build docker image') {
            steps {
                script {
                    sh "./gradlew runDocker"                    
                    }
                }
            }
        }
    }