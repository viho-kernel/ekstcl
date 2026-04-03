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


curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.2/2026-02-27/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
