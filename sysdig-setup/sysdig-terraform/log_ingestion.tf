module "pub-sub" {
  source                   = "sysdiglabs/secure/google//modules/integrations/pub-sub"
  version                  = "~>0.6"
  project_id               = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
  audit_log_config         = [
    {
      service = "allServices"
      log_config = [
        { log_type = "ADMIN_READ" },
        { log_type = "DATA_WRITE" },
        { log_type = "DATA_READ" }
      ]
    }
  ]
  ingestion_sink_filter    = <<EOF
    protoPayload.@type = "type.googleapis.com/google.cloud.audit.AuditLog"
  EOF
  exclude_logs_filter      = [
    {
      name        = "system_principals"
      description = "Exclude system principals"
      filter      = "protoPayload.authenticationInfo.principalEmail=~\"^system\\:.*\" AND (protoPayload.authenticationInfo.principalEmail!~\"^system\\:(anonymous|serviceaccount)*\" OR protoPayload.authenticationInfo.principalEmail=~\"^system\\:serviceaccount\\:kube-system\")"
    },
    {
      name        = "k8s_audit"
      description = "Exclude logs from the clusters control planes"
      filter      = "protoPayload.methodName=~\"^(io\\.k8s|io\\.traefik|us\\.containo|io\\.x-k8s|io\\.gke|org\\.projectcalico|io\\.openshift|io\\.istio)\" AND protoPayload.methodName!~\"secret\""
    },
    {
      name        = "ciulium_control_plane"
      description = "Exclude operations on Cilium"
      filter      = "protoPayload.methodName=~\"^io\\.cilium\" AND protoPayload.methodName!~\"identitites\""
    },
    {
      name        = "monitoring_queries"
      description = "Exclude monitoring queries"
      filter      = "protoPayload.methodName=~\"^com\\.coreos\""
    }
  ]
}

resource "sysdig_secure_cloud_auth_account_feature" "threat_detection" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_THREAT_DETECTION"
  enabled    = true
  components = [module.pub-sub.pubsub_datasource_component_id]
  depends_on = [module.pub-sub]
}

resource "sysdig_secure_cloud_auth_account_feature" "identity_entitlement_advanced" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_IDENTITY_ENTITLEMENT"
  enabled    = true
  components = concat(sysdig_secure_cloud_auth_account_feature.identity_entitlement_basic.components, [module.pub-sub.pubsub_datasource_component_id])
  depends_on = [module.pub-sub]
  flags      = { "CIEM_FEATURE_MODE": "advanced" }
  lifecycle {
    ignore_changes = [flags, components]
  }
}
