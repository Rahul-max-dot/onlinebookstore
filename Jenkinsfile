
pipeline {
    agent any

    environment {
        IMAGE_NAME = "onlinebookstore"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Rahul-max-dot/onlinebookstore.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Check Build') {
            steps {
                sh 'ls -lh target/'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Docker Image Check') {
            steps {
                sh 'docker images ${IMAGE_NAME}'
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'BUILD SUCCESSFUL'
            echo 'Docker image created successfully'
            echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo '======================================'
        }

        failure {
            echo 'BUILD FAILED'
        }
    }
}
