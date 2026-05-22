Act as a senior devops engineer, revise the kubernetes infrastructure manifest, which has not being changed over 3 years.

# Before
read this kubernetes manifest yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
spec:
  replicas: 1
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
        image: chronos-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          value: "P@ssw0rd2023!"
        - name: JWT_SECRET
          value: "hvt-jwt-prod-secret"

# After
Create the new manifest, save it in a file as: OUTPUT.md, with the following instructions:

- Need high availability
- version image (Do not use latest tag)
- secrets outside the manifest
- Resource requests and limits
- Livenss and readiness probes
- non-root securityContext
- any other production grade safe practice

# Brigde
Create a plan that will show what is need to make the changes necessary to achieve the "# AFTER" step, add the step to step instruction in an EXPLANATION.md