pipeline {
    agent { label 'worker' }

    options {
        timestamps()
    }

    stages {

        stage('Init') {
            steps {
                echo '=== INIT STAGE ==='
                sh '''
                    docker network ls | grep lab-net || docker network create lab-net
                '''
            }
        }

        stage('Build') {
            steps {
                echo '=== BUILD STAGE ==='
                sh 'docker build -t task1-app ./Task1'
            }
        }

        stage('Deploy') {
            steps {
                echo '=== DEPLOY STAGE ==='
                sh '''
                    docker rm -f task1-container || true
                    docker run -d \
                        --name task1-container \
                        --network lab-net \
                        -p 8081:80 \
                        task1-app
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                echo '=== UNIT TESTS ==='
                sh './tests/test.sh'
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                echo '=== TRIVY SECURITY SCAN ==='
                sh '''
                    trivy fs . --format table --output trivy-report.txt
                '''
            }
        }
    }

    post {
        always {
            echo '=== POST ACTIONS ==='
            archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
        }

        failure {
            echo 'Build failed'
        }
    }
}

