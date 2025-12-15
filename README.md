# pyroscope

ArgoCD-managed deployment of Grafana Pyroscope for continuous profiling of applications.

## Overview

This repository contains the ArgoCD ApplicationSet configuration for deploying [Grafana Pyroscope](https://grafana.com/oss/pyroscope/) to enable continuous profiling of applications running in Kubernetes.

Pyroscope collects and visualizes profiling data (CPU, memory, goroutines, etc.) to help identify performance bottlenecks and optimize resource usage.

## Architecture

- **Chart**: [pyroscope](https://grafana.github.io/helm-charts) v1.15.1
- **Namespace**: `observability`
- **Ingress**: `pyroscope.pkflores.io` (nginx ingress with cert-manager)
- **Deployment**: Managed via ArgoCD ApplicationSet, auto-discovered by the deployer app-of-apps

## Files

### ArgoCD Configuration
- **[deploy/project.yaml](deploy/project.yaml)**: ArgoCD AppProject definition for pyroscope
- **[deploy/appset.yaml](deploy/appset.yaml)**: ApplicationSet that deploys the Helm chart with embedded Helm values

## Configuration

### Resource Limits

Configured for local/lab environment:

- **CPU Request**: 100m
- **Memory Request**: 256Mi
- **Memory Limit**: 512Mi

### Storage

Persistence is currently **disabled** for quick experiments. For production use:
1. Edit [deploy/appset.yaml](deploy/appset.yaml)
2. Set `persistence.enabled: true`
3. Configure appropriate `storageClass`

### Ingress

- **Hostname**: pyroscope.pkflores.io
- **Ingress Class**: nginx
- **TLS**: Managed by cert-manager (vault-cert-manager-issuer)
- **External DNS**: Automatically configured

## Usage

### Enabling Profiling for Applications

To enable profiling for an application monitored by Pyroscope, add these pod annotations:

```yaml
podAnnotations:
  profiles.grafana.com/cpu.scrape: "true"
  profiles.grafana.com/cpu.port: "8083"
  profiles.grafana.com/memory.scrape: "true"
  profiles.grafana.com/memory.port: "8083"
```

### Accessing the UI

Access Pyroscope at: https://pyroscope.pkflores.io

### Profile Types

Pyroscope can collect various profile types:
- **CPU**: CPU usage over time
- **Memory**: Memory allocations and heap usage
- **Goroutines**: Number of goroutines (Go applications)
- **Block**: Blocking operations
- **Mutex**: Mutex contention

## Deployment

This repository is automatically discovered and deployed by the [deployer](https://github.com/pkflores-lab/deployer) app-of-apps pattern, which scans for repositories in the `pkflores-lab` GitHub organization containing `deploy/appset.yaml`.

### Prerequisites

1. ArgoCD installed and configured
2. nginx-ingress-controller installed
3. cert-manager installed with vault-cert-manager-issuer configured
4. external-dns installed (optional, for automatic DNS management)

### Manual Deployment

If needed, you can manually apply the resources:

```bash
# Apply ArgoCD project
kubectl apply -f deploy/project.yaml

# Apply pyroscope ApplicationSet
kubectl apply -f deploy/appset.yaml

# Wait for pyroscope to be ready
kubectl wait --for=condition=available --timeout=300s deployment/pyroscope -n observability
```

## Troubleshooting

### Check Pyroscope logs
```bash
kubectl logs -n observability -l app.kubernetes.io/name=pyroscope
```

### Check application status
```bash
kubectl get application -n argocd | grep pyroscope
kubectl describe application pyroscope-in-cluster -n argocd
```

### Check deployment status
```bash
kubectl get all -n observability -l app.kubernetes.io/name=pyroscope
```

### Verify ingress
```bash
kubectl get ingress -n observability
kubectl describe ingress pyroscope -n observability
```

### Test profiling endpoint
```bash
# Port-forward to pyroscope
kubectl port-forward -n observability svc/pyroscope 4040:4040

# Access locally
open http://localhost:4040
```

## Integration Examples

### Go Application

```go
import "github.com/grafana/pyroscope-go"

func main() {
    pyroscope.Start(pyroscope.Config{
        ApplicationName: "my-app",
        ServerAddress:   "http://pyroscope.observability:4040",
        ProfileTypes: []pyroscope.ProfileType{
            pyroscope.ProfileCPU,
            pyroscope.ProfileAllocObjects,
            pyroscope.ProfileAllocSpace,
            pyroscope.ProfileInuseObjects,
            pyroscope.ProfileInuseSpace,
        },
    })

    // Your application code
}
```

### Python Application

```python
import pyroscope

pyroscope.configure(
    application_name="my-python-app",
    server_address="http://pyroscope.observability:4040",
)

# Your application code
```

### Node.js Application

```javascript
const Pyroscope = require('@pyroscope/nodejs');

Pyroscope.init({
  appName: 'my-nodejs-app',
  serverAddress: 'http://pyroscope.observability:4040',
});

// Your application code
```

## Migration from Terraform

This deployment was migrated from Terraform-managed ArgoCD application to a standalone ArgoCD ApplicationSet. The Helm release name (`pyroscope`) and namespace (`observability`) remain the same to ensure continuity.

### What Changed
- Pyroscope deployment: Moved from Terraform to ArgoCD ApplicationSet
- ArgoCD project: Moved from Terraform to static Kubernetes manifest
- Configuration: Helm values now embedded in ApplicationSet instead of external file

## References

- [Grafana Pyroscope Documentation](https://grafana.com/docs/pyroscope/latest/)
- [Pyroscope GitHub](https://github.com/grafana/pyroscope)
- [Continuous Profiling Guide](https://grafana.com/docs/pyroscope/latest/get-started/)
