pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    IMAGE_NAME       = 'pipeline-demo'
    TF_IN_AUTOMATION = 'true'
  }

  stages {
    stage('Test application') {
      steps {
        dir('docker') {
          sh 'python3 -m venv .venv'
          sh '.venv/bin/python -m pip install -r requirements.txt'
          sh '.venv/bin/python -m pytest -q'
        }
      }
    }

    stage('Build image') {
      steps {
        sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} docker'
      }
    }

    stage('Validate Kubernetes manifests') {
      steps {
        sh 'kubectl kustomize k8s/overlays/local'
      }
    }

    stage('Validate Terraform') {
      parallel {
        stage('Jenkins stack') {
          steps {
            dir('terraform/jenkins') {
              sh 'terraform fmt -check'
              sh 'terraform init -backend=false -input=false'
              sh 'terraform validate'
            }
          }
        }

        stage('Web stack') {
          steps {
            dir('terraform/web') {
              sh 'terraform fmt -check'
              sh 'terraform init -backend=false -input=false'
              sh 'terraform validate'
            }
          }
        }
      }
    }

    stage('Validate Ansible') {
      steps {
        sh 'ansible-playbook --syntax-check ansible/provision_jenkins.yaml'
        sh 'ansible-playbook --syntax-check ansible/provision_web.yaml'
      }
    }
  }
}
