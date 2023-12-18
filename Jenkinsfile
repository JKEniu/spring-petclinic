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
        stage('Get VM IP'){
            steps{
                script{
                    def vmIP = sh(script: "curl ifconfig.me", returnStdout: true)
                    env.VM_IP = vmIP
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
                    sh "docker tag petclinic-test:latest $VM_IP:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION"
                    }
                }
            }
        stage('Login into Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexusCreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                        sh "docker login $VM_IP:8082 -u $USERNAME -p $PASSWORD"
                    }
                }
            }
        }

        stage('Push docker image') {
            steps {
                script {
                    sh "docker push $VM_IP:8082/repository/spring-petclinic/petclinic-test:$PROJECT_VERSION"
                    }
                }
            }
        stage('Update docker image on GCP instance group') {
            steps {
                script {
                        withCredentials([file(credentialsId: 'GCLOUD_CREDS', variable: 'GCLOUD_CREDS')]) {
                            sh "gcloud auth activate-service-account --key-file='$GCLOUD_CREDS'"
                            sh """
                            gcloud compute instance-templates create-with-container petclinic-template \
                            --container-image=${VM_IP}:8082/repository/spring-petclinic/petclinic-test:${PROJECT_VERSION} \
                            --tags=http-server \
                            --machine-type=e2-medium \
                            --container-env=MYSQL_URL=jdbc:mysql://petclinic
                            --container-env=MYSQL_USER=petclinic \
                            --container-env=MYSQL_PASSWORD=test123 \
                            --container-env=spring.profiles.active=mysql \
                            --subnet=capstone-loadbalancer-subnetwork \
                            --region=us-central1
                            --no-address \
                            --metadata=startup-script='#! /bin/bash
                            echo {
                            "insecure-registries": ["${VM_IP}:8082"]
                            } | sudo tee /etc/docker/daemon.json
                            sudo systemctl restart docker
                            '
                            """
                            sh "gcloud compute instance-groups managed rolling-action replace capstone-loadbalancer-group --version template=petclinic-template --zone us-central1-a"                     
                            // sh '''
                            // INSTANCE_LIST=$(gcloud compute instances list --filter "NAME~petclinic" --format="value(NAME)" || echo "Error getting instance list")

                            // if [ -n "$INSTANCE_LIST" ]; then
                            //     echo "Instance list: $INSTANCE_LIST"
                            //     for i in $INSTANCE_LIST; do
                            //     gcloud compute instances update-container "$i" --zone us-central1-a --container-image=${VM_IP}:8082/repository/spring-petclinic/petclinic-test:${PROJECT_VERSION} || echo "Error updating container for instance $i"
                            //     done
                            // else
                            //     echo "Error getting instance list. Exiting."
                            //     exit 1
                            // fi
                            // '''
                        }
                    }
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
