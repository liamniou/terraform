output "ip" {
  value = "${aws_instance.python.public_ip}"
}