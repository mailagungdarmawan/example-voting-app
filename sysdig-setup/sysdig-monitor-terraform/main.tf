terraform {
  required_version = ">= 0.12"
  required_providers {
      sysdig = {
        source  = "sysdiglabs/sysdig"
      }
  }
}

provider "google" {
  project = "awesome-sylph-443516-n0"
  region = "us-central1"
}

provider "sysdig" {
  sysdig_monitor_url = "https://app.au1.sysdig.com"
  sysdig_monitor_api_token = "71cb9e8b-5e1c-466a-a068-e0303dad9906"
}

module "sysdig_monitor_cloud_account" {
  source = "github.com/sysdiglabs/terraform-gcp-monitor-for-cloud/single-project"
  gcp_project_id = "awesome-sylph-443516-n0"
}
