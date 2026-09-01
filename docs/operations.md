# Operations Notes

## Runtime Checks

- `/health` confirms the process is alive and can serve traffic.
- `/ready` exposes lightweight readiness metadata used by deployment checks.
- The Docker image includes a container healthcheck against `/health`.
- `SERVICE_VERSION` is surfaced by the app so build identity can be verified after deployment.

## Pipeline Gates

```text
application tests
  -> Docker image build
  -> Terraform format and validation
  -> Ansible syntax checks
  -> deploy only after infrastructure and configuration checks pass
```

## Platform Engineering Focus

The project is deliberately small, but it models the platform pieces around a service:

- application package
- container artifact
- infrastructure definitions
- configuration management
- delivery pipeline
- health and readiness checks
