pipeline {
    agent any

    environment {
        REGISTRY = "wala12"                       // Your Docker Hub username
        REGISTRY_CREDENTIAL = "dockerhub-credentials" // Jenkins credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    // List of your microservices
                    def services = ['auth', 'payment', 'client', 'expiration', 'orders', 'tickets']

                    // Login to Docker Hub once
                    withCredentials([usernamePassword(credentialsId: REGISTRY_CREDENTIAL,
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    }

                    // Build and push images in parallel
                    def buildPushStages = [:]

                    for (service in services) {
                        buildPushStages[service] = {
                            def imageTag = "${REGISTRY}/${service}:${env.GIT_COMMIT.take(7)}" // short SHA
                            echo "Building ${service} image: ${imageTag}"

                            // Build Docker image
                            sh "docker build -t ${imageTag} ./${service}"

                            // Push Docker image
                            sh "docker push ${imageTag}"
                        }
                    }

                    parallel buildPushStages
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker login...'
            sh 'docker logout'
        }
        success {
            echo 'All microservices images built and pushed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}
