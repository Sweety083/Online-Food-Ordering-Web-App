pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub' // Jenkins DockerHub credential ID
        DOCKER_IMAGE = "sweetyraj22/food-ordering:latest"
        K8S_NAMESPACE = "production" // your namespace
        APP_NAME = "food-ordering"
        BLUE_DEPLOYMENT = "food-ordering-blue"
        GREEN_DEPLOYMENT = "food-ordering-green"
        KUBECONFIG_CREDENTIALS = 'kubeconfig-cred-id' // Jenkins kubeconfig credential ID
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sweety083/Online-Food-Ordering-Web-App'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS}", variable: 'KUBECONFIG_FILE')]) {
                    script {
                        sh 'export KUBECONFIG=$KUBECONFIG_FILE'

                        // Determine current active deployment
                        def currentDeployment = sh(
                            script: "kubectl get svc ${APP_NAME}-service -n ${K8S_NAMESPACE} -o jsonpath='{.spec.selector.version}'",
                            returnStdout: true
                        ).trim()

                        // Determine target deployment
                        def targetDeployment = currentDeployment == "blue" ? "green" : "blue"

                        echo "Current Deployment: ${currentDeployment}"
                        echo "Target Deployment: ${targetDeployment}"

                        // Update target deployment image
                        def targetDeployName = targetDeployment == "blue" ? BLUE_DEPLOYMENT : GREEN_DEPLOYMENT
                        sh "kubectl set image deployment/${targetDeployName} ${APP_NAME}=${DOCKER_IMAGE} -n ${K8S_NAMESPACE}"

                        // Wait for rollout
                        sh "kubectl rollout status deployment/${targetDeployName} -n ${K8S_NAMESPACE}"

                        // Switch service to target deployment
                        sh "kubectl patch svc ${APP_NAME}-service -n ${K8S_NAMESPACE} -p '{\"spec\":{\"selector\":{\"app\":\"${APP_NAME}\",\"version\":\"${targetDeployment}\"}}}'"

                        // Optional: cleanup old pods (keep only 2)
                        sh "kubectl delete pods -l app=${APP_NAME},version=${currentDeployment} -n ${K8S_NAMESPACE} --grace-period=30 --force || true"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Blue-Green Deployment completed successfully!"
        }
        failure {
            echo "Deployment failed. Check the logs!"
        }
    }
}
