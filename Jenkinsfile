pipeline {
    agent any

    triggers {
        githubPush()
    }   

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/JKEniu/spring-petclinic.git']]])
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
                    sh "docker tag petclinic:latest jkeniu/petclinic:${env.BUILD_NUMBER}"
                    }
                }
            }
        stage('Login into Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexusCreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                        sh "docker login -u $USERNAME -p $PASSWORD"
                    }
                }
            }
        }

        stage('Push docker image') {
            steps {
                script {
                    sh "docker push jkeniu/petclinic:${env.BUILD_NUMBER}"
                    }
                }
            }
        stage('Save docker image') {
            steps {
                script {
                    sh "docker save -o petclinic_${env.BUILD_NUMBER}.tar petclinic:latest"
                }
            }
        }    

        stage('Archive docker image') {
            steps {
                archiveArtifacts artifacts: "petclinic_${env.BUILD_NUMBER}.tar", fingerprint: true
            }
        }
    }    
    post{
            always {
                script {
                        sh "docker stop petclinic"
                        sh "docker rm petclinic"
                        sh "docker rmi $VM_IP:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION"                 
                    }
                }
            }
        }
}
