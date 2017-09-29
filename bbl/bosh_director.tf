output "bosh_open_tag_name" {
    value = "${google_compute_firewall.bosh-open.name}"
}

output "bosh_director_tag_name" {
	value = "${google_compute_firewall.bosh-director.name}"
}

output "jumpbox_tag_name" {
	value = "${var.env_id}-jumpbox"
}

output "internal_tag_name" {
    value = "${google_compute_firewall.internal.name}"
}

output "director_address" {
	value = "https://${google_compute_address.bosh-external-ip.address}:25555"
}

resource "google_compute_address" "bosh-external-ip" {
  count = "${var.count}"
  name = "${var.env_id}-bosh-external-ip"
}

resource "google_compute_firewall" "external" {
  count = "${var.count}"
  name    = "${var.env_id}-external"
  network = "${google_compute_network.bbl-network.name}"

  source_ranges = ["0.0.0.0/0"]

  allow {
    ports = ["22", "6868", "25555"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-bosh-open"]
}

resource "google_compute_firewall" "bosh-open" {
  count = "${var.count}"
  name    = "${var.env_id}-bosh-open"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-bosh-open"]

  allow {
    ports = ["22", "6868", "8443", "25555"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-bosh-director"]
}

resource "google_compute_firewall" "bosh-director" {
  count = "${var.count}"
  name    = "${var.env_id}-bosh-director"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-bosh-director"]

  allow {
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-internal"]
}

resource "google_compute_firewall" "internal-to-director" {
  count = "${var.count}"
  name    = "${var.env_id}-internal-to-director"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-internal"]

  allow {
    ports = ["4222", "25250", "25777"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-bosh-director"]
}

resource "google_compute_firewall" "jumpbox-to-all" {
  count = "${var.count}"
  name    = "${var.env_id}-jumpbox-to-all"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-jumpbox"]

  allow {
    ports = ["22"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-internal", "${var.env_id}-bosh-director"]
}

resource "google_compute_firewall" "internal" {
  count = "${var.count}"
  name    = "${var.env_id}-internal"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-internal"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  target_tags = ["${var.env_id}-internal"]
}
