variable "project" {
  description = "ID of your GCP project"
  type        = string
  default     = "epam-hw-424120"
}

variable "location" {
  description = "Location of GCS bucket"
  type        = string
  default     = "EU"
}

variable "region" {
  description = "Region for deployment"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone in the region for deployment"
  type        = string
  default     = "europe-west1-b"
}
