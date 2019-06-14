resource "aws_vpc" "personal-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Personal-VPC"
  }
}

resource "aws_subnet" "public-subnet-1" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = "${aws_vpc.personal-vpc.id}"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_internet_gateway" "production-igw" {
  vpc_id = "${aws_vpc.personal-vpc.id}"

  tags = {
    Name = "Personal-IGW"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.personal-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.production-igw.id}"
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id      = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = "${aws_route_table.public-route-table.id}"
  gateway_id             = "${aws_internet_gateway.production-igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "ec2_public_security_group" {
  name = "EC2-Public-SG"
  description = "Internet reaching access for EC2 Instances"
  vpc_id = "${aws_vpc.personal-vpc.id}"

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    # cidr_blocks = ["37.17.56.164/32", "134.17.152.0/24"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "rutracker_notifier_bot_setup_script" {
  template = "${file("templates/setup_rutracker_notifier_bot.tpl")}"
  vars = {
    token              = "${var.rutracker_notifier_bot.token}"
    database_name      = "${var.rutracker_notifier_bot.database_name}"
    rutracker_login    = "${var.rutracker_notifier_bot.rutracker_login}"
    rutracker_password = "${var.rutracker_notifier_bot.rutracker_password}"
  }
}

data "template_file" "transmission_management_bot_setup_script" {
  template = "${file("templates/setup_transmission_management_bot.tpl")}"
  vars = {
    token                     = "${var.transmission_management_bot.token}"
    transmission_host         = "${var.transmission_management_bot.transmission_host}"
    transmission_port         = "${var.transmission_management_bot.transmission_port}"
    transmission_user         = "${var.transmission_management_bot.transmission_user}"
    transmission_password     = "${var.transmission_management_bot.transmission_password}"
    transmission_download_dir = "${var.transmission_management_bot.transmission_download_dir}"
  }
}

data "template_file" "zoya_monitoring_bot_setup_script" {
  template = "${file("templates/setup_zoya_monitoring_bot.tpl")}"
  vars = {
    token          = "${var.zoya_monitoring_bot.token}"
    scope          = "${var.zoya_monitoring_bot.scope}"
    spreadsheet_id = "${var.zoya_monitoring_bot.spreadsheet_id}"
    sheet_id       = "${var.zoya_monitoring_bot.sheet_id}"
  }
}

data "template_file" "shared_budget_bot_setup_script" {
  template = "${file("templates/setup_shared_budget_bot.tpl")}"
  vars = {
    token          = "${var.shared_budget_bot.token}"
    person_1_tg_id = "${var.shared_budget_bot.person_1_tg_id}"
    person_2_tg_id = "${var.shared_budget_bot.person_2_tg_id}"
    scope          = "${var.shared_budget_bot.scope}"
    spreadsheet_id = "${var.shared_budget_bot.spreadsheet_id}"
    sheet_id       = "${var.shared_budget_bot.sheet_id}"
  }
}

resource "aws_instance" "python" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  key_name                    = "personal-key-pair"
  subnet_id                   = "${aws_subnet.public-subnet-1.id}"
  security_groups             = ["${aws_security_group.ec2_public_security_group.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  provisioner "file" {
    destination = "/home/ubuntu/setup_1.sh"
    content     = "${data.template_file.rutracker_notifier_bot_setup_script.rendered}"
  }

  provisioner "file" {
    destination = "/home/ubuntu/setup_2.sh"
    content     = "${data.template_file.transmission_management_bot_setup_script.rendered}"
  }

  provisioner "file" {
    destination = "/home/ubuntu/setup_3.sh"
    content     = "${data.template_file.zoya_monitoring_bot_setup_script.rendered}"
  }

  provisioner "file" {
    destination = "/home/ubuntu/setup_4.sh"
    content     = "${data.template_file.shared_budget_bot_setup_script.rendered}"
  }

  provisioner "file" {
    source = "zoya.pickle"
    destination = "/tmp/zoya.pickle"
  }

  provisioner "file" {
    source = "budget.pickle"
    destination = "/tmp/budget.pickle"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /home/ubuntu/setup_1.sh",
      "sudo sh /home/ubuntu/setup_2.sh",
      "sudo sh /home/ubuntu/setup_3.sh",
      "sudo sh /home/ubuntu/setup_4.sh",
    ]
  }

  connection {
    host        = "${aws_instance.python.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("~/.ssh/personal-key-pair.pem")}"
  }
}
