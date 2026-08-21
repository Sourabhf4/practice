pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Sourabhf4/todo-app.git'
            }
        }

        stage('Verify Code') {
            steps {
                sh 'ls -la'
            }
        }
    }
}
