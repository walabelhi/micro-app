
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'wala12'
        COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    def services = ['auth', 'orders', 'payments', 'tickets', 'expiration', 'client']
                    services.each { service ->
                        def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                        sh "docker build -t ${imageName} ./${service}"
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
                        sh "docker push ${imageName}"
                    }
                }
            }
        }
    }

    post {
        always { sh "docker system prune -f" }
        success { echo 'Docker images built and pushed successfully!' }
        failure { echo 'Pipeline failed.' }
    }
}
