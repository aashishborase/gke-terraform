pipeline {
    agent any

    parameters {
        choice(name: 'TERRAFORM_ACTION', 
               choices: ['plan', 'apply', 'destroy'], 
               description: 'Select Terraform action to perform')
    }

    environment {
        // Replace with your specific Terraform configuration directory
        TF_WORKING_DIR = './fraud_detection/terraform'   // Path where your Terraform files are located
    }

    stages {
        stage('Initialize Terraform') {
            steps {
                script {
                    // Initialize Terraform (this is needed before any plan/apply/destroy)
                    dir(TF_WORKING_DIR) {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.TERRAFORM_ACTION == 'plan' }
            }
            steps {
                script {
                    // Run Terraform Plan
                    dir(TF_WORKING_DIR) {
                        sh 'terraform plan -var-file=dev.tfvars'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.TERRAFORM_ACTION == 'apply' }
            }
            steps {
                script {
                    // Run Terraform Apply
                    dir(TF_WORKING_DIR) {
                        sh 'terraform apply -var-file=dev.tfvars -auto-approve'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.TERRAFORM_ACTION == 'destroy' }
            }
            steps {
                script {
                    // Run Terraform Destroy
                    dir(TF_WORKING_DIR) {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Terraform action '${params.TERRAFORM_ACTION}' completed."
        }
        success {
            echo 'Terraform operation succeeded!'
        }
        failure {
            echo 'Terraform operation failed!'
        }
    }
}
