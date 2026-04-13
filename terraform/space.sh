#!/bin/bash
set -eu
echo "=== Initial disk layout ==="
lsblk
# Install required package (RHEL uses dnf/yum)
dnf install -y cloud-utils-growpart || yum install -y cloud-utils-growpart

# Expand partition 4
growpart /dev/nvme0n1 4

echo "=== After growpart ==="
lsblk

# Resize physical volume
pvresize /dev/nvme0n1p4

# Show volume group free space
vgdisplay RootVG

#========#

# Extend /var to 20GB TOTAL
lvextend -L 30G /dev/RootVG/varVol

# Resize filesystem (RHEL uses XFS here)
xfs_growfs /var

echo "=== Final disk usage ==="
df -hT

sudo dnf -y install dnf-plugins-core

sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl start docker

sudo systemctl enable docker

sudo usermod -aG docker ec2-user

docker --version

# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH


curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl


curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Install kubens (namespace switcher)
sudo curl -sL https://github.com/ahmetb/kubectx/releases/latest/download/kubens -o /usr/local/bin/kubens
sudo chmod +x /usr/local/bin/kubens

# Install k9s (Kubernetes TUI)
curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz -o k9s.tar.gz
tar -xzf k9s.tar.gz -C /tmp && rm k9s.tar.gz
sudo install -m 0755 /tmp/k9s /usr/local/bin/k9s && rm /tmp/k9s

# AWS CLI configure for ec2-user
mkdir -p /home/ec2-user/.aws
cat <<EOF > /home/ec2-user/.aws/credentials
[default]
aws_access_key_id = ${aws_access_key}
aws_secret_access_key = ${aws_secret_key}
EOF

cat <<EOF > /home/ec2-user/.aws/config
[default]
region = us-east-1
output = json
EOF

chown -R ec2-user:ec2-user /home/ec2-user/.aws
chmod 600 /home/ec2-user/.aws/credentials
chmod 600 /home/ec2-user/.aws/config

# Clone eksctl repo and create EKS cluster
cd /home/ec2-user
sudo -u ec2-user git clone https://github.com/viho-kernel/ekstcl.git
cd ekstcl
sudo -u ec2-user /usr/local/bin/eksctl create cluster -f eks.yaml

# Authenticate kubectl with the cluster
sudo -u ec2-user aws eks update-kubeconfig --region us-east-1 --name roboshop
sudo -u ec2-user /usr/local/bin/kubectl get nodes