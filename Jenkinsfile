pipeline {
    agent any

    environment {
        REGISTRY = "wala12"
        REGISTRY_CREDENTIAL = "dockerhub-credentials"
        SONAR_TOKEN = credentials('d953b3af1d5419e0e9c577d0f5845870d34eefca')
        SONAR_URL = "http://localhost:9000"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: REGISTRY_CREDENTIAL,
                    usernameVariable: 'wala12',
                    passwordVariable: '123456789')]) {

                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
            }
        }

       stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonar') {
            sh """
            sonar-scanner \
              -Dsonar.projectKey=micro-app \
              -Dsonar.sources=. \
              -Dsonar.host.url=http://localhost:9000 \
              -Dsonar.login=$sqp_39eb71bdb4af554f81efaf8fa343d8fccd61d38f
            """
        }
    }
}
        

        stage('Trivy Scan Images') {
            steps {
                script {
                    def services = ['auth','payment','client','expiration','orders','tickets']

                    for (service in services) {
                        sh """
                        trivy image ${REGISTRY}/${service}:latest || true
                        """
                    }
                }
            }
        }

        stage('Build & Push Docker Images') {
            steps {
                script {
                    def services = ['auth','payment','client','expiration','orders','tickets']

                    def buildStages = [:]

                    for (service in services) {
                        buildStages[service] = {
                            def sha = env.GIT_COMMIT.take(7)
                            def imageSha = "${REGISTRY}/${service}:${sha}"
                            def imageLatest = "${REGISTRY}/${service}:latest"

                            echo "Building ${service}"

                            sh "docker build -t ${imageSha} ./${service}"
                            sh "docker tag ${imageSha} ${imageLatest}"

                            retry(2) {
                                sh "docker push ${imageSha}"
                                sh "docker push ${imageLatest}"
                            }
                        }
                    }

                    parallel buildStages
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }

        success {
            echo "CI/CD completed successfully (Sonar + Trivy + Docker push)"
        }

        failure {
            echo "Pipeline failed"
        }
    }
}
        }
    }
}
