locals {
  project = "awesome-sylph-443516-n0"
  services = [
    "pubsub.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

provider "google" {
  project     = local.project
  region      = "us-west1"
}

resource "google_project_service" "enable_cdr_ciem_apis" {
  project            = local.project

  for_each           = toset(local.services)
  service            = each.value
  disable_on_destroy = false
}

output "enabled_projects" {
  value = distinct([for service in local.services : google_project_service.enable_cdr_ciem_apis[service].project])
}

output "enabled_services" {
  value = [for service in local.services : google_project_service.enable_cdr_ciem_apis[service].service]
}