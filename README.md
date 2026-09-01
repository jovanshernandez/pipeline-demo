# Pipeline Demo

End-to-end platform engineering demo that connects application delivery, infrastructure provisioning, and configuration management.

The project demonstrates how a small service can move through a delivery pipeline:

1. Test a Python web service
2. Build a Docker image
3. Validate Kubernetes manifests
4. Validate Terraform infrastructure
5. Run Ansible syntax checks
6. Provision Jenkins and web hosts in AWS

## What This Shows

- Jenkins pipeline design with separate test, build, IaC, and configuration stages
- Containerized Python service with health and readiness checks
- Kubernetes deployment manifests with probes and resource requests
- GitHub Actions checks for tests, image build, and manifest rendering
- Terraform-managed EC2 hosts and security groups
- Ansible playbooks for Jenkins and Docker host bootstrapping
- Separation between Jenkins controller infrastructure and web application infrastructure
- Runtime build metadata exposed through `SERVICE_VERSION`

## Repository Layout

```text
.
├── Jenkinsfile
├── docs/
│   └── operations.md
├── ansible/
│   ├── provision_jenkins.yaml
│   └── provision_web.yaml
├── docker/
│   ├── Dockerfile
│   ├── hello.py
│   ├── requirements.txt
│   └── test_hello.py
├── k8s/
│   ├── base/
│   └── overlays/
├── scripts/
│   └── smoke-test.sh
└── terraform/
    ├── jenkins/
    │   └── main.tf
    └── web/
        └── main.tf
```

## Local App Workflow

```bash
cd docker
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest
docker build -t pipeline-demo:local .
docker run --rm -p 8000:8000 pipeline-demo:local
curl http://localhost:8000/health
curl http://localhost:8000/ready
./scripts/smoke-test.sh http://localhost:8000
```

## Kubernetes Workflow

Render the local overlay before applying it to a cluster:

```bash
kubectl kustomize k8s/overlays/local
```

## Infrastructure Workflow

Each Terraform stack can be validated independently:

```bash
cd terraform/jenkins
terraform init
terraform validate
terraform plan

cd ../web
terraform init
terraform validate
terraform plan
```

## Pipeline Stages

The Jenkinsfile is written as a portfolio-friendly delivery pipeline:

- `Test application`: installs Python dependencies and runs tests
- `Build image`: builds the Docker artifact
- `Validate Kubernetes manifests`: renders the local Kustomize overlay
- `Validate Terraform`: runs `terraform fmt` and `terraform validate` for each stack
- `Validate Ansible`: syntax-checks both provisioning playbooks

## Security Notes

- SSH ingress is parameterized through `ssh_cidr_blocks`
- Web ingress is isolated to the application stack
- EC2 metadata requires IMDSv2
- Root volumes are encrypted by default
- AWS profile names are variables, not hard-coded personal workstation values

## Resume Positioning

Use this project on the Platform Engineer resume as a concise delivery-platform example: tests, image build, Kubernetes manifest validation, Terraform validation, Ansible validation, and runtime health/readiness checks. It can support the SRE resume, but `market-risk-platform` is the stronger reliability-facing project.
