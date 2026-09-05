```groovy
pipeline {

    agent any

    environment {
        IMAGE_NAME = "onlinebookstore"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out source code..."

                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                echo "Building Maven application..."

                sh '''
                    mvn clean package -DskipTests

                    echo "WAR file:"
                    ls -lh target/*.war
                '''
            }
        }

        stage('Maven Test') {
            steps {
                echo "Running Maven tests..."

                sh '''
                    mvn test
                '''
            }

            post {
                always {
                    junit(
                        allowEmptyResults: true,
                        testResults: 'target/surefire-reports/*.xml'
                    )
                }
            }
        }

        stage('Docker Check') {
            steps {
                echo "Checking Docker..."

                sh '''
                    docker --version
                    docker info
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image..."

                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest .

                    echo "Docker image created successfully"

                    docker images | grep onlinebookstore
                '''
            }
        }
    }

    post {

        success {
            echo "Maven build and Docker image creation successful!"
        }

        failure {
            echo "Pipeline failed. Check the failed stage."
        }

        always {
            echo "Pipeline execution completed."
        }
    }
}
```
