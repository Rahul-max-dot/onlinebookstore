
pipeline {
    agent any

    environment {
        IMAGE_NAME = "rahulhnb/onlinebookstore"
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
                sh 'docker images | grep onlinebookstore'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Docker Logout') {
            steps {
                sh 'docker logout'
            }
        }

        stage('Load Image into Minikube') {
            steps {
                sh '''
                    minikube image load ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                '''
            }
        }

        stage('Update Kubernetes Image') {
            steps {
                sh '''
                    kubectl set image deployment/onlinebookstore \
                    onlinebookstore=${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Check Kubernetes Deployment') {
            steps {
                sh '''
                    kubectl get deployments
                    kubectl get pods
                    kubectl get services
                '''
            }
        }

        stage('Deployment Status') {
            steps {
                sh '''
                    kubectl rollout status deployment/onlinebookstore
                '''
            }
        }
    }

    post {

        success {
            echo '======================================'
            echo 'PIPELINE SUCCESSFUL'
            echo '======================================'
            echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "Docker Image: ${IMAGE_NAME}:latest"
            echo 'Kubernetes Deployment: onlinebookstore'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'PIPELINE FAILED'
            echo '======================================'
        }
    }
}


