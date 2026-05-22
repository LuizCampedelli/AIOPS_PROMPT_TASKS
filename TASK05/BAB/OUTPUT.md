apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
  labels:
    app: chronos-api
spec:
  replicas: 2 # Increased for High Availability
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