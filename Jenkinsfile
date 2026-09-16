pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    parameters {
        string(
            name: 'BACKEND_IMAGE_TAG',
            defaultValue: '12',
            description: 'Must match backend_image_tag currently used by Terraform production.'
        )

        string(
            name: 'FRONTEND_IMAGE_TAG',
            defaultValue: '17',
            description: 'Must match frontend_image_tag currently used by Terraform production.'
        )
    }

    environment {
        PROJECT_DIR = 'Project-04-FarmDirect-Secure-DevSecOps-Platform'
        AWS_REGION = 'ap-south-1'
        PRODUCTION_DOMAIN = 'https://farmdirect.blacktunes.in'

        DOCKER_EXE = 'C:/Users/Madhankumar/AppData/Local/Programs/DockerDesktop/resources/bin/docker.exe'
        DOCKER_COMPOSE_EXE = 'C:/Users/Madhankumar/AppData/Local/Programs/DockerDesktop/resources/bin/docker-compose.exe'
        KUBECTL_EXE = 'C:/Users/Madhankumar/AppData/Local/Programs/DockerDesktop/resources/bin/kubectl.exe'
        KIND_EXE = 'C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/Kubernetes.kind_Microsoft.Winget.Source_8wekyb3d8bbwe/kind.exe'
    }

    stages {
        stage('Secret Scan - Gitleaks') {
            steps {
                dir("${PROJECT_DIR}") {
                    bat '"C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/Gitleaks.Gitleaks_Microsoft.Winget.Source_8wekyb3d8bbwe/gitleaks.exe" detect --source . --no-git --redact'
                }
            }
        }

        stage('AWS Deployment Preflight') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'farmdirect-aws-deployer'
                ]]) {
                    bat '''
                    aws --version
                    aws sts get-caller-identity --region %AWS_REGION%
                    '''
                }
            }
        }

        stage('Terraform Production State Access') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'farmdirect-aws-deployer'
                ]]) {
                    dir("${PROJECT_DIR}/terraform") {
                        bat '''
                        terraform -chdir=environments/production init -input=false
                        terraform -chdir=environments/production state list
                        '''
                    }
                }
            }
        }

        stage('ECR Deployment Preflight') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'farmdirect-aws-deployer'
                ]]) {
                    bat '''
                    aws ecr describe-repositories ^
                      --region %AWS_REGION% ^
                      --repository-names farmdirect-production-backend farmdirect-production-frontend ^
                      --query "repositories[].repositoryUri" ^
                      --output table
                    '''
                }
            }
        }

        stage('Terraform Format and Validate') {
            steps {
                dir("${PROJECT_DIR}/terraform") {
                    bat '''
                    terraform fmt -check -recursive
                    terraform -chdir=environments/staging init -backend=false
                    terraform -chdir=environments/staging validate
                    '''
                }
            }
        }

        stage('IaC Security Scan - Trivy') {
            steps {
                dir("${PROJECT_DIR}/terraform") {
                    bat '"C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe/trivy.exe" config --severity HIGH,CRITICAL --exit-code 0 --quiet .'
                }
            }
        }

        stage('Backend Dependencies') {
            steps {
                dir("${PROJECT_DIR}/app/backend") {
                    bat 'npm install'
                }
            }
        }

        stage('Backend Tests') {
            steps {
                dir("${PROJECT_DIR}/app/backend") {
                    bat 'npm test -- --coverage'
                }
            }
        }

        stage('Frontend Production Build') {
            steps {
                dir("${PROJECT_DIR}/app/frontend") {
                    bat 'npm install'
                    bat 'npm run build'
                }
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                dir("${PROJECT_DIR}") {
                    script {
                        def scannerHome = tool 'SonarScanner'

                        withSonarQubeEnv('SonarQube-Local') {
                            bat "\"${scannerHome}\\bin\\sonar-scanner.bat\""
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Prepare Staging Configuration') {
            steps {
                dir("${PROJECT_DIR}") {
                    bat 'copy /Y docker\\.env.example docker\\.env'
                }
            }
        }

        stage('Docker Image Build') {
            steps {
                dir("${PROJECT_DIR}/docker") {
                    bat 'set DOCKER_HOST=npipe:////./pipe/dockerDesktopLinuxEngine && "%DOCKER_COMPOSE_EXE%" -p farmdirect-staging -f docker-compose.yml -f docker-compose.staging.yml build --pull'
                }
            }
        }

        stage('Container Security Scan - Trivy') {
            steps {
                bat '"C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe/trivy.exe" image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 0 farmdirect-staging-backend'

                bat '"C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe/trivy.exe" image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 0 farmdirect-staging-frontend'

                bat '"C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe/trivy.exe" image --scanners vuln --severity CRITICAL --ignore-unfixed --exit-code 1 farmdirect-staging-backend'

                bat '"C:/Users/Madhankumar/AppData/Local/Microsoft/WinGet/Packages/AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe/trivy.exe" image --scanners vuln --severity CRITICAL --ignore-unfixed --exit-code 1 farmdirect-staging-frontend'
            }
        }

        stage('Deploy to Docker Compose Staging') {
            steps {
                dir("${PROJECT_DIR}/docker") {
                    bat 'set DOCKER_HOST=npipe:////./pipe/dockerDesktopLinuxEngine && "%DOCKER_COMPOSE_EXE%" -p farmdirect-staging -f docker-compose.yml -f docker-compose.staging.yml up -d'
                }
            }
        }

        stage('Docker Compose Staging Smoke Test') {
            steps {
                bat '''
                @echo off
                set attempt=0

                :retry
                set /a attempt=attempt+1

                curl.exe --fail --silent http://localhost:5001/api/health
                if not errorlevel 1 goto passed

                if %attempt% GEQ 12 goto failed

                echo Backend is not ready. Waiting 5 seconds before retry %attempt% of 12...
                timeout /t 5 /nobreak >nul
                goto retry

                :passed
                echo Docker Compose staging health check passed.
                exit /b 0

                :failed
                echo Docker Compose staging health check failed after 12 attempts.
                exit /b 1
                '''
            }
        }

        stage('Deploy to Local Kubernetes') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'farmdirect-kind-kubeconfig',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    dir("${PROJECT_DIR}") {
                        bat '''
                        @echo off
                        setlocal
                        set DOCKER_HOST=npipe:////./pipe/dockerDesktopLinuxEngine
                        set "PATH=C:/Users/Madhankumar/AppData/Local/Programs/DockerDesktop/resources/bin;%PATH%"

                        "%DOCKER_EXE%" tag farmdirect-staging-backend:latest farmdirect-staging-backend:%BUILD_NUMBER% || exit /b 1
                        "%DOCKER_EXE%" tag farmdirect-staging-frontend:latest farmdirect-staging-frontend:%BUILD_NUMBER% || exit /b 1

                        "%DOCKER_EXE%" save --output "%WORKSPACE%\\farmdirect-backend-%BUILD_NUMBER%.tar" farmdirect-staging-backend:%BUILD_NUMBER% || exit /b 1
                        "%DOCKER_EXE%" save --output "%WORKSPACE%\\farmdirect-frontend-%BUILD_NUMBER%.tar" farmdirect-staging-frontend:%BUILD_NUMBER% || exit /b 1

                        "%KIND_EXE%" load image-archive "%WORKSPACE%\\farmdirect-backend-%BUILD_NUMBER%.tar" --name farmdirect || exit /b 1
                        "%KIND_EXE%" load image-archive "%WORKSPACE%\\farmdirect-frontend-%BUILD_NUMBER%.tar" --name farmdirect || exit /b 1

                        del /q "%WORKSPACE%\\farmdirect-backend-%BUILD_NUMBER%.tar"
                        del /q "%WORKSPACE%\\farmdirect-frontend-%BUILD_NUMBER%.tar"

                        "%KUBECTL_EXE%" apply -k kubernetes/base || exit /b 1

                        "%KUBECTL_EXE%" -n farmdirect set image deployment/backend backend=farmdirect-staging-backend:%BUILD_NUMBER% || exit /b 1
                        "%KUBECTL_EXE%" -n farmdirect set image deployment/frontend frontend=farmdirect-staging-frontend:%BUILD_NUMBER% || exit /b 1

                        "%KUBECTL_EXE%" rollout status deployment/backend -n farmdirect --timeout=180s || exit /b 1
                        "%KUBECTL_EXE%" rollout status deployment/frontend -n farmdirect --timeout=180s || exit /b 1

                        "%KUBECTL_EXE%" get pods -n farmdirect || exit /b 1
                        '''
                    }
                }
            }
        }

        stage('Kubernetes Smoke Test') {
            steps {
                bat 'curl.exe --fail --silent http://localhost:8083/api/health'
            }
        }

        stage('Manual Production Approval') {
            steps {
                input(
                    message: 'Staging and Kubernetes checks passed. Approve FarmDirect AWS production release?',
                    ok: 'Approve AWS release'
                )
            }
        }

        stage('Build and Push Production Images to ECR') {
            steps {
                script {
                    def backendTag = params.BACKEND_IMAGE_TAG?.trim() ?: '12'
                    def frontendTag = params.FRONTEND_IMAGE_TAG?.trim() ?: '17'

                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'farmdirect-aws-deployer'
                    ]]) {
                        dir("${PROJECT_DIR}") {
                            bat """
                            @echo off
                            setlocal

                            set BACKEND_TAG=${backendTag}
                            set FRONTEND_TAG=${frontendTag}

                            echo Backend image tag: %BACKEND_TAG%
                            echo Frontend image tag: %FRONTEND_TAG%

                            for /f %%A in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT_ID=%%A

                            set ECR_REGISTRY=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
                            set BACKEND_REPOSITORY=%ECR_REGISTRY%/farmdirect-production-backend
                            set FRONTEND_REPOSITORY=%ECR_REGISTRY%/farmdirect-production-frontend
                            set DOCKER_CONFIG=%WORKSPACE%\\farmdirect-ecr-auth

                            if exist "%DOCKER_CONFIG%" rmdir /s /q "%DOCKER_CONFIG%"
                            mkdir "%DOCKER_CONFIG%"

                            aws ecr get-login-password --region %AWS_REGION% | "%DOCKER_EXE%" --config "%DOCKER_CONFIG%" login --username AWS --password-stdin %ECR_REGISTRY% || exit /b 1

                            "%DOCKER_EXE%" build --pull -t farmdirect-production-backend:%BACKEND_TAG% app\\backend || exit /b 1
                            "%DOCKER_EXE%" build --pull -t farmdirect-production-frontend:%FRONTEND_TAG% app\\frontend || exit /b 1

                            "%DOCKER_EXE%" tag farmdirect-production-backend:%BACKEND_TAG% %BACKEND_REPOSITORY%:%BACKEND_TAG% || exit /b 1
                            "%DOCKER_EXE%" tag farmdirect-production-frontend:%FRONTEND_TAG% %FRONTEND_REPOSITORY%:%FRONTEND_TAG% || exit /b 1

                            "%DOCKER_EXE%" --config "%DOCKER_CONFIG%" push %BACKEND_REPOSITORY%:%BACKEND_TAG% || exit /b 1
                            "%DOCKER_EXE%" --config "%DOCKER_CONFIG%" push %FRONTEND_REPOSITORY%:%FRONTEND_TAG% || exit /b 1
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy to AWS ECS Production') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'farmdirect-aws-deployer'
                ]]) {
                    bat '''
                    @echo off

                    aws ecs update-service --region %AWS_REGION% --cluster farmdirect-production-cluster --service farmdirect-production-backend --force-new-deployment >nul || exit /b 1
                    aws ecs update-service --region %AWS_REGION% --cluster farmdirect-production-cluster --service farmdirect-production-frontend --force-new-deployment >nul || exit /b 1

                    aws ecs wait services-stable --region %AWS_REGION% --cluster farmdirect-production-cluster --services farmdirect-production-backend farmdirect-production-frontend || exit /b 1

                    aws ecs describe-services --region %AWS_REGION% --cluster farmdirect-production-cluster --services farmdirect-production-backend farmdirect-production-frontend --query "services[].{Service:serviceName,Desired:desiredCount,Running:runningCount,Pending:pendingCount}" --output table || exit /b 1
                    '''
                }
            }
        }

        stage('AWS Production Smoke Test') {
            steps {
                bat 'curl.exe --fail --silent --show-error --retry 12 --retry-delay 5 %PRODUCTION_DOMAIN%/api/health'
            }
        }
    }

    post {
        success {
            echo 'FarmDirect CI checks, local staging, Kubernetes verification, ECR image publishing, and AWS ECS production deployment completed.'
        }

        failure {
            echo 'Pipeline failed. Check the failed stage logs before retrying.'
        }
    }
}