pipeline {
    agent any

    environment {
        REGISTRY = "wala12"
        REGISTRY_CREDENTIAL = "dockerhub-credentials"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                // Placeholder (we connect real Sonar later)
                sh 'echo "SonarQube scan simulated"'
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    // ✅ FIXED services list
                    def services = ['auth', 'payments', 'client', 'expiration', 'orders', 'tickets']

                    withCredentials([usernamePassword(
                        credentialsId: REGISTRY_CREDENTIAL,
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    }

                    def buildPushStages = [:]

                    for (service in services) {
                        buildPushStages[service] = {
                            def shaTag = "${env.GIT_COMMIT.take(7)}"
                            def imageSha = "${REGISTRY}/${service}:${shaTag}"
                            def imageLatest = "${REGISTRY}/${service}:latest"

                            echo "Building ${service}..."

                            sh "docker build -t ${imageSha} ./${service}"
                            sh "docker tag ${imageSha} ${imageLatest}"

                            retry(2) {
                                sh "docker push ${imageSha}"
                                sh "docker push ${imageLatest}"
                            }
                        }
                    }

                    parallel buildPushStages
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def services = ['auth', 'payments', 'client', 'expiration', 'orders', 'tickets']
                    def shaTag = "${env.GIT_COMMIT.take(7)}"

                    for (service in services) {
                        echo "Scanning ${service}..."
                        sh "trivy image ${REGISTRY}/${service}:${shaTag} || true"
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
            echo "Docker logout complete."
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
