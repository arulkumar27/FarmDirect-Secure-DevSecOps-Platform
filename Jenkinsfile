pipeline {
    agent any

    environment {
        AWS_REGION    = 'ap-south-1'
        EKS_CLUSTER   = 'farmdirect-production'
        NAMESPACE     = 'farmdirect'

        BACKEND_IMAGE  = 'farmdirect-backend'
        FRONTEND_IMAGE = 'farmdirect-frontend'

        AWS_CREDENTIALS = 'aws-jenkins'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test & Build') {
            steps {
                sh '''
                    set -e

                    echo "=== Backend ==="
                    cd app/backend
                    npm ci
                    npm test -- --passWithNoTests

                    echo "=== Frontend ==="
                    cd ../frontend
                    npm ci
                    npm run build
                '''
            }
        }

        stage('Security') {
            steps {
                sh '''
                    set -e

                    echo "=== Gitleaks ==="
                    gitleaks detect --source . --no-banner --redact

                    echo "=== Trivy Filesystem Scan ==="
                    trivy fs --severity HIGH,CRITICAL --exit-code 0 .
                '''
            }
        }

        stage('SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        if [ -f sonar-project.properties ]; then
                            sonar-scanner
                        else
                            echo "SonarQube configuration not found - skipping"
                        fi
                    '''
                }
            }
        }

        stage('Docker Build & Scan') {
            steps {
                sh '''
                    set -e

                    docker build \
                        -f docker/backend/Dockerfile \
                        -t $BACKEND_IMAGE:$IMAGE_TAG .

                    docker build \
                        -f docker/frontend/Dockerfile \
                        -t $FRONTEND_IMAGE:$IMAGE_TAG .

                    echo "=== Backend Image Scan ==="
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        $BACKEND_IMAGE:$IMAGE_TAG

                    echo "=== Frontend Image Scan ==="
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        $FRONTEND_IMAGE:$IMAGE_TAG
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${AWS_CREDENTIALS}"]
                ]) {
                    sh '''
                        set -e

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account \
                            --output text)

                        ECR="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

                        aws ecr get-login-password \
                            --region "$AWS_REGION" |
                        docker login \
                            --username AWS \
                            --password-stdin "$ECR"

                        docker tag \
                            $BACKEND_IMAGE:$IMAGE_TAG \
                            $ECR/$BACKEND_IMAGE:$IMAGE_TAG

                        docker tag \
                            $FRONTEND_IMAGE:$IMAGE_TAG \
                            $ECR/$FRONTEND_IMAGE:$IMAGE_TAG

                        docker push \
                            $ECR/$BACKEND_IMAGE:$IMAGE_TAG

                        docker push \
                            $ECR/$FRONTEND_IMAGE:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: "${AWS_CREDENTIALS}"]
                ]) {
                    sh '''
                        set -e

                        aws eks update-kubeconfig \
                            --region "$AWS_REGION" \
                            --name "$EKS_CLUSTER"

                        kubectl apply -k kubernetes/base

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account \
                            --output text)

                        ECR="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

                        kubectl -n "$NAMESPACE" set image \
                            deployment/backend \
                            backend=$ECR/$BACKEND_IMAGE:$IMAGE_TAG

                        kubectl -n "$NAMESPACE" set image \
                            deployment/frontend \
                            frontend=$ECR/$FRONTEND_IMAGE:$IMAGE_TAG

                        kubectl -n "$NAMESPACE" rollout status \
                            deployment/backend \
                            --timeout=5m

                        kubectl -n "$NAMESPACE" rollout status \
                            deployment/frontend \
                            --timeout=5m
                    '''
                }
            }
        }

        stage('Verify') {
            steps {
                sh '''
                    echo "=== Nodes ==="
                    kubectl get nodes

                    echo "=== Pods ==="
                    kubectl get pods -n "$NAMESPACE"

                    echo "=== Services ==="
                    kubectl get svc -n "$NAMESPACE"

                    echo "=== Deployments ==="
                    kubectl get deployments -n "$NAMESPACE"
                '''
            }
        }
    }

    post {
        success {
            echo 'FarmDirect deployment completed successfully.'
        }

        failure {
            echo 'FarmDirect deployment failed. Check the failed stage.'
        }
    }
}