provider "google" {
  project = "mern app"  # Replace with your GCP project ID
  region  = "europe-west1"      # Choose a region
  zone    = "europe-west1-d"    # Choose a zone
}

# Frontend (React) Instance
resource "google_compute_instance" "frontend" {
  name         = "mern-frontend"
  machine_type = "f1-micro"   # Choose a small instance type for frontend
  zone         = "europe-west1-d"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20210121"  # Ubuntu 20.04
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Allows external IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update && apt install -y nodejs npm
    cd /home/ubuntu
    git clone https://your-repository-url/frontend.git
    cd frontend
    npm install
    npm run build
    npm install -g serve
    serve -s build -l 3000
  EOT
}

# Backend (Node.js/Express) Instance
resource "google_compute_instance" "backend" {
  name         = "mern-backend"
  machine_type = "f1-micro"   # Choose a small instance type for backend
  zone         = "europe-west1-d"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20210121"  # Ubuntu 20.04
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Allows external IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update && apt install -y nodejs npm
    cd /home/ubuntu
    git clone https://your-repository-url/backend.git
    cd backend
    npm install
    npm start
  EOT
}

# Firewall rules for Frontend and Backend
resource "google_compute_firewall" "allow_frontend" {
  name    = "allow-frontend"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  target_tags = ["frontend"]
}

resource "google_compute_firewall" "allow_backend" {
  name    = "allow-backend"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  target_tags = ["backend"]
}

# Firewall rule for allowing HTTP/HTTPS traffic (optional)
resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["frontend"]
}
