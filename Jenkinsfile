
pipeline {

    agent any

    environment {

        // Application
        APP_NAME = "onlinebookstore"

        // Docker Hub
        DOCKER_USERNAME = "YOUR_DOCKERHUB_USERNAME"
        IMAGE_NAME = "${DOCKER_USERNAME}/onlinebookstore"

        // Docker image tag
        IMAGE_TAG = "${BUILD_NUMBER}"

        // Kubernetes
        K8S_NAMESPACE = "default"
    }

    stages {

        /*
         * 1. Checkout Source Code
         */
        stage('Checkout') {
            steps {
                echo "Checking out source code..."

                checkout scm
            }
        }


        /*
         * 2. Maven Build
         */
        stage('Maven Build') {
            steps {
                echo "Building Maven application..."

                sh '''
                    mvn clean package -DskipTests

                    echo "Generated WAR files:"
                    ls -lh target/*.war
                '''
            }
        }


        /*
         * 3. Unit Test
         */
        stage('Unit Test') {
            steps {
                echo "Running Maven tests..."

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


        /*
         * 4. Docker Image Creation
         */
        stage('Docker Build') {
            steps {
                echo "Building Docker image..."

                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest .

                    echo "Docker images:"
                    docker images | grep onlinebookstore
                '''
            }
        }


        /*
         * 5. Docker Hub Login
         */
        stage('Docker Login') {
            steps {

                echo "Logging into Docker Hub..."

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin
                    '''
                }
            }
        }


        /*
         * 6. Push Docker Image
         */
        stage('Docker Push') {
            steps {

                echo "Pushing Docker image to Docker Hub..."

                sh '''
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }


        /*
         * 7. Kubernetes Deployment
         */
        stage('Kubernetes Deploy') {
            steps {

                echo "Deploying application to Kubernetes..."

                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${IMAGE_NAME}:${IMAGE_TAG}

                    kubectl rollout status deployment/${APP_NAME} \
                        --timeout=180s
                '''
            }
        }


        /*
         * 8. Kubernetes Verification
         */
        stage('Kubernetes Verify') {
            steps {

                sh '''
                    echo "=============================="
                    echo "KUBERNETES NODES"
                    echo "=============================="

                    kubectl get nodes

                    echo "=============================="
                    echo "DEPLOYMENTS"
                    echo "=============================="

                    kubectl get deployments

                    echo "=============================="
                    echo "PODS"
                    echo "=============================="

                    kubectl get pods -o wide

                    echo "=============================="
                    echo "SERVICES"
                    echo "=============================="

                    kubectl get services
                '''
            }
        }
    }


    /*
     * Pipeline Result
     */
    post {

        success {
            echo '''
            ==================================
            CI/CD PIPELINE SUCCESSFUL
            ==================================
            Maven Build       : SUCCESS
            Docker Build      : SUCCESS
            Docker Hub Push   : SUCCESS
            Kubernetes Deploy : SUCCESS
            ==================================
            '''
        }

        failure {
            echo '''
            ==================================
            CI/CD PIPELINE FAILED
            ==================================
            Check the Jenkins console output.
            ==================================
            '''
        }

        always {
            sh '''
                docker logout || true
            '''

            echo "Pipeline execution completed."
        }
    }
}

