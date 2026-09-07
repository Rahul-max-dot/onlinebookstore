
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
                sh '''
                    mvn clean package -DskipTests
                '''
            }
        }

        stage('Check Build') {
            steps {
                sh '''
                    echo "Checking WAR file..."
                    ls -lh target/
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building Docker image..."

                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        .
                '''
            }
        }

        stage('Docker Image Check') {
            steps {
                sh '''
                    docker images | grep onlinebookstore
                '''
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
                    echo "Pushing version image..."
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}

                    echo "Pushing latest image..."
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Docker Logout') {
            steps {
                sh '''
                    docker logout
                '''
            }
        }

        /*
         * IMPORTANT:
         * No "minikube image load" stage here.
         *
         * Kubernetes will pull the image directly
         * from Docker Hub.
         */

        stage('Check Kubernetes') {
            steps {
                sh '''
                    echo "Checking Kubernetes connection..."

                    /usr/local/bin/kubectl get nodes
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "Applying Kubernetes Deployment..."

                    /usr/local/bin/kubectl apply -f deployment.yaml

                    echo "Applying Kubernetes Service..."

                    /usr/local/bin/kubectl apply -f service.yaml
                '''
            }
        }

        stage('Update Kubernetes Image') {
            steps {
                sh '''
                    echo "Updating Kubernetes image..."

                    /usr/local/bin/kubectl set image deployment/onlinebookstore \
                        onlinebookstore=${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Check Kubernetes Deployment') {
            steps {
                sh '''
                    echo "Deployments:"
                    /usr/local/bin/kubectl get deployments

                    echo "Pods:"
                    /usr/local/bin/kubectl get pods

                    echo "Services:"
                    /usr/local/bin/kubectl get services
                '''
            }
        }

        stage('Deployment Status') {
            steps {
                sh '''
                    echo "Waiting for deployment..."

                    /usr/local/bin/kubectl rollout status \
                        deployment/onlinebookstore \
                        --timeout=180s
                '''
            }
        }
    }

    post {

        success {
            echo '''
========================================
       PIPELINE SUCCESSFUL
========================================
'''
            echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "Docker Image: ${IMAGE_NAME}:latest"
            echo "Kubernetes Deployment: onlinebookstore"
            echo "Kubernetes Service: onlinebookstore-service"
            echo '''
========================================
'''
        }

        failure {
            echo '''
========================================
          PIPELINE FAILED
========================================
'''
        }

        always {
            echo "Build Number: ${BUILD_NUMBER}"
        }
    }
}
