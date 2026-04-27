pipeline {
    agent { label 'worker' }

    stages {

        stage('Init') {
            steps {
                echo 'INIT stage'
                sh 'docker network ls || true'
            }
        }

        stage('Build') {
            steps {
                echo 'BUILD stage'
                sh 'docker build -t task1-app ./Task1'
            }
        }

        stage('Deploy') {
            steps {
                echo 'DEPLOY stage'
                sh '''
                    docker rm -f task1-container || true
                    docker run -d \
                        --name task1-container \
                        -p 8081:80 \
                        task1-app
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'TEST stage'
                sh './tests/test.sh'
            }
        }
    }
}
