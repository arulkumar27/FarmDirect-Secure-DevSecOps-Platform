#!/bin/bash

set -e

echo "=============================================="
echo " FarmDirect DevOps / Jump Server Setup"
echo " Ubuntu 24.04"
echo "=============================================="

# ------------------------------------------------
# 1. SYSTEM UPDATE
# ------------------------------------------------

echo "[1/14] Updating system..."

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# ------------------------------------------------
# 2. BASE TOOLS
# ------------------------------------------------

echo "[2/14] Installing base tools..."

sudo apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    zip \
    jq \
    tree \
    vim \
    nano \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    build-essential \
    net-tools \
    dnsutils \
    htop \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv

# ------------------------------------------------
# 3. AWS CLI
# ------------------------------------------------

echo "[3/14] Installing AWS CLI..."

if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI already installed."
else
    cd /tmp

    curl -fsSL \
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o awscliv2.zip

    unzip -q awscliv2.zip

    sudo ./aws/install

    rm -rf aws awscliv2.zip
fi

aws --version

# ------------------------------------------------
# 4. KUBECTL
# ------------------------------------------------

echo "[4/14] Installing kubectl..."

if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl already installed."
else
    KUBECTL_VERSION=$(curl -L -s \
        https://dl.k8s.io/release/stable.txt)

    curl -LO \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

    curl -LO \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    chmod +x kubectl

    sudo mv kubectl /usr/local/bin/kubectl

    rm -f kubectl.sha256
fi

kubectl version --client

# ------------------------------------------------
# 5. EKSCTL
# ------------------------------------------------

echo "[5/14] Installing eksctl..."

if command -v eksctl >/dev/null 2>&1; then
    echo "eksctl already installed."
else
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH

    curl -sLO \
        "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"

    tar -xzf "eksctl_${PLATFORM}.tar.gz"

    sudo mv eksctl /usr/local/bin/

    rm -f "eksctl_${PLATFORM}.tar.gz"
fi

eksctl version

# ------------------------------------------------
# 6. TERRAFORM
# ------------------------------------------------

echo "[6/14] Installing Terraform..."

if command -v terraform >/dev/null 2>&1; then
    echo "Terraform already installed."
else
    wget -qO- https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com \
      $(. /etc/os-release && echo $VERSION_CODENAME) main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt-get update

    sudo apt-get install -y terraform
fi

terraform version

# ------------------------------------------------
# 7. DOCKER
# ------------------------------------------------

echo "[7/14] Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
else
    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL \
        https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc

    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.asc] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update

    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
fi

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker "$USER"

docker --version
docker compose version

# ------------------------------------------------
# 8. HELM
# ------------------------------------------------

echo "[8/14] Installing Helm..."

if command -v helm >/dev/null 2>&1; then
    echo "Helm already installed."
else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
        | bash
fi

helm version

# ------------------------------------------------
# 9. ANSIBLE
# ------------------------------------------------

echo "[9/14] Installing Ansible..."

if command -v ansible >/dev/null 2>&1; then
    echo "Ansible already installed."
else
    sudo apt-get install -y ansible
fi

ansible --version

# ------------------------------------------------
# 10. TRIVY
# ------------------------------------------------

echo "[10/14] Installing Trivy..."

if command -v trivy >/dev/null 2>&1; then
    echo "Trivy already installed."
else
    sudo apt-get install -y wget gnupg

    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/trivy.gpg >/dev/null

    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
        https://aquasecurity.github.io/trivy-repo/deb \
        generic main" \
        | sudo tee /etc/apt/sources.list.d/trivy.list

    sudo apt-get update

    sudo apt-get install -y trivy
fi

trivy --version

# ------------------------------------------------
# 11. GITLEAKS
# ------------------------------------------------

echo "[11/14] Installing Gitleaks..."

if command -v gitleaks >/dev/null 2>&1; then
    echo "Gitleaks already installed."
else
    GITLEAKS_VERSION=$(curl -s \
        https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
        | jq -r '.tag_name' \
        | sed 's/^v//')

    cd /tmp

    wget -q \
        "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"

    tar -xzf \
        "gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"

    sudo mv gitleaks /usr/local/bin/gitleaks

    rm -f \
        "gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
fi

gitleaks version

# ------------------------------------------------
# 12. NODE.JS 22
# ------------------------------------------------

echo "[12/14] Installing Node.js..."

if command -v node >/dev/null 2>&1; then
    echo "Node.js already installed."
else
    curl -fsSL https://deb.nodesource.com/setup_22.x \
        | sudo -E bash -

    sudo apt-get install -y nodejs
