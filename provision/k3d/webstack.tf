
module "webstack" {
  depends_on = [module.argocd]
  source = "../../charts/webstack"
}