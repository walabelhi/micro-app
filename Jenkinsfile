
pipeline {
    agent any

    environment {
        BACKEND_SERVICES = 'auth,orders,payments,tickets,expiration'
        FRONTEND_SERVICE = 'client'
        BACKEND_START_PORT = 4001  // starting port for backend services
        FRONTEND_PORT = 8080       // frontend port
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/walabelhi/micro-app.git'
            }
        }

        stage('Create Docker Network') {
            steps {
                // ignore if network already exists
                sh "sudo docker network create micro-network || true"
            }
        }

        stage('Build Backend Docker Images') {
            steps {
                script {
                    def services = env.BACKEND_SERVICES.split(',').toList()
                    for (service in services) {
                        echo "Building backend service: ${service}"
                        sh "sudo docker build -t ${service}-image ./${service}"
                    }
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                echo "Building frontend service: ${env.FRONTEND_SERVICE}"
                sh "sudo docker build -t ${env.FRONTEND_SERVICE}-image ./${env.FRONTEND_SERVICE}"
            }
        }

        stage('Run Backend Containers') {
            steps {
                script {
                    def services = env.BACKEND_SERVICES.split(',').toList()
                    for (service in services) {
                        echo "Running backend service: ${service}"

                        // remove old container if exists
                        sh "sudo docker rm -f ${service}-container || true"

                        // calculate port
                        def port = env.BACKEND_START_PORT.toInteger() + services.indexOf(service)

                        sh """
                        sudo docker run -d \
                        --network micro-network \
                        --restart unless-stopped \
                        -p ${port}:3000 \
                        --name ${service}-container \
                        ${service}-image
                        """
                    }
                }
            }
        }

        stage('Run Frontend Container') {
            steps {
                echo "Running frontend service: ${env.FRONTEND_SERVICE}"

                sh "sudo docker rm -f ${env.FRONTEND_SERVICE}-container || true"

                sh """
                sudo docker run -d \
                --network micro-network \
                --restart unless-stopped \
                -p ${env.FRONTEND_PORT}:80 \
                --name ${env.FRONTEND_SERVICE}-container \
                ${env.FRONTEND_SERVICE}-image
                """
            }
        }

        stage('Verify Running Containers') {
            steps {
                sh "sudo docker ps"
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
