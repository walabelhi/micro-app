pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning Git repository...'
                git branch: 'main', url: 'https://github.com/walabelhi/micro-app.git'
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Building and testing all microservices...'
                sh '''
                    cd orders && npm install && npm test
                    cd ../payments && npm install && npm test
                    cd ../tickets && npm install && npm test
                    cd ../expiration && npm install && npm test
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker images...'
                sh 'docker-compose build'
            }
        }
    }
}
