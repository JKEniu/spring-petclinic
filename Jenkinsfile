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
        stage("Test"){
            steps{
                script {
                    sh """
                        docker build -t test -f Dockerfile_T . > logs_test_${env.BUILD_NUMBER}.log 2>&1 || exit 1
                        docker run --rm test > test_results_${env.BUILD_NUMBER}.log 2>&1 || exit 1
                    """
                }
            }
        stage('Tag docker image') {
            steps {
                script {
                    sh "docker tag petclinic-test:latest patry77/petclinic-test:$PROJECT_VERSION"
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
                    sh "docker push patry77/petclinic-test:$PROJECT_VERSION"
                    }
                }
            }
        stage('Save docker image') {
        steps {
            script {
                sh "docker save -o petclinic-test_${env.BUILD_NUMBER}.tar petclinic-test:latest"
            }
        }
    }

    stage('Archive docker image') {
        steps {
            archiveArtifacts artifacts: "petclinic-test_${env.BUILD_NUMBER}.tar", fingerprint: true
        }
    }
    }

        post{
            always {
                script {
                        sh "docker stop petclinic"
                        sh "docker rm petclinic"
                        sh "docker rmi patry77/petclinic-test:$PROJECT_VERSION"                 
                    }
                }
            }
        }
