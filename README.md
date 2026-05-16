# Pipeline Demo

End-to-end platform engineering demo that connects application delivery, infrastructure provisioning, and configuration management.

The project demonstrates how a small service can move through a delivery pipeline:

1. Test a Python web service
2. Build a Docker image
3. Validate Terraform infrastructure
4. Run Ansible syntax checks
5. Provision Jenkins and web hosts in AWS

## What This Shows

- Jenkins pipeline design with separate test, build, IaC, and configuration stages
- Containerized Python service with health checks
- Terraform-managed EC2 hosts and security groups
- Ansible playbooks for Jenkins and Docker host bootstrapping
- Separation between Jenkins controller infrastructure and web application infrastructure

## Repository Layout

```text
.
├── Jenkinsfile
├── ansible/
│   ├── provision_jenkins.yaml
│   └── provision_web.yaml
├── docker/
│   ├── Dockerfile
│   ├── hello.py
│   ├── requirements.txt
│   └── test_hello.py
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
- `Validate Terraform`: runs `terraform fmt` and `terraform validate` for each stack
- `Validate Ansible`: syntax-checks both provisioning playbooks

## Security Notes

- SSH ingress is parameterized through `ssh_cidr_blocks`
- Web ingress is isolated to the application stack
- EC2 metadata requires IMDSv2
- Root volumes are encrypted by default
- AWS profile names are variables, not hard-coded personal workstation values
