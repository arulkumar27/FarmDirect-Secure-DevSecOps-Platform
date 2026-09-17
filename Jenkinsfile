```groovy
pipeline {
    agent any

    environment {
        // Docker image names
        BACKEND_IMAGE  = "farmdirect-backend"
        FRONTEND_IMAGE = "farmdirect-frontend"

        // Kubernetes
        K8S_NAMESPACE = "farmdirect"

        // Kind cluster for local Jenkins/Kubernetes deployment
        KIND_CLUSTER = "farmdirect"

        // Image tag generated from Jenkins build number
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Project Structure') {
            steps {
                bat '''
                    echo ==============================
                    echo Checking FarmDirect structure
                    echo ==============================

                    if not exist app (
                        echo ERROR: app directory not found
                        exit /b 1
                    )

                    if not exist app\\backend (
                        echo ERROR: backend directory not found
                        exit /b 1
                    )

                    if not exist app\\frontend (
                        echo ERROR: frontend directory not found
                        exit /b 1
                    )

                    if not exist kubernetes (
                        echo ERROR: kubernetes directory not found
                        exit /b 1
                    )

                    if not exist docker (
                        echo ERROR: docker directory not found
                        exit /b 1
                    )

                    echo Project structure OK.
                '''
            }
        }

        stage('Backend Dependencies') {
            steps {
                dir('app/backend') {
                    bat 'npm ci'
                }
            }
        }

        stage('Backend Tests') {
            steps {
                dir('app/backend') {
                    bat 'npm test -- --passWithNoTests'
                }
            }
        }

        stage('Frontend Dependencies') {
            steps {
                dir('app/frontend') {
                    bat 'npm ci'
                }
            }
        }

        stage('Frontend Build') {
            steps {
                dir('app/frontend') {
                    bat 'npm run build'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube analysis...'

                // Requires SonarScanner to be installed/configured
                // in the Jenkins agent PATH.
                bat '''
                    if exist sonar-project.properties (
                        sonar-scanner
                    ) else (
                        echo sonar-project.properties not found.
                        echo Skipping SonarQube analysis.
                    )
                '''
            }
        }

        stage('Secret Scan') {
            steps {
                echo 'Running Gitleaks secret scan...'

                bat '''
                    gitleaks detect --source . --no-banner --redact
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                echo "Building Docker images with tag ${IMAGE_TAG}..."

                bat """
                    docker build -t %BACKEND_IMAGE%:%IMAGE_TAG% -f app/backend/Dockerfile app/backend
                    docker build -t %FRONTEND_IMAGE%:%IMAGE_TAG% -f app/frontend/Dockerfile app/frontend
                """
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo 'Scanning Docker images with Trivy...'

                bat """
                    trivy image --exit-code 1 --severity HIGH,CRITICAL %BACKEND_IMAGE%:%IMAGE_TAG%
                    trivy image --exit-code 1 --severity HIGH,CRITICAL %FRONTEND_IMAGE%:%IMAGE_TAG%
                """
            }
        }

        stage('Prepare Kind Cluster') {
            steps {
                echo "Preparing Kind cluster: ${KIND_CLUSTER}"

                bat '''
                    kind get clusters
                '''

                bat """
                    kind get clusters | findstr /I "%KIND_CLUSTER%" >nul
                    if errorlevel 1 (
                        echo Creating Kind cluster...
                        kind create cluster --name %KIND_CLUSTER%
                    ) else (
                        echo Kind cluster already exists.
                    )
                """
            }
        }

        stage('Load Images into Kind') {
            steps {
                echo 'Loading Docker images into Kind...'

                bat """
                    kind load docker-image %BACKEND_IMAGE%:%IMAGE_TAG% --name %KIND_CLUSTER%
                    kind load docker-image %FRONTEND_IMAGE%:%IMAGE_TAG% --name %KIND_CLUSTER%
                """
            }
        }

        stage('Create Kubernetes Namespace') {
            steps {
                bat '''
                    kubectl apply -f kubernetes/base/namespace.yaml
                '''
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                echo 'Deploying FarmDirect application to Kubernetes...'

                bat '''
                    kubectl apply -k kubernetes/base
                '''
            }
        }

        stage('Update Application Images') {
            steps {
                echo 'Updating Kubernetes deployments with current build images...'

                bat """
                    kubectl -n %K8S_NAMESPACE% set image deployment/backend backend=%BACKEND_IMAGE%:%IMAGE_TAG%
                    kubectl -n %K8S_NAMESPACE% set image deployment/frontend frontend=%FRONTEND_IMAGE%:%IMAGE_TAG%
                """
            }
        }

        stage('Wait for Rollout') {
            steps {
                echo 'Waiting for Kubernetes deployments...'

                bat """
                    kubectl -n %K8S_NAMESPACE% rollout status deployment/backend --timeout=180s
                    kubectl -n %K8S_NAMESPACE% rollout status deployment/frontend --timeout=180s
                """
            }
        }

        stage('Verify Kubernetes') {
            steps {
                echo 'Checking Kubernetes resources...'

                bat '''
                    kubectl get nodes
                    kubectl get pods -n %K8S_NAMESPACE%
                    kubectl get services -n %K8S_NAMESPACE%
                    kubectl get deployments -n %K8S_NAMESPACE%
                '''
            }
        }
    }

    post {

        success {
            echo '''
            ==========================================
            FarmDirect Pipeline Completed Successfully
            ==========================================
            '''
        }

        failure {
            echo '''
            ==========================================
            FarmDirect Pipeline Failed
            Check the stage logs for the failure.
            ==========================================
            '''
        }

        always {
            echo 'Pipeline execution completed.'
        }
    }
}
```
