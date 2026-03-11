
pipeline {
    agent any

    environment {
        BACKEND_SERVICES = ['auth', 'orders', 'payments', 'tickets', 'expiration']
        FRONTEND_SERVICE = 'client'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/micro-app.git'
            }
        }

        stage('Build Backend Docker Images') {
            steps {
                script {
                    for (service in env.BACKEND_SERVICES) {
                        sh "docker build -t ${service}-image ./${service}"
                    }
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                sh "docker build -t ${env.FRONTEND_SERVICE}-image ./${env.FRONTEND_SERVICE}"
            }
        }

        stage('Run Backend Containers') {
            steps {
                script {
                    for (service in env.BACKEND_SERVICES) {
                        // Stop and remove old container if exists
                        sh "docker rm -f ${service}-container || true"
                        sh "docker run -d -p 3000:3000 --name ${service}-container ${service}-image"
                    }
                }
            }
        }

        stage('Run Frontend Container') {
            steps {
                // Stop old container if exists
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
