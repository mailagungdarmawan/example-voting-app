locals {
  project = "awesome-sylph-443516-n0"
  services = [
    "cloudasset.googleapis.com",
    "admin.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

provider "google" {
  project     = local.project
  region      = "us-central1"
}

resource "google_project_service" "enable_cspm_apis" {
  project            = local.project

  for_each           = toset(local.services)
  service            = each.value
  disable_on_destroy = false
}

output "enabled_projects" {
  value = distinct([for service in local.services : google_project_service.enable_cspm_apis[service].project])
}

output "enabled_services" {
  value = [for service in local.services : google_project_service.enable_cspm_apis[service].service]
}