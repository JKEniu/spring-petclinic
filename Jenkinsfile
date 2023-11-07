pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/patry77/spring-petclinic.git']]])
            }
        }
        
        stage('Get Project Version') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'githubToken', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')])
                    sh "./gradlew release -Prelease.customUsername='$USERNAME' -Prelease.customPassword='$PASSWORD'"
                    def gradleOutput = sh(script: './gradlew cV', returnStdout: true).trim()
                    def versionLine = gradleOutput.readLines().find { it.startsWith('Project version') }
                    def projectVersion = versionLine - 'Project version: '
                    env.PROJECT_VERSION = projectVersion.trim()
                    echo "Project version is: $PROJECT_VERSION"
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
        stage('Tag docker image') {
            steps {
                script {
                    sh "docker tag petclinic-test:latest localhost:8082/repository/spring-petclinic/petclinic-test:latest"
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