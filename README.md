# OpenTelemetry POC

Deploys an OpenTelemetry Collector and Target Allocator as plain Kubernetes Deployments in `tenant-hawk-hawk-test`. No OpenTelemetry Operator, OpenTelemetry CRDs, ClusterRole, or ClusterRoleBinding.

## Before install

1. ServiceMonitor and PodMonitor CRDs must already exist in the cluster.
2. Edit `values.yaml` and set `dynatrace.endpoint` to the Dynatrace OTLP base URL, for example `https://<environment-id>.live.dynatrace.com/api/v2/otlp`.
3. Put a Dynatrace API token with `metrics.ingest` in `examples/01-dynatrace-secret.yaml`.

```bash
kubectl apply -f examples/01-dynatrace-secret.yaml
```

## Install

```bash
helm template hawk-opentelemetry . -n tenant-hawk-hawk-test

helm upgrade --install hawk-opentelemetry . \
  -n tenant-hawk-hawk-test
```

## Validate

```bash
kubectl -n tenant-hawk-hawk-test get pods
kubectl -n tenant-hawk-hawk-test get deploy
kubectl -n tenant-hawk-hawk-test get svc
kubectl -n tenant-hawk-hawk-test get roles
kubectl -n tenant-hawk-hawk-test get rolebindings

kubectl -n tenant-hawk-hawk-test auth can-i list pods \
  --as=system:serviceaccount:tenant-hawk-hawk-test:tenant-hawk-otel
kubectl -n tenant-hawk-hawk-test auth can-i list servicemonitors.monitoring.coreos.com \
  --as=system:serviceaccount:tenant-hawk-hawk-test:tenant-hawk-otel
kubectl -n tenant-hawk-hawk-test auth can-i list podmonitors.monitoring.coreos.com \
  --as=system:serviceaccount:tenant-hawk-hawk-test:tenant-hawk-otel
```

```bash
kubectl -n tenant-hawk-hawk-test logs deploy/hawk-opentelemetry-targetallocator
kubectl -n tenant-hawk-hawk-test logs deploy/hawk-opentelemetry-collector
```

Discovered jobs and targets allocated to the Collector pod:

```bash
kubectl -n tenant-hawk-hawk-test port-forward svc/hawk-opentelemetry-targetallocator 8080:8080
curl -s localhost:8080/jobs
COLLECTOR_POD=$(kubectl -n tenant-hawk-hawk-test get pod -l app.kubernetes.io/component=opentelemetry-collector -o jsonpath='{.items[0].metadata.name}')
curl -s localhost:8080/scrape_configs
# After /jobs lists a job name:
# curl -s "localhost:8080/jobs/<job>/targets?collector_id=${COLLECTOR_POD}"
```

Collector scrape and Dynatrace export show up in the Collector log as successful scrapes and the absence of `otlphttp/dynatrace` export errors.
