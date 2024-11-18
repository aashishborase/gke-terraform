pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Tag for the Docker image')
    }

    environment {
        DOCKER_IMAGE = "nginx"  // Replace with your Docker image name
        DOCKER_REGISTRY = "us-central1-docker.pkg.dev/keen-acolyte-441610-k2/gke-bluegreen"    // Optional: If you are pushing to a registry (e.g., DockerHub or private registry)
        WORKING_DIR = './gke-bluegreen/docker'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository (ensure Dockerfile exists in the root or specify path)
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {

                    dir(WORKING_DIR) {

                        // Building the Docker image from the Dockerfile
                    sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    '''
                    }
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    // Optionally run tests to verify the built Docker image works
                    sh "docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} nginx -v"
                }
            }
        }

        stage('Push Docker Image') {
            when {
                expression { return env.DOCKER_REGISTRY != '' }  // Only push if a registry is defined
            }
            steps {
                script {
                    // Login to Docker registry (replace with your credentials or use Jenkins' credentials)
                    sh "gcloud auth configure-docker us-central1-docker.pkg.dev"

                    // Tagging and pushing the Docker image
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
    }

    post {
        always {
            script {
                // Cleanup the local Docker image after the build
                sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
            }
        }
        success {
            echo 'Docker image build and push succeeded!'
        }
        failure {
            echo 'Docker image build or push failed!'
        }
    }
}
