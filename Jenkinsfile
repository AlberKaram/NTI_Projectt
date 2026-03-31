pipeline {
    agent any

    environment {
        AWS_REGION      = 'us-east-2'
        ECR_REGISTRY    = '698995615790.dkr.ecr.us-east-2.amazonaws.com'
        ECR_REPO        = 'nti-app-repo'
        EKS_CLUSTER     = 'nti-eks-cluster'
        IMAGE_TAG       = "v${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Pulling code from GitHub...'
                checkout scm
            }
        }

        stage('Build API Image') {
            steps {
                echo '🔨 Building API Docker image...'
                sh """
                    docker build -t ${ECR_REGISTRY}/${ECR_REPO}:api-${IMAGE_TAG} ./app/api
                    docker tag ${ECR_REGISTRY}/${ECR_REPO}:api-${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO}:api-latest
                """
            }
        }

        stage('Build Web Image') {
            steps {
                echo '🔨 Building Web Docker image...'
                sh """
                    docker build -t ${ECR_REGISTRY}/${ECR_REPO}:web-${IMAGE_TAG} ./app/web
                    docker tag ${ECR_REGISTRY}/${ECR_REPO}:web-${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO}:web-latest
                """
            }
        }

        stage('Push to ECR') {
            steps {
                echo '📤 Pushing images to ECR...'
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}

                        docker push ${ECR_REGISTRY}/${ECR_REPO}:api-${IMAGE_TAG}
                        docker push ${ECR_REGISTRY}/${ECR_REPO}:api-latest
                        docker push ${ECR_REGISTRY}/${ECR_REPO}:web-${IMAGE_TAG}
                        docker push ${ECR_REGISTRY}/${ECR_REPO}:web-latest
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo '🚀 Deploying to EKS with Helm...'
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh """
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                        helm upgrade --install nti-prod ./helm \
                            --set api.image.tag=api-${IMAGE_TAG} \
                            --set web.image.tag=web-${IMAGE_TAG} \
                            --wait
                    """
                }
            }
        }

    }

    post {
        success {
            echo '✅ Pipeline succeeded! App deployed successfully.'
        }
        failure {
            echo '❌ Pipeline failed! Check the logs above.'
        }
    }
}
