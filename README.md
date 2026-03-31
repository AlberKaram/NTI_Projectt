# NTI Final Project — Cloud DevOps Pipeline

A full DevOps project built on AWS using Terraform, Ansible, Docker, Kubernetes, Helm, Jenkins, and Prometheus.

---

## Architecture Overview

```
GitHub → Jenkins → Docker Build → ECR → EKS (Helm) → Live App
                                              ↑
                                        Prometheus + Grafana
```

**Infrastructure:**
- VPC with public/private subnets across 2 AZs
- EKS cluster with 2 worker nodes
- EC2 instance for Jenkins
- ECR repository for Docker images
- RDS PostgreSQL database

---

## Project Structure

```
.
├── ansible/          # Jenkins server configuration
├── app/
│   ├── api/          # Python Flask backend
│   ├── web/          # Vue.js frontend
│   └── db/           # Database migrations
├── helm/             # Helm chart for Kubernetes deployment
├── kubernetes/       # Raw Kubernetes manifests (reference only)
├── terraform/        # AWS infrastructure as code
└── Jenkinsfile       # CI/CD pipeline definition
```

---

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Helm >= 3
- Docker

---

## Deployment

### 1. Provision Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### 2. Configure Jenkins

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml
```

### 3. Update kubeconfig

```bash
aws eks update-kubeconfig --region us-east-2 --name nti-eks-cluster
```

### 4. Deploy Application

```bash
helm install nti-prod ./helm
```

### 5. Deploy Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

---

## CI/CD Pipeline (Jenkinsfile)

The pipeline runs automatically and includes:

| Stage | Description |
|-------|-------------|
| Checkout | Pull code from GitHub |
| Build API Image | Docker build for Python backend |
| Build Web Image | Docker build for Vue.js frontend |
| Push to ECR | Push images to AWS ECR |
| Deploy to EKS | Helm upgrade on EKS cluster |

---

## Access the App

```bash
kubectl get svc web -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Access Grafana

```bash
# Get password
kubectl --namespace monitoring get secrets monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d

# Port forward
kubectl --namespace monitoring port-forward svc/monitoring-grafana 3000:80
```

Open: `http://localhost:3000` — Username: `admin`

---

## Technologies Used

| Tool | Purpose |
|------|---------|
| Terraform | Infrastructure provisioning |
| Ansible | Configuration management |
| Docker | Containerization |
| Kubernetes (EKS) | Container orchestration |
| Helm | Kubernetes package manager |
| Jenkins | CI/CD automation |
| Prometheus | Metrics collection |
| Grafana | Monitoring dashboards |
| AWS ECR | Docker image registry |

---

## Jenkins Credentials Required

| ID | Type | Description |
|----|------|-------------|
| `aws-credentials` | AWS Credentials | Access Key + Secret Key |

---

## Tear Down

```bash
helm uninstall nti-prod
helm uninstall monitoring -n monitoring
cd terraform && terraform destroy
```
