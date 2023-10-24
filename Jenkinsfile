pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/patry77/spring-petclinic.git']]])
            }
        }
        
        stage('Set up JDK') {
            steps {
                script {
                    def jdkTool = tool name: 'JDK 19', type: 'hudson.model.JDK$Installations'
                    env.JAVA_HOME = "${jdkTool}/"
                    sh "${jdkTool}/bin/java -version"
                }
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
                    sh "./gradlew buildDockerImage"                    
                    }
                }
            }
        }
    }