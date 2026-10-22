pipeline {
    agent { label 'kt10-agent' }

    parameters {
        choice(name: 'MODE', choices: ['REST_API', 'DEBUG', 'RELEASE'], description: 'KT10 build mode')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'make clean && make'
                    } else {
                        bat 'make clean && make'
                    }
                }
            }
        }
        stage('Run') {
            steps {
                echo "NODE_NAME=${env.NODE_NAME}"
                script {
                    if (isUnix()) {
                        sh 'hostname; uname -a; MODE="$MODE" ./build/kt10'
                    } else {
                        bat 'hostname && ver && set MODE=%MODE% && build\\kt10.exe'
                    }
                }
            }
        }
    }
}
