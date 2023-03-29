
provider "google" {
  project = "elg5164-terraform-gcp"
  region  = "us-west1"
}

locals {
  bucket_name = "elg5164-terraform-gcp-storage-bucket"
}

resource "google_storage_bucket" "bucket" {
  name     = local.bucket_name
  location = "US"

  versioning {
    enabled = true
  }

  cors_configuration {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_binding" "bucket" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:cloud-storage@system.gserviceaccount.com",
  ]
}

resource "google_compute_backend_bucket" "backend" {
  name        = "elg5164-terraform-gcp-backend-bucket"
  bucket_name = google_storage_bucket.bucket.name
}

resource "google_compute_url_map" "urlmap" {
  name            = "elg5164-terraform-gcp-urlmap"
  default_service = google_compute_backend_bucket.backend.self_link
}

resource "google_compute_target_http_proxy" "http" {
  name    = "elg5164-terraform-gcp-http-proxy"
  url_map = google_compute_url_map.urlmap.self_link
}

resource "google_compute_target_https_proxy" "https" {
  name             = "elg5164-terraform-gcp-https-proxy"
  url_map          = google_compute_url_map.urlmap.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "elg5164-terraform-gcp-http-forwarding-rule"
  target     = google_compute_target_http_proxy.http.self_link
  port_range = "80"

  ip_address = google_compute_global_address.static_ipv4_address.address
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "elg5164-terraform-gcp-https-forwarding-rule"
  target     = google_compute_target_https_proxy.https.self_link
  port_range = "443"

  ip_address = google_compute_global_address.static_ipv4_address.address
}

resource "google_compute_global_address" "static_ipv4_address" {
  name = "elg5164-terraform-gcp-static-ipv4-address"
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  name = "elg5164-terraform-gcp-ssl-certificate"

  managed {
    domains = ["elg5164-terraform-gcp.gtliu.com"]
  }
}

resource "google_storage_bucket_access_control" "bucket_acl" {
  bucket = google_storage_bucket.bucket.name
  role   = "READER"
  entity = "allUsers"
}
