## Grafana Pyroscope

Enabling profiling in the app you want monitored, then add annotations:

```yaml
podAnnotations:
  profiles.grafana.com/cpu.scrape: "true"
  profiles.grafana.com/cpu.port: "8083"
  profiles.grafana.com/memory.scrape: "true"
  profiles.grafana.com/memory.port: "8083"
```
