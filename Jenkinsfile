
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/walabelhi/micro-app.git'
            }
        }

        stage('Build Orders') {
            steps {
                sh 'cd orders && npm install'
            }
        }

        stage('Build Payments') {
            steps {
                sh 'cd payments && npm install'
            }
        }

        stage('Build Tickets') {
            steps {
                sh 'cd tickets && npm install'
            }
        }

        stage('Build Expiration') {
            steps {
                sh 'cd expiration && npm install'
            }
        }

    }
}
