# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains ArgoCD manifests for deploying Grafana Pyroscope (continuous profiling platform) to a Kubernetes cluster using the app-of-apps pattern.

## Architecture

### Deployment Pattern

- **App-of-Apps**: This repository is auto-discovered by the deployer ApplicationSet which scans for `deploy/appset.yaml` files
- **ArgoCD Integration**: ArgoCD ApplicationSet automatically deploys the Pyroscope Helm chart
- **Target Environment**: Deploys to the `observability` namespace in clusters labeled `active: 'true'`

### Key Files

- [deploy/project.yaml](deploy/project.yaml) - ArgoCD project resource defining permissions and allowed sources/destinations
- [deploy/appset.yaml](deploy/appset.yaml) - ArgoCD ApplicationSet that deploys the Pyroscope Helm chart
- [deploy/pyroscope-values.yaml](deploy/pyroscope-values.yaml) - Reference Helm values (embedded in appset.yaml)

### Infrastructure Details

- **Helm Chart**: `grafana/pyroscope` version 1.15.1 from https://grafana.github.io/helm-charts
- **Sync Policy**: Auto-sync enabled with prune and self-heal
- **Ingress**: Configured for `pyroscope.pkflores.io` with nginx ingress controller and cert-manager
- **Persistence**: Currently disabled (ephemeral storage) - set `enabled: true` in appset.yaml for production use

## Common Commands

### ArgoCD Application Management

```bash
# View application status
kubectl get application -n argocd | grep pyroscope
kubectl describe application pyroscope-in-cluster -n argocd

# Sync the application manually
argocd app sync pyroscope-in-cluster

# View application diff
argocd app diff pyroscope-in-cluster
```

### Deployment Monitoring

```bash
# View deployed resources
kubectl get all -n observability -l app.kubernetes.io/name=pyroscope

# Check Pyroscope logs
kubectl logs -n observability -l app.kubernetes.io/name=pyroscope

# Port-forward to access UI locally
kubectl port-forward -n observability svc/pyroscope 4040:4040
```

### Making Changes

When modifying the deployment:

1. Edit [deploy/appset.yaml](deploy/appset.yaml) (Helm values are embedded in this file)
2. Commit and push changes
3. ArgoCD will automatically detect and sync changes (or manually sync)

```bash
# Apply changes locally for testing
kubectl apply -f deploy/project.yaml
kubectl apply -f deploy/appset.yaml
```

## Application Profiling Setup

To enable profiling for applications monitored by Pyroscope, add these pod annotations:

```yaml
podAnnotations:
  profiles.grafana.com/cpu.scrape: "true"
  profiles.grafana.com/cpu.port: "8083"
  profiles.grafana.com/memory.scrape: "true"
  profiles.grafana.com/memory.port: "8083"
```

## Repository Structure

This repository follows the standard app-of-apps pattern used across the homelab infrastructure:

- `deploy/` - ArgoCD manifests
  - `project.yaml` - ArgoCD AppProject
  - `appset.yaml` - ArgoCD ApplicationSet with embedded Helm values
  - `pyroscope-values.yaml` - Reference values file (not used directly)

## Migration Notes

This repository was migrated from Terraform-managed deployment to ArgoCD ApplicationSet. The Terraform files have been removed but can be found in git history if needed.