fi

node --version
npm --version

# ------------------------------------------------
# 13. JAVA 21
# ------------------------------------------------

echo "[13/14] Installing Java 21..."

sudo apt-get install -y openjdk-21-jdk

java -version

# ------------------------------------------------
# 14. JENKINS
# ------------------------------------------------

echo "[14/14] Installing Jenkins..."

if systemctl list-unit-files | grep -q "^jenkins.service"; then

    echo "Jenkins already installed."

else

    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
        https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
        https://pkg.jenkins.io/debian-stable binary/" \
        | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

    sudo apt-get update

    sudo apt-get install -y jenkins
fi

sudo systemctl enable jenkins
sudo systemctl start jenkins

# Allow Jenkins to use Docker
sudo usermod -aG docker jenkins

# ------------------------------------------------
# SONARQUBE
# ------------------------------------------------

echo ""
echo "=============================================="
echo " Installing SonarQube"
echo "=============================================="

SONAR_DIR="/opt/sonarqube"

if [ -d "$SONAR_DIR" ]; then

    echo "SonarQube directory already exists."

else

    cd /tmp

    SONAR_VERSION="25.9.0.112764"

    wget -q \
        "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip" \
        -O sonarqube.zip

    sudo unzip -q sonarqube.zip -d /opt

    sudo mv \
        "/opt/sonarqube-${SONAR_VERSION}" \
        "$SONAR_DIR"

    sudo useradd \
        --system \
        --home "$SONAR_DIR" \
        --shell /bin/bash \
        sonarqube 2>/dev/null || true

    sudo chown -R sonarqube:sonarqube "$SONAR_DIR"

    rm -f sonarqube.zip
fi

# ------------------------------------------------
# SONARQUBE SERVICE
# ------------------------------------------------

echo "Creating SonarQube systemd service..."

sudo tee /etc/systemd/system/sonarqube.service >/dev/null <<'EOF'
[Unit]
Description=SonarQube
After=network.target

[Service]
Type=forking

User=sonarqube
Group=sonarqube

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# ------------------------------------------------
# DOCKER PERMISSION
# ------------------------------------------------

echo ""
echo "Configuring Docker permissions..."

sudo usermod -aG docker "$USER"
sudo usermod -aG docker jenkins

# ------------------------------------------------
# KUBECTL AUTOCOMPLETION
# ------------------------------------------------

echo "Configuring kubectl completion..."

cat <<'EOF' >> ~/.bashrc

# Kubernetes
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

EOF

# ------------------------------------------------
# HELM REPOSITORIES
# ------------------------------------------------

echo "Adding Helm repositories..."

helm repo add prometheus-community \
    https://prometheus-community.github.io/helm-charts || true

helm repo add ingress-nginx \
    https://kubernetes.github.io/ingress-nginx || true

helm repo update

# ------------------------------------------------
# FINAL VERIFICATION
# ------------------------------------------------

echo ""
echo "=============================================="
echo " INSTALLATION COMPLETE"
echo "=============================================="

echo ""
echo "Git:"
git --version

echo ""
echo "AWS CLI:"
aws --version

echo ""
echo "Kubectl:"
kubectl version --client

echo ""
echo "EKSCTL:"
eksctl version

echo ""
echo "Terraform:"
terraform version

echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker Compose:"
docker compose version

echo ""
echo "Helm:"
helm version

echo ""
echo "Ansible:"
ansible --version | head -1

echo ""
echo "Trivy:"
trivy --version

echo ""
echo "Gitleaks:"
gitleaks version

echo ""
echo "Node:"
node --version

echo ""
echo "NPM:"
npm --version

echo ""
echo "Java:"
java -version

echo ""
echo "Jenkins:"
sudo systemctl --no-pager status jenkins | head -10

echo ""
echo "SonarQube:"
sudo systemctl --no-pager status sonarqube | head -10

echo ""
echo "=============================================="
echo " IMPORTANT"
echo "=============================================="

echo ""
echo "1. Log out and SSH back in so Docker group changes apply."
echo ""
echo "2. Jenkins URL:"
echo "   http://<JENKINS_SERVER_PUBLIC_IP>:8080"
echo ""
echo "3. SonarQube URL:"
echo "   http://<JENKINS_SERVER_PUBLIC_IP>:9000"
echo ""
echo "4. Get Jenkins initial password:"
echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "5. Check services:"
echo "   sudo systemctl status jenkins"
echo "   sudo systemctl status sonarqube"
echo ""
echo "6. AWS authentication:"
echo "   aws sts get-caller-identity"
echo ""
echo "=============================================="