pipeline {
    agent any

    environment {
        // AWS Credentials (Ensure these are set in Jenkins Credentials or here)
        AWS_ACCESS_KEY_ID     = 'AKIAQ2ALM3FHVHCTDFUY'
        AWS_SECRET_ACCESS_KEY = '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'
        TF_VAR_region         = 'us-east-1'
        
        // Docker Config
        DOCKERHUB_NAMESPACE = 'inshafrajaaei'
        IMAGE_TAG           = 'latest'
        
        // Ansible Config (Disable host checking for automation)
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                // Change the branch to your feature branch for testing!
                git branch: 'feature/full-automation', url: 'https://github.com/InshafRajaaei/RYNZA-DevOps-Repo'
            }
        }

        stage('2. Build & Push Images') {
            steps {
                script {
                    // Define Image Names
                    def backendImg  = "${DOCKERHUB_NAMESPACE}/rynza-backend:${IMAGE_TAG}"
                    def frontendImg = "${DOCKERHUB_NAMESPACE}/rynza-frontend:${IMAGE_TAG}"
                    def adminImg    = "${DOCKERHUB_NAMESPACE}/rynza-admin:${IMAGE_TAG}"
                    
                    // Dummy URL for build (Ansible will inject the real one later in .env)
                    def buildUrl = "http://localhost:4000" 

                    echo "Building Backend..."
                    sh "docker build -t $backendImg ./backend"

                    echo "Building Frontend..."
                    sh "docker build --build-arg VITE_BACKEND_URL=\"${buildUrl}\" -t $frontendImg ./frontend"

                    echo "Building Admin Panel..."
                    sh "docker build --build-arg VITE_BACKEND_URL=\"${buildUrl}\" -t $adminImg ./admin-panel"

                    echo "Pushing Images to Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push $backendImg"
                        sh "docker push $frontendImg"
                        sh "docker push $adminImg"
                    }
                }
            }
        }

        stage('3. Provision Infrastructure (Terraform)') {
            steps {
                script {
                    dir('terraform-deploy') {
                        echo "Initializing Terraform..."
                        sh 'terraform init'
                        
                        echo "Applying Terraform (Creating Server)..."
                        sh 'terraform apply -auto-approve'
                        
                        // Capture the IP Address
                        sh 'terraform output -raw server_ip > ../server_ip.txt'
                        
                        // Copy the generated SSH Key to the root so Ansible can find it
                        // Your main.tf creates 'rynza-key.pem' in the current folder
                        sh 'cp rynza-key.pem ../rynza-key.pem'
                    }
                    // Read IP into Groovy variable
                    env.SERVER_IP = readFile('server_ip.txt').trim()
                    
                    // Set permissions for the key (Crucial for SSH)
                    sh 'chmod 400 rynza-key.pem'
                    
                    echo "Infrastructure Ready at IP: ${env.SERVER_IP}"
                }
            }
        }

        stage('4. Wait for Server Initialization') {
            steps {
                echo "Waiting 45 seconds for SSH to wake up..."
                sleep 45
            }
        }

        stage('5. Configure & Deploy (Ansible)') {
            steps {
                script {
                    echo "Deploying to ${env.SERVER_IP} using Ansible..."
                    
                    // Create an inventory file dynamically
                    // We use the 'rynza-key.pem' that Terraform created!
                    sh """
                        echo "${env.SERVER_IP} ansible_user=ubuntu ansible_ssh_private_key_file=./rynza-key.pem" > inventory.ini
                    """

                    // Run Ansible Playbook
                    sh """
                        ansible-playbook -i inventory.ini deploy.yml \
                        -e "docker_registry=${DOCKERHUB_NAMESPACE}" \
                        -e "backend_image_tag=${IMAGE_TAG}" \
                        -e "frontend_image_tag=${IMAGE_TAG}" \
                        -e "admin_image_tag=${IMAGE_TAG}"
                    """
                }
            }
        }
    }
}