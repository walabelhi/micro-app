
pipeline {
    agent any

    environment {
        // Use comma-separated string instead of a Groovy list
        BACKEND_SERVICES = 'auth,orders,payments,tickets,expiration'
        FRONTEND_SERVICE = 'client'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/walabelhi/micro-app.git'
            }
        }

        stage('Build Backend Docker Images') {
            steps {
                script {
                    // Split the string into a list
                    def services = env.BACKEND_SERVICES.split(',')
                    for (service in services) {
                        echo "Building backend service: ${service}"
                        sh "docker build -t ${service}-image ./${service}"
                    }
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                echo "Building frontend service: ${env.FRONTEND_SERVICE}"
                sh "docker build -t ${env.FRONTEND_SERVICE}-image ./${env.FRONTEND_SERVICE}"
            }
        }

        stage('Run Backend Containers') {
            steps {
                script {
                    def services = env.BACKEND_SERVICES.split(',')
                    for (service in services) {
                        echo "Running backend service: ${service}"
                        // Stop and remove old container if exists
                        sh "docker rm -f ${service}-container || true"
                        // Map different ports per service (example: 3001, 3002...) to avoid conflicts
                        def port = 3000 + services.indexOf(service)
                        sh "docker run -d -p ${port}:3000 --name ${service}-container ${service}-image"
                    }
                }
            }
        }

        stage('Run Frontend Container') {
            steps {
                echo "Running frontend service: ${env.FRONTEND_SERVICE}"
                sh "docker rm -f ${env.FRONTEND_SERVICE}-container || true"
                sh "docker run -d -p 8080:80 --name ${env.FRONTEND_SERVICE}-container ${env.FRONTEND_SERVICE}-image"
            }
        }

        stage('Verify') {
            steps {
                sh "docker ps"
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished!'
        }
        success {
            echo 'All services built and running successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
