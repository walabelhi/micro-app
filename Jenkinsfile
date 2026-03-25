pipeline {
    agent any

    environment {
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

                        // remove old container
                        sh "docker rm -f ${service}-container || true"

                        // assign different port لكل service
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

        stage('Scan Docker Images with Trivy') {
            steps {
                script {
                    def services = env.BACKEND_SERVICES.split(',')
                    services.add(env.FRONTEND_SERVICE)

                    for (service in services) {
                        echo "Scanning ${service}-image with Trivy"

                        sh """
                        trivy image \
                          --format template \
                          --template '@contrib/html.tpl' \
                          -o trivy-${service}.html \
                          ${service}-image || true
                        """
                    }
                }
            }
        }

        stage('Publish Trivy Reports') {
            steps {
                script {
                    def services = env.BACKEND_SERVICES.split(',')
                    services.add(env.FRONTEND_SERVICE)

                    for (service in services) {
                        publishHTML([
                            allowMissing: true,
                            alwaysLinkToLastBuild: true,
                            keepAll: true,
                            reportDir: '.',
                            reportFiles: "trivy-${service}.html",
                            reportName: "Trivy Report - ${service}"
                        ])
                    }
                }
            }
        }

        stage('Verify Running Containers') {
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
            echo 'All services built, running, and scanned successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
