https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/

https://github.com/argoproj/argocd-example-apps/tree/master/apps

Ignoring resources, for ex. cilium while using DigitalOcean:
https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#resource-exclusioninclusion

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
  name: argocd-cm
  namespace: argocd
data:
  resource.exclusions: |
    - apiGroups:
      - cilium.io
      kinds:
      - CiliumIdentity
      clusters:
      - "*"
```