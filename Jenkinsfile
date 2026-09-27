pipeline {
    agent any

    environment {
        // Define variables for our pipeline
        IMAGE_NAME = 'cicd-demo'
        IMAGE_TAG = "${env.BUILD_ID}" // Uses the Jenkins build number as the tag
        CONTAINER_NAME = 'cicd-demo-app'
    }

    stages {
        stage('Checkout') {
            steps {
                // Jenkins will automatically pull from your Git repository here
                checkout scm
            }
        }

        stage('Test') {
            steps {
                echo 'Running Unit Tests...'
                // Instead of mounting volumes (which is tricky when Jenkins is inside Docker itself),
                // we build the test environment using the 'builder' stage of our Dockerfile
                sh '''
                docker build --target builder -t cicd-test-env .
                docker run --rm cicd-test-env go test -v ./...
                '''
            }
        }

        stage('Build Image') {
            steps {
                echo 'Building Docker Image for Production...'
                sh "docker build -t ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy (Local CD)') {
            steps {
                echo 'Deploying the application locally...'
                // 1. Stop and remove the old container if it exists
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                
                // 2. Start the new container, mapping port 8081 on your Mac to port 8080 in the container
                sh "docker run -d --name ${CONTAINER_NAME} -p 8081:8080 ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
    
    post {
        success {
            echo "🎉 Pipeline succeeded! Application deployed to http://localhost:8081"
        }
        failure {
            echo "❌ Pipeline failed! Please check the logs."
        }
    }
}
