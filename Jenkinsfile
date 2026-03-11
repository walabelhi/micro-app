
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-dockerhub-username' // replace with your Docker Hub username
        COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    def services = ['auth', 'orders', 'payments', 'tickets', 'expiration', 'client']

                    services.each { service ->
                        def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                        echo "Building Docker image for ${service}: ${imageName}"

                        // Build the Docker image
                        sh "docker build -t ${imageName} ./${service}"
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    def services = ['auth', 'orders', 'payments', 'tickets', 'expiration', 'client']

                    services.each { service ->
                        def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                        echo "Pushing Docker image: ${imageName}"

                        // Push the Docker image
                        sh "docker push ${imageName}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up local Docker images...'
            sh "docker system prune -f"
        }
        success {
            echo 'Docker images built and pushed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
