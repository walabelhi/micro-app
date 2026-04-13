pipeline {
    agent any

    environment {
        REGISTRY = "wala12"
        REGISTRY_CREDENTIAL = "dockerhub-credentials"
        SONAR_SERVER = "sonar"
        SERVICES = "auth client orders payments tickets expiration"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: REGISTRY_CREDENTIAL,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=micro-app \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://localhost:9000 \
                          -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def services = SERVICES.split()

                    for (svc in services) {
                        sh """
                            echo "Scanning ${svc}"
                            trivy fs ${svc} --severity HIGH,CRITICAL || true
                        """
                    }
                }
            }
        }

        stage('Build & Push Docker Images') {
            steps {
                script {
                    def services = SERVICES.split()
                    def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                    withCredentials([usernamePassword(
                        credentialsId: REGISTRY_CREDENTIAL,
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {

                        def builds = [:]

                        for (svc in services) {
                            builds[svc] = {
                                sh """
                                    echo "Building ${svc}"

                                    docker build -t ${REGISTRY}/${svc}:latest ./${svc}
                                    docker tag ${REGISTRY}/${svc}:latest ${REGISTRY}/${svc}:${gitCommit}

                                    docker push ${REGISTRY}/${svc}:latest
                                    docker push ${REGISTRY}/${svc}:${gitCommit}
                                """
                            }
                        }

                        parallel builds
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
            echo "Pipeline finished"
        }

        success {
            echo "CI Pipeline SUCCESS (Sonar + Trivy + Docker Push)"
        }

        failure {
            echo "Pipeline FAILED - check logs"
        }
    }
}
