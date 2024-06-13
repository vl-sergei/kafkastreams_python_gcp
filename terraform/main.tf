# terraform {
#   backend "gcs" {}
# }

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "random" {}

resource "random_pet" "random_suffix" {
  keepers = {
    project = var.project
    region  = var.region
    zone    = var.zone
  }
}

resource "google_storage_bucket" "storage_bucket" {
  name          = "storage-bucket-${random_pet.random_suffix.id}"
  location      = var.location
  force_destroy = false
  storage_class = "STANDARD"
}


resource "google_storage_bucket_object" "upload_files" {
  for_each = fileset("D:/Users/Sergei/Documents/Python_Scripts/Kafka_streams/m12kafkastreams/", "**")

  name   = each.value
  source = "D:/Users/Sergei/Documents/Python_Scripts/Kafka_streams/m12kafkastreams/${each.value}"
  bucket = google_storage_bucket.storage_bucket.name

  depends_on = [
    google_storage_bucket.storage_bucket,
    google_storage_bucket_iam_binding.binding
  ]
}


resource "google_service_account" "service_account" {
  account_id   = "gcs-${random_pet.random_suffix.id}-rw"
  display_name = "Service Account for RW"
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = "storage-bucket-${random_pet.random_suffix.id}"
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
  depends_on = [google_storage_bucket.storage_bucket, google_service_account.service_account]
}

resource "google_container_cluster" "kubernetes_cluster" {
  name                = "k8s-cluster-${random_pet.random_suffix.id}"
  location            = var.zone
  initial_node_count  = 3
  deletion_protection = false
  node_config {
    machine_type    = "n1-standard-4"
    service_account = google_service_account.service_account.email
    disk_size_gb    = 50
  }
  depends_on = [google_project_service.container_service, google_storage_bucket_iam_binding.binding]
}

resource "google_project_service" "container_service" {
  service                    = "container.googleapis.com"
  disable_dependent_services = true
}
