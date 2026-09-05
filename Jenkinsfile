
pipeline {

    agent any

    environment {
        APP_NAME = "my-java-app"
        IMAGE = "my-java-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                echo 'Building Java application...'

                sh '''
                    mvn clean package -DskipTests
                '''
            }
        }

        stage('Unit Test') {
            steps {
                echo 'Running unit tests...'

                sh '''
                    mvn test
                '''
            }

            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image inside Minikube...'

                sh '''
                    eval $(minikube docker-env)

                    docker build \
                        -t ${IMAGE}:${IMAGE_TAG} \
                        -t ${IMAGE}:latest \
                        .
                '''
            }
        }

        stage('Docker Verify') {
            steps {
                sh '''
                    eval $(minikube docker-env)

                    docker images | grep ${IMAGE}
                '''
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo 'Deploying application to Minikube...'

                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${IMAGE}:${IMAGE_TAG}
                '''
            }
        }

        stage('Rollout') {
            steps {
                echo 'Waiting for Kubernetes deployment...'

                sh '''
                    kubectl rollout status deployment/${APP_NAME} \
                        --timeout=180s
                '''
            }
        }

        stage('Verify') {
            steps {
                echo 'Checking Kubernetes resources...'

                sh '''
                    echo "===== NODES ====="
                    kubectl get nodes

                    echo "===== PODS ====="
                    kubectl get pods -o wide

                    echo "===== DEPLOYMENT ====="
                    kubectl get deployment ${APP_NAME}

                    echo "===== SERVICE ====="
                    kubectl get service ${APP_NAME}-service

                    echo "===== APPLICATION URL ====="
                    minikube service ${APP_NAME}-service --url
                '''
            }
        }
    }

    post {

        success {
            echo '======================================'
            echo 'CI/CD PIPELINE SUCCESSFUL'
            echo 'Application deployed to Minikube'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'CI/CD PIPELINE FAILED'
            echo 'Check Jenkins console output'
            echo '======================================'
        }

        always {
            echo 'Pipeline execution completed.'
        }
    }
}

