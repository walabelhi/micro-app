pipeline {
    agent any

    environment {
        // Git repo to clone (optional if Jenkins Multibranch handles it)
        GIT_REPO_URL = 'https://github.com/walabelhi/micro-app' // replace if using multibranch or to be overridden

        // Credentials (replace with your actual Jenkins IDs)
        DOCKERHUB_CREDENTIALS_ID = 'dckr_pat_kX6BbPt5MTLKwjNCMF14JcC63pc' // Username/Password or Docker Hub token stored in Jenkins
        // If you use a separate registry for image pulling/pushing:
        // DOCKERHUB_REGISTRY = 'docker.io' // optional

        // SonarQube
        SONARQUBE_SERVER = 'http://localhost:9000' // Jenkins SonarQube server ID configured in Jenkins
        SONAR_TOKEN_CREDENTIALS_ID = 'sqp_sqp_39eb71bdb4af554f81efaf8fa343d8fccd61d38f' // Secret text or credentials containing sonar token

        // Trivy image (use a compatible image with your environment)
        TRIVY_IMAGE = 'aquasec/trivy:latest'

        // Services list (space-separated directory names under repo root)
        SERVICES = "auth client orders payments tickets expiration"

        // Branch to track (adjust if using feature branches)
        GIT_BRANCH = '*/main'
    }

    options {
        timestamps()
        // Concurrency control if desired
        // disableConcurrentBuilds()
        // Keep build logs readable
        skipDefaultCheckout false
    }

    stages {
        stage('Checkout') {
            steps {
                // If using Multibranch Pipeline, you may omit manual checkout
                checkout scm: [
                    $class: 'GitSCM',
                    branches: [[ name: "${GIT_BRANCH}" ]],
                    userRemoteConfigs: [[ url: "${GIT_REPO_URL}" ]]
                ]
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID,
                                                     usernameVariable: 'DOCKERHUB_USERNAME',
                                                     passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        sh """
                          echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                        """
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // Run SonarQube analysis per service
                    def services = "${SERVICES}".split()
                    withSonarQubeEnv(SONARQUBE_SERVER) {
                        for (svc in services) {
                            def sonarProjectKey = "${svc}"
                            def sonarProjectDir = "${svc}"
                            // If you have per-service sonar-project.properties, use it; otherwise, pass defaults
                            sh """
                               if [ -f "${sonarProjectDir}/sonar-project.properties" ]; then
                                   sonar-scanner -Dsonar.projectKey=${sonarProjectKey} -Dsonar.sources=${sonarProjectDir}
                               else
                                   sonar-scanner -Dsonar.projectKey=${sonarProjectKey} -Dsonar.sources=${sonarProjectDir} \
                                                 -Dsonar.host.url=\$(grep -m1 -oP 'server:\s*.*' -n ${SONARQUBE_SERVER} || true) || true
                               fi
                            """
                        }
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def services = "${SERVICES}".split()
                    // Run Trivy scan for each service directory (scans filesystem)
                    for (svc in services) {
                        if (fileExists("${svc}/Dockerfile")) {
                            sh """
                               docker build -q -t ${svc}-temp-build ${svc} >/dev/null 2>&1 || true
                               docker rm -f ${svc}-trivy || true
                               docker run --name ${svc}-trivy --rm -v \$(pwd):/project -w /project ${TRIVY_IMAGE} \
                                   fs ${svc} --ignore-unfixed || true
                            """
                        } else {
                            echo "No Dockerfile found for ${svc}, skipping Trivy scan for this service."
                        }
                    }
                }
            }
        }

        stage('Build & Push') {
            steps {
                script {
                    def services = "${SERVICES}".split()
                    def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                    // Build & push in parallel per service
                    def builds = [:]
                    for (svc in services) {
                        builds[svc] = {
                            stage("Build & Push ${svc}") {
                                withEnv(["IMAGE_TAG=${svc}:latest", "COMMIT_TAG=${svc}:${gitCommit}"]) {
                                    sh """
                                       set -e
                                       if [ ! -f ${svc}/Dockerfile ]; then
                                           echo "No Dockerfile for ${svc}, skipping..."
                                           exit 0
                                       fi

                                       # Build
                                       docker build -t ${svc}:latest ${svc}
                                       # Tag for Docker Hub
                                       docker tag ${svc}:latest ${DOCKERHUB_USERNAME}/${svc}:latest
                                       docker tag ${svc}:latest ${DOCKERHUB_USERNAME}/${svc}:${gitCommit}

                                       # Push
                                       docker push ${DOCKERHUB_USERNAME}/${svc}:latest
                                       docker push ${DOCKERHUB_USERNAME}/${svc}:${gitCommit}
                                    """
                                }
                            }
                        }
                    }

                    // Resolve DOCKERHUB_USERNAME from credentials now
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID,
                                                     usernameVariable: 'DOCKERHUB_USERNAME',
                                                     passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        // login was done earlier; ensure env has username for tagging
                        parallel builds
                    }
                }
            }
        }

        stage('Post Actions') {
            steps {
                sh 'docker logout'
                // Optional: cleanup local images
                script {
                    sh 'docker image prune -f || true'
                }
            }
        }

        stage('CD Prep (Kubernetes)') {
            when {
                expression { true } // placeholder; enable when CD is implemented
            }
            steps {
                echo 'CD stage is prepared (Kubernetes deployment not implemented in this version).'
                // Example stub: you could generate manifests or push to a release repo here
            }
        }
    }

    post {
        always {
            script {
                echo "Build finished with status: ${currentBuild.currentResult}"
                // Optional: archive logs/artifacts if needed
            }
        }
        success {
            echo 'Pipeline succeeded.'
        }
        failure {
            echo 'Pipeline failed.'
        }
        unstable {
            echo 'Pipeline unstable.'
        }
        changed {
            echo 'Pipeline status changed.'
        }
    }
}

