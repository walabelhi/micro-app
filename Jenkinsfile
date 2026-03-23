pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "yourdockerhubusername"
        IMAGE_AUTH = "${DOCKER_REGISTRY}/auth-image:latest"
        IMAGE_CLIENT = "${DOCKER_REGISTRY}/client-image:latest"
        JWT_KEY = "43ba2895a746d98f86a62d45f3fbfdd6"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/gharbijihen/micro-app.git', branch: 'master'
            }
        }

        stage('Build Images') {
            steps {
                script {
                    docker.build("auth-image", "./auth")
                    docker.build("client-image", "./client")
                }
            }
        }

        stage('Push Images') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("auth-image").push('latest')
                        docker.image("client-image").push('latest')
                    }
                }
            }
        }
    }
}
