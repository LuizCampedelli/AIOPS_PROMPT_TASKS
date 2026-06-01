# Plan to Modernize Kubernetes Deployment Manifest

This document outlines the steps to upgrade the `chronos-api` Kubernetes Deployment to align with modern best practices for production environments.

### 1. Increase Replica Count for High Availability

*   **Problem:** The current `replicas: 1` creates a single point of failure. If the pod crashes, the application becomes unavailable.
*   **Solution:** Increase the replica count to at least `3`. This ensures that if one pod goes down, another is available to handle requests, providing high availability.

### 2. Use Specific Docker Image Tags

*   **Problem:** The `image: chronos-api:latest` tag is mutable and can lead to unpredictable deployments. It's difficult to track which version of the code is running and makes rollbacks challenging.
*   **Solution:** Replace `latest` with a specific, immutable image tag, such as a semantic version (`chronos-api:v1.2.3`) or a git commit SHA (`chronos-api:a1b2c3d`). This ensures that every deployment is consistent and reproducible.

### 3. Externalize Secrets

*   **Problem:** Storing secrets like `DB_PASSWORD` and `JWT_SECRET` directly in the Deployment manifest is a major security risk. Anyone with read access to the manifest can see the plaintext secrets.
*   **Solution:**
    1.  Create a Kubernetes `Secret` object to store these sensitive values.
    2.  Modify the Deployment to reference these secrets using `valueFrom` and `secretKeyRef`. This practice securely injects secrets into the container at runtime without exposing them in version control or to unauthorized users.

### 4. Implement Resource Requests and Limits

*   **Problem:** Without resource requests and limits, the pod can either consume excessive resources on a node, affecting other applications, or be scheduled on a node without sufficient resources to run properly.
*   **Solution:** Add `resources` block with `requests` (the amount of resources the pod needs to start) and `limits` (the maximum amount of resources the pod can use). This allows Kubernetes to make smarter scheduling decisions and protects the stability of the node.

### 5. Configure Liveness and Readiness Probes

*   **Problem:** Kubernetes has no way to know if the application inside the container is actually healthy and ready to serve traffic. It only knows if the container process is running.
*   **Solution:**
    *   **Liveness Probe:** Configure a `livenessProbe` (e.g., an HTTP endpoint like `/healthz`) that Kubernetes can periodically check. If the probe fails, Kubernetes will restart the container, helping to recover from deadlocks.
    *   **Readiness Probe:** Configure a `readinessProbe` (e.g., an HTTP endpoint like `/readyz`) to signal when the application is ready to start accepting traffic. If this probe fails, Kubernetes will not send traffic to the pod.

### 6. Enhance Security with a Security Context

*   **Problem:** By default, containers can run as the `root` user, which violates the principle of least privilege and poses a security risk if the container is compromised.
*   **Solution:** Add a `securityContext` to the container spec:
    *   `runAsUser` and `runAsGroup`: Specify a non-root user and group ID for the container process.
    *   `allowPrivilegeEscalation: false`: Prevents the container from gaining more privileges than its parent process.
    *   `runAsNonRoot: true`: Ensures the container will not run as root.

By implementing these changes, we will transform the legacy manifest into a secure, reliable, and production-ready configuration.
