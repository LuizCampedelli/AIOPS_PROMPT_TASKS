apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
  labels:
    app: chronos-api
spec:
  replicas: 3 # Increased for High Availability
  selector:
    matchLabels:
      app: chronos-api
  template:
    metadata:
      labels:
        app: chronos-api
    spec:
      containers:
      - name: api
        image: chronos-api:v1.2.3 # Specific image version
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: chronos-api-secrets # Secret name
              key: DB_PASSWORD
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: chronos-api-secrets # Secret name
              key: JWT_SECRET
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        securityContext:
          runAsUser: 1000
          runAsGroup: 3000
          allowPrivilegeEscalation: false
          runAsNonRoot: true
      securityContext:
        fsGroup: 2000

---
### Why replicas: 1 → 3

The original manifest ran a single pod (`replicas: 1`), making `chronos-api` a **Single Point of Failure (SPOF)**:

| Scenario with replicas: 1 | Impact |
|---------------------------|--------|
| Pod crash or OOM kill | Service fully down until Kubernetes reschedules (30 s – 2 min) |
| Rolling deployment | Brief downtime as the only pod is replaced |
| Node failure or maintenance drain | Service fully unavailable until pod is rescheduled on another node |

Setting `replicas: 3` addresses all three:

- **Fault tolerance**: if one pod crashes, two remain serving traffic — Kubernetes restarts the failed pod in the background with zero user impact.
- **Zero-downtime deployments**: the default rolling update strategy (`maxUnavailable: 1`) takes down one pod at a time while two continue serving, so no request is dropped during a deploy.
- **Load distribution**: traffic is spread across three instances, reducing per-pod pressure and giving headroom before the HPA needs to scale out.
- **Node resilience**: with the default pod anti-affinity, Kubernetes schedules pods across different nodes, so a single node going down does not take the entire service offline.

Three replicas is the minimum recommended baseline for a stateless production API. It satisfies the "high availability" requirement stated in the `# After` section without over-provisioning for a service whose traffic profile is not yet defined.

---
### Companion Kubernetes Secret

To make the above Deployment work, you first need to create a Secret object. Below is an example of how to create it using `kubectl`.

**1. Create secret literals:**

```bash
kubectl create secret generic chronos-api-secrets \
  --from-literal=DB_PASSWORD='your-new-strong-password' \
  --from-literal=JWT_SECRET='your-new-super-secret-jwt-token' \
  --namespace=production
```

**2. Verify the secret:**

```bash
kubectl get secret chronos-api-secrets -n production -o yaml
```
