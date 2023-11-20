pipeline {
    agent any

    triggers {
        githubPush()
    }   

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/patry77/spring-petclinic.git']]])
            }
        }
        
        stage('Get Project Version') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'githubToken', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                        sh "./gradlew release -Prelease.customUsername='$USERNAME' -Prelease.customPassword='$PASSWORD' -Prelease.disableChecks -Prelease.pushTagsOnly"
                        def gradleOutput = sh(script: './gradlew cV', returnStdout: true).trim()
                        def versionLine = gradleOutput.readLines().find { it.startsWith('Project version: ') }
                        def projectVersion = versionLine - 'Project version: '
                        env.PROJECT_VERSION = projectVersion.trim()
                        echo "Project version is: $PROJECT_VERSION"
                    }
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
                    sh "docker tag petclinic-test:latest localhost:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION"
                    }
                }
            }
        stage('Login into Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexusCreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                        sh "docker login localhost:8082 -u $USERNAME -p $PASSWORD"
                    }
                }
            }
        }

        stage('Push docker image') {
            steps {
                script {
                    sh "docker push localhost:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION"
                    }
                }
            }
        // stage('Update docker image on GCP instance group') {
        //     steps {
        //         script {
        //             sh "gcloud auth activate-service-account --key-file='$GCLOUD_CREDS'"
        //             sh "for i in $(gcloud compute instances list --filter NAME~"tfproject" --format="value(NAME)");do gcloud compute instances update-container $i --zone us-west4-a --container-image=localhost:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION;done"
        //             }
        //         }
        //     }
    }

        post{
            always {
                script {
                    sh "docker stop petclinic"
                    sh "docker rm petclinic"
                    sh "docker rmi petclinic-test:$PROJECT_VERSION"
                    sh "docker rmi localhost:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION"                 
                    }
                }
            }
        }
