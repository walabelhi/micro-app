pipeline {
    agent any

    environment {
        REGISTRY = "wala12"                  // Your Docker Hub username
        REGISTRY_CREDENTIAL = "dockerhub-credentials"  // Jenkins credential ID containing PAT
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

                    // Docker login using PAT from Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: REGISTRY_CREDENTIAL,
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    }

                    // Build and push each service in parallel
                    def buildPushStages = [:]

                    for (service in services) {
                        buildPushStages[service] = {
                            def shaTag = "${env.GIT_COMMIT.take(7)}"
                            def imageSha = "${REGISTRY}/${service}:${shaTag}"
                            def imageLatest = "${REGISTRY}/${service}:latest"

                            echo "Building ${service} image with tags: ${shaTag} and latest"

                            // Build image
                            sh "docker build -t ${imageSha} ./${service}"

                            // Tag as latest
                            sh "docker tag ${imageSha} ${imageLatest}"

                            // Push both tags
                            retry(2) {  // retry in case of transient errors
                                sh "docker push ${imageSha}"
                                sh "docker push ${imageLatest}"
                            }
                        }
                    }

                    // Execute all builds in parallel
                    parallel buildPushStages
                }
            }
        }
    }

    post {
        always {
            // Logout from Docker Hub
            sh "docker logout"
            echo "Docker logout complete."
        }
        success {
            echo "All microservices built and pushed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs for details."
        }
    }
}
