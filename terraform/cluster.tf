provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "bootstrap" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.consul_server_size}"
    security_groups = ["${aws_security_group.consul.name}"]
    key_name = "${var.key_name}"

    tags {
      Name = "consul-bootstrap"
    }

    connection {
      user = "ubuntu"
      key_file = "${var.key_path}"
      agent = "false"
    }

    provisioner "remote-exec" {
    inline = [
        "echo ${var.datadog_api_key} > /tmp/datadog-api-key",
        "echo ${var.datadog_app_key} > /tmp/datadog-app-key",
        "echo 'consul-server' > /tmp/datadog-tag"
      ]
    }

    provisioner "remote-exec" {
    scripts = [
        "./scripts/datadog.sh",
        "./scripts/hosts-watch.sh",
        "./scripts/configure-bootstrap.sh",
        "./scripts/hosts.sh"
      ]
    }
}

output "server_address" {
    value = "${aws_instance.bootstrap.public_dns}"
}

resource "aws_instance" "server1" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.consul_server_size}"
    security_groups = ["${aws_security_group.consul.name}"]
    key_name = "${var.key_name}"

    tags {
      Name = "consul-server1"
    }

    connection {
      user = "ubuntu"
      key_file = "${var.key_path}"
      agent = "false"
    }

    provisioner "remote-exec" {
    inline = [
        "echo ${aws_instance.bootstrap.private_dns} > /tmp/consul-server-addr",
        "echo ${var.datadog_api_key} > /tmp/datadog-api-key",
        "echo ${var.datadog_app_key} > /tmp/datadog-app-key",
        "echo 'consul-server' > /tmp/datadog-tag"
      ]
    }

    provisioner "remote-exec" {
    scripts = [
        "./scripts/datadog.sh",
        "./scripts/hosts-watch.sh",
        "./scripts/configure-servers.sh",
        "./scripts/hosts.sh"
      ]
    }
}

resource "aws_instance" "server2" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.consul_server_size}"
    security_groups = ["${aws_security_group.consul.name}"]
    key_name = "${var.key_name}"

    tags {
      Name = "consul-server2"
    }

    connection {
      user = "ubuntu"
      key_file = "${var.key_path}"
      agent = "false"
    }

    provisioner "remote-exec" {
    inline = [
        "echo ${aws_instance.bootstrap.private_dns} > /tmp/consul-server-addr",
        "echo ${var.datadog_api_key} > /tmp/datadog-api-key",
        "echo ${var.datadog_app_key} > /tmp/datadog-app-key",
        "echo 'consul-server' > /tmp/datadog-tag"
      ]
    }

    provisioner "remote-exec" {
    scripts = [
        "./scripts/datadog.sh",
        "./scripts/hosts-watch.sh",
        "./scripts/configure-servers.sh",
        "./scripts/hosts.sh"
      ]
    }
}

resource "aws_instance" "client" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.consul_client_size}"
    security_groups = ["${aws_security_group.consul.name}"]
    key_name = "${var.key_name}"
    count = "${var.count}"

    tags {
      Name = "kvexpress-demo"
    }

    connection {
      user = "ubuntu"
      key_file = "${var.key_path}"
      agent = "false"
    }

    provisioner "remote-exec" {
    inline = [
        "echo ${aws_instance.bootstrap.private_dns} > /tmp/consul-server-addr",
        "echo ${aws_instance.server1.private_dns} > /tmp/server1-addr",
        "echo ${aws_instance.server2.private_dns} > /tmp/server2-addr",
        "echo ${var.datadog_api_key} > /tmp/datadog-api-key",
        "echo 'consul-agent' > /tmp/datadog-tag"
      ]
    }

    provisioner "remote-exec" {
    scripts = [
        "./scripts/datadog.sh",
        "./scripts/hosts-watch.sh",
        "./scripts/configure-clients.sh"
      ]
    }
}
