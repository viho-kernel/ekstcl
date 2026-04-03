# EC2 User Data Setup: Disk Expansion + Docker + Kubernetes Tools

This repository contains a `user_data` script designed for **RHEL-based Amazon EC2 instances**.  
It automates disk expansion for `/var`, installs Docker, and sets up Kubernetes tooling (`kubectl` and `eksctl`).

---

## 🚀 What the Script Does

1. **Disk Expansion**
   - Installs `cloud-utils-growpart`.
   - Expands partition `/dev/nvme0n1p4`.
   - Resizes the physical volume and logical volume (`RootVG/varVol`).
   - Extends `/var` filesystem (XFS) to the desired size.

2. **Docker Installation**
   - Adds the official Docker CE repository.
   - Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, and `docker-compose-plugin`.
   - Enables and starts the Docker service.
   - Adds the default `ec2-user` to the `docker` group.

3. **eksctl Installation**
   - Detects architecture (`amd64` by default).
   - Downloads the latest `eksctl` release from GitHub.
   - Verifies checksum (optional).
   - Installs `eksctl` into `/usr/local/bin`.

4. **kubectl Installation**
   - Downloads the Amazon EKS release binary (`1.35.2`).
   - Makes it executable and places it in `$HOME/bin`.
   - Updates `PATH` to include `$HOME/bin`.

---

## 🛠️ Verification

After the instance boots, verify installations:

```bash
docker --version
eksctl version
kubectl version --client
