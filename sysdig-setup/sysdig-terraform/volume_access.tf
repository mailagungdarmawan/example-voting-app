module "agentless-scan" {
  source                   = "sysdiglabs/secure/google//modules/agentless-scan"
  version                  = "~>0.3"
  project_id               = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}

resource "sysdig_secure_cloud_auth_account_feature" "agentless_scanning" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_AGENTLESS_SCANNING"
  enabled    = true
  components = [module.agentless-scan.agentless_scan_component_id]
  lifecycle {
      ignore_changes = [flags]
  }
  depends_on = [module.agentless-scan]
  flags = {
    "SCANNING_HOST_CONTAINER_ENABLED": "true",
    "SCANNING_MALWARE_ENABLED": "false"
  }
}