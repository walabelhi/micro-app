
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'wala12'
        COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                // Full checkout to ensure all files are present
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
                echo "Listing root project files:"
                sh 'ls -l'
                echo "Listing service directories:"
                sh 'ls -l auth orders payments tickets expiration client'
                echo "Listing auth/src files:"
                sh 'ls -l auth/src || echo "auth/src missing"'
                sh 'ls -l auth/tsconfig.json || echo "auth/tsconfig.json missing"'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    def services = ['auth', 'orders', 'payments', 'tickets', 'expiration', 'client']
                    services.each { service ->
                        def dockerfile = "./${service}/Dockerfile"
                        def srcFolder = "./${service}/src"

                        if (fileExists(dockerfile) && fileExists(srcFolder)) {
                            def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                            echo "Building Docker image for ${service}: ${imageName}"
                            sh "docker build -t ${imageName} ./${service}"
                        } else {
                            echo "Skipping ${service}: Dockerfile or src folder missing"
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
                        def dockerfile = "./${service}/Dockerfile"
                        def srcFolder = "./${service}/src"

                        if (fileExists(dockerfile) && fileExists(srcFolder)) {
                            def imageName = "${DOCKER_REGISTRY}/${service}:${COMMIT_HASH}"
                            echo "Pushing Docker image: ${imageName}"
                            sh "docker push ${imageName}"
                        } else {
                            echo "Skipping push for ${service}: Dockerfile or src folder missing"
                        }
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
        success { echo 'Docker images built and pushed successfully!' }
        failure { echo 'Pipeline failed.' }
    }
}
