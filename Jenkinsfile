pipeline {
    agent any

    triggers {
        pollSCM '* * * * *' 
    }

    environment {

        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        TF_VAR_region         = 'us-east-1'
        
        DOCKERHUB_NAMESPACE       = 'inshafrajaaei'
        IMAGE_TAG                 = 'latest'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                git branch: 'feature/full-automation', url: 'https://github.com/InshafRajaaei/RYNZA-DevOps-Repo'
            }
        }

        stage('2. Provision Infrastructure (Terraform)') {
            steps {
                script {
                    dir('terraform-deploy') {
                        echo "Initializing Terraform..."
                        sh 'terraform init'
                        
                        echo "Applying Terraform..."
                        sh 'terraform apply -auto-approve'
                        
                        sh 'terraform output -raw server_ip > ../server_ip.txt'
                        
                        sh 'rm -f ../rynza-key.pem'
                        sh 'cp rynza-key.pem ../rynza-key.pem'
                    }
                    env.SERVER_IP = readFile('server_ip.txt').trim()
                    sh 'chmod 400 rynza-key.pem'
                    
                    echo "Infrastructure Ready at IP: ${env.SERVER_IP}"
                }
            }
        }

        stage('3. Build & Push Images') {
            steps {
                script {
                    def backendImg  = "${DOCKERHUB_NAMESPACE}/rynza-backend:${IMAGE_TAG}"
                    def frontendImg = "${DOCKERHUB_NAMESPACE}/rynza-frontend:${IMAGE_TAG}"
                    def adminImg    = "${DOCKERHUB_NAMESPACE}/rynza-admin:${IMAGE_TAG}"
                    
                    def realBackendUrl = "http://${env.SERVER_IP}:4000"
                    
                    echo "Building Backend..."
                    sh "docker build -t $backendImg ./backend"

                    echo "Building Frontend with API: ${realBackendUrl}"
                    sh "docker build --build-arg VITE_BACKEND_URL=\"${realBackendUrl}\" -t $frontendImg ./frontend"

                    echo "Building Admin Panel with API: ${realBackendUrl}"
                    sh "docker build --build-arg VITE_BACKEND_URL=\"${realBackendUrl}\" -t $adminImg ./admin-panel"

                    echo "Pushing Images..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push $backendImg"
                        sh "docker push $frontendImg"
                        sh "docker push $adminImg"
                    }
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
                withCredentials([
                    string(credentialsId: 'rynza-mongo-url', variable: 'MONGO_URL'),
                    string(credentialsId: 'rynza-stripe-key', variable: 'STRIPE_KEY'),
                    string(credentialsId: 'rynza-cloudinary-secret', variable: 'CLOUD_SECRET'),
                    string(credentialsId: 'rynza-jwt-secret', variable: 'JWT_SECRET'),
                    string(credentialsId: 'rynza-admin-password', variable: 'ADMIN_PASS')
                ]) {
                    script {
                        echo "Deploying to ${env.SERVER_IP}..."
                        
                        sh """
                            echo "${env.SERVER_IP} ansible_user=ubuntu ansible_ssh_private_key_file=./rynza-key.pem" > inventory.ini
                        """

                        sh """
                            ansible-playbook -i inventory.ini deploy.yml \
                            -e "docker_registry=${DOCKERHUB_NAMESPACE}" \
                            -e "backend_image_tag=${IMAGE_TAG}" \
                            -e "frontend_image_tag=${IMAGE_TAG}" \
                            -e "admin_image_tag=${IMAGE_TAG}" \
                            -e "mongodb_url=${MONGO_URL}" \
                            -e "stripe_secret_key=${STRIPE_KEY}" \
                            -e "cloudinary_secret_key=${CLOUD_SECRET}" \
                            -e "jwt_secret=${JWT_SECRET}" \
                            -e "admin_password=${ADMIN_PASS}" \
                            -e "cloudinary_api_key=344298332585696" \
                            -e "cloudinary_name=dtif0kosd" \
                            -e "admin_email=rynza@gmail.com"
                        """
                    }
                }
            }
        }
    }
}