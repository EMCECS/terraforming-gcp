resource "google_compute_address" "jumpbox-ip" {
  count = "${var.count}"
  name = "${var.env_id}-jumpbox-ip"
}

output "jumpbox_url" {
    value = "${google_compute_address.jumpbox-ip.address}:22"
}

output "external_ip" {
    value = "${google_compute_address.jumpbox-ip.address}"
}
