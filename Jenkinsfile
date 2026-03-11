
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'wala12'
        COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [[$class: 'CloneOption', shallow: false, depth: 0, noTags: false, timeout: 10]],
                    userRemoteConfigs: [[url: 'https://github.com/walabelhi/micro-app.git', credentialsId: 'github-token']]
                ])
            }
        }

        stage('Debug Workspace') {
            steps {
                echo "Root files:"
                sh 'ls -l'
                echo "Service directories:"
                sh 'ls -l auth orders payments tickets expiration client'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Define all services
                    def services = ['auth', 'orders', 'payments', 'tickets', 'expiration', 'client']

                    services.each { service ->
                        def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                        echo "Building Docker image for ${service}: ${imageName}"

                        if (service == 'client') {
                            // React frontend service
                            sh """
                                docker build -t ${imageName} ./${service}
                            """
                        } else {
                            // Node backend services
                            sh """
                                docker build -t ${imageName} ./${service}
                            """
                        }
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }

                    def services = ['auth', 'orders', 'payments', 'tickets', 'expiration', 'client']
                    services.each { service ->
                        def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                        echo "Pushing Docker image: ${imageName}"
                        sh "docker push ${imageName}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker cache..."
            sh "docker system prune -f"
        }
        success { echo "All Docker images built and pushed successfully!" }
        failure { echo "Pipeline failed." }
    }
}
