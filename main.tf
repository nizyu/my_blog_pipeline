provider "google" {
  credentials = "${file("${var.gcp_credential_path}")}"
  project     = "${var.gcp_project_id}"
  region      = "us-central1"
}

terraform {
  required_version = "0.10.5"

  backend "gcs" {}
}

resource "google_storage_bucket" "backend" {
  name = "${var.backend_bucket_name}"
}


resource "google_sourcerepo_repository" "my_blog" {
  name = "${var.document_repository}"
}

resource "google_dns_managed_zone" "my_dns" {
  name        = "my-dns"
  dns_name    = "${var.website_domain}."
  description = "DNS of my domain"
}

resource "google_dns_record_set" "my_website" {
  name = "${var.website_host}.${google_dns_managed_zone.my_dns.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.my_dns.name}"

  rrdatas = ["c.storage.googleapis.com."]
}

resource "google_storage_bucket" "website" {
  depends_on = ["google_dns_record_set.my_website"]

  name = "${var.website_host}.${var.website_domain}"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}


output "dns_servars" {
  value = "${google_dns_managed_zone.my_dns.name_servers}"
}
