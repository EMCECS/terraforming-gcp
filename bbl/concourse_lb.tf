output "concourse_target_pool" {
	value = "${google_compute_target_pool.target-pool.name}"
}

output "concourse_lb_ip" {
  value = "${google_compute_address.concourse-address.address}"
}

variable "concourse_lb_count" {}

resource "google_compute_firewall" "firewall-concourse" {
  count = "${var.concourse_lb_count}"
  name    = "${var.env_id}-concourse-open"
  network = "${google_compute_network.bbl-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["443", "2222"]
  }

  target_tags = ["concourse"]
}

resource "google_compute_address" "concourse-address" {
  count = "${var.concourse_lb_count}"
  name = "${var.env_id}-concourse"
}

resource "google_compute_target_pool" "target-pool" {
  count = "${var.concourse_lb_count}"
  name = "${var.env_id}-concourse"

  session_affinity = "NONE"
}

resource "google_compute_forwarding_rule" "ssh-forwarding-rule" {
  count       = "${var.concourse_lb_count}"
  name        = "${var.env_id}-concourse-ssh"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "2222"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}

resource "google_compute_forwarding_rule" "https-forwarding-rule" {
  count       = "${var.concourse_lb_count}"
  name        = "${var.env_id}-concourse-https"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}
