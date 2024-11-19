pipeline {
    agent any

    parameters {
        string(name: 'TAG', , defaultValue: '1.0.0', description: 'please enter the tag in following format 1.0.0')
        string(name: 'RELEASE_NAME', defaultValue: 'my-nginx-chart', description: 'Helm release name')
        string(name: 'OLD_RELEASE_NAME', defaultValue: 'NEW_DEPLOYMENT', description: 'previous release')
        string(name: 'CHART_NAME', defaultValue: './gke_bluegreen/application-chart', description: 'Path or name of Helm chart')
        string(name: 'NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace')
    }

    stages {

        stage('Connect to the cluster') {
            steps {
                sh 'gcloud container clusters get-credentials bluegreen-cluster --zone us-central1-a --project keen-acolyte-441610-k2'
            }
        }
        stage('Helm Version Check') {
            steps {
                sh 'helm version'
            }
        }

        stage('Deploy Helm Chart') {
            steps {
                script {
                    echo "Deploying Helm chart: ${params.CHART_NAME}"
                    echo "Using release name: ${params.RELEASE_NAME}"
                    echo "Namespace: ${params.NAMESPACE}"

                    // Deploy the Helm chart with the provided parameters
                    sh """
                    helm upgrade --install ${params.RELEASE_NAME} \
                                 ${params.CHART_NAME} \
                                 --namespace ${params.NAMESPACE} \
                                 --set image.tag=${params.TAG} \
                                 --wait
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Verifying the deployment in namespace ${params.NAMESPACE}"
                    // Verify that the pods are running in the desired namespace
                    sh "kubectl get pods -n ${params.NAMESPACE}"
                }
            }
        }


        stage('Patch the green deployment') {
            steps {
                script {
                      sh """
                      kubectl patch service green -p '{"spec":{"selector":{"app": "${params.TAG}"}}}'
                      sleep 5
                    

                    """
                }
            }
        }

        stage(' Test the green deployment') {
            steps {
                script {
                      sh """
                       kubectl exec nginx-interactive -- curl --silent --show-error --fail green

                    """
                }
            }
        }

        stage(' Making it live  deployment') {
            steps {
                script {
                      sh """
                      kubectl patch service blue -p '{"spec":{"selector":{"app": "${params.TAG}"}}}'
                      sleep 5

                    """
                }
            }
        }

         stage(' Test the blue deployment') {
            steps {
                script {
                      sh """
                     kubectl exec nginx-interactive -- curl --silent --show-error --fail blue

                    """
                }
            }
        }

            stage('Patch the green deployment back') {
            steps {
                script {
                      sh """
                      kubectl patch service green -p '{"spec":{"selector":{"app": "green"}}}'
                      sleep 5
                    

                    """
                }
            }
        }

        stage(' Remove the old deployment') {
             when {
         expression { params.OLD_RELEASE_NAME != 'NEW_DEPLOYMENT' }
                 }
            steps {
                script {
                      sh """
                      helm uninstall ${params.OLD_RELEASE_NAME}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'deployment succeeded!'
        }
        failure {
            echo 'deployment failed!'
        }
    }
}
