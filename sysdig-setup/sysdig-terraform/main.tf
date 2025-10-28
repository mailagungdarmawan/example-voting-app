terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~>1.48"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "https://app.au1.sysdig.com"
  sysdig_secure_api_token = "b6304e0a-595f-4129-b23b-8b1da0fe1f95"
}

provider "google" {
  project = "awesome-sylph-443516-n0"
  region  = "us-central1"
}

module "onboarding" {
  source     = "sysdiglabs/secure/google//modules/onboarding"
  version    = "~>0.6"
  project_id = "awesome-sylph-443516-n0"
}

module "config-posture" {
  source                   = "sysdiglabs/secure/google//modules/config-posture"
  version                  = "~>0.6"
  project_id               = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}

resource "sysdig_secure_cloud_auth_account_feature" "config_posture" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_CONFIG_POSTURE"
  enabled    = true
  components = [module.config-posture.service_principal_component_id]
  depends_on = [module.config-posture]
}

resource "sysdig_secure_cloud_auth_account_feature" "identity_entitlement_basic" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_IDENTITY_ENTITLEMENT"
  enabled    = true
  components = [module.config-posture.service_principal_component_id]
  depends_on = [module.config-posture, sysdig_secure_cloud_auth_account_feature.config_posture]
  flags      = { "CIEM_FEATURE_MODE": "basic" }
  lifecycle {
    ignore_changes = [flags, components]
  }
}