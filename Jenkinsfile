pipeline {
    agent { label 'worker' }

    options {
        timestamps()
    }

    stages {

        /* =====================
           INIT STAGE
           ===================== */
        stage('Init') {
            steps {
                echo '=== INIT STAGE ==='
                sh '''
                    # Ensure Docker network exists (idempotent)
                    docker network ls | grep lab-net || docker network create lab-net
                '''
            }
        }

        /* =====================
           BUILD STAGE
           ===================== */
        stage('Build') {
            steps {
                echo '=== BUILD STAGE ==='
                sh '''
                    docker build -t task1-app ./Task1
                '''
            }
        }

        /* =====================
           DEPLOY STAGE
           ===================== */
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

        /* =====================
           UNIT TESTS (UNSTABLE ON FAIL)
           ===================== */
        stage('Unit Tests') {
            steps {
                echo '=== UNIT TESTS ==='
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh './tests/test.sh'
                }
            }
        }

        /* =====================
           SECURITY SCAN (TRIVY)
           ===================== */
        stage('Security Scan (Trivy)') {
            steps {
                echo '=== TRIVY SECURITY SCAN ==='
                sh '''
                    trivy fs . --format table --output trivy-report.txt || true
                '''
            }
        }

        /* =====================
           MANUAL APPROVAL GATE
           ===================== */
        stage('Approval') {
            steps {
                input message: 'Approve deployment after Trivy scan?'
            }
        }
    }

    /* =====================
       POST ACTIONS
       ===================== */
    post {
        always {
            echo '=== POST ACTIONS ==='
            archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
        }

        failure {
            echo 'Build failed'
        }

        unstable {
            echo 'Build marked UNSTABLE due to test failures'
        }
    }
}
