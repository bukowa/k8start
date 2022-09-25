<a href="https://www.digitalocean.com/?refcode=97c5fc2f1bd1&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg" alt="DigitalOcean Referral Badge" /></a>

1. Create [digitalocean](https://m.do.co/c/97c5fc2f1bd1) cluster, for ex. with [terraform](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster) in this git repo:
```bash
$ export DIGITALOCEAN_TOKEN=
$ terraform init
$ terraform apply
# overrides config
$ file=$(terraform output -raw kube_config_path) && terraform output -raw kube_config > $file
# or use multiple configs ex. KUBECONFIG="/home/user/.kube/cluster1:/home/user/.kube/cluster2"
```
2. [Install argocd](https://argo-cd.readthedocs.io/en/stable/):
```bash
kubectl create namespace argocd && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -f configmap.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443
argocd login localhost:8080 --username=admin --password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd app create starter --repo https://github.com/bukowa/k8start.git --dest-server https://kubernetes.default.svc --path=.
argocd app sync starter
```
3. Point DNS A records to LoadBalancer.


Debug helm template;
```
helm template --debug .
```

!!!!
https://argo-cd.readthedocs.io/en/stable/operator-manual/health/#argocd-app
!!!!
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
  name: argocd-cm
data:
  resource.exclusions: |
    - apiGroups:
      - cilium.io
      kinds:
      - CiliumIdentity
      clusters:
      - "*"

```